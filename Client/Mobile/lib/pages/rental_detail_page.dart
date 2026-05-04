import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';

class RentalDetailPage extends StatefulWidget {
  final String rentalId;

  const RentalDetailPage({Key? key, required this.rentalId}) : super(key: key);

  @override
  State<RentalDetailPage> createState() => _RentalDetailPageState();
}

class _RentalDetailPageState extends State<RentalDetailPage> {
  bool _isLoading = true;
  bool _isActionLoading = false;
  ApiResponseOfRentalDetailDto? _response;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRentalDetail();
  }

  Future<void> _loadRentalDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.rentals.getRentalById(widget.rentalId);
      setState(() {
        _response = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load rental details';
        _isLoading = false;
      });
    }
  }

  Future<void> _performAction(String action) async {
    setState(() => _isActionLoading = true);

    try {
      switch (action) {
        case 'confirm':
          await ApiService.rentals.confirmRental(widget.rentalId);
          break;
        case 'activate':
          await ApiService.rentals.activateRental(widget.rentalId);
          break;
        case 'complete':
          await ApiService.rentals.completeRental(widget.rentalId, false);
          break;
        case 'cancel':
          await ApiService.rentals.cancelRental(widget.rentalId);
          break;
      }
      Get.snackbar('Success', 'Rental ${action}ed successfully!',
          backgroundColor: AppColor.successColor.withOpacity(0.9),
          colorText: Colors.white);
      await _loadRentalDetail();
    } catch (e) {
      Get.snackbar('Error', 'Failed to $action rental',
          backgroundColor: AppColor.warningColor.withOpacity(0.9),
          colorText: Colors.white);
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Rental Details',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor))
          : _errorMessage != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
          SizedBox(height: 16),
          Text(_errorMessage!,
              style: TextStyle(fontSize: 16, color: AppColor.mediumText)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRentalDetail,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor),
            child: Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final data = _response?.data;
    if (data == null) return _buildError();

    final dateFormat = DateFormat('MMM dd, yyyy');
    final status = data.status ?? 'Unknown';
    final statusColor = _getStatusColor(status);

    return RefreshIndicator(
      onRefresh: _loadRentalDetail,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image
            if (data.itemImage != null)
              Image.network(
                data.itemImage!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: AppColor.borderGray,
                  child: Icon(Icons.image_not_supported,
                      size: 48, color: AppColor.grey),
                ),
              )
            else
              Container(
                height: 220,
                color: AppColor.borderGray,
                child: Center(
                    child: Icon(Icons.inventory_2_outlined,
                        size: 64, color: AppColor.grey)),
              ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Item Title
                  Text(
                    data.itemTitle ?? 'Untitled Item',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkText,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Rental Period Card
                  _buildInfoCard(
                    icon: Icons.date_range,
                    title: 'Rental Period',
                    children: [
                      _buildInfoRow('Start Date',
                          data.startDate != null
                              ? dateFormat.format(data.startDate!)
                              : 'N/A'),
                      _buildInfoRow('End Date',
                          data.endDate != null
                              ? dateFormat.format(data.endDate!)
                              : 'N/A'),
                      if (data.startDate != null && data.endDate != null)
                        _buildInfoRow('Duration',
                            '${data.endDate!.difference(data.startDate!).inDays} days'),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Pricing Card
                  _buildInfoCard(
                    icon: Icons.payments_outlined,
                    title: 'Pricing',
                    children: [
                      _buildInfoRow('Rental Price',
                          'EGP ${data.rentalPrice?.toStringAsFixed(2) ?? '0.00'}'),
                      if (data.depositAmount != null)
                        _buildInfoRow('Deposit',
                            'EGP ${data.depositAmount!.toStringAsFixed(2)}'),
                      if (data.depositStatus != null)
                        _buildInfoRow('Deposit Status', data.depositStatus!),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Owner Card
                  if (data.ownerFirstName != null)
                    _buildInfoCard(
                      icon: Icons.person_outline,
                      title: 'Owner',
                      children: [
                        _buildInfoRow('Name', data.ownerFirstName!),
                        if (data.ownerCity != null)
                          _buildInfoRow('City', data.ownerCity!),
                      ],
                    ),

                  SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(status),

                  // Review Section (for completed rentals)
                  if (status.toLowerCase() == 'completed' && data.hasReview != true)
                    _buildReviewSection(),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColor.primaryColor),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  TextStyle(fontSize: 14, color: AppColor.mediumText)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.darkText)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    final List<Widget> buttons = [];

    switch (status.toLowerCase()) {
      case 'pending':
        buttons.addAll([
          _buildActionButton('Confirm', Icons.check_circle_outline,
              AppColor.successColor, () => _performAction('confirm')),
          SizedBox(height: 10),
          _buildActionButton('Cancel', Icons.cancel_outlined,
              AppColor.warningColor, () => _performAction('cancel')),
        ]);
        break;
      case 'confirmed':
        buttons.addAll([
          _buildActionButton('Activate', Icons.play_circle_outline,
              Color(0xFF2563eb), () => _performAction('activate')),
          SizedBox(height: 10),
          _buildActionButton('Cancel', Icons.cancel_outlined,
              AppColor.warningColor, () => _performAction('cancel')),
        ]);
        break;
      case 'active':
        buttons.add(
          _buildActionButton('Complete', Icons.check_circle,
              AppColor.successColor, () => _performAction('complete')),
        );
        break;
    }

    if (buttons.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Actions',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.darkText)),
        SizedBox(height: 12),
        ...buttons,
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isActionLoading ? null : onPressed,
        icon: _isActionLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Icon(icon, size: 20),
        label: Text(label,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Color(0xFFd97706);
      case 'confirmed':
        return Color(0xFF2563eb);
      case 'active':
        return AppColor.successColor;
      case 'completed':
        return AppColor.primaryColor;
      case 'cancelled':
        return AppColor.warningColor;
      default:
        return AppColor.grey;
    }
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1A1A1A).withOpacity(0.08),
                Color(0xFF1A1A1A).withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFF1A1A1A).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(Icons.rate_review_outlined, size: 36, color: Color(0xFF1A1A1A)),
              SizedBox(height: 8),
              Text('How was your experience?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.darkText)),
              SizedBox(height: 4),
              Text('Share your feedback to help the community',
                  style: TextStyle(fontSize: 13, color: AppColor.mediumText)),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _showReviewDialog(),
                  icon: Icon(Icons.star_rounded, size: 20),
                  label: Text('Write a Review',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showReviewDialog() {
    int _selectedRating = 5;
    final _commentController = TextEditingController();
    bool _isSubmittingReview = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              24, 24, 24,
              24 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColor.borderGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                Text('Rate Your Rental',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.darkText)),
                SizedBox(height: 20),
                // Star Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setModalState(() => _selectedRating = i + 1),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 40,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 8),
                Text(
                  _getRatingLabel(_selectedRating),
                  style: TextStyle(fontSize: 14, color: AppColor.mediumText, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 20),
                // Comment
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Share your experience (optional)',
                    hintStyle: TextStyle(color: AppColor.lightText),
                    filled: true,
                    fillColor: AppColor.backgroundcolor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmittingReview
                        ? null
                        : () async {
                            setModalState(() => _isSubmittingReview = true);
                            try {
                              await ApiService.reviews.createReview(
                                widget.rentalId,
                                CreateReviewCommand(
                                  rentalId: widget.rentalId,
                                  rating: _selectedRating,
                                  comment: _commentController.text.trim().isEmpty
                                      ? null
                                      : _commentController.text.trim(),
                                ),
                              );
                              Navigator.pop(ctx);
                              Get.snackbar('Thank You!', 'Your review has been submitted',
                                  backgroundColor: AppColor.successColor.withOpacity(0.9),
                                  colorText: Colors.white);
                              await _loadRentalDetail();
                            } catch (e) {
                              Get.snackbar('Error', 'Failed to submit review',
                                  backgroundColor: AppColor.warningColor.withOpacity(0.9),
                                  colorText: Colors.white);
                            } finally {
                              setModalState(() => _isSubmittingReview = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    child: _isSubmittingReview
                        ? SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Submit Review',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1: return 'Poor';
      case 2: return 'Below Average';
      case 3: return 'Average';
      case 4: return 'Good';
      case 5: return 'Excellent';
      default: return '';
    }
  }
}
