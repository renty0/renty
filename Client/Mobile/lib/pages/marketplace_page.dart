import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/controllers/marketplace_controller.dart';
import 'package:renty/pages/marketplace_widgets/mp_filter_sheet.dart';
import 'package:renty/pages/marketplace_widgets/mp_item_card.dart';
import 'package:renty/pages/marketplace_widgets/mp_search_bar.dart';
import 'package:renty/utils/language_manager.dart';

class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarketplaceController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            _Header(controller: controller, isDark: isDark),

            // ── Items Grid ──────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColor.fourthColor));
                }
                if (controller.errorMessage.value.isNotEmpty) {
                  return _ErrorState(controller: controller);
                }
                if (controller.items.isEmpty) {
                  return _EmptyState(controller: controller, isDark: isDark);
                }
                return _ItemsGrid(controller: controller, isDark: isDark);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header (search + chips + sort/filter buttons) ───────────────────────────

class _Header extends StatelessWidget {
  final MarketplaceController controller;
  final bool isDark;
  const _Header({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row + action buttons
          Row(
            children: [
              Text('Marketplace'.tr,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColor.primaryColor, letterSpacing: -0.5)),
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
          Obx(() => Text(
            '@count items found'.trParams({'count': controller.totalItems.value.toString()}),
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : AppColor.mediumText),
          )),
          const SizedBox(height: 8),

          // Category chips
          _CategoryChips(controller: controller, isDark: isDark),

          // Subcategory chips (appear dynamically)
          Obx(() => controller.subcategories.isNotEmpty
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 6),
                  _SubcategoryChips(controller: controller, isDark: isDark),
                ])
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

// ── Category chips ───────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final MarketplaceController controller;
  final bool isDark;
  const _CategoryChips({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cats = controller.categories;
      return SizedBox(
        height: 34,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: cats.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) {
              return Obx(() => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text('All'.tr),
                  selected: controller.selectedCategoryId.value == null,
                  onSelected: (_) => controller.setCategory(null),
                  selectedColor: AppColor.fourthColor,
                  labelStyle: TextStyle(
                    color: controller.selectedCategoryId.value == null ? Colors.white : (isDark ? Colors.white70 : AppColor.mediumText),
                    fontWeight: FontWeight.w600, fontSize: 12,
                  ),
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ));
            }
            final cat = cats[i - 1];
            return Obx(() => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(
                  LanguageManager.isArabic()
                      ? (cat.nameAr ?? cat.nameEn ?? '')
                      : (cat.nameEn ?? cat.nameAr ?? ''),
                ),
                selected: controller.selectedCategoryId.value == cat.id,
                onSelected: (_) => controller.setCategory(cat.id),
                selectedColor: AppColor.fourthColor,
                labelStyle: TextStyle(
                  color: controller.selectedCategoryId.value == cat.id ? Colors.white : (isDark ? Colors.white70 : AppColor.mediumText),
                  fontWeight: FontWeight.w600, fontSize: 12,
                ),
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ));
          },
        ),
      );
    });
  }
}

// ── Subcategory chips ─────────────────────────────────────────────────────────

class _SubcategoryChips extends StatelessWidget {
  final MarketplaceController controller;
  final bool isDark;
  const _SubcategoryChips({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.subcategories.length,
        itemBuilder: (_, i) {
          final sub = controller.subcategories[i];
          return Obx(() => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(
                LanguageManager.isArabic()
                    ? (sub.nameAr ?? sub.nameEn ?? '')
                    : (sub.nameEn ?? sub.nameAr ?? ''),
              ),
              selected: controller.selectedSubcategoryId.value == sub.id,
              onSelected: (_) {
                controller.selectedSubcategoryId.value =
                    controller.selectedSubcategoryId.value == sub.id ? null : sub.id;
                controller.applyFilters();
              },
              selectedColor: AppColor.primaryColor,
              labelStyle: TextStyle(
                color: controller.selectedSubcategoryId.value == sub.id ? Colors.white : (isDark ? Colors.white70 : AppColor.mediumText),
                fontWeight: FontWeight.w600, fontSize: 12,
              ),
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ));
        },
      ),
    );
  }
}

// ── Sort popup ────────────────────────────────────────────────────────────────

class _SortButton extends StatelessWidget {
  final MarketplaceController controller;
  final bool isDark;
  const _SortButton({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.selectedSort.value;
      return PopupMenuButton<String>(
        icon: Icon(Icons.sort_rounded, color: isDark ? Colors.white70 : AppColor.primaryColor),
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 6,
        onSelected: controller.setSort,
        itemBuilder: (_) => [
          _sortItem('newest',     'Newest First'.tr,        Icons.schedule,       active, isDark),
          _sortItem('price_low',  'Price: Low to High'.tr,  Icons.arrow_upward,   active, isDark),
          _sortItem('price_high', 'Price: High to Low'.tr,  Icons.arrow_downward, active, isDark),
          _sortItem('rating',     'Highest Rated'.tr,       Icons.star_rounded,   active, isDark),
        ],
      );
    });
  }

  PopupMenuItem<String> _sortItem(String value, String label, IconData icon, String active, bool dark) {
    final on = value == active;
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 18, color: on ? AppColor.fourthColor : (dark ? Colors.white54 : Colors.grey[500])),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: TextStyle(
          fontWeight: on ? FontWeight.w700 : FontWeight.w500,
          color: on ? AppColor.fourthColor : (dark ? Colors.white : AppColor.darkText),
        ))),
        if (on) Icon(Icons.check_rounded, size: 18, color: AppColor.fourthColor),
      ]),
    );
  }
}

// ── Filter button ─────────────────────────────────────────────────────────────

class _FilterButton extends StatelessWidget {
  final MarketplaceController controller;
  final bool isDark;
  const _FilterButton({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.activeFilterCount;
      return Stack(
        children: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: isDark ? Colors.white70 : AppColor.primaryColor),
            onPressed: () => MpFilterSheet.show(context, controller),
          ),
          if (count > 0)
            Positioned(
              top: 6, right: 6,
              child: Container(
                width: 16, height: 16,
                decoration: BoxDecoration(color: AppColor.fourthColor, shape: BoxShape.circle),
                child: Center(child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
              ),
            ),
        ],
      );
    });
  }
}

// ── Items grid ────────────────────────────────────────────────────────────────

class _ItemsGrid extends StatelessWidget {
  final MarketplaceController controller;
  final bool isDark;
  const _ItemsGrid({required this.controller, required this.isDark});

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
        child: Obx(() => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.72,
            crossAxisSpacing: 12, mainAxisSpacing: 12,
          ),
          itemCount: controller.items.length + (controller.isLoadingMore.value ? 2 : 0),
          itemBuilder: (_, i) {
            if (i >= controller.items.length) {
              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 2)));
            }
            return MpItemCard(item: controller.items[i], isDark: isDark);
          },
        )),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final MarketplaceController controller;
  const _ErrorState({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey[400]),
      const SizedBox(height: 16),
      Text(controller.errorMessage.value, style: TextStyle(color: Colors.grey[600])),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: () => controller.loadItems(),
        icon: const Icon(Icons.refresh), label: Text('Retry'.tr),
        style: ElevatedButton.styleFrom(backgroundColor: AppColor.fourthColor, foregroundColor: Colors.white),
      ),
    ]));
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final MarketplaceController controller;
  final bool isDark;
  const _EmptyState({required this.controller, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
      const SizedBox(height: 16),
      Text('No items found'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600])),
      const SizedBox(height: 8),
      Text('Try adjusting your filters'.tr, style: TextStyle(color: Colors.grey[500])),
      const SizedBox(height: 16),
      TextButton(onPressed: controller.clearFilters, child: Text('Clear Filters'.tr)),
    ]));
  }
}
