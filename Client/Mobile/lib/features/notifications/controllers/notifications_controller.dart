import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

/// GetX controller for Notifications.
/// Swagger: GET /api/v1/notifications, PUT read-all, PUT {id}/read
class NotificationsController extends GetxController {
  final _api = ApiService.instance;

  final notifications = <Map<String, dynamic>>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  // ── Load Notifications ────────────────────────────────────────

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final res = await _api.get(
        ApiEndpoints.notifications,
        authenticated: true,
      );

      final error = res['error'] as bool? ?? true;
      if (!error) {
        final data = res['data'];
        if (data is Map<String, dynamic>) {
          final items = data['notifications'];
          if (items is List) {
            notifications.value = items.cast<Map<String, dynamic>>();
          }
          unreadCount.value = (data['unreadCount'] as int?) ?? 0;
        }
      }
    } catch (_) {
      // Silent
    } finally {
      isLoading.value = false;
    }
  }

  // ── Mark Single as Read ───────────────────────────────────────

  Future<void> markAsRead(String id) async {
    try {
      final res = await _api.put(
        ApiEndpoints.readNotification(id),
        <String, dynamic>{},
        authenticated: true,
      );
      final error = res['error'] as bool? ?? true;
      if (!error) {
        // Update local state
        final idx = notifications.indexWhere((n) => n['id'] == id);
        if (idx >= 0) {
          notifications[idx] = {...notifications[idx], 'isRead': true};
          notifications.refresh();
        }
        if (unreadCount.value > 0) unreadCount.value--;
      }
    } catch (_) {}
  }

  // ── Mark All as Read ──────────────────────────────────────────

  Future<void> markAllAsRead() async {
    try {
      final res = await _api.put(
        ApiEndpoints.readAllNotifications,
        <String, dynamic>{},
        authenticated: true,
      );
      final error = res['error'] as bool? ?? true;
      if (!error) {
        for (int i = 0; i < notifications.length; i++) {
          notifications[i] = {...notifications[i], 'isRead': true};
        }
        notifications.refresh();
        unreadCount.value = 0;
        Get.snackbar('Done', 'All notifications marked as read',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to mark all as read',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
