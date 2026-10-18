import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/blocs/blocs.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:renty/utils/language_manager.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit()..loadCategories(),
      child: const _SearchPageContent(),
    );
  }
}

class _SearchPageContent extends StatefulWidget {
  const _SearchPageContent();

  @override
  State<_SearchPageContent> createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<_SearchPageContent> {
  final _searchTextController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchTextController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showFilterSheet(SearchCubit controller) {
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
    final controller = context.read<SearchCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
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
                    color: Colors.black.withValues(alpha: 0.04),
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
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: TextField(
                        controller: _searchTextController,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        cursorColor: const Color(0xFF2563EB),
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF1A1A1A),
                          fontSize: 15,
                        ),
                        onChanged: (query) =>
                            controller.onSearchChanged(query),
                        onSubmitted: (query) =>
                            controller.performSearch(query),
                        decoration: InputDecoration(
                          hintText: 'Search items to rent...'.tr,
                          hintStyle: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF94A3B8),
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          suffixIcon: BlocBuilder<SearchCubit, SearchState>(
                            buildWhen: (prev, curr) =>
                                prev.searchQuery != curr.searchQuery,
                            builder: (context, state) {
                              if (state.searchQuery.isNotEmpty) {
                                return IconButton(
                                  icon: Icon(Icons.close,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B)),
                                  onPressed: () {
                                    _searchTextController.clear();
                                    controller.clearSearch();
                                  },
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter button with active indicator
                  BlocBuilder<SearchCubit, SearchState>(
                    builder: (context, state) {
                      final hasFilters = state.hasActiveFilters;
                      return GestureDetector(
                        onTap: () => _showFilterSheet(controller),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: hasFilters
                                ? AppColor.fourthColor
                                : (isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: hasFilters
                                  ? AppColor.fourthColor
                                  : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1)),
                            ),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            size: 22,
                            color: hasFilters
                                ? Colors.white
                                : (isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B)),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Active filter chips ──
            BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (!state.hasActiveFilters) return const SizedBox.shrink();
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      if (state.selectedCategoryName.isNotEmpty)
                        _buildChip(state.selectedCategoryName, isDark, () {
                          controller.setCategory(null, '');
                        }),
                      if (state.selectedCity.isNotEmpty)
                        _buildChip(state.selectedCity, isDark, () {
                          controller.setCity('');
                        }),
                      if (state.sortBy != 'newest')
                        _buildChip(_sortLabel(state.sortBy), isDark, () {
                          controller.setSort('newest');
                        }),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: controller.resetFilters,
                        child: Text(
                          'Clear all'.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.fourthColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ]),
                  ),
                );
              },
            ),

            // ── Results ──
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColor.fourthColor),
                    );
                  }

                  if (state.errorMessage.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            state.errorMessage,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () =>
                                controller.performSearch(state.searchQuery),
                            icon: const Icon(Icons.refresh, size: 18),
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

                  if (state.searchQuery.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  if (state.results.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No results found'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try different keywords or adjust filters'.tr,
                            style: TextStyle(color: Colors.grey[500]),
                          ),
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
                          '@count results for "@query"'.trParams({
                            'count': state.totalResults.toString(),
                            'query': state.searchQuery,
                          }),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white70 : AppColor.mediumText,
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
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: state.results.length,
                            itemBuilder: (context, index) {
                              return _SearchResultCard(
                                item: state.results[index],
                                isDark: isDark,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
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
        color: AppColor.fourthColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.fourthColor.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColor.fourthColor,
          ),
        ),
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
      case 'price_low':
        return 'Price: Low→High'.tr;
      case 'price_high':
        return 'Price: High→Low'.tr;
      case 'rating':
        return 'Top Rated'.tr;
      default:
        return 'Newest'.tr;
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
              color: AppColor.fourthColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_rounded,
                size: 48, color: AppColor.fourthColor.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 20),
          Text(
            'Find what you need'.tr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColor.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start typing to search for items'.tr,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white54 : AppColor.lightText,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Bottom Sheet ───
class _FilterSheet extends StatefulWidget {
  final SearchCubit controller;
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
    final s = widget.controller.state;
    _catId = s.selectedCategoryId;
    _catName = s.selectedCategoryName;
    _city = s.selectedCity;
    _sort = s.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(children: [
            Text(
              'Filters'.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColor.darkText,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  _catId = null;
                  _catName = '';
                  _city = '';
                  _sort = 'newest';
                });
              },
              child: Text(
                'Reset'.tr,
                style: const TextStyle(
                  color: AppColor.fourthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ]),
        ),
        const Divider(height: 1),

        // Scrollable filter body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Sort By ──
              _sectionTitle('Sort By'.tr, isDark),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _sortChip('Newest'.tr, 'newest', isDark),
                _sortChip('Price: Low→High'.tr, 'price_low', isDark),
                _sortChip('Price: High→Low'.tr, 'price_high', isDark),
                _sortChip('Top Rated'.tr, 'rating', isDark),
              ]),

              const SizedBox(height: 24),

              // ── Category ──
              _sectionTitle('Category'.tr, isDark),
              const SizedBox(height: 10),
              BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state.categories.isEmpty) {
                    return Text(
                      'Loading...'.tr,
                      style: TextStyle(
                          color: isDark ? Colors.white54 : AppColor.lightText),
                    );
                  }
                  return Wrap(spacing: 8, runSpacing: 8, children: [
                    _catChip('All'.tr, null, isDark),
                    ...state.categories.map((cat) => _catChip(
                        LanguageManager.isArabic()
                            ? (cat.nameAr ?? cat.nameEn ?? '')
                            : (cat.nameEn ?? cat.nameAr ?? ''),
                        cat.id,
                        isDark)),
                  ]);
                },
              ),

              const SizedBox(height: 24),

              // ── City ──
              _sectionTitle('City'.tr, isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C2C2C)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _city.isEmpty ? null : _city,
                    hint: Text(
                      'All Cities'.tr,
                      style: TextStyle(
                          color: isDark ? Colors.white54 : AppColor.lightText),
                    ),
                    dropdownColor:
                        isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColor.darkText,
                        fontSize: 14),
                    items: [
                      DropdownMenuItem<String>(
                          value: '', child: Text('All Cities'.tr)),
                      ...SearchCubit.governorates.map((g) =>
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
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.controller.setCategory(_catId, _catName);
                widget.controller.setCity(_city);
                widget.controller.setSort(_sort);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                'Apply Filters'.tr,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _sectionTitle(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColor.darkText,
      ),
    );
  }

  Widget _sortChip(String label, String value, bool isDark) {
    final selected = _sort == value;
    return GestureDetector(
      onTap: () => setState(() => _sort = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.primaryColor
              : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColor.primaryColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark ? Colors.white70 : AppColor.mediumText),
          ),
        ),
      ),
    );
  }

  Widget _catChip(String label, int? catId, bool isDark) {
    final selected = _catId == catId;
    return GestureDetector(
      onTap: () => setState(() {
        _catId = catId;
        _catName = catId == null ? '' : label;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.fourthColor
              : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColor.fourthColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark ? Colors.white70 : AppColor.mediumText),
          ),
        ),
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
      onTap: () =>
          AppNavigator.pushNamed('/item-detail', arguments: {'itemId': item.id}),
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
            // Image + Type badge
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    item.primaryImage != null && item.primaryImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.primaryImage!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: isDark
                                  ? const Color(0xFF2A2A2A)
                                  : const Color(0xFFF1F5F9),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColor.fourthColor,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: isDark
                                  ? const Color(0xFF2A2A2A)
                                  : const Color(0xFFF1F5F9),
                              child: Icon(Icons.image_not_supported_outlined,
                                  color: Colors.grey[400], size: 32),
                            ),
                          )
                        : Container(
                            color: isDark
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFF1F5F9),
                            child: Icon(Icons.image_outlined,
                                color: Colors.grey[400], size: 32),
                          ),

                    // Rating badge
                    if (item.avgRating != null && item.avgRating! > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Color(0xFFFFB800), size: 13),
                              const SizedBox(width: 3),
                              Text(
                                item.avgRating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LanguageManager.isArabic()
                          ? (item.titleAr ?? item.titleEn ?? '')
                          : (item.titleEn ?? item.titleAr ?? ''),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColor.darkText,
                        height: 1.2,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '${item.dailyPrice?.toStringAsFixed(0) ?? '0'} ',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.fourthColor,
                                ),
                              ),
                              TextSpan(
                                text: 'EGP/day'.tr,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.white54
                                      : AppColor.lightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.city != null && item.city!.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 11,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.grey[400]),
                              const SizedBox(width: 2),
                              Text(
                                item.city!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.grey[500],
                                ),
                              ),
                            ],
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
