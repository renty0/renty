import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';
import '../controllers/support_controller.dart';

/// Bottom sheet for creating a new support ticket.
/// Swagger POST /api/v1/support/tickets body: { "type": "string", "message": "string" }
class CreateTicketSheet extends StatefulWidget {
  const CreateTicketSheet({super.key});

  @override
  State<CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends State<CreateTicketSheet> {
  final _ctrl = Get.find<SupportController>();
  final _messageCtrl = TextEditingController();
  String _selectedType = 'general';

  static const _types = [
    'general',
    'billing',
    'technical',
    'account',
    'rental_issue',
    'other',
  ];

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

            Text('New Support Ticket',
                style: AppTextStyles.heading2.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text('We will get back to you as soon as possible.',
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.gray500)),
            const SizedBox(height: 24),

            // Type dropdown
            Text('Type',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gray200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  items: _types.map((t) {
                    final display = t.replaceAll('_', ' ');
                    return DropdownMenuItem(
                      value: t,
                      child: Text(display.capitalizeFirst ?? display,
                          style: AppTextStyles.bodyLarge.copyWith(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Message
            CustomTextField(
              label: 'Describe your issue',
              controller: _messageCtrl,
              prefixIcon: const Icon(Icons.message_outlined),
              maxLines: 4,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Message is required' : null,
            ),
            const SizedBox(height: 24),

            // Submit
            Obx(() => LoadingButton(
                  text: 'Submit Ticket',
                  isLoading: _ctrl.isSubmitting.value,
                  onPressed: () async {
                    final success = await _ctrl.createTicket(
                      _selectedType,
                      _messageCtrl.text,
                    );
                    if (success && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
