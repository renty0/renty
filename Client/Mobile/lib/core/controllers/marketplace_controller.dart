import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/api_service.dart';

class MarketplaceController extends GetxController {
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final items = <ItemListDto>[].obs;
  final categories = <ProductCategoryDto>[].obs;
  final errorMessage = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalItems = 0.obs;
  final itemsPerPage = 12;

  // Filters
  final selectedCategoryId = Rxn<int>();
  final selectedSubcategoryId = Rxn<int>();
  final selectedCity = ''.obs;
  final minPrice = Rxn<double>();
  final maxPrice = Rxn<double>();
  final selectedType = ''.obs;
  final selectedCondition = ''.obs;
  final selectedSort = 'createdAt'.obs;
  final selectedSortOrder = 'desc'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadItems();
  }

  Future<void> loadItems({bool reset = true}) async {
    if (reset) {
      currentPage.value = 1;
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await ApiService.items.getItems(
        currentPage.value,
        itemsPerPage,
        categoryId: selectedCategoryId.value,
        subcategoryId: selectedSubcategoryId.value,
        city: selectedCity.value.isNotEmpty ? selectedCity.value : null,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        type: selectedType.value.isNotEmpty ? selectedType.value : null,
        condition: selectedCondition.value.isNotEmpty
            ? selectedCondition.value
            : null,
        sort: selectedSort.value,
        sortOrder: selectedSortOrder.value,
      );

      if (response != null) {
        final newItems = response.data ?? [];

        if (reset) {
          items.assignAll(newItems);
        } else {
          items.addAll(newItems);
        }

        // Parse pagination from response
        totalItems.value = response.total ?? 0;
        totalPages.value = response.pages ?? 1;

        // Clear error on success
        errorMessage.value = '';
      } else {
        // null response is NOT an error – just means empty result
        if (reset) {
          items.assignAll([]);
        }
      }
    } on ApiException catch (e) {
      // Only show error if we have NO items to display
      if (items.isEmpty) {
        errorMessage.value = 'Failed to load items';
      }
      print('MarketplaceController API error: ${e.code} ${e.message}');
    } catch (e) {
      if (items.isEmpty) {
        errorMessage.value = 'Failed to load items';
      }
      print('MarketplaceController error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      final response = await ApiService.categories.getCategories(1, 50);
      if (response != null && response.data != null) {
        categories.assignAll(response.data!);
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  void loadNextPage() {
    if (!isLoadingMore.value &&
        currentPage.value < totalPages.value) {
      currentPage.value++;
      loadItems(reset: false);
    }
  }

  void applyFilters() {
    loadItems(reset: true);
  }

  void clearFilters() {
    selectedCategoryId.value = null;
    selectedSubcategoryId.value = null;
    selectedCity.value = '';
    minPrice.value = null;
    maxPrice.value = null;
    selectedType.value = '';
    selectedCondition.value = '';
    selectedSort.value = 'createdAt';
    selectedSortOrder.value = 'desc';
    loadItems(reset: true);
  }

  void setCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;
    // Also clear subcategory when category changes
    selectedSubcategoryId.value = null;
    applyFilters();
  }

  void setSort(String sort, String order) {
    selectedSort.value = sort;
    selectedSortOrder.value = order;
    applyFilters();
  }
}
