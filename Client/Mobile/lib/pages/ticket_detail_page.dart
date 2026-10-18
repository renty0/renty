import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/services/secure_storage_service.dart';
import 'package:renty/core/services/support_signalr_service.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:renty/main.dart';

/// Full ticket detail page with chat-style message thread + real-time SignalR.
/// Matches web's ticket-details component exactly.
class TicketDetailPage extends StatefulWidget {
  final String? ticketId;
  const TicketDetailPage({super.key, this.ticketId});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  final _supportSignalr = SupportSignalrService();
  StreamSubscription? _msgSub;
  StreamSubscription? _typingSub;
  Timer? _typingTimer;

  bool _isLoading = true;
  bool _isSending = false;
  String? _ticketId;
  Map<String, dynamic>? _ticket;
  List<Map<String, dynamic>> _messages = [];
  String? _typingUser;
  int? _currentUserId;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _ticketId = widget.ticketId ?? (ModalRoute.of(context)?.settings.arguments as String?);
      _currentUserId = int.tryParse(cachedUserId ?? '');
      _loadTicketDetails();
      _initSignalR();
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _msgSub?.cancel();
    _typingSub?.cancel();
    _typingTimer?.cancel();
    if (_ticketId != null) _supportSignalr.leaveTicket(_ticketId!);
    _supportSignalr.dispose();
    super.dispose();
  }

  Future<void> _initSignalR() async {
    if (_ticketId == null) return;

    _msgSub = _supportSignalr.onMessage.listen((msg) {
      if (msg.ticketId == _ticketId) {
        // Avoid duplicates
        final exists = _messages.any((m) => m['id'] == msg.id);
        if (!exists && mounted) {
          setState(() {
            _messages.add({
              'id': msg.id,
              'senderId': msg.senderId,
              'senderName': msg.senderName,
              'senderRole': msg.senderRole,
              'message': msg.message,
              'createdAt': msg.createdAt,
            });
          });
          _scrollToBottom();

          // Play default notification sound if message is from the support agent or other user
          if (msg.senderId != _currentUserId) {
            FlutterRingtonePlayer().playNotification();
          }
        }
      }
    });

    _typingSub = _supportSignalr.onTyping.listen((name) {
      if (mounted) {
        setState(() => _typingUser = name);
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _typingUser = null);
        });
      }
    });

    await _supportSignalr.startConnection();
    await _supportSignalr.joinTicket(_ticketId!);
  }

  Future<void> _loadTicketDetails() async {
    if (_ticketId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.client.invokeAPI(
        '/api/v1/support/tickets/$_ticketId',
        'GET', [], null, {}, {}, null,
      );

      if (response.statusCode >= 200 && response.statusCode < 300 && response.body.isNotEmpty) {
        final body = jsonDecode(response.body);
        if (body['data'] != null) {
          final data = body['data'] as Map<String, dynamic>;
          final ticket = data['ticket'] as Map<String, dynamic>?;
          if (ticket != null && mounted) {
            setState(() {
              _ticket = ticket;
              _messages = List<Map<String, dynamic>>.from(
                  (ticket['messages'] as List?)?.map((m) => Map<String, dynamic>.from(m)) ?? []);
              _isLoading = false;
            });
            _scrollToBottom();
            return;
          }
        }
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      print('TicketDetail load error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendReply() async {
    final msg = _msgController.text.trim();
    if (msg.isEmpty || _ticketId == null || _isSending) return;

    setState(() => _isSending = true);

    try {
      final response = await ApiService.client.invokeAPI(
        '/api/v1/support/tickets/$_ticketId/messages',
        'POST',
        <QueryParam>[],
        {
          'ticketId': _ticketId,
          'message': msg,
          'mediaUrl': null,
          'messageType': 0,
          'isSupportAgent': false,
        },
        <String, String>{},
        <String, String>{},
        'application/json',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to send message');
      }

      String? messageId;
      if (response.body.isNotEmpty) {
        final body = jsonDecode(response.body);
        messageId = body['data']?['messageId'] as String?;
      }

      if (!mounted) return;
      _msgController.clear();

      // Optimistic: add message locally
      setState(() {
        _isSending = false;
        _messages.add({
          'id': messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'senderId': _currentUserId,
          'senderName': 'You',
          'senderRole': 'User',
          'message': msg,
          'createdAt': DateTime.now().toIso8601String(),
        });
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      AppNavigator.showSnackBar(
        'Error'.tr,
        'Failed to send message'.tr,
        backgroundColor: const Color(0xFFDC2626).withOpacity(0.9),
        textColor: Colors.white,
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isCurrentUser(dynamic senderId) {
    if (_currentUserId == null || senderId == null) return false;
    if (senderId is int) return senderId == _currentUserId;
    return senderId.toString() == _currentUserId.toString();
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'open': return const Color(0xFF2563EB);
      case 'awaitingsupport': return const Color(0xFFF59E0B);
      case 'awaitingcustomer': return const Color(0xFF6366F1);
      case 'resolved': return const Color(0xFF10B981);
      case 'closed': return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'open': return 'Open'.tr;
      case 'awaitingsupport': return 'Awaiting Support'.tr;
      case 'awaitingcustomer': return 'Awaiting Response'.tr;
      case 'resolved': return 'Resolved'.tr;
      case 'closed': return 'Closed'.tr;
      default: return status != null ? status.tr : 'Unknown'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          _ticketId != null
              ? 'Ticket #@id'.trParams({'id': _ticketId!.length > 8 ? _ticketId!.substring(0, 8) : _ticketId!})
              : 'Ticket Detail'.tr,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_ticket != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              onSelected: (status) => _loadTicketDetails(), // Refresh after status update
              itemBuilder: (_) => [],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColor.fourthColor))
          : _ticketId == null
              ? _buildErrorState(isDark)
              : Column(children: [
                  // ── Ticket info header ──
                  if (_ticket != null) _buildTicketHeader(isDark),
                  // ── Messages thread ──
                  Expanded(child: _buildMessageList(isDark)),
                  // ── Typing indicator ──
                  if (_typingUser != null) _buildTypingIndicator(isDark),
                  // ── Input bar ──
                  _buildInputBar(isDark),
                ]),
    );
  }

  Widget _buildTicketHeader(bool isDark) {
    final status = _ticket?['status'] as String?;
    final type = _ticket?['type'] as String?;
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_statusLabel(status),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ),
        const SizedBox(width: 8),
        if (type != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(type,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColor.mediumText)),
          ),
        const Spacer(),
        // SignalR connection indicator
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _supportSignalr.isConnected ? const Color(0xFF10B981) : Colors.grey,
          ),
        ),
        const SizedBox(width: 6),
        Text(_supportSignalr.isConnected ? 'Live'.tr : 'Offline'.tr,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: _supportSignalr.isConnected ? const Color(0xFF10B981) : Colors.grey)),
      ]),
    );
  }

  Widget _buildMessageList(bool isDark) {
    if (_messages.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('No messages yet'.tr, style: TextStyle(color: isDark ? Colors.white54 : AppColor.lightText)),
          const SizedBox(height: 4),
          Text('Send the first message below'.tr,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[400])),
        ]),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildMessageBubble(_messages[i], isDark),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isDark) {
    final isMine = _isCurrentUser(msg['senderId']);
    final senderName = msg['senderName'] ?? 'Support';
    final senderRole = msg['senderRole'] ?? '';
    final text = msg['message'] ?? '';
    final createdAt = msg['createdAt'] as String?;
    final timeStr = _formatTime(createdAt);

    return Align(
      alignment: isMine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: EdgeInsetsDirectional.only(bottom: 8, start: isMine ? 60 : 0, end: isMine ? 0 : 60),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, bottom: 4),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(senderName,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white54 : AppColor.mediumText)),
                  if (senderRole.isNotEmpty && senderRole != 'User') ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(senderRole.tr,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                    ),
                  ],
                ]),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine
                    ? AppColor.primaryColor
                    : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
                borderRadius: BorderRadiusDirectional.only(
                  topStart: const Radius.circular(16),
                  topEnd: const Radius.circular(16),
                  bottomStart: Radius.circular(isMine ? 16 : 4),
                  bottomEnd: Radius.circular(isMine ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 6, offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(text,
                    style: TextStyle(fontSize: 14, height: 1.4,
                        color: isMine ? Colors.white : (isDark ? Colors.white : AppColor.darkText))),
                const SizedBox(height: 4),
                Text(timeStr,
                    style: TextStyle(fontSize: 10,
                        color: isMine ? Colors.white60 : (isDark ? Colors.white38 : Colors.grey[400]))),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(children: [
        SizedBox(
          width: 16, height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColor.fourthColor),
        ),
        const SizedBox(width: 8),
        Text('@name is typing...'.trParams({'name': _typingUser ?? ''}),
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic,
                color: isDark ? Colors.white54 : AppColor.lightText)),
      ]),
    );
  }

  Widget _buildInputBar(bool isDark) {
    final isClosed = _ticket?['status']?.toString().toLowerCase() == 'closed' ||
        _ticket?['status']?.toString().toLowerCase() == 'resolved';

    if (isClosed) {
      return Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: Row(children: [
          Icon(Icons.lock_outline, size: 18, color: isDark ? Colors.white38 : Colors.grey[400]),
          const SizedBox(width: 8),
          Text('This ticket is closed'.tr,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey[400])),
        ]),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _msgController,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendReply(),
              onChanged: (_) {
                if (_ticketId != null) {
                  // SECURITY: use cachedUserId as typing indicator name
                  // (synchronous, no async needed for SignalR typing events)
                  final name = cachedUserId ?? 'User';
                  _supportSignalr.sendTyping(_ticketId!, name);
                }
              },
              style: TextStyle(fontSize: 15, color: isDark ? Colors.white : AppColor.darkText),
              decoration: InputDecoration(
                hintText: 'Type a message...'.tr,
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _isSending ? null : _sendReply,
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              shape: BoxShape.circle,
            ),
            child: _isSending
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('Ticket not found'.tr,
            style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : AppColor.mediumText)),
      ]),
    );
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final d = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        return DateFormat('HH:mm').format(d);
      }
      return DateFormat('MMM d, HH:mm').format(d);
    } catch (_) { return ''; }
  }
}
