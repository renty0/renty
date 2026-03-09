import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/component/custom_button.dart';
import 'package:renty/component/custom_text_field.dart';
import 'package:renty/utils/validators.dart';
import 'package:renty/main.dart';

import '../core/ChangePasswordController.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final ChangePasswordController _controller = Get.put(ChangePasswordController());

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await _controller.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorSnackbar(_controller.errorMessage.value);
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
              Icon(Icons.check_circle, color: AppColor.successColor),
              SizedBox(width: 12),
              Text("Success", style: TextStyle(color: AppColor.successColor)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Password changed successfully!"),
              SizedBox(height: 8),
              Text(
                "For security reasons, you will be logged out and need to login again with your new password.",
                style: TextStyle(fontSize: 14, color: AppColor.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logoutAndNavigate();
              },
              child: Text("OK", style: TextStyle(color: AppColor.primaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _logoutAndNavigate() {
    // Clear user data and token
    sharedPref.remove("user_id");
    sharedPref.remove("user_email");
    sharedPref.remove("user_name");
    sharedPref.remove("user_phone");
    sharedPref.remove("token");
    sharedPref.setString("step", "1"); // Reset to login step

    // Navigate to login screen
    Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
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
        title: const Text('Change Password'),
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
                      'For security reasons, you will be logged out\nafter changing your password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
                label: 'Current Password',
                hint: 'Enter your current password',
                prefixIcon: Icon(Icons.lock, color: AppColor.primaryColor),
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
                label: 'New Password',
                hint: 'Enter new password',
                prefixIcon: Icon(Icons.lock_outline, color: AppColor.primaryColor),
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
                label: 'Confirm New Password',
                hint: 'Confirm your new password',
                prefixIcon: Icon(Icons.lock_outline, color: AppColor.primaryColor),
                obscureText: !showConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
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
                        'You will be automatically logged out after password change for security purposes.',
                        style: TextStyle(
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
                      'Password Requirements:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('• At least 6 characters long', style: TextStyle(fontSize: 14)),
                    Text('• Include uppercase and lowercase letters', style: TextStyle(fontSize: 14)),
                    Text('• Include numbers and special characters', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Update Button
              Obx(() => CustomButton(
                text: 'Update Password & Logout',
                onPressed: _controller.isLoading.value ? null : _changePassword,
                isLoading: _controller.isLoading.value,
                backgroundColor: AppColor.primaryColor,
              )),
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
    super.dispose();
  }
}