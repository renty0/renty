import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/pages/chat_room_page.dart';

class ItemDetailController extends GetxController {
  final isLoading = true.obs;
  final item = Rxn<ApiResponseOfItemDetailDtoData>();
  final reviews = <ReviewDto>[].obs;
  final avgRating = 0.0.obs;
  final totalReviews = 0.obs;
  final isFavorite = false.obs;
  final isFavoriteLoading = false.obs;
  final errorMessage = ''.obs;
  final similarItems = <ItemListDto>[].obs;
  final isLoadingSimilar = false.obs;
  final isChatting = false.obs;
  final ownerId = Rxn<int>();

  // ── New: Availability ──
  final bookedRanges = <Map<String, DateTime>>[].obs;
  final isLoadingAvailability = false.obs;

  // ── New: Reminder ──
  final isReminded = false.obs;

  // ── New: Review submission ──
  final isSubmittingReview = false.obs;
  final hasRentedItem = false.obs;

  String? itemId;

  void loadItem(String id) {
    itemId = id;
    _fetchItemDetail();
    _fetchReviews();
    _checkFavorite();
    _fetchAvailability();
    _checkReminder();
    _checkUserHasRented();
  }

  /// Star distribution: count of reviews per star level (1–5)
  int getStarCount(int star) {
    return reviews.where((r) => (r.rating ?? 0).round() == star).length;
  }

  double getStarPercent(int star) {
    if (totalReviews.value == 0) return 0;
    return (getStarCount(star) / totalReviews.value) * 100;
  }

  Future<void> _fetchItemDetail() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // Single API call — extract ownerId from raw JSON, then parse typed DTO
      final rawResponse = await ApiService.items.getItemByIdWithHttpInfo(itemId!);
      if (rawResponse.statusCode == 200 && rawResponse.body.isNotEmpty) {
        final body = jsonDecode(rawResponse.body);
        final data = body['data'];
        if (data != null) {
          // ownerId lives inside owner.id (Web's OwnerDto has id but mobile's doesn't)
          final owner = data['owner'];
          if (owner != null && owner['id'] != null) {
            ownerId.value = owner['id'] is int
                ? owner['id']
                : int.tryParse(owner['id'].toString());
          }
        }
      }
      final response = await ApiService.items.getItemById(itemId!);
      if (response != null && response.data != null) {
        item.value = response.data!;
        _loadSimilarItems();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load item details';
      print('ItemDetailController error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSimilarItems() async {
    final categoryId = item.value?.category?.id;
    if (categoryId == null) return;
    isLoadingSimilar.value = true;
    try {
      final response = await ApiService.items.getItems(1, 8, categoryId: categoryId);
      if (response != null && response.data != null) {
        final items = response.data!
            .where((it) => it.id != itemId)
            .take(6)
            .toList();
        similarItems.assignAll(items);
      }
    } catch (e) {
      print('Error loading similar items: $e');
    } finally {
      isLoadingSimilar.value = false;
    }
  }

  // ── Availability (raw API — not in generated client) ──

  Future<void> _fetchAvailability() async {
    isLoadingAvailability.value = true;
    try {
      final response = await ApiService.items.apiClient.invokeAPI(
        '/api/v1/items/$itemId/availability',
        'GET', [], null, {}, {}, null,
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        if (data is List) {
          bookedRanges.assignAll(data.map<Map<String, DateTime>>((range) {
            return {
              'start': DateTime.parse(range['start']),
              'end': DateTime.parse(range['end']),
            };
          }).toList());
        }
      }
    } catch (e) {
      print('Error loading availability: $e');
    } finally {
      isLoadingAvailability.value = false;
    }
  }

  bool isDateBooked(DateTime day) {
    for (final range in bookedRanges) {
      final start = range['start']!;
      final end = range['end']!;
      if (!day.isBefore(start) && !day.isAfter(end)) return true;
    }
    return false;
  }

  // ── Reminder (raw API — not in generated client) ──

  Future<void> _checkReminder() async {
    if (!ApiService.isAuthenticated) return;
    try {
      final response = await ApiService.items.apiClient.invokeAPI(
        '/api/v1/items/$itemId/remind',
        'GET', [], null, {}, {}, null,
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final body = jsonDecode(response.body);
        isReminded.value = body['data']?['isReminded'] == true;
      }
    } catch (_) {}
  }

  Future<void> toggleReminder() async {
    if (!ApiService.isAuthenticated) {
      _showSnackbar(icon: Icons.login, message: 'Please login first', color: AppColor.fourthColor);
      return;
    }
    try {
      final method = isReminded.value ? 'DELETE' : 'POST';
      final response = await ApiService.items.apiClient.invokeAPI(
        '/api/v1/items/$itemId/remind',
        method, [], null, {}, {}, null,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        isReminded.value = !isReminded.value;
        _showSnackbar(
          icon: isReminded.value ? Icons.notifications_active : Icons.notifications_off,
          message: isReminded.value ? 'Reminder set' : 'Reminder removed',
          color: isReminded.value ? AppColor.fourthColor : Colors.grey[700]!,
        );
      }
    } catch (e) {
      _showSnackbar(icon: Icons.error_outline, message: 'Failed to update reminder', color: const Color(0xFFDC2626));
    }
  }

  // ── Check if user has rented this item (to show/hide review form) ──

  Future<void> _checkUserHasRented() async {
    if (!ApiService.isAuthenticated) return;
    try {
      final response = await ApiService.rentals.getRentals(1, 100);
      if (response != null && response.data != null) {
        // RentalListDto doesn't have itemId, match by itemTitle
        final currentTitle = item.value?.titleEn;
        hasRentedItem.value = currentTitle != null &&
            response.data!.rentals.any((r) => r.itemTitle == currentTitle);
      }
    } catch (_) {}
  }

  // ── Submit Review (raw API — not in generated client) ──

  Future<void> submitReview(int rating, String comment) async {
    if (!ApiService.isAuthenticated) {
      _showSnackbar(icon: Icons.login, message: 'Please login to review', color: AppColor.fourthColor);
      return;
    }
    isSubmittingReview.value = true;
    try {
      final body = jsonEncode({'rating': rating, 'comment': comment});
      final response = await ApiService.items.apiClient.invokeAPI(
        '/api/v1/items/$itemId/reviews',
        'POST', [], body, {'Content-Type': 'application/json'}, {}, 'application/json',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSnackbar(icon: Icons.check_circle, message: 'Review submitted!', color: AppColor.successColor);
        _fetchReviews(); // Refresh reviews list
      } else {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final messages = errorBody['messages'];
        final msg = (messages is List && messages.isNotEmpty) ? messages.first.toString() : 'Failed to submit review';
        _showSnackbar(icon: Icons.error_outline, message: msg, color: const Color(0xFFDC2626));
      }
    } catch (e) {
      _showSnackbar(icon: Icons.error_outline, message: 'Failed to submit review', color: const Color(0xFFDC2626));
    } finally {
      isSubmittingReview.value = false;
    }
  }

  // ── Chat ──

  Future<void> startChat() async {
    if (ownerId.value == null) {
      _showSnackbar(
        icon: Icons.error_outline,
        message: 'Owner information not available',
        color: Colors.grey[700]!,
      );
      return;
    }
    if (isChatting.value) return;
    isChatting.value = true;
    try {
      final cmd = CreateChatCommand(userId: ownerId.value);
      final response = await ApiService.chat.createChat(cmd);
      final chatId = response?.data?.chatId;
      if (chatId != null) {
        Get.to(() => ChatRoomPage(
          chatId: chatId,
          otherUserName: item.value?.owner?.firstName ?? 'Owner',
        ));
      } else {
        _showSnackbar(
          icon: Icons.chat,
          message: 'Chat started',
          color: AppColor.fourthColor,
        );
      }
    } catch (e) {
      _showSnackbar(
        icon: Icons.error_outline,
        message: 'Failed to start chat',
        color: Color(0xFFDC2626),
      );
    } finally {
      isChatting.value = false;
    }
  }

  // ── Reviews ──

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

  // ── Favorites ──

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
