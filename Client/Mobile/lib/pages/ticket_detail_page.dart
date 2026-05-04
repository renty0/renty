import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';

/// Ticket detail / conversation page.
/// Since the generated API does not expose a `getTicketDetails` endpoint,
/// this page lets the user send a follow-up message to the ticket.
class TicketDetailPage extends StatefulWidget {
  const TicketDetailPage({super.key});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final _messageController = TextEditingController();
  bool _isSending = false;
  bool _messageSent = false;
  String? _ticketId;

  @override
  void initState() {
    super.initState();
    _ticketId = Get.arguments as String?;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final msg = _messageController.text.trim();
    if (msg.isEmpty || _ticketId == null) return;
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      final command = PostSupportMessageCommand(message: msg);
      await ApiService.support.postSupportMessage(_ticketId!, command);
      if (!mounted) return;

      _messageController.clear();
      setState(() {
        _isSending = false;
        _messageSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: const [
          Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Expanded(child: Text('Reply sent successfully')),
        ]),
        backgroundColor: AppColor.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: const [
          Icon(Icons.error_outline, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Expanded(child: Text('Failed to send reply')),
        ]),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      print('SendReply error: ${e.code} ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: const [
          Icon(Icons.error_outline, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Expanded(child: Text('Failed to send reply')),
        ]),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text(
          _ticketId != null
              ? 'Ticket #${_ticketId!.length > 8 ? _ticketId!.substring(0, 8) : _ticketId!}'
              : 'Ticket Detail',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _ticketId == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Ticket not found',
                      style: TextStyle(
                          fontSize: 16,
                          color:
                              isDark ? Colors.white70 : AppColor.mediumText)),
                ],
              ),
            )
          : Column(
              children: [
                // ── Info banner ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: isDark
                      ? AppColor.fourthColor.withOpacity(0.1)
                      : AppColor.fourthColor.withOpacity(0.06),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 20, color: AppColor.fourthColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Send a follow-up message to the support team.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white70
                                : AppColor.mediumText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Success indicator ──
                if (_messageSent)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    color: isDark
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFF10B981).withOpacity(0.06),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 20, color: Color(0xFF10B981)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your message has been sent. The support team will respond shortly.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white70
                                  : AppColor.mediumText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Reply field ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(isDark ? 0.3 : 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reply',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : AppColor.darkText)),
                          const SizedBox(height: 14),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark
                                    ? Colors.white
                                    : AppColor.darkText,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Type your message here...',
                                hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.grey[400]),
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: isDark
                                          ? Colors.white12
                                          : Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: isDark
                                          ? Colors.white12
                                          : Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColor.fourthColor,
                                      width: 2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Send button ──
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _sendReply,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Icon(Icons.send_rounded, size: 20),
                      label: Text(
                          _isSending ? 'Sending...' : 'Send Reply',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.fourthColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColor.fourthColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
