import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/api_service.dart';

class MarketplaceController extends GetxController {
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final items = <ItemListDto>[].obs;
  final categories = <ProductCategoryDto>[].obs;
  final subcategories = <ProductSubcategoryDto>[].obs;
  final errorMessage = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalItems = 0.obs;
  final itemsPerPage = 12;

  // Search
  final searchTerm = ''.obs;

  // Filters — matching web exactly
  final selectedCategoryId = Rxn<int>();
  final selectedSubcategoryId = Rxn<int>();
  final selectedCity = Rxn<String>();
  final minPrice = Rxn<double>();
  final maxPrice = Rxn<double>();
  final selectedType = Rxn<String>();      // 'standard' | 'premium'
  final selectedCondition = Rxn<String>(); // 'new' | 'used' | 'like_new' | 'good' | 'fair'
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final minRating = Rxn<int>();
  final selectedSort = 'newest'.obs;       // 'newest' | 'price_low' | 'price_high' | 'rating'

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
      if (isLoadingMore.value) return;
      isLoadingMore.value = true;
    }
    errorMessage.value = '';

    try {
      final q = searchTerm.value.trim();

      if (q.isNotEmpty) {
        // Use SearchClient when there's a query — matches web's performSearch()
        final response = await ApiService.search.searchItems(
          q,
          currentPage.value,
          itemsPerPage,
          categoryId: selectedCategoryId.value,
          city: selectedCity.value,
        );
        if (response != null) {
          final newItems = response.data?.items ?? [];
          if (reset) {
            items.assignAll(newItems);
          } else {
            items.addAll(newItems);
          }
          totalItems.value = response.data?.total ?? 0;
          totalPages.value = (totalItems.value / itemsPerPage).ceil();
        }
      } else {
        // Standard filtered browse — matches web's performGetItems()
        String? sort;
        String? sortOrder;
        switch (selectedSort.value) {
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
          currentPage.value,
          itemsPerPage,
          categoryId: selectedCategoryId.value,
          subcategoryId: selectedSubcategoryId.value,
          city: selectedCity.value,
          minPrice: minPrice.value,
          maxPrice: maxPrice.value,
          startDate: startDate.value,
          endDate: endDate.value,
          minRating: minRating.value,
          type: selectedType.value,
          condition: selectedCondition.value,
          sort: sort,
          sortOrder: sortOrder,
        );

        if (response != null) {
          final newItems = response.data ?? [];
          if (reset) {
            items.assignAll(newItems);
          } else {
            items.addAll(newItems);
          }
          totalItems.value = response.total ?? 0;
          totalPages.value = response.pages ?? 1;
        } else if (reset) {
          items.assignAll([]);
        }
      }
      errorMessage.value = '';
    } on ApiException catch (e) {
      if (items.isEmpty) errorMessage.value = 'Failed to load items';
      print('MarketplaceController API error: ${e.code} ${e.message}');
    } catch (e) {
      if (items.isEmpty) errorMessage.value = 'Failed to load items';
      print('MarketplaceController error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      final response = await ApiService.categories.getCategories(1, 100);
      if (response?.data != null) categories.assignAll(response!.data!);
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> loadSubcategories(int categoryId) async {
    try {
      final response = await ApiService.subcategories.getSubcategories(1, 100, categoryId: categoryId);
      if (response?.data != null) {
        subcategories.assignAll(response!.data!);
      } else {
        subcategories.clear();
      }
    } catch (e) {
      subcategories.clear();
    }
  }

  void loadNextPage() {
    if (!isLoadingMore.value && currentPage.value < totalPages.value) {
      currentPage.value++;
      loadItems(reset: false);
    }
  }

  void applyFilters() => loadItems(reset: true);

  void clearFilters() {
    searchTerm.value = '';
    selectedCategoryId.value = null;
    selectedSubcategoryId.value = null;
    selectedCity.value = null;
    minPrice.value = null;
    maxPrice.value = null;
    selectedType.value = null;
    selectedCondition.value = null;
    startDate.value = null;
    endDate.value = null;
    minRating.value = null;
    selectedSort.value = 'newest';
    subcategories.clear();
    loadItems(reset: true);
  }

  void setCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;
    selectedSubcategoryId.value = null;
    subcategories.clear();
    if (categoryId != null) loadSubcategories(categoryId);
    applyFilters();
  }

  void setSort(String sortKey) {
    selectedSort.value = sortKey;
    applyFilters();
  }

  /// Count of active filters (for badge display)
  int get activeFilterCount {
    int count = 0;
    if (selectedCategoryId.value != null) count++;
    if (selectedSubcategoryId.value != null) count++;
    if (selectedCity.value != null) count++;
    if (minPrice.value != null) count++;
    if (maxPrice.value != null) count++;
    if (selectedType.value != null) count++;
    if (selectedCondition.value != null) count++;
    if (startDate.value != null) count++;
    if (endDate.value != null) count++;
    if (minRating.value != null) count++;
    return count;
  }
}
