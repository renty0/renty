import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/blocs/blocs.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:renty/pages/home_widgets/home_categories.dart';
import 'package:renty/pages/home_widgets/home_destinations.dart';
import 'package:renty/pages/home_widgets/home_features.dart';
import 'package:renty/pages/home_widgets/home_hero.dart';
import 'package:renty/pages/home_widgets/home_how_it_works.dart';
import 'package:renty/pages/home_widgets/home_new_items.dart';
import 'package:renty/pages/home_widgets/home_popular.dart';
import 'package:renty/pages/home_widgets/home_section_header.dart';
import 'package:renty/pages/home_widgets/home_trust.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit()..loadHomeData(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  void _goToMarketplace(BuildContext context) {
    try {
      context.read<NavigationCubit>().switchToTab(1);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColor.fourthColor,
          onRefresh: () => context.read<HomeCubit>().refreshHome(),
          child: CustomScrollView(
            slivers: [
              // ── AppBar ──────────────────────────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor:
                    isDark ? const Color(0xFF1E1E1E) : Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColor.primaryColor,
                              AppColor.fourthColor
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.home_outlined,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RENTY',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: isDark
                                  ? Colors.white
                                  : AppColor.primaryColor,
                            ),
                          ),
                          Text(
                            'Borrow. Lend. Save.'.tr,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white54
                                  : AppColor.grey,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _NotificationBell(isDark: isDark),
                    ],
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────────
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColor.fourthColor,
                        ),
                      ),
                    );
                  } else if (state.errorMessage.isNotEmpty) {
                    return SliverFillRemaining(
                      child: _buildError(context, state.errorMessage),
                    );
                  } else {
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        // 1. Hero Carousel
                        HomeHero(suggestedItems: state.suggestedItems),
                        const SizedBox(height: 28),

                        // 2. Features
                        HomeSectionHeader(
                          badge: 'WHY RENTY'.tr,
                          title: 'Built for You'.tr,
                          subtitle: 'Trusted, affordable and fast'.tr,
                        ),
                        const SizedBox(height: 12),
                        const HomeFeatures(),
                        const SizedBox(height: 28),

                        // 3. Categories
                        if (state.categories.isNotEmpty) ...[
                          HomeSectionHeader(
                            badge: 'CATEGORIES'.tr,
                            title: 'Browse by Category'.tr,
                            onSeeAll: () => _goToMarketplace(context),
                          ),
                          const SizedBox(height: 12),
                          HomeCategories(categories: state.categories),
                          const SizedBox(height: 28),
                        ],

                        // 4. Popular Items
                        if (state.popularItems.isNotEmpty) ...[
                          HomeSectionHeader(
                            badge: 'TRENDING'.tr,
                            title: 'Most Popular'.tr,
                            subtitle: 'What everyone is renting'.tr,
                            onSeeAll: () => _goToMarketplace(context),
                          ),
                          const SizedBox(height: 12),
                          HomePopular(items: state.popularItems),
                          const SizedBox(height: 28),
                        ],

                        // 5. New Items
                        if (state.newItems.isNotEmpty) ...[
                          HomeSectionHeader(
                            badge: 'JUST ADDED'.tr,
                            title: 'New Arrivals'.tr,
                            onSeeAll: () => _goToMarketplace(context),
                          ),
                          const SizedBox(height: 12),
                          HomeNewItems(items: state.newItems),
                          const SizedBox(height: 28),
                        ],

                        // 6. Top Destinations
                        HomeSectionHeader(
                          badge: 'TOP SPOTS'.tr,
                          title: 'Top Destinations'.tr,
                          subtitle: 'Popular rental locations in Egypt'.tr,
                        ),
                        const SizedBox(height: 12),
                        const HomeDestinations(),
                        const SizedBox(height: 28),

                        // 7. How It Works
                        HomeSectionHeader(
                          badge: 'HOW IT WORKS'.tr,
                          title: 'Rent in 3 Steps'.tr,
                        ),
                        const SizedBox(height: 16),
                        const HomeHowItWorks(),
                        const SizedBox(height: 28),

                        // 8. Trust & Security
                        const HomeTrust(),
                        const SizedBox(height: 100),
                      ]),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<HomeCubit>().refreshHome(),
            icon: const Icon(Icons.refresh),
            label: Text('Retry'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.fourthColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Isolated StatelessWidget for the notification bell with BLoC.
class _NotificationBell extends StatelessWidget {
  final bool isDark;
  const _NotificationBell({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBadgeCubit, NotificationBadgeState>(
      builder: (context, badgeState) {
        final badge = badgeState.unreadCount;
        return GestureDetector(
          onTap: () {
            context.read<NotificationBadgeCubit>().markAllSeen();
            AppNavigator.pushNamed('/notifications');
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    badge > 0
                        ? Icons.notifications_active
                        : Icons.notifications_outlined,
                    key: ValueKey(badge > 0),
                    color: badge > 0
                        ? AppColor.fourthColor
                        : (isDark ? Colors.white70 : AppColor.primaryColor),
                    size: 26,
                  ),
                ),
                if (badge > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade600, Colors.red.shade400],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
