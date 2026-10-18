import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:renty/core/utils/app_navigator.dart';
import 'package:renty/main.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/secure_storage_service.dart';

/// An HTTP client wrapper that intercepts 401 responses and
/// automatically attempts to refresh the access token.
///
/// SECURITY: Token reads use the in-memory cache ([cachedToken]) populated
/// from Keystore/Keychain at startup. Writes after refresh update both the
/// Keystore/Keychain AND the in-memory cache via [SecureStorageService].
class AuthInterceptorClient extends http.BaseClient {
  final http.Client _inner;
  static bool _isRefreshing = false;
  static final List<Completer<void>> _waitingQueue = [];

  AuthInterceptorClient([http.Client? inner]) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Attach the current token to every request (reads from memory cache)
    final token = cachedToken;
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await _inner.send(request);

    // If 401, try refreshing the token — skip auth endpoints where 401
    // means "wrong credentials", not "expired token"
    if (response.statusCode == 401 && !_isAuthEndpoint(request.url)) {
      final refreshed = await _handleTokenRefresh();
      if (refreshed) {
        // Retry with the freshly cached token
        final retryRequest = _copyRequest(request);
        final newToken = cachedToken;
        if (newToken != null && newToken.isNotEmpty) {
          retryRequest.headers['Authorization'] = 'Bearer $newToken';
        }
        return await _inner.send(retryRequest);
      } else {
        // Refresh failed — clear secure storage and redirect to login
        _redirectToLogin();
      }
    }

    return response;
  }

  /// Check if the request is to an auth endpoint where 401 means
  /// "invalid credentials", not "expired session".
  bool _isAuthEndpoint(Uri url) {
    final path = url.path.toLowerCase();
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/reset-password') ||
        path.contains('/auth/verify') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/send-verification');
  }

  /// Queue-based deduplication: if a refresh is already running,
  /// subsequent 401s wait for it rather than spawning multiple refreshes.
  Future<bool> _handleTokenRefresh() async {
    if (_isRefreshing) {
      final completer = Completer<void>();
      _waitingQueue.add(completer);
      await completer.future;
      return cachedToken != null && cachedToken!.isNotEmpty;
    }

    _isRefreshing = true;
    try {
      final success = await _refreshTokens();
      for (final c in _waitingQueue) {
        c.complete();
      }
      _waitingQueue.clear();
      return success;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Performs the actual token refresh — reads from / writes to
  /// Keystore/Keychain via [SecureStorageService].
  Future<bool> _refreshTokens() async {
    try {
      final currentToken = cachedToken;
      final refreshToken = cachedRefreshToken;
      if (currentToken == null || refreshToken == null) return false;

      // Use a plain client to avoid infinite recursion
      final plainClient = ApiClient(
        basePath: 'https://starfish-app-vavqt.ondigitalocean.app',
      );

      final authApi = AuthApi(plainClient);
      final command = RefreshTokenCommand(
        accessToken: currentToken,
        refreshToken: refreshToken,
      );

      final response = await authApi.authRefresh(command);

      if (response != null && response.data != null) {
        final data = response.data!;
        if (data.accessToken != null && data.refreshToken != null) {
          // Persist to Keystore/Keychain AND update memory cache
          await SecureStorageService.setToken(data.accessToken!);
          await SecureStorageService.setRefreshToken(data.refreshToken!);
          cachedToken        = data.accessToken!;
          cachedRefreshToken = data.refreshToken!;
          return true;
        }
      }
      return false;
    } catch (_) {
      // Do NOT log token values in production
      return false;
    }
  }

  /// Redirect to login and clear ALL sensitive data from Keystore/Keychain.
  void _redirectToLogin() {
    // Fire-and-forget — we don't await inside void to avoid blocking
    SecureStorageService.clearAll().then((_) {
      cachedToken        = null;
      cachedRefreshToken = null;
      cachedUserId       = null;
    });
    AppNavigator.pushNamedAndRemoveUntil('/login');
  }

  /// Creates a copy of the original request for retry.
  http.BaseRequest _copyRequest(http.BaseRequest original) {
    if (original is http.Request) {
      final request = http.Request(original.method, original.url)
        ..headers.addAll(original.headers)
        ..body = original.body;
      return request;
    }
    return original;
  }

  @override
  void close() {
    _inner.close();
  }
}
