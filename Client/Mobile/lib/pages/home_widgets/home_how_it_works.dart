import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/utils/language_manager.dart';

class HomeHowItWorks extends StatelessWidget {
  const HomeHowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = [
      {'icon': Icons.search_rounded,        'title': 'Find'.tr,   'desc': 'Browse thousands of items near you'.tr},
      {'icon': Icons.calendar_today_rounded, 'title': 'Book'.tr,   'desc': 'Pick dates & confirm instantly'.tr},
      {'icon': Icons.celebration_rounded,   'title': 'Enjoy'.tr,  'desc': 'Receive your item & have fun'.tr},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector arrow — fixed-width so it sits between Expanded children
            return SizedBox(
              width: 24,
              child: Icon(
                LanguageManager.isArabic()
                    ? Icons.arrow_back_rounded
                    : Icons.arrow_forward_rounded,
                size: 18,
                color: AppColor.primaryColor.withValues(alpha: 0.4),
              ),
            );
          }
          final step = steps[i ~/ 2];
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Step icon with number badge
                SizedBox(
                  width: 60, height: 60,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Positioned(
                        left: 4, bottom: 4,
                        child: Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColor.primaryColor.withValues(alpha: 0.15)
                                : AppColor.primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            step['icon'] as IconData,
                            color: AppColor.primaryColor,
                            size: 26,
                          ),
                        ),
                      ),
                      Container(
                        width: 18, height: 18,
                        decoration: const BoxDecoration(
                          color: AppColor.fourthColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i ~/ 2 + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step['title'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColor.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step['desc'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white54 : AppColor.mediumText,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
