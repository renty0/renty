import 'package:equatable/equatable.dart';
import 'package:renty/api/lib/api.dart';

class MarketplaceState extends Equatable {
  final bool isLoading;
  final bool isLoadingMore;
  final List<ItemListDto> items;
  final List<ProductCategoryDto> categories;
  final List<ProductSubcategoryDto> subcategories;
  final String errorMessage;

  // Pagination
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  // Filters & Search
  final String searchTerm;
  final int? selectedCategoryId;
  final int? selectedSubcategoryId;
  final String? selectedCity;
  final double? minPrice;
  final double? maxPrice;
  final String? selectedType;
  final String? selectedCondition;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minRating;
  final String selectedSort;

  const MarketplaceState({
    this.isLoading = true,
    this.isLoadingMore = false,
    this.items = const [],
    this.categories = const [],
    this.subcategories = const [],
    this.errorMessage = '',
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.itemsPerPage = 12,
    this.searchTerm = '',
    this.selectedCategoryId,
    this.selectedSubcategoryId,
    this.selectedCity,
    this.minPrice,
    this.maxPrice,
    this.selectedType,
    this.selectedCondition,
    this.startDate,
    this.endDate,
    this.minRating,
    this.selectedSort = 'newest',
  });

  int get activeFilterCount {
    int count = 0;
    if (selectedCategoryId != null) count++;
    if (selectedSubcategoryId != null) count++;
    if (selectedCity != null) count++;
    if (minPrice != null) count++;
    if (maxPrice != null) count++;
    if (selectedType != null) count++;
    if (selectedCondition != null) count++;
    if (startDate != null) count++;
    if (endDate != null) count++;
    if (minRating != null) count++;
    return count;
  }

  MarketplaceState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<ItemListDto>? items,
    List<ProductCategoryDto>? categories,
    List<ProductSubcategoryDto>? subcategories,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    int? itemsPerPage,
    String? searchTerm,
    int? Function()? selectedCategoryId,
    int? Function()? selectedSubcategoryId,
    String? Function()? selectedCity,
    double? Function()? minPrice,
    double? Function()? maxPrice,
    String? Function()? selectedType,
    String? Function()? selectedCondition,
    DateTime? Function()? startDate,
    DateTime? Function()? endDate,
    int? Function()? minRating,
    String? selectedSort,
  }) {
    return MarketplaceState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      items: items ?? this.items,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      searchTerm: searchTerm ?? this.searchTerm,
      selectedCategoryId: selectedCategoryId != null
          ? selectedCategoryId()
          : this.selectedCategoryId,
      selectedSubcategoryId: selectedSubcategoryId != null
          ? selectedSubcategoryId()
          : this.selectedSubcategoryId,
      selectedCity:
          selectedCity != null ? selectedCity() : this.selectedCity,
      minPrice: minPrice != null ? minPrice() : this.minPrice,
      maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
      selectedType:
          selectedType != null ? selectedType() : this.selectedType,
      selectedCondition: selectedCondition != null
          ? selectedCondition()
          : this.selectedCondition,
      startDate: startDate != null ? startDate() : this.startDate,
      endDate: endDate != null ? endDate() : this.endDate,
      minRating: minRating != null ? minRating() : this.minRating,
      selectedSort: selectedSort ?? this.selectedSort,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingMore,
        items,
        categories,
        subcategories,
        errorMessage,
        currentPage,
        totalPages,
        totalItems,
        itemsPerPage,
        searchTerm,
        selectedCategoryId,
        selectedSubcategoryId,
        selectedCity,
        minPrice,
        maxPrice,
        selectedType,
        selectedCondition,
        startDate,
        endDate,
        minRating,
        selectedSort,
      ];
}
