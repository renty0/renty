import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/support_controller.dart';

/// Detail view for a support ticket — messages thread + reply.
class SupportDetailView extends StatefulWidget {
  final String ticketId;
  final String subject;
  final String status;

  const SupportDetailView({
    super.key,
    required this.ticketId,
    required this.subject,
    required this.status,
  });

  @override
  State<SupportDetailView> createState() => _SupportDetailViewState();
}

class _SupportDetailViewState extends State<SupportDetailView> {
  final _ctrl = Get.find<SupportController>();
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _ctrl.loadTicketMessages(widget.ticketId);
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
    final success = await _ctrl.sendTicketMessage(widget.ticketId, text);
    if (success) _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isClosed = widget.status.toLowerCase() == 'closed' ||
        widget.status.toLowerCase() == 'resolved';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(widget.subject,
            style: AppTextStyles.heading3
                .copyWith(color: AppColors.white, fontSize: 16)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          if (!isClosed)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.white),
              onSelected: (v) {
                if (v == 'close') {
                  _confirmClose();
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'close',
                  child: Text('Close Ticket'),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Messages ──
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
                        Icon(Icons.forum_outlined,
                            size: 64, color: AppColors.gray300),
                        const SizedBox(height: 16),
                        Text('No messages yet',
                            style: AppTextStyles.heading3
                                .copyWith(color: AppColors.gray500)),
                        const SizedBox(height: 8),
                        Text('Your support team will respond soon',
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
                  final isSupport = msg['isSupport'] == true ||
                      msg['senderType']?.toString().toLowerCase() == 'admin' ||
                      msg['senderType']?.toString().toLowerCase() == 'support';
                  final isMine = !isSupport &&
                      (_currentUserId != null && senderId == _currentUserId ||
                          msg['isOwn'] == true);
                  return _SupportMessage(
                      message: msg, isMine: isMine, isSupport: isSupport);
                },
              );
            }),
          ),

          // ── Reply bar ──
          if (!isClosed) _buildReplyBar(),
          if (isClosed) _buildClosedBar(),
        ],
      ),
    );
  }

  Widget _buildReplyBar() {
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
                  hintText: 'Type your reply...',
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
                decoration: const BoxDecoration(
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

  Widget _buildClosedBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF1F5F9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 16, color: AppColors.gray500),
          const SizedBox(width: 8),
          Text('This ticket is closed',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.gray500, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _confirmClose() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Close Ticket', style: AppTextStyles.heading3),
        content: const Text('Are you sure you want to close this ticket?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: AppColors.gray500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _ctrl.closeTicket(widget.ticketId);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Individual support message bubble.
class _SupportMessage extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMine;
  final bool isSupport;

  const _SupportMessage(
      {required this.message, required this.isMine, required this.isSupport});

  @override
  Widget build(BuildContext context) {
    final content = message['message']?.toString() ??
        message['content']?.toString() ??
        '';
    final createdAt = message['createdAt']?.toString() ?? '';

    String timeText = '';
    try {
      final dt = DateTime.parse(createdAt);
      timeText = DateFormat('h:mm a').format(dt);
    } catch (_) {}

    final bgColor = isSupport
        ? const Color(0xFFEEF2FF) // light indigo for support
        : isMine
            ? AppColors.primary
            : AppColors.white;

    final textColor = isMine ? AppColors.white : AppColors.gray700;
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
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
            if (isSupport)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('Support Team',
                    style: AppTextStyles.captionSmall.copyWith(
                        color: const Color(0xFF4F46E5),
                        fontWeight: FontWeight.w700,
                        fontSize: 10)),
              ),
            Text(content,
                style: AppTextStyles.bodyLarge.copyWith(
                    color: textColor, fontSize: 14, height: 1.4)),
            if (timeText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(timeText,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: isMine
                        ? AppColors.white.withValues(alpha: 0.7)
                        : AppColors.gray400,
                    fontSize: 10,
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
