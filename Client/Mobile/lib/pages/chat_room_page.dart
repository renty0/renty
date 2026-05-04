import 'package:flutter/material.dart';
import 'package:renty/core/constant/app_colors.dart';

/// Chat Room page — SIMULATED placeholder per team decision.
class ChatRoomPage extends StatefulWidget {
  final String chatId;
  final String otherUserName;

  const ChatRoomPage({
    Key? key,
    required this.chatId,
    required this.otherUserName,
  }) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<_MockMessage> _messages = [
    _MockMessage('Hi! Is this item still available?', true, DateTime.now().subtract(Duration(hours: 2))),
    _MockMessage('Yes, it is! When would you like to rent it?', false, DateTime.now().subtract(Duration(hours: 1, minutes: 50))),
    _MockMessage('I was thinking next weekend. What\'s the daily rate?', true, DateTime.now().subtract(Duration(hours: 1, minutes: 40))),
    _MockMessage('It\'s 150 EGP/day. I can offer a weekend discount of 250 EGP for both days.', false, DateTime.now().subtract(Duration(hours: 1, minutes: 30))),
    _MockMessage('That sounds great! Let me create a rental request.', true, DateTime.now().subtract(Duration(minutes: 30))),
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_MockMessage(text, true, DateTime.now()));
      _messageController.clear();
    });

    // Simulate auto-reply
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(_MockMessage(
            'Thanks for your message! This is a simulated reply.',
            false,
            DateTime.now(),
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColor.backgroundcolor;
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor;
    final inputBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final inputFieldBgColor = isDark ? const Color(0xFF2C2C2C) : AppColor.backgroundcolor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isDark ? AppColor.fourthColor.withOpacity(0.2) : Colors.white24,
              child: Text(
                widget.otherUserName.substring(0, 1),
                style: TextStyle(
                  color: isDark ? const Color(0xFF93C5FD) : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherUserName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Text('Simulated Chat',
                    style: TextStyle(fontSize: 11, color: Colors.white60)),
              ],
            ),
          ],
        ),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white, // Keep foreground white for AppBar
        elevation: 0,
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              reverse: false,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          // Message Input
          Container(
            padding: EdgeInsets.fromLTRB(
              16, 10, 8,
              10 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: inputBgColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
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
                      color: inputFieldBgColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: isDark ? Colors.white : AppColor.darkText),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: isDark ? Colors.white54 : AppColor.lightText),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColor.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_MockMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final otherMsgColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final otherTextColor = isDark ? Colors.white : AppColor.darkText;

    return Align(
      alignment:
          message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: message.isMine ? 60 : 0,
          right: message.isMine ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMine
              ? AppColor.primaryColor
              : otherMsgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMine ? 16 : 4),
            bottomRight: Radius.circular(message.isMine ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: message.isMine ? Colors.white : otherTextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: message.isMine ? Colors.white60 : (isDark ? Colors.white38 : AppColor.lightText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class _MockMessage {
  final String text;
  final bool isMine;
  final DateTime time;

  _MockMessage(this.text, this.isMine, this.time);
}
