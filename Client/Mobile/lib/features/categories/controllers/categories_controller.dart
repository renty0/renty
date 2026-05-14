import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

/// GetX controller for Categories CRUD.
/// Swagger: GET/POST /api/v1/categories, GET/PUT/DELETE /api/v1/categories/{id}
class CategoriesController extends GetxController {
  final _api = ApiService.instance;

  final categories = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      final res = await _api.get('${ApiEndpoints.categories}?page=1&limit=100', authenticated: true);
      final error = res['error'] as bool? ?? true;
      if (!error) {
        final data = res['data'];
        if (data is List) {
          categories.value = data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          final list = data['categories'] ?? data['items'];
          if (list is List) categories.value = list.cast<Map<String, dynamic>>();
        }
      }
    } catch (_) {}
    finally { isLoading.value = false; }
  }

  Future<bool> createCategory(Map<String, dynamic> payload) async {
    isSubmitting.value = true;
    try {
      final res = await _api.post(ApiEndpoints.categories, payload, authenticated: true);
      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Category created', snackPosition: SnackPosition.BOTTOM);
        loadCategories();
        return true;
      }
      final msgs = (res['messages'] as List?)?.cast<String>() ?? [];
      Get.snackbar('Error', msgs.isNotEmpty ? msgs[0] : 'Failed', snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (_) {
      Get.snackbar('Error', 'Failed to create category', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally { isSubmitting.value = false; }
  }

  Future<bool> updateCategory(String id, Map<String, dynamic> payload) async {
    isSubmitting.value = true;
    try {
      final res = await _api.put('${ApiEndpoints.categories}/$id', payload, authenticated: true);
      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Category updated', snackPosition: SnackPosition.BOTTOM);
        loadCategories();
        return true;
      }
      return false;
    } catch (_) {
      Get.snackbar('Error', 'Failed to update', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally { isSubmitting.value = false; }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final res = await _api.delete('${ApiEndpoints.categories}/$id', authenticated: true);
      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Category deleted', snackPosition: SnackPosition.BOTTOM);
        loadCategories();
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete', snackPosition: SnackPosition.BOTTOM);
    }
  }

  String getLocalizedName(Map<String, dynamic> c) =>
      c['nameEn']?.toString() ?? c['nameAr']?.toString() ?? c['name']?.toString() ?? '';
}
