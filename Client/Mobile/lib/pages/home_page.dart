import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/controllers/home_controller.dart';
import 'package:renty/core/controllers/main_navigation_controller.dart';
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
    final controller = Get.put(HomeController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColor.fourthColor,
          onRefresh: controller.refreshHome,
          child: CustomScrollView(
            slivers: [
              // ── AppBar ──────────────────────────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColor.primaryColor, AppColor.fourthColor],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.home_outlined, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Renty'.tr,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColor.primaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: isDark ? Colors.white70 : AppColor.primaryColor,
                          ),
                          onPressed: () => Get.toNamed('/notifications'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Body ────────────────────────────────────────────
              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColor.fourthColor)),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return SliverFillRemaining(child: _buildError(controller));
                }

                return SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Hero Carousel (hero banner + recommended items)
                    Obx(() => HomeHero(suggestedItems: controller.suggestedItems.toList())),
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
                    HomeSectionHeader(
                      badge: 'CATEGORIES'.tr,
                      title: 'Browse by Category'.tr,
                      onSeeAll: () => _goToMarketplace(),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => controller.categories.isNotEmpty
                        ? HomeCategories(categories: controller.categories.toList())
                        : const SizedBox.shrink()),
                    const SizedBox(height: 28),

                    // 5. Popular Items
                    Obx(() => controller.popularItems.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HomeSectionHeader(
                                badge: 'TRENDING'.tr,
                                title: 'Most Popular'.tr,
                                subtitle: 'What everyone is renting'.tr,
                                onSeeAll: () => _goToMarketplace(),
                              ),
                              const SizedBox(height: 12),
                              HomePopular(items: controller.popularItems.toList()),
                              const SizedBox(height: 28),
                            ],
                          )
                        : const SizedBox.shrink()),

                    // 6. New Items
                    Obx(() => controller.newItems.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HomeSectionHeader(
                                badge: 'JUST ADDED'.tr,
                                title: 'New Arrivals'.tr,
                                onSeeAll: () => _goToMarketplace(),
                              ),
                              const SizedBox(height: 12),
                              HomeNewItems(items: controller.newItems.toList()),
                              const SizedBox(height: 28),
                            ],
                          )
                        : const SizedBox.shrink()),

                    // 7. Top Destinations
                    HomeSectionHeader(
                      badge: 'TOP SPOTS'.tr,
                      title: 'Top Destinations'.tr,
                      subtitle: 'Popular rental locations in Egypt'.tr,
                    ),
                    const SizedBox(height: 12),
                    const HomeDestinations(),
                    const SizedBox(height: 28),

                    // 8. How It Works
                    HomeSectionHeader(
                      badge: 'HOW IT WORKS'.tr,
                      title: 'Rent in 3 Steps'.tr,
                    ),
                    const SizedBox(height: 16),
                    const HomeHowItWorks(),
                    const SizedBox(height: 28),

                    // 9. Trust & Security
                    const HomeTrust(),
                    const SizedBox(height: 100),
                  ]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _goToMarketplace() {
    try {
      Get.find<MainNavigationController>().currentIndex.value = 1;
    } catch (_) {}
  }

  Widget _buildError(HomeController controller) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.refreshHome,
            icon: const Icon(Icons.refresh),
            label: Text('Retry'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.fourthColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
