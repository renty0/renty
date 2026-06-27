import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/services/ProfileService.dart';
import 'package:renty/main.dart';

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
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  String? _profileImageUrl;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService().getUserProfile();
      if (!mounted) return;
      setState(() {
        _firstNameCtrl.text = profile?['firstName'] ?? '';
        _lastNameCtrl.text = profile?['lastName'] ?? '';
        _phoneCtrl.text = profile?['phoneNumber'] ?? '';
        _addressCtrl.text = profile?['address'] ?? '';
        _cityCtrl.text = profile?['city'] ?? '';
        _countryCtrl.text = profile?['country'] ?? '';
        _bioCtrl.text = profile?['bio'] ?? '';
        _profileImageUrl = profile?['profilePictureUrl'];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Get.snackbar('Error'.tr, 'Failed to load profile'.tr,
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final command = UpdateUserCommand(
        firstName: _firstNameCtrl.text.trim().isEmpty ? null : _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim().isEmpty ? null : _lastNameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        country: _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        profilePictureUrl: _profileImageUrl,
      );

      await ApiService.auth.authUpdateMe(command);

      // Update locally stored profile data
      if (_firstNameCtrl.text.trim().isNotEmpty) {
        await sharedPref.setString('user_firstName', _firstNameCtrl.text.trim());
        await sharedPref.setString('user_name', _firstNameCtrl.text.trim());
      }
      if (_lastNameCtrl.text.trim().isNotEmpty) {
        await sharedPref.setString('user_lastName', _lastNameCtrl.text.trim());
      }

      if (!mounted) return;
      Get.snackbar('Success'.tr, 'Profile updated successfully'.tr,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white);
      Navigator.pop(context, true); // Return true to trigger parent refresh
    } on ApiException catch (e) {
      Get.snackbar('Error'.tr, '${'Failed to update'.tr}: ${e.message ?? e.code}',
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to update profile'.tr,
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColor.backgroundcolor;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Edit Profile'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text('Save'.tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColor.fourthColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Photo
                    _buildPhotoSection(isDark, cardColor),
                    const SizedBox(height: 24),

                    // Personal Info section
                    _buildSectionHeader('Personal Information'.tr, Icons.person_outline, isDark),
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
                        children: [
                          _buildField('First Name'.tr, _firstNameCtrl, isDark,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'First name is required'.tr
                                  : null),
                          const SizedBox(height: 16),
                          _buildField('Last Name'.tr, _lastNameCtrl, isDark,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Last name is required'.tr
                                  : null),
                          const SizedBox(height: 16),
                          _buildField('Phone Number'.tr, _phoneCtrl, isDark,
                              keyboardType: TextInputType.phone,
                              icon: Icons.phone_outlined),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Location section
                    _buildSectionHeader('Location'.tr, Icons.location_on_outlined, isDark),
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
                        children: [
                          _buildField('Address'.tr, _addressCtrl, isDark,
                              icon: Icons.home_outlined),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildField('City'.tr, _cityCtrl, isDark)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _buildField(
                                      'Country'.tr, _countryCtrl, isDark)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bio section
                    _buildSectionHeader('About Me'.tr, Icons.info_outline, isDark),
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
                      child: _buildField('Bio'.tr, _bioCtrl, isDark,
                          maxLines: 4,
                          hint: 'Tell others about yourself...'.tr),
                    ),

                    const SizedBox(height: 32),

                    // Save button at bottom
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 3,
                          disabledBackgroundColor: AppColor.borderGray,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text('Save Changes'.tr,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
  Widget _buildPhotoSection(bool isDark, Color cardColor) {
    final initials = _firstNameCtrl.text.isNotEmpty
        ? _firstNameCtrl.text[0].toUpperCase()
        : 'U';

    return Center(
      child: GestureDetector(
        onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _profileImageUrl == null
                    ? LinearGradient(
                        colors: [AppColor.fourthColor, AppColor.primaryColor],
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
              child: _profileImageUrl != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: _profileImageUrl!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        placeholder: (_, __) => Center(
                          child: Text(initials,
                              style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                        errorWidget: (_, __, ___) => Center(
                          child: Text(initials,
                              style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(initials,
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColor.fourthColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF121212) : Colors.white,
                    width: 2,
                  ),
                ),
                child: _isUploadingPhoto
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.camera_alt, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      final filePath = picked.path;
      final filename = picked.name;
      final ext = filename.split('.').last.toLowerCase();
      final mimeSubtype = const {
        'jpg': 'jpeg', 'jpeg': 'jpeg', 'png': 'png',
        'gif': 'gif', 'webp': 'webp', 'bmp': 'bmp', 'heic': 'heic',
      }[ext] ?? 'jpeg';

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: filename,
        contentType: MediaType('image', mimeSubtype),
      );
      final resp = await ApiService.media.uploadMedia(
        entityType: 'profile',
        file: multipartFile,
      );
      final url = resp?.data?.url;
      if (url != null && mounted) {
        setState(() => _profileImageUrl = url);
        Get.snackbar('Success', 'Photo uploaded',
            backgroundColor: Colors.green.withValues(alpha: 0.9),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload photo',
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.fourthColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColor.fourthColor),
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
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        color: isDark ? Colors.white : AppColor.darkText,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: AppColor.fourthColor)
            : null,
        labelStyle: TextStyle(
          color: isDark ? Colors.white54 : AppColor.mediumText,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.white30 : AppColor.lightText,
          fontSize: 14,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
