import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

/// GetX controller for Chat — list conversations and send/receive messages.
/// Swagger: GET/POST /api/v1/chats, GET/POST /api/v1/chats/{id}/messages
class ChatController extends GetxController {
  final _api = ApiService.instance;

  // ── Chat list ─────────────────────────────────────────────────
  final chats = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  // ── Active conversation ───────────────────────────────────────
  final messages = <Map<String, dynamic>>[].obs;
  final isLoadingMessages = false.obs;
  final isSending = false.obs;
  final activeChatId = ''.obs;
  final activeChatTitle = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  // ── Load Chat List ────────────────────────────────────────────

  Future<void> loadChats() async {
    isLoading.value = true;
    try {
      final res = await _api.get(
        ApiEndpoints.chats,
        authenticated: true,
      );
      final error = res['error'] as bool? ?? true;
      if (!error) {
        final data = res['data'];
        if (data is List) {
          chats.value = data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          final list = data['chats'] ?? data['conversations'];
          if (list is List) {
            chats.value = list.cast<Map<String, dynamic>>();
          }
        }
      }
    } catch (_) {
      // Silent
    } finally {
      isLoading.value = false;
    }
  }

  // ── Create / Start Chat ───────────────────────────────────────

  Future<String?> startChat(int userId) async {
    try {
      final res = await _api.post(
        ApiEndpoints.chats,
        <String, dynamic>{'userId': userId},
        authenticated: true,
      );
      final error = res['error'] as bool? ?? true;
      if (!error) {
        final data = res['data'];
        if (data is Map<String, dynamic>) {
          final chatId = data['chatId']?.toString();
          loadChats(); // refresh list
          return chatId;
        }
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to start chat',
          snackPosition: SnackPosition.BOTTOM);
    }
    return null;
  }

  // ── Load Messages ─────────────────────────────────────────────

  Future<void> loadMessages(String chatId) async {
    activeChatId.value = chatId;
    isLoadingMessages.value = true;
    messages.clear();
    try {
      final res = await _api.get(
        ApiEndpoints.chatMessages(chatId),
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
    } catch (_) {
      // Silent
    } finally {
      isLoadingMessages.value = false;
    }
  }

  // ── Send Message ──────────────────────────────────────────────

  Future<bool> sendMessage(String chatId, String content) async {
    if (content.trim().isEmpty) return false;

    isSending.value = true;
    try {
      final res = await _api.post(
        ApiEndpoints.chatMessages(chatId),
        <String, dynamic>{'chatId': chatId, 'message': content.trim()},
        authenticated: true,
      );
      final error = res['error'] as bool? ?? true;
      if (!error) {
        // Add to local list immediately for responsiveness
        final data = res['data'];
        if (data is Map<String, dynamic>) {
          messages.add(data);
        } else {
          // Reload to get the message from server
          await loadMessages(chatId);
        }
        return true;
      } else {
        final msgs = (res['messages'] as List?)?.cast<String>() ?? [];
        Get.snackbar('Error', msgs.isNotEmpty ? msgs[0] : 'Failed to send',
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to send message',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSending.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────

  String getChatPartnerName(Map<String, dynamic> chat) {
    // Swagger: flat field "otherUserFirstName"
    final name = chat['otherUserFirstName']?.toString();
    if (name != null && name.isNotEmpty) return name;
    // Fallback for nested structure
    final partner = chat['otherUser'] ?? chat['recipient'] ?? chat['partner'];
    if (partner is Map<String, dynamic>) {
      return partner['firstName']?.toString() ?? 'Chat';
    }
    return chat['title']?.toString() ?? 'Chat';
  }

  String getLastMessage(Map<String, dynamic> chat) {
    // Swagger: flat string "lastMessage"
    return chat['lastMessage']?.toString() ?? '';
  }

  String getLastMessageTime(Map<String, dynamic> chat) {
    final last = chat['lastMessage'];
    String? time;
    if (last is Map<String, dynamic>) {
      time = last['createdAt']?.toString();
    }
    time ??= chat['updatedAt']?.toString() ?? chat['createdAt']?.toString();
    if (time == null) return '';
    try {
      final dt = DateTime.parse(time);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${dt.month}/${dt.day}';
    } catch (_) {
      return '';
    }
  }
}
