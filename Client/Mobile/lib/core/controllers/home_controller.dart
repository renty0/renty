import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/api_service.dart';

class HomeController extends GetxController {
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  // Data sections — matches web's forkJoin structure
  final newItems = <ItemListDto>[].obs;        // sort: newest, 4 items
  final popularItems = <ItemListDto>[].obs;    // sort: popular, 4 items
  final suggestedItems = <ItemListDto>[].obs;  // carousel items
  final categories = <ProductCategoryDto>[].obs;

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
        _loadNewItems(),
        _loadPopularItems(),
        _loadSuggestedItems(),
        _loadCategories(),
      ]);
    } catch (e) {
      errorMessage.value = 'Failed to load data. Pull to refresh.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadNewItems() async {
    try {
      final response = await ApiService.items.getItems(
        1, 4,
        sort: 'newest',
        sortOrder: 'desc',
      );
      if (response?.data != null) newItems.assignAll(response!.data!);
    } catch (_) {}
  }

  Future<void> _loadPopularItems() async {
    try {
      final response = await ApiService.items.getItems(
        1, 4,
        sort: 'popular',
        sortOrder: 'desc',
      );
      if (response?.data != null) popularItems.assignAll(response!.data!);
    } catch (_) {}
  }

  Future<void> _loadSuggestedItems() async {
    try {
      // Use regular items endpoint — 8 items for the carousel
      final response = await ApiService.items.getItems(
        1, 8,
        sort: 'popular',
        sortOrder: 'desc',
      );
      if (response?.data != null) suggestedItems.assignAll(response!.data!);
    } catch (_) {}
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiService.categories.getCategories(1, 20);
      if (response?.data != null) categories.assignAll(response!.data!);
    } catch (_) {}
  }

  Future<void> refreshHome() async => loadHomeData();
}
