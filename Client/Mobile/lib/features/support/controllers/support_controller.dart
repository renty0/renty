import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

/// GetX controller for Support Tickets.
/// Swagger: GET/POST /api/v1/support/tickets,
///          GET/POST /api/v1/support/tickets/{id}/messages,
///          PUT /api/v1/support/tickets/{id}/status
class SupportController extends GetxController {
  final _api = ApiService.instance;

  // ── Ticket list ───────────────────────────────────────────────
  final tickets = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // ── Active ticket ─────────────────────────────────────────────
  final messages = <Map<String, dynamic>>[].obs;
  final isLoadingMessages = false.obs;
  final isSending = false.obs;
  final activeTicket = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  // ── Load Tickets ──────────────────────────────────────────────

  Future<void> loadTickets() async {
    isLoading.value = true;
    try {
      final res = await _api.get(
        ApiEndpoints.supportTickets,
        authenticated: true,
      );
      final error = res['error'] as bool? ?? true;
      if (!error) {
        final data = res['data'];
        if (data is List) {
          tickets.value = data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          final list = data['tickets'];
          if (list is List) {
            tickets.value = list.cast<Map<String, dynamic>>();
          }
        }
      }
    } catch (_) {}
    finally {
      isLoading.value = false;
    }
  }

  // ── Create Ticket ─────────────────────────────────────────────

  Future<bool> createTicket(String type, String message) async {
    if (message.trim().isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'type': type,
        'message': message.trim(),
      };

      final res = await _api.post(
        ApiEndpoints.supportTickets,
        body,
        authenticated: true,
      );

      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Ticket submitted!',
            snackPosition: SnackPosition.BOTTOM);
        loadTickets();
        return true;
      } else {
        final msgs = (res['messages'] as List?)?.cast<String>() ?? [];
        Get.snackbar('Error', msgs.isNotEmpty ? msgs[0] : 'Failed',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to create ticket',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Load Ticket Messages ──────────────────────────────────────

  Future<void> loadTicketMessages(String ticketId) async {
    isLoadingMessages.value = true;
    messages.clear();
    try {
      final res = await _api.get(
        ApiEndpoints.ticketMessages(ticketId),
        authenticated: true,
      );
      final error = res['error'] as bool? ?? true;
      if (!error) {
        final data = res['data'];
        if (data is List) {
          messages.value = data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          final list = data['messages'];
          if (list is List) {
            messages.value = list.cast<Map<String, dynamic>>();
          }
        }
      }
    } catch (_) {}
    finally {
      isLoadingMessages.value = false;
    }
  }

  // ── Send Message ──────────────────────────────────────────────

  Future<bool> sendTicketMessage(String ticketId, String content) async {
    if (content.trim().isEmpty) return false;

    isSending.value = true;
    try {
      final res = await _api.post(
        ApiEndpoints.ticketMessages(ticketId),
        <String, dynamic>{'ticketId': ticketId, 'message': content.trim()},
        authenticated: true,
      );
      final error = res['error'] as bool? ?? true;
      if (!error) {
        final data = res['data'];
        if (data is Map<String, dynamic>) {
          messages.add(data);
        } else {
          await loadTicketMessages(ticketId);
        }
        return true;
      }
      return false;
    } catch (_) {
      Get.snackbar('Error', 'Failed to send message',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  // ── Close Ticket ──────────────────────────────────────────────

  Future<void> closeTicket(String ticketId) async {
    try {
      final res = await _api.put(
        ApiEndpoints.ticketStatus(ticketId),
        <String, dynamic>{'ticketId': ticketId, 'status': 'closed'},
        authenticated: true,
      );
      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Done', 'Ticket closed',
            snackPosition: SnackPosition.BOTTOM);
        loadTickets();
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to close ticket',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────

  static String statusLabel(dynamic status) {
    final s = status?.toString().toLowerCase() ?? '';
    switch (s) {
      case 'open': return 'Open';
      case 'in_progress': return 'In Progress';
      case 'resolved': return 'Resolved';
      case 'closed': return 'Closed';
      default: return status?.toString() ?? 'Unknown';
    }
  }

  static int statusColor(dynamic status) {
    final s = status?.toString().toLowerCase() ?? '';
    switch (s) {
      case 'open': return 0xFF10B981;
      case 'in_progress': return 0xFF3B82F6;
      case 'resolved': return 0xFF8B5CF6;
      case 'closed': return 0xFF6B7280;
      default: return 0xFF6B7280;
    }
  }
}
