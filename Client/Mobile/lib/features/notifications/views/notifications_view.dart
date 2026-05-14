import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/notifications_controller.dart';

/// Notifications page — list of system notifications with read/unread states.
class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<NotificationsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text('Notifications',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Obx(() {
            if (ctrl.unreadCount.value > 0) {
              return TextButton.icon(
                onPressed: ctrl.markAllAsRead,
                icon: const Icon(Icons.done_all, size: 18, color: AppColors.white),
                label: Text('Read all',
                    style: AppTextStyles.captionSmall
                        .copyWith(color: AppColors.white, fontSize: 12)),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: ctrl.notifications.length,
            itemBuilder: (context, index) {
              final notif = ctrl.notifications[index];
              return _NotificationCard(notif: notif, ctrl: ctrl);
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
            Icon(Icons.notifications_none_outlined,
                size: 80, color: AppColors.gray300),
            const SizedBox(height: 24),
            Text('No notifications',
                style:
                    AppTextStyles.heading3.copyWith(color: AppColors.gray500)),
            const SizedBox(height: 12),
            Text('You are all caught up!\nNotifications will appear here.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Individual notification card.
class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notif;
  final NotificationsController ctrl;

  const _NotificationCard({required this.notif, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isRead = notif['isRead'] == true;
    final title = notif['title']?.toString() ?? '';
    final message = notif['message']?.toString() ?? '';
    final createdAt = notif['createdAt']?.toString() ?? '';
    final id = notif['id']?.toString() ?? '';

    String timeText = '';
    try {
      final dt = DateTime.parse(createdAt);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) {
        timeText = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        timeText = '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        timeText = '${diff.inDays}d ago';
      } else {
        timeText = DateFormat('MMM d').format(dt);
      }
    } catch (_) {
      timeText = createdAt;
    }

    return GestureDetector(
      onTap: () {
        if (!isRead && id.isNotEmpty) {
          ctrl.markAsRead(id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? AppColors.white : AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? AppColors.gray100 : AppColors.primary.withValues(alpha: 0.15),
          ),
          boxShadow: [
            if (!isRead)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 5, right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRead
                    ? Colors.transparent
                    : AppColors.primary,
              ),
            ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeText,
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.gray400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isRead ? AppColors.gray500 : AppColors.gray700,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
