import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/pages/checkout_page.dart';

/// Payment method configuration — matches the Web's PaymentMethodConfig.
class _PaymentMethod {
  final String id;
  final IconData icon;
  final Color color;
  final String label;
  final String? accountNumber;
  final List<String> steps;

  const _PaymentMethod({
    required this.id,
    required this.icon,
    required this.color,
    required this.label,
    this.accountNumber,
    required this.steps,
  });
}

/// Payment page — displays payment methods + order summary and submits
/// via POST /api/v1/payments. Identical flow to the Web's PaymentComponent.
class PaymentPage extends StatefulWidget {
  final String orderId;
  final double totalAmount;
  final List<CheckoutItem> items;

  const PaymentPage({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.items,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedMethod = 'vodafone_cash';
  final _txnRefController = TextEditingController();
  bool _isProcessing = false;
  static const double _deliveryFee = 25;

  // ── Payment Methods (same as Web) ──
  static const List<_PaymentMethod> _methods = [
    _PaymentMethod(
      id: 'vodafone_cash',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFFE53935),
      label: 'Vodafone Cash',
      accountNumber: '01012345678',
      steps: [
        'Open Vodafone Cash app or dial *9*9#',
        'Send the total amount to the number below',
        'Enter the transaction reference number',
      ],
    ),
    _PaymentMethod(
      id: 'fawry',
      icon: Icons.payments_outlined,
      color: Color(0xFFFF8F00),
      label: 'Fawry',
      accountNumber: '123456789',
      steps: [
        'Go to the nearest Fawry outlet',
        'Use the reference code below to pay',
        'Enter the receipt number after payment',
      ],
    ),
    _PaymentMethod(
      id: 'paymob',
      icon: Icons.credit_card_outlined,
      color: Color(0xFF0066FF),
      label: 'Paymob',
      steps: [
        'You will be redirected to Paymob\'s secure payment page',
        'Complete the payment and return to the app',
      ],
    ),
    _PaymentMethod(
      id: 'credit_card',
      icon: Icons.payment_outlined,
      color: Color(0xFF6C63FF),
      label: 'Credit Card',
      steps: [
        'Enter your card details on the secure payment page',
        'Confirm the payment with your bank\'s OTP',
      ],
    ),
    _PaymentMethod(
      id: 'bank_transfer',
      icon: Icons.account_balance_outlined,
      color: Color(0xFF00897B),
      label: 'Bank Transfer',
      accountNumber: 'EG123456789012345678901',
      steps: [
        'Transfer the total amount to the account below',
        'Use your order ID as payment reference',
        'Enter the transfer reference number',
      ],
    ),
  ];

  _PaymentMethod get _currentMethod =>
      _methods.firstWhere((m) => m.id == _selectedMethod);

  double get _subtotal =>
      widget.items.fold(0, (sum, i) => sum + (i.price * i.quantity));
  double get _grandTotal => widget.totalAmount + _deliveryFee;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    try {
      final cmd = CreatePaymentCommand(
        orderId: widget.orderId,
        method: _selectedMethod,
        transactionRef: _txnRefController.text.trim().isNotEmpty
            ? _txnRefController.text.trim()
            : null,
      );

      final resp = await ApiService.payments.createPayment(cmd);
      if (!mounted) return;

      if (resp != null && resp.error != true) {
        _showSuccessDialog();
      } else {
        final msg = (resp?.messages?.isNotEmpty == true)
            ? resp!.messages!.first
            : 'Payment failed. Please try again.';
        _showError(msg);
      }
    } on ApiException catch (e) {
      _showError('Payment error: ${e.message}');
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.successColor.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.check_circle_rounded,
                    color: AppColor.successColor, size: 48),
              ),
              const SizedBox(height: 20),
              const Text('Payment Successful!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Your order #${widget.orderId.substring(0, 8)}... has been confirmed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Navigate back to home
                    Get.offAllNamed('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.fourthColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Back to Home',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Get.offAllNamed('/orders');
                },
                child: Text('View My Orders',
                    style: TextStyle(
                        color: AppColor.fourthColor,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _txnRefController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColor.darkText;
    final subtextColor = isDark ? Colors.white54 : AppColor.mediumText;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Payment',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          // ── Progress Stepper ──
          _buildStepper(isDark),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Select Payment Method ──
                  _sectionHeader(
                    'Select Payment Method',
                    'Choose your preferred way to pay',
                    Icons.credit_score_outlined,
                    textColor,
                    subtextColor,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _methods.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) =>
                          _buildMethodCard(_methods[i], isDark, cardColor),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── How to Pay (instructions) ──
                  _sectionHeader(
                    'How to Pay',
                    _currentMethod.label,
                    Icons.info_outline,
                    textColor,
                    subtextColor,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.3 : 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account number if available
                        if (_currentMethod.accountNumber != null) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _currentMethod.color
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: _currentMethod.color
                                      .withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Account / Reference Number',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: subtextColor,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 4),
                                      Text(
                                        _currentMethod.accountNumber!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: _currentMethod.color,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy_rounded,
                                      color: _currentMethod.color),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(
                                        text:
                                            _currentMethod.accountNumber!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Copied!'),
                                        duration: Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Steps
                        ...List.generate(_currentMethod.steps.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentMethod.color
                                        .withValues(alpha: 0.12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _currentMethod.color,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _currentMethod.steps[i],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textColor,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 8),
                        // Transaction ref input
                        Text('Transaction Reference',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: subtextColor,
                            )),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _txnRefController,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                          decoration: InputDecoration(
                            hintText: 'TXN-XXXXXXXXXX',
                            hintStyle: TextStyle(
                                color:
                                    isDark ? Colors.white24 : Colors.grey[400]),
                            prefixIcon: Icon(Icons.receipt_long_outlined,
                                size: 20,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey[500]),
                            filled: true,
                            fillColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Order Summary ──
                  _sectionHeader(
                    'Order Summary',
                    '${widget.items.length} item${widget.items.length > 1 ? 's' : ''}',
                    Icons.receipt_long_outlined,
                    textColor,
                    subtextColor,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.3 : 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ...widget.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.title,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: textColor),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        Text('× ${item.quantity}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: subtextColor)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${(item.price * item.quantity).toStringAsFixed(0)} EGP',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        Divider(
                            color:
                                isDark ? Colors.grey[700] : Colors.grey[200]),
                        const SizedBox(height: 6),
                        _summaryRow('Subtotal',
                            '${_subtotal.toStringAsFixed(2)} EGP', subtextColor, textColor),
                        const SizedBox(height: 4),
                        _summaryRow('Delivery',
                            '${_deliveryFee.toStringAsFixed(2)} EGP', subtextColor, textColor),
                        const SizedBox(height: 10),
                        Divider(
                            color:
                                isDark ? Colors.grey[700] : Colors.grey[200]),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: textColor)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text('EGP ',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.fourthColor)),
                                Text(_grandTotal.toStringAsFixed(2),
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AppColor.fourthColor)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Trust Bar ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColor.fourthColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              AppColor.fourthColor.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_outlined,
                            size: 16, color: AppColor.fourthColor),
                        const SizedBox(width: 6),
                        Text('Your payment is secure & protected',
                            style: TextStyle(
                              fontSize: 12,
                              color: subtextColor,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Pay Button ──
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.fourthColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColor.fourthColor.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Pay Now · ${_grandTotal.toStringAsFixed(2)} EGP',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: subtextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──

  Widget _buildStepper(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Row(
        children: [
          _stepCircle(0, 1, 'Summary', true),
          _stepLine(true),
          _stepCircle(1, 1, 'Payment', false),
          _stepLine(false),
          _stepCircle(2, 1, 'Done', false),
        ],
      ),
    );
  }

  Widget _stepCircle(
      int step, int current, String label, bool isCompleted) {
    final isActive = step == current;
    final color = isCompleted || isActive
        ? AppColor.fourthColor
        : Colors.grey[400]!;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? AppColor.fourthColor : Colors.transparent,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColor.fourthColor : Colors.grey[500],
              )),
        ],
      ),
    );
  }

  Widget _stepLine(bool filled) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: filled ? AppColor.fourthColor : Colors.grey[300],
      ),
    );
  }

  Widget _buildMethodCard(
      _PaymentMethod method, bool isDark, Color cardColor) {
    final isSelected = _selectedMethod == method.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? method.color.withValues(alpha: 0.08)
              : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? method.color
                : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: method.color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(method.icon,
                size: 28,
                color: isSelected
                    ? method.color
                    : (isDark ? Colors.white54 : Colors.grey[500])),
            const SizedBox(height: 8),
            Text(
              method.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? method.color
                    : (isDark ? Colors.white70 : AppColor.mediumText),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(Icons.check_circle,
                  size: 16, color: method.color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle, IconData icon,
      Color textColor, Color subtextColor) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColor.fourthColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColor.fourthColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor)),
            Text(subtitle,
                style: TextStyle(fontSize: 12, color: subtextColor)),
          ],
        ),
      ],
    );
  }

  Widget _summaryRow(
      String label, String value, Color labelColor, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: labelColor)),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }
}
