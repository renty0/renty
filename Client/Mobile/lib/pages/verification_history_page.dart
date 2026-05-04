import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';

/// Verification History page — shows all verifications for a given item.
class VerificationHistoryPage extends StatefulWidget {
  const VerificationHistoryPage({Key? key}) : super(key: key);

  @override
  State<VerificationHistoryPage> createState() => _VerificationHistoryPageState();
}

class _VerificationHistoryPageState extends State<VerificationHistoryPage> {
  bool _isLoading = true;
  List<VerificationDto> _verifications = [];
  String? _errorMessage;
  String? _itemId;

  @override
  void initState() {
    super.initState();
    // Item ID is passed via arguments
    final args = ModalRoute.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _itemId = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?)?['itemId'];
      if (_itemId != null) {
        _loadVerifications();
      } else {
        setState(() {
          _errorMessage = 'No item ID provided';
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _loadVerifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.verifications.getVerifications(_itemId!);
      if (response != null && response.data != null) {
        setState(() {
          _verifications = response.data!.verifications ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load verifications';
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
        title: Text('Verification History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColor.primaryColor))
          : _errorMessage != null
              ? _buildError()
              : _verifications.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _loadVerifications,
                      color: AppColor.primaryColor,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _verifications.length,
                        itemBuilder: (context, index) =>
                            _buildVerificationCard(_verifications[index], isDark),
                      ),
                    ),
    );
  }

  Widget _buildVerificationCard(VerificationDto v, bool isDark) {
    final dateFormat = DateFormat('MMM dd, yyyy – hh:mm a');
    final status = v.status ?? 'Unknown';
    final statusColor = _getStatusColor(status);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColor.cardShadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Spacer(),
              // Check Type
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  v.checkType ?? 'Check',
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Expert Name
          if (v.expertFirstName != null)
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: AppColor.lightText),
                SizedBox(width: 6),
                Text('Expert: ${v.expertFirstName!}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : AppColor.darkText,
                    )),
              ],
            ),
          if (v.notes != null && v.notes!.isNotEmpty) ...[
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes_outlined, size: 16, color: AppColor.lightText),
                SizedBox(width: 6),
                Expanded(
                  child: Text(v.notes!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : AppColor.mediumText,
                      )),
                ),
              ],
            ),
          ],
          SizedBox(height: 8),
          // Date
          if (v.createdAt != null)
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: AppColor.lightText),
                SizedBox(width: 6),
                Text(dateFormat.format(v.createdAt!),
                    style: TextStyle(fontSize: 12, color: AppColor.lightText)),
              ],
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'passed':
        return AppColor.successColor;
      case 'failed':
        return AppColor.warningColor;
      case 'needsrepair':
        return Color(0xFFd97706);
      case 'pending':
        return Color(0xFF2563eb);
      default:
        return AppColor.grey;
    }
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fact_check_outlined, size: 80, color: AppColor.borderGray),
          SizedBox(height: 16),
          Text('No Verifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.darkText)),
          SizedBox(height: 8),
          Text('No verification records found for this item',
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
            onPressed: _loadVerifications,
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor),
            child: Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
