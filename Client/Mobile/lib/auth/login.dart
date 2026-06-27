import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/functions/checkinternet.dart';
import 'package:renty/core/middleware/internet_middleware.dart';
import 'package:renty/main.dart';
import '../component/button.dart';
import '../component/logo.dart';
import '../component/textformfield.dart';
import 'package:renty/utils/favorites_manager.dart';
import 'package:renty/utils/language_manager.dart';
import 'package:renty/utils/theme_manager.dart';
import 'package:renty/auth/forget_password_email.dart';
import 'package:renty/auth/otp_verification_page.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  /// Parse user-friendly error from ApiException JSON body
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
      case 401:
        return 'Invalid email or password. Please try again.';
      case 403:
        return 'Your account has been suspended. Please contact support.';
      case 404:
        return 'Account not found. Please check your email.';
      case 422:
        return 'Please check your input and try again.';
      case 429:
        return 'Too many attempts. Please wait and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => errorMessage = 'Please fill in all fields'.tr);
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
      final response = await ApiService.auth.authLogin(
        LoginCommand(email: email, password: password),
      );

      if (!mounted) return;

      if (response != null && response.data != null) {
        final data = response.data!;
        if (data.accessToken != null && data.accessToken!.isNotEmpty) {
          // Save tokens
          await sharedPref.setString("token", data.accessToken!);
          if (data.refreshToken != null) {
            await sharedPref.setString("refresh_token", data.refreshToken!);
          }
          // Save user info
          if (data.user != null) {
            if (data.user!.id != null) {
              await sharedPref.setString("user_id", data.user!.id!.toString());
            }
            if (data.user!.email != null) {
              await sharedPref.setString("user_email", data.user!.email!);
            }
            if (data.user!.firstName != null) {
              await sharedPref.setString("user_name", data.user!.firstName!);
            }
            
            // Set user ID for isolated preferences
            final userId = data.user!.id!.toString();
            LanguageManager.setCurrentUser(userId);
            ThemeManager.setCurrentUser(userId);
            FavoritesManager.setCurrentUser(userId);
            
            // Apply theme for the new user immediately
            final userTheme = ThemeManager.getThemeMode();
            MyApp.of(context)?.changeTheme(userTheme);
          }

          ApiService.refreshClient();

          try {
            await FavoritesManager.syncFavoritesFromServer();
          } catch (_) {}

          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil("/main", (route) => false);
          return;
        } else {
          // No token — server returned error messages
          final messages = response.messages ?? [];
          if (!mounted) return;

          // EmailNotConfirmed: redirect to OTP verification (matches web behaviour)
          if (messages.isNotEmpty && messages.first == 'EmailNotConfirmed') {
            setState(() => isLoading = false);
            Get.snackbar(
              'Verify Your Email'.tr,
              'Please verify your email to continue.'.tr,
              backgroundColor: Colors.orange.withValues(alpha: 0.9),
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => OTPVerificationPage(email: email),
            ));
            return;
          }

          setState(() {
            isLoading = false;
            errorMessage = messages.isNotEmpty
                ? messages.first
                : 'Login failed. Please check your credentials.'.tr;
          });
          return;
        }
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMessage = 'Login failed. Please check your credentials.'.tr;
        });
        return;
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      // EmailNotConfirmed can also arrive as a 400/401 ApiException
      final parsed = _parseApiError(e);
      if (parsed == 'EmailNotConfirmed' || e.message?.contains('EmailNotConfirmed') == true) {
        setState(() => isLoading = false);
        Get.snackbar(
          'Verify Your Email'.tr,
          'Please verify your email to continue.'.tr,
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OTPVerificationPage(email: email),
        ));
        return;
      }
      setState(() {
        isLoading = false;
        errorMessage = parsed;
      });
    } on SocketException catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showNoInternetDialog(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Connection error. Please check your internet and try again.'.tr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              SizedBox(height: 30),
              Logo(),
              SizedBox(height: 30),
              Text(
                "Welcome Back".tr,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColor.primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Login to continue".tr,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorBanner(errorMessage!),
              ],
              const SizedBox(height: 40),
              Text("Email".tr, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              CustomTextForm(
                hintText: "Enter your email".tr,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              Text("Password".tr, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              CustomTextForm(
                hintText: "Enter your password".tr,
                controller: passController,
                obscureText: true,
                isPassword: true,
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ForgetPasswordEmailPage(),
                  ));
                },
                child: Container(
                  alignment: TextDirection.ltr == Directionality.of(context)
                      ? Alignment.topRight
                      : Alignment.topLeft,
                  child: Text(
                    "Forgot Password?".tr,
                    style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF93C5FD) : AppColor.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Button(title: "Login".tr, isLoading: isLoading, onpressed: signIn),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ".tr,
                      style: Theme.of(context).textTheme.bodyMedium),
                  InkWell(
                    onTap: () => Navigator.of(context).pushNamed("/register"),
                    child: Text("Register".tr,
                        style: TextStyle(
                            fontSize: 16,
                            color: isDark ? const Color(0xFF93C5FD) : AppColor.primaryColor,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
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
            child: Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
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
