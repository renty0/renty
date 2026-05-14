import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/register_view.dart';
import 'features/auth/views/verify_email_view.dart';
import 'features/auth/views/forgot_password_view.dart';
import 'features/auth/views/reset_password_view.dart';
import 'features/favorites/controllers/favorites_controller.dart';
import 'features/favorites/views/favorites_view.dart';
import 'features/marketplace/controllers/marketplace_controller.dart';
import 'features/marketplace/views/marketplace_view.dart';
import 'features/marketplace/views/product_detail_view.dart';
import 'features/my_items/controllers/my_items_controller.dart';
import 'features/my_items/views/my_items_view.dart';
import 'features/brands/controllers/brands_controller.dart';
import 'features/brands/views/brands_list_view.dart';
import 'features/categories/controllers/categories_controller.dart';
import 'features/categories/views/categories_list_view.dart';
import 'features/subcategories/controllers/subcategories_controller.dart';
import 'features/subcategories/views/subcategories_list_view.dart';
import 'features/home/views/home_view.dart';
import 'features/chat/controllers/chat_controller.dart';
import 'features/chat/views/chat_list_view.dart';
import 'features/notifications/controllers/notifications_controller.dart';
import 'features/notifications/views/notifications_view.dart';
import 'features/profile/controllers/profile_controller.dart';
import 'features/profile/views/profile_view.dart';
import 'features/rent_requests/controllers/rent_request_controller.dart';
import 'features/rent_requests/views/rent_requests_view.dart';
import 'features/support/controllers/support_controller.dart';
import 'features/support/views/support_list_view.dart';

void main() {
  runApp(const RentyApp());
}

class RentyApp extends StatelessWidget {
  const RentyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Renty',
      debugShowCheckedModeBanner: false,

      // ── Theme matching web design ──
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          error: AppColors.danger,
          surface: AppColors.white,
        ),
        scaffoldBackgroundColor: AppColors.white,
        textTheme: GoogleFonts.alexandriaTextTheme(),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
        ),
      ),

      // ── Initial bindings ──
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.lazyPut(() => MarketplaceController());
      }),

      // ── Routes ──
      initialRoute: '/login',
      getPages: [
        // Auth
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/register', page: () => const RegisterView()),
        GetPage(name: '/verify-email', page: () => const VerifyEmailView()),
        GetPage(name: '/forgot-password', page: () => const ForgotPasswordView()),
        GetPage(name: '/reset-password', page: () => const ResetPasswordView()),

        // Marketplace
        GetPage(
          name: '/',
          page: () => const MarketplaceView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<MarketplaceController>()) {
              Get.put(MarketplaceController());
            }
          }),
        ),
        GetPage(
          name: '/marketplace',
          page: () => const MarketplaceView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<MarketplaceController>()) {
              Get.put(MarketplaceController());
            }
          }),
        ),
        GetPage(
          name: '/marketplace/product/:id',
          page: () => const ProductDetailView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<MarketplaceController>()) {
              Get.put(MarketplaceController());
            }
          }),
        ),

        // Favorites
        GetPage(
          name: '/favorites',
          page: () => const FavoritesView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<FavoritesController>()) {
              Get.put(FavoritesController());
            }
          }),
        ),

        // Rent Requests
        GetPage(
          name: '/rent-requests',
          page: () => const RentRequestsView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<RentRequestController>()) {
              Get.put(RentRequestController());
            }
          }),
        ),

        // My Items
        GetPage(
          name: '/my-items',
          page: () => const MyItemsView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<MyItemsController>()) {
              Get.put(MyItemsController());
            }
          }),
        ),

        // Notifications
        GetPage(
          name: '/notifications',
          page: () => const NotificationsView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<NotificationsController>()) {
              Get.put(NotificationsController());
            }
          }),
        ),

        // Chat
        GetPage(
          name: '/chat',
          page: () => const ChatListView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<ChatController>()) {
              Get.put(ChatController());
            }
          }),
        ),

        // Support
        GetPage(
          name: '/support',
          page: () => const SupportListView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<SupportController>()) {
              Get.put(SupportController());
            }
          }),
        ),

        // Brands
        GetPage(
          name: '/brands',
          page: () => const BrandsListView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<BrandsController>()) {
              Get.put(BrandsController());
            }
          }),
        ),

        // Categories
        GetPage(
          name: '/categories',
          page: () => const CategoriesListView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<CategoriesController>()) {
              Get.put(CategoriesController());
            }
          }),
        ),

        // Subcategories
        GetPage(
          name: '/subcategories',
          page: () => const SubcategoriesListView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<SubcategoriesController>()) {
              Get.put(SubcategoriesController());
            }
          }),
        ),

        // Home / Dashboard
        GetPage(
          name: '/home-dashboard',
          page: () => const HomeView(),
        ),

        // Profile
        GetPage(
          name: '/profile',
          page: () => const ProfileView(),
          binding: BindingsBuilder(() {
            if (!Get.isRegistered<ProfileController>()) {
              Get.put(ProfileController());
            }
          }),
        ),
      ],
    );
  }
}

