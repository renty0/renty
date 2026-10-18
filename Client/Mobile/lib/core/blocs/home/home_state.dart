import 'package:equatable/equatable.dart';
import 'package:renty/api/lib/api.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final String errorMessage;
  final List<ItemListDto> newItems;
  final List<ItemListDto> popularItems;
  final List<ItemListDto> suggestedItems;
  final List<ProductCategoryDto> categories;

  const HomeState({
    this.isLoading = true,
    this.errorMessage = '',
    this.newItems = const [],
    this.popularItems = const [],
    this.suggestedItems = const [],
    this.categories = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ItemListDto>? newItems,
    List<ItemListDto>? popularItems,
    List<ItemListDto>? suggestedItems,
    List<ProductCategoryDto>? categories,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      newItems: newItems ?? this.newItems,
      popularItems: popularItems ?? this.popularItems,
      suggestedItems: suggestedItems ?? this.suggestedItems,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        newItems,
        popularItems,
        suggestedItems,
        categories,
      ];
}
