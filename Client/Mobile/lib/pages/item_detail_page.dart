import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/controllers/item_detail_controller.dart';
import 'package:renty/core/controllers/rentals_controller.dart';
import 'package:renty/pages/create_rental_page.dart';
import 'package:renty/pages/public_profile_page.dart';
import 'package:renty/pages/checkout_page.dart';

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ItemDetailController());
    final args = Get.arguments as Map<String, dynamic>?;
    final itemId = args?['itemId'] as String?;

    if (itemId != null) {
      controller.loadItem(itemId);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.fourthColor),
          );
        }

        if (controller.errorMessage.value.isNotEmpty || controller.item.value == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value.isNotEmpty
                      ? controller.errorMessage.value
                      : 'Item not found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        final item = controller.item.value!;

        return CustomScrollView(
          slivers: [
            // ── Image Gallery ──
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
                onPressed: () => Get.back(),
              ),
              actions: [
                Obx(() => IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          controller.isFavorite.value
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: controller.isFavorite.value
                              ? Colors.red
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: controller.toggleFavorite,
                    )),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _ImageGallery(
                  images: item.images ?? [],
                  primaryImage: item.images?.firstWhere(
                    (i) => i.isPrimary == true,
                    orElse: () => item.images!.first,
                  ),
                ),
              ),
            ),

            // ── Item Info ──
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Title + Status
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.status != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: _getStatusColor(item.status!).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.status!,
                                style: TextStyle(
                                  color: _getStatusColor(item.status!),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          Text(
                            item.titleEn ?? item.titleAr ?? 'Untitled',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColor.primaryColor,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Rating row
                          Row(
                            children: [
                              if (controller.avgRating.value > 0) ...[
                                Icon(Icons.star_rounded, color:   Color(0xFF1A1A1A), size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  controller.avgRating.value.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppColor.darkText,
                                  ),
                                ),
                                Text(
                                  ' (${controller.totalReviews.value} reviews)',
                                  style: TextStyle(
                                    color: isDark ? Colors.white54 : AppColor.lightText,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                              if (item.city != null) ...[
                                Icon(Icons.location_on_outlined,
                                    size: 16,
                                    color: isDark ? Colors.white54 : AppColor.lightText),
                                const SizedBox(width: 4),
                                Text(
                                  item.city!,
                                  style: TextStyle(
                                    color: isDark ? Colors.white54 : AppColor.lightText,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    _divider(isDark),

                    // ── Pricing ──
                    if (item.pricing != null && item.pricing!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pricing',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColor.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: item.pricing!.map((p) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColor.fourthColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColor.fourthColor.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${p.price?.toStringAsFixed(0) ?? '0'} EGP',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppColor.fourthColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '/ ${p.pricingType ?? 'day'}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? Colors.white54 : AppColor.lightText,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            if (item.defaultDeposit != null && item.defaultDeposit! > 0) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.shield_outlined,
                                      size: 16, color: AppColor.successColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Deposit: ${item.defaultDeposit!.toStringAsFixed(0)} EGP',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.successColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      _divider(isDark),
                    ],

                    // ── Description ──
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColor.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.descEn ?? item.descAr ?? 'No description available.',
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.white70 : AppColor.mediumText,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _divider(isDark),

                    // ── Details (Type, Condition, Category) ──
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColor.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _detailRow('Type', item.type ?? 'N/A', isDark),
                          _detailRow('Condition', item.condition ?? 'N/A', isDark),
                          if (item.category != null)
                            _detailRow('Category',
                                item.category!.nameEn ?? item.category!.nameAr ?? '', isDark),
                          if (item.subcategory != null)
                            _detailRow('Subcategory',
                                item.subcategory!.nameEn ?? item.subcategory!.nameAr ?? '', isDark),
                          if (item.brand != null)
                            _detailRow('Brand',
                                item.brand!.nameEn ?? item.brand!.nameAr ?? '', isDark),
                        ],
                      ),
                    ),
                    _divider(isDark),

                    // ── Owner ──
                    if (item.owner != null)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PublicProfilePage(
                                userId: '',
                                userName: item.owner!.firstName ?? 'Owner',
                                userCity: item.owner!.city,
                                userImageUrl: item.owner!.profileImageUrl,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColor.fourthColor.withOpacity(0.1),
                                backgroundImage: item.owner!.profileImageUrl != null
                                    ? CachedNetworkImageProvider(item.owner!.profileImageUrl!)
                                    : null,
                                child: item.owner!.profileImageUrl == null
                                    ? Icon(Icons.person, color: AppColor.fourthColor)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.owner!.firstName ?? 'Owner',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : AppColor.darkText,
                                      ),
                                    ),
                                    if (item.owner!.city != null)
                                      Text(
                                        item.owner!.city!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? Colors.white54 : AppColor.lightText,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Chat with Owner button (only when ownerId available)
                              Obx(() => controller.ownerId.value != null
                                ? SizedBox(
                                    height: 36,
                                    child: ElevatedButton.icon(
                                      onPressed: controller.isChatting.value
                                          ? null
                                          : controller.startChat,
                                      icon: controller.isChatting.value
                                          ? SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Icon(Icons.chat_bubble_outline, size: 16),
                                      label: Text(
                                        controller.isChatting.value ? 'Opening...' : 'Chat',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColor.fourthColor,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  )
                                : Icon(Icons.chevron_right_rounded,
                                    color: isDark ? Colors.white38 : Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Reviews with Star Distribution ──
                    if (controller.reviews.isNotEmpty) ...[
                      _divider(isDark),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reviews (${controller.totalReviews.value})',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColor.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Star distribution chart (like Web)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Avg rating display
                                Column(
                                  children: [
                                    Text(
                                      controller.avgRating.value.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : AppColor.darkText,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(5, (i) => Icon(
                                        i < controller.avgRating.value.round()
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 16,
                                        color: const Color(0xFFFFB800),
                                      )),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${controller.totalReviews.value} reviews',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white54 : AppColor.lightText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 24),
                                // Bar chart
                                Expanded(
                                  child: Column(
                                    children: List.generate(5, (index) {
                                      final star = 5 - index;
                                      final pct = controller.getStarPercent(star);
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 14,
                                              child: Text(
                                                '$star',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark ? Colors.white54 : AppColor.lightText,
                                                ),
                                              ),
                                            ),
                                            Icon(Icons.star_rounded, size: 12, color: const Color(0xFFFFB800)),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  value: pct / 100,
                                                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                                  valueColor: AlwaysStoppedAnimation(
                                                    const Color(0xFFFFB800),
                                                  ),
                                                  minHeight: 8,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 30,
                                              child: Text(
                                                '${pct.round()}%',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark ? Colors.white54 : AppColor.lightText,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...controller.reviews.take(5).map(
                                  (review) => _ReviewCard(review: review, isDark: isDark),
                                ),
                          ],
                        ),
                      ),
                    ],

                    // ── Similar Items ──
                    Obx(() {
                      if (controller.similarItems.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _divider(isDark),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Text(
                              'Similar Items',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColor.primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: controller.similarItems.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final si = controller.similarItems[index];
                                return GestureDetector(
                                  onTap: () {
                                    Get.off(() => const ItemDetailPage(),
                                        arguments: {'itemId': si.id});
                                  },
                                  child: Container(
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(14)),
                                          child: CachedNetworkImage(
                                            imageUrl: si.primaryImage ?? '',
                                            height: 110,
                                            width: 150,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                            ),
                                            errorWidget: (_, __, ___) => Container(
                                              color: Colors.grey[200],
                                              height: 110,
                                              child: const Icon(Icons.image_outlined,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                si.titleEn ?? si.titleAr ?? '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark ? Colors.white : AppColor.darkText,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              if (si.dailyPrice != null)
                                                Text(
                                                  '${si.dailyPrice!.toStringAsFixed(0)} EGP',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColor.fourthColor,
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
                    }),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        );
      }),

      // ── Bottom Action Bar ──
      bottomNavigationBar: Obx(() {
        if (controller.item.value == null) return const SizedBox.shrink();
        final item = controller.item.value!;
        final price = item.pricing?.firstOrNull?.price;

        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            12 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (price != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${price.toStringAsFixed(0)} EGP',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColor.fourthColor,
                      ),
                    ),
                    Text(
                      '/ ${item.pricing!.first.pricingType ?? 'day'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : AppColor.lightText,
                      ),
                    ),
                  ],
                ),
              const Spacer(),
              // Show Buy Now for sell/both items
              if (item.type?.toLowerCase() == 'sell' ||
                  item.type?.toLowerCase() == 'both')
                Padding(
                  padding: EdgeInsets.only(
                      right: item.type?.toLowerCase() == 'both' ? 8 : 0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutPage(
                            items: [
                              CheckoutItem(
                                itemId: item.id ?? '',
                                title: item.titleEn ?? item.titleAr ?? 'Untitled',
                                price: price?.toDouble() ?? 0,
                                quantity: 1,
                                imageUrl: item.images?.firstOrNull?.imageUrl,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              // Show Rent Now for rent/both items
              if (item.type?.toLowerCase() != 'sell')
                ElevatedButton(
                  onPressed: () {
                    Get.put(RentalsController());
                    num? dailyP, weeklyP, monthlyP;
                    for (final p in (item.pricing ?? [])) {
                      switch (p.pricingType?.toLowerCase()) {
                        case 'daily': dailyP = p.price; break;
                        case 'weekly': weeklyP = p.price; break;
                        case 'monthly': monthlyP = p.price; break;
                      }
                    }
                    dailyP ??= price;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateRentalPage(
                          itemId: item.id ?? '',
                          itemTitle: item.titleEn ?? item.titleAr ?? 'Untitled',
                          dailyPrice: dailyP,
                          weeklyPrice: weeklyP,
                          monthlyPrice: monthlyP,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.fourthColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Rent Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : AppColor.lightText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColor.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColor.successColor;
      case 'rented':
        return AppColor.fourthColor;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColor.grey;
    }
  }
}

class _ImageGallery extends StatefulWidget {
  final List<ItemImageDto> images;
  final ItemImageDto? primaryImage;

  const _ImageGallery({required this.images, this.primaryImage});

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_outlined, size: 80, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            final image = widget.images[index];
            return CachedNetworkImage(
              imageUrl: image.imageUrl ?? '',
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
              ),
            );
          },
        ),
        // Page indicator
        if (widget.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => Container(
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        // Image counter
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentPage + 1}/${widget.images.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewDto review;
  final bool isDark;

  const _ReviewCard({required this.review, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColor.fourthColor.withOpacity(0.1),
                backgroundImage: review.reviewer?.profileImageUrl != null
                    ? CachedNetworkImageProvider(review.reviewer!.profileImageUrl!)
                    : null,
                child: review.reviewer?.profileImageUrl == null
                    ? Icon(Icons.person, size: 16, color: AppColor.fourthColor)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                review.reviewer?.firstName ?? 'User',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColor.darkText,
                ),
              ),
              const Spacer(),
              ...List.generate(
                5,
                (i) => Icon(
                  i < (review.rating ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 16,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : AppColor.mediumText,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
