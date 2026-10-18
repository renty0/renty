import 'package:flutter/material.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/blocs/blocs.dart';
import 'package:renty/core/utils/app_navigator.dart';

class HomeHero extends StatefulWidget {
  final List<ItemListDto> suggestedItems;
  const HomeHero({super.key, this.suggestedItems = const []});

  @override
  State<HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<HomeHero> {
  late final PageController _pageCtrl;
  int _current = 0;

  // Slide 0 = hero banner, Slide 1 = recommended promo (if items exist)
  int get _totalPages => widget.suggestedItems.isNotEmpty ? 2 : 1;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || _totalPages <= 1) return;
      final next = (_current + 1) % _totalPages;
      _pageCtrl.animateToPage(next,
        duration: const Duration(milliseconds: 600),
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

  // Stats are built dynamically inside build() so .tr works at runtime

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // ── Carousel ──
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemCount: _totalPages,
                  itemBuilder: (_, i) {
                    if (i == 0) return _buildHeroBanner();
                    return _buildRecommendedPromo(isDark);
                  },
                ),
                // Dot indicators
                if (_totalPages > 1)
                  Positioned(
                    bottom: 12,
                    left: 0, right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_totalPages, (i) {
                        final active = i == _current;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: active ? 0.95 : 0.4),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildStatsRow(isDark),
      ],
    );
  }

  // ── Slide 0: Hero banner ──
  Widget _buildHeroBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E40AF), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(right: -20, top: -30, child: _decorCircle(160, 0.05)),
          Positioned(right: 30, bottom: -40, child: _decorCircle(120, 0.04)),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rent Anything,\nAnytime.'.tr,
                  style: const TextStyle(color: Colors.white, fontSize: 26,
                      fontWeight: FontWeight.w900, height: 1.15, letterSpacing: -0.6)),
                const SizedBox(height: 6),
                Text('Thousands of items available near you'.tr,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    try { NavigationCubit.instance.switchToTab(3); } catch (_) {}
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.8), size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Search items to rent...'.tr,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                        overflow: TextOverflow.ellipsis)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Slide 1: "Recommended For You" promo ──
  Widget _buildRecommendedPromo(bool isDark) {
    final count = widget.suggestedItems.length;
    return GestureDetector(
      onTap: () => AppNavigator.pushNamed('/recommended-items'),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E40AF), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative glow
            Positioned(right: -30, top: -20, child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppColor.fourthColor.withValues(alpha: 0.08)),
            )),
            Positioned(left: -20, bottom: -30, child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppColor.primaryColor.withValues(alpha: 0.06)),
            )),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColor.primaryColor, AppColor.fourthColor]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 5),
                      Text('Picked For You'.tr, style: const TextStyle(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Text('Recommended Items'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 22,
                        fontWeight: FontWeight.w900, height: 1.15, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('$count ${'items curated just for you'.tr}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                  const Spacer(),
                  // CTA
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColor.fourthColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Explore Now'.tr, style: const TextStyle(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: opacity)),
  );

  Widget _buildStatsRow(bool isDark) {
    final stats = [
      {'value': '10k+', 'label': 'Items'.tr},
      {'value': '20+',  'label': 'Cities'.tr},
      {'value': '15k+', 'label': 'Users'.tr},
      {'value': '4.9',  'label': 'Rating'.tr},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: stats.map((s) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 8, offset: const Offset(0, 2),
              )],
            ),
            child: Column(children: [
              Text(s['value']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                  color: AppColor.primaryColor, letterSpacing: -0.3)),
              const SizedBox(height: 2),
              Text(s['label']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : AppColor.mediumText)),
            ]),
          ),
        )).toList(),
      ),
    );
  }
}
