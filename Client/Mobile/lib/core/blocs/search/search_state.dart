import 'package:equatable/equatable.dart';
import 'package:renty/api/lib/api.dart';

class SearchState extends Equatable {
  final bool isLoading;
  final List<ItemListDto> results;
  final String searchQuery;
  final String errorMessage;

  final int currentPage;
  final int totalPages;
  final int totalResults;

  final int? selectedCategoryId;
  final String selectedCategoryName;
  final String selectedCity;
  final String sortBy;

  final List<ProductCategoryDto> categories;
  final bool isCategoriesLoaded;

  const SearchState({
    this.isLoading = false,
    this.results = const [],
    this.searchQuery = '',
    this.errorMessage = '',
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalResults = 0,
    this.selectedCategoryId,
    this.selectedCategoryName = '',
    this.selectedCity = '',
    this.sortBy = 'newest',
    this.categories = const [],
    this.isCategoriesLoaded = false,
  });

  bool get hasActiveFilters =>
      selectedCategoryId != null ||
      selectedCity.isNotEmpty ||
      sortBy != 'newest';

  SearchState copyWith({
    bool? isLoading,
    List<ItemListDto>? results,
    String? searchQuery,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    int? totalResults,
    int? Function()? selectedCategoryId,
    String? selectedCategoryName,
    String? selectedCity,
    String? sortBy,
    List<ProductCategoryDto>? categories,
    bool? isCategoriesLoaded,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalResults: totalResults ?? this.totalResults,
      selectedCategoryId: selectedCategoryId != null
          ? selectedCategoryId()
          : this.selectedCategoryId,
      selectedCategoryName:
          selectedCategoryName ?? this.selectedCategoryName,
      selectedCity: selectedCity ?? this.selectedCity,
      sortBy: sortBy ?? this.sortBy,
      categories: categories ?? this.categories,
      isCategoriesLoaded: isCategoriesLoaded ?? this.isCategoriesLoaded,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        results,
        searchQuery,
        errorMessage,
        currentPage,
        totalPages,
        totalResults,
        selectedCategoryId,
        selectedCategoryName,
        selectedCity,
        sortBy,
        categories,
        isCategoriesLoaded,
      ];
}
