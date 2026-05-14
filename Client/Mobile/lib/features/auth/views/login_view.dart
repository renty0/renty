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

/// Login page — matches the web login exactly:
/// logo → title → subtitle → email → password → forgot → button → register link
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authCtrl = Get.find<AuthController>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    _authCtrl.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
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
                    Image.asset(
                      'assets/app_icon/Logo1.png',
                      width: 72,
                      height: 72,
                    ),
                    const SizedBox(height: 20),

                    // ── Title ──
                    Text('Welcome Back', style: AppTextStyles.heading1),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue to Renty',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 36),

                    // ── Email ──
                    CustomTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    ),
                    const SizedBox(height: 20),

                    // ── Password ──
                    CustomTextField(
                      controller: _passwordCtrl,
                      label: 'Password',
                      obscureText: true,
                      validator: Validators.password,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    ),
                    const SizedBox(height: 4),

                    // ── Forgot password ──
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.toNamed('/forgot-password'),
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Login button ──
                    Obx(() => LoadingButton(
                          text: 'Login',
                          isLoading: _authCtrl.isLoading.value,
                          onPressed: _onSubmit,
                        )),
                    const SizedBox(height: 32),

                    // ── Divider ──
                    Divider(color: AppColors.gray200.withOpacity(0.5)),
                    const SizedBox(height: 24),

                    // ── Register link ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed('/register'),
                          child: Text('Sign Up', style: AppTextStyles.link),
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
