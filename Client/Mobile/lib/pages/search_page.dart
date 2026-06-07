import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/controllers/search_controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = Get.put(AppSearchController());
  final _searchTextController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.loadCategories();
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(controller: controller, isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar + Filter Button ──
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
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: TextField(
                        controller: _searchTextController,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        cursorColor: const Color(0xFF2563EB),
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          fontSize: 15,
                        ),
                        onChanged: (query) => controller.onSearchChanged(query),
                        onSubmitted: (query) => controller.performSearch(query),
                        decoration: InputDecoration(
                          hintText: 'Search items to rent...',
                          hintStyle: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          suffixIcon: Obx(() {
                            if (controller.searchQuery.value.isNotEmpty) {
                              return IconButton(
                                icon: Icon(Icons.close,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                onPressed: () {
                                  _searchTextController.clear();
                                  controller.clearSearch();
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter button with active indicator
                  Obx(() => GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: controller.hasActiveFilters
                            ? AppColor.fourthColor
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: controller.hasActiveFilters
                              ? AppColor.fourthColor
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 22,
                        color: controller.hasActiveFilters
                            ? Colors.white
                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                    ),
                  )),
                ],
              ),
            ),

            // ── Active filter chips ──
            Obx(() {
              if (!controller.hasActiveFilters) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    if (controller.selectedCategoryName.value.isNotEmpty)
                      _buildChip(controller.selectedCategoryName.value, isDark, () {
                        controller.selectedCategoryId.value = null;
                        controller.selectedCategoryName.value = '';
                        controller.applyFilters();
                      }),
                    if (controller.selectedCity.value.isNotEmpty)
                      _buildChip(controller.selectedCity.value, isDark, () {
                        controller.selectedCity.value = '';
                        controller.applyFilters();
                      }),
                    if (controller.sortBy.value != 'newest')
                      _buildChip(_sortLabel(controller.sortBy.value), isDark, () {
                        controller.sortBy.value = 'newest';
                        controller.applyFilters();
                      }),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: controller.resetFilters,
                      child: Text('Clear all',
                          style: TextStyle(fontSize: 12, color: AppColor.fourthColor, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),
              );
            }),

            // ── Results ──
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
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => controller.performSearch(controller.searchQuery.value),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry'),
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

                if (controller.searchQuery.value.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                if (controller.results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No results found',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Text('Try different keywords or adjust filters',
                            style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        '${controller.totalResults.value} results for "${controller.searchQuery.value}"',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : AppColor.mediumText,
                        ),
                      ),
                    ),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollEndNotification &&
                              notification.metrics.extentAfter < 200) {
                            controller.loadMore();
                          }
                          return false;
                        },
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: controller.results.length,
                          itemBuilder: (context, index) {
                            return _SearchResultCard(
                              item: controller.results[index],
                              isDark: isDark,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isDark, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.fourthColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.fourthColor.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColor.fourthColor)),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close, size: 14, color: AppColor.fourthColor),
        ),
      ]),
    );
  }

  String _sortLabel(String key) {
    switch (key) {
      case 'price_low': return 'Price: Low→High';
      case 'price_high': return 'Price: High→Low';
      case 'rating': return 'Top Rated';
      default: return 'Newest';
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColor.fourthColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_rounded, size: 48, color: AppColor.fourthColor.withOpacity(0.6)),
          ),
          const SizedBox(height: 20),
          Text('Find what you need',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColor.primaryColor)),
          const SizedBox(height: 8),
          Text('Start typing to search for items',
              style: TextStyle(fontSize: 15, color: isDark ? Colors.white54 : AppColor.lightText)),
        ],
      ),
    );
  }
}

// ─── Filter Bottom Sheet ───
class _FilterSheet extends StatefulWidget {
  final AppSearchController controller;
  final bool isDark;
  const _FilterSheet({required this.controller, required this.isDark});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late int? _catId;
  late String _catName;
  late String _city;
  late String _sort;

  @override
  void initState() {
    super.initState();
    _catId = widget.controller.selectedCategoryId.value;
    _catName = widget.controller.selectedCategoryName.value;
    _city = widget.controller.selectedCity.value;
    _sort = widget.controller.sortBy.value;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(children: [
            Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColor.darkText)),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() { _catId = null; _catName = ''; _city = ''; _sort = 'newest'; });
              },
              child: const Text('Reset', style: TextStyle(color: AppColor.fourthColor, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
        const Divider(height: 1),

        // Scrollable filter body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Sort By ──
              _sectionTitle('Sort By', isDark),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _sortChip('Newest', 'newest', isDark),
                _sortChip('Price: Low→High', 'price_low', isDark),
                _sortChip('Price: High→Low', 'price_high', isDark),
                _sortChip('Top Rated', 'rating', isDark),
              ]),

              const SizedBox(height: 24),

              // ── Category ──
              _sectionTitle('Category', isDark),
              const SizedBox(height: 10),
              Obx(() {
                if (widget.controller.categories.isEmpty) {
                  return Text('Loading...', style: TextStyle(color: isDark ? Colors.white54 : AppColor.lightText));
                }
                return Wrap(spacing: 8, runSpacing: 8, children: [
                  _catChip('All', null, isDark),
                  ...widget.controller.categories.map((cat) =>
                    _catChip(cat.nameEn ?? cat.nameAr ?? '', cat.id, isDark)),
                ]);
              }),

              const SizedBox(height: 24),

              // ── City ──
              _sectionTitle('City', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _city.isEmpty ? null : _city,
                    hint: Text('All Cities', style: TextStyle(color: isDark ? Colors.white54 : AppColor.lightText)),
                    dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : AppColor.darkText, fontSize: 14),
                    items: [
                      DropdownMenuItem<String>(value: '', child: Text('All Cities')),
                      ...AppSearchController.governorates.map((g) =>
                        DropdownMenuItem<String>(value: g, child: Text(g))),
                    ],
                    onChanged: (val) => setState(() => _city = val ?? ''),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ]),
          ),
        ),

        // Apply button
        Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.controller.selectedCategoryId.value = _catId;
                widget.controller.selectedCategoryName.value = _catName;
                widget.controller.selectedCity.value = _city;
                widget.controller.sortBy.value = _sort;
                widget.controller.applyFilters();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _sectionTitle(String text, bool isDark) {
    return Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColor.darkText));
  }

  Widget _sortChip(String label, String value, bool isDark) {
    final selected = _sort == value;
    return GestureDetector(
      onTap: () => setState(() => _sort = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColor.primaryColor : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColor.primaryColor : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : (isDark ? Colors.white70 : AppColor.mediumText),
        )),
      ),
    );
  }

  Widget _catChip(String label, int? catId, bool isDark) {
    final selected = _catId == catId;
    return GestureDetector(
      onTap: () => setState(() { _catId = catId; _catName = catId == null ? '' : label; }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColor.fourthColor : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColor.fourthColor : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : (isDark ? Colors.white70 : AppColor.mediumText),
        )),
      ),
    );
  }
}

// ─── Search Result Card ───
class _SearchResultCard extends StatelessWidget {
  final ItemListDto item;
  final bool isDark;

  const _SearchResultCard({required this.item, required this.isDark});

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
                child: item.primaryImage != null && item.primaryImage!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.primaryImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: Icon(Icons.image_outlined, color: Colors.grey[400]),
                        ),
                      )
                    : Container(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 40),
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
                      item.titleEn ?? item.titleAr ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColor.darkText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (item.dailyPrice != null)
                      Text(
                        '${item.dailyPrice!.toStringAsFixed(0)} EGP/day',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColor.fourthColor),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (item.avgRating != null && item.avgRating! > 0) ...[
                          Icon(Icons.star_rounded, size: 14, color: const Color(0xFFFBBF24)),
                          const SizedBox(width: 2),
                          Text(item.avgRating!.toStringAsFixed(1),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : AppColor.mediumText)),
                          const SizedBox(width: 6),
                        ],
                        if (item.city != null)
                          Expanded(
                            child: Text(item.city!,
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : AppColor.lightText),
                                overflow: TextOverflow.ellipsis),
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
