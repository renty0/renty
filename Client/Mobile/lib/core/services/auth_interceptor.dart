import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:renty/main.dart';
import 'package:renty/api/lib/api.dart';

/// An HTTP client wrapper that intercepts 401 responses and
/// automatically attempts to refresh the access token.
///
/// If the refresh succeeds, the original request is retried with
/// the new token. If it fails, the user is redirected to login.
class AuthInterceptorClient extends http.BaseClient {
  final http.Client _inner;
  static bool _isRefreshing = false;
  static final List<Completer<void>> _waitingQueue = [];

  AuthInterceptorClient([http.Client? inner])
      : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Attach the current token to every request
    final token = sharedPref.getString("token");
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await _inner.send(request);

    // If 401, try refreshing the token — BUT skip for auth endpoints
    // where 401 means "wrong credentials", not "expired token"
    if (response.statusCode == 401 && !_isAuthEndpoint(request.url)) {
      final refreshed = await _handleTokenRefresh();
      if (refreshed) {
        // Clone and retry the request with the new token
        final retryRequest = _copyRequest(request);
        final newToken = sharedPref.getString("token");
        if (newToken != null && newToken.isNotEmpty) {
          retryRequest.headers['Authorization'] = 'Bearer $newToken';
        }
        return await _inner.send(retryRequest);
      } else {
        // Refresh failed — redirect to login
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

  /// Handles token refresh with queue-based deduplication.
  /// If a refresh is already in progress, subsequent 401s wait
  /// for that refresh to complete rather than spawning multiple.
  Future<bool> _handleTokenRefresh() async {
    if (_isRefreshing) {
      // Wait for the ongoing refresh to finish
      final completer = Completer<void>();
      _waitingQueue.add(completer);
      await completer.future;
      // After waiting, check if we have a valid token
      final token = sharedPref.getString("token");
      return token != null && token.isNotEmpty;
    }

    _isRefreshing = true;
    try {
      final success = await _refreshTokens();
      // Notify all waiting requests
      for (final c in _waitingQueue) {
        c.complete();
      }
      _waitingQueue.clear();
      return success;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Performs the actual token refresh using the refresh token.
  Future<bool> _refreshTokens() async {
    try {
      final currentToken = sharedPref.getString("token");
      final refreshToken = sharedPref.getString("refresh_token");
      if (currentToken == null || refreshToken == null) return false;

      // Use a separate client to avoid infinite recursion
      final plainClient = ApiClient(
        basePath: 'https://renty.runasp.net',
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
          await sharedPref.setString("token", data.accessToken!);
          await sharedPref.setString("refresh_token", data.refreshToken!);
          print('AuthInterceptor: Token refreshed successfully');
          return true;
        }
      }
      return false;
    } catch (e) {
      print('AuthInterceptor: Token refresh failed: $e');
      return false;
    }
  }

  /// Redirect to login and clear stored tokens.
  void _redirectToLogin() {
    sharedPref.remove("token");
    sharedPref.remove("refresh_token");
    sharedPref.remove("user_id");
    Get.offAllNamed('/login');
  }

  /// Creates a copy of the original request for retry.
  http.BaseRequest _copyRequest(http.BaseRequest original) {
    if (original is http.Request) {
      final request = http.Request(original.method, original.url)
        ..headers.addAll(original.headers)
        ..body = original.body;
      return request;
    }
    // For other request types (StreamedRequest, MultipartRequest),
    // we return as-is since they can't be easily cloned.
    // In practice, 401s on file uploads are rare.
    return original;
  }

  @override
  void close() {
    _inner.close();
  }
}
