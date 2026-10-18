import 'package:equatable/equatable.dart';
import 'package:renty/api/lib/api.dart';

class ItemDetailState extends Equatable {
  final bool isLoading;
  final ApiResponseOfItemDetailDtoData? item;
  final List<ReviewDto> reviews;
  final double avgRating;
  final int totalReviews;
  final bool isFavorite;
  final bool isFavoriteLoading;
  final String errorMessage;
  final List<ItemListDto> similarItems;
  final bool isLoadingSimilar;
  final bool isChatting;
  final int? ownerId;

  final List<Map<String, DateTime>> bookedRanges;
  final bool isLoadingAvailability;
  final bool isReminded;
  final bool isSubmittingReview;
  final bool hasRentedItem;

  const ItemDetailState({
    this.isLoading = true,
    this.item,
    this.reviews = const [],
    this.avgRating = 0.0,
    this.totalReviews = 0,
    this.isFavorite = false,
    this.isFavoriteLoading = false,
    this.errorMessage = '',
    this.similarItems = const [],
    this.isLoadingSimilar = false,
    this.isChatting = false,
    this.ownerId,
    this.bookedRanges = const [],
    this.isLoadingAvailability = false,
    this.isReminded = false,
    this.isSubmittingReview = false,
    this.hasRentedItem = false,
  });

  int getStarCount(int star) {
    return reviews.where((r) => (r.rating ?? 0).round() == star).length;
  }

  double getStarPercent(int star) {
    if (totalReviews == 0) return 0;
    return (getStarCount(star) / totalReviews) * 100;
  }

  bool isDateBooked(DateTime day) {
    for (final range in bookedRanges) {
      final start = range['start']!;
      final end = range['end']!;
      if (!day.isBefore(start) && !day.isAfter(end)) return true;
    }
    return false;
  }

  ItemDetailState copyWith({
    bool? isLoading,
    ApiResponseOfItemDetailDtoData? Function()? item,
    List<ReviewDto>? reviews,
    double? avgRating,
    int? totalReviews,
    bool? isFavorite,
    bool? isFavoriteLoading,
    String? errorMessage,
    List<ItemListDto>? similarItems,
    bool? isLoadingSimilar,
    bool? isChatting,
    int? Function()? ownerId,
    List<Map<String, DateTime>>? bookedRanges,
    bool? isLoadingAvailability,
    bool? isReminded,
    bool? isSubmittingReview,
    bool? hasRentedItem,
  }) {
    return ItemDetailState(
      isLoading: isLoading ?? this.isLoading,
      item: item != null ? item() : this.item,
      reviews: reviews ?? this.reviews,
      avgRating: avgRating ?? this.avgRating,
      totalReviews: totalReviews ?? this.totalReviews,
      isFavorite: isFavorite ?? this.isFavorite,
      isFavoriteLoading: isFavoriteLoading ?? this.isFavoriteLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      similarItems: similarItems ?? this.similarItems,
      isLoadingSimilar: isLoadingSimilar ?? this.isLoadingSimilar,
      isChatting: isChatting ?? this.isChatting,
      ownerId: ownerId != null ? ownerId() : this.ownerId,
      bookedRanges: bookedRanges ?? this.bookedRanges,
      isLoadingAvailability:
          isLoadingAvailability ?? this.isLoadingAvailability,
      isReminded: isReminded ?? this.isReminded,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      hasRentedItem: hasRentedItem ?? this.hasRentedItem,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        item,
        reviews,
        avgRating,
        totalReviews,
        isFavorite,
        isFavoriteLoading,
        errorMessage,
        similarItems,
        isLoadingSimilar,
        isChatting,
        ownerId,
        bookedRanges,
        isLoadingAvailability,
        isReminded,
        isSubmittingReview,
        hasRentedItem,
      ];
}
