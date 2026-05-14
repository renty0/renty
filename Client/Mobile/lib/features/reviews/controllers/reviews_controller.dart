import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

/// GetX controller for Reviews.
/// Swagger: POST /api/v1/rentals/{rentalId}/review, GET /api/v1/items/{itemId}/reviews
class ReviewsController extends GetxController {
  final _api = ApiService.instance;

  // ── Item reviews list ─────────────────────────────────────────
  final reviews = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // ── Review form ───────────────────────────────────────────────
  final rating = 0.obs;
  final comment = ''.obs;

  // ── Stats ─────────────────────────────────────────────────────
  final averageRating = 0.0.obs;
  final totalReviews = 0.obs;

  // ── Load Reviews for an Item ──────────────────────────────────

  Future<void> loadItemReviews(String itemId) async {
    isLoading.value = true;
    try {
      final res = await _api.get(
        ApiEndpoints.itemReviews(itemId),
        authenticated: true,
      );
      final error = res['error'] as bool? ?? true;
      if (!error) {
        final data = res['data'];
        if (data is List) {
          reviews.value = data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          final list = data['reviews'];
          if (list is List) {
            reviews.value = list.cast<Map<String, dynamic>>();
          }
          averageRating.value =
              (data['avgRating'] as num?)?.toDouble() ??
              (data['averageRating'] as num?)?.toDouble() ?? 0.0;
          totalReviews.value = (data['totalReviews'] as int?) ?? reviews.length;
        }
        // Calculate average if not provided
        if (averageRating.value == 0.0 && reviews.isNotEmpty) {
          double sum = 0;
          for (final r in reviews) {
            sum += (r['rating'] as num?)?.toDouble() ?? 0;
          }
          averageRating.value = sum / reviews.length;
          totalReviews.value = reviews.length;
        }
      }
    } catch (_) {
      // Silent
    } finally {
      isLoading.value = false;
    }
  }

  // ── Submit Review for a Rental ────────────────────────────────

  Future<bool> submitReview(String rentalId) async {
    if (rating.value < 1) {
      Get.snackbar('Error', 'Please select a rating',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'rentalId': rentalId,
        'rating': rating.value,
        'comment': comment.value.trim(),
      };

      final res = await _api.post(
        ApiEndpoints.createReview(rentalId),
        body,
        authenticated: true,
      );

      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Review submitted!',
            snackPosition: SnackPosition.BOTTOM);
        _resetForm();
        return true;
      } else {
        final messages = (res['messages'] as List?)?.cast<String>() ?? [];
        final msg = messages.isNotEmpty ? messages[0] : 'Failed to submit';
        Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to submit review',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void _resetForm() {
    rating.value = 0;
    comment.value = '';
  }
}
