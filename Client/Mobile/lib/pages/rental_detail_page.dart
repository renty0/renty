import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/pages/chat_room_page.dart';

class RentalDetailPage extends StatefulWidget {
  final String rentalId;

  const RentalDetailPage({Key? key, required this.rentalId}) : super(key: key);

  @override
  State<RentalDetailPage> createState() => _RentalDetailPageState();
}

class _RentalDetailPageState extends State<RentalDetailPage> {
  bool _isLoading = true;
  bool _isActionLoading = false;
  bool _isDamaged = false;
  bool _isChatting = false;
  bool _isDisputeSubmitting = false;
  ApiResponseOfRentalDetailDto? _response;
  String? _errorMessage;
  int? _ownerId;
  String? _handoffCode;
  bool _isHandoffVerified = false;
  final _handoffCodeController = TextEditingController();
  List<String> _handoverPhotoUrls = [];
  List<String> _returnPhotoUrls = [];

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
      try {
        final rawResp = await ApiService.rentals.getRentalByIdWithHttpInfo(widget.rentalId);
        if (rawResp.statusCode == 200 && rawResp.body.isNotEmpty) {
          final body = jsonDecode(rawResp.body);
          final d = body['data'];
          if (d != null) {
            // Try top-level ownerId first (RentalDetailDto), fallback to owner.id
            if (d['ownerId'] != null) {
              _ownerId = d['ownerId'] is int
                  ? d['ownerId']
                  : int.tryParse(d['ownerId'].toString());
            } else if (d['owner'] != null && d['owner']['id'] != null) {
              _ownerId = d['owner']['id'] is int
                  ? d['owner']['id']
                  : int.tryParse(d['owner']['id'].toString());
            }
            // Extract handoff/photo fields from raw JSON
            _handoffCode = d['handoffCode']?.toString();
            _isHandoffVerified = d['isHandoffVerified'] == true;
            _handoverPhotoUrls = (d['handoverImageUrls'] as List?)?.cast<String>() ?? [];
            _returnPhotoUrls = (d['returnImageUrls'] as List?)?.cast<String>() ?? [];
          }
        }
      } catch (_) {}
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

  Future<void> _startChat() async {
    if (_ownerId == null) {
      Get.snackbar('Info', 'Owner information not available',
          backgroundColor: Colors.grey[700]?.withOpacity(0.9),
          colorText: Colors.white);
      return;
    }
    if (_isChatting) return;
    setState(() => _isChatting = true);
    try {
      final cmd = CreateChatCommand(userId: _ownerId);
      final response = await ApiService.chat.createChat(cmd);
      final chatId = response?.data?.chatId;
      if (chatId != null) {
        Get.to(() => ChatRoomPage(
          chatId: chatId,
          otherUserName: _response?.data?.ownerFirstName ?? 'Owner',
        ));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start chat',
          backgroundColor: AppColor.warningColor.withOpacity(0.9),
          colorText: Colors.white);
    } finally {
      setState(() => _isChatting = false);
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
          await ApiService.rentals.completeRental(widget.rentalId, _isDamaged);
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
                        SizedBox(height: 12),
                        // Chat with Owner button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isChatting ? null : _startChat,
                            icon: _isChatting
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(Icons.chat_bubble_outline, size: 18),
                            label: Text(
                              _isChatting ? 'Opening Chat...' : 'Chat with Owner',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.fourthColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 24),

                  // ── Handoff Code / Verify (Confirmed/Active) ──
                  if (status.toLowerCase() == 'confirmed' || status.toLowerCase() == 'active')
                    _buildHandoffSection(status),

                  // ── Condition Photos ──
                  _buildConditionPhotosSection(status),

                  // Action Buttons
                  _buildActionButtons(status),

                  // Dispute button
                  if (['active', 'completed', 'overdue', 'disputed', 'confirmed']
                      .contains(status.toLowerCase()))
                    _buildDisputeButton(),

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
      case 'overdue':
        buttons.add(
          _buildCompleteSection(),
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
      case 'overdue':
        return Colors.red;
      case 'completed':
        return AppColor.primaryColor;
      case 'cancelled':
        return AppColor.warningColor;
      case 'disputed':
        return Colors.deepOrange;
      default:
        return AppColor.grey;
    }
  }

  // ── Handoff Code / Verify ──
  Widget _buildHandoffSection(String status) {
    // Determine if current user is the owner (mock: check if ownerId matches)
    // Since we can't determine ownership reliably from DTO, show both views
    // In production, backend would provide isOwner flag
    final bool showRenterView = _handoffCode != null && _handoffCode!.isNotEmpty;
    final bool showOwnerVerify = status.toLowerCase() == 'confirmed' && !_isHandoffVerified;

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: _buildInfoCard(
        icon: Icons.vpn_key_rounded,
        title: 'Handoff Verification',
        children: [
          if (showRenterView) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2563eb).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF2563eb).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(Icons.key_rounded, size: 32, color: Color(0xFF2563eb)),
                  SizedBox(height: 8),
                  Text('Handoff Code',
                      style: TextStyle(fontSize: 13, color: AppColor.mediumText)),
                  SizedBox(height: 4),
                  Text(
                    _handoffCode!,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                      color: Color(0xFF2563eb),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Give this code to the owner upon handoff',
                    style: TextStyle(fontSize: 12, color: AppColor.lightText),
                  ),
                ],
              ),
            ),
          ],
          if (showOwnerVerify) ...[
            SizedBox(height: showRenterView ? 12 : 0),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.fourthColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.fourthColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_rounded, size: 20, color: AppColor.fourthColor),
                      SizedBox(width: 8),
                      Text('Verify Handoff Code',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColor.darkText)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _handoffCodeController,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4,
                          ),
                          decoration: InputDecoration(
                            hintText: 'EX: 123456',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0,
                              color: AppColor.lightText,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isActionLoading
                            ? null
                            : () {
                                // MOCK — Backend API not available yet
                                setState(() => _isActionLoading = true);
                                Future.delayed(Duration(seconds: 1), () {
                                  setState(() {
                                    _isActionLoading = false;
                                    _isHandoffVerified = true;
                                  });
                                  Get.snackbar('Success', 'Handoff code verified!',
                                      backgroundColor: AppColor.successColor.withOpacity(0.9),
                                      colorText: Colors.white);
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: _isActionLoading
                            ? SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text('Verify', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (_isHandoffVerified) ...[
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.successColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColor.successColor, size: 20),
                  SizedBox(width: 8),
                  Text('Handoff Verified',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColor.successColor,
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Condition Photos ──
  Widget _buildConditionPhotosSection(String status) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: _buildInfoCard(
        icon: Icons.photo_library_outlined,
        title: 'Condition Photos',
        children: [
          // Handover Photos
          _buildPhotoSubsection(
            title: 'Handover Photos',
            photoUrls: _handoverPhotoUrls,
            canUpload: status.toLowerCase() == 'confirmed',
            uploadLabel: 'Upload handover photos',
          ),
          SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey[200]),
          SizedBox(height: 16),
          // Return Photos
          _buildPhotoSubsection(
            title: 'Return Photos',
            photoUrls: _returnPhotoUrls,
            canUpload: status.toLowerCase() == 'active',
            uploadLabel: 'Upload return photos',
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSubsection({
    required String title,
    required List<String> photoUrls,
    required bool canUpload,
    required String uploadLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.darkText,
                )),
            if (canUpload)
              TextButton.icon(
                onPressed: () {
                  // MOCK — uploadRentalPhotos API not available yet
                  Get.snackbar('Coming Soon',
                      'Photo upload will be available once the backend API is ready.',
                      backgroundColor: Color(0xFF2563eb).withOpacity(0.9),
                      colorText: Colors.white);
                },
                icon: Icon(Icons.add_a_photo_outlined, size: 16),
                label: Text('Upload', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        if (photoUrls.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: photoUrls.map((url) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                url,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            )).toList(),
          )
        else
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported_outlined, size: 28, color: Colors.grey[400]),
                SizedBox(height: 4),
                Text('No photos yet',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
          ),
      ],
    );
  }

  // ── Dispute Button + Bottom Sheet ──
  Widget _buildDisputeButton() {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: () => _showDisputeSheet(),
          icon: Icon(Icons.gavel_rounded, size: 20),
          label: Text('Open Dispute',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.deepOrange,
            side: BorderSide(color: Colors.deepOrange, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  void _showDisputeSheet() {
    String? selectedReason;
    final descController = TextEditingController();
    final reasons = [
      'Item not as described',
      'Item damaged',
      'Late delivery',
      'Payment issue',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
            24, 20, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.gavel_rounded, color: Colors.deepOrange, size: 24),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Open Dispute',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.darkText,
                          )),
                      Text('Report an issue with this rental',
                          style: TextStyle(fontSize: 13, color: AppColor.mediumText)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Warning
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Disputes are reviewed by our team. Please provide accurate details.',
                        style: TextStyle(fontSize: 12, color: Colors.amber[900]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Reason dropdown
              Text('Reason', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedReason,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  hintText: 'Select a reason',
                ),
                items: reasons.map((r) => DropdownMenuItem(
                  value: r, child: Text(r, style: TextStyle(fontSize: 14)),
                )).toList(),
                onChanged: (v) => setSheetState(() => selectedReason = v),
              ),
              SizedBox(height: 16),
              // Description
              Text('Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              SizedBox(height: 8),
              TextField(
                controller: descController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the issue in detail...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
              SizedBox(height: 24),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (selectedReason == null || _isDisputeSubmitting)
                          ? null
                          : () {
                              // MOCK — Dispute API not available yet
                              setSheetState(() => _isDisputeSubmitting = true);
                              Future.delayed(Duration(seconds: 2), () {
                                setSheetState(() => _isDisputeSubmitting = false);
                                Navigator.pop(ctx);
                                Get.snackbar(
                                  'Dispute Submitted',
                                  'Your dispute has been submitted and is under review.',
                                  backgroundColor: Colors.deepOrange.withOpacity(0.9),
                                  colorText: Colors.white,
                                );
                              });
                            },
                      icon: _isDisputeSubmitting
                          ? SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(Icons.gavel_rounded, size: 18),
                      label: Text(
                        _isDisputeSubmitting ? 'Submitting...' : 'Submit Dispute',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatefulBuilder(
          builder: (context, setLocalState) => CheckboxListTile(
            value: _isDamaged,
            onChanged: (v) {
              setLocalState(() => _isDamaged = v ?? false);
              setState(() {});
            },
            title: const Text('Item is damaged',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Check if the item was returned with damage',
                style: TextStyle(fontSize: 12)),
            activeColor: Colors.red,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 8),
        _buildActionButton('Complete Rental', Icons.assignment_turned_in,
            AppColor.successColor, () => _performAction('complete')),
      ],
    );
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
