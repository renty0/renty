import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/functions/checkinternet.dart';
import 'package:renty/core/middleware/internet_middleware.dart';
import '../component/button.dart';
import '../component/logo.dart';
import '../component/textformfield.dart';
import 'email_verification_notification.dart';

/// Register page — matches the Web's 3-step registration flow:
/// Step 1: Account Info (email, password, confirm)
/// Step 2: Profile Info (firstName, lastName, phone)
/// Step 3: Additional Info (userType, city, country, bio)
class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  // Step 1: Account Info
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmController = TextEditingController();

  // Step 2: Profile Info
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  // Step 3: Additional Info
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final bioController = TextEditingController();

  int _currentStep = 0;
  bool isLoading = false;
  String? errorMessage;
  bool acceptTerms = false;
  bool acceptPrivacy = false;

  // UserType: 1=Renter, 2=Owner, 3=Both
  UserType _selectedUserType = UserType.number1;

  final List<Map<String, dynamic>> _userTypeOptions = [
    {
      'label': 'Renter',
      'desc': 'I want to rent items from others',
      'icon': Icons.shopping_bag_outlined,
      'value': UserType.number1,
    },
    {
      'label': 'Owner',
      'desc': 'I want to list my items for others to rent',
      'icon': Icons.storefront_outlined,
      'value': UserType.number2,
    },
    {
      'label': 'Both',
      'desc': 'I want to rent and list items',
      'icon': Icons.groups_outlined,
      'value': UserType.number3,
    },
  ];

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    confirmController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    countryController.dispose();
    bioController.dispose();
    super.dispose();
  }

  String? _validateStep(int step) {
    switch (step) {
      case 0:
        if (firstNameController.text.trim().isEmpty)
          return 'First name is required';
        if (lastNameController.text.trim().isEmpty)
          return 'Last name is required';
        if (emailController.text.trim().isEmpty) return 'Email is required';
        if (!GetUtils.isEmail(emailController.text.trim()))
          return 'Please enter a valid email';
        break;
      case 1:
        if (passController.text.trim().length < 6)
          return 'Password must be at least 6 characters';
        if (passController.text != confirmController.text)
          return 'Passwords do not match';
        break;
      case 2:
        if (!acceptTerms) return 'You must agree to the Terms & Conditions to continue';
        if (!acceptPrivacy) return 'You must agree to the Privacy Policy to continue';
        break;
    }
    return null;
  }

  void _nextStep() {
    final error = _validateStep(_currentStep);
    if (error != null) {
      setState(() => errorMessage = error);
      return;
    }
    setState(() {
      errorMessage = null;
      _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      errorMessage = null;
      _currentStep--;
    });
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
      case 409:
        return 'An account with this email already exists.';
      case 422:
        return 'Please check your input and try again.';
      case 429:
        return 'Too many attempts. Please wait and try again.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  Future<void> _signUp() async {
    final error = _validateStep(_currentStep);
    if (error != null) {
      setState(() => errorMessage = error);
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
      final command = RegisterCommand(
        email: emailController.text.trim(),
        password: passController.text.trim(),
        confirmPassword: confirmController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phoneNumber: phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
        userType: _selectedUserType,
        city: cityController.text.trim().isEmpty
            ? null
            : cityController.text.trim(),
        country: countryController.text.trim().isEmpty
            ? null
            : countryController.text.trim(),
        bio: bioController.text.trim().isEmpty
            ? null
            : bioController.text.trim(),
      );

      final response = await ApiService.auth.authRegister(command);

      if (!mounted) return;

      if (response != null && response.error != true) {
        Get.snackbar('Success', 'Account created! Please verify your email.',
            backgroundColor: AppColor.successColor.withValues(alpha: 0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 3));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationNotification(
              email: emailController.text.trim(),
            ),
          ),
        );
      } else {
        final messages = response?.messages ?? [];
        setState(() {
          isLoading = false;
          errorMessage = messages.isNotEmpty
              ? messages.first
              : 'Registration failed. Please try again.';
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
        errorMessage = 'Connection error. Please check your internet and try again.';
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
              SizedBox(height: 20),
              Logo(),
              SizedBox(height: 20),
              Text(
                "Create Account",
                style: TextStyle(
                  color: isDark ? Colors.white : AppColor.primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                "Step ${_currentStep + 1} of 3",
                style: TextStyle(
                    fontSize: 14,
                    color: AppColor.mediumText,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              // Step indicator
              _buildStepIndicator(),
              SizedBox(height: 16),

              // Error
              if (errorMessage != null) _buildError(),

              SizedBox(height: 16),

              // Step content
              if (_currentStep == 0) _buildAccountStep(),
              if (_currentStep == 1) _buildProfileStep(),
              if (_currentStep == 2) _buildAdditionalStep(),

              SizedBox(height: 24),

              // Navigation
              _buildStepButtons(),

              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? const Color(0xFF93C5FD) : AppColor.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i <= _currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            height: 4,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColor.primaryColor
                  : AppColor.borderGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildError() {
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
            child: Text(errorMessage!,
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

  // ─── Step 1: Personal Info ────────────────────────────────────
  Widget _buildAccountStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Personal Information",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColor.darkText)),
        SizedBox(height: 6),
        Text("Tell us your name and email address",
            style: TextStyle(fontSize: 13, color: AppColor.mediumText)),
        SizedBox(height: 20),
        Text("First Name *", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        CustomTextForm(
          key: const ValueKey('firstName'),
          hintText: "Enter your first name",
          controller: firstNameController,
        ),
        SizedBox(height: 16),
        Text("Last Name *", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        CustomTextForm(
          key: const ValueKey('lastName'),
          hintText: "Enter your last name",
          controller: lastNameController,
        ),
        SizedBox(height: 16),
        Text("Email *", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        CustomTextForm(
          key: const ValueKey('email'),
          hintText: "Enter your email",
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  // ─── Step 2: Account Security ─────────────────────────────────
  Widget _buildProfileStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Account Security",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColor.darkText)),
        SizedBox(height: 6),
        Text("Set your phone number and create a password",
            style: TextStyle(fontSize: 13, color: AppColor.mediumText)),
        SizedBox(height: 20),
        Text("Phone Number", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        CustomTextForm(
          key: const ValueKey('phone'),
          hintText: "Optional",
          controller: phoneController,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 16),
        Text("Password *", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        CustomTextForm(
          key: const ValueKey('password'),
          hintText: "Min 6 characters",
          controller: passController,
          obscureText: true,
          isPassword: true,
        ),
        SizedBox(height: 16),
        Text("Confirm Password *",
            style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        CustomTextForm(
          key: const ValueKey('confirmPassword'),
          hintText: "Re-enter your password",
          controller: confirmController,
          obscureText: true,
          isPassword: true,
        ),
      ],
    );
  }

  // ─── Step 3: Additional Info ──────────────────────────────────
  Widget _buildAdditionalStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Account Type",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColor.darkText)),
        SizedBox(height: 6),
        Text("How will you use Renty?",
            style: TextStyle(fontSize: 13, color: AppColor.mediumText)),
        SizedBox(height: 16),
        // User Type Cards
        ..._userTypeOptions.map((opt) {
          final isSelected = _selectedUserType == opt['value'];
          return GestureDetector(
            onTap: () => setState(() => _selectedUserType = opt['value']),
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColor.fourthColor.withOpacity(0.2) : AppColor.primaryColor.withOpacity(0.08))
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? (isDark ? AppColor.fourthColor : AppColor.primaryColor) : (isDark ? const Color(0xFF334155) : AppColor.borderGray),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(opt['icon'],
                          color: isSelected
                              ? (isDark ? const Color(0xFF93C5FD) : AppColor.primaryColor)
                              : (isDark ? Colors.white54 : AppColor.mediumText),
                      size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opt['label'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isSelected
                                  ? (isDark ? Colors.white : AppColor.primaryColor)
                                  : (isDark ? Colors.white : AppColor.darkText),
                            )),
                        SizedBox(height: 2),
                        Text(opt['desc'],
                            style: TextStyle(
                                fontSize: 12, color: AppColor.mediumText)),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle,
                        color: isDark ? AppColor.fourthColor : AppColor.primaryColor, size: 22),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: 16),
        Text("City", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        CustomTextForm(
          hintText: "Optional",
          controller: cityController,
        ),
        SizedBox(height: 16),
        Text("Country", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        CustomTextForm(
          hintText: "Optional",
          controller: countryController,
        ),
        SizedBox(height: 16),
        Text("Bio", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        CustomTextForm(
          hintText: "Tell us about yourself (optional)",
          controller: bioController,
        ),
        SizedBox(height: 20),
        // ── Terms & Privacy Agreement ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColor.primaryColor.withOpacity(0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Before creating your account',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              // Terms checkbox
              _buildAgreementRow(
                value: acceptTerms,
                onChanged: (v) => setState(() => acceptTerms = v ?? false),
                label: 'I agree to the ',
                linkText: 'Terms & Conditions',
                url: 'https://appforyou.store/Renty/terms.html',
              ),
              const SizedBox(height: 10),
              // Privacy checkbox
              _buildAgreementRow(
                value: acceptPrivacy,
                onChanged: (v) => setState(() => acceptPrivacy = v ?? false),
                label: 'I agree to the ',
                linkText: 'Privacy Policy',
                url: 'https://appforyou.store/Renty/privacy.html',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Reusable checkbox + tappable link row for agreement items.
  Widget _buildAgreementRow({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
    required String linkText,
    required String url,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColor.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : AppColor.mediumText,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                  }
                },
                child: Text(
                  linkText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepButtons() {
    if (_currentStep == 0) {
      return Button(
        title: "Next",
        isLoading: false,
        onpressed: _nextStep,
      );
    } else if (_currentStep == 1) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _prevStep,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: AppColor.primaryColor),
              ),
              child: Text("Back",
                  style: TextStyle(
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Button(title: "Next", isLoading: false, onpressed: _nextStep),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _prevStep,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: AppColor.primaryColor),
              ),
              child: Text("Back",
                  style: TextStyle(
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Button(
                title: "Register", isLoading: isLoading, onpressed: _signUp),
          ),
        ],
      );
    }
  }
}
