import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/component/button.dart';
import 'package:renty/auth/reset_password.dart';
import '../core/functions/checkinternet.dart';
import '../core/middleware/internet_middleware.dart';

class ForgetPasswordOTPPage extends StatefulWidget {
  final String email;

  const ForgetPasswordOTPPage({Key? key, required this.email})
      : super(key: key);

  @override
  _ForgetPasswordOTPPageState createState() => _ForgetPasswordOTPPageState();
}

class _ForgetPasswordOTPPageState extends State<ForgetPasswordOTPPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  bool _canResend = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendCountdown--;
          if (_resendCountdown <= 0) {
            _canResend = true;
          } else {
            _startCountdown();
          }
        });
      }
    });
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
        return 'Invalid or expired verification code.'.tr;
      case 404:
        return 'No reset request found. Please request a new code.'.tr;
      case 429:
        return 'Too many attempts. Please wait a few minutes.'.tr;
      default:
        return 'Verification failed. Please try again.'.tr;
    }
  }

  Future<void> _verifyOTP() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      setState(() => _errorMessage = 'Please enter the full 6-digit code'.tr);
      return;
    }

    // Check internet
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      if (mounted) showNoInternetDialog(context);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final command = VerifyResetTokenCommand(
        email: widget.email,
        token: code,
      );
      final response = await ApiService.auth.authVerifyResetCode(command);

      if (!mounted) return;

      if (response != null && response.error != true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(
              email: widget.email,
              verificationCode: code,
            ),
          ),
        );
      } else {
        final messages = response?.messages ?? [];
        setState(() {
          _isLoading = false;
          _errorMessage = messages.isNotEmpty
              ? messages.first
              : 'Invalid verification code. Please try again.'.tr;
        });
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _parseApiError(e);
      });
    } on SocketException catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showNoInternetDialog(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Connection error. Please check your internet and try again.'.tr;
      });
    }
  }

  Future<void> _resendOTP() async {
    bool hasInternet = await checkInternet();
    if (!hasInternet) {
      if (mounted) showNoInternetDialog(context);
      return;
    }

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final command = ForgotPasswordCommand(email: widget.email);
      final response = await ApiService.auth.authForgotPassword(command);

      if (!mounted) return;

      if (response != null && response.error != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text("Verification code resent!".tr),
            ]),
            backgroundColor: AppColor.successColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to resend code. Please try again.".tr),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to resend code. Please try again.".tr),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
          _canResend = false;
          _resendCountdown = 60;
        });
        _startCountdown();
      }
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
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
          padding: EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.phonelink_lock,
                      size: 40, color: isDark ? const Color(0xFF93C5FD) : AppColor.primaryColor),
                ),
                SizedBox(height: 10),
                Text(
                  "Enter Verification Code".tr,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColor.primaryColor),
                ),
                SizedBox(height: 8),
                Text("We've sent a 6-digit code to".tr,
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : AppColor.grey)),
                SizedBox(height: 4),
                Text(widget.email,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColor.primaryColor)),

                // Error message
                if (_errorMessage != null) ...[
                  SizedBox(height: 16),
                  _buildErrorBanner(_errorMessage!),
                ],

                SizedBox(height: 40),

                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 60,
                    fieldWidth: 50,
                    activeFillColor:
                        isDark ? const Color(0xFF1E293B) : Colors.white,
                    activeColor: AppColor.primaryColor,
                    selectedColor: AppColor.secondColor,
                    selectedFillColor:
                        isDark ? const Color(0xFF1E293B) : Colors.white,
                    inactiveColor: isDark ? const Color(0xFF334155) : AppColor.borderGray,
                    inactiveFillColor:
                        isDark ? const Color(0xFF1E293B) : Colors.white,
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  keyboardType: TextInputType.number,
                  onCompleted: (v) => _verifyOTP(),
                  onChanged: (value) {
                    // Clear error when user starts typing
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),

                SizedBox(height: 30),

                Button(
                    title: "Verify",
                    isLoading: _isLoading,
                    onpressed: _verifyOTP),

                SizedBox(height: 40),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      Text("Didn't receive the code?".tr,
                          style:
                              TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColor.grey)),
                      SizedBox(height: 8),
                      if (_canResend)
                        TextButton(
                          onPressed: _isResending ? null : _resendOTP,
                          child: _isResending
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColor.primaryColor),
                                  ),
                                )
                              : Text("Resend Code".tr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFF93C5FD) : AppColor.primaryColor)),
                        )
                      else
                        Text(
                          'Resend code in @sec seconds'.trParams({'sec': _resendCountdown.toString()}),
                          style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : AppColor.grey,
                              fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom > 0
                        ? 100
                        : 20),
              ],
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
            onTap: () => setState(() => _errorMessage = null),
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
