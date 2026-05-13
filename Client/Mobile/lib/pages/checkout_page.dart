import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/pages/payment_page.dart';

/// Checkout page — displays order summary and creates the order via API.
/// Mirrors the Web's checkout-summary → payment → confirmation flow.
class CheckoutPage extends StatefulWidget {
  /// Items the user wants to order. Each entry needs itemId + quantity.
  /// The display info (title, image, price) is passed for the summary card.
  final List<CheckoutItem> items;

  const CheckoutPage({super.key, required this.items});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isCreating = false;
  static const double _deliveryFee = 25;

  double get _subtotal => widget.items.fold(
      0, (sum, i) => sum + (i.price * i.quantity));
  double get _total => _subtotal + _deliveryFee;

  Future<void> _placeOrder() async {
    setState(() => _isCreating = true);
    try {
      final cmd = CreateOrderCommand(
        items: widget.items
            .map((i) => OrderItemInputDto(
                  itemId: i.itemId,
                  quantity: i.quantity,
                ))
            .toList(),
      );
      final resp = await ApiService.orders.createOrder(cmd);
      if (!mounted) return;

      if (resp != null && resp.data != null && resp.error != true) {
        final orderId = resp.data!.orderId ?? '';
        final totalAmount = resp.data!.totalAmount?.toDouble() ?? _total;
        // Navigate to payment page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentPage(
              orderId: orderId,
              totalAmount: totalAmount,
              items: widget.items,
            ),
          ),
        );
      } else {
        final msg = (resp?.messages?.isNotEmpty == true)
            ? resp!.messages!.first
            : 'Failed to create order';
        _showError(msg);
      }
    } on ApiException catch (e) {
      _showError('Order failed: ${e.message}');
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColor.darkText;
    final subtextColor = isDark ? Colors.white54 : AppColor.mediumText;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          // ── Progress Stepper ──
          _buildStepper(isDark, currentStep: 0),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Order Items ──
                  _sectionTitle('Order Items', Icons.shopping_bag_outlined, textColor),
                  const SizedBox(height: 12),
                  ...widget.items.map((item) => _buildItemCard(
                      item, isDark, cardColor, textColor, subtextColor)),
                  const SizedBox(height: 20),

                  // ── Price Summary ──
                  _sectionTitle('Price Summary', Icons.receipt_long_outlined, textColor),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _costRow('Subtotal', '${_subtotal.toStringAsFixed(2)} EGP',
                            textColor, subtextColor),
                        const SizedBox(height: 10),
                        _costRow('Delivery Fee', '${_deliveryFee.toStringAsFixed(2)} EGP',
                            textColor, subtextColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Divider(
                              color: isDark ? Colors.grey[700] : Colors.grey[200]),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                )),
                            Text('${_total.toStringAsFixed(2)} EGP',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.fourthColor,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Security Trust Bar ──
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColor.fourthColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColor.fourthColor.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _trustItem(Icons.verified_user_outlined, 'SSL Secured', subtextColor),
                        Container(height: 20, width: 1,
                            color: AppColor.fourthColor.withValues(alpha: 0.2)),
                        _trustItem(Icons.lock_outline, 'Encrypted', subtextColor),
                        Container(height: 20, width: 1,
                            color: AppColor.fourthColor.withValues(alpha: 0.2)),
                        _trustItem(Icons.shield_outlined, 'Protected', subtextColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Action Bar ──
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
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isCreating ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.fourthColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColor.fourthColor.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _isCreating
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
                        'Place Order · ${_total.toStringAsFixed(2)} EGP',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──

  Widget _buildStepper(bool isDark, {required int currentStep}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Row(
        children: [
          _stepCircle(0, currentStep, 'Summary'),
          _stepLine(currentStep >= 1),
          _stepCircle(1, currentStep, 'Payment'),
          _stepLine(currentStep >= 2),
          _stepCircle(2, currentStep, 'Done'),
        ],
      ),
    );
  }

  Widget _stepCircle(int step, int current, String label) {
    final isCompleted = step < current;
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
                        fontSize: 13,
                      ),
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

  Widget _sectionTitle(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColor.fourthColor),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textColor,
            )),
      ],
    );
  }

  Widget _buildItemCard(CheckoutItem item, bool isDark, Color cardColor,
      Color textColor, Color subtextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 64,
                      height: 64,
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFE8E8E8),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFE8E8E8),
                      child: Icon(Icons.image, color: Colors.grey[400]),
                    ),
                  )
                : Container(
                    width: 64,
                    height: 64,
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE8E8E8),
                    child: Icon(Icons.image, color: Colors.grey[400]),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('× ${item.quantity}',
                    style: TextStyle(
                      fontSize: 13,
                      color: subtextColor,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('${(item.price * item.quantity).toStringAsFixed(0)} EGP',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColor.fourthColor,
              )),
        ],
      ),
    );
  }

  Widget _costRow(
      String label, String value, Color textColor, Color subtextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: subtextColor)),
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
      ],
    );
  }

  Widget _trustItem(IconData icon, String label, Color subtextColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColor.fourthColor),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: subtextColor, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

/// Data class for items in the checkout flow.
/// Carries display info + the itemId/quantity needed for the API.
class CheckoutItem {
  final String itemId;
  final String title;
  final double price;
  final int quantity;
  final String? imageUrl;

  const CheckoutItem({
    required this.itemId,
    required this.title,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
  });
}
