import 'package:flutter/material.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/pages/edit_item_page.dart';
import 'package:renty/utils/language_manager.dart';

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
        // All items returned by the API are active
        final activeItems = response.data!;
        setState(() {
          if (reset || _page == 1) _items.clear();
          _items.addAll(activeItems);
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
        _error = 'Failed to load your items'.tr;
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

  Future<void> _deleteItem(ItemListDto item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Item'.tr),
        content: Text('Are you sure you want to delete "@title"? This cannot be undone.'.trParams({
          'title': item.titleEn ?? item.titleAr ?? 'this item'.tr
        })),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.tr)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || item.id == null) return;

    try {
      await ApiService.items.deleteItem(item.id!);
      if (!mounted) return;
      setState(() {
        _items.remove(item);
        _totalCount = (_totalCount - 1).clamp(0, _totalCount);
      });
      AppNavigator.showSnackBar('Deleted'.tr, 'Item has been deleted.'.tr,
          backgroundColor: Colors.green.withValues(alpha: 0.9), textColor: Colors.white);
    } on ApiException catch (e) {
      AppNavigator.showSnackBar('Error'.tr, '${'Failed to delete'.tr}: ${e.message ?? e.code}',
          backgroundColor: Colors.red.withValues(alpha: 0.9), textColor: Colors.white, isError: true);
    } catch (e) {
      AppNavigator.showSnackBar('Error'.tr, 'Failed to delete item.'.tr,
          backgroundColor: Colors.red.withValues(alpha: 0.9), textColor: Colors.white, isError: true);
    }
  }

  String _formatCondition(String raw) {
    switch (raw.toLowerCase()) {
      case 'new':
        return 'New'.tr;
      case 'used':
        return 'Used'.tr;
      case 'like_new':
      case 'likenew':
        return 'Like New'.tr;
      case 'good':
        return 'Good'.tr;
      case 'fair':
        return 'Fair'.tr;
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
          'My Items'.tr,
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
                  _totalCount == 1
                      ? '@count item'.trParams({'count': '$_totalCount'})
                      : '@count items'.trParams({'count': '$_totalCount'}),
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
                final created = await AppNavigator.pushNamed('/create-item');
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
                label: Text('Retry'.tr),
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
                'No Items Yet'.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColor.primaryColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You haven\'t listed any items for rent.\nStart sharing your items with others!'.tr,
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
                  final created = await AppNavigator.pushNamed('/create-item');
                  if (created == true) _loadItems(reset: true);
                },
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text('Add Your First Item'.tr),
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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            childAspectRatio: 0.60,
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
              onDelete: _deleteItem,
              onEdit: (item) async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditItemPage(itemId: item.id!)),
                );
                if (result == true) {
                  _page = 1;
                  _loadItems(reset: true);
                }
              },
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
  final void Function(ItemListDto) onDelete;
  final void Function(ItemListDto) onEdit;

  const _MyItemCard({
    required this.item,
    required this.isDark,
    required this.formatCondition,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppNavigator.pushNamed('/item-detail', arguments: {'itemId': item.id}),
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
                      item.titleEn ?? item.titleAr ?? 'Untitled'.tr,
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
                        '@price EGP / day'.trParams({'price': item.dailyPrice!.toStringAsFixed(0)}),
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
                              item.city!.tr,
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

                    // ── Action buttons row (icon-only, never wrap) ──
                    Row(
                      children: [
                        _iconBtn(
                          icon: Icons.visibility_outlined,
                          label: 'View'.tr,
                          fg: AppColor.fourthColor,
                          bg: AppColor.fourthColor.withValues(alpha: 0.1),
                          onTap: () => AppNavigator.pushNamed('/item-detail',
                              arguments: {'itemId': item.id}),
                        ),
                        const SizedBox(width: 6),
                        _iconBtn(
                          icon: Icons.edit_outlined,
                          label: 'Edit'.tr,
                          fg: isDark ? Colors.white70 : AppColor.mediumText,
                          bg: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.grey.withValues(alpha: 0.1),
                          onTap: () => onEdit(item),
                        ),
                        const SizedBox(width: 6),
                        _iconBtn(
                          icon: Icons.delete_outline,
                          label: 'Delete'.tr,
                          fg: Colors.red[400]!,
                          bg: Colors.red.withValues(alpha: 0.08),
                          onTap: () => onDelete(item),
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

  Widget _iconBtn({
    required IconData icon,
    required String label,
    required Color fg,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 34,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: fg),
          ),
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
    final sub = LanguageManager.isArabic()
        ? (item.subcategory?.nameAr ?? item.subcategory?.nameEn)
        : (item.subcategory?.nameEn ?? item.subcategory?.nameAr);
    final cat = LanguageManager.isArabic()
        ? (item.category?.nameAr ?? item.category?.nameEn)
        : (item.category?.nameEn ?? item.category?.nameAr);
    if (sub != null && cat != null) return '$sub / $cat';
    return sub ?? cat ?? '';
  }
}
