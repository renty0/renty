import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/utils/app_navigator.dart';
import 'package:renty/pages/chat_room_page.dart';
import 'item_detail_state.dart';

class ItemDetailCubit extends Cubit<ItemDetailState> {
  String? itemId;

  ItemDetailCubit() : super(const ItemDetailState());

  void loadItem(String id) {
    itemId = id;
    _fetchItemDetail();
    _fetchReviews();
    _checkFavorite();
    _fetchAvailability();
    _checkReminder();
    _checkUserHasRented();
  }

  Future<void> _fetchItemDetail() async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    try {
      int? foundOwnerId;
      final rawResponse =
          await ApiService.items.getItemByIdWithHttpInfo(itemId!);
      if (rawResponse.statusCode == 200 && rawResponse.body.isNotEmpty) {
        final body = jsonDecode(rawResponse.body);
        final data = body['data'];
        if (data != null) {
          final owner = data['owner'];
          if (owner != null && owner['id'] != null) {
            foundOwnerId = owner['id'] is int
                ? owner['id']
                : int.tryParse(owner['id'].toString());
          }
        }
      }

      final response = await ApiService.items.getItemById(itemId!);
      if (response != null && response.data != null) {
        emit(state.copyWith(
          item: () => response.data!,
          ownerId: () => foundOwnerId,
          isLoading: false,
          errorMessage: '',
        ));
        _loadSimilarItems(response.data!.category?.id);
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      print('ItemDetailCubit error: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load item details',
      ));
    }
  }

  Future<void> _loadSimilarItems(int? categoryId) async {
    if (categoryId == null) return;
    emit(state.copyWith(isLoadingSimilar: true));
    try {
      final response =
          await ApiService.items.getItems(1, 8, categoryId: categoryId);
      if (response != null && response.data != null) {
        final items =
            response.data!.where((it) => it.id != itemId).take(6).toList();
        emit(state.copyWith(
          similarItems: items,
          isLoadingSimilar: false,
        ));
      } else {
        emit(state.copyWith(isLoadingSimilar: false));
      }
    } catch (e) {
      print('Error loading similar items: $e');
      emit(state.copyWith(isLoadingSimilar: false));
    }
  }

  Future<void> _fetchAvailability() async {
    emit(state.copyWith(isLoadingAvailability: true));
    try {
      final response = await ApiService.items.apiClient.invokeAPI(
        '/api/v1/items/$itemId/availability',
        'GET',
        [],
        null,
        {},
        {},
        null,
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        if (data is List) {
          final ranges = data.map<Map<String, DateTime>>((range) {
            return {
              'start': DateTime.parse(range['start']),
              'end': DateTime.parse(range['end']),
            };
          }).toList();
          emit(state.copyWith(
            bookedRanges: ranges,
            isLoadingAvailability: false,
          ));
          return;
        }
      }
      emit(state.copyWith(isLoadingAvailability: false));
    } catch (e) {
      print('Error loading availability: $e');
      emit(state.copyWith(isLoadingAvailability: false));
    }
  }

  Future<void> _checkReminder() async {
    if (!ApiService.isAuthenticated) return;
    try {
      final response = await ApiService.items.apiClient.invokeAPI(
        '/api/v1/items/$itemId/remind',
        'GET',
        [],
        null,
        {},
        {},
        null,
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final body = jsonDecode(response.body);
        emit(state.copyWith(isReminded: body['data']?['isReminded'] == true));
      }
    } catch (_) {}
  }

  Future<void> toggleReminder() async {
    if (!ApiService.isAuthenticated) {
      _showSnackbar(
        icon: Icons.login,
        message: 'Please login first',
        color: AppColor.fourthColor,
      );
      return;
    }
    try {
      final method = state.isReminded ? 'DELETE' : 'POST';
      final response = await ApiService.items.apiClient.invokeAPI(
        '/api/v1/items/$itemId/remind',
        method,
        [],
        null,
        {},
        {},
        null,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final newReminded = !state.isReminded;
        emit(state.copyWith(isReminded: newReminded));
        _showSnackbar(
          icon: newReminded
              ? Icons.notifications_active
              : Icons.notifications_off,
          message: newReminded ? 'Reminder set' : 'Reminder removed',
          color: newReminded ? AppColor.fourthColor : Colors.grey[700]!,
        );
      }
    } catch (e) {
      _showSnackbar(
        icon: Icons.error_outline,
        message: 'Failed to update reminder',
        color: const Color(0xFFDC2626),
      );
    }
  }

  Future<void> _checkUserHasRented() async {
    if (!ApiService.isAuthenticated) return;
    try {
      final response = await ApiService.rentals.getRentals(1, 100);
      if (response != null && response.data != null) {
        final currentTitle = state.item?.titleEn;
        final hasRented = currentTitle != null &&
            response.data!.rentals.any((r) => r.itemTitle == currentTitle);
        emit(state.copyWith(hasRentedItem: hasRented));
      }
    } catch (_) {}
  }

  Future<void> submitReview(int rating, String comment) async {
    if (!ApiService.isAuthenticated) {
      _showSnackbar(
        icon: Icons.login,
        message: 'Please login to review',
        color: AppColor.fourthColor,
      );
      return;
    }
    emit(state.copyWith(isSubmittingReview: true));
    try {
      final body = jsonEncode({'rating': rating, 'comment': comment});
      final response = await ApiService.items.apiClient.invokeAPI(
        '/api/v1/items/$itemId/reviews',
        'POST',
        [],
        body,
        {'Content-Type': 'application/json'},
        {},
        'application/json',
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSnackbar(
          icon: Icons.check_circle,
          message: 'Review submitted!',
          color: AppColor.successColor,
        );
        _fetchReviews();
      } else {
        final errorBody =
            response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final messages = errorBody['messages'];
        final msg = (messages is List && messages.isNotEmpty)
            ? messages.first.toString()
            : 'Failed to submit review';
        _showSnackbar(
          icon: Icons.error_outline,
          message: msg,
          color: const Color(0xFFDC2626),
        );
      }
    } catch (e) {
      _showSnackbar(
        icon: Icons.error_outline,
        message: 'Failed to submit review',
        color: const Color(0xFFDC2626),
      );
    } finally {
      emit(state.copyWith(isSubmittingReview: false));
    }
  }

  Future<void> startChat() async {
    if (state.ownerId == null) {
      _showSnackbar(
        icon: Icons.error_outline,
        message: 'Owner information not available',
        color: Colors.grey[700]!,
      );
      return;
    }
    if (state.isChatting) return;
    emit(state.copyWith(isChatting: true));
    try {
      final cmd = CreateChatCommand(userId: state.ownerId);
      final response = await ApiService.chat.createChat(cmd);
      final chatId = response?.data?.chatId;
      if (chatId != null) {
        AppNavigator.push(ChatRoomPage(
          chatId: chatId,
          otherUserName: state.item?.owner?.firstName ?? 'Owner',
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
        color: const Color(0xFFDC2626),
      );
    } finally {
      emit(state.copyWith(isChatting: false));
    }
  }

  Future<void> _fetchReviews() async {
    try {
      final response = await ApiService.reviews.getItemReviews(itemId!);
      if (response != null && response.data != null) {
        emit(state.copyWith(
          reviews: List<ReviewDto>.from(response.data!.reviews ?? []),
          avgRating: response.data!.avgRating?.toDouble() ?? 0.0,
          totalReviews: response.data!.totalReviews ?? 0,
        ));
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
        emit(state.copyWith(
            isFavorite: favItems.any((f) => f.id == itemId)));
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

    if (state.isFavoriteLoading) return;
    emit(state.copyWith(isFavoriteLoading: true));

    final wasInFavorites = state.isFavorite;
    emit(state.copyWith(isFavorite: !wasInFavorites));

    try {
      if (wasInFavorites) {
        await ApiService.favorites.removeFavorite(itemId!);
        _showSnackbar(
          icon: Icons.heart_broken_rounded,
          message: 'Removed from favorites',
          color: Colors.grey[700]!,
        );
      } else {
        await ApiService.favorites.addFavorite(itemId!);
        _showSnackbar(
          icon: Icons.favorite_rounded,
          message: 'Added to favorites',
          color: AppColor.fourthColor,
        );
      }
    } on ApiException catch (e) {
      final errorBody = _parseErrorMessages(e);

      if (e.code == 400 && errorBody.toLowerCase().contains('already')) {
        emit(state.copyWith(isFavorite: true));
        _showSnackbar(
          icon: Icons.favorite_rounded,
          message: 'Already in favorites',
          color: AppColor.fourthColor,
        );
        return;
      }

      if (e.code == 404 || errorBody.toLowerCase().contains('not found')) {
        emit(state.copyWith(isFavorite: false));
        _showSnackbar(
          icon: Icons.heart_broken_rounded,
          message: 'Removed from favorites',
          color: Colors.grey[700]!,
        );
        return;
      }

      emit(state.copyWith(isFavorite: wasInFavorites));
      _showSnackbar(
        icon: Icons.error_outline,
        message: 'Failed to update favorites',
        color: const Color(0xFFDC2626),
      );
    } catch (e) {
      emit(state.copyWith(isFavorite: wasInFavorites));
      _showSnackbar(
        icon: Icons.error_outline,
        message: 'Failed to update favorites',
        color: const Color(0xFFDC2626),
      );
    } finally {
      emit(state.copyWith(isFavoriteLoading: false));
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
    AppNavigator.showSnackBar(
      '',
      message,
      backgroundColor: color,
      icon: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
