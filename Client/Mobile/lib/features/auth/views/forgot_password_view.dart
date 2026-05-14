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

/// Forgot Password page — matches the web:
/// email input → submit → success message with "Enter Code" link.
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _authCtrl = Get.find<AuthController>();
  bool _submitted = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await _authCtrl.forgotPassword(_emailCtrl.text.trim());
    if (success) {
      setState(() => _submitted = true);
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
                  Text('Forgot Password', style: AppTextStyles.heading1),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email to receive a reset code',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  if (!_submitted) ...[
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
                          const SizedBox(height: 24),
                          Obx(() => LoadingButton(
                                text: 'Send Reset Code',
                                isLoading: _authCtrl.isLoading.value,
                                onPressed: _onSubmit,
                              )),
                        ],
                      ),
                    ),
                  ] else ...[
                    // ── Success ──
                    const Icon(Icons.mark_email_read_outlined,
                        color: AppColors.success, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'A reset code has been sent to your email. Please check your inbox.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.gray700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    LoadingButton(
                      text: 'Enter Reset Code',
                      onPressed: () => Get.offNamed('/reset-password',
                          arguments: {'email': _emailCtrl.text.trim(), 'codeSent': true}),
                    ),
                  ],

                  const SizedBox(height: 32),
                  Divider(color: AppColors.gray200.withOpacity(0.5)),
                  const SizedBox(height: 16),
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
    );
  }
}
