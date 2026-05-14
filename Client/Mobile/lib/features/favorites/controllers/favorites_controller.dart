import 'package:get/get.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

/// GetX controller for Favorites — toggle, list, check status.
class FavoritesController extends GetxController {
  final _api = ApiService.instance;

  // ── Data ──────────────────────────────────────────────────────
  final favorites = <Map<String, dynamic>>[].obs;
  final favoriteIds = <String>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  // ── Load Favorites ────────────────────────────────────────────

  Future<void> loadFavorites() async {
    isLoading.value = true;
    try {
      final res = await _api.get(
        ApiEndpoints.myFavorites,
        authenticated: true,
      );

      final data = res['data'];
      if (data is List) {
        favorites.value = data.cast<Map<String, dynamic>>();
        favoriteIds.value = data
            .map<String>((item) => (item['id'] ?? item['itemId'] ?? '').toString())
            .where((id) => id.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // Silent fail — favorites are optional
    } finally {
      isLoading.value = false;
    }
  }

  // ── Check if item is in favorites ─────────────────────────────

  bool isFavorite(String itemId) => favoriteIds.contains(itemId);

  // ── Toggle Favorite ───────────────────────────────────────────

  Future<void> toggleFavorite(String itemId) async {
    final wasFavorite = isFavorite(itemId);

    // Optimistic update
    if (wasFavorite) {
      favoriteIds.remove(itemId);
      favorites.removeWhere(
          (item) => (item['id'] ?? item['itemId']).toString() == itemId);
    } else {
      favoriteIds.add(itemId);
    }

    try {
      if (wasFavorite) {
        await _api.delete(
          ApiEndpoints.removeFavorite(itemId),
          authenticated: true,
        );
      } else {
        await _api.postEmpty(
          ApiEndpoints.addFavorite(itemId),
          authenticated: true,
        );
      }

      // Reload to get fresh data (especially for newly added items)
      if (!wasFavorite) {
        await loadFavorites();
      }
    } catch (_) {
      // Revert optimistic update on failure
      if (wasFavorite) {
        favoriteIds.add(itemId);
        loadFavorites(); // Reload to get the item back
      } else {
        favoriteIds.remove(itemId);
      }
      Get.snackbar('Error', 'Failed to update favorites',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
