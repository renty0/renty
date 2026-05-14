/// API endpoint constants matching the deployed Swagger spec at
/// https://renty.runasp.net/swagger/v1/swagger.json
class ApiEndpoints {
  ApiEndpoints._();

  // ── Base ──────────────────────────────────────────────────────────
  static const String baseUrl = 'https://renty.runasp.net';

  // ── Auth ──────────────────────────────────────────────────────────
  static const String _auth = '/api/v1/auth';
  static const String login = '$_auth/login';
  static const String register = '$_auth/register';
  static const String verifyEmail = '$_auth/verify-email';
  static const String sendVerification = '$_auth/send-verification';
  static const String forgotPassword = '$_auth/forgot-password';
  static const String verifyResetCode = '$_auth/verify-reset-code';
  static const String resetPassword = '$_auth/reset-password';
  static const String refresh = '$_auth/refresh';
  static const String me = '$_auth/me'; // GET = profile, PUT = update profile

  // ── Items ─────────────────────────────────────────────────────────
  static const String items = '/api/v1/items';
  static String itemById(String id) => '/api/v1/items/$id';
  static String updateItem(String id) => '/api/v1/items/$id';
  static String deleteItem(String id) => '/api/v1/items/$id';

  // ── Search ────────────────────────────────────────────────────────
  static const String search = '/api/v1/search';

  // ── Categories ────────────────────────────────────────────────────
  static const String categories = '/api/v1/categories';

  // ── Subcategories ─────────────────────────────────────────────────
  static const String subcategories = '/api/v1/subcategories';

  // ── Brands ────────────────────────────────────────────────────────
  static const String brands = '/api/v1/brands';

  // ── Media ─────────────────────────────────────────────────────────
  static const String mediaUpload = '/api/v1/media';

  // ── Favorites ─────────────────────────────────────────────────────
  static String addFavorite(String itemId) => '/api/v1/items/$itemId/favorite';
  static String removeFavorite(String itemId) =>
      '/api/v1/items/$itemId/favorite';
  static const String myFavorites = '/api/v1/users/me/favorites';

  // ── Rentals ───────────────────────────────────────────────────────
  static const String rentals = '/api/v1/rentals';
  static String rentalById(String id) => '/api/v1/rentals/$id';
  static String confirmRental(String id) => '/api/v1/rentals/$id/confirm';
  static String activateRental(String id) => '/api/v1/rentals/$id/activate';
  static String completeRental(String id) => '/api/v1/rentals/$id/complete';
  static String cancelRental(String id) => '/api/v1/rentals/$id/cancel';

  // ── Reviews ───────────────────────────────────────────────────────
  static String createReview(String rentalId) =>
      '/api/v1/rentals/$rentalId/review';
  static String itemReviews(String itemId) => '/api/v1/items/$itemId/reviews';

  // ── Orders ────────────────────────────────────────────────────────
  static const String orders = '/api/v1/orders';
  static String orderById(String id) => '/api/v1/orders/$id';

  // ── Delivery ──────────────────────────────────────────────────────
  static String deliveryStatus(String orderId) =>
      '/api/v1/orders/$orderId/delivery';

  // ── Payments ──────────────────────────────────────────────────────
  static const String payments = '/api/v1/payments';
  static String paymentByOrder(String orderId) => '/api/v1/payments/$orderId';

  // ── Notifications ─────────────────────────────────────────────────
  static const String notifications = '/api/v1/notifications';
  static const String readAllNotifications = '/api/v1/notifications/read-all';
  static String readNotification(String id) => '/api/v1/notifications/$id/read';

  // ── Chat ──────────────────────────────────────────────────────────
  static const String chats = '/api/v1/chats';
  static String chatMessages(String chatId) => '/api/v1/chats/$chatId/messages';

  // ── Support ───────────────────────────────────────────────────────
  static const String supportTickets = '/api/v1/support/tickets';
  static String ticketMessages(String ticketId) =>
      '/api/v1/support/tickets/$ticketId/messages';
  static String ticketStatus(String ticketId) =>
      '/api/v1/support/tickets/$ticketId/status';

  // ── Recommendations ───────────────────────────────────────────────
  static const String recommendations = '/api/v1/recommendations';
  static String recommendationClick(String id) =>
      '/api/v1/recommendations/$id/click';

  // ── Verifications ─────────────────────────────────────────────────
  static String verifyItem(String itemId) => '/api/v1/items/$itemId/verify';
  static String itemVerifications(String itemId) =>
      '/api/v1/items/$itemId/verifications';
  static const String expertAssigned = '/api/v1/expert/assigned';
}
