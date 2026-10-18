import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/api_service.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  Timer? _debounceTimer;

  static const List<String> governorates = [
    'Cairo', 'Giza', 'Alexandria', 'Dakahlia', 'Red Sea', 'Beheira',
    'Fayoum', 'Gharbia', 'Ismailia', 'Menofia', 'Minya', 'Qalyubia',
    'New Valley', 'Suez', 'Aswan', 'Assiut', 'Beni Suef', 'Port Said',
    'Damietta', 'Sharkia', 'South Sinai', 'Kafr El Sheikh', 'Matrouh',
    'Luxor', 'Qena', 'North Sinai', 'Sohag',
  ];

  SearchCubit() : super(const SearchState());

  Future<void> loadCategories() async {
    if (state.isCategoriesLoaded) return;
    try {
      final resp = await ApiService.categories.getCategories(1, 100);
      if (resp?.data != null) {
        emit(state.copyWith(
          categories: resp!.data!,
          isCategoriesLoaded: true,
        ));
      }
    } catch (e) {
      print('Failed to load categories: $e');
    }
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      performSearch(query);
    });
  }

  Future<void> performSearch(String query, {bool reset = true}) async {
    if (query.trim().isEmpty) return;

    final targetPage = reset ? 1 : state.currentPage;
    emit(state.copyWith(
      searchQuery: query,
      currentPage: targetPage,
      isLoading: true,
      errorMessage: '',
    ));

    try {
      final response = await ApiService.search.searchItems(
        query.trim(),
        targetPage,
        20,
        categoryId: state.selectedCategoryId,
        city: state.selectedCity.isNotEmpty ? state.selectedCity : null,
      );

      if (response != null && response.data != null) {
        final data = response.data!;
        final newItems = List<ItemListDto>.from(data.items);

        _sortItems(newItems, state.sortBy);

        final allItems = reset ? newItems : [...state.results, ...newItems];

        emit(state.copyWith(
          results: allItems,
          totalPages: data.pages ?? 1,
          totalResults: data.total ?? 0,
          isLoading: false,
          errorMessage: '',
        ));
      } else {
        emit(state.copyWith(
          results: reset ? const [] : state.results,
          totalResults: reset ? 0 : state.totalResults,
          isLoading: false,
          errorMessage: '',
        ));
      }
    } on ApiException catch (e) {
      print('Search API error (${e.code}): ${e.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Search failed. Please try again.',
        results: reset ? const [] : state.results,
      ));
    } catch (e) {
      print('SearchCubit error: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Search failed. Please try again.',
        results: reset ? const [] : state.results,
      ));
    }
  }

  void _sortItems(List<ItemListDto> items, String sortBy) {
    switch (sortBy) {
      case 'price_low':
        items.sort((a, b) => (a.dailyPrice ?? 0).compareTo(b.dailyPrice ?? 0));
        break;
      case 'price_high':
        items.sort((a, b) => (b.dailyPrice ?? 0).compareTo(a.dailyPrice ?? 0));
        break;
      case 'rating':
        items.sort((a, b) => (b.avgRating ?? 0).compareTo(a.avgRating ?? 0));
        break;
      default: // newest
        break;
    }
  }

  void loadMore() {
    if (state.currentPage < state.totalPages && !state.isLoading) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
      performSearch(state.searchQuery, reset: false);
    }
  }

  void setCategory(int? id, String name) {
    emit(state.copyWith(
      selectedCategoryId: () => id,
      selectedCategoryName: name,
    ));
    applyFilters();
  }

  void setCity(String city) {
    emit(state.copyWith(selectedCity: city));
    applyFilters();
  }

  void setSort(String sort) {
    emit(state.copyWith(sortBy: sort));
    if (state.results.isNotEmpty) {
      final sorted = List<ItemListDto>.from(state.results);
      _sortItems(sorted, sort);
      emit(state.copyWith(results: sorted));
    }
  }

  void applyFilters() {
    if (state.searchQuery.isNotEmpty) {
      performSearch(state.searchQuery);
    }
  }

  void resetFilters() {
    emit(state.copyWith(
      selectedCategoryId: () => null,
      selectedCategoryName: '',
      selectedCity: '',
      sortBy: 'newest',
    ));
    if (state.searchQuery.isNotEmpty) {
      performSearch(state.searchQuery);
    }
  }

  void clearSearch() {
    emit(state.copyWith(
      searchQuery: '',
      results: const [],
      currentPage: 1,
      totalPages: 1,
      totalResults: 0,
      errorMessage: '',
    ));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
