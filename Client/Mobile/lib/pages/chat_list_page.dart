import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/pages/chat_room_page.dart';

/// Real chat list page backed by GET /api/v1/chats.
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<ChatListDto> _chats = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final resp = await ApiService.chat.getChats();
      if (!mounted) return;
      setState(() {
        _chats = resp?.data?.chats ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load conversations';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColor.backgroundcolor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColor.fourthColor))
          : _error != null
              ? _buildError(isDark)
              : _chats.isEmpty
                  ? _buildEmpty(isDark)
                  : RefreshIndicator(
                      onRefresh: _loadChats,
                      color: AppColor.fourthColor,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _chats.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          indent: 80,
                          color: isDark ? Colors.white10 : Colors.grey[200],
                        ),
                        itemBuilder: (ctx, i) => _buildChatTile(_chats[i], isDark),
                      ),
                    ),
    );
  }

  Widget _buildChatTile(ChatListDto chat, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppColor.fourthColor.withValues(alpha: 0.1),
        backgroundImage: chat.otherUserProfileImage != null
            ? CachedNetworkImageProvider(chat.otherUserProfileImage!)
            : null,
        child: chat.otherUserProfileImage == null
            ? Text(
                (chat.otherUserFirstName ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.fourthColor,
                ),
              )
            : null,
      ),
      title: Text(
        chat.otherUserFirstName ?? 'User',
        style: TextStyle(
          fontWeight: (chat.unreadCount ?? 0) > 0 ? FontWeight.w700 : FontWeight.w600,
          fontSize: 16,
          color: isDark ? Colors.white : AppColor.darkText,
        ),
      ),
      subtitle: chat.lastMessage != null
          ? Text(
              chat.lastMessage!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : AppColor.mediumText,
                fontWeight: (chat.unreadCount ?? 0) > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            )
          : null,
      trailing: (chat.unreadCount ?? 0) > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColor.fourthColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${chat.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomPage(
              chatId: chat.id ?? '',
              otherUserName: chat.otherUserFirstName ?? 'User',
              otherUserImage: chat.otherUserProfileImage,
            ),
          ),
        );
        _loadChats(); // Refresh on return
      },
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64,
              color: isDark ? Colors.white24 : Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No conversations yet',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : AppColor.mediumText)),
          const SizedBox(height: 8),
          Text('Start a chat from an item listing',
              style: TextStyle(
                  fontSize: 14, color: isDark ? Colors.white30 : AppColor.lightText)),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : AppColor.mediumText)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadChats,
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
