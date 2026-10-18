import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/auth_interceptor.dart';
import 'package:renty/core/services/secure_storage_service.dart';
import 'package:renty/main.dart';

/// Centralized API service that configures the OpenAPI client
/// with the correct base URL and authentication token.
///
/// SECURITY: Tokens are read from [SecureStorageService] (Android Keystore /
/// iOS Keychain) and cached in memory ([cachedToken]) for synchronous access.
class ApiService {
  static const String _baseUrl = 'https://starfish-app-vavqt.ondigitalocean.app';

  static ApiClient? _apiClient;

  /// Get or create the API client with the current auth token.
  /// Reads from the in-memory cache — populated at startup and updated
  /// after every login / token refresh.
  static ApiClient get client {
    final token = cachedToken; // memory-cached from Keystore/Keychain
    _apiClient = ApiClient(
      basePath: _baseUrl,
      authentication: token != null && token.isNotEmpty
          ? HttpBearerAuth()
          : null,
    );
    if (token != null && token.isNotEmpty) {
      (_apiClient!.authentication as HttpBearerAuth).accessToken = token;
    }
    // Inject the auth interceptor HTTP client
    _apiClient!.client = AuthInterceptorClient();
    return _apiClient!;
  }

  /// Refresh the API client (call after login/logout/token refresh)
  static void refreshClient() {
    _apiClient = null;
  }

  // ─── API Instances ───────────────────────────────────────────

  static AuthApi            get auth            => AuthApi(client);
  static ItemsApi           get items           => ItemsApi(client);
  static CategoriesApi      get categories      => CategoriesApi(client);
  static SubcategoriesApi   get subcategories   => SubcategoriesApi(client);
  static BrandsApi          get brands          => BrandsApi(client);
  static SearchApi          get search          => SearchApi(client);
  static FavoritesApi       get favorites       => FavoritesApi(client);
  static RentalsApi         get rentals         => RentalsApi(client);
  static OrdersApi          get orders          => OrdersApi(client);
  static PaymentsApi        get payments        => PaymentsApi(client);
  static ChatApi            get chat            => ChatApi(client);
  static NotificationsApi   get notifications   => NotificationsApi(client);
  static SupportApi         get support         => SupportApi(client);
  static ReviewsApi         get reviews         => ReviewsApi(client);
  static VerificationsApi   get verifications   => VerificationsApi(client);
  static RecommendationsApi get recommendations => RecommendationsApi(client);
  static MediaApi           get media           => MediaApi(client);
  static DeliveryApi        get delivery        => DeliveryApi(client);
  static IdentityApi        get identity        => IdentityApi(client);

  // ─── Token Management ────────────────────────────────────────

  /// Save tokens after login — writes to Keystore/Keychain AND updates
  /// the in-memory cache so synchronous callers stay consistent.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Write to secure storage (Android Keystore / iOS Keychain)
    await SecureStorageService.setToken(accessToken);
    await SecureStorageService.setRefreshToken(refreshToken);
    // Update in-memory cache for synchronous reads
    cachedToken = accessToken;
    cachedRefreshToken = refreshToken;
    refreshClient();
  }

  /// Attempt token refresh using refresh token
  static Future<bool> refreshTokens() async {
    try {
      final currentToken  = cachedToken;
      final refreshToken  = cachedRefreshToken;
      if (currentToken == null || refreshToken == null) return false;

      final command = RefreshTokenCommand(
        accessToken: currentToken,
        refreshToken: refreshToken,
      );

      final response = await auth.authRefresh(command);

      if (response != null && response.data != null) {
        final data = response.data!;
        if (data.accessToken != null && data.refreshToken != null) {
          await saveTokens(
            accessToken:  data.accessToken!,
            refreshToken: data.refreshToken!,
          );
          return true;
        }
      }
      return false;
    } catch (_) {
      // Do NOT log token-related exceptions in production
      return false;
    }
  }

  /// Clear ALL sensitive data on logout
  static Future<void> clearTokens() async {
    await SecureStorageService.clearAll();
    // Clear in-memory caches
    cachedToken        = null;
    cachedRefreshToken = null;
    cachedUserId       = null;
    refreshClient();
  }

  /// Check if user is authenticated using the in-memory cache
  static bool get isAuthenticated =>
      cachedToken != null && cachedToken!.isNotEmpty;
}
