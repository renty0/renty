import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';
import '../controllers/profile_controller.dart';

/// Profile page matching the web's profile component:
/// avatar with camera button, editable form fields, save + logout.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _ctrl = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: _ctrl.firstName.value);
    _lastNameCtrl = TextEditingController(text: _ctrl.lastName.value);
    _emailCtrl = TextEditingController(text: _ctrl.email.value);
    _addressCtrl = TextEditingController(text: _ctrl.address.value);
    _cityCtrl = TextEditingController(text: _ctrl.city.value);
    _countryCtrl = TextEditingController(text: _ctrl.country.value);
    _bioCtrl = TextEditingController(text: _ctrl.bio.value);

    // Sync controllers when data loads
    ever(_ctrl.userData, (_) {
      _firstNameCtrl.text = _ctrl.firstName.value;
      _lastNameCtrl.text = _ctrl.lastName.value;
      _emailCtrl.text = _ctrl.email.value;
      _addressCtrl.text = _ctrl.address.value;
      _cityCtrl.text = _ctrl.city.value;
      _countryCtrl.text = _ctrl.country.value;
      _bioCtrl.text = _ctrl.bio.value;
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _syncFormToController() {
    _ctrl.firstName.value = _firstNameCtrl.text.trim();
    _ctrl.lastName.value = _lastNameCtrl.text.trim();
    _ctrl.address.value = _addressCtrl.text.trim();
    _ctrl.city.value = _cityCtrl.text.trim();
    _ctrl.country.value = _countryCtrl.text.trim();
    _ctrl.bio.value = _bioCtrl.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text('Profile',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent_outlined),
            tooltip: 'Support',
            onPressed: () => Get.toNamed('/support'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Profile Card ──
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.gray200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ── Avatar ──
                      _buildAvatar(),
                      const SizedBox(height: 32),

                      // ── Divider line ──
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Form Fields ──
                      CustomTextField(
                        label: 'First Name',
                        controller: _firstNameCtrl,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (v) => v == null || v.isEmpty
                            ? 'First name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: 'Last Name',
                        controller: _lastNameCtrl,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Last name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: 'Email',
                        controller: _emailCtrl,
                        prefixIcon: const Icon(Icons.email_outlined),
                        readOnly: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: 'Address',
                        controller: _addressCtrl,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: 'City',
                        controller: _cityCtrl,
                        prefixIcon: const Icon(Icons.location_city_outlined),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: 'Country',
                        controller: _countryCtrl,
                        prefixIcon: const Icon(Icons.public_outlined),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: 'Bio',
                        controller: _bioCtrl,
                        prefixIcon: const Icon(Icons.info_outline),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      // ── Save Button ──
                      Container(
                        padding: const EdgeInsets.only(top: 24),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFF1F5F9)),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Obx(() => LoadingButton(
                                text: 'Save Changes',
                                isLoading: _ctrl.isSaving.value,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _syncFormToController();
                                    _ctrl.updateProfile();
                                  }
                                },
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Avatar Widget ─────────────────────────────────────────────

  Widget _buildAvatar() {
    return Column(
      children: [
        Text(
          'My Profile',
          style: AppTextStyles.heading2.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 20),
        Stack(
          children: [
            // Avatar image
            Obx(() {
              final url = _ctrl.profilePictureUrl.value;
              return Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gray300.withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: url.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          width: 130,
                          height: 130,
                          placeholder: (_, __) => Container(
                            color: AppColors.gray100,
                            child: const Icon(Icons.person,
                                size: 60, color: AppColors.gray400),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.gray100,
                            child: const Icon(Icons.person,
                                size: 60, color: AppColors.gray400),
                          ),
                        )
                      : Container(
                          color: AppColors.gray100,
                          child: const Icon(Icons.person,
                              size: 60, color: AppColors.gray400),
                        ),
                ),
              );
            }),

            // Camera button
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: _ctrl.pickAndUploadAvatar,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Uploading indicator
        Obx(() {
          if (!_ctrl.isUploading.value) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Uploading...',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.gray500,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Logout Dialog ─────────────────────────────────────────────

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: AppTextStyles.heading3),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.gray500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _ctrl.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
