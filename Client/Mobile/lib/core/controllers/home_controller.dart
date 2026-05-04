import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/api_service.dart';

class HomeController extends GetxController {
  final isLoading = true.obs;
  final items = <ItemListDto>[].obs;
  final recommendations = <RecommendationEntryDto>[].obs;
  final categories = <ProductCategoryDto>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.wait([
        _loadFeaturedItems(),
        _loadCategories(),
        _loadRecommendations(),
      ]);
    } catch (e) {
      errorMessage.value = 'Failed to load data. Pull to refresh.';
      print('HomeController error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFeaturedItems() async {
    try {
      final response = await ApiService.items.getItems(
        1, 10,
        sort: 'createdAt',
        sortOrder: 'desc',
      );
      if (response != null && response.data != null) {
        items.assignAll(response.data!);
      }
    } catch (e) {
      print('Error loading featured items: $e');
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      final response = await ApiService.recommendations.getRecommendationsV1();
      if (response != null && response.data != null) {
        recommendations.assignAll(response.data!.recommendations);
      }
    } catch (e) {
      // Recommendations are non-critical — fail silently
      print('Error loading recommendations: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiService.categories.getCategories(1, 20);
      if (response != null && response.data != null) {
        categories.assignAll(response.data!);
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> refreshHome() async {
    await loadHomeData();
  }
}
