import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/pages/chat_room_page.dart';

/// Chat list page — SIMULATED placeholder per team decision.
/// Shows a static demo UI. Replace with real ChatApi integration when ready.
class ChatListPage extends StatelessWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColor.backgroundcolor;
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor;
    final textColor = isDark ? Colors.white : Colors.white; // Foreground is white in light mode too for AppBar

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Messages',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: appBarColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: _buildSimulatedList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar('Coming Soon',
              'New chat functionality is being planned with the team.',
              backgroundColor: AppColor.primaryColor.withOpacity(0.9),
              colorText: Colors.white);
        },
        backgroundColor: AppColor.primaryColor,
        child: Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildSimulatedList(BuildContext context) {
    final mockChats = [
      _MockChat('Ahmed M.', 'Is the camera still available?', '2m ago', false),
      _MockChat('Sara K.', 'Thanks! I will pick it up tomorrow.', '1h ago', true),
      _MockChat('Omar H.', 'Can we negotiate the price?', '3h ago', false),
      _MockChat('Nour A.', 'The rental was great, thank you!', 'Yesterday', true),
      _MockChat('Youssef R.', 'Is it available for next week?', '2d ago', true),
    ];

    return Column(
      children: [
        // Simulated Banner
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColor.fourthColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.fourthColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColor.fourthColor),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Chat is in preview mode. Full messaging coming soon!',
                  style: TextStyle(
                      fontSize: 12, color: AppColor.fourthColor, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: mockChats.length,
            itemBuilder: (context, index) {
              final chat = mockChats[index];
              return _buildChatTile(context, chat);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatTile(BuildContext context, _MockChat chat) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColor.darkText;
    final subtextColor = isDark ? Colors.white54 : AppColor.mediumText;
    final timeColor = chat.isRead 
        ? (isDark ? Colors.white38 : AppColor.lightText) 
        : AppColor.fourthColor;
    final borderColor = isDark ? Colors.white10 : AppColor.borderGray.withOpacity(0.5);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomPage(
              chatId: 'simulated',
              otherUserName: chat.name,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: isDark ? AppColor.fourthColor.withOpacity(0.2) : AppColor.primaryColor.withOpacity(0.1),
              child: Text(
                chat.name.substring(0, 1),
                style: TextStyle(
                  color: isDark ? const Color(0xFF93C5FD) : AppColor.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              chat.isRead ? FontWeight.w500 : FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        chat.time,
                        style: TextStyle(
                          fontSize: 11,
                          color: timeColor,
                          fontWeight:
                              chat.isRead ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: chat.isRead
                                ? subtextColor
                                : textColor,
                            fontWeight:
                                chat.isRead ? FontWeight.normal : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!chat.isRead)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColor.fourthColor,
                            shape: BoxShape.circle,
                          ),
                        ),
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

class _MockChat {
  final String name;
  final String lastMessage;
  final String time;
  final bool isRead;

  _MockChat(this.name, this.lastMessage, this.time, this.isRead);
}
