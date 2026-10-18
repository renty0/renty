import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/component/custom_button.dart';
import 'package:renty/component/custom_text_field.dart';
import 'package:renty/utils/validators.dart';
import 'package:renty/core/services/secure_storage_service.dart';
import 'package:renty/core/blocs/blocs.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:renty/main.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ChangePasswordCubit _cubit;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _cubit = ChangePasswordCubit();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await _cubit.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorSnackbar(_cubit.state.errorMessage);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColor.successColor),
              const SizedBox(width: 12),
              Text('Success'.tr, style: const TextStyle(color: AppColor.successColor)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Password changed successfully!'.tr),
              const SizedBox(height: 8),
              Text(
                'For security reasons, you will be logged out and need to login again with your new password.'.tr,
                style: const TextStyle(fontSize: 14, color: AppColor.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logoutAndNavigate();
              },
              child: Text('OK'.tr, style: const TextStyle(color: AppColor.primaryColor)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logoutAndNavigate() async {
    // SECURITY: Wipe all sensitive data from Keystore/Keychain
    await SecureStorageService.clearAll();
    // Clear in-memory caches
    cachedToken        = null;
    cachedRefreshToken = null;
    cachedUserId       = null;
    // 'step' is non-sensitive — stays in SharedPreferences
    await sharedPref.setString('step', '1');

    // Navigate to login screen
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.warningColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'.tr),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security Icon with Info
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security_outlined,
                        size: 40,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'For security reasons, you will be logged out\nafter changing your password.'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColor.secondColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Current Password
              CustomTextField(
                controller: currentPasswordController,
                label: 'Current Password'.tr,
                hint: 'Enter your current password'.tr,
                prefixIcon: const Icon(Icons.lock, color: AppColor.primaryColor),
                obscureText: !showCurrentPassword,
                validator: (value) => Validators.validateRequired(value, 'Current password'),
                suffixIcon: IconButton(
                  icon: Icon(
                    showCurrentPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColor.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      showCurrentPassword = !showCurrentPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // New Password
              CustomTextField(
                controller: newPasswordController,
                label: 'New Password'.tr,
                hint: 'Enter new password'.tr,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColor.primaryColor),
                obscureText: !showNewPassword,
                validator: Validators.validatePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    showNewPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColor.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      showNewPassword = !showNewPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              CustomTextField(
                controller: confirmPasswordController,
                label: 'Confirm New Password'.tr,
                hint: 'Confirm your new password'.tr,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColor.primaryColor),
                obscureText: !showConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password'.tr;
                  }
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match'.tr;
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColor.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      showConfirmPassword = !showConfirmPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Security Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.warningColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColor.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You will be automatically logged out after password change for security purposes.'.tr,
                        style: const TextStyle(
                          color: AppColor.warningColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Password Requirements
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.backgroundcolor2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.borderGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Requirements:'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('• At least 6 characters long'.tr, style: const TextStyle(fontSize: 14)),
                    Text('• Include uppercase and lowercase letters'.tr, style: const TextStyle(fontSize: 14)),
                    Text('• Include numbers and special characters'.tr, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Update Button
              BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                bloc: _cubit,
                builder: (context, state) => CustomButton(
                  text: 'Update Password & Logout'.tr,
                  onPressed: state.isLoading ? null : _changePassword,
                  isLoading: state.isLoading,
                  backgroundColor: AppColor.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _cubit.close();
    super.dispose();
  }
}