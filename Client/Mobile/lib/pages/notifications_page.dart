import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/services/notification_signalr_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;
  List<NotificationDto> _notifications = [];
  int _unreadCount = 0;
  String? _errorMessage;

  final _signalr = NotificationSignalrService();
  StreamSubscription? _notifSub;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _initSignalR();
  }

  Future<void> _initSignalR() async {
    await _signalr.startConnection();
    _notifSub = _signalr.onNotification.listen((notif) {
      if (!mounted) return;
      setState(() {
        _notifications.insert(
          0,
          NotificationDto(
            id: notif.id,
            title: notif.title,
            message: notif.message,
            isRead: false,
            createdAt: notif.createdAt ?? DateTime.now(),
          ),
        );
        _unreadCount++;
      });
      // Show in-app snackbar for real-time notification
      Get.snackbar(
        notif.title ?? 'Notification',
        notif.message ?? '',
        backgroundColor: AppColor.primaryColor.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.notifications_active, color: Colors.white),
        snackPosition: SnackPosition.TOP,
      );
    });
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    _signalr.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.notifications.getNotifications();
      if (response != null && response.data != null) {
        setState(() {
          _notifications = response.data!.notifications;
          _unreadCount = response.data!.unreadCount ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load notifications';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await ApiService.notifications.markNotificationRead(id);
      setState(() {
        final idx = _notifications.indexWhere((n) => n.id == id);
        if (idx >= 0) {
          _notifications[idx].isRead = true;
          _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        }
      });
    } catch (e) {
      print('Error marking notification read: $e');
    }
  }

  Future<void> _markAllRead() async {
    try {
      await ApiService.notifications.markAllNotificationsRead();
      setState(() {
        for (var n in _notifications) {
          n.isRead = true;
        }
        _unreadCount = 0;
      });
      Get.snackbar('Done', 'All notifications marked as read',
          backgroundColor: AppColor.successColor.withOpacity(0.9),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark all as read');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text('Mark all read',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColor.primaryColor))
          : _errorMessage != null
              ? _buildError(context)
              : _notifications.isEmpty
                  ? _buildEmpty(context)
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: AppColor.primaryColor,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) =>
                            _buildNotificationTile(context, _notifications[index]),
                      ),
                    ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationDto notification) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = notification.isRead != true;
    final timeAgo = notification.createdAt != null
        ? _formatTimeAgo(notification.createdAt!)
        : '';

    return InkWell(
      onTap: () {
        if (isUnread && notification.id != null) {
          _markAsRead(notification.id!);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColor.fourthColor.withOpacity(0.05)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: isDark ? const Color(0xFF334155) : AppColor.borderGray.withOpacity(0.5)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot
            Container(
              width: 10,
              height: 10,
              margin: EdgeInsets.only(top: 5, right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnread ? AppColor.fourthColor : Colors.transparent,
              ),
            ),
            // Icon
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getNotificationIcon(notification.title ?? ''),
                size: 20,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title ?? 'Notification',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                      color: isDark ? Colors.white : AppColor.darkText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    notification.message ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : AppColor.mediumText,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : AppColor.lightText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('rental')) return Icons.receipt_long_outlined;
    if (t.contains('order')) return Icons.shopping_bag_outlined;
    if (t.contains('payment')) return Icons.payment;
    if (t.contains('review')) return Icons.star_outline;
    if (t.contains('chat') || t.contains('message')) return Icons.chat_bubble_outline;
    return Icons.notifications_outlined;
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd').format(date);
  }

  Widget _buildEmpty(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: isDark ? const Color(0xFF334155) : AppColor.borderGray),
          SizedBox(height: 16),
          Text('No Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColor.darkText)),
          SizedBox(height: 8),
          Text("You're all caught up!",
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColor.mediumText)),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
          SizedBox(height: 16),
          Text(_errorMessage!, style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : AppColor.mediumText)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNotifications,
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor),
            child: Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
