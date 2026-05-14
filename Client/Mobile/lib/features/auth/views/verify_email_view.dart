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

/// Verify Email page — matches the web:
/// email + code fields, success state → back to login.
class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _authCtrl = Get.find<AuthController>();
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill email from navigation arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['email'] != null) {
      _emailCtrl.text = args['email'];
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await _authCtrl.verifyEmail(
      _emailCtrl.text.trim(),
      _codeCtrl.text.trim(),
    );
    if (success) {
      setState(() => _verified = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.offAllNamed('/login');
      });
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo ──
                  Image.asset('assets/app_icon/Logo1.png', width: 72, height: 72),
                  const SizedBox(height: 20),

                  // ── Title ──
                  Text('Verify Your Email', style: AppTextStyles.heading1),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the verification code sent to your email',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  if (_verified) ...[
                    // ── Success state ──
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.success, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Email verified successfully!',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.gray700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Get.offAllNamed('/login'),
                      child: Text('Back to Login', style: AppTextStyles.link),
                    ),
                  ] else ...[
                    // ── Form ──
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _emailCtrl,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                            prefixIcon:
                                const Icon(Icons.email_outlined, size: 20),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _codeCtrl,
                            label: 'Verification Code',
                            validator: (v) =>
                                Validators.required(v, 'Verification code'),
                            prefixIcon:
                                const Icon(Icons.pin_outlined, size: 20),
                          ),
                          const SizedBox(height: 24),
                          Obx(() => LoadingButton(
                                text: 'Verify',
                                isLoading: _authCtrl.isLoading.value,
                                onPressed: _onSubmit,
                              )),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  Divider(color: AppColors.gray200.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  if (!_verified)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          if (_emailCtrl.text.trim().isNotEmpty) {
                            _authCtrl.sendVerification(_emailCtrl.text.trim());
                          }
                        },
                        child: Text('Resend Code', style: AppTextStyles.link),
                      ),
                    ),
                  GestureDetector(
                    onTap: () => Get.offAllNamed('/login'),
                    child: Text('Back to Login', style: AppTextStyles.link),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
