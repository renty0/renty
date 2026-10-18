import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/main.dart';
import 'package:renty/pages/chat_room_page.dart';

class RentalDetailPage extends StatefulWidget {
  final String rentalId;

  const RentalDetailPage({Key? key, required this.rentalId}) : super(key: key);

  @override
  State<RentalDetailPage> createState() => _RentalDetailPageState();
}

class _RentalDetailPageState extends State<RentalDetailPage> {
  bool _isLoading = true;
  final Map<String, bool> _loadingStates = {};

  bool _isLoadingState(String key) => _loadingStates[key] == true;

  void _setLoadingState(String key, bool val) {
    if (mounted) {
      setState(() {
        _loadingStates[key] = val;
      });
    }
  }

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

  bool _ownerWantsExpertAtConfirm = false;
  String _handoffDeliveryMethod = 'ByHand';
  String _selectedDeliveryMethodFromExpert = 'ByHand';
  String _returnDeliveryMethod = 'ByHand';
  bool _showReturnOptions = false;
  bool _reviewSubmitted = false; // track if review was submitted this session
  bool _hasReview = false; // track if review is already submitted on server

  @override
  void initState() {
    super.initState();
    _loadRentalDetail(showFullScreenLoader: true);
  }

  Future<void> _loadRentalDetail({bool showFullScreenLoader = false}) async {
    if (showFullScreenLoader || _response == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

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
            _hasReview = d['hasReview'] == true;
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
    final data = _response?.data;
    if (data == null) return;
    if (_isChatting) return;

    final currentUserId = cachedUserId; // SECURITY: in-memory cache from Keystore/Keychain
    final bool isOwner = data.ownerId?.toString() == currentUserId;

    // If current user is the owner, chat with the renter; otherwise chat with the owner
    final int? targetUserId = isOwner
        ? (data.renterId is int ? data.renterId as int : int.tryParse(data.renterId?.toString() ?? ''))
        : _ownerId;
    final String otherUserName = isOwner
        ? (data.renterFirstName ?? 'Renter')
        : (data.ownerFirstName ?? 'Owner');

    if (targetUserId == null) {
      AppNavigator.showSnackBar('Info'.tr, 'User information not available'.tr,
          backgroundColor: Colors.grey[700]?.withOpacity(0.9),
          colorText: Colors.white);
      return;
    }

    setState(() => _isChatting = true);
    try {
      final cmd = CreateChatCommand(
        userId: targetUserId,
        itemId: data.itemId?.toString(),
      );
      final response = await ApiService.chat.createChat(cmd);
      final chatId = response?.data?.chatId;
      if (chatId != null) {
        AppNavigator.push(ChatRoomPage(
          chatId: chatId,
          otherUserName: otherUserName,
        ));
      }
    } catch (e) {
      AppNavigator.showSnackBar('Error'.tr, 'Failed to start chat'.tr,
          backgroundColor: AppColor.warningColor.withOpacity(0.9),
          colorText: Colors.white);
    } finally {
      setState(() => _isChatting = false);
    }
  }

  Future<void> _confirmRental() async {
    _setLoadingState('confirm_rental', true);
    try {
      if (_ownerWantsExpertAtConfirm) {
        await ApiService.client.invokeAPI(
          '/api/v1/rentals/${widget.rentalId}/expert-review',
          'POST', [], null, {}, {}, null,
        );
      }
      await ApiService.rentals.confirmRental(widget.rentalId);
      AppNavigator.showSnackBar('Success'.tr, 'Rental confirmed successfully!'.tr,
          backgroundColor: AppColor.successColor.withOpacity(0.9), colorText: Colors.white);
      await _loadRentalDetail();
    } catch (e) {
      AppNavigator.showSnackBar('Error'.tr, 'Failed to confirm rental'.tr,
          backgroundColor: AppColor.warningColor.withOpacity(0.9), colorText: Colors.white);
    } finally {
      _setLoadingState('confirm_rental', false);
    }
  }

  Future<void> _cancelRental() async {
    _setLoadingState('cancel_rental', true);
    try {
      await ApiService.rentals.cancelRental(widget.rentalId);
      AppNavigator.showSnackBar('Success'.tr, 'Rental cancelled successfully!'.tr,
          backgroundColor: AppColor.successColor.withOpacity(0.9), colorText: Colors.white);
      await _loadRentalDetail();
    } catch (e) {
      AppNavigator.showSnackBar('Error'.tr, 'Failed to cancel rental'.tr,
          backgroundColor: AppColor.warningColor.withOpacity(0.9), colorText: Colors.white);
    } finally {
      _setLoadingState('cancel_rental', false);
    }
  }

  Future<void> _setHandoffMethod() async {
    _setLoadingState('set_handoff', true);
    try {
      final body = SetHandoffMethodBody(handoffMethod: _handoffDeliveryMethod);
      await ApiService.rentals.setHandoffMethod(widget.rentalId, body);
      AppNavigator.showSnackBar('Success'.tr, 'Delivery method set successfully!'.tr,
          backgroundColor: AppColor.successColor.withOpacity(0.9), colorText: Colors.white);
      await _loadRentalDetail();
    } catch (e) {
      AppNavigator.showSnackBar('Error'.tr, 'Failed to set delivery method'.tr,
          backgroundColor: AppColor.warningColor.withOpacity(0.9), colorText: Colors.white);
    } finally {
      _setLoadingState('set_handoff', false);
    }
  }

  Future<void> _initiateReturn(String method) async {
    _setLoadingState('initiate_return', true);
    try {
      await ApiService.client.invokeAPI(
        '/api/v1/rentals/${widget.rentalId}/possession?action=initiate_return&method=$method',
        'PUT', [], null, {}, {}, null,
      );
      AppNavigator.showSnackBar('Success'.tr, 'Return initiated successfully!'.tr,
          backgroundColor: AppColor.successColor.withOpacity(0.9), colorText: Colors.white);
      setState(() => _showReturnOptions = false);
      await _loadRentalDetail();
    } catch (e) {
      AppNavigator.showSnackBar('Error'.tr, 'Failed to initiate return'.tr,
          backgroundColor: AppColor.warningColor.withOpacity(0.9), colorText: Colors.white);
    } finally {
      _setLoadingState('initiate_return', false);
    }
  }

  Future<void> _confirmReceipt() async {
    _setLoadingState('confirm_receipt', true);
    try {
      await ApiService.client.invokeAPI(
        '/api/v1/rentals/${widget.rentalId}/possession?action=confirm_receipt&method=ByHand',
        'PUT', [], null, {}, {}, null,
      );
      AppNavigator.showSnackBar('Success'.tr, 'Receipt confirmed successfully!'.tr,
          backgroundColor: AppColor.successColor.withOpacity(0.9), colorText: Colors.white);
      await _loadRentalDetail();
    } catch (e) {
      AppNavigator.showSnackBar('Error'.tr, 'Failed to confirm receipt'.tr,
          backgroundColor: AppColor.warningColor.withOpacity(0.9), colorText: Colors.white);
    } finally {
      _setLoadingState('confirm_receipt', false);
    }
  }

  Future<void> _completeRental() async {
    _setLoadingState('complete_rental', true);
    try {
      await ApiService.rentals.completeRental(widget.rentalId, _isDamaged);
      AppNavigator.showSnackBar('Success'.tr, 'Rental completed successfully!'.tr,
          backgroundColor: AppColor.successColor.withOpacity(0.9), colorText: Colors.white);
      await _loadRentalDetail();
    } catch (e) {
      AppNavigator.showSnackBar('Error'.tr, 'Failed to complete rental'.tr,
          backgroundColor: AppColor.warningColor.withOpacity(0.9), colorText: Colors.white);
    } finally {
      _setLoadingState('complete_rental', false);
    }
  }

  Future<void> _pickAndUploadPhoto(String type) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('Take Photo'.tr),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('Choose from Gallery'.tr),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1200, imageQuality: 80);
    if (picked == null) return;

    final String uploadKey = type == 'Handover' ? 'upload_handover' : 'upload_return';
    _setLoadingState(uploadKey, true);

    try {
      final ext = picked.path.split('.').last.toLowerCase();
      final mime = const {
        'jpg': 'jpeg',
        'jpeg': 'jpeg',
        'png': 'png',
        'gif': 'gif',
        'webp': 'webp',
        'heic': 'heic',
      }[ext] ?? 'jpeg';

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        picked.path,
        filename: picked.name,
        contentType: MediaType('image', mime),
      );
      final response = await ApiService.media.uploadMedia(
        entityId: widget.rentalId,
        entityType: 'Rental',
        file: multipartFile,
      );

      if (response == null || response.data?.id == null) {
        _setLoadingState(uploadKey, false);
        AppNavigator.showSnackBar('Error'.tr, 'Failed to upload photo'.tr,
            backgroundColor: AppColor.warningColor.withOpacity(0.9), colorText: Colors.white);
        return;
      }

      final mediaId = response.data!.id;

      if (mediaId == null) {
        _setLoadingState(uploadKey, false);
        AppNavigator.showSnackBar('Error'.tr, 'Failed to get media ID'.tr,
            backgroundColor: AppColor.warningColor.withOpacity(0.9), colorText: Colors.white);
        return;
      }

      final imgType = type == 'Handover' ? RentalImageType.number1 : RentalImageType.number2;
      final uploadBody = UploadRentalPhotosBody(
        imageIds: [mediaId],
        type: imgType,
      );
      await ApiService.rentals.uploadRentalPhotos(widget.rentalId, uploadBody);

      AppNavigator.showSnackBar('Success'.tr, '$type photo uploaded!'.tr,
          backgroundColor: AppColor.successColor.withOpacity(0.9), colorText: Colors.white);
      await _loadRentalDetail();
    } catch (e) {
      AppNavigator.showSnackBar('Error'.tr, 'Photo upload failed'.tr,
          backgroundColor: AppColor.warningColor.withOpacity(0.9), colorText: Colors.white);
    } finally {
      _setLoadingState(uploadKey, false);
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

    final currentUserId = cachedUserId; // SECURITY: in-memory cache from Keystore/Keychain
    final bool isOwner = data.ownerId?.toString() == currentUserId;
    final bool isRenter = data.renterId?.toString() == currentUserId;
    final String currentUserRole = isOwner ? 'Owner' : (isRenter ? 'Renter' : 'Unknown');

    return RefreshIndicator(
      onRefresh: _loadRentalDetail,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image
            if (data.itemImageUrl != null)
              CachedNetworkImage(
                imageUrl: data.itemImageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 220,
                  color: AppColor.borderGray,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (_, __, ___) => Container(
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

                  const SizedBox(height: 16),

                  // Item Title
                  Text(
                    data.itemTitle ?? 'Untitled Item',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkText,
                    ),
                  ),

                  const SizedBox(height: 24),

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

                  const SizedBox(height: 16),

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
                      if (data.expertReviewFee != null && data.expertReviewFee! > 0)
                        _buildInfoRow('Expert Review Fee',
                            'EGP ${data.expertReviewFee!.toStringAsFixed(2)}'),
                      if (data.lateFee != null && data.lateFee! > 0)
                        _buildInfoRow('Late Fee',
                            'EGP ${data.lateFee!.toStringAsFixed(2)}'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Parties Card (Renter & Owner)
                  _buildInfoCard(
                    icon: Icons.groups_outlined,
                    title: 'Parties',
                    children: [
                      if (data.ownerFirstName != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Owner'.tr, style: TextStyle(fontSize: 14, color: AppColor.mediumText)),
                              Text(data.ownerFirstName!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColor.darkText)),
                            ],
                          ),
                        ),
                      if (data.renterFirstName != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Renter'.tr, style: TextStyle(fontSize: 14, color: AppColor.mediumText)),
                              Text(data.renterFirstName!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColor.darkText)),
                            ],
                          ),
                        ),
                      if (data.notes != null && data.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Notes'.tr, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColor.mediumText)),
                        const SizedBox(height: 4),
                        Text(data.notes!, style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey[700])),
                      ],
                      const SizedBox(height: 12),
                      // Chat with Other Party button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isChatting ? null : _startChat,
                          icon: _isChatting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.chat_bubble_outline, size: 18),
                          label: Text(
                            _isChatting ? 'Opening Chat...'.tr : 'Chat Now'.tr,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.fourthColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Transfer History ──
                  if (data.transfers.isNotEmpty &&
                      !['pending', 'confirmed'].contains(status.toLowerCase()))
                    _buildTransferHistoryCard(data),

                  // ── Item Possession ──
                  _buildPossessionCard(data),

                  // ── Expert Review Status Card ──
                  _buildExpertReviewCard(data),

                  // ── Expert Handoff Delivery Selector ──
                  _buildExpertHandoffSelector(data),

                  // ── Active Transfer / Verification Code ──
                  _buildActiveTransferCard(data, isOwner, isRenter, currentUserRole),

                  // ── Condition Photos ──
                  _buildConditionPhotosSection(status, data),

                  // Action Buttons
                  _buildActionButtons(status, data),

                  // Dispute button
                  if (['active', 'completed', 'overdue', 'disputed', 'confirmed', 'returned']
                      .contains(status.toLowerCase()))
                    _buildDisputeButton(),

                  // Review Section (for completed rentals, renter only, no existing review)
                  if (status.toLowerCase() == 'completed' && isRenter && !isOwner && !_reviewSubmitted && !_hasReview)
                    _buildReviewSection(),

                  const SizedBox(height: 20),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColor.primaryColor),
              const SizedBox(width: 8),
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
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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

  Widget _buildActionButtons(String status, ApiResponseOfRentalDetailDtoData data) {
    final List<Widget> buttons = [];
    final currentUserId = cachedUserId; // SECURITY: in-memory cache from Keystore/Keychain
    final bool isOwner = data.ownerId?.toString() == currentUserId;
    final bool isRenter = data.renterId?.toString() == currentUserId;

    if (isOwner) {
      if (status.toLowerCase() == 'pending') {
        if (data.ownerWantsExpertReview != true) {
          buttons.add(
            CheckboxListTile(
              value: _ownerWantsExpertAtConfirm,
              title: Text('Request Expert Review'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: Text('100 EGP fee'.tr, style: const TextStyle(fontSize: 11)),
              activeColor: AppColor.primaryColor,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                setState(() {
                  _ownerWantsExpertAtConfirm = val ?? false;
                });
              },
            ),
          );
        }
        buttons.addAll([
          _buildActionButton('Confirm Rental', Icons.check_circle_outline,
              AppColor.successColor, _confirmRental, loadingKey: 'confirm_rental'),
          const SizedBox(height: 10),
        ]);
      } else if (status.toLowerCase() == 'confirmed') {
        final bool isExpertRequired = data.ownerWantsExpertReview == true || data.renterWantsExpertReview == true;
        buttons.addAll([
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              isExpertRequired
                  ? 'Select delivery method to the expert:'.tr
                  : 'Select delivery method to the renter:'.tr,
              style: TextStyle(fontSize: 13, color: AppColor.mediumText),
            ),
          ),
          RadioListTile<String>(
            value: 'ByHand',
            groupValue: _handoffDeliveryMethod,
            title: Text('By Hand'.tr, style: const TextStyle(fontSize: 14)),
            onChanged: (val) {
              setState(() {
                _handoffDeliveryMethod = val ?? 'ByHand';
              });
            },
          ),
          RadioListTile<String>(
            value: 'DeliveryService',
            groupValue: _handoffDeliveryMethod,
            title: Text('Delivery Service'.tr, style: const TextStyle(fontSize: 14)),
            onChanged: (val) {
              setState(() {
                _handoffDeliveryMethod = val ?? 'ByHand';
              });
            },
          ),
          const SizedBox(height: 10),
          _buildActionButton('Set Delivery Method', Icons.local_shipping,
              AppColor.primaryColor, _setHandoffMethod, loadingKey: 'set_handoff'),
          const SizedBox(height: 10),
        ]);
      } else if (status.toLowerCase() == 'returned') {
        final bool hasExpertReturn = data.transfers.any(
          (t) => t.phase?.toLowerCase() == 'return' && t.fromActorType?.toLowerCase() == 'expert'
        );
        if (data.currentPossession?.toLowerCase() == 'expert' && !hasExpertReturn) {
          buttons.addAll([
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Select delivery method from expert back to you:'.tr,
                style: TextStyle(fontSize: 13, color: AppColor.mediumText),
              ),
            ),
            RadioListTile<String>(
              value: 'ByHand',
              groupValue: _returnDeliveryMethod,
              title: Text('By Hand'.tr, style: const TextStyle(fontSize: 14)),
              onChanged: (val) {
                setState(() {
                  _returnDeliveryMethod = val ?? 'ByHand';
                });
              },
            ),
            RadioListTile<String>(
              value: 'DeliveryService',
              groupValue: _returnDeliveryMethod,
              title: Text('Delivery Service'.tr, style: const TextStyle(fontSize: 14)),
              onChanged: (val) {
                setState(() {
                  _returnDeliveryMethod = val ?? 'ByHand';
                });
              },
            ),
            const SizedBox(height: 10),
            _buildActionButton('Confirm Return from Expert', Icons.check_circle_outline,
                AppColor.primaryColor, _confirmExpertToOwnerReturn, loadingKey: 'expert_return'),
            const SizedBox(height: 10),
          ]);
        }
      }
      
      // Cancel option for owner
      if (!['active', 'completed', 'cancelled', 'rejected', 'overdue', 'returned'].contains(status.toLowerCase())) {
        buttons.add(
          _buildActionButton('Cancel Rental', Icons.cancel_outlined,
              AppColor.warningColor, _cancelRental, loadingKey: 'cancel_rental'),
        );
      }
    }

    if (isRenter) {
      if (!['active', 'completed', 'cancelled', 'rejected', 'overdue', 'returned'].contains(status.toLowerCase())) {
        buttons.add(
          _buildActionButton('Cancel Rental', Icons.cancel_outlined,
              AppColor.warningColor, _cancelRental, loadingKey: 'cancel_rental'),
        );
      }
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Actions',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.darkText)),
        const SizedBox(height: 12),
        ...buttons,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed, {String? loadingKey}) {
    final bool isButtonLoading = loadingKey != null ? _isLoadingState(loadingKey) : false;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isButtonLoading ? null : onPressed,
        icon: isButtonLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Icon(icon, size: 20),
        label: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
        return const Color(0xFFd97706);
      case 'confirmed':
        return const Color(0xFF2563eb);
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

  Widget _buildActiveTransferCard(ApiResponseOfRentalDetailDtoData data, bool isOwner, bool isRenter, String currentUserRole) {
    final activeTransfer = data.transfers.firstWhereOrNull(
      (t) => t.sequence == data.currentTransferSequence && t.status != 'Verified'
    );

    if (activeTransfer == null) {
      if (_isHandoffVerified || data.status?.toLowerCase() == 'active') {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.successColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColor.successColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Handoff Verified'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColor.successColor,
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    if (activeTransfer.fromActorType == 'Expert' &&
        activeTransfer.toActorType == 'Renter' &&
        data.deliveryMethodFromExpert == null) {
      return const SizedBox.shrink();
    }

    final bool showSenderView = activeTransfer.fromActorType == currentUserRole || activeTransfer.fromActorType == 'Expert';
    final bool showReceiverView = activeTransfer.toActorType == currentUserRole;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.vpn_key_rounded, size: 20, color: AppColor.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Transfer Verification'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (showSenderView) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2563eb).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2563eb).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.key_rounded, size: 32, color: Color(0xFF2563eb)),
                  const SizedBox(height: 8),
                  Text(
                    activeTransfer.fromActorType == 'Expert'
                        ? 'Verification Code from Expert'.tr
                        : 'Verification Code'.tr,
                    style: TextStyle(fontSize: 13, color: AppColor.mediumText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activeTransfer.verificationCode ?? '',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                      color: Color(0xFF2563eb),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activeTransfer.fromActorType == 'Expert'
                        ? 'Give this code to the expert hub'.tr
                        : 'Give this code to the recipient'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColor.lightText),
                  ),
                ],
              ),
            ),
          ],
          if (showReceiverView) ...[
            Builder(
              builder: (context) {
                final bool isHandoverTransfer = activeTransfer.phase?.toLowerCase() == 'handover' || 
                    activeTransfer.phase?.toLowerCase() == 'handoff' ||
                    ['confirmed', 'awaitingpickup'].contains(data.status?.toLowerCase() ?? '');
                final bool disableInput = isRenter && isHandoverTransfer && data.handoverImages.isEmpty;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
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
                          const SizedBox(width: 8),
                          Text(
                            'Enter Transfer Code'.tr,
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColor.darkText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _handoffCodeController,
                                  enabled: !disableInput,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 4,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: disableInput ? 'Upload photos first'.tr : 'EX: 123456',
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0,
                                      color: AppColor.lightText,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                  ),
                                ),
                                if (disableInput) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Please upload handover photos first before entering the verification code.'.tr,
                                    style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: (_isLoadingState('verify_transfer') || disableInput)
                                ? null
                                : () async {
                                    final code = _handoffCodeController.text.trim();
                                    if (code.isEmpty) return;

                                    _setLoadingState('verify_transfer', true);
                                    try {
                                      await ApiService.rentals.verifyTransfer(widget.rentalId, code);
                                      _handoffCodeController.clear();
                                      AppNavigator.showSnackBar('Success'.tr, 'Transfer code verified!'.tr,
                                          backgroundColor: AppColor.successColor.withOpacity(0.9),
                                          colorText: Colors.white);
                                      await _loadRentalDetail();
                                    } catch (e) {
                                      AppNavigator.showSnackBar('Error'.tr, 'Invalid transfer code'.tr,
                                          backgroundColor: AppColor.warningColor.withOpacity(0.9),
                                          colorText: Colors.white);
                                    } finally {
                                      _setLoadingState('verify_transfer', false);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: _isLoadingState('verify_transfer')
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text('Verify'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  List<VerificationDto?> _getRelevantVerifications(ApiResponseOfRentalDetailDtoData data) {
    if (data.verifications.isEmpty) {
      if (data.renterWantsExpertReview == true || data.ownerWantsExpertReview == true) {
        return [null];
      }
      return [];
    }

    final beforeRent = data.verifications.firstWhereOrNull(
      (v) => v.checkType?.toLowerCase() == 'beforerent' || v.checkType?.toLowerCase() == 'before_rent'
    );
    final afterReturn = data.verifications.firstWhereOrNull(
      (v) => v.checkType?.toLowerCase() == 'afterreturn' || v.checkType?.toLowerCase() == 'after_return'
    );

    final results = <VerificationDto?>[];
    if (beforeRent != null) {
      results.add(beforeRent);
    } else if (beforeRent == null && afterReturn == null) {
      results.add(null);
    }

    final status = data.status?.toLowerCase() ?? '';
    final showAfterReturn = ['active', 'completed', 'overdue', 'disputed'].contains(status);

    if (showAfterReturn && afterReturn != null) {
      results.add(afterReturn);
    }

    return results;
  }

  Widget _buildExpertReviewCard(ApiResponseOfRentalDetailDtoData data) {
    if (data.renterWantsExpertReview != true && data.ownerWantsExpertReview != true) {
      return const SizedBox.shrink();
    }

    final verifications = _getRelevantVerifications(data);
    if (verifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: verifications.map((verif) {
        final String title = (verif?.checkType?.toLowerCase() == 'afterreturn' ||
                               verif?.checkType?.toLowerCase() == 'after_return')
            ? 'Expert Review After Return'.tr
            : 'Expert Review Before Rent'.tr;

        IconData statusIcon = Icons.hourglass_empty;
        Color statusColor = Colors.orange;
        String statusText = 'Pending Assignment'.tr;

        if (verif != null) {
          if (verif.status == 'Approved') {
            statusIcon = Icons.check_circle;
            statusColor = AppColor.successColor;
            statusText = 'Approved'.tr;
          } else if (verif.status == 'Rejected') {
            statusIcon = Icons.cancel;
            statusColor = Colors.red;
            statusText = 'Rejected'.tr;
          } else if (data.assignedExpertId != null) {
            statusIcon = Icons.hourglass_bottom;
            statusColor = Colors.blue;
            statusText = 'Expert Assigned'.tr;
          }
        } else if (data.assignedExpertId != null) {
          statusIcon = Icons.hourglass_bottom;
          statusColor = Colors.blue;
          statusText = 'Expert Assigned'.tr;
        }

        final expertName = verif?.expertFirstName ?? data.assignedExpertName ?? 'Not Assigned'.tr;

        final currentUserId = cachedUserId; // SECURITY: in-memory cache from Keystore/Keychain
        final bool isOwner = data.ownerId?.toString() == currentUserId;
        final bool isRenter = data.renterId?.toString() == currentUserId;

        final bool canCancel = verif?.status == null &&
            ((isOwner && data.ownerWantsExpertReview == true) ||
             (isRenter && data.renterWantsExpertReview == true));

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColor.cardShadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user_outlined, size: 20, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Expert: $expertName',
                          style: TextStyle(fontSize: 12, color: AppColor.mediumText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (verif?.notes != null && verif!.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    '"${verif.notes}"',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
              if (canCancel) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingState('cancel_expert')
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Cancel Expert Review'.tr),
                                content: Text('Are you sure you want to cancel the expert review request?'.tr),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('No'.tr)),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Yes'.tr)),
                                ],
                              ),
                            );
                            if (confirm != true) return;

                            _setLoadingState('cancel_expert', true);
                            try {
                              await ApiService.rentals.cancelExpertReview(widget.rentalId);
                              AppNavigator.showSnackBar('Success'.tr, 'Expert review cancelled'.tr,
                                  backgroundColor: AppColor.successColor.withOpacity(0.9), colorText: Colors.white);
                              await _loadRentalDetail();
                            } catch (e) {
                              AppNavigator.showSnackBar('Error'.tr, 'Failed to cancel expert review'.tr,
                                  backgroundColor: AppColor.warningColor.withOpacity(0.9), colorText: Colors.white);
                            } finally {
                              _setLoadingState('cancel_expert', false);
                            }
                          },
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: Text('Cancel Expert Review'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpertHandoffSelector(ApiResponseOfRentalDetailDtoData data) {
    final currentUserId = cachedUserId; // SECURITY: in-memory cache from Keystore/Keychain
    final bool isRenter = data.renterId?.toString() == currentUserId;
    if (!isRenter) return const SizedBox.shrink();

    final hasBeforeRentApproval = data.verifications.any(
      (v) => (v.checkType?.toLowerCase() == 'beforerent' || v.checkType?.toLowerCase() == 'before_rent') && v.status == 'Approved'
    );

    final bool needsMethodSelection = data.currentPossession?.toLowerCase() == 'expert' &&
        hasBeforeRentApproval &&
        data.deliveryMethodFromExpert == null;

    if (!needsMethodSelection) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Receive from Expert Hub'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Before rent inspection approved! Choose how you would like to receive the item from the expert hub:'.tr,
            style: TextStyle(fontSize: 13, color: AppColor.mediumText),
          ),
          const SizedBox(height: 12),
          RadioListTile<String>(
            value: 'ByHand',
            groupValue: _selectedDeliveryMethodFromExpert,
            title: Text('Pickup in Person'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text('Go to the expert hub location to pick up'.tr, style: const TextStyle(fontSize: 12)),
            onChanged: (val) {
              setState(() {
                _selectedDeliveryMethodFromExpert = val ?? 'ByHand';
              });
            },
          ),
          RadioListTile<String>(
            value: 'DeliveryService',
            groupValue: _selectedDeliveryMethodFromExpert,
            title: Text('Use Delivery Service'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text('Deliver the item to your address'.tr, style: const TextStyle(fontSize: 12)),
            onChanged: (val) {
              setState(() {
                _selectedDeliveryMethodFromExpert = val ?? 'ByHand';
              });
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoadingState('hub_deliver')
                  ? null
                  : () async {
                      _setLoadingState('hub_deliver', true);
                      try {
                        await ApiService.rentals.generateHandoffFromHubTransfers(
                          widget.rentalId,
                          method: _selectedDeliveryMethodFromExpert,
                        );
                        AppNavigator.showSnackBar('Success'.tr, 'Delivery method confirmed!'.tr,
                            backgroundColor: AppColor.successColor.withOpacity(0.9), colorText: Colors.white);
                        await _loadRentalDetail();
                      } catch (e) {
                        AppNavigator.showSnackBar('Error'.tr, 'Failed to confirm selection'.tr,
                            backgroundColor: AppColor.warningColor.withOpacity(0.9), colorText: Colors.white);
                      } finally {
                        _setLoadingState('hub_deliver', false);
                      }
                    },
              icon: const Icon(Icons.local_shipping, color: Colors.white),
              label: Text('Confirm Selection'.tr, style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmExpertToOwnerReturn() async {
    _setLoadingState('expert_return', true);
    try {
      await ApiService.rentals.generateExpertToOwnerTransfers(
        widget.rentalId,
        method: _returnDeliveryMethod,
      );
      AppNavigator.showSnackBar('Success'.tr, 'Expert return transfer generated!'.tr,
          backgroundColor: AppColor.successColor.withOpacity(0.9), colorText: Colors.white);
      await _loadRentalDetail();
    } catch (e) {
      AppNavigator.showSnackBar('Error'.tr, 'Failed to confirm return from expert'.tr,
          backgroundColor: AppColor.warningColor.withOpacity(0.9), colorText: Colors.white);
    } finally {
      _setLoadingState('expert_return', false);
    }
  }

  Widget _buildPossessionCard(ApiResponseOfRentalDetailDtoData data) {
    final status = data.status?.toLowerCase();
    if (status != 'active' && status != 'overdue') return const SizedBox.shrink();

    final cp = data.currentPossession?.toString() ?? 'none';
    String holderName = 'Renter';
    IconData holderIcon = Icons.person_pin_circle_rounded;
    Color holderColor = AppColor.fourthColor;

    if (cp.toLowerCase() == 'owner') {
      holderName = 'Owner';
      holderIcon = Icons.home_work_rounded;
      holderColor = AppColor.primaryColor;
    } else if (cp.toLowerCase() == 'expert') {
      holderName = 'Expert Hub';
      holderIcon = Icons.admin_panel_settings_rounded;
      holderColor = Colors.teal;
    } else if (cp.toLowerCase() == 'intransit') {
      holderName = 'In Transit';
      holderIcon = Icons.local_shipping_rounded;
      holderColor = Colors.orange;
    }

    final currentUserId = cachedUserId; // SECURITY: in-memory cache from Keystore/Keychain
    final bool isRenterUser = data.renterId?.toString() == currentUserId;
    final bool isOwnerUser = _ownerId?.toString() == currentUserId;

    // Check if return transfer in progress
    final bool returnInProgress = data.transfers.any((t) => t.phase?.toLowerCase() == 'return');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildInfoCard(
        icon: Icons.share_location_rounded,
        title: 'Item Possession',
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: holderColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: holderColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(holderIcon, color: holderColor, size: 30),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Holder'.tr, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 2),
                      Text(
                        holderName.tr,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: holderColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isRenterUser && cp.toLowerCase() == 'renter' && !returnInProgress) ...[
            const SizedBox(height: 16),
            if (_showReturnOptions) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Return Method:'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    RadioListTile<String>(
                      value: 'ByHand',
                      groupValue: _returnDeliveryMethod,
                      title: Text('By Hand'.tr, style: const TextStyle(fontSize: 14)),
                      onChanged: (val) {
                        setState(() {
                          _returnDeliveryMethod = val ?? 'ByHand';
                        });
                      },
                    ),
                    RadioListTile<String>(
                      value: 'DeliveryService',
                      groupValue: _returnDeliveryMethod,
                      title: Text('Delivery Service'.tr, style: const TextStyle(fontSize: 14)),
                      onChanged: (val) {
                        setState(() {
                          _returnDeliveryMethod = val ?? 'ByHand';
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _showReturnOptions = false;
                              });
                            },
                            child: Text('Cancel'.tr),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor),
                            onPressed: () => _initiateReturn(_returnDeliveryMethod),
                            child: Text('Confirm'.tr, style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showReturnOptions = true;
                    });
                  },
                  icon: const Icon(Icons.assignment_turned_in_outlined, color: Colors.white),
                  label: Text('Initiate Return'.tr, style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.fourthColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
          // ── RENTER: InTransit — receiving item from owner/delivery (handover phase) ──
          if (isRenterUser && cp.toLowerCase() == 'intransit' && !returnInProgress) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_rounded, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your item is on its way. Confirm once you receive it.'.tr,
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoadingState('confirm_receipt') ? null : _confirmReceipt,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text('Confirm Receipt'.tr, style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.successColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
          // ── RENTER: InTransit — returning item back to owner ──
          if (isRenterUser && cp.toLowerCase() == 'intransit' && returnInProgress) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Item is in transit back to the owner.'.tr,
                      style: const TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // ── OWNER: Active/Overdue info banner ──
          if (isOwnerUser && (status == 'active' || status == 'overdue')) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: AppColor.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cp.toLowerCase() == 'renter'
                          ? (status == 'overdue'
                              ? 'Item is still with the renter. Rental is overdue.'.tr
                              : 'Item is with the renter.'.tr)
                          : cp.toLowerCase() == 'expert'
                              ? 'Item is currently at the expert hub.'.tr
                              : cp.toLowerCase() == 'owner'
                                  ? 'You have the item back.'.tr
                                  : 'Item is in transit.'.tr,
                      style: const TextStyle(fontSize: 12, color: AppColor.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // ── OWNER: InTransit — confirm receipt ──
          if (isOwnerUser && cp.toLowerCase() == 'intransit') ...[
            const SizedBox(height: 16),
            Text(
              'The renter has initiated the return. Please confirm when you have received the item back.'.tr,
              style: const TextStyle(fontSize: 13, color: AppColor.mediumText),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoadingState('confirm_receipt') ? null : _confirmReceipt,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text('Confirm Receipt'.tr, style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.successColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
          // ── OWNER: possession back, complete the rental ──
          if (isOwnerUser && cp.toLowerCase() == 'owner' && (status == 'active' || status == 'overdue')) ...[
            const SizedBox(height: 16),
            _buildCompleteSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildConditionPhotosSection(String status, ApiResponseOfRentalDetailDtoData data) {
    final currentUserId = cachedUserId; // SECURITY: in-memory cache from Keystore/Keychain
    final bool isOwner = data.ownerId?.toString() == currentUserId;
    final bool isRenter = data.renterId?.toString() == currentUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildInfoCard(
        icon: Icons.photo_library_outlined,
        title: 'Condition Photos',
        children: [
          _buildPhotoSubsection(
            title: 'Handover Photos',
            photoUrls: data.handoverImages.map((img) => img.url ?? '').where((u) => u.isNotEmpty).toList(),
            images: data.handoverImages,
            canUpload: isRenter && ['confirmed', 'awaitingpickup', 'intransit'].contains(status.toLowerCase()),
            uploadLabel: 'Upload handover photos',
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 16),
          _buildPhotoSubsection(
            title: 'Return Photos',
            photoUrls: data.returnImages.map((img) => img.url ?? '').where((u) => u.isNotEmpty).toList(),
            images: data.returnImages,
            canUpload: isOwner && ['active', 'overdue', 'returned'].contains(status.toLowerCase()),
            uploadLabel: 'Upload return photos',
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSubsection({
    required String title,
    required List<String> photoUrls,
    required List<RentalImageDto> images,
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
              _isLoadingState(title == 'Handover Photos' ? 'upload_handover' : 'upload_return')
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColor.primaryColor),
                      ),
                    )
                  : TextButton.icon(
                      onPressed: () => _pickAndUploadPhoto(title == 'Handover Photos' ? 'Handover' : 'Return'),
                      icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                      label: Text('Upload'.tr, style: const TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColor.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
          ],
        ),
        const SizedBox(height: 8),
        if (photoUrls.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: images.map((img) {
              final url = img.url ?? '';
              if (url.isEmpty) return const SizedBox.shrink();
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GestureDetector(
                      onTap: () => _showImageLightbox(url),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  if (img.canDelete == true)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _deletePhoto(url),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }).toList(),
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
                const SizedBox(height: 4),
                Text('No photos yet'.tr,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
          ),
      ],
    );
  }

  void _showImageLightbox(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(color: Colors.white54),
                    ),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(ctx).padding.top + 12,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deletePhoto(String url) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Photo'.tr),
        content: Text('Are you sure you want to delete this photo?'.tr),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.tr)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete'.tr, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    _setLoadingState('delete_photo', true);
    try {
      await ApiService.rentals.deleteRentalPhoto(widget.rentalId, url);
      AppNavigator.showSnackBar('Success'.tr, 'Photo deleted successfully!'.tr,
          backgroundColor: AppColor.successColor.withOpacity(0.9), colorText: Colors.white);
      await _loadRentalDetail();
    } catch (e) {
      AppNavigator.showSnackBar('Error'.tr, 'Failed to delete photo'.tr,
          backgroundColor: AppColor.warningColor.withOpacity(0.9), colorText: Colors.white);
    } finally {
      _setLoadingState('delete_photo', false);
    }
  }

  Widget _buildDisputeButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: _showDisputeSheet,
          icon: const Icon(Icons.gavel_rounded, size: 20),
          label: Text('Open Dispute'.tr,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.deepOrange,
            side: const BorderSide(color: Colors.deepOrange, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  final ValueNotifier<List<String>> _disputePhotos = ValueNotifier([]);

  void _showDisputeSheet() {
    String? selectedReason;
    final descController = TextEditingController();
    _disputePhotos.value = []; // reset on each open

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          void onPhotosChanged() => setSheetState(() {});
          _disputePhotos.addListener(onPhotosChanged);

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.85,
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.gavel_rounded, color: Colors.deepOrange, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Open Dispute'.tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.darkText,
                                )),
                            Text('Report an issue with this rental'.tr,
                                style: TextStyle(fontSize: 13, color: AppColor.mediumText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20, height: 20,
                          child: Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Disputes are reviewed by our team. Please provide accurate details.'.tr,
                            style: TextStyle(fontSize: 12, color: Colors.amber[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Reason *'.tr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      hintText: 'Select a reason'.tr,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Broken', child: Text('Item Damaged / Broken')),
                      DropdownMenuItem(value: 'NotAsDescribed', child: Text('Item Not as Described')),
                      DropdownMenuItem(value: 'LateReturn', child: Text('Late Return')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (v) => setSheetState(() => selectedReason = v),
                  ),
                  const SizedBox(height: 16),
                  Text('Description * (min 10 characters)'.tr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descController,
                    maxLines: 4,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      hintText: 'Describe the issue in detail...'.tr,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.add_a_photo, size: 18, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      Text('Evidence Photos *'.tr,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('At least 1 photo required to support your dispute'.tr,
                      style: TextStyle(fontSize: 12, color: AppColor.mediumText)),
                  const SizedBox(height: 10),
                  ValueListenableBuilder<List<String>>(
                    valueListenable: _disputePhotos,
                    builder: (_, photos, __) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (photos.isNotEmpty)
                          SizedBox(
                            height: 90,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: photos.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (_, i) => Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: photos[i],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        width: 80, height: 80,
                                        color: Colors.grey[200],
                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        width: 80, height: 80,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 2, right: 2,
                                    child: GestureDetector(
                                      onTap: () {
                                        final updated = List<String>.from(photos)..removeAt(i);
                                        _disputePhotos.value = updated;
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        _isLoadingState('dispute_upload')
                            ? const Center(child: CircularProgressIndicator())
                            : OutlinedButton.icon(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 1200,
                                    imageQuality: 80,
                                  );
                                  if (picked == null) return;

                                  _setLoadingState('dispute_upload', true);
                                  try {
                                    final ext = picked.path.split('.').last.toLowerCase();
                                    final mime = const {
                                      'jpg': 'jpeg', 'jpeg': 'jpeg',
                                      'png': 'png', 'gif': 'gif',
                                      'webp': 'webp', 'heic': 'heic',
                                    }[ext] ?? 'jpeg';

                                    final multipartFile = await http.MultipartFile.fromPath(
                                      'file', picked.path,
                                      filename: picked.name,
                                      contentType: MediaType('image', mime),
                                    );
                                    final res = await ApiService.media.uploadMedia(
                                      entityId: widget.rentalId,
                                      entityType: 'Rental',
                                      file: multipartFile,
                                    );
                                    final url = res?.data?.url;
                                    if (url != null) {
                                      _disputePhotos.value = [..._disputePhotos.value, url];
                                    } else {
                                      AppNavigator.showSnackBar('Error'.tr, 'Failed to upload photo'.tr,
                                          backgroundColor: Colors.red.withOpacity(0.9),
                                          colorText: Colors.white);
                                    }
                                  } catch (_) {
                                    AppNavigator.showSnackBar('Error'.tr, 'Photo upload failed'.tr,
                                        backgroundColor: Colors.red.withOpacity(0.9),
                                        colorText: Colors.white);
                                  } finally {
                                    _setLoadingState('dispute_upload', false);
                                  }
                                },
                                icon: const Icon(Icons.upload, size: 18),
                                label: Text('Add Photo'.tr),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blueGrey,
                                ),
                              ),
                        if (photos.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('* At least 1 photo is required'.tr,
                                style: const TextStyle(color: Colors.deepOrange, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Cancel'.tr),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ValueListenableBuilder<List<String>>(
                          valueListenable: _disputePhotos,
                          builder: (_, photos, __) => ElevatedButton.icon(
                            onPressed: (selectedReason == null ||
                                    _isDisputeSubmitting ||
                                    photos.isEmpty ||
                                    descController.text.trim().length < 10)
                                ? null
                                : () async {
                                    setSheetState(() => _isDisputeSubmitting = true);
                                    try {
                                      final body = OpenDisputeBody(
                                        reasonType: selectedReason,
                                        description: descController.text.trim(),
                                        mediaUrls: List<String>.from(photos),
                                      );
                                      await ApiService.rentals.openRentalDispute(widget.rentalId, body);
                                      if (!context.mounted) return;
                                      Navigator.pop(ctx);
                                      _disputePhotos.value = [];
                                      AppNavigator.showSnackBar(
                                        'Dispute Submitted'.tr,
                                        'Your dispute has been submitted and is under review.'.tr,
                                        backgroundColor: Colors.deepOrange.withOpacity(0.9),
                                        colorText: Colors.white,
                                      );
                                      await _loadRentalDetail();
                                    } catch (e) {
                                      setSheetState(() => _isDisputeSubmitting = false);
                                      AppNavigator.showSnackBar(
                                        'Error'.tr,
                                        'Failed to submit dispute. Please try again.'.tr,
                                        backgroundColor: Colors.red.withOpacity(0.9),
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                            icon: _isDisputeSubmitting
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.gavel_rounded, size: 18),
                            label: Text(
                              _isDisputeSubmitting ? 'Submitting...'.tr : 'Submit Dispute'.tr,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
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
      },
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
            title: Text('Item is damaged'.tr,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text('Check if the item was returned with damage'.tr,
                style: const TextStyle(fontSize: 12)),
            activeColor: Colors.red,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 8),
        _buildActionButton('Complete Rental', Icons.assignment_turned_in,
            AppColor.successColor, _completeRental, loadingKey: 'complete_rental'),
      ],
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1A1A).withOpacity(0.08),
                const Color(0xFF1A1A1A).withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1A1A1A).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.rate_review_outlined, size: 36, color: Color(0xFF1A1A1A)),
              const SizedBox(height: 8),
              Text('How was your experience?'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.darkText)),
              const SizedBox(height: 4),
              Text('Share your feedback to help the community'.tr,
                  style: TextStyle(fontSize: 13, color: AppColor.mediumText)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _showReviewDialog,
                  icon: const Icon(Icons.star_rounded, size: 20),
                  label: Text('Write a Review'.tr,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
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
    int selectedRating = 5;
    final commentController = TextEditingController();
    bool isSubmittingReview = false;

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
            decoration: const BoxDecoration(
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
                const SizedBox(height: 20),
                Text('Rate Your Rental'.tr,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.darkText)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedRating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 40,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  _getRatingLabel(selectedRating).tr,
                  style: TextStyle(fontSize: 14, color: AppColor.mediumText, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Share your experience (optional)'.tr,
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSubmittingReview
                        ? null
                        : () async {
                            setModalState(() => isSubmittingReview = true);
                            try {
                              await ApiService.reviews.createReview(
                                widget.rentalId,
                                CreateReviewCommand(
                                  rentalId: widget.rentalId,
                                  rating: selectedRating,
                                  comment: commentController.text.trim().isEmpty
                                      ? null
                                      : commentController.text.trim(),
                                ),
                              );
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              AppNavigator.showSnackBar('Thank You!'.tr, 'Your review has been submitted'.tr,
                                  backgroundColor: AppColor.successColor.withOpacity(0.9),
                                  colorText: Colors.white);
                              setState(() => _reviewSubmitted = true);
                              await _loadRentalDetail();
                            } catch (e) {
                              AppNavigator.showSnackBar('Error'.tr, 'Failed to submit review'.tr,
                                  backgroundColor: AppColor.warningColor.withOpacity(0.9),
                                  colorText: Colors.white);
                            } finally {
                              setModalState(() => isSubmittingReview = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    child: isSubmittingReview
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Submit Review'.tr,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransferHistoryCard(ApiResponseOfRentalDetailDtoData data) {
    final transfers = data.transfers;
    if (transfers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildInfoCard(
        icon: Icons.swap_horiz_rounded,
        title: 'Transfer History',
        children: [
          ...transfers.map((t) {
            final isActive = t.sequence == data.currentTransferSequence &&
                (t.status?.toLowerCase() != 'verified' && t.status?.toLowerCase() != 'completed');
            final isCompleted = t.status?.toLowerCase() == 'verified' || t.status?.toLowerCase() == 'completed';

            final fromLabel = t.fromActorType?.toLowerCase() == 'owner'
                ? 'Owner'
                : t.fromActorType?.toLowerCase() == 'renter'
                    ? 'Renter'
                    : t.fromActorType?.toLowerCase() == 'expert'
                        ? 'Expert Hub'
                        : t.fromActorType?.toLowerCase() == 'deliveryagent'
                            ? 'Delivery'
                            : t.fromActorType ?? '?';
            final toLabel = t.toActorType?.toLowerCase() == 'owner'
                ? 'Owner'
                : t.toActorType?.toLowerCase() == 'renter'
                    ? 'Renter'
                    : t.toActorType?.toLowerCase() == 'expert'
                        ? 'Expert Hub'
                        : t.toActorType?.toLowerCase() == 'deliveryagent'
                            ? 'Delivery'
                            : t.toActorType ?? '?';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.check_circle
                          : isActive
                              ? Icons.pending_rounded
                              : Icons.radio_button_unchecked,
                      size: 18,
                      color: isCompleted
                          ? AppColor.successColor
                          : isActive
                              ? AppColor.primaryColor
                              : Colors.grey[400],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Text(fromLabel.tr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                color: AppColor.darkText,
                              )),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                          ),
                          Text(toLabel.tr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                color: AppColor.darkText,
                              )),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColor.successColor.withOpacity(0.1)
                            : isActive
                                ? AppColor.primaryColor.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isCompleted
                            ? 'Done'.tr
                            : isActive
                                ? 'Active'.tr
                                : 'Pending'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? AppColor.successColor
                              : isActive
                                  ? AppColor.primaryColor
                                  : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                if (t.completedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 28, top: 2, bottom: 8),
                    child: Text(
                      DateFormat('MMM dd, yyyy – hh:mm a').format(t.completedAt!),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  )
                else if (isActive)
                  Padding(
                    padding: const EdgeInsets.only(left: 28, top: 2, bottom: 8),
                    child: Text(
                      'Waiting for verification code'.tr,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 28, top: 2, bottom: 8),
                    child: Text(
                      'Pending'.tr,
                      style: TextStyle(fontSize: 11, color: Colors.grey[400], fontStyle: FontStyle.italic),
                    ),
                  ),
                if (transfers.last != t)
                  Divider(height: 1, color: Colors.grey[200]),
              ],
            );
          }),
        ],
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
