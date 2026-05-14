import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../rent_requests/views/create_rent_request_sheet.dart';
import '../../reviews/views/item_reviews_view.dart';
import '../controllers/marketplace_controller.dart';

/// Product detail page matching the web:
/// image gallery, pricing, specs, rent now button, related items
class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final _ctrl = Get.find<MarketplaceController>();

  @override
  void initState() {
    super.initState();
    final id = Get.parameters['id'];
    if (id != null) {
      _ctrl.loadItemDetail(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() {
        if (_ctrl.isLoadingDetail.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final item = _ctrl.currentItem.value;
        if (item == null) {
          return _buildNotFound();
        }

        return CustomScrollView(
          slivers: [
            // ── Image Gallery SliverAppBar ──
            _buildGalleryAppBar(item),

            // ── Content ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    _buildCategoryBadge(item),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      _ctrl.getLocalizedName(item),
                      style: AppTextStyles.heading1.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 8),

                    // Condition badge
                    if (item['condition'] != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['condition'],
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Pricing
                    _buildPricing(item),
                    const SizedBox(height: 20),

                    // Description
                    Text(
                      _ctrl.getLocalizedDesc(item),
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rating
                    _buildRating(item),
                    const SizedBox(height: 12),

                    // See Reviews button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final itemId = item['id']?.toString() ?? '';
                          final title = _ctrl.getLocalizedName(item);
                          Get.to(() => ItemReviewsView(
                                itemId: itemId,
                                itemTitle: title,
                              ));
                        },
                        icon: const Icon(Icons.star_border, size: 18),
                        label: const Text('See All Reviews'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final itemId = item['id'];
                          final dailyPrice = item['dailyPrice'] as num? ?? 0;
                          final title = _ctrl.getLocalizedName(item);
                          if (itemId != null) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => CreateRentRequestSheet(
                                rentableItemId: itemId.toString(),
                                itemTitle: title,
                                dailyPrice: dailyPrice,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.calendar_month, size: 20),
                        label: Text('Rent Now',
                            style: AppTextStyles.button.copyWith(fontSize: 17)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 8,
                          shadowColor:
                              AppColors.primary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Specifications
                    _buildSpecifications(item),
                    const SizedBox(height: 32),

                    // Related Products
                    _buildRelatedProducts(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Gallery AppBar ──────────────────────────────────────────────

  Widget _buildGalleryAppBar(Map<String, dynamic> item) {
    final images = item['images'] as List? ?? [];

    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.width,
      pinned: true,
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.primary,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: AppColors.white.withValues(alpha: 0.9),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Main image
            Obx(() => Container(
                  width: double.infinity,
                  color: const Color(0xFFF8FAFC),
                  child: _ctrl.selectedImage.value.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: _ctrl.selectedImage.value,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.image_outlined,
                            size: 64,
                            color: AppColors.gray300,
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.image_outlined,
                              size: 64, color: AppColors.gray300),
                        ),
                )),

            // Thumbnails at bottom
            if (images.length > 1)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: SizedBox(
                  height: 64,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final img = images[index] as Map<String, dynamic>;
                      final url = img['imageUrl'] ?? '';
                      return Obx(() => GestureDetector(
                            onTap: () =>
                                _ctrl.selectedImage.value = url,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 64,
                              height: 64,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      _ctrl.selectedImage.value == url
                                          ? AppColors.primary
                                          : Colors.transparent,
                                  width: 2.5,
                                ),
                                color: AppColors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ));
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Category Badge ──────────────────────────────────────────────

  Widget _buildCategoryBadge(Map<String, dynamic> item) {
    final category = item['category'] as Map<String, dynamic>?;
    final subcategory = item['subcategory'] as Map<String, dynamic>?;
    final catName = _ctrl.getLocalizedRefName(category);
    final subName = _ctrl.getLocalizedRefName(subcategory);

    final label = subName.isNotEmpty ? '$catName / $subName' : catName;
    if (label.isEmpty) return const SizedBox.shrink();

    return Text(
      label.toUpperCase(),
      style: AppTextStyles.captionSmall.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        fontSize: 11,
      ),
    );
  }

  // ── Pricing ─────────────────────────────────────────────────────

  Widget _buildPricing(Map<String, dynamic> item) {
    final pricing = item['pricing'] as List? ?? [];
    if (pricing.isEmpty) {
      final dailyPrice = item['dailyPrice'];
      if (dailyPrice != null) {
        return RichText(
          text: TextSpan(
            style: AppTextStyles.heading2.copyWith(fontSize: 28),
            children: [
              TextSpan(text: '$dailyPrice EGP'),
              TextSpan(
                text: '/day',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: pricing.map<Widget>((p) {
          final pMap = p as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pMap['pricingType'] ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                    children: [
                      TextSpan(text: '${pMap['price']} EGP'),
                      TextSpan(
                        text: '/${pMap['pricingType']}',
                        style: AppTextStyles.captionSmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Rating ──────────────────────────────────────────────────────

  Widget _buildRating(Map<String, dynamic> item) {
    final rating = item['avgRating'];
    final reviewCount = item['reviewCount'];
    if (rating == null || rating == 0) return const SizedBox.shrink();

    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(
          (rating is num) ? rating.toStringAsFixed(1) : '$rating',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 6),
          Text(
            '($reviewCount reviews)',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ],
    );
  }

  // ── Specifications ──────────────────────────────────────────────

  Widget _buildSpecifications(Map<String, dynamic> item) {
    final specs = <Map<String, String>>[];

    if (item['condition'] != null) {
      specs.add({'label': 'Condition', 'value': item['condition']});
    }
    if (item['type'] != null) {
      specs.add({'label': 'Type', 'value': item['type']});
    }
    final brand = item['brand'] as Map<String, dynamic>?;
    if (brand != null) {
      specs.add({
        'label': 'Brand',
        'value': _ctrl.getLocalizedRefName(brand),
      });
    }
    if (item['city'] != null) {
      specs.add({'label': 'Location', 'value': item['city']});
    }

    if (specs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Specifications', style: AppTextStyles.heading3),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: specs.map((spec) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spec['label']!.toUpperCase(),
                    style: AppTextStyles.captionSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spec['value']!,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Related Products ────────────────────────────────────────────

  Widget _buildRelatedProducts() {
    return Obx(() {
      if (_ctrl.relatedItems.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          Text('Related Products', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _ctrl.relatedItems.length,
              itemBuilder: (context, index) {
                final related = _ctrl.relatedItems[index];
                final imageUrl = related['primaryImage'] ?? '';
                final title = _ctrl.getLocalizedName(related);
                final price = related['dailyPrice'];

                return GestureDetector(
                  onTap: () {
                    final relId = related['id'];
                    if (relId != null) {
                      Get.offNamed('/marketplace/product/$relId');
                    }
                  },
                  child: Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Container(
                            height: 130,
                            width: double.infinity,
                            color: const Color(0xFFF8FAFC),
                            child: imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.contain,
                                    errorWidget: (_, __, ___) =>
                                        const Icon(Icons.image_outlined,
                                            color: AppColors.gray300),
                                  )
                                : const Icon(Icons.image_outlined,
                                    color: AppColors.gray300),
                          ),
                        ),
                        // Info
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (price != null)
                                RichText(
                                  text: TextSpan(
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(text: '$price EGP'),
                                      TextSpan(
                                        text: '/day',
                                        style: AppTextStyles.captionSmall
                                            .copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  // ── Not Found ───────────────────────────────────────────────────

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppColors.gray300),
          const SizedBox(height: 16),
          Text(
            'Product not found',
            style: AppTextStyles.heading3.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Back to Marketplace'),
          ),
        ],
      ),
    );
  }
}
