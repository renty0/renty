import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Home / Dashboard landing page matching the web's home component.
/// Hero section, category cards, how-it-works steps, and stats.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            const SizedBox(height: 32),
            _buildCategories(),
            const SizedBox(height: 40),
            _buildHowItWorks(),
            const SizedBox(height: 40),
            _buildStats(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Hero Section ────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 40,
        bottom: 40,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C295E), Color(0xFF1A3A6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Renty',
              style: AppTextStyles.heading1.copyWith(
                  color: AppColors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Rent anything,\nanytime, anywhere.',
              style: AppTextStyles.heading2.copyWith(
                  color: AppColors.white.withValues(alpha: 0.85),
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  height: 1.4)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/marketplace'),
                  icon: const Icon(Icons.search, size: 20),
                  label: const Text('Browse Items'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed('/my-items'),
                  icon: const Icon(Icons.add_box_outlined, size: 20),
                  label: const Text('List Item'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.white),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Categories Grid (matching web) ──────────────────────────
  Widget _buildCategories() {
    final categories = [
      {'name': 'Electronics', 'icon': Icons.devices},
      {'name': 'Tools', 'icon': Icons.construction},
      {'name': 'Furniture', 'icon': Icons.chair},
      {'name': 'Cameras', 'icon': Icons.photo_camera},
      {'name': 'Sports', 'icon': Icons.sports_soccer},
      {'name': 'Party', 'icon': Icons.celebration},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Browse by Category',
              style: AppTextStyles.heading2.copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final cat = categories[i];
              return GestureDetector(
                onTap: () => Get.toNamed('/marketplace'),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.gray100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(cat['icon'] as IconData,
                            color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(cat['name'] as String,
                          style: AppTextStyles.captionSmall.copyWith(
                              fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── How It Works (matching web steps) ───────────────────────
  Widget _buildHowItWorks() {
    final steps = [
      {
        'icon': Icons.search,
        'title': 'Find What You Need',
        'desc': 'Browse thousands of items available for rent.'
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Book & Pay',
        'desc': 'Select your dates and complete your booking.'
      },
      {
        'icon': Icons.shopping_bag_outlined,
        'title': 'Enjoy & Return',
        'desc': 'Use the item and return it when you\'re done.'
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How It Works',
              style: AppTextStyles.heading2.copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((e) {
            final i = e.key;
            final step = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.gray100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0C295E), Color(0xFF1A3A6E)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text('${i + 1}',
                          style: AppTextStyles.heading2.copyWith(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step['title'] as String,
                            style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(step['desc'] as String,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.gray500)),
                      ],
                    ),
                  ),
                  Icon(step['icon'] as IconData,
                      color: AppColors.primary, size: 28),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Stats (matching web stats section) ──────────────────────
  Widget _buildStats() {
    final stats = [
      {'value': '50k+', 'label': 'Items Available'},
      {'value': '100+', 'label': 'Cities'},
      {'value': '25k+', 'label': 'Happy Users'},
      {'value': '4.9/5', 'label': 'Avg Rating'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0C295E), Color(0xFF1A3A6E)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceAround,
          runSpacing: 20,
          children: stats.map((s) {
            return SizedBox(
              width: 140,
              child: Column(
                children: [
                  Text(s['value']!,
                      style: AppTextStyles.heading1.copyWith(
                          color: AppColors.accent,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(s['label']!,
                      style: AppTextStyles.captionSmall.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                          fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
