import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/pages/chat_room_page.dart';

// ─── Simple unified list item (both regular chats and support) ──────────────
class _ChatItem {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isSupport;

  const _ChatItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isSupport = false,
  });

  String get fullName => '$firstName $lastName'.trim();
}

// ─────────────────────────────────────────────────────────────────────────────
// ChatListPage
// ─────────────────────────────────────────────────────────────────────────────
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<_ChatItem> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  // ─── Load: regular chats + support tickets in parallel (same as web) ──────

  Future<void> _loadChats() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      // Run both requests concurrently
      final results = await Future.wait([
        ApiService.chat.getChats().catchError((_) => null),
        ApiService.support.getSupportTickets().catchError((_) => null),
      ]);

      if (!mounted) return;

      final chatsResp   = (results[0] as ApiResponseOfGetChatsResponse?)?.data;
      final supportResp = (results[1] as ApiResponseOfGetTicketsResponse?)?.data;

      final List<_ChatItem> list = [];

      // ── Regular chats ──────────────────────────────────────────────────────
      final chats = chatsResp?.chats ?? [];
      for (final c in chats) {
        String? avatarUrl = c.otherUserProfileImage;
        if (avatarUrl != null && avatarUrl.isNotEmpty && !avatarUrl.startsWith('http')) {
          avatarUrl = '${ApiService.client.basePath}/${avatarUrl.replaceAll(RegExp(r'^/+'), '')}';
        }
        list.add(_ChatItem(
          id:            c.id ?? '',
          firstName:     c.otherUserFirstName ?? '',
          lastName:      c.otherUserLastName ?? '',
          avatarUrl:     avatarUrl,
          lastMessage:   c.lastMessage,
          lastMessageAt: c.lastMessageAt,
          unreadCount:   c.unreadCount ?? 0,
        ));
      }

      // ── Support Team entry (always shown — same as web) ────────────────────
      final tickets     = supportResp?.tickets ?? [];
      String? supportMsg;
      DateTime? supportDate;
      if (tickets.isNotEmpty) {
        final t = tickets.first;
        supportMsg  = t.lastMessage ?? t.type;
        supportDate = t.updatedAt ?? t.createdAt;
      }
      supportMsg ??= 'we will contact with u soon'.tr;

      list.add(_ChatItem(
        id:            'support',
        firstName:     'Support',
        lastName:      'Team',
        lastMessage:   supportMsg,
        lastMessageAt: supportDate,
        isSupport:     true,
      ));

      // Sort by latest activity (newest first) — same as web
      list.sort((a, b) {
        final dateA = a.lastMessageAt?.millisecondsSinceEpoch ?? 0;
        final dateB = b.lastMessageAt?.millisecondsSinceEpoch ?? 0;
        return dateB.compareTo(dateA);
      });

      setState(() { _items = list; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Failed to load conversations'.tr; _isLoading = false; });
    }
  }

  // ─── Format timestamp ──────────────────────────────────────────────────────

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    final now   = DateTime.now();
    final local = dt.toLocal();
    if (local.year == now.year && local.month == now.month && local.day == now.day) {
      return DateFormat('HH:mm').format(local);
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (local.year == yesterday.year && local.month == yesterday.month && local.day == yesterday.day) {
      return 'Yesterday'.tr;
    }
    return DateFormat('MMM d').format(local);
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColor.backgroundcolor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Messages'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColor.fourthColor))
          : _error != null
              ? _buildError(isDark)
              : _items.isEmpty
                  ? _buildEmpty(isDark)
                  : RefreshIndicator(
                      onRefresh: _loadChats,
                      color: AppColor.fourthColor,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1, indent: 80,
                          color: isDark ? Colors.white10 : Colors.grey[200],
                        ),
                        itemBuilder: (ctx, i) => _buildTile(_items[i], isDark),
                      ),
                    ),
    );
  }

  Widget _buildTile(_ChatItem item, bool isDark) {
    final initials = item.fullName.isNotEmpty ? item.fullName[0].toUpperCase() : 'S';
    final tsStr    = _formatTimestamp(item.lastMessageAt);
    final unread   = item.unreadCount;

    // Support Team gets a special headset icon avatar
    final Widget avatar = item.isSupport
        ? Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.primaryColor.withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.support_agent_rounded, color: AppColor.primaryColor, size: 26),
          )
        : Stack(clipBehavior: Clip.none, children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColor.fourthColor.withValues(alpha: 0.1),
              backgroundImage: (item.avatarUrl != null && item.avatarUrl!.isNotEmpty)
                  ? CachedNetworkImageProvider(item.avatarUrl!)
                  : null,
              child: (item.avatarUrl == null || item.avatarUrl!.isEmpty)
                  ? Text(initials, style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.fourthColor))
                  : null,
            ),
            if (unread > 0)
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: AppColor.successColor, shape: BoxShape.circle,
                    border: Border.all(color: isDark ? const Color(0xFF121212) : Colors.white, width: 2),
                  ),
                ),
              ),
          ]);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: avatar,
      title: Row(children: [
        Expanded(child: Text(
          item.fullName,
          style: TextStyle(
            fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
            fontSize: 15,
            color: isDark ? Colors.white : AppColor.darkText,
          ),
        )),
        if (tsStr.isNotEmpty)
          Text(tsStr, style: TextStyle(
            fontSize: 11,
            color: unread > 0 ? AppColor.fourthColor : (isDark ? Colors.white38 : AppColor.lightText),
            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
          )),
      ]),
      subtitle: item.lastMessage != null
          ? Text(
              item.lastMessage!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : AppColor.mediumText,
                fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            )
          : null,
      trailing: unread > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: AppColor.fourthColor, shape: BoxShape.circle),
              child: Text('$unread', style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            )
          : const Icon(Icons.chevron_right, size: 18, color: AppColor.grey),
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => ChatRoomPage(
            chatId:        item.id,
            otherUserName: item.fullName,
            otherUserImage: item.avatarUrl,
            isSupport:     item.isSupport,
          ),
        ));
        _loadChats();
      },
    );
  }

  Widget _buildEmpty(bool isDark) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.chat_bubble_outline, size: 64, color: isDark ? Colors.white24 : Colors.grey[300]),
    const SizedBox(height: 16),
    Text('No conversations yet'.tr, style: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: isDark ? Colors.white54 : AppColor.mediumText)),
    const SizedBox(height: 8),
    Text('Start a chat from an item listing'.tr,
        style: TextStyle(fontSize: 14, color: isDark ? Colors.white30 : AppColor.lightText)),
  ]));

  Widget _buildError(bool isDark) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
    const SizedBox(height: 16),
    Text(_error!, style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : AppColor.mediumText)),
    const SizedBox(height: 16),
    ElevatedButton(
      onPressed: _loadChats,
      style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor),
      child: Text('Retry'.tr, style: const TextStyle(color: Colors.white)),
    ),
  ]));
}
