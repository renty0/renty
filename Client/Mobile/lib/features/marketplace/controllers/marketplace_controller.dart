import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

/// GetX controller for the marketplace — items, categories, filters, pagination.
class MarketplaceController extends GetxController {
  final _api = ApiService.instance;

  // ── Data ──────────────────────────────────────────────────────────
  final items = <Map<String, dynamic>>[].obs;
  final categories = <Map<String, dynamic>>[].obs;
  final subcategories = <Map<String, dynamic>>[].obs;

  // ── Loading states ────────────────────────────────────────────────
  final isLoadingItems = false.obs;
  final isLoadingCategories = false.obs;
  final isLoadingMore = false.obs;

  // ── Filters ───────────────────────────────────────────────────────
  final searchTerm = ''.obs;
  final selectedCategoryId = Rxn<int>();
  final selectedSubcategoryId = Rxn<int>();

  // ── Pagination ────────────────────────────────────────────────────
  final page = 1.obs;
  final pageSize = 12.obs;
  final totalCount = 0.obs;
  bool get hasMore => items.length < totalCount.value;

  // ── Product detail ────────────────────────────────────────────────
  final currentItem = Rxn<Map<String, dynamic>>();
  final relatedItems = <Map<String, dynamic>>[].obs;
  final isLoadingDetail = false.obs;
  final selectedImage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadItems();

    // React to filter changes
    ever(selectedCategoryId, (_) {
      _onFilterChanged();
      _loadSubcategoriesForCategory();
    });
    ever(selectedSubcategoryId, (_) => _onFilterChanged());
    debounce(searchTerm, (_) => _onFilterChanged(),
        time: const Duration(milliseconds: 400));
  }

  void _onFilterChanged() {
    page.value = 1;
    items.clear();
    loadItems();
  }

  void _loadSubcategoriesForCategory() {
    final catId = selectedCategoryId.value;
    selectedSubcategoryId.value = null;
    if (catId != null) {
      loadSubcategories(catId);
    } else {
      subcategories.clear();
    }
  }

  // ── Load Categories ───────────────────────────────────────────────

  Future<void> loadCategories() async {
    isLoadingCategories.value = true;
    try {
      final res = await _api.get(
        '${ApiEndpoints.categories}?page=1&limit=100',
      );
      final data = res['data'];
      if (data is List) {
        categories.value = data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      // Silently fail — categories are optional UI
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // ── Load Subcategories ────────────────────────────────────────────

  Future<void> loadSubcategories(int categoryId) async {
    try {
      final res = await _api.get(
        '${ApiEndpoints.subcategories}?page=1&limit=100&categoryId=$categoryId',
      );
      final data = res['data'];
      if (data is List) {
        subcategories.value = data.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
  }

  // ── Load Items ────────────────────────────────────────────────────

  Future<void> loadItems() async {
    isLoadingItems.value = true;
    try {
      final queryParams = <String, String>{
        'page': page.value.toString(),
        'limit': pageSize.value.toString(),
        'sort': 'newest',
        'sortOrder': 'desc',
      };

      if (selectedCategoryId.value != null) {
        queryParams['categoryId'] = selectedCategoryId.value.toString();
      }
      if (selectedSubcategoryId.value != null) {
        queryParams['subcategoryId'] = selectedSubcategoryId.value.toString();
      }

      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final res = await _api.get('${ApiEndpoints.items}?$query');
      final data = res['data'];
      final total = res['total'];

      if (data is List) {
        items.value = data.cast<Map<String, dynamic>>();
      }
      if (total is int) {
        totalCount.value = total;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingItems.value = false;
    }
  }

  /// Load next page (infinite scroll)
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore) return;
    isLoadingMore.value = true;
    page.value++;

    try {
      final queryParams = <String, String>{
        'page': page.value.toString(),
        'limit': pageSize.value.toString(),
        'sort': 'newest',
        'sortOrder': 'desc',
      };

      if (selectedCategoryId.value != null) {
        queryParams['categoryId'] = selectedCategoryId.value.toString();
      }
      if (selectedSubcategoryId.value != null) {
        queryParams['subcategoryId'] = selectedSubcategoryId.value.toString();
      }

      final query = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final res = await _api.get('${ApiEndpoints.items}?$query');
      final data = res['data'];

      if (data is List) {
        items.addAll(data.cast<Map<String, dynamic>>());
      }
    } catch (_) {
      page.value--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ── Load Item Detail ──────────────────────────────────────────────

  Future<void> loadItemDetail(String id) async {
    isLoadingDetail.value = true;
    currentItem.value = null;
    relatedItems.clear();

    try {
      final res = await _api.get(ApiEndpoints.itemById(id));
      final error = res['error'] as bool? ?? false;
      final data = res['data'];

      if (!error && data is Map<String, dynamic>) {
        currentItem.value = data;

        // Set primary image
        final images = data['images'] as List?;
        if (images != null && images.isNotEmpty) {
          final primary = images.firstWhere(
            (img) => img['isPrimary'] == true,
            orElse: () => images[0],
          );
          selectedImage.value = primary['imageUrl'] ?? '';
        } else {
          selectedImage.value = '';
        }

        // Load related items
        final subcategory = data['subcategory'] as Map<String, dynamic>?;
        if (subcategory != null && subcategory['id'] != null) {
          _loadRelatedItems(subcategory['id'], id);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load product details',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> _loadRelatedItems(int subcategoryId, String currentId) async {
    try {
      final res = await _api.get(
        '${ApiEndpoints.items}?page=1&limit=5&subcategoryId=$subcategoryId&sort=newest&sortOrder=desc',
      );
      final data = res['data'];
      if (data is List) {
        relatedItems.value = data
            .cast<Map<String, dynamic>>()
            .where((i) => i['id'] != currentId)
            .take(4)
            .toList();
      }
    } catch (_) {}
  }

  // ── Filter Reset ──────────────────────────────────────────────────

  void resetFilters() {
    searchTerm.value = '';
    selectedCategoryId.value = null;
    selectedSubcategoryId.value = null;
  }

  // ── Localization helpers ──────────────────────────────────────────

  String getLocalizedName(Map<String, dynamic> item) {
    return item['titleEn'] ?? item['titleAr'] ?? '';
  }

  String getLocalizedDesc(Map<String, dynamic> item) {
    return item['descEn'] ?? item['descAr'] ?? '';
  }

  String getLocalizedRefName(Map<String, dynamic>? ref) {
    if (ref == null) return '';
    return ref['nameEn'] ?? ref['nameAr'] ?? '';
  }
}
