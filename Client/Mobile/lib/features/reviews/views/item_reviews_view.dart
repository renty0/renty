import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/reviews_controller.dart';

/// Displays reviews for a specific item — rating summary + review list.
class ItemReviewsView extends StatefulWidget {
  final String itemId;
  final String itemTitle;

  const ItemReviewsView({
    super.key,
    required this.itemId,
    required this.itemTitle,
  });

  @override
  State<ItemReviewsView> createState() => _ItemReviewsViewState();
}

class _ItemReviewsViewState extends State<ItemReviewsView> {
  late final ReviewsController _ctrl;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ReviewsController>()) {
      Get.put(ReviewsController());
    }
    _ctrl = Get.find<ReviewsController>();
    _ctrl.loadItemReviews(widget.itemId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text('Reviews',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value && _ctrl.reviews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => _ctrl.loadItemReviews(widget.itemId),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Rating Summary ──
              _buildRatingSummary(),
              const SizedBox(height: 20),

              // ── Reviews list ──
              if (_ctrl.reviews.isEmpty)
                _buildEmptyState()
              else
                ..._ctrl.reviews.map((r) => _ReviewCard(review: r)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRatingSummary() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gray100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Big average number
              Column(
                children: [
                  Text(
                    _ctrl.averageRating.value.toStringAsFixed(1),
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStarRow(
                      _ctrl.averageRating.value, 20, AppColors.accent),
                  const SizedBox(height: 6),
                  Text(
                    '${_ctrl.totalReviews.value} reviews',
                    style: AppTextStyles.captionSmall
                        .copyWith(color: AppColors.gray500),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Star distribution (visual)
              Expanded(
                child: Column(
                  children: List.generate(5, (i) {
                    final star = 5 - i;
                    final count = _ctrl.reviews
                        .where(
                            (r) => (r['rating'] as num?)?.toInt() == star)
                        .length;
                    final pct = _ctrl.reviews.isNotEmpty
                        ? count / _ctrl.reviews.length
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text('$star',
                              style: AppTextStyles.captionSmall
                                  .copyWith(fontSize: 12)),
                          const SizedBox(width: 4),
                          const Icon(Icons.star,
                              size: 12, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                backgroundColor: AppColors.gray100,
                                valueColor:
                                    const AlwaysStoppedAnimation(
                                        Color(0xFFF59E0B)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 20,
                            child: Text('$count',
                                style: AppTextStyles.captionSmall
                                    .copyWith(fontSize: 11),
                                textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined, size: 64, color: AppColors.gray300),
          const SizedBox(height: 16),
          Text('No reviews yet',
              style: AppTextStyles.heading3.copyWith(color: AppColors.gray500)),
          const SizedBox(height: 8),
          Text('Be the first to review this item!',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  static Widget _buildStarRow(double rating, double size, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star, size: size, color: color);
        } else if (i < rating) {
          return Icon(Icons.star_half, size: size, color: color);
        }
        return Icon(Icons.star_border, size: size, color: color);
      }),
    );
  }
}

/// Individual review card.
class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final rating = (review['rating'] as num?)?.toInt() ?? 0;
    final comment = review['comment']?.toString() ?? '';
    final createdAt = review['createdAt']?.toString() ?? '';
    final reviewer = review['reviewer'] ?? review['user'];
    String reviewerName = 'Anonymous';
    if (reviewer is Map<String, dynamic>) {
      final first = reviewer['firstName'] ?? '';
      final last = reviewer['lastName'] ?? '';
      reviewerName = '$first $last'.trim();
      if (reviewerName.isEmpty) reviewerName = 'Anonymous';
    }

    String dateText = '';
    try {
      final dt = DateTime.parse(createdAt);
      dateText = '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    reviewerName.isNotEmpty ? reviewerName[0].toUpperCase() : '?',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reviewerName,
                        style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < rating ? Icons.star : Icons.star_border,
                            size: 14,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                        if (dateText.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(dateText,
                              style: AppTextStyles.captionSmall
                                  .copyWith(fontSize: 10, color: AppColors.gray400)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(comment,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray700, height: 1.4)),
          ],
        ],
      ),
    );
  }
}
