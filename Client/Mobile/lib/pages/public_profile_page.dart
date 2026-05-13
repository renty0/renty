import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';

/// Public profile page — shows a user's info and their listed items.
/// Since there is no dedicated GET /users/{id}/profile endpoint,
/// we derive the profile from the owner field on the item detail and
/// list items filtered by owner ID.
class PublicProfilePage extends StatefulWidget {
  final String userId;
  final String? userName;
  final String? userCity;
  final String? userImageUrl;

  const PublicProfilePage({
    super.key,
    required this.userId,
    this.userName,
    this.userCity,
    this.userImageUrl,
  });

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  bool _isLoading = true;
  List<ItemListDto> _items = [];

  @override
  void initState() {
    super.initState();
    _loadUserItems();
  }

  Future<void> _loadUserItems() async {
    // OwnerDto doesn't expose a user ID — if we don't have one, skip the query
    if (widget.userId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final resp = await ApiService.items.getItems(1, 50, owner: widget.userId);
      if (resp != null) {
        _items = resp.data ?? [];
      }
    } catch (e) {
      print('PublicProfile: failed to load items: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColor.backgroundcolor;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : AppColor.darkText;
    final subtextColor = isDark ? Colors.white54 : AppColor.mediumText;
    final initials = (widget.userName ?? 'U')[0].toUpperCase();

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // ── Gradient App Bar ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColor.primaryColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColor.primaryColor,
                      AppColor.secondColor,
                      AppColor.fourthColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: widget.userImageUrl != null &&
                                  widget.userImageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: widget.userImageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      _initialsWidget(initials),
                                  errorWidget: (_, __, ___) =>
                                      _initialsWidget(initials),
                                )
                              : _initialsWidget(initials),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.userName ?? 'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (widget.userCity != null &&
                          widget.userCity!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(widget.userCity!,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Stats Row ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statItem(
                      '${_items.length}',
                      'Listings',
                      Icons.inventory_2_outlined,
                      textColor,
                      subtextColor,
                    ),
                    Container(
                        height: 32,
                        width: 1,
                        color: isDark ? Colors.white12 : Colors.grey[200]),
                    _statItem(
                      _avgRating(),
                      'Avg Rating',
                      Icons.star_rounded,
                      textColor,
                      subtextColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Section Header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('Listings',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor)),
            ),
          ),

          // ── Items Grid ──
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(
                      child:
                          CircularProgressIndicator(color: AppColor.fourthColor)),
                )
              : _items.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text('No listings yet',
                                style: TextStyle(
                                    color: subtextColor, fontSize: 16)),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) =>
                              _ItemCard(item: _items[i], isDark: isDark),
                          childCount: _items.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _initialsWidget(String initials) {
    return Container(
      color: AppColor.fourthColor,
      child: Center(
        child: Text(initials,
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon, Color textColor,
      Color subtextColor) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColor.fourthColor),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: subtextColor,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _avgRating() {
    if (_items.isEmpty) return '—';
    final rated = _items.where((i) => i.avgRating != null && i.avgRating! > 0);
    if (rated.isEmpty) return '—';
    final avg = rated.map((i) => i.avgRating!).reduce((a, b) => a + b) /
        rated.length;
    return avg.toStringAsFixed(1);
  }
}

// ── Reusable Item Card ──
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
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: item.primaryImage != null &&
                        item.primaryImage!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.primaryImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => Container(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
                          child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
                          child: Icon(Icons.image_outlined,
                              color: Colors.grey[400], size: 40),
                        ),
                      )
                    : Container(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0),
                        child: Icon(Icons.image_outlined,
                            color: Colors.grey[400], size: 40),
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
