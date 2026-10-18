import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/utils/app_navigator.dart';

class HomeCategories extends StatelessWidget {
  final List<ProductCategoryDto> categories;
  const HomeCategories({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: categories.length > 6 ? 6 : categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => AppNavigator.pushNamed('/marketplace', arguments: {'categoryId': cat.id}),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: 8, offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image or gradient
                    cat.logoUrl != null && cat.logoUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: cat.logoUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _gradientBg(index),
                          )
                        : _gradientBg(index),
                    // Dark overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.65),
                          ],
                        ),
                      ),
                    ),
                    // Name
                    Positioned(
                      bottom: 8, left: 6, right: 6,
                      child: Text(
                        cat.nameEn ?? cat.nameAr ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Fallback gradient backgrounds cycling through brand colors
  static const _gradients = [
    [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    [Color(0xFF059669), Color(0xFF047857)],
    [Color(0xFFF59E0B), Color(0xFFD97706)],
    [Color(0xFF7C3AED), Color(0xFF6D28D9)],
    [Color(0xFFDB2777), Color(0xFFBE185D)],
    [Color(0xFF0891B2), Color(0xFF0E7490)],
  ];

  Widget _gradientBg(int index) {
    final colors = _gradients[index % _gradients.length];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.category_outlined, color: Colors.white.withOpacity(0.4), size: 36),
    );
  }
}
