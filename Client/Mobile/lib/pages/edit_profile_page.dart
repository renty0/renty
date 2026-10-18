import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/services/secure_storage_service.dart';
import 'package:renty/main.dart';

const List<String> kEgyptianCities = [
  'Cairo',
  'Giza',
  'Alexandria',
  'Luxor',
  'Aswan',
  'Hurghada',
  'Sharm El Sheikh',
  'Port Said',
  'Suez',
  'Mansoura',
  'Tanta',
  'Asyut',
  'Zagazig',
  'Ismailia',
  'Fayoum',
  'Minya',
  'Beni Suef',
  'Sohag',
  'Qena',
  'Damietta',
  'Kafr El Sheikh',
  'Beheira',
  'Monufia',
  'Sharqia',
  'Qalyubia',
  'Gharbia',
  'Dakahlia',
  'North Sinai',
  'South Sinai',
  'Matruh',
  'New Valley',
  'Red Sea',
];

const List<String> kCountries = [
  'Egypt',
  'Saudi Arabia',
  'UAE',
  'Kuwait',
  'Qatar',
  'Other',
];

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  String? _selectedCountry;
  String? _selectedCity;

  String? _profileImageUrl;
  bool _isUploadingPhoto = false;

  // 'verified' | 'pending' | 'rejected' | null (not submitted)
  String? _idVerificationStatus;
  String? _idRejectionNotes; // Notes from backend when rejected
  String? _frontIdUrl;
  String? _backIdUrl;
  bool _isUploadingFrontId = false;
  bool _isUploadingBackId = false;
  bool _isSubmittingId = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  // ─── Single raw /auth/me call that reads ALL fields ───────────────────────

  Future<void> _loadProfile() async {
    try {
      final raw = await ApiService.auth.authMeWithHttpInfo();
      if (!mounted) return;

      if (raw.statusCode == 200 && raw.body.isNotEmpty) {
        final body = jsonDecode(raw.body) as Map<String, dynamic>?;
        final data = body?['data'] as Map<String, dynamic>?;
        if (data != null) {
          final city = data['city'] as String?;
          final country = data['country'] as String?;

          // idVerificationStatus: 'None' | 'Pending' | 'Approved' | 'Rejected'
          final rawStatus = data['idVerificationStatus']?.toString() ?? '';
          final status = rawStatus.toLowerCase();
          final isVerified = data['isVerified'] as bool? ?? false;

          String? verificationStatus;
          if (isVerified || status == 'approved') {
            verificationStatus = 'verified';
          } else if (status == 'pending') {
            verificationStatus = 'pending';
          } else if (status == 'rejected') {
            verificationStatus = 'rejected';
          }
          // 'none' or empty → leave null so upload form is shown

          setState(() {
            _firstNameCtrl.text = data['firstName'] as String? ?? '';
            _lastNameCtrl.text = data['lastName'] as String? ?? '';
            _emailCtrl.text = data['email'] as String? ?? '';
            _addressCtrl.text = data['address'] as String? ?? '';
            _bioCtrl.text = data['bio'] as String? ?? '';
            _profileImageUrl = data['profileImageUrl'] as String?;

            _selectedCountry = (country != null && kCountries.contains(country))
                ? country
                : kCountries.first;
            _selectedCity =
                (city != null &&
                    kEgyptianCities.any(
                      (c) => c.toLowerCase() == city.toLowerCase(),
                    ))
                ? kEgyptianCities.firstWhere(
                    (c) => c.toLowerCase() == city.toLowerCase(),
                  )
                : null;

            _idVerificationStatus = verificationStatus;
            _idRejectionNotes = data['idRejectionNotes'] as String?;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppNavigator.showSnackBar(
        'Error'.tr,
        'Failed to load profile'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        textColor: Colors.white,
        isError: true,
      );
    }
  }

  // ─── Save Profile ─────────────────────────────────────────────────────────

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final command = UpdateUserCommand(
        firstName: _firstNameCtrl.text.trim().isEmpty
            ? null
            : _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim().isEmpty
            ? null
            : _lastNameCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty
            ? null
            : _addressCtrl.text.trim(),
        city: _selectedCity,
        country: _selectedCountry,
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        profilePictureUrl: _profileImageUrl,
      );
      await ApiService.auth.authUpdateMe(command);
      if (_firstNameCtrl.text.trim().isNotEmpty) {
        // SECURITY: user PII stored in Keystore/Keychain
        await SecureStorageService.setUserFirstName(_firstNameCtrl.text.trim());
        await SecureStorageService.setUserName(_firstNameCtrl.text.trim());
      }
      if (_lastNameCtrl.text.trim().isNotEmpty) {
        await SecureStorageService.setUserLastName(_lastNameCtrl.text.trim());
      }
      if (!mounted) return;
      AppNavigator.showSnackBar(
        'Success'.tr,
        'Profile updated successfully'.tr,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        textColor: Colors.white,
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      AppNavigator.showSnackBar(
        'Error'.tr,
        'Failed to update: ${e.message ?? e.code}',
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        textColor: Colors.white,
        isError: true,
      );
    } catch (_) {
      AppNavigator.showSnackBar(
        'Error'.tr,
        'Failed to update profile'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        textColor: Colors.white,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── Photo Upload ──────────────────────────────────────────────────────────

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _isUploadingPhoto = true);
    try {
      final url = await _uploadImage(picked.path, picked.name);
      if (url != null && mounted) setState(() => _profileImageUrl = url);
    } catch (_) {
      AppNavigator.showSnackBar(
        'Error'.tr,
        'Failed to upload photo'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        textColor: Colors.white,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _pickIdImage({required bool isFront}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked == null) return;
    if (isFront)
      setState(() => _isUploadingFrontId = true);
    else
      setState(() => _isUploadingBackId = true);
    try {
      final url = await _uploadImage(picked.path, picked.name);
      if (url != null && mounted) {
        setState(() => isFront ? _frontIdUrl = url : _backIdUrl = url);
      }
    } catch (_) {
      AppNavigator.showSnackBar(
        'Error'.tr,
        'Failed to upload ID image'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        textColor: Colors.white,
        isError: true,
      );
    } finally {
      if (mounted) {
        if (isFront)
          setState(() => _isUploadingFrontId = false);
        else
          setState(() => _isUploadingBackId = false);
      }
    }
  }

  Future<String?> _uploadImage(String filePath, String filename) async {
    final ext = filename.split('.').last.toLowerCase();
    final mime =
        const {
          'jpg': 'jpeg',
          'jpeg': 'jpeg',
          'png': 'png',
          'gif': 'gif',
          'webp': 'webp',
          'bmp': 'bmp',
          'heic': 'heic',
        }[ext] ??
        'jpeg';
    final f = await http.MultipartFile.fromPath(
      'file',
      filePath,
      filename: filename,
      contentType: MediaType('image', mime),
    );
    final resp = await ApiService.media.uploadMedia(
      entityType: 'profile',
      file: f,
    );
    return resp?.data?.url;
  }

  // ─── Submit ID Verification (same endpoint as Web) ────────────────────────

  Future<void> _submitIdVerification() async {
    if (_frontIdUrl == null || _backIdUrl == null) {
      AppNavigator.showSnackBar(
        'Missing Images'.tr,
        'Please upload both front and back of your ID'.tr,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        textColor: Colors.white,
      );
      return;
    }
    setState(() => _isSubmittingId = true);
    try {
      await ApiService.identity.uploadIdVerification(
        UploadIdVerificationCommand(
          frontImageUrl: _frontIdUrl,
          backImageUrl: _backIdUrl,
        ),
      );

      // Re-fetch /auth/me from server to confirm the status (same as web)
      final raw = await ApiService.auth.authMeWithHttpInfo();
      if (raw.statusCode == 200 && raw.body.isNotEmpty) {
        final body = jsonDecode(raw.body) as Map<String, dynamic>?;
        final data = body?['data'] as Map<String, dynamic>?;
        final rawSt = data?['idVerificationStatus']?.toString() ?? '';
        final st = rawSt.toLowerCase();
        final isVerified = data?['isVerified'] as bool? ?? false;

        String? newStatus;
        if (isVerified || st == 'approved') {
          newStatus = 'verified';
        } else if (st == 'pending') {
          newStatus = 'pending';
        } else if (st == 'rejected') {
          newStatus = 'rejected';
        }

        if (mounted) {
          setState(() {
            _idVerificationStatus =
                newStatus ?? 'pending'; // optimistic fallback
            _frontIdUrl = null;
            _backIdUrl = null;
          });
        }
      } else {
        // Optimistic update if re-fetch fails
        if (mounted) {
          setState(() {
            _idVerificationStatus = 'pending';
            _frontIdUrl = null;
            _backIdUrl = null;
          });
        }
      }

      AppNavigator.showSnackBar(
        'Success'.tr,
        'ID submitted for verification'.tr,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        textColor: Colors.white,
      );
    } catch (_) {
      AppNavigator.showSnackBar(
        'Error'.tr,
        'Failed to submit ID verification'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        textColor: Colors.white,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmittingId = false);
    }
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FB);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Edit Profile'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Save'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColor.fourthColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile Photo ─────────────────────────────────────
                    _buildPhotoSection(isDark),
                    const SizedBox(height: 28),

                    // ── 1. Account Info ───────────────────────────────────
                    _buildSectionCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      icon: Icons.person_rounded,
                      iconColor: AppColor.fourthColor,
                      title: 'Account Info'.tr,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildField(
                                'First Name'.tr,
                                _firstNameCtrl,
                                isDark,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Required'.tr
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                'Last Name'.tr,
                                _lastNameCtrl,
                                isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          'Email Address'.tr,
                          _emailCtrl,
                          isDark,
                          icon: Icons.email_outlined,
                          readOnly: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── 2. Location & About ───────────────────────────────
                    _buildSectionCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      title: 'Location & About'.tr,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                label: 'Country'.tr,
                                value: _selectedCountry,
                                items: kCountries,
                                isDark: isDark,
                                onChanged: (v) =>
                                    setState(() => _selectedCountry = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdown(
                                label: 'City'.tr,
                                value: _selectedCity,
                                items: kEgyptianCities,
                                isDark: isDark,
                                onChanged: (v) =>
                                    setState(() => _selectedCity = v),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          'Address'.tr,
                          _addressCtrl,
                          isDark,
                          hint: 'Street, building, area...'.tr,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── 3. Bio ────────────────────────────────────────────
                    _buildSectionCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      icon: Icons.description_rounded,
                      iconColor: const Color(0xFF06B6D4),
                      title: 'Bio'.tr,
                      children: [
                        _buildField(
                          'Bio'.tr,
                          _bioCtrl,
                          isDark,
                          maxLines: 4,
                          hint: 'Tell others about yourself...'.tr,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── 4. Identity Verification ──────────────────────────
                    _buildIdentitySection(isDark, cardColor),
                    const SizedBox(height: 32),

                    // ── Save Button ───────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveProfile,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded, size: 20),
                        label: Text(
                          'Save Changes'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                          disabledBackgroundColor: AppColor.borderGray,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // ─── Profile Photo Widget ─────────────────────────────────────────────────

  Widget _buildPhotoSection(bool isDark) {
    final initials = _firstNameCtrl.text.isNotEmpty
        ? _firstNameCtrl.text[0].toUpperCase()
        : 'U';

    // Resolve full image URL
    String? resolvedUrl;
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      resolvedUrl = _profileImageUrl!.startsWith('http')
          ? _profileImageUrl!
          : 'https://starfish-app-vavqt.ondigitalocean.app${_profileImageUrl!.startsWith('/') ? '' : '/'}$_profileImageUrl!';
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: resolvedUrl == null
                    ? LinearGradient(
                        colors: [AppColor.fourthColor, AppColor.primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.fourthColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: _isUploadingPhoto
                    ? Container(
                        color: Colors.black38,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : resolvedUrl != null
                    ? CachedNetworkImage(
                        imageUrl: resolvedUrl,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        placeholder: (_, __) => Container(
                          color: AppColor.fourthColor,
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColor.fourthColor,
                                AppColor.primaryColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.fourthColor,
                              AppColor.primaryColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 0,
            child: GestureDetector(
              onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColor.fourthColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF121212) : Colors.white,
                    width: 2.5,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Identity Section Widget ──────────────────────────────────────────────

  Widget _buildIdentitySection(bool isDark, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                size: 20,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Identity Verification'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColor.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
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
          child: _idVerificationStatus == 'verified'
              ? _buildVerifiedBadge()
              : _idVerificationStatus == 'pending'
              ? _buildPendingBadge()
              : _idVerificationStatus == 'rejected'
              ? _buildRejectedBadge(isDark)
              : _buildIdUploadForm(isDark),
        ),
      ],
    );
  }

  Widget _buildVerifiedBadge() => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.successColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.verified_rounded,
          color: AppColor.successColor,
          size: 28,
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Identity Verified'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColor.successColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Your identity has been successfully verified.'.tr,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildPendingBadge() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: Color(0xFF3B82F6),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Verification Pending'.tr,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        'Your ID has been submitted and is currently under review.'.tr,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
    ],
  );

  Widget _buildRejectedBadge(bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.cancel_outlined,
              color: Colors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Verification Rejected'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      if (_idRejectionNotes != null && _idRejectionNotes!.isNotEmpty) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 14, color: Colors.red),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _idRejectionNotes!,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 14),
      Text(
        'You can re-submit your ID photos below.'.tr,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white70 : AppColor.mediumText,
        ),
      ),
      const SizedBox(height: 16),
      _buildIdPicker(
        isDark: isDark,
        label: 'Front of ID'.tr,
        imageUrl: _frontIdUrl,
        isUploading: _isUploadingFrontId,
        onTap: () => _pickIdImage(isFront: true),
      ),
      const SizedBox(height: 12),
      _buildIdPicker(
        isDark: isDark,
        label: 'Back of ID'.tr,
        imageUrl: _backIdUrl,
        isUploading: _isUploadingBackId,
        onTap: () => _pickIdImage(isFront: false),
      ),
      const SizedBox(height: 18),
      _buildSubmitButton(),
    ],
  );

  Widget _buildIdUploadForm(bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Upload your national ID to verify your identity.'.tr,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white70 : AppColor.mediumText,
        ),
      ),
      const SizedBox(height: 16),
      _buildIdPicker(
        isDark: isDark,
        label: 'Front of ID'.tr,
        imageUrl: _frontIdUrl,
        isUploading: _isUploadingFrontId,
        onTap: () => _pickIdImage(isFront: true),
      ),
      const SizedBox(height: 12),
      _buildIdPicker(
        isDark: isDark,
        label: 'Back of ID'.tr,
        imageUrl: _backIdUrl,
        isUploading: _isUploadingBackId,
        onTap: () => _pickIdImage(isFront: false),
      ),
      const SizedBox(height: 18),
      _buildSubmitButton(),
    ],
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    height: 46,
    child: ElevatedButton.icon(
      onPressed: (_frontIdUrl != null && _backIdUrl != null && !_isSubmittingId)
          ? _submitIdVerification
          : null,
      icon: _isSubmittingId
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.upload_rounded, size: 18),
      label: Text(
        'Submit for Verification'.tr,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColor.borderGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  Widget _buildIdPicker({
    required bool isDark,
    required String label,
    required String? imageUrl,
    required bool isUploading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: imageUrl != null
                ? AppColor.successColor.withValues(alpha: 0.6)
                : (isDark ? Colors.white24 : AppColor.borderGray),
            width: 1.5,
          ),
        ),
        child: isUploading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : (imageUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl.startsWith('http')
                                ? imageUrl
                                : 'https://starfish-app-vavqt.ondigitalocean.app${imageUrl.startsWith('/') ? '' : '/'}$imageUrl',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColor.successColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 32,
                          color: isDark ? Colors.white38 : AppColor.grey,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white54
                                : AppColor.mediumText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Tap to upload'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : AppColor.lightText,
                          ),
                        ),
                      ],
                    )),
      ),
    );
  }

  // ─── Section Card & Field helpers ────────────────────────────────────────

  Widget _buildSectionCard({
    required bool isDark,
    required Color cardColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColor.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    bool isDark, {
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    int maxLines = 1,
    String? hint,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      style: TextStyle(
        color: readOnly
            ? (isDark ? Colors.white54 : AppColor.mediumText)
            : (isDark ? Colors.white : AppColor.darkText),
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(
                icon,
                size: 20,
                color: readOnly ? AppColor.grey : AppColor.fourthColor,
              )
            : null,
        labelStyle: TextStyle(
          color: isDark ? Colors.white54 : AppColor.mediumText,
          fontSize: 13,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.white30 : AppColor.lightText,
          fontSize: 14,
        ),
        filled: true,
        fillColor: readOnly
            ? (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEEF0F4))
            : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.fourthColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required bool isDark,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white54 : AppColor.mediumText,
          fontSize: 13,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.fourthColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      style: TextStyle(
        color: isDark ? Colors.white : AppColor.darkText,
        fontSize: 14,
      ),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
