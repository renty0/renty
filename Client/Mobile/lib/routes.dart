import 'package:renty/auth/login.dart';
import 'package:renty/auth/register.dart';
import 'package:renty/pages/change_password_screen.dart';
import 'package:renty/pages/main_container.dart';
import 'package:renty/onboarding/onboarding.dart';
import 'package:get/get.dart';
import 'auth/email_verification_notification.dart';
import 'auth/forget_password_email.dart';
import 'auth/forget_password_otp.dart';
import 'auth/otp_verification_page.dart';
import 'auth/reset_password.dart';

List<GetPage<dynamic>>? routes = [
  // Onboarding route
  GetPage(name: "/onboarding", page: () => const OnBoarding()),
  // Auth routes
  GetPage(name: "/login", page: () => const login()),
  GetPage(name: "/register", page: () => const register()),

  // Main container with bottom navigation - starts at Home (index 2)
  GetPage(name: "/main", page: () => const MainContainer(initialIndex: 2)),
  GetPage(
    name: "/home",
    page: () => const MainContainer(initialIndex: 2),
  ), // Alias for backwards compatibility
  // Direct page access

  // Add to your routes list
  GetPage(
    name: "/email-verification",
    page: () => EmailVerificationNotification(email: ''),
  ),
  GetPage(
    name: "/otp-verification",
    page: () => OTPVerificationPage(email: ''),
  ),

  // Add to your routes list
  GetPage(
    name: "/forget-password-email",
    page: () => ForgetPasswordEmailPage(),
  ),
  GetPage(
    name: "/forget-password-otp",
    page: () => ForgetPasswordOTPPage(email: ''),
  ),
  GetPage(
    name: "/reset-password",
    page: () => ResetPasswordPage(email: '', verificationCode: ''),
  ),

  GetPage(
    name: "/cart",
    page: () => MainContainer(initialIndex: 3),
  ), // Cart is index 3
  // Cart route
  GetPage(name: "/cart", page: () => MainContainer(initialIndex: 3)),

  GetPage(name: "/change-password", page: () => ChangePasswordScreen()),
];
