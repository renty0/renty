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

  // Main container with bottom navigation (Chat = 0, Marketplace = 1, Home = 2, Search = 3, Profile = 4)
  GetPage(name: "/main", page: () => const MainContainer(initialIndex: 2)),
  GetPage(
    name: "/home",
    page: () => const MainContainer(initialIndex: 2),
  ),
  GetPage(
    name: "/marketplace",
    page: () => const MainContainer(initialIndex: 1),
  ),
  GetPage(
    name: "/search",
    page: () => const MainContainer(initialIndex: 3),
  ),
  GetPage(
    name: "/profile",
    page: () => const MainContainer(initialIndex: 4),
  ),

  // Item detail
  GetPage(
    name: "/item-detail",
    page: () => const ItemDetailPage(),
    transition: Transition.cupertino,
  ),

  // Recommended items
  GetPage(
    name: "/recommended-items",
    page: () => const RecommendedItemsPage(),
    transition: Transition.cupertino,
  ),

  // Email verification
  GetPage(
    name: "/email-verification",
    page: () => EmailVerificationNotification(email: ''),
  ),
  GetPage(
    name: "/otp-verification",
    page: () => OTPVerificationPage(email: ''),
  ),

  // Forgot password flow
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

  // Change password
  GetPage(name: "/change-password", page: () => ChangePasswordScreen()),

  // Edit profile
  GetPage(
    name: "/edit-profile",
    page: () => const EditProfilePage(),
    transition: Transition.cupertino,
  ),

  // Phase 2: Rentals & Orders
  GetPage(
    name: "/my-rentals",
    page: () => const MyRentalsPage(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/my-orders",
    page: () => const MyOrdersPage(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/my-items",
    page: () => const MyItemsPage(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/create-item",
    page: () => const CreateItemPage(),
    transition: Transition.cupertino,
  ),

  // Phase 3: Communication & Engagement
  GetPage(
    name: "/notifications",
    page: () => const NotificationsPage(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/favorites",
    page: () => const FavoritesPage(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/chat-list",
    page: () => const ChatListPage(),
    transition: Transition.cupertino,
  ),

  // Phase 5: Expert / Verification & Wallet
  GetPage(
    name: "/expert-assigned",
    page: () => const ExpertAssignedPage(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/verification-history",
    page: () => const VerificationHistoryPage(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/wallet",
    page: () => const WalletPage(),
    transition: Transition.cupertino,
  ),

  // Support
  GetPage(
    name: "/support",
    page: () => const SupportTicketsPage(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/support/new",
    page: () => const CreateTicketPage(),
    transition: Transition.cupertino,
  ),
  GetPage(
    name: "/support/detail",
    page: () => const TicketDetailPage(),
    transition: Transition.cupertino,
  ),
];
