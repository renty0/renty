import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/blocs/blocs.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:renty/pages/marketplace_widgets/mp_filter_sheet.dart';
import 'package:renty/pages/marketplace_widgets/mp_item_card.dart';
import 'package:renty/pages/marketplace_widgets/mp_search_bar.dart';
import 'package:renty/utils/language_manager.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MarketplaceCubit()
        ..loadCategories()
        ..loadItems(),
      child: const _MarketplaceContent(),
    );
  }
}

class _MarketplaceContent extends StatelessWidget {
  const _MarketplaceContent();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MarketplaceCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            _Header(controller: cubit, isDark: isDark),

            // ── Items Grid ──────────────────────────────────────────
            Expanded(
              child: BlocBuilder<MarketplaceCubit, MarketplaceState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.fourthColor,
                      ),
                    );
                  }
                  if (state.errorMessage.isNotEmpty) {
                    return _ErrorState(controller: cubit, state: state);
                  }
                  if (state.items.isEmpty) {
                    return _EmptyState(controller: cubit, isDark: isDark);
                  }
                  return _ItemsGrid(
                    controller: cubit,
                    state: state,
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header (search + chips + sort/filter buttons) ───────────────────────────

class _Header extends StatelessWidget {
  final MarketplaceCubit controller;
  final bool isDark;
  const _Header({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row + action buttons
          Row(
            children: [
              Text(
                'Marketplace'.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColor.primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              _SortButton(controller: controller, isDark: isDark),
              const SizedBox(width: 4),
              _FilterButton(controller: controller, isDark: isDark),
            ],
          ),
          const SizedBox(height: 10),

          // Search bar
          MpSearchBar(controller: controller, isDark: isDark),
          const SizedBox(height: 10),

          // Results count
          BlocBuilder<MarketplaceCubit, MarketplaceState>(
            builder: (context, state) => Text(
              '@count items found'
                  .trParams({'count': state.totalItems.toString()}),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : AppColor.mediumText,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Category chips
          _CategoryChips(controller: controller, isDark: isDark),

          // Subcategory chips (appear dynamically)
          BlocBuilder<MarketplaceCubit, MarketplaceState>(
            builder: (context, state) => state.subcategories.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      _SubcategoryChips(
                        controller: controller,
                        state: state,
                        isDark: isDark,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Category chips ───────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final MarketplaceCubit controller;
  final bool isDark;
  const _CategoryChips({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketplaceCubit, MarketplaceState>(
      builder: (context, state) {
        final cats = state.categories;
        return SizedBox(
          height: 34,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cats.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                final isSelected = state.selectedCategoryId == null;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text('All'.tr),
                    selected: isSelected,
                    onSelected: (_) => controller.setCategory(null),
                    selectedColor: AppColor.fourthColor,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : AppColor.mediumText),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    backgroundColor:
                        isDark ? Colors.grey[800] : Colors.grey[100],
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              }
              final cat = cats[i - 1];
              final isSelected = state.selectedCategoryId == cat.id;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(
                    LanguageManager.isArabic()
                        ? (cat.nameAr ?? cat.nameEn ?? '')
                        : (cat.nameEn ?? cat.nameAr ?? ''),
                  ),
                  selected: isSelected,
                  onSelected: (_) => controller.setCategory(cat.id),
                  selectedColor: AppColor.fourthColor,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : AppColor.mediumText),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  backgroundColor:
                      isDark ? Colors.grey[800] : Colors.grey[100],
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Subcategory chips ─────────────────────────────────────────────────────────

class _SubcategoryChips extends StatelessWidget {
  final MarketplaceCubit controller;
  final MarketplaceState state;
  final bool isDark;
  const _SubcategoryChips({
    required this.controller,
    required this.state,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.subcategories.length,
        itemBuilder: (_, i) {
          final sub = state.subcategories[i];
          final isSelected = state.selectedSubcategoryId == sub.id;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(
                LanguageManager.isArabic()
                    ? (sub.nameAr ?? sub.nameEn ?? '')
                    : (sub.nameEn ?? sub.nameAr ?? ''),
              ),
              selected: isSelected,
              onSelected: (_) {
                controller.setSubcategory(isSelected ? null : sub.id);
                controller.applyFilters();
              },
              selectedColor: AppColor.primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : AppColor.mediumText),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              backgroundColor:
                  isDark ? Colors.grey[800] : Colors.grey[100],
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        },
      ),
    );
  }
}

// ── Sort popup ────────────────────────────────────────────────────────────────

class _SortButton extends StatelessWidget {
  final MarketplaceCubit controller;
  final bool isDark;
  const _SortButton({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketplaceCubit, MarketplaceState>(
      builder: (context, state) {
        final active = state.selectedSort;
        return PopupMenuButton<String>(
          icon: Icon(
            Icons.sort_rounded,
            color: isDark ? Colors.white70 : AppColor.primaryColor,
          ),
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 6,
          onSelected: controller.setSort,
          itemBuilder: (_) => [
            _sortItem('newest', 'Newest First'.tr, Icons.schedule, active,
                isDark),
            _sortItem('price_low', 'Price: Low to High'.tr,
                Icons.arrow_upward, active, isDark),
            _sortItem('price_high', 'Price: High to Low'.tr,
                Icons.arrow_downward, active, isDark),
            _sortItem('rating', 'Highest Rated'.tr, Icons.star_rounded,
                active, isDark),
          ],
        );
      },
    );
  }

  PopupMenuItem<String> _sortItem(
    String value,
    String label,
    IconData icon,
    String active,
    bool dark,
  ) {
    final on = value == active;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: on
                ? AppColor.fourthColor
                : (dark ? Colors.white54 : Colors.grey[500]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                color: on
                    ? AppColor.fourthColor
                    : (dark ? Colors.white : AppColor.darkText),
              ),
            ),
          ),
          if (on)
            Icon(Icons.check_rounded, size: 18, color: AppColor.fourthColor),
        ],
      ),
    );
  }
}

// ── Filter button ─────────────────────────────────────────────────────────────

class _FilterButton extends StatelessWidget {
  final MarketplaceCubit controller;
  final bool isDark;
  const _FilterButton({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketplaceCubit, MarketplaceState>(
      builder: (context, state) {
        final count = state.activeFilterCount;
        return Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.tune_rounded,
                color: isDark ? Colors.white70 : AppColor.primaryColor,
              ),
              onPressed: () => MpFilterSheet.show(context, controller),
            ),
            if (count > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColor.fourthColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Items grid ────────────────────────────────────────────────────────────────

class _ItemsGrid extends StatelessWidget {
  final MarketplaceCubit controller;
  final MarketplaceState state;
  final bool isDark;
  const _ItemsGrid({
    required this.controller,
    required this.state,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollEndNotification && n.metrics.extentAfter < 200) {
          controller.loadNextPage();
        }
        return false;
      },
      child: RefreshIndicator(
        color: AppColor.fourthColor,
        onRefresh: () => controller.loadItems(reset: true),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: state.items.length + (state.isLoadingMore ? 2 : 0),
          itemBuilder: (_, i) {
            if (i >= state.items.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return MpItemCard(item: state.items[i], isDark: isDark);
          },
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final MarketplaceCubit controller;
  final MarketplaceState state;
  const _ErrorState({required this.controller, required this.state});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(state.errorMessage, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => controller.loadItems(),
            icon: const Icon(Icons.refresh),
            label: Text('Retry'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.fourthColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final MarketplaceCubit controller;
  final bool isDark;
  const _EmptyState({required this.controller, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No items found'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text('Try adjusting your filters'.tr,
              style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 16),
          TextButton(
            onPressed: controller.clearFilters,
            child: Text('Clear Filters'.tr),
          ),
        ],
      ),
    );
  }
}
