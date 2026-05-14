import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/chat_controller.dart';

/// Chat messages view — single conversation thread.
class ChatMessagesView extends StatefulWidget {
  final String chatId;
  final String title;

  const ChatMessagesView({
    super.key,
    required this.chatId,
    required this.title,
  });

  @override
  State<ChatMessagesView> createState() => _ChatMessagesViewState();
}

class _ChatMessagesViewState extends State<ChatMessagesView> {
  final _ctrl = Get.find<ChatController>();
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _ctrl.loadMessages(widget.chatId);
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('user_id');
    });
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _send() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    _messageCtrl.clear();
    final success = await _ctrl.sendMessage(widget.chatId, text);
    if (success) _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(widget.title,
            style: AppTextStyles.heading3
                .copyWith(color: AppColors.white, fontSize: 17)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Messages list ──
          Expanded(
            child: Obx(() {
              if (_ctrl.isLoadingMessages.value && _ctrl.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_ctrl.messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_outlined,
                            size: 64, color: AppColors.gray300),
                        const SizedBox(height: 16),
                        Text('No messages yet',
                            style: AppTextStyles.heading3
                                .copyWith(color: AppColors.gray500)),
                        const SizedBox(height: 8),
                        Text('Send a message to start the conversation',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                );
              }

              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _scrollToBottom());

              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: _ctrl.messages.length,
                itemBuilder: (context, index) {
                  final msg = _ctrl.messages[index];
                  final senderId = msg['senderId']?.toString() ??
                      msg['userId']?.toString() ??
                      '';
                  final isMine = _currentUserId != null &&
                      senderId == _currentUserId;
                  return _MessageBubble(message: msg, isMine: isMine);
                },
              );
            }),
          ),

          // ── Input bar ──
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0
            ? 10
            : MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageCtrl,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.gray400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: _ctrl.isSending.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.white))
                      : const Icon(Icons.send, size: 20, color: AppColors.white),
                  onPressed: _ctrl.isSending.value ? null : _send,
                ),
              )),
        ],
      ),
    );
  }
}

/// Individual message bubble.
class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final content = message['content']?.toString() ?? '';
    final createdAt = message['createdAt']?.toString() ?? '';

    String timeText = '';
    try {
      final dt = DateTime.parse(createdAt);
      timeText = DateFormat('h:mm a').format(dt);
    } catch (_) {}

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMine
              ? AppColors.primary
              : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isMine ? AppColors.white : AppColors.gray700,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (timeText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                timeText,
                style: AppTextStyles.captionSmall.copyWith(
                  color: isMine
                      ? AppColors.white.withValues(alpha: 0.7)
                      : AppColors.gray400,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
