import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/core/constant/app_colors.dart';

class HomeFeatures extends StatelessWidget {
  const HomeFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final features = [
      {
        'icon': Icons.verified_user_outlined,
        'title': 'Trusted Platform'.tr,
        'desc': 'Verified owners & renters with secure identity checks.'.tr,
        'color': const Color(0xFF2563EB),
      },
      {
        'icon': Icons.wallet_outlined,
        'title': 'Save Money'.tr,
        'desc': 'Rent instead of buy — fraction of the cost.'.tr,
        'color': const Color(0xFF059669),
      },
      {
        'icon': Icons.flash_on_rounded,
        'title': 'Fast Booking'.tr,
        'desc': 'Book in seconds, receive in hours.'.tr,
        'color': const Color(0xFFF59E0B),
      },
    ];

    return SizedBox(
      height: 168,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: features.length,
        itemBuilder: (context, i) {
          final f = features[i];
          final color = f['color'] as Color;
          return Container(
            width: 160,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(f['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  f['title'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColor.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  f['desc'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : AppColor.mediumText,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
