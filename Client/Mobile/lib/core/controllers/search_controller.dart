import 'dart:async';
import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/api_service.dart';

class AppSearchController extends GetxController {
  final isLoading = false.obs;
  final results = <ItemListDto>[].obs;
  final searchQuery = ''.obs;
  final errorMessage = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalResults = 0.obs;

  // Filters
  final selectedCategoryId = Rxn<int>();
  final selectedCity = ''.obs;

  // Debounce timer for live search
  Timer? _debounceTimer;

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Called on every keystroke — debounces then searches
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

    searchQuery.value = query;
    if (reset) currentPage.value = 1;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiService.search.searchItems(
        query.trim(),
        currentPage.value,
        20,
        categoryId: selectedCategoryId.value,
        city: selectedCity.value.isNotEmpty ? selectedCity.value : null,
      );

      if (response != null && response.data != null) {
        final data = response.data!;
        // Use List.from to ensure a growable list (avoid fixed-length crash)
        final newItems = List<ItemListDto>.from(data.items);
        if (reset) {
          results.assignAll(newItems);
        } else {
          results.addAll(newItems);
        }
        totalPages.value = data.pages ?? 1;
        totalResults.value = data.total ?? 0;
      } else {
        if (reset) {
          results.assignAll(<ItemListDto>[]);
        }
        totalResults.value = 0;
      }
    } on ApiException catch (e) {
      print('Search API error (${e.code}): ${e.message}');
      errorMessage.value = 'Search failed. Please try again.';
      if (reset) results.assignAll(<ItemListDto>[]);
    } catch (e) {
      errorMessage.value = 'Search failed. Please try again.';
      print('AppSearchController error: $e');
      if (reset) results.assignAll(<ItemListDto>[]);
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      currentPage.value++;
      performSearch(searchQuery.value, reset: false);
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    // Use assignAll instead of clear() to avoid fixed-length list crash
    results.assignAll(<ItemListDto>[]);
    currentPage.value = 1;
    totalPages.value = 1;
    totalResults.value = 0;
    errorMessage.value = '';
  }
}
