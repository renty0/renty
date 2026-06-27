import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/auth_interceptor.dart';
import 'package:renty/main.dart';

/// Centralized API service that configures the OpenAPI client
/// with the correct base URL and authentication token.
class ApiService {
  // 🔧 LOCAL DEV: change back to 'https://renty.runasp.net' before pushing
  static const String _baseUrl = 'https://renty.runasp.net';

  static ApiClient? _apiClient;

  /// Get or create the API client with current auth token.
  /// Uses AuthInterceptorClient for automatic 401 refresh.
  static ApiClient get client {
    final token = sharedPref.getString("token");
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

  static AuthApi get auth => AuthApi(client);
  static ItemsApi get items => ItemsApi(client);
  static CategoriesApi get categories => CategoriesApi(client);
  static SubcategoriesApi get subcategories => SubcategoriesApi(client);
  static BrandsApi get brands => BrandsApi(client);
  static SearchApi get search => SearchApi(client);
  static FavoritesApi get favorites => FavoritesApi(client);
  static RentalsApi get rentals => RentalsApi(client);
  static OrdersApi get orders => OrdersApi(client);
  static PaymentsApi get payments => PaymentsApi(client);
  static ChatApi get chat => ChatApi(client);
  static NotificationsApi get notifications => NotificationsApi(client);
  static SupportApi get support => SupportApi(client);
  static ReviewsApi get reviews => ReviewsApi(client);
  static VerificationsApi get verifications => VerificationsApi(client);
  static RecommendationsApi get recommendations => RecommendationsApi(client);
  static MediaApi get media => MediaApi(client);
  static DeliveryApi get delivery => DeliveryApi(client);

  // ─── Token Management ────────────────────────────────────────

  /// Save tokens after login
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await sharedPref.setString("token", accessToken);
    await sharedPref.setString("refresh_token", refreshToken);
    refreshClient();
  }

  /// Attempt token refresh using refresh token
  static Future<bool> refreshTokens() async {
    try {
      final currentToken = sharedPref.getString("token");
      final refreshToken = sharedPref.getString("refresh_token");
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
            accessToken: data.accessToken!,
            refreshToken: data.refreshToken!,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    }
  }

  /// Clear tokens on logout
  static Future<void> clearTokens() async {
    await sharedPref.remove("token");
    await sharedPref.remove("refresh_token");
    await sharedPref.remove("user_id");
    refreshClient();
  }

  /// Check if user is authenticated
  static bool get isAuthenticated {
    final token = sharedPref.getString("token");
    return token != null && token.isNotEmpty;
  }
}
