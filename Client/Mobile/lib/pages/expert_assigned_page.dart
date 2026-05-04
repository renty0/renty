import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';

/// Expert Assigned Items page — shows items assigned to the expert for verification.
class ExpertAssignedPage extends StatefulWidget {
  const ExpertAssignedPage({Key? key}) : super(key: key);

  @override
  State<ExpertAssignedPage> createState() => _ExpertAssignedPageState();
}

class _ExpertAssignedPageState extends State<ExpertAssignedPage> {
  bool _isLoading = true;
  List<AssignedVerificationDto> _assignments = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.verifications.getExpertAssigned();
      if (response != null && response.data != null) {
        setState(() {
          _assignments = response.data!.assignments;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load assigned items';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Expert Assignments',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColor.primaryColor))
          : _errorMessage != null
              ? _buildError()
              : _assignments.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _loadAssignments,
                      color: AppColor.primaryColor,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _assignments.length,
                        itemBuilder: (context, index) =>
                            _buildAssignmentCard(_assignments[index], isDark),
                      ),
                    ),
    );
  }

  Widget _buildAssignmentCard(AssignedVerificationDto assignment, bool isDark) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final checkType = assignment.checkType ?? 'Unknown';

    return GestureDetector(
      onTap: () => _showSubmitVerificationDialog(assignment),
      child: Container(
        margin: EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColor.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: assignment.itemImage != null
                  ? Image.network(
                      assignment.itemImage!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Check Type Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCheckTypeColor(checkType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      checkType.toUpperCase(),
                      style: TextStyle(
                        color: _getCheckTypeColor(checkType),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Title
                  Text(
                    assignment.itemTitleEn ?? assignment.itemTitleAr ?? 'Untitled',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColor.darkText,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Rental Period
                  if (assignment.rentalStartDate != null ||
                      assignment.rentalEndDate != null)
                    Row(
                      children: [
                        Icon(Icons.date_range, size: 16, color: AppColor.lightText),
                        SizedBox(width: 6),
                        Text(
                          '${assignment.rentalStartDate != null ? dateFormat.format(assignment.rentalStartDate!) : '?'} — ${assignment.rentalEndDate != null ? dateFormat.format(assignment.rentalEndDate!) : '?'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : AppColor.mediumText,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 6),
                  // Created At
                  if (assignment.createdAt != null)
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: AppColor.lightText),
                        SizedBox(width: 6),
                        Text(
                          'Assigned: ${dateFormat.format(assignment.createdAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : AppColor.lightText,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 14),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () => _showSubmitVerificationDialog(assignment),
                      icon: Icon(Icons.verified_outlined, size: 18),
                      label: Text('Submit Verification',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
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

  void _showSubmitVerificationDialog(AssignedVerificationDto assignment) {
    String _status = 'Passed';
    final _notesController = TextEditingController();
    bool _isSubmitting = false;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColor.borderGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text('Submit Verification',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                        color: AppColor.darkText)),
                SizedBox(height: 6),
                Text(
                  assignment.itemTitleEn ?? assignment.itemTitleAr ?? 'Item',
                  style: TextStyle(fontSize: 14, color: AppColor.mediumText),
                ),
                SizedBox(height: 20),
                // Status Selection
                Text('Status', style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.darkText)),
                SizedBox(height: 8),
                Row(
                  children: ['Passed', 'Failed', 'NeedsRepair'].map((s) {
                    final selected = _status == s;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => _status = s),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? _getStatusButtonColor(s)
                                : AppColor.backgroundcolor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? _getStatusButtonColor(s)
                                  : AppColor.borderGray,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              s == 'NeedsRepair' ? 'Repair' : s,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : AppColor.mediumText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                // Notes
                Text('Notes', style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColor.darkText)),
                SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add verification notes...',
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
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            setModalState(() => _isSubmitting = true);
                            try {
                              await ApiService.verifications.createVerification(
                                assignment.verificationId ?? '',
                                CreateVerificationCommand(
                                  checkType: assignment.checkType,
                                  status: _status,
                                  notes: _notesController.text.trim().isEmpty
                                      ? null
                                      : _notesController.text.trim(),
                                ),
                              );
                              Navigator.pop(ctx);
                              Get.snackbar('Success', 'Verification submitted!',
                                  backgroundColor: AppColor.successColor.withOpacity(0.9),
                                  colorText: Colors.white);
                              await _loadAssignments();
                            } catch (e) {
                              Get.snackbar('Error', 'Failed to submit verification',
                                  backgroundColor: AppColor.warningColor.withOpacity(0.9),
                                  colorText: Colors.white);
                            } finally {
                              setModalState(() => _isSubmitting = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSubmitting
                        ? SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Submit',
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

  Color _getCheckTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pre-rental':
        return Color(0xFF2563eb);
      case 'post-rental':
        return Color(0xFF1A1A1A);
      case 'damage':
        return AppColor.warningColor;
      default:
        return AppColor.primaryColor;
    }
  }

  Color _getStatusButtonColor(String status) {
    switch (status) {
      case 'Passed':
        return AppColor.successColor;
      case 'Failed':
        return AppColor.warningColor;
      case 'NeedsRepair':
        return Color(0xFFd97706);
      default:
        return AppColor.primaryColor;
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: AppColor.borderGray,
      child: Center(child: Icon(Icons.inventory_2_outlined, size: 48, color: AppColor.grey)),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_outlined, size: 80, color: AppColor.borderGray),
          SizedBox(height: 16),
          Text('No Assignments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.darkText)),
          SizedBox(height: 8),
          Text('No items assigned for verification',
              style: TextStyle(fontSize: 14, color: AppColor.mediumText)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColor.warningColor),
          SizedBox(height: 16),
          Text(_errorMessage!, style: TextStyle(fontSize: 16, color: AppColor.mediumText)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAssignments,
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor),
            child: Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
