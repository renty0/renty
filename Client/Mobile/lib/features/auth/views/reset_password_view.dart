import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';

/// Reset Password page — 3-step flow within a single screen:
/// Step 1: Enter email → request code
/// Step 2: Enter verification code
/// Step 3: Enter new password + confirm
class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _authCtrl = Get.find<AuthController>();

  int _step = 1; // 1: Request Code, 2: Verify Code, 3: Reset Password

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['email'] != null) {
      _emailCtrl.text = args['email'];
    }
    // If navigated from forgot-password, the code was already sent → skip to step 2
    if (args != null && args['codeSent'] == true) {
      _step = 2;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_step == 1) {
      final success = await _authCtrl.forgotPassword(_emailCtrl.text.trim());
      if (success) setState(() => _step = 2);
    } else if (_step == 2) {
      final success = await _authCtrl.verifyResetCode(
        _emailCtrl.text.trim(),
        _codeCtrl.text.trim(),
      );
      if (success) setState(() => _step = 3);
    } else {
      // Check password match before submitting
      if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
        Get.snackbar('Error', 'Passwords do not match',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      await _authCtrl.resetPassword(
        _emailCtrl.text.trim(),
        _codeCtrl.text.trim(),
        _newPasswordCtrl.text,
      );
    }
  }

  String get _buttonText {
    switch (_step) {
      case 1:
        return 'Send Reset Code';
      case 2:
        return 'Verify Code';
      default:
        return 'Reset Password';
    }
  }

  String get _subtitle {
    switch (_step) {
      case 1:
        return 'Enter your email to receive a reset code';
      case 2:
        return 'Enter the code sent to your email';
      default:
        return 'Create your new password';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: AuthCard(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Logo ──
                    Image.asset('assets/app_icon/Logo1.png',
                        width: 72, height: 72),
                    const SizedBox(height: 20),

                    // ── Title ──
                    Text('Reset Password', style: AppTextStyles.heading1),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),

                    // ── Email (always visible, disabled after step 1) ──
                    CustomTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      enabled: _step == 1,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    ),
                    const SizedBox(height: 20),

                    // ── Step 2: Code input ──
                    if (_step == 2) ...[
                      CustomTextField(
                        controller: _codeCtrl,
                        label: 'Reset Code',
                        validator: (v) => Validators.required(v, 'Reset code'),
                        prefixIcon: const Icon(Icons.pin_outlined, size: 20),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Step 3: New password fields ──
                    if (_step == 3) ...[
                      CustomTextField(
                        controller: _newPasswordCtrl,
                        label: 'New Password',
                        obscureText: true,
                        validator: Validators.password,
                        prefixIcon:
                            const Icon(Icons.lock_outline, size: 20),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _confirmPasswordCtrl,
                        label: 'Confirm Password',
                        obscureText: true,
                        validator: (v) => Validators.confirmPassword(
                            v, _newPasswordCtrl.text),
                        prefixIcon:
                            const Icon(Icons.lock_outline, size: 20),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Submit button ──
                    Obx(() => LoadingButton(
                          text: _buttonText,
                          isLoading: _authCtrl.isLoading.value,
                          onPressed: _onSubmit,
                        )),

                    const SizedBox(height: 32),
                    Divider(color: AppColors.gray200.withOpacity(0.5)),
                    const SizedBox(height: 16),

                    // ── Login link ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remember your password? ',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.offAllNamed('/login'),
                          child: Text('Login', style: AppTextStyles.link),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
