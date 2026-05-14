import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/support_controller.dart';
import 'support_detail_view.dart';
import 'create_ticket_sheet.dart';

/// Support tickets list page.
class SupportListView extends StatelessWidget {
  const SupportListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SupportController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text('Support',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const CreateTicketSheet(),
          );
        },
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text('New Ticket',
            style: AppTextStyles.button.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        elevation: 6,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.tickets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.tickets.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadTickets,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: ctrl.tickets.length,
            itemBuilder: (context, index) {
              final ticket = ctrl.tickets[index];
              return _TicketCard(ticket: ticket);
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
            Icon(Icons.support_agent_outlined,
                size: 80, color: AppColors.gray300),
            const SizedBox(height: 24),
            Text('No support tickets',
                style:
                    AppTextStyles.heading3.copyWith(color: AppColors.gray500)),
            const SizedBox(height: 12),
            Text(
                'Need help? Tap the button below\nto create a support ticket.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Individual ticket card.
class _TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final type = ticket['type']?.toString() ?? 'general';
    final typeDisplay = type.replaceAll('_', ' ');
    final status = ticket['status']?.toString() ?? '';
    final statusText = SupportController.statusLabel(status);
    final statusClr = Color(SupportController.statusColor(status));
    final lastMessage = ticket['lastMessage']?.toString() ?? '';
    final createdAt = ticket['createdAt']?.toString() ?? '';
    final ticketId = ticket['id']?.toString() ?? '';

    String dateText = '';
    try {
      final dt = DateTime.parse(createdAt);
      dateText = '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {}

    return GestureDetector(
      onTap: () {
        if (ticketId.isNotEmpty) {
          Get.to(() => SupportDetailView(
                ticketId: ticketId,
                subject: typeDisplay,
                status: status,
              ));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status dot
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusClr,
                  ),
                ),
                Expanded(
                  child: Text(typeDisplay.capitalize ?? typeDisplay,
                      style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusClr.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(statusText,
                      style: AppTextStyles.captionSmall.copyWith(
                        color: statusClr,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (lastMessage.isNotEmpty) ...[
                  Icon(Icons.message_outlined,
                      size: 13, color: AppColors.gray400),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(lastMessage,
                        style: AppTextStyles.captionSmall
                            .copyWith(color: AppColors.gray500, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 16),
                ],
                if (dateText.isNotEmpty) ...[
                  Icon(Icons.calendar_today_outlined,
                      size: 13, color: AppColors.gray400),
                  const SizedBox(width: 4),
                  Text(dateText,
                      style: AppTextStyles.captionSmall
                          .copyWith(color: AppColors.gray500, fontSize: 11)),
                ],
                const Spacer(),
                Icon(Icons.chevron_right, size: 18, color: AppColors.gray400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
