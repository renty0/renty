import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/component/button.dart';
import 'package:renty/component/textformfield.dart';
import '../core/functions/checkinternet.dart';
import '../core/middleware/internet_middleware.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String verificationCode;

  const ResetPasswordPage({
    Key? key,
    required this.email,
    required this.verificationCode,
  }) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String _parseApiError(ApiException e) {
    try {
      if (e.message != null && e.message!.isNotEmpty) {
        final body = jsonDecode(e.message!);
        if (body is Map) {
          final messages = body['messages'];
          if (messages is List && messages.isNotEmpty) {
            return messages.first.toString();
          }
          if (body['error'] is String) return body['error'];
        }
      }
    } catch (_) {}
    switch (e.code) {
      case 400:
        return 'Invalid or expired reset token. Please request a new code.'.tr;
      case 422:
        return 'Password does not meet requirements. Please try again.'.tr;
      case 429:
        return 'Too many attempts. Please wait a few minutes.'.tr;
      default:
        return 'Failed to reset password. Please try again.'.tr;
    }
  }

  Future<void> resetPassword() async {
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      setState(() => errorMessage = 'Please fill in all fields'.tr);
      return;
    }
    if (newPass.length < 6) {
      setState(() => errorMessage = 'Password must be at least 6 characters'.tr);
      return;
    }
    if (newPass != confirmPass) {
      setState(() => errorMessage = 'Passwords do not match'.tr);
      return;
    }

    // Check internet
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      if (mounted) showNoInternetDialog(context);
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final command = ResetPasswordCommand(
        email: widget.email,
        token: widget.verificationCode,
        newPassword: newPass,
      );
      final response = await ApiService.auth.authResetPassword(command);

      if (!mounted) return;

      if (response != null && response.error != true) {
        // Show success dialog
        _showSuccessDialog();
      } else {
        final messages = response?.messages ?? [];
        setState(() {
          isLoading = false;
          errorMessage = messages.isNotEmpty
              ? messages.first
              : 'Failed to reset password. Please try again.'.tr;
        });
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = _parseApiError(e);
      });
    } on SocketException catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showNoInternetDialog(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage =
            'Connection error. Please check your internet and try again.'.tr;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColor.successColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle,
                      color: AppColor.successColor, size: 40),
                ),
                SizedBox(height: 16),
                Text("Password Reset!".tr,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor)),
                SizedBox(height: 8),
                Text(
                  "Your password has been reset successfully.\nPlease login with your new password.".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: AppColor.grey, height: 1.5),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/login", (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColor.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Go to Login".tr,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : AppColor.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 100,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(bottom: 20, top: 20),
                    decoration: BoxDecoration(
                      color: AppColor.successColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_open,
                        size: 50, color: AppColor.successColor),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Create New Password".tr,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColor.primaryColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Enter your new password below".tr,
                    style: TextStyle(
                        fontSize: 16, color: isDark ? Colors.white70 : AppColor.grey, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  if (errorMessage != null) ...[
                    SizedBox(height: 16),
                    _buildErrorBanner(errorMessage!),
                  ],
                  SizedBox(height: 40),
                  Text(
                    "New Password".tr,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColor.primaryColor),
                  ),
                  SizedBox(height: 10),
                  CustomTextForm(
                    hintText: "Enter new password".tr,
                    controller: newPasswordController,
                    obscureText: true,
                    isPassword: true,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Confirm Password".tr,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColor.primaryColor),
                  ),
                  SizedBox(height: 10),
                  CustomTextForm(
                    hintText: "Confirm new password".tr,
                    controller: confirmPasswordController,
                    obscureText: true,
                    isPassword: true,
                  ),
                  SizedBox(height: 30),
                  Button(
                    title: "Reset Password".tr,
                    isLoading: isLoading,
                    onpressed: resetPassword,
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20, top: 20),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/login", (route) => false);
                      },
                      child: Text("Back to Login".tr,
                          style: TextStyle(
                              fontSize: 16, color: isDark ? const Color(0xFF93C5FD) : AppColor.primaryColor)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1),
            child:
                Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4)),
          ),
          GestureDetector(
            onTap: () => setState(() => errorMessage = null),
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.close, color: Color(0xFFDC2626), size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
