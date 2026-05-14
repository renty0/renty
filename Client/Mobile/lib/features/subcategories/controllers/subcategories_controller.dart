import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

/// GetX controller for Subcategories CRUD.
/// Swagger: GET/POST /api/v1/subcategories, GET/PUT/DELETE /api/v1/subcategories/{id}
class SubcategoriesController extends GetxController {
  final _api = ApiService.instance;

  final subcategories = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSubcategories();
  }

  Future<void> loadSubcategories() async {
    isLoading.value = true;
    try {
      final res = await _api.get('${ApiEndpoints.subcategories}?page=1&limit=100', authenticated: true);
      final error = res['error'] as bool? ?? true;
      if (!error) {
        final data = res['data'];
        if (data is List) {
          subcategories.value = data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          final list = data['subcategories'] ?? data['items'];
          if (list is List) subcategories.value = list.cast<Map<String, dynamic>>();
        }
      }
    } catch (_) {}
    finally { isLoading.value = false; }
  }

  Future<bool> createSubcategory(Map<String, dynamic> payload) async {
    isSubmitting.value = true;
    try {
      final res = await _api.post(ApiEndpoints.subcategories, payload, authenticated: true);
      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Subcategory created', snackPosition: SnackPosition.BOTTOM);
        loadSubcategories();
        return true;
      }
      final msgs = (res['messages'] as List?)?.cast<String>() ?? [];
      Get.snackbar('Error', msgs.isNotEmpty ? msgs[0] : 'Failed', snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (_) {
      Get.snackbar('Error', 'Failed to create subcategory', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally { isSubmitting.value = false; }
  }

  Future<bool> updateSubcategory(String id, Map<String, dynamic> payload) async {
    isSubmitting.value = true;
    try {
      final res = await _api.put('${ApiEndpoints.subcategories}/$id', payload, authenticated: true);
      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Subcategory updated', snackPosition: SnackPosition.BOTTOM);
        loadSubcategories();
        return true;
      }
      return false;
    } catch (_) {
      Get.snackbar('Error', 'Failed to update', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally { isSubmitting.value = false; }
  }

  Future<void> deleteSubcategory(String id) async {
    try {
      final res = await _api.delete('${ApiEndpoints.subcategories}/$id', authenticated: true);
      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Subcategory deleted', snackPosition: SnackPosition.BOTTOM);
        loadSubcategories();
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete', snackPosition: SnackPosition.BOTTOM);
    }
  }

  String getLocalizedName(Map<String, dynamic> s) =>
      s['nameEn']?.toString() ?? s['nameAr']?.toString() ?? s['name']?.toString() ?? '';

  String getCategoryName(Map<String, dynamic> s) =>
      s['categoryNameEn']?.toString() ?? s['categoryName']?.toString() ?? '';
}
