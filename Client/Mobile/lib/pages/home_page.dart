import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/controllers/home_controller.dart';
import 'package:renty/core/controllers/main_navigation_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : AppColor.backgroundcolor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColor.fourthColor,
          onRefresh: controller.refreshHome,
          child: CustomScrollView(
            slivers: [
              // ── App Bar ──
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColor.primaryColor, AppColor.fourthColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.home_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Renty',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColor.primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? Colors.white70 : AppColor.primaryColor,
                    ),
                    onPressed: () => Get.toNamed('/notifications'),
                  ),
                ],
              ),

              // ── Body ──
              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColor.fourthColor,
                      ),
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: controller.refreshHome,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.fourthColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Welcome Banner Carousel ──
                    _buildWelcomeBanner(isDark, controller),
                    const SizedBox(height: 24),

                    // ── Categories Section ──
                    if (controller.categories.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Categories',
                        isDark,
                        onSeeAll: () {
                          // Switch to Marketplace tab (index 1)
                          try {
                            final nav = Get.find<MainNavigationController>();
                            nav.currentIndex.value = 1;
                          } catch (_) {}
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildCategoriesList(controller.categories, isDark),
                      const SizedBox(height: 28),
                    ],

                    // ── Featured Items ──
                    if (controller.items.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Recently Added',
                        isDark,
                        onSeeAll: () {
                          // Switch to Marketplace tab (index 1)
                          try {
                            final nav = Get.find<MainNavigationController>();
                            nav.currentIndex.value = 1;
                          } catch (_) {}
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildItemsGrid(controller.items, isDark),
                      const SizedBox(height: 24),
                    ],

                    // Empty state
                    if (controller.items.isEmpty &&
                        controller.categories.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No items available yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back soon for new rental items!',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 100), // Bottom padding for nav bar
                  ]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(bool isDark, HomeController controller) {
    return _HomeBannerCarousel(isDark: isDark, controller: controller);
  }

  Widget _buildSectionHeader(
    String title,
    bool isDark, {
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColor.primaryColor,
              letterSpacing: -0.3,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'See All',
                style: TextStyle(
                  color: AppColor.fourthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
    List<ProductCategoryDto> categories,
    bool isDark,
  ) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              Get.toNamed('/marketplace', arguments: {'categoryId': cat.id});
            },
            child: Container(
              width: 90,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColor.fourthColor.withOpacity(0.15)
                          : AppColor.fourthColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColor.fourthColor.withOpacity(0.2),
                      ),
                    ),
                    child: cat.logoUrl != null && cat.logoUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: cat.logoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Icon(
                                Icons.category_outlined,
                                color: AppColor.fourthColor,
                                size: 28,
                              ),
                              errorWidget: (_, __, ___) => Icon(
                                Icons.category_outlined,
                                color: AppColor.fourthColor,
                                size: 28,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.category_outlined,
                            color: AppColor.fourthColor,
                            size: 28,
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat.nameEn ?? cat.nameAr ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColor.darkText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemsGrid(List<ItemListDto> items, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _ItemCard(item: items[index], isDark: isDark);
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ItemListDto item;
  final bool isDark;

  const _ItemCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/item-detail', arguments: {'itemId': item.id}),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    item.primaryImage != null && item.primaryImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.primaryImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE2E8F0),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE2E8F0),
                              child: Icon(
                                Icons.image_outlined,
                                color: isDark
                                    ? const Color(0xFF475569)
                                    : const Color(0xFF94A3B8),
                                size: 40,
                              ),
                            ),
                          )
                        : Container(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE2E8F0),
                            child: Icon(
                              Icons.image_outlined,
                              color: isDark
                                  ? const Color(0xFF475569)
                                  : const Color(0xFF94A3B8),
                              size: 40,
                            ),
                          ),
                    // Type badge
                    if (item.type != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.fourthColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.type!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titleEn ?? item.titleAr ?? 'Untitled',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColor.darkText,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Price
                    if (item.dailyPrice != null)
                      Text(
                        '${item.dailyPrice!.toStringAsFixed(0)} EGP/day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColor.fourthColor,
                        ),
                      ),
                    const SizedBox(height: 4),
                    // Rating + City
                    Row(
                      children: [
                        if (item.avgRating != null && item.avgRating! > 0) ...[
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFF1A1A1A),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            item.avgRating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white70
                                  : AppColor.mediumText,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (item.city != null)
                          Expanded(
                            child: Text(
                              item.city!,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white54
                                    : AppColor.lightText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Auto-scrolling Banner Carousel ──────────────────────────────────────────

class _HomeBannerCarousel extends StatefulWidget {
  final bool isDark;
  final HomeController controller;

  const _HomeBannerCarousel({required this.isDark, required this.controller});

  @override
  State<_HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<_HomeBannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  // We use a large virtual count for infinite-loop effect
  static const int _virtualCount = 10000;
  static const int _realCount = 2; // main card + recommended card

  @override
  void initState() {
    super.initState();
    final initPage = (_virtualCount ~/ 2).round();
    _pageController = PageController(initialPage: initPage);
    _currentPage = initPage % _realCount;
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) {
              setState(() => _currentPage = idx % _realCount);
            },
            itemBuilder: (context, idx) {
              final page = idx % _realCount;
              if (page == 0) {
                return _buildMainCard(widget.isDark);
              } else {
                return _buildRecommendedCard(widget.isDark);
              }
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_realCount, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF2563EB)
                    : (widget.isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMainCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A365D), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A365D).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rent Anything,\nAnytime.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thousands of items available near you',
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              try {
                final nav = Get.find<MainNavigationController>();
                nav.currentIndex.value = 3; // Search tab
              } catch (_) {}
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: Colors.white.withOpacity(0.85),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Search for items to rent...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A365D), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A365D).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Obx(() {
          final recs = widget.controller.recommendations;
          if (recs.isEmpty) {
            return _buildEmptyRecommendation();
          }
          return _buildFeaturedRecommendation(recs.first);
        }),
      ),
    );
  }

  Widget _buildEmptyRecommendation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF93C5FD),
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Discover More',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Browse items to unlock personalized\nrecommendations just for you',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.75),
              height: 1.4,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              try {
                final nav = Get.find<MainNavigationController>();
                nav.currentIndex.value = 1;
              } catch (_) {}
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Explore Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Color(0xFF1A365D),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedRecommendation(RecommendationEntryDto featured) {
    final item = featured.item;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (item?.image != null && item!.image!.isNotEmpty)
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                const Color(0xFF1A365D).withOpacity(0.65),
                BlendMode.srcOver,
              ),
              child: CachedNetworkImage(
                imageUrl: item.image!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF93C5FD),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Picked For You',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.85),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item?.title ?? 'Recommended Item',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  if (item?.price != null)
                    Text(
                      '${item!.price!.toStringAsFixed(0)} EGP/day',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF93C5FD),
                      ),
                    ),
                  if (item?.city != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      item!.city!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed(
                      '/item-detail',
                      arguments: {'itemId': item?.id},
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'View',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
