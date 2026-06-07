import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';

class HomeItemCard extends StatelessWidget {
  final ItemListDto item;
  const HomeItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColor.fourthColor),
                              ),
                            ),
                            errorWidget: (_, __, ___) => _imagePlaceholder(isDark),
                          )
                        : _imagePlaceholder(isDark),
                    if (item.type != null)
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColor.fourthColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.type!,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
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
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColor.fourthColor,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (item.avgRating != null && item.avgRating! > 0) ...[
                          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text(
                            item.avgRating!.toStringAsFixed(1),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : AppColor.mediumText),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (item.city != null)
                          Expanded(
                            child: Text(
                              item.city!,
                              style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : AppColor.lightText),
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

  Widget _imagePlaceholder(bool isDark) => Container(
    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
    child: Icon(Icons.image_outlined,
        color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8), size: 40),
  );
}
