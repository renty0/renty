import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/favorites_controller.dart';

/// Favorites list page — shows all favorited items as cards.
class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<FavoritesController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text('My Favorites',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.favorites.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.favorites.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadFavorites,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.favorites.length,
            itemBuilder: (context, index) {
              final item = ctrl.favorites[index];
              return _FavoriteCard(item: item, ctrl: ctrl);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border,
                size: 80, color: AppColors.gray300),
            const SizedBox(height: 24),
            Text(
              'No favorites yet',
              style: AppTextStyles.heading3.copyWith(color: AppColors.gray500),
            ),
            const SizedBox(height: 12),
            Text(
              'Browse the marketplace and tap the heart\nicon to add items here',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/marketplace'),
              icon: const Icon(Icons.storefront),
              label: const Text('Browse Marketplace'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual favorite card — horizontal layout with image, info, remove
class _FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final FavoritesController ctrl;

  const _FavoriteCard({required this.item, required this.ctrl});

  String get _title => item['titleEn'] ?? item['titleAr'] ?? '';
  String get _imageUrl => item['primaryImage'] ?? '';
  String get _category {
    final c = item['category'] as Map<String, dynamic>?;
    return c?['nameEn'] ?? c?['nameAr'] ?? '';
  }
  num? get _price => item['dailyPrice'] as num?;

  @override
  Widget build(BuildContext context) {
    final itemId = (item['id'] ?? '').toString();

    return GestureDetector(
      onTap: () {
        if (itemId.isNotEmpty) {
          Get.toNamed('/marketplace/product/$itemId');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Container(
                width: 120,
                height: 120,
                color: const Color(0xFFF8FAFC),
                child: _imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: _imageUrl,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.image_outlined,
                          size: 36,
                          color: AppColors.gray300,
                        ),
                      )
                    : const Icon(Icons.image_outlined,
                        size: 36, color: AppColors.gray300),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_category.isNotEmpty)
                      Text(
                        _category.toUpperCase(),
                        style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      _title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (_price != null)
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          children: [
                            TextSpan(text: '$_price EGP'),
                            TextSpan(
                              text: '/day',
                              style: AppTextStyles.captionSmall.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Remove button
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(Icons.favorite,
                    color: Colors.redAccent, size: 26),
                onPressed: () => ctrl.toggleFavorite(itemId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
