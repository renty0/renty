import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';

/// Auto-scrolling carousel for "Recommended For You" items.
class HomeSuggested extends StatefulWidget {
  final List<ItemListDto> items;
  const HomeSuggested({super.key, required this.items});

  @override
  State<HomeSuggested> createState() => _HomeSuggestedState();
}

class _HomeSuggestedState extends State<HomeSuggested> {
  late final PageController _pageCtrl;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.82);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted || widget.items.isEmpty) return;
      final next = (_current + 1) % widget.items.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.items.length,
            itemBuilder: (context, i) {
              final item = widget.items[i];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                margin: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: _current == i ? 0 : 10,
                ),
                child: GestureDetector(
                  onTap: () => AppNavigator.pushNamed('/item-detail', arguments: {'itemId': item.id}),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        item.primaryImage != null && item.primaryImage!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.primaryImage!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB))),
                                ),
                                errorWidget: (_, __, ___) => _fallback(),
                              )
                            : _fallback(),

                        // Gradient overlay
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xDD0F172A)],
                              stops: [0.35, 1.0],
                            ),
                          ),
                        ),

                        // Badge
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColor.primaryColor, AppColor.fourthColor],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome_rounded, size: 11, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'Recommended'.tr,
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom info
                        Positioned(
                          bottom: 14,
                          left: 14,
                          right: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.titleEn ?? item.titleAr ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (item.dailyPrice != null) ...[
                                    Text(
                                      '${item.dailyPrice!.toStringAsFixed(0)} EGP/day',
                                      style: const TextStyle(
                                        color: Color(0xFF93C5FD),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  if (item.avgRating != null && item.avgRating! > 0) ...[
                                    const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                                    const SizedBox(width: 2),
                                    Text(
                                      item.avgRating!.toStringAsFixed(1),
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                  const Spacer(),
                                  if (item.city != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.location_on_rounded, size: 12, color: Colors.white54),
                                        const SizedBox(width: 2),
                                        Text(
                                          item.city!,
                                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Page indicator dots
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppColor.fourthColor : (AppColor.fourthColor.withValues(alpha: 0.25)),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _fallback() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF1A365D), Color(0xFF2563EB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: const Center(
      child: Icon(Icons.image_outlined, color: Colors.white24, size: 48),
    ),
  );
}
