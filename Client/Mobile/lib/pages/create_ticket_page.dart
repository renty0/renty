import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _messageController = TextEditingController();
  String _selectedType = 'General';
  bool _isSubmitting = false;

  static const _types = [
    {'value': 'General', 'label': 'General'},
    {'value': 'Billing', 'label': 'Billing'},
    {'value': 'Rental', 'label': 'Rental'},
    {'value': 'Payment', 'label': 'Payment'},
    {'value': 'Technical', 'label': 'Technical'},
    {'value': 'Other', 'label': 'Other'},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _showSnackbar('Please enter a message'.tr, isError: true);
      return;
    }
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final command = CreateTicketCommand(
        type: _selectedType,
        message: message,
      );
      final response = await ApiService.support.createSupportTicket(command);
      if (!mounted) return;

      _showSnackbar('Ticket created successfully'.tr, isError: false);

      // Navigate to ticket detail if we got an ID, otherwise go back
      if (response?.data?.ticketId != null) {
        Get.offNamed('/support/detail',
            arguments: response!.data!.ticketId);
      } else {
        Get.back(result: true);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnackbar('Failed to create ticket'.tr, isError: true);
      print('CreateTicket error: ${e.code} ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnackbar('Failed to create ticket'.tr, isError: true);
    }
  }

  void _showSnackbar(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(msg.tr)),
      ]),
      backgroundColor:
          isError ? const Color(0xFFDC2626) : AppColor.primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('New Ticket'.tr,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Type Selector ──
              Text('Ticket Type'.tr,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColor.darkText)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey[300]!,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white : AppColor.darkText,
                    ),
                    items: _types
                        .map((t) => DropdownMenuItem(
                              value: t['value'],
                              child: Text(t['label']!.tr),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedType = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Message ──
              Text('Message'.tr,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColor.darkText)),
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                maxLines: 8,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : AppColor.darkText,
                ),
                decoration: InputDecoration(
                  hintText: 'Describe your issue or question...'.tr,
                  hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey[400]),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white12 : Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.white12 : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColor.fourthColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Submit ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, size: 20),
                  label: Text(_isSubmitting ? 'Submitting...'.tr : 'Submit Ticket'.tr,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.fourthColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColor.fourthColor.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
