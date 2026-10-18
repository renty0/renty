import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/api_service.dart';
import 'marketplace_state.dart';

class MarketplaceCubit extends Cubit<MarketplaceState> {
  MarketplaceCubit() : super(const MarketplaceState());

  Future<void> loadItems({bool reset = true}) async {
    if (reset) {
      emit(state.copyWith(
        currentPage: 1,
        isLoading: true,
        errorMessage: '',
      ));
    } else {
      if (state.isLoadingMore) return;
      emit(state.copyWith(isLoadingMore: true, errorMessage: ''));
    }

    try {
      final q = state.searchTerm.trim();

      if (q.isNotEmpty) {
        final response = await ApiService.search.searchItems(
          q,
          state.currentPage,
          state.itemsPerPage,
          categoryId: state.selectedCategoryId,
          city: state.selectedCity,
        );

        if (response != null) {
          final newItems = response.data?.items ?? [];
          final allItems = reset ? newItems : [...state.items, ...newItems];
          final total = response.data?.total ?? 0;
          final pages = (total / state.itemsPerPage).ceil();

          emit(state.copyWith(
            items: allItems,
            totalItems: total,
            totalPages: pages > 0 ? pages : 1,
            isLoading: false,
            isLoadingMore: false,
            errorMessage: '',
          ));
        }
      } else {
        String? sort;
        String? sortOrder;
        switch (state.selectedSort) {
          case 'price_low':
            sort = 'price';
            sortOrder = 'asc';
            break;
          case 'price_high':
            sort = 'price';
            sortOrder = 'desc';
            break;
          case 'rating':
            sort = 'rating';
            sortOrder = 'desc';
            break;
          case 'newest':
          default:
            sort = 'createdAt';
            sortOrder = 'desc';
            break;
        }

        final response = await ApiService.items.getItems(
          state.currentPage,
          state.itemsPerPage,
          categoryId: state.selectedCategoryId,
          subcategoryId: state.selectedSubcategoryId,
          city: state.selectedCity,
          minPrice: state.minPrice,
          maxPrice: state.maxPrice,
          startDate: state.startDate,
          endDate: state.endDate,
          minRating: state.minRating,
          type: state.selectedType,
          condition: state.selectedCondition,
          sort: sort,
          sortOrder: sortOrder,
        );

        if (response != null) {
          final newItems = response.data ?? [];
          final allItems = reset ? newItems : [...state.items, ...newItems];
          final total = response.total ?? 0;
          final pages = response.pages ?? 1;

          emit(state.copyWith(
            items: allItems,
            totalItems: total,
            totalPages: pages,
            isLoading: false,
            isLoadingMore: false,
            errorMessage: '',
          ));
        } else if (reset) {
          emit(state.copyWith(
            items: const [],
            isLoading: false,
            isLoadingMore: false,
            errorMessage: '',
          ));
        }
      }
    } on ApiException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: state.items.isEmpty ? 'Failed to load items' : '',
      ));
      print('MarketplaceCubit API error: ${e.code} ${e.message}');
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: state.items.isEmpty ? 'Failed to load items' : '',
      ));
      print('MarketplaceCubit error: $e');
    }
  }

  Future<void> loadCategories() async {
    try {
      final response = await ApiService.categories.getCategories(1, 100);
      if (response?.data != null) {
        emit(state.copyWith(categories: response!.data!));
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> loadSubcategories(int categoryId) async {
    try {
      final response = await ApiService.subcategories.getSubcategories(
        1,
        100,
        categoryId: categoryId,
      );
      if (response?.data != null) {
        emit(state.copyWith(subcategories: response!.data!));
      } else {
        emit(state.copyWith(subcategories: const []));
      }
    } catch (e) {
      emit(state.copyWith(subcategories: const []));
    }
  }

  void loadNextPage() {
    if (!state.isLoadingMore && state.currentPage < state.totalPages) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
      loadItems(reset: false);
    }
  }

  void setSearchTerm(String term) {
    emit(state.copyWith(searchTerm: term));
  }

  void setCategory(int? categoryId) {
    emit(state.copyWith(
      selectedCategoryId: () => categoryId,
      selectedSubcategoryId: () => null,
      subcategories: const [],
    ));
    if (categoryId != null) loadSubcategories(categoryId);
    applyFilters();
  }

  void setSubcategory(int? subcategoryId) {
    emit(state.copyWith(selectedSubcategoryId: () => subcategoryId));
  }

  void setCity(String? city) {
    emit(state.copyWith(selectedCity: () => city));
  }

  void setPriceRange(double? min, double? max) {
    emit(state.copyWith(
      minPrice: () => min,
      maxPrice: () => max,
    ));
  }

  void setType(String? type) {
    emit(state.copyWith(selectedType: () => type));
  }

  void setCondition(String? condition) {
    emit(state.copyWith(selectedCondition: () => condition));
  }

  void setDates(DateTime? start, DateTime? end) {
    emit(state.copyWith(
      startDate: () => start,
      endDate: () => end,
    ));
  }

  void setMinRating(int? rating) {
    emit(state.copyWith(minRating: () => rating));
  }

  void setSort(String sortKey) {
    emit(state.copyWith(selectedSort: sortKey));
    applyFilters();
  }

  void applyFilters() => loadItems(reset: true);

  void clearFilters() {
    emit(state.copyWith(
      searchTerm: '',
      selectedCategoryId: () => null,
      selectedSubcategoryId: () => null,
      selectedCity: () => null,
      minPrice: () => null,
      maxPrice: () => null,
      selectedType: () => null,
      selectedCondition: () => null,
      startDate: () => null,
      endDate: () => null,
      minRating: () => null,
      selectedSort: 'newest',
      subcategories: const [],
    ));
    loadItems(reset: true);
  }
}
