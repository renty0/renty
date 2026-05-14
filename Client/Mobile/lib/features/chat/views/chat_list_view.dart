import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/chat_controller.dart';
import 'chat_messages_view.dart';

/// Chat list page — all conversations.
class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChatController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text('Messages',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.chats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.chats.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadChats,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            itemCount: ctrl.chats.length,
            itemBuilder: (context, index) {
              final chat = ctrl.chats[index];
              return _ChatTile(chat: chat, ctrl: ctrl);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: AppColors.gray300),
            const SizedBox(height: 24),
            Text('No messages yet',
                style:
                    AppTextStyles.heading3.copyWith(color: AppColors.gray500)),
            const SizedBox(height: 12),
            Text(
                'Start a conversation from a product page\nto chat with the owner.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Single chat conversation tile.
class _ChatTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  final ChatController ctrl;

  const _ChatTile({required this.chat, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final name = ctrl.getChatPartnerName(chat);
    final lastMsg = ctrl.getLastMessage(chat);
    final time = ctrl.getLastMessageTime(chat);
    final chatId = chat['id']?.toString() ?? '';
    final unread = (chat['unreadCount'] as int?) ?? 0;

    // Get avatar initial
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return InkWell(
      onTap: () {
        if (chatId.isNotEmpty) {
          ctrl.activeChatTitle.value = name;
          Get.to(() => ChatMessagesView(chatId: chatId, title: name));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: unread > 0
              ? AppColors.primary.withValues(alpha: 0.03)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: AppColors.gray100, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight:
                                unread > 0 ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: AppTextStyles.captionSmall.copyWith(
                            color: unread > 0
                                ? AppColors.primary
                                : AppColors.gray400,
                            fontSize: 11,
                            fontWeight: unread > 0
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg.isNotEmpty ? lastMsg : 'No messages yet',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: unread > 0
                                ? AppColors.gray700
                                : AppColors.gray500,
                            fontWeight: unread > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unread > 9 ? '9+' : unread.toString(),
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
