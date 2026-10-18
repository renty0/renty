import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:renty/auth/login.dart';
import 'package:renty/auth/register.dart';
import 'package:renty/pages/change_password_screen.dart';
import 'package:renty/pages/main_container.dart';
import 'package:renty/pages/item_detail_page.dart';
import 'package:renty/pages/my_rentals_page.dart';
import 'package:renty/pages/my_orders_page.dart';
import 'package:renty/pages/my_items_page.dart';
import 'package:renty/pages/create_item_page.dart';
import 'package:renty/pages/edit_profile_page.dart';
import 'package:renty/pages/recommended_items_page.dart';
import 'package:renty/pages/notifications_page.dart';
import 'package:renty/pages/favorites_page.dart';
import 'package:renty/pages/chat_list_page.dart';
import 'package:renty/pages/expert_assigned_page.dart';
import 'package:renty/pages/verification_history_page.dart';
import 'package:renty/pages/wallet_page.dart';
import 'package:renty/pages/support_tickets_page.dart';
import 'package:renty/pages/create_ticket_page.dart';
import 'package:renty/pages/ticket_detail_page.dart';
import 'package:renty/onboarding/onboarding.dart';
import 'auth/email_verification_notification.dart';
import 'auth/forget_password_email.dart';
import 'auth/forget_password_otp.dart';
import 'auth/otp_verification_page.dart';
import 'auth/reset_password.dart';

/// Centralized Flutter route generation — replaces GetPage table
class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Onboarding
      case "/onboarding":
        return MaterialPageRoute(
          builder: (_) => const OnBoarding(),
          settings: settings,
        );

      // Auth
      case "/login":
        return MaterialPageRoute(
          builder: (_) => const login(),
          settings: settings,
        );
      case "/register":
        return MaterialPageRoute(
          builder: (_) => const register(),
          settings: settings,
        );

      // Main container with bottom navigation
      case "/main":
        return MaterialPageRoute(
          builder: (_) => const MainContainer(initialIndex: 2),
          settings: settings,
        );
      case "/home":
        return MaterialPageRoute(
          builder: (_) => const MainContainer(initialIndex: 2),
          settings: settings,
        );
      case "/marketplace":
        return MaterialPageRoute(
          builder: (_) => const MainContainer(initialIndex: 1),
          settings: settings,
        );
      case "/search":
        return MaterialPageRoute(
          builder: (_) => const MainContainer(initialIndex: 3),
          settings: settings,
        );
      case "/profile":
        return MaterialPageRoute(
          builder: (_) => const MainContainer(initialIndex: 4),
          settings: settings,
        );

      // Item detail
      case "/item-detail":
        return CupertinoPageRoute(
          builder: (_) => const ItemDetailPage(),
          settings: settings,
        );

      // Recommended items
      case "/recommended-items":
        return CupertinoPageRoute(
          builder: (_) => const RecommendedItemsPage(),
          settings: settings,
        );

      // Email verification
      case "/email-verification":
        final email =
            settings.arguments is String ? settings.arguments as String : '';
        return MaterialPageRoute(
          builder: (_) => EmailVerificationNotification(email: email),
          settings: settings,
        );
      case "/otp-verification":
        final email =
            settings.arguments is String ? settings.arguments as String : '';
        return MaterialPageRoute(
          builder: (_) => OTPVerificationPage(email: email),
          settings: settings,
        );

      // Forgot password flow
      case "/forget-password-email":
        return MaterialPageRoute(
          builder: (_) => ForgetPasswordEmailPage(),
          settings: settings,
        );
      case "/forget-password-otp":
        final email =
            settings.arguments is String ? settings.arguments as String : '';
        return MaterialPageRoute(
          builder: (_) => ForgetPasswordOTPPage(email: email),
          settings: settings,
        );
      case "/reset-password":
        String email = '';
        String code = '';
        if (settings.arguments is Map) {
          final map = settings.arguments as Map;
          email = map['email']?.toString() ?? '';
          code = map['verificationCode']?.toString() ?? '';
        }
        return MaterialPageRoute(
          builder: (_) =>
              ResetPasswordPage(email: email, verificationCode: code),
          settings: settings,
        );

      // Change password
      case "/change-password":
        return MaterialPageRoute(
          builder: (_) => ChangePasswordScreen(),
          settings: settings,
        );

      // Edit profile
      case "/edit-profile":
        return CupertinoPageRoute(
          builder: (_) => const EditProfilePage(),
          settings: settings,
        );

      // Rentals & Orders
      case "/my-rentals":
        return CupertinoPageRoute(
          builder: (_) => const MyRentalsPage(),
          settings: settings,
        );
      case "/my-orders":
        return CupertinoPageRoute(
          builder: (_) => const MyOrdersPage(),
          settings: settings,
        );
      case "/my-items":
        return CupertinoPageRoute(
          builder: (_) => const MyItemsPage(),
          settings: settings,
        );
      case "/create-item":
        return CupertinoPageRoute(
          builder: (_) => const CreateItemPage(),
          settings: settings,
        );

      // Communication & Engagement
      case "/notifications":
        return CupertinoPageRoute(
          builder: (_) => const NotificationsPage(),
          settings: settings,
        );
      case "/favorites":
        return CupertinoPageRoute(
          builder: (_) => const FavoritesPage(),
          settings: settings,
        );
      case "/chat-list":
        return CupertinoPageRoute(
          builder: (_) => const ChatListPage(),
          settings: settings,
        );

      // Expert / Verification & Wallet
      case "/expert-assigned":
        return CupertinoPageRoute(
          builder: (_) => const ExpertAssignedPage(),
          settings: settings,
        );
      case "/verification-history":
        return CupertinoPageRoute(
          builder: (_) => const VerificationHistoryPage(),
          settings: settings,
        );
      case "/wallet":
        return CupertinoPageRoute(
          builder: (_) => const WalletPage(),
          settings: settings,
        );

      // Support
      case "/support":
        return CupertinoPageRoute(
          builder: (_) => const SupportTicketsPage(),
          settings: settings,
        );
      case "/support/new":
        return CupertinoPageRoute(
          builder: (_) => const CreateTicketPage(),
          settings: settings,
        );
      case "/support/detail":
        return CupertinoPageRoute(
          builder: (_) => const TicketDetailPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
