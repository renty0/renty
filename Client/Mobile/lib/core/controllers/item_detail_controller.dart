import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';

class ItemDetailController extends GetxController {
  final isLoading = true.obs;
  final item = Rxn<ApiResponseOfItemDetailDtoData>();
  final reviews = <ReviewDto>[].obs;
  final avgRating = 0.0.obs;
  final totalReviews = 0.obs;
  final isFavorite = false.obs;
  final isFavoriteLoading = false.obs;
  final errorMessage = ''.obs;

  String? itemId;

  void loadItem(String id) {
    itemId = id;
    _fetchItemDetail();
    _fetchReviews();
    _checkFavorite();
  }

  Future<void> _fetchItemDetail() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.items.getItemById(itemId!);
      if (response != null && response.data != null) {
        item.value = response.data!;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load item details';
      print('ItemDetailController error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchReviews() async {
    try {
      final response = await ApiService.reviews.getItemReviews(itemId!);
      if (response != null && response.data != null) {
        reviews.assignAll(List<ReviewDto>.from(response.data!.reviews ?? []));
        avgRating.value = response.data!.avgRating?.toDouble() ?? 0.0;
        totalReviews.value = response.data!.totalReviews ?? 0;
      }
    } catch (e) {
      print('Error loading reviews: $e');
    }
  }

  Future<void> _checkFavorite() async {
    if (!ApiService.isAuthenticated) return;
    try {
      final response = await ApiService.favorites.getMyFavorites();
      if (response != null && response.data != null) {
        final favItems = response.data!.items ?? [];
        isFavorite.value = favItems.any((f) => f.id == itemId);
      }
    } catch (e) {
      print('Error checking favorite: $e');
    }
  }

  Future<void> toggleFavorite() async {
    if (!ApiService.isAuthenticated) {
      _showSnackbar(
        icon: Icons.login,
        message: 'Please login to manage favorites',
        color: AppColor.fourthColor,
      );
      return;
    }

    if (isFavoriteLoading.value) return; // Prevent double-tap
    isFavoriteLoading.value = true;

    final wasInFavorites = isFavorite.value;

    // Optimistic UI update — toggle immediately for snappy UX
    isFavorite.value = !wasInFavorites;

    try {
      if (wasInFavorites) {
        // ── REMOVE ──
        await ApiService.favorites.removeFavorite(itemId!);
        _showSnackbar(
          icon: Icons.heart_broken_rounded,
          message: 'Removed from favorites',
          color: Colors.grey[700]!,
        );
      } else {
        // ── ADD ──
        await ApiService.favorites.addFavorite(itemId!);
        _showSnackbar(
          icon: Icons.favorite_rounded,
          message: 'Added to favorites',
          color: AppColor.fourthColor,
        );
      }
    } on ApiException catch (e) {
      final errorBody = _parseErrorMessages(e);

      // Handle "Already in favorites" (400) — treat as success
      if (e.code == 400 && errorBody.toLowerCase().contains('already')) {
        isFavorite.value = true; // It IS in favorites
        _showSnackbar(
          icon: Icons.favorite_rounded,
          message: 'Already in favorites',
          color: AppColor.fourthColor,
        );
        return;
      }

      // Handle "Not found in favorites" (404) — treat as success
      if (e.code == 404 || errorBody.toLowerCase().contains('not found')) {
        isFavorite.value = false; // It's NOT in favorites
        _showSnackbar(
          icon: Icons.heart_broken_rounded,
          message: 'Removed from favorites',
          color: Colors.grey[700]!,
        );
        return;
      }

      // Real error — revert optimistic update
      isFavorite.value = wasInFavorites;
      _showSnackbar(
        icon: Icons.error_outline,
        message: 'Failed to update favorites',
        color: Color(0xFFDC2626),
      );
    } catch (e) {
      // Real error — revert optimistic update
      isFavorite.value = wasInFavorites;
      _showSnackbar(
        icon: Icons.error_outline,
        message: 'Failed to update favorites',
        color: Color(0xFFDC2626),
      );
    } finally {
      isFavoriteLoading.value = false;
    }
  }

  String _parseErrorMessages(ApiException e) {
    try {
      if (e.message != null && e.message!.isNotEmpty) {
        final body = jsonDecode(e.message!);
        if (body is Map) {
          final messages = body['messages'];
          if (messages is List && messages.isNotEmpty) {
            return messages.first.toString();
          }
        }
      }
    } catch (_) {}
    return '';
  }

  void _showSnackbar({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    Get.showSnackbar(GetSnackBar(
      messageText: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      message: '',
      backgroundColor: color,
      borderRadius: 12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      animationDuration: const Duration(milliseconds: 300),
    ));
  }
}
