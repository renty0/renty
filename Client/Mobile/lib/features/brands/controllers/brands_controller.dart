import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

/// GetX controller for Brands CRUD.
/// Swagger: GET/POST /api/v1/brands, GET/PUT/DELETE /api/v1/brands/{id}
class BrandsController extends GetxController {
  final _api = ApiService.instance;

  final brands = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBrands();
  }

  Future<void> loadBrands() async {
    isLoading.value = true;
    try {
      final res = await _api.get('${ApiEndpoints.brands}?page=1&limit=100', authenticated: true);
      final error = res['error'] as bool? ?? true;
      if (!error) {
        final data = res['data'];
        if (data is List) {
          brands.value = data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          final list = data['brands'] ?? data['items'];
          if (list is List) brands.value = list.cast<Map<String, dynamic>>();
        }
      }
    } catch (_) {}
    finally { isLoading.value = false; }
  }

  Future<bool> createBrand(Map<String, dynamic> payload) async {
    isSubmitting.value = true;
    try {
      final res = await _api.post(ApiEndpoints.brands, payload, authenticated: true);
      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Brand created', snackPosition: SnackPosition.BOTTOM);
        loadBrands();
        return true;
      }
      final msgs = (res['messages'] as List?)?.cast<String>() ?? [];
      Get.snackbar('Error', msgs.isNotEmpty ? msgs[0] : 'Failed', snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (_) {
      Get.snackbar('Error', 'Failed to create brand', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally { isSubmitting.value = false; }
  }

  Future<bool> updateBrand(String id, Map<String, dynamic> payload) async {
    isSubmitting.value = true;
    try {
      final res = await _api.put('${ApiEndpoints.brands}/$id', payload, authenticated: true);
      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Brand updated', snackPosition: SnackPosition.BOTTOM);
        loadBrands();
        return true;
      }
      return false;
    } catch (_) {
      Get.snackbar('Error', 'Failed to update brand', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally { isSubmitting.value = false; }
  }

  Future<void> deleteBrand(String id) async {
    try {
      final res = await _api.delete('${ApiEndpoints.brands}/$id', authenticated: true);
      final error = res['error'] as bool? ?? true;
      if (!error) {
        Get.snackbar('Success', 'Brand deleted', snackPosition: SnackPosition.BOTTOM);
        loadBrands();
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete', snackPosition: SnackPosition.BOTTOM);
    }
  }

  String getLocalizedName(Map<String, dynamic> b) =>
      b['nameEn']?.toString() ?? b['nameAr']?.toString() ?? b['name']?.toString() ?? '';

  String getLocalizedDesc(Map<String, dynamic> b) =>
      b['descEn']?.toString() ?? b['descAr']?.toString() ?? b['description']?.toString() ?? '';
}
