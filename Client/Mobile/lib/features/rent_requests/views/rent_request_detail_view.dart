import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../reviews/views/create_review_sheet.dart';
import '../controllers/rent_request_controller.dart';

/// Detail view for a single rental — full info + action buttons.
class RentRequestDetailView extends StatefulWidget {
  final String requestId;
  final bool isMine;

  const RentRequestDetailView({
    super.key,
    required this.requestId,
    required this.isMine,
  });

  @override
  State<RentRequestDetailView> createState() => _RentRequestDetailViewState();
}

class _RentRequestDetailViewState extends State<RentRequestDetailView> {
  final _ctrl = Get.find<RentRequestController>();

  @override
  void initState() {
    super.initState();
    _ctrl.loadRequestDetail(widget.requestId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text('Rental Details',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final req = _ctrl.selectedRequest.value;
        if (req == null) {
          return const Center(child: Text('Rental not found'));
        }

        final status = req['status']?.toString() ?? '';
        final statusText = RentRequestController.statusLabel(status);
        final statusClr = RentRequestController.statusColor(status);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Status Banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: statusClr.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusClr.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: statusClr.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_statusIcon(status), color: statusClr, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(statusText,
                              style: AppTextStyles.heading3.copyWith(
                                  color: statusClr, fontSize: 18)),
                          const SizedBox(height: 2),
                          Text(
                            _statusDescription(status, widget.isMine),
                            style: AppTextStyles.captionSmall
                                .copyWith(color: statusClr),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Details Card ──
              _buildDetailsCard(req),
              const SizedBox(height: 16),

              // ── Pricing Card ──
              _buildPricingCard(req),

              const SizedBox(height: 24),

              // ── Action Buttons ──
              _buildActions(req, status),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailsCard(Map<String, dynamic> req) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rental Details',
              style: AppTextStyles.heading3.copyWith(fontSize: 16)),
          const SizedBox(height: 16),
          _infoRow('Item', req['itemTitle']?.toString() ?? '—'),
          _infoRow('Start Date', req['startDate']?.toString() ?? '—'),
          _infoRow('End Date', req['endDate']?.toString() ?? '—'),
          if (req['ownerFirstName'] != null)
            _infoRow('Owner', req['ownerFirstName'].toString()),
          if (req['depositStatus'] != null)
            _infoRow('Deposit', req['depositStatus'].toString()),
        ],
      ),
    );
  }

  Widget _buildPricingCard(Map<String, dynamic> req) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pricing',
              style: AppTextStyles.heading3.copyWith(fontSize: 16)),
          const SizedBox(height: 16),
          _infoRow('Rental Price', '${req['rentalPrice'] ?? '—'} EGP'),
          if (req['depositAmount'] != null)
            _infoRow('Deposit', '${req['depositAmount']} EGP'),
          if (req['lateFee'] != null && (req['lateFee'] as num?) != 0)
            _infoRow('Late Fee', '${req['lateFee']} EGP'),
        ],
      ),
    );
  }

  Widget _buildActions(Map<String, dynamic> req, String status) {
    return Obx(() {
      if (_ctrl.isSubmitting.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final id = widget.requestId;
      final statusLower = status.toLowerCase();
      final List<Widget> buttons = [];

      if (statusLower == 'pending') {
        buttons.add(_actionBtn('Confirm', const Color(0xFF10B981),
            Icons.check, () => _ctrl.respondToRequest(id, true)));
        buttons.add(const SizedBox(height: 10));
        buttons.add(_actionBtn('Cancel', AppColors.danger, Icons.close,
            () => _confirmAction('Cancel this rental?', () => _ctrl.cancelRequest(id))));
      }
      if (statusLower == 'confirmed') {
        buttons.add(_actionBtn('Activate Rental', const Color(0xFF10B981),
            Icons.play_arrow, () => _confirmAction('Activate this rental?', () => _ctrl.startRentalAction(id))));
        buttons.add(const SizedBox(height: 10));
        buttons.add(_actionBtn('Cancel', AppColors.danger, Icons.close,
            () => _confirmAction('Cancel this rental?', () => _ctrl.cancelRequest(id))));
      }
      if (statusLower == 'active') {
        buttons.add(_actionBtn('Complete Rental', const Color(0xFF8B5CF6),
            Icons.check_circle, () => _confirmAction('Mark rental as completed?', () => _ctrl.completeRentalAction(id))));
      }
      if (statusLower == 'completed') {
        buttons.add(_actionBtn('Write a Review', const Color(0xFFF59E0B),
            Icons.star, () {
          final itemTitle = req['itemTitle']?.toString() ?? 'Item';
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CreateReviewSheet(
              rentalId: id,
              itemTitle: itemTitle,
            ),
          );
        }));
      }

      if (buttons.isEmpty) return const SizedBox.shrink();

      return Column(children: buttons);
    });
  }

  Widget _actionBtn(
      String label, Color color, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          elevation: 4,
          shadowColor: color.withValues(alpha: 0.3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void _confirmAction(String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Confirm', style: AppTextStyles.heading3),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: AppColors.gray500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.gray500, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodyLarge
                    .copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.hourglass_empty;
      case 'confirmed': return Icons.thumb_up_alt_outlined;
      case 'active': return Icons.play_circle_outline;
      case 'completed': return Icons.check_circle_outline;
      case 'cancelled': return Icons.cancel_outlined;
      default: return Icons.info_outline;
    }
  }

  String _statusDescription(String status, bool isMine) {
    switch (status.toLowerCase()) {
      case 'pending': return isMine ? 'Waiting for confirmation' : 'Awaiting your confirmation';
      case 'confirmed': return 'Ready to activate';
      case 'active': return 'Rental is currently active';
      case 'completed': return 'Rental completed successfully';
      case 'cancelled': return 'This rental was cancelled';
      default: return '';
    }
  }
}
