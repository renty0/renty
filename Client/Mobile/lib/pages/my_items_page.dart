import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';

/// Displays items owned by the currently logged-in user.
/// Mirrors the Web's /my-items route (ItemsListComponent with ownerMode='me').
class MyItemsPage extends StatefulWidget {
  const MyItemsPage({super.key});

  @override
  State<MyItemsPage> createState() => _MyItemsPageState();
}

class _MyItemsPageState extends State<MyItemsPage> {
  final List<ItemListDto> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _error = '';
  int _page = 1;
  int _totalCount = 0;
  static const int _pageSize = 12;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems({bool reset = false}) async {
    if (reset) {
      setState(() {
        _page = 1;
        _items.clear();
        _isLoading = true;
        _error = '';
      });
    }

    try {
      final response = await ApiService.items.getItems(
        _page,
        _pageSize,
        owner: 'me',
        sort: 'newest',
        sortOrder: 'desc',
      );

      if (!mounted) return;

      if (response != null && response.data != null) {
        setState(() {
          if (reset || _page == 1) _items.clear();
          _items.addAll(response.data!);
          _totalCount = response.total ?? _items.length;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load your items';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _loadNextPage() {
    if (_isLoadingMore || _items.length >= _totalCount) return;
    setState(() {
      _isLoadingMore = true;
      _page++;
    });
    _loadItems();
  }

  String _formatCondition(String raw) {
    switch (raw.toLowerCase()) {
      case 'new':
        return 'New';
      case 'used':
        return 'Used';
      case 'like_new':
      case 'likenew':
        return 'Like New';
      case 'good':
        return 'Good';
      case 'fair':
        return 'Fair';
      default:
        return raw
            .split('_')
            .map((w) =>
                w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : AppColor.primaryColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Items',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColor.primaryColor,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          // Item count badge
          if (!_isLoading && _error.isEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.fourthColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_totalCount ${_totalCount == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColor.fourthColor,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(isDark),
      floatingActionButton: (!_isLoading && _error.isEmpty && _items.isNotEmpty)
          ? FloatingActionButton(
              onPressed: () async {
                final created = await Get.toNamed('/create-item');
                if (created == true) _loadItems(reset: true);
              },
              backgroundColor: AppColor.fourthColor,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildBody(bool isDark) {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.fourthColor),
      );
    }

    // Error state
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _loadItems(reset: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.fourthColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColor.fourthColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 56,
                  color: AppColor.fourthColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Items Yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColor.primaryColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You haven\'t listed any items for rent.\nStart sharing your items with others!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : AppColor.mediumText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final created = await Get.toNamed('/create-item');
                  if (created == true) _loadItems(reset: true);
                },
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add Your First Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.fourthColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Items grid
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200) {
          _loadNextPage();
        }
        return false;
      },
      child: RefreshIndicator(
        color: AppColor.fourthColor,
        onRefresh: () => _loadItems(reset: true),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.62,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _items.length + (_isLoadingMore ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= _items.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColor.fourthColor,
                  ),
                ),
              );
            }
            return _MyItemCard(
              item: _items[index],
              isDark: isDark,
              formatCondition: _formatCondition,
            );
          },
        ),
      ),
    );
  }
}

// ─── Item Card ────────────────────────────────────────────────────────────────

class _MyItemCard extends StatelessWidget {
  final ItemListDto item;
  final bool isDark;
  final String Function(String) formatCondition;

  const _MyItemCard({
    required this.item,
    required this.isDark,
    required this.formatCondition,
  });

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
            // ── Image ──
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(),
                    // Condition badge
                    if (item.condition != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            formatCondition(item.condition!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    // Type badge (rent/sale)
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
                            color: AppColor.primaryColor.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.type!.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Info ──
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
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
                    const SizedBox(height: 4),

                    // Category / subcategory
                    if (item.category != null || item.subcategory != null)
                      Text(
                        _categoryLabel(),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : AppColor.lightText,
                        ),
                        maxLines: 1,
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
                    const SizedBox(height: 6),

                    // Rating + City row
                    Row(
                      children: [
                        if (item.avgRating != null && item.avgRating! > 0) ...[
                          const Icon(Icons.star_rounded,
                              size: 14, color: Color(0xFF1A1A1A)),
                          const SizedBox(width: 2),
                          Text(
                            item.avgRating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? Colors.white70 : AppColor.mediumText,
                            ),
                          ),
                          if (item.reviewCount != null)
                            Text(
                              ' (${item.reviewCount})',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey[500]),
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
                    const SizedBox(height: 8),

                    // Action button row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 30,
                            child: OutlinedButton.icon(
                              onPressed: () => Get.toNamed(
                                '/item-detail',
                                arguments: {'itemId': item.id},
                              ),
                              icon: const Icon(Icons.visibility_outlined,
                                  size: 14),
                              label: const Text('View'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColor.fourthColor,
                                side: BorderSide(
                                  color:
                                      AppColor.fourthColor.withOpacity(0.4),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                textStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: SizedBox(
                            height: 30,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Get.snackbar(
                                  'Coming Soon',
                                  'Edit functionality is under development.',
                                  backgroundColor:
                                      AppColor.primaryColor.withOpacity(0.9),
                                  colorText: Colors.white,
                                );
                              },
                              icon:
                                  const Icon(Icons.edit_outlined, size: 14),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark
                                    ? Colors.white60
                                    : AppColor.mediumText,
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.grey[300]!,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                textStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
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

  Widget _buildImage() {
    if (item.primaryImage != null && item.primaryImage!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: item.primaryImage!,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          child: Icon(
            Icons.image_outlined,
            color:
                isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
            size: 40,
          ),
        ),
      );
    }
    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
      child: Icon(
        Icons.image_outlined,
        color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
        size: 40,
      ),
    );
  }

  String _categoryLabel() {
    final sub = item.subcategory?.nameEn ?? item.subcategory?.nameAr;
    final cat = item.category?.nameEn ?? item.category?.nameAr;
    if (sub != null && cat != null) return '$sub / $cat';
    return sub ?? cat ?? '';
  }
}
