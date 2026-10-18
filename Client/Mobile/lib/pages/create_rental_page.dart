import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:renty/core/blocs/rentals/rentals_cubit.dart';
import 'package:renty/pages/checkout_page.dart';
import 'package:renty/pages/payment_page.dart';
import 'package:renty/pages/rental_detail_page.dart';

class CreateRentalPage extends StatefulWidget {
  final String itemId;
  final String itemTitle;
  final String? itemImageUrl;
  final String? ownerName;
  final num? dailyPrice;
  final num? weeklyPrice;
  final num? monthlyPrice;
  final num? depositAmount;

  const CreateRentalPage({
    Key? key,
    required this.itemId,
    required this.itemTitle,
    this.itemImageUrl,
    this.ownerName,
    this.dailyPrice,
    this.weeklyPrice,
    this.monthlyPrice,
    this.depositAmount,
  }) : super(key: key);

  @override
  State<CreateRentalPage> createState() => _CreateRentalPageState();
}

class _CreateRentalPageState extends State<CreateRentalPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPricingType = 'daily';
  bool _isSubmitting = false;
  bool _requestExpertReview = false;
  bool _policyExpanded = false;
  final _notesController = TextEditingController();

  final dateFormat = DateFormat('MMM dd, yyyy');

  static const double _expertReviewFee = 100.0;

  num get _rentalPrice {
    if (_startDate == null || _endDate == null) return 0;
    final days = _endDate!.difference(_startDate!).inDays + 1;
    if (days <= 0) return 0;

    switch (_selectedPricingType) {
      case 'weekly':
        final weeks = (days / 7).ceil();
        return (widget.weeklyPrice ?? widget.dailyPrice ?? 0) * weeks;
      case 'monthly':
        final months = (days / 30).ceil();
        return (widget.monthlyPrice ?? widget.dailyPrice ?? 0) * months;
      default:
        return (widget.dailyPrice ?? 0) * days;
    }
  }

  num get _deposit => widget.depositAmount ?? 0;

  num get _totalAmount =>
      _rentalPrice + _deposit + (_requestExpertReview ? _expertReviewFee : 0);

  int get _rentalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColor.primaryColor),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      AppNavigator.showSnackBar('Info'.tr, 'Please select a start date first'.tr);
      return;
    }
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!.add(const Duration(days: 1)),
      lastDate: _startDate!.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColor.primaryColor),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _endDate = date);
  }

  Future<void> _submitRental() async {
    if (_startDate == null || _endDate == null) {
      AppNavigator.showSnackBar('Error'.tr, 'Please select both start and end dates'.tr, isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final cubit = RentalsCubit.instance;
      final result = await cubit.createRentalFull(
        itemId: widget.itemId,
        startDate: _startDate!,
        endDate: _endDate!,
        pricingType: _selectedPricingType,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        requestExpertReview: _requestExpertReview,
      );

      if (result != null) {
        // Show success animation overlay
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => PopScope(
            canPop: false,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/animations/susscess.json',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                      repeat: false,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Rental Requested!".tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : AppColor.darkText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Your request has been sent to the owner. Let's arrange the handover!".tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : AppColor.lightText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Play celebration animation for 3 seconds
        await Future.delayed(const Duration(milliseconds: 3000));

        // Dismiss the dialog safely
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        // Pop the CreateRentalPage first
        if (mounted) {
          Navigator.pop(context, true);
        }
        
        // Navigate directly to RentalDetailPage for the new pending rental
        if (result.rentalId != null && result.rentalId!.isNotEmpty) {
          AppNavigator.push(RentalDetailPage(rentalId: result.rentalId!));
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Book Item'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Item context card ──
            _buildItemCard(isDark),
            const SizedBox(height: 20),

            // ── Configuration Section ──
            _buildSectionHeader(
                Icons.settings_outlined, 'Rental Period'.tr, isDark),
            const SizedBox(height: 12),
            _buildPricingSelector(isDark),
            const SizedBox(height: 16),

            // Date Range
            Row(
              children: [
                Expanded(
                  child: _buildDateCard(
                    'Start Date'.tr, _startDate, _selectStartDate, isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateCard(
                    'End Date'.tr, _endDate, _selectEndDate, isDark),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Delivery info hint
            _buildInfoBox(
              isDark,
              Icons.info_outline,
              'Delivery date will be negotiated with the owner after the rental is confirmed.'.tr,
            ),
            const SizedBox(height: 16),

            // Notes
            _buildNotesField(isDark),
            const SizedBox(height: 16),

            // Expert Review checkbox
            _buildExpertReviewToggle(isDark),
            const SizedBox(height: 20),

            // ── Price Breakdown ──
            _buildSectionHeader(
                Icons.receipt_long_outlined, 'Rental Cost'.tr, isDark),
            const SizedBox(height: 12),
            _buildPriceBreakdown(isDark),
            const SizedBox(height: 20),

            // ── Cancellation Policy ──
            _buildCancellationPolicy(isDark),
            const SizedBox(height: 28),

            // ── Submit ──
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: (_startDate == null ||
                        _endDate == null ||
                        _isSubmitting)
                    ? null
                    : _submitRental,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  disabledBackgroundColor: isDark
                      ? Colors.grey[800]
                      : AppColor.borderGray,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Confirm Rental'.tr,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildItemCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.inventory_2_outlined, color: AppColor.primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.itemTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColor.darkText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.ownerName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 14,
                          color: isDark ? Colors.white54 : AppColor.lightText),
                      const SizedBox(width: 4),
                      Text(
                        widget.ownerName!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : AppColor.lightText,
                        ),
                      ),
                    ],
                  ),
                ],
                if (widget.dailyPrice != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'EGP ${widget.dailyPrice!.toStringAsFixed(0)} / day',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, bool isDark) {
    return Row(
      children: [
        Icon(icon,
            size: 18,
            color: isDark ? Colors.white70 : AppColor.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColor.darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSelector(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : AppColor.borderGray,
        ),
      ),
      child: Row(
        children: [
          if (widget.dailyPrice != null)
            _buildPricingOption('daily', 'Daily'.tr,
                'EGP ${widget.dailyPrice!.toStringAsFixed(0)}', isDark),
          if (widget.weeklyPrice != null)
            _buildPricingOption('weekly', 'Weekly'.tr,
                'EGP ${widget.weeklyPrice!.toStringAsFixed(0)}', isDark),
          if (widget.monthlyPrice != null)
            _buildPricingOption('monthly', 'Monthly'.tr,
                'EGP ${widget.monthlyPrice!.toStringAsFixed(0)}', isDark),
        ],
      ),
    );
  }

  Widget _buildPricingOption(
      String value, String label, String price, bool isDark) {
    final isSelected = _selectedPricingType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPricingType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : AppColor.mediumText),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                price,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? Colors.white70
                      : (isDark ? Colors.white38 : AppColor.lightText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(
      String label, DateTime? date, VoidCallback onTap, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final selectedColor = AppColor.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: date != null ? selectedColor : (isDark ? Colors.grey[700]! : AppColor.borderGray),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : AppColor.mediumText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 15,
                    color: date != null
                        ? selectedColor
                        : (isDark ? Colors.white38 : AppColor.grey)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date != null ? dateFormat.format(date) : 'Select date'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          date != null ? FontWeight.w600 : FontWeight.normal,
                      color: date != null
                          ? (isDark ? Colors.white : AppColor.darkText)
                          : (isDark ? Colors.white38 : AppColor.lightText),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(bool isDark, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withAlpha(isDark ? 30 : 15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColor.primaryColor.withAlpha(isDark ? 60 : 40),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColor.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : AppColor.mediumText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)'.tr,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColor.mediumText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: TextStyle(
            color: isDark ? Colors.white : AppColor.darkText,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Any special requests or notes for the owner...'.tr,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : AppColor.lightText,
              fontSize: 13,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : AppColor.borderGray,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : AppColor.borderGray,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColor.primaryColor, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildExpertReviewToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _requestExpertReview
              ? AppColor.primaryColor
              : (isDark ? Colors.grey[700]! : AppColor.borderGray),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Expert Review'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColor.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'An expert will inspect the item before and after the rental (+EGP 100)'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppColor.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _requestExpertReview,
                onChanged: (v) =>
                    setState(() => _requestExpertReview = v),
                activeColor: AppColor.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final hasDates = _startDate != null && _endDate != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : AppColor.borderGray,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow(
            hasDates
                ? '${'Rental Duration'.tr} ($_rentalDays ${'days'.tr})'
                : 'Rental Duration'.tr,
            hasDates ? 'EGP ${_rentalPrice.toStringAsFixed(2)}' : '—',
            isDark,
            isPlaceholder: !hasDates,
          ),
          const SizedBox(height: 8),
          _buildPriceRow(
            'Deposit'.tr,
            'EGP ${_deposit.toStringAsFixed(2)}',
            isDark,
          ),
          if (_requestExpertReview) ...[
            const SizedBox(height: 8),
            _buildPriceRow(
              'Expert Review Fee'.tr,
              'EGP ${_expertReviewFee.toStringAsFixed(2)}',
              isDark,
              accent: true,
            ),
          ],
          const SizedBox(height: 12),
          Divider(
              height: 1,
              color: isDark ? Colors.grey[700] : Colors.grey[200]),
          const SizedBox(height: 12),
          _buildPriceRow(
            'Total Cost'.tr,
            hasDates
                ? 'EGP ${_totalAmount.toStringAsFixed(2)}'
                : '—',
            isDark,
            isTotal: true,
            isPlaceholder: !hasDates,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value,
    bool isDark, {
    bool isTotal = false,
    bool accent = false,
    bool isPlaceholder = false,
  }) {
    final labelColor = isTotal
        ? (isDark ? Colors.white : AppColor.darkText)
        : (isDark ? Colors.white60 : AppColor.mediumText);
    final valueColor = isTotal
        ? AppColor.primaryColor
        : accent
            ? AppColor.fourthColor
            : (isDark ? Colors.white : AppColor.darkText);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight:
                isTotal ? FontWeight.w700 : FontWeight.w500,
            color: labelColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight:
                isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isPlaceholder
                ? (isDark ? Colors.white38 : Colors.grey)
                : valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCancellationPolicy(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : AppColor.borderGray,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () =>
                setState(() => _policyExpanded = !_policyExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.policy_outlined,
                      size: 18,
                      color: isDark
                          ? Colors.white70
                          : AppColor.primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cancellation Policy'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? Colors.white : AppColor.darkText,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _policyExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more_rounded,
                        color: isDark
                            ? Colors.white54
                            : AppColor.mediumText),
                  ),
                ],
              ),
            ),
          ),
          if (_policyExpanded) ...[
            Divider(
                height: 1,
                color: isDark ? Colors.grey[700] : Colors.grey[200]),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our flexible cancellation policy gives you peace of mind.'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white54
                          : AppColor.lightText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildPolicyTier(
                    isDark,
                    Icons.check_circle_outline,
                    AppColor.successColor,
                    'Free Cancellation'.tr,
                    'Cancel up to 24 hours before the rental start date for a full refund.'.tr,
                  ),
                  const SizedBox(height: 10),
                  _buildPolicyTier(
                    isDark,
                    Icons.info_outline,
                    AppColors.warning,
                    'Partial Refund'.tr,
                    'Cancel within 24 hours of the start date to receive a 50% refund.'.tr,
                  ),
                  const SizedBox(height: 10),
                  _buildPolicyTier(
                    isDark,
                    Icons.cancel_outlined,
                    AppColors.error,
                    'No Refund'.tr,
                    'Cancellations after the rental has started are non-refundable.'.tr,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColor.fourthColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            AppColor.fourthColor.withAlpha(40),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline,
                            size: 14,
                            color: AppColor.fourthColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'The security deposit is refunded within 3–5 business days after the rental ends without damage.'.tr,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white60
                                  : AppColor.mediumText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPolicyTier(bool isDark, IconData icon, Color iconColor,
      String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColor.darkText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : AppColor.lightText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
