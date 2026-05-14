import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';
import '../controllers/rent_request_controller.dart';

/// Bottom sheet for creating a rent request from the product detail page.
class CreateRentRequestSheet extends StatefulWidget {
  final String rentableItemId;
  final String itemTitle;
  final num dailyPrice;

  const CreateRentRequestSheet({
    super.key,
    required this.rentableItemId,
    required this.itemTitle,
    required this.dailyPrice,
  });

  @override
  State<CreateRentRequestSheet> createState() => _CreateRentRequestSheetState();
}

class _CreateRentRequestSheetState extends State<CreateRentRequestSheet> {
  late final RentRequestController _ctrl;
  final _messageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<RentRequestController>()) {
      Get.put(RentRequestController());
    }
    _ctrl = Get.find<RentRequestController>();
    // Reset form
    _ctrl.startDate.value = null;
    _ctrl.endDate.value = null;
    _ctrl.message.value = '';
    _ctrl.isDeliveryRequested.value = false;
    _ctrl.deliveryAddress.value = '';
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_ctrl.startDate.value ?? now)
          : (_ctrl.endDate.value ?? _ctrl.startDate.value ?? now),
      firstDate: isStart ? now : (_ctrl.startDate.value ?? now),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      if (isStart) {
        _ctrl.startDate.value = picked;
        // Reset end date if before start
        if (_ctrl.endDate.value != null &&
            _ctrl.endDate.value!.isBefore(picked)) {
          _ctrl.endDate.value = null;
        }
      } else {
        _ctrl.endDate.value = picked;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Text('Rent Request',
                style: AppTextStyles.heading2.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(widget.itemTitle,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.gray500)),
            const SizedBox(height: 4),
            Text('${widget.dailyPrice} EGP/day',
                style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 24),

            // ── Date Pickers ──
            Row(
              children: [
                Expanded(
                  child: Obx(() => _dateField(
                        'Start Date',
                        _ctrl.startDate.value,
                        fmt,
                        () => _pickDate(true),
                      )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => _dateField(
                        'End Date',
                        _ctrl.endDate.value,
                        fmt,
                        () => _pickDate(false),
                      )),
                ),
              ],
            ),

            // ── Estimated total ──
            Obx(() {
              if (_ctrl.startDate.value != null &&
                  _ctrl.endDate.value != null) {
                final days = _ctrl.endDate.value!
                        .difference(_ctrl.startDate.value!)
                        .inDays +
                    1;
                final total = widget.dailyPrice * days;
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$days days',
                            style: AppTextStyles.bodyLarge
                                .copyWith(fontWeight: FontWeight.w600)),
                        Text('≈ $total EGP',
                            style: AppTextStyles.heading3.copyWith(
                                color: AppColors.primary, fontSize: 16)),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 16),

            // ── Message ──
            CustomTextField(
              label: 'Message to owner (optional)',
              controller: _messageCtrl,
              prefixIcon: const Icon(Icons.message_outlined),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // ── Delivery toggle ──
            Obx(() => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Request Delivery',
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('Have the item delivered to you',
                      style: AppTextStyles.captionSmall),
                  value: _ctrl.isDeliveryRequested.value,
                  activeColor: AppColors.primary,
                  onChanged: (v) => _ctrl.isDeliveryRequested.value = v,
                )),

            // ── Delivery address ──
            Obx(() {
              if (!_ctrl.isDeliveryRequested.value) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CustomTextField(
                  label: 'Delivery Address',
                  controller: _addressCtrl,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Address is required' : null,
                ),
              );
            }),
            const SizedBox(height: 24),

            // ── Submit ──
            Obx(() => LoadingButton(
                  text: 'Submit Request',
                  isLoading: _ctrl.isSubmitting.value,
                  onPressed: () async {
                    _ctrl.message.value = _messageCtrl.text.trim();
                    _ctrl.deliveryAddress.value = _addressCtrl.text.trim();
                    final success =
                        await _ctrl.createRequest(widget.rentableItemId);
                    if (success && mounted) Navigator.of(context).pop();
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _dateField(
      String label, DateTime? value, DateFormat fmt, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: AppColors.gray400),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.captionSmall
                          .copyWith(fontSize: 10, color: AppColors.gray400)),
                  const SizedBox(height: 2),
                  Text(
                    value != null ? fmt.format(value) : 'Select',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: value != null
                          ? AppColors.gray700
                          : AppColors.gray400,
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
}
