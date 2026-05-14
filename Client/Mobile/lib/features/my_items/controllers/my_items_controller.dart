import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

/// GetX controller for My Items — owner's item CRUD management.
/// Uses /api/v1/items endpoints from Swagger with string (GUID) IDs.
class MyItemsController extends GetxController {
  final _api = ApiService.instance;

  // ── Data ──────────────────────────────────────────────────────
  final myItems = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  // ── Lookup data ───────────────────────────────────────────────
  final categories = <Map<String, dynamic>>[].obs;
  final subcategories = <Map<String, dynamic>>[].obs;
  final brands = <Map<String, dynamic>>[].obs;

  // ── Constants ─────────────────────────────────────────────────
  static const typeOptions = ['standard', 'premium'];
  static const conditionOptions = ['new', 'like_new', 'good', 'fair'];
  static const governorates = [
    'Cairo', 'Giza', 'Alexandria', 'Dakahlia', 'Red Sea',
    'Beheira', 'Fayoum', 'Gharbiya', 'Ismailia', 'Monufia',
    'Minya', 'Qalubiya', 'New Valley', 'Suez', 'Aswan',
    'Assiut', 'Beni Suef', 'Port Said', 'Damietta', 'Sharkia',
    'South Sinai', 'Kafr El Sheikh', 'Matrouh', 'Luxor', 'Qena',
    'North Sinai', 'Sohag',
  ];

  @override
  void onInit() {
    super.onInit();
    loadMyItems();
    _loadLookups();
  }

  // ── Load My Items ─────────────────────────────────────────────
  // Uses the public items endpoint with owner filter.
  // The API filters by the authenticated user's items.

  Future<void> loadMyItems() async {
    isLoading.value = true;
    try {
      // Items endpoint: GET /api/v1/items?page=1&limit=50
      // When authenticated, we can filter by owner=me or the backend
      // may return all items. We rely on backend to filter by owner.
      final res = await _api.get(
        '${ApiEndpoints.items}?page=1&limit=50',
        authenticated: true,
      );
      final data = res['data'];
      if (data is List) {
        myItems.value = data.cast<Map<String, dynamic>>();
      }
    } catch (_) {
      // Silent
    } finally {
      isLoading.value = false;
    }
  }

  // ── Load lookups ──────────────────────────────────────────────

  Future<void> _loadLookups() async {
    try {
      final catRes = await _api.get(
        '${ApiEndpoints.categories}?page=1&limit=100',
      );
      final catData = catRes['data'];
      if (catData is List) {
        categories.value = catData.cast<Map<String, dynamic>>();
      }
    } catch (_) {}

    try {
      final subRes = await _api.get(
        '${ApiEndpoints.subcategories}?page=1&limit=1000',
      );
      final subData = subRes['data'];
      if (subData is List) {
        subcategories.value = subData.cast<Map<String, dynamic>>();
      }
    } catch (_) {}

    try {
      final brandRes = await _api.get(
        '${ApiEndpoints.brands}?page=1&limit=100',
      );
      final brandData = brandRes['data'];
      if (brandData is List) {
        brands.value = brandData.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
  }

  List<Map<String, dynamic>> getSubcategoriesForCategory(int? categoryId) {
    if (categoryId == null) return [];
    return subcategories
        .where((s) => s['categoryId'] == categoryId)
        .toList();
  }

  // ── Create Item ───────────────────────────────────────────────

  Future<bool> createItem(Map<String, dynamic> payload) async {
    isSaving.value = true;
    try {
      final res = await _api.post(
        ApiEndpoints.items,
        payload,
        authenticated: true,
      );
      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Item created successfully!',
            snackPosition: SnackPosition.BOTTOM);
        loadMyItems();
        return true;
      } else {
        final messages = (res['messages'] as List?)?.cast<String>() ?? [];
        final msg = messages.isNotEmpty ? messages[0] : 'Failed';
        Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to create item',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ── Update Item ───────────────────────────────────────────────

  Future<bool> updateItem(String id, Map<String, dynamic> payload) async {
    isSaving.value = true;
    try {
      final res = await _api.put(
        ApiEndpoints.updateItem(id),
        payload,
        authenticated: true,
      );
      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Item updated successfully!',
            snackPosition: SnackPosition.BOTTOM);
        loadMyItems();
        return true;
      } else {
        final messages = (res['messages'] as List?)?.cast<String>() ?? [];
        final msg = messages.isNotEmpty ? messages[0] : 'Failed';
        Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to update item',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ── Delete Item ───────────────────────────────────────────────

  Future<void> deleteItemAction(String id) async {
    try {
      final res = await _api.delete(
        ApiEndpoints.deleteItem(id),
        authenticated: true,
      );
      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Item deleted',
            snackPosition: SnackPosition.BOTTOM);
        myItems.removeWhere((item) => item['id'] == id);
      } else {
        final messages = (res['messages'] as List?)?.cast<String>() ?? [];
        Get.snackbar('Error', messages.isNotEmpty ? messages[0] : 'Failed',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete item',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
