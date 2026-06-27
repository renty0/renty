import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/component/button.dart';
import 'package:renty/component/textformfield.dart';
import 'package:renty/auth/forget_password_otp.dart';
import '../core/functions/checkinternet.dart';
import '../core/middleware/internet_middleware.dart';

class ForgetPasswordEmailPage extends StatefulWidget {
  const ForgetPasswordEmailPage({super.key});

  @override
  State<ForgetPasswordEmailPage> createState() =>
      _ForgetPasswordEmailPageState();
}

class _ForgetPasswordEmailPageState extends State<ForgetPasswordEmailPage> {
  final emailController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
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
      case 404:
        return 'No account found with this email address.'.tr;
      case 429:
        return 'Too many attempts. Please wait a few minutes.'.tr;
      default:
        return 'Failed to send reset code. Please try again.'.tr;
    }
  }

  Future<void> sendResetOTP() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() => errorMessage = 'Please enter your email'.tr);
      return;
    }
    if (!GetUtils.isEmail(email)) {
      setState(() => errorMessage = 'Please enter a valid email address'.tr);
      return;
    }

    // Check internet BEFORE calling API
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
      final command = ForgotPasswordCommand(email: email);
      final response = await ApiService.auth.authForgotPassword(command);

      if (!mounted) return;

      if (response != null && response.error != true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ForgetPasswordOTPPage(email: email),
          ),
        );
      } else {
        final messages = response?.messages ?? [];
        setState(() {
          isLoading = false;
          errorMessage = messages.isNotEmpty
              ? messages.first
              : 'Failed to send reset code. Please try again.'.tr;
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
                      color: AppColor.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 50,
                      color: isDark ? const Color(0xFF93C5FD) : AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Forgot Password".tr,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColor.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Enter your email to receive a reset code".tr,
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
                    "Email".tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomTextForm(
                    hintText: "Enter your email".tr,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 30),
                  Button(
                    title: "Send Reset Code".tr,
                    isLoading: isLoading,
                    onpressed: sendResetOTP,
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20, top: 20),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Back to Login".tr,
                        style:
                            TextStyle(fontSize: 16, color: isDark ? const Color(0xFF93C5FD) : AppColor.primaryColor),
                      ),
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
