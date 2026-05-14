import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../controllers/marketplace_controller.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';

/// Marketplace listing page matching the web:
/// search bar, category chips, subcategory dropdown, product grid, pagination
class MarketplaceView extends StatefulWidget {
  const MarketplaceView({super.key});

  @override
  State<MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends State<MarketplaceView> {
  final _ctrl = Get.find<MarketplaceController>();
  late final FavoritesController _favCtrl;
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    // Lazily register FavoritesController if not yet available
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put(FavoritesController());
    }
    _favCtrl = Get.find<FavoritesController>();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _ctrl.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: NestedScrollView(
        controller: _scrollCtrl,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── App Bar with Search ──
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            expandedHeight: 160,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.receipt_long_outlined),
                tooltip: 'My Requests',
                onPressed: () => Get.toNamed('/rent-requests'),
              ),
              IconButton(
                icon: const Icon(Icons.inventory_2_outlined),
                tooltip: 'My Items',
                onPressed: () => Get.toNamed('/my-items'),
              ),
              IconButton(
                icon: const Icon(Icons.chat_outlined),
                tooltip: 'Chat',
                onPressed: () => Get.toNamed('/chat'),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
                onPressed: () => Get.toNamed('/notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                tooltip: 'Favorites',
                onPressed: () => Get.toNamed('/favorites'),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                tooltip: 'Profile',
                onPressed: () => Get.toNamed('/profile'),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.admin_panel_settings_outlined),
                tooltip: 'Manage',
                onSelected: (route) => Get.toNamed(route),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: '/home-dashboard', child: Text('Dashboard')),
                  const PopupMenuItem(value: '/brands', child: Text('Brands')),
                  const PopupMenuItem(value: '/categories', child: Text('Categories')),
                  const PopupMenuItem(value: '/subcategories', child: Text('Subcategories')),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0C295E), Color(0xFF183458)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marketplace',
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.white,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find the perfect rental for you',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.gray300,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Search bar
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => _ctrl.searchTerm.value = v,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              hintStyle: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white.withValues(alpha: 0.5),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.white.withValues(alpha: 0.6),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Categories chips ──
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Obx(() {
                  if (_ctrl.isLoadingCategories.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 44,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        CategoryChip(
                          label: 'All',
                          isActive: _ctrl.selectedCategoryId.value == null,
                          onTap: () => _ctrl.selectedCategoryId.value = null,
                        ),
                        const SizedBox(width: 10),
                        ..._ctrl.categories.map((cat) {
                          final id = cat['id'] as int?;
                          final name =
                              cat['nameEn'] ?? cat['nameAr'] ?? 'Category';
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: CategoryChip(
                              label: name,
                              isActive:
                                  _ctrl.selectedCategoryId.value == id,
                              onTap: () =>
                                  _ctrl.selectedCategoryId.value = id,
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),

                // ── Subcategory dropdown ──
                Obx(() {
                  if (_ctrl.subcategories.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gray200),
                      ),
                      child: DropdownButton<int?>(
                        value: _ctrl.selectedSubcategoryId.value,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        hint: Text(
                          'All Subcategories',
                          style: AppTextStyles.bodySmall,
                        ),
                        style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Subcategories'),
                          ),
                          ..._ctrl.subcategories.map((sub) {
                            final id = sub['id'] as int?;
                            final name =
                                sub['nameEn'] ?? sub['nameAr'] ?? '';
                            return DropdownMenuItem(
                              value: id,
                              child: Text(name),
                            );
                          }),
                        ],
                        onChanged: (v) =>
                            _ctrl.selectedSubcategoryId.value = v,
                      ),
                    ),
                  );
                }),

                // ── Results count ──
                Obx(() => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Row(
                        children: [
                          Text(
                            'Products',
                            style: AppTextStyles.heading3.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              '${_ctrl.totalCount.value} results',
                              style: AppTextStyles.captionSmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],

        // ── Product Grid ──
        body: Obx(() {
          if (_ctrl.isLoadingItems.value && _ctrl.items.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_ctrl.items.isEmpty) {
            return _buildEmptyState();
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemCount: _ctrl.items.length + (_ctrl.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _ctrl.items.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final item = _ctrl.items[index];
              final itemId = (item['id'] ?? '').toString();
              return Obx(() => ProductCard(
                item: item,
                isFavorite: _favCtrl.isFavorite(itemId),
                onFavoriteToggle: () => _favCtrl.toggleFavorite(itemId),
                onTap: () {
                  if (itemId.isNotEmpty) {
                    Get.toNamed('/marketplace/product/$itemId');
                  }
                },
              ));
            },
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_dissatisfied_outlined,
              size: 64,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 20),
            Text(
              'No products found',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your filters',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                _searchCtrl.clear();
                _ctrl.resetFilters();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('View All Products'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
