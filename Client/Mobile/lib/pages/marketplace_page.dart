import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/controllers/marketplace_controller.dart';

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
            // ── Header ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Marketplace',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColor.primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      // Sort button
                      _SortButton(controller: controller, isDark: isDark),
                      const SizedBox(width: 8),
                      // Filter button
                      _FilterButton(controller: controller, isDark: isDark),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Category chips
                  _CategoryChips(controller: controller, isDark: isDark),
                ],
              ),
            ),

            // ── Items Grid ──
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColor.fourthColor),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(controller.errorMessage.value,
                            style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => controller.loadItems(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.fourthColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No items found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: controller.clearFilters,
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification &&
                        notification.metrics.extentAfter < 200) {
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
                      itemCount: controller.items.length +
                          (controller.isLoadingMore.value ? 2 : 0),
                      itemBuilder: (context, index) {
                        if (index >= controller.items.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        return _MarketplaceItemCard(
                          item: controller.items[index],
                          isDark: isDark,
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final MarketplaceController controller;
  final bool isDark;

  const _CategoryChips({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categories = controller.categories;
      return SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length + 1, // +1 for "All"
          itemBuilder: (context, index) {
            if (index == 0) {
              return Obx(() => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: controller.selectedCategoryId.value == null,
                      onSelected: (_) => controller.setCategory(null),
                      selectedColor: AppColor.fourthColor,
                      labelStyle: TextStyle(
                        color: controller.selectedCategoryId.value == null
                            ? Colors.white
                            : (isDark ? Colors.white70 : AppColor.mediumText),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ));
            }
            final cat = categories[index - 1];
            return Obx(() => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat.nameEn ?? cat.nameAr ?? ''),
                    selected: controller.selectedCategoryId.value == cat.id,
                    onSelected: (_) => controller.setCategory(cat.id),
                    selectedColor: AppColor.fourthColor,
                    labelStyle: TextStyle(
                      color: controller.selectedCategoryId.value == cat.id
                          ? Colors.white
                          : (isDark ? Colors.white70 : AppColor.mediumText),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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

class _SortButton extends StatelessWidget {
  final MarketplaceController controller;
  final bool isDark;

  const _SortButton({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSort = controller.selectedSort.value;
      final currentOrder = controller.selectedSortOrder.value;
      String activeKey = 'newest';
      if (currentSort == 'price' && currentOrder == 'asc') activeKey = 'price_low';
      if (currentSort == 'price' && currentOrder == 'desc') activeKey = 'price_high';
      if (currentSort == 'rating') activeKey = 'rating';

      return PopupMenuButton<String>(
        icon: Icon(
          Icons.sort_rounded,
          color: isDark ? Colors.white70 : AppColor.primaryColor,
        ),
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 6,
        onSelected: (value) {
          switch (value) {
            case 'newest':
              controller.setSort('createdAt', 'desc');
              break;
            case 'price_low':
              controller.setSort('price', 'asc');
              break;
            case 'price_high':
              controller.setSort('price', 'desc');
              break;
            case 'rating':
              controller.setSort('rating', 'desc');
              break;
          }
        },
        itemBuilder: (context) => [
          _sortItem('newest', 'Newest First', Icons.schedule, activeKey, isDark),
          _sortItem('price_low', 'Price: Low to High', Icons.arrow_upward, activeKey, isDark),
          _sortItem('price_high', 'Price: High to Low', Icons.arrow_downward, activeKey, isDark),
          _sortItem('rating', 'Highest Rated', Icons.star_rounded, activeKey, isDark),
        ],
      );
    });
  }

  PopupMenuItem<String> _sortItem(
      String value, String label, IconData icon, String active, bool dark) {
    final isActive = value == active;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18,
              color: isActive ? AppColor.fourthColor : (dark ? Colors.white54 : Colors.grey[500])),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? AppColor.fourthColor
                      : (dark ? Colors.white : AppColor.darkText),
                )),
          ),
          if (isActive)
            Icon(Icons.check_rounded, size: 18, color: AppColor.fourthColor),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final MarketplaceController controller;
  final bool isDark;

  const _FilterButton({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.tune_rounded,
        color: isDark ? Colors.white70 : AppColor.primaryColor,
      ),
      onPressed: () => _showFilterSheet(context),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final minCtrl = TextEditingController(
      text: controller.minPrice.value?.toStringAsFixed(0) ?? '',
    );
    final maxCtrl = TextEditingController(
      text: controller.maxPrice.value?.toStringAsFixed(0) ?? '',
    );
    final cityCtrl = TextEditingController(
      text: controller.selectedCity.value,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColor.primaryColor,
                ),
              ),
              const SizedBox(height: 20),

              // ── City ──
              _filterLabel('City', isDark),
              const SizedBox(height: 8),
              TextField(
                controller: cityCtrl,
                style: TextStyle(color: isDark ? Colors.white : AppColor.darkText),
                decoration: InputDecoration(
                  hintText: 'e.g. Cairo, Alexandria',
                  hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400]),
                  prefixIcon: Icon(Icons.location_city_rounded,
                      size: 20, color: isDark ? Colors.white38 : Colors.grey[500]),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // ── Condition ──
              _filterLabel('Condition', isDark),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      {'label': 'New', 'value': 'new'},
                      {'label': 'Like New', 'value': 'like_new'},
                      {'label': 'Good', 'value': 'good'},
                      {'label': 'Used', 'value': 'used'},
                      {'label': 'Fair', 'value': 'fair'},
                    ].map((c) {
                      final selected = controller.selectedCondition.value == c['value'];
                      return ChoiceChip(
                        label: Text(c['label']!),
                        selected: selected,
                        onSelected: (_) {
                          controller.selectedCondition.value = selected ? '' : c['value']!;
                        },
                        selectedColor: AppColor.fourthColor,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : (isDark ? Colors.white70 : AppColor.mediumText),
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        side: BorderSide.none,
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 20),

              // ── Type ──
              _filterLabel('Listing Type', isDark),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      {'label': 'For Rent', 'value': 'rent'},
                      {'label': 'For Sale', 'value': 'sell'},
                      {'label': 'Both', 'value': 'both'},
                    ].map((t) {
                      final selected = controller.selectedType.value == t['value'];
                      return ChoiceChip(
                        label: Text(t['label']!),
                        selected: selected,
                        onSelected: (_) {
                          controller.selectedType.value = selected ? '' : t['value']!;
                        },
                        selectedColor: AppColor.fourthColor,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : (isDark ? Colors.white70 : AppColor.mediumText),
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        side: BorderSide.none,
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 20),

              // ── Price Range ──
              _filterLabel('Price Range (EGP)', isDark),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : AppColor.darkText),
                      decoration: InputDecoration(
                        hintText: 'Min',
                        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400]),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('–', style: TextStyle(color: Colors.grey[500], fontSize: 20)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : AppColor.darkText),
                      decoration: InputDecoration(
                        hintText: 'Max',
                        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400]),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Active filter count ──
              Obx(() {
                int count = 0;
                if (controller.selectedCondition.value.isNotEmpty) count++;
                if (controller.selectedType.value.isNotEmpty) count++;
                if (controller.minPrice.value != null) count++;
                if (controller.maxPrice.value != null) count++;
                if (controller.selectedCity.value.isNotEmpty) count++;
                if (controller.selectedCategoryId.value != null) count++;
                if (count > 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '$count filter${count > 1 ? 's' : ''} active',
                      style: TextStyle(
                        color: AppColor.fourthColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearFilters();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColor.fourthColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Clear All', style: TextStyle(color: AppColor.fourthColor)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.selectedCity.value = cityCtrl.text.trim();
                        if (minCtrl.text.isNotEmpty) {
                          controller.minPrice.value = double.tryParse(minCtrl.text);
                        } else {
                          controller.minPrice.value = null;
                        }
                        if (maxCtrl.text.isNotEmpty) {
                          controller.maxPrice.value = double.tryParse(maxCtrl.text);
                        } else {
                          controller.maxPrice.value = null;
                        }
                        controller.applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.fourthColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterLabel(String text, bool isDark) {
    return Text(text, style: TextStyle(
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white70 : AppColor.darkText,
    ));
  }
}

class _MarketplaceItemCard extends StatelessWidget {
  final ItemListDto item;
  final bool isDark;

  const _MarketplaceItemCard({required this.item, required this.isDark});

  String _formatCondition(String raw) {
    switch (raw.toLowerCase()) {
      case 'new': return 'New';
      case 'used': return 'Used';
      case 'like_new':
      case 'likenew': return 'Like New';
      case 'good': return 'Good';
      case 'fair': return 'Fair';
      default:
        // Fallback: replace underscores with spaces and capitalise each word
        return raw.split('_').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
    }
  }

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
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    item.primaryImage != null && item.primaryImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.primaryImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB))),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                              child: Icon(Icons.image_outlined, color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8), size: 40),
                            ),
                          )
                        : Container(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                            child: Icon(Icons.image_outlined, color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8), size: 40),
                          ),
                    if (item.condition != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatCondition(item.condition!),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
                    Row(
                      children: [
                        if (item.avgRating != null && item.avgRating! > 0) ...[
                          Icon(Icons.star_rounded, size: 14, color: Color(0xFF1A1A1A)),
                          const SizedBox(width: 2),
                          Text(
                            item.avgRating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : AppColor.mediumText,
                            ),
                          ),
                          if (item.reviewCount != null)
                            Text(
                              ' (${item.reviewCount})',
                              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                            ),
                          const SizedBox(width: 6),
                        ],
                        if (item.city != null)
                          Expanded(
                            child: Text(
                              item.city!,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : AppColor.lightText,
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
