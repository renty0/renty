import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/loading_button.dart';
import '../controllers/reviews_controller.dart';

/// Bottom sheet for submitting a review after a completed rental.
class CreateReviewSheet extends StatefulWidget {
  final String rentalId;
  final String itemTitle;

  const CreateReviewSheet({
    super.key,
    required this.rentalId,
    required this.itemTitle,
  });

  @override
  State<CreateReviewSheet> createState() => _CreateReviewSheetState();
}

class _CreateReviewSheetState extends State<CreateReviewSheet> {
  late final ReviewsController _ctrl;
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ReviewsController>()) {
      Get.put(ReviewsController());
    }
    _ctrl = Get.find<ReviewsController>();
    _ctrl.rating.value = 0;
    _ctrl.comment.value = '';
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Text('Leave a Review',
                style: AppTextStyles.heading2.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(widget.itemTitle,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.gray500)),
            const SizedBox(height: 24),

            // ── Star Rating ──
            Text('Your Rating',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Center(
              child: Obx(() => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      final starIndex = i + 1;
                      return GestureDetector(
                        onTap: () => _ctrl.rating.value = starIndex,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: AnimatedScale(
                            scale:
                                _ctrl.rating.value >= starIndex ? 1.15 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Icon(
                              _ctrl.rating.value >= starIndex
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 40,
                              color: _ctrl.rating.value >= starIndex
                                  ? const Color(0xFFF59E0B)
                                  : AppColors.gray300,
                            ),
                          ),
                        ),
                      );
                    }),
                  )),
            ),
            const SizedBox(height: 8),
            Center(
              child: Obx(() => Text(
                    _ratingLabel(_ctrl.rating.value),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _ctrl.rating.value > 0
                          ? AppColors.primary
                          : AppColors.gray400,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
            ),
            const SizedBox(height: 24),

            // ── Comment ──
            Text('Comment (optional)',
                style: AppTextStyles.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gray200),
              ),
              child: TextField(
                controller: _commentCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  hintStyle: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.gray400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
                onChanged: (v) => _ctrl.comment.value = v,
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit ──
            Obx(() => LoadingButton(
                  text: 'Submit Review',
                  isLoading: _ctrl.isSubmitting.value,
                  onPressed: () async {
                    _ctrl.comment.value = _commentCtrl.text.trim();
                    final success =
                        await _ctrl.submitReview(widget.rentalId);
                    if (success && context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap to rate';
    }
  }
}
