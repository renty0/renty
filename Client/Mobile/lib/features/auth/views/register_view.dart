import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_background.dart';

/// 3-step registration — matches the web's register stepper:
/// Step 1: Account Info (email, password, confirm)
/// Step 2: Profile Info (first name, last name, phone)
/// Step 3: User Type + Location + Terms
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _pageCtrl = PageController();
  final _authCtrl = Get.find<AuthController>();

  // Step form keys
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // Step 1 controllers
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  // Step 2 controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Step 3 controllers
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  int _currentStep = 0;
  String _selectedUserType = 'Renter';
  bool _acceptTerms = false;
  bool _formSubmitted = false;

  final _userTypeOptions = [
    {
      'name': 'Renter',
      'icon': Icons.shopping_basket_outlined,
      'title': 'Renter',
      'desc': 'Browse and rent items from owners near you',
    },
    {
      'name': 'Owner',
      'icon': Icons.storefront_outlined,
      'title': 'Owner',
      'desc': 'List your items and earn money by renting them out',
    },
    {
      'name': 'Both',
      'icon': Icons.diversity_3_outlined,
      'title': 'Both',
      'desc': 'Rent items from others and list your own',
    },
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _addressCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && !_step1Key.currentState!.validate()) return;
    if (_currentStep == 1 && !_step2Key.currentState!.validate()) return;

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSubmit() {
    setState(() => _formSubmitted = true);
    if (!_step3Key.currentState!.validate()) return;
    if (!_acceptTerms) return;

    _authCtrl.register({
      'email': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text,
      'confirmPassword': _confirmPasswordCtrl.text,
      'firstName': _firstNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'phoneNumber': _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      'city': _cityCtrl.text.trim().isNotEmpty ? _cityCtrl.text.trim() : null,
      'country': _countryCtrl.text.trim().isNotEmpty ? _countryCtrl.text.trim() : null,
      'address': _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
      'bio': _bioCtrl.text.trim().isNotEmpty ? _bioCtrl.text.trim() : null,
      'userType': _userTypeToInt(_selectedUserType),
    });
  }

  int _userTypeToInt(String type) {
    switch (type) {
      case 'Renter': return 1;
      case 'Owner': return 2;
      case 'Both': return 3;
      default: return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                children: [
                  Image.asset('assets/app_icon/Logo1.png', width: 64, height: 64),
                  const SizedBox(height: 12),
                  Text(
                    'Create Account',
                    style: AppTextStyles.heading2.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray300),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Text(
                          'Login',
                          style: AppTextStyles.link.copyWith(color: AppColors.accentLight),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Step Indicator ──
                  _buildStepIndicator(),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ── Steps Content ──
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step Indicator ───────────────────────────────────────────────

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepDot(0, Icons.person_outline, 'Account'),
        _buildStepConnector(0),
        _buildStepDot(1, Icons.assignment_ind_outlined, 'Profile'),
        _buildStepConnector(1),
        _buildStepDot(2, Icons.settings_suggest_outlined, 'Preferences'),
      ],
    );
  }

  Widget _buildStepDot(int index, IconData icon, String label) {
    final isActive = _currentStep == index;
    final isCompleted = _currentStep > index;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success
                  : isActive
                      ? AppColors.accentLight
                      : AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompleted || isActive
                    ? Colors.transparent
                    : AppColors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.accentLight.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: isActive ? AppColors.white : AppColors.gray400,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int index) {
    final isCompleted = _currentStep > index;
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.success : AppColors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // ── Step 1: Account Info ─────────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account Information', style: AppTextStyles.heading3),
            const SizedBox(height: 4),
            Text('Enter your email and create a password',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _emailCtrl,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _passwordCtrl,
              label: 'Password',
              obscureText: true,
              validator: Validators.password,
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _confirmPasswordCtrl,
              label: 'Confirm Password',
              obscureText: true,
              validator: (v) =>
                  Validators.confirmPassword(v, _passwordCtrl.text),
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
            ),
            const SizedBox(height: 32),
            LoadingButton(
              text: 'Next',
              onPressed: _nextStep,
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Profile Info ─────────────────────────────────────────

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile Information', style: AppTextStyles.heading3),
            const SizedBox(height: 4),
            Text('Tell us a bit about yourself',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _firstNameCtrl,
              label: 'First Name',
              validator: (v) => Validators.minLength(v, 2, 'First name'),
              prefixIcon: const Icon(Icons.person_outline, size: 20),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _lastNameCtrl,
              label: 'Last Name',
              validator: (v) => Validators.minLength(v, 2, 'Last name'),
              prefixIcon: const Icon(Icons.person_outline, size: 20),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: Validators.phone,
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: LoadingButton(
                    text: 'Back',
                    onPressed: _prevStep,
                    outlined: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LoadingButton(
                    text: 'Next',
                    onPressed: _nextStep,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 3: User Type + Location ─────────────────────────────────

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step3Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Your Role', style: AppTextStyles.heading3),
            const SizedBox(height: 4),
            Text('How will you use Renty?', style: AppTextStyles.bodySmall),
            const SizedBox(height: 20),

            // ── Role cards ──
            ..._userTypeOptions.map((opt) => _buildRoleCard(opt)),
            const SizedBox(height: 24),

            // ── Divider ──
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.gray200)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'LOCATION & ABOUT',
                    style: AppTextStyles.captionSmall.copyWith(
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.gray200)),
              ],
            ),
            const SizedBox(height: 20),

            // ── Location fields ──
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _cityCtrl,
                    label: 'City',
                    prefixIcon: const Icon(Icons.location_city_outlined, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _countryCtrl,
                    label: 'Country',
                    prefixIcon: const Icon(Icons.public_outlined, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _addressCtrl,
              label: 'Address',
              prefixIcon: const Icon(Icons.home_outlined, size: 20),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _bioCtrl,
              label: 'Bio',
              maxLines: 3,
              prefixIcon: const Icon(Icons.info_outline, size: 20),
            ),
            const SizedBox(height: 20),

            // ── Terms ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _acceptTerms,
                          onChanged: (v) => setState(() => _acceptTerms = v!),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.gray600,
                            ),
                            children: const [
                              TextSpan(text: 'I accept the '),
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_formSubmitted && !_acceptTerms) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.error_outline, size: 16, color: AppColors.danger),
                        const SizedBox(width: 4),
                        Text(
                          'You must accept the terms',
                          style: AppTextStyles.error,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Actions ──
            Row(
              children: [
                Expanded(
                  child: LoadingButton(
                    text: 'Back',
                    onPressed: _prevStep,
                    outlined: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => LoadingButton(
                        text: 'Register',
                        isLoading: _authCtrl.isLoading.value,
                        onPressed: _onSubmit,
                        color: AppColors.accent,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> option) {
    final isSelected = _selectedUserType == option['name'];
    return GestureDetector(
      onTap: () => setState(() => _selectedUserType = option['name'] as String),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.04) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.gray100,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option['icon'] as IconData,
                color: isSelected ? AppColors.white : AppColors.gray600,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['title'] as String,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option['desc'] as String,
                    style: AppTextStyles.captionSmall.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.success, size: 24),
          ],
        ),
      ),
    );
  }
}
