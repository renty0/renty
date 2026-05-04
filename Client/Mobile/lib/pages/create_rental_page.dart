import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/controllers/rentals_controller.dart';

class CreateRentalPage extends StatefulWidget {
  final String itemId;
  final String itemTitle;
  final num? dailyPrice;
  final num? weeklyPrice;
  final num? monthlyPrice;

  const CreateRentalPage({
    Key? key,
    required this.itemId,
    required this.itemTitle,
    this.dailyPrice,
    this.weeklyPrice,
    this.monthlyPrice,
  }) : super(key: key);

  @override
  State<CreateRentalPage> createState() => _CreateRentalPageState();
}

class _CreateRentalPageState extends State<CreateRentalPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPricingType = 'daily';
  bool _isSubmitting = false;

  final dateFormat = DateFormat('MMM dd, yyyy');

  num get _estimatedPrice {
    if (_startDate == null || _endDate == null) return 0;
    final days = _endDate!.difference(_startDate!).inDays;
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

  int get _rentalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColor.primaryColor),
          ),
          child: child!,
        );
      },
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
      Get.snackbar('Info', 'Please select a start date first');
      return;
    }
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate!.add(Duration(days: 1)),
      firstDate: _startDate!.add(Duration(days: 1)),
      lastDate: _startDate!.add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColor.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _submitRental() async {
    if (_startDate == null || _endDate == null) {
      Get.snackbar('Error', 'Please select both start and end dates');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final controller = Get.find<RentalsController>();
      final success = await controller.createRental(
        itemId: widget.itemId,
        startDate: _startDate!,
        endDate: _endDate!,
        pricingType: _selectedPricingType,
      );

      if (success) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Rent Item',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.cardShadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.inventory_2_outlined,
                        color: AppColor.primaryColor),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.itemTitle,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColor.darkText),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: 4),
                        if (widget.dailyPrice != null)
                          Text(
                            'EGP ${widget.dailyPrice!.toStringAsFixed(2)} / day',
                            style: TextStyle(
                                fontSize: 14, color: AppColor.primaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Pricing Type
            Text('Pricing Type',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkText)),
            SizedBox(height: 12),
            _buildPricingSelector(),

            SizedBox(height: 24),

            // Date Selection
            Text('Rental Period',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkText)),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDateCard('Start Date', _startDate, _selectStartDate)),
                SizedBox(width: 12),
                Expanded(child: _buildDateCard('End Date', _endDate, _selectEndDate)),
              ],
            ),

            SizedBox(height: 24),

            // Summary
            if (_startDate != null && _endDate != null)
              _buildSummaryCard(),

            SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_startDate == null || _endDate == null || _isSubmitting)
                    ? null
                    : _submitRental,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                  disabledBackgroundColor: AppColor.borderGray,
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('Submit Rental Request',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderGray),
      ),
      child: Row(
        children: [
          if (widget.dailyPrice != null)
            _buildPricingOption('daily', 'Daily',
                'EGP ${widget.dailyPrice!.toStringAsFixed(0)}'),
          if (widget.weeklyPrice != null)
            _buildPricingOption('weekly', 'Weekly',
                'EGP ${widget.weeklyPrice!.toStringAsFixed(0)}'),
          if (widget.monthlyPrice != null)
            _buildPricingOption('monthly', 'Monthly',
                'EGP ${widget.monthlyPrice!.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  Widget _buildPricingOption(String value, String label, String price) {
    final isSelected = _selectedPricingType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPricingType = value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColor.mediumText,
                  )),
              SizedBox(height: 2),
              Text(price,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white70 : AppColor.lightText,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: date != null ? AppColor.primaryColor : AppColor.borderGray,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.cardShadow,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: AppColor.mediumText,
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16,
                    color:
                        date != null ? AppColor.primaryColor : AppColor.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null ? dateFormat.format(date) : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
                      color:
                          date != null ? AppColor.darkText : AppColor.lightText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor.withOpacity(0.05),
            AppColor.primaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rental Summary',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor)),
          SizedBox(height: 12),
          _buildSummaryRow('Duration', '$_rentalDays days'),
          _buildSummaryRow('Pricing', _selectedPricingType.capitalize!),
          Divider(height: 20, color: AppColor.primaryColor.withOpacity(0.2)),
          _buildSummaryRow(
            'Estimated Total',
            'EGP ${_estimatedPrice.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 14,
                color: isBold ? AppColor.primaryColor : AppColor.mediumText,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              )),
          Text(value,
              style: TextStyle(
                fontSize: isBold ? 18 : 14,
                color: isBold ? AppColor.primaryColor : AppColor.darkText,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
