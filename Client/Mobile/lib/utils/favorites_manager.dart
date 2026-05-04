import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/services/api_service.dart';

/// Manages favorites with local caching + server sync.
/// Migrated from old Crud/AppLink to generated OpenAPI FavoritesApi.
class FavoritesManager {
  static const String _favoritesKeyPrefix = 'favorites_user_';
  static SharedPreferences? _prefs;
  static String? _currentUserId;
  static bool _initialized = false;

  static Future<void> initialize() async {
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
        _initialized = true;
        print('FavoritesManager initialized successfully');
      }
    } catch (e) {
      print('Error initializing FavoritesManager: $e');
      _initialized = false;
    }
  }

  static Future<void> _ensureInitialized() async {
    if (!_initialized || _prefs == null) {
      await initialize();
    }
  }

  static void setCurrentUser(String userId) {
    _currentUserId = userId;
    // Sync favorites from server when user logs in
    syncFavoritesFromServer();
  }

  static String _getUserFavoritesKey() {
    if (_currentUserId == null) return 'favorites_default';
    return '$_favoritesKeyPrefix$_currentUserId';
  }

  // Sync favorites from server to local storage
  static Future<void> syncFavoritesFromServer() async {
    await _ensureInitialized();
    if (_currentUserId == null) return;

    try {
      final response = await ApiService.favorites.getMyFavorites();
      if (response != null && response.data != null) {
        final favItems = response.data!.items ?? [];
        List<String> serverFavoriteIds = favItems
            .where((item) => item.id != null)
            .map((item) => item.id!)
            .toList();

        // Update local storage
        final favoritesJson = jsonEncode(serverFavoriteIds);
        await _prefs!.setString(_getUserFavoritesKey(), favoritesJson);
        print('Synced ${serverFavoriteIds.length} favorites from server');
      }
    } catch (e) {
      print('Error syncing favorites from server: $e');
    }
  }

  // Get favorite IDs (async)
  static Future<List<String>> getFavoriteIds() async {
    await _ensureInitialized();
    if (_prefs == null || !_initialized) {
      print('FavoritesManager not initialized, returning empty list');
      return [];
    }

    try {
      final favoritesJson = _prefs!.getString(_getUserFavoritesKey());
      if (favoritesJson == null) return [];

      final List<dynamic> favoritesList = jsonDecode(favoritesJson);
      return favoritesList.map((id) => id.toString()).toList();
    } catch (e) {
      print('Error getting favorite IDs: $e');
      return [];
    }
  }

  // Get favorite IDs (sync)
  static List<String> getFavoriteIdsSync() {
    if (_prefs == null || !_initialized) {
      print('FavoritesManager not initialized, returning empty list');
      return [];
    }

    try {
      final favoritesJson = _prefs!.getString(_getUserFavoritesKey());
      if (favoritesJson == null) return [];

      final List<dynamic> favoritesList = jsonDecode(favoritesJson);
      return favoritesList.map((id) => id.toString()).toList();
    } catch (e) {
      print('Error getting favorite IDs: $e');
      return [];
    }
  }

  // Add to favorites (with server sync)
  static Future<bool> addToFavorites(String productId) async {
    await _ensureInitialized();
    if (_prefs == null || _currentUserId == null) return false;

    try {
      // Add to server first
      await ApiService.favorites.addFavorite(productId);
    } on ApiException catch (e) {
      // 400 "Already in favorites" — treat as success
      if (e.code == 400) {
        // Already in favorites — that's fine, continue to update local
      } else {
        print('Error adding to favorites: $e');
        return false;
      }
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }

    // Update local storage
    try {
      final favorites = getFavoriteIdsSync();
      if (!favorites.contains(productId)) {
        favorites.add(productId);
        final favoritesJson = jsonEncode(favorites);
        return await _prefs!.setString(_getUserFavoritesKey(), favoritesJson);
      }
      return true;
    } catch (e) {
      print('Error updating local favorites: $e');
      return false;
    }
  }

  // Remove from favorites (with server sync)
  static Future<bool> removeFromFavorites(String productId) async {
    await _ensureInitialized();
    if (_prefs == null || _currentUserId == null) return false;

    try {
      // Remove from server first
      await ApiService.favorites.removeFavorite(productId);
    } on ApiException catch (e) {
      // 404 "Not found" — treat as success (already removed)
      if (e.code == 404 || e.code == 400) {
        // Not in favorites — that's fine, continue to update local
      } else {
        print('Error removing from favorites: $e');
        return false;
      }
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }

    // Update local storage
    try {
      final favorites = getFavoriteIdsSync();
      if (favorites.contains(productId)) {
        favorites.remove(productId);
        final favoritesJson = jsonEncode(favorites);
        return await _prefs!.setString(_getUserFavoritesKey(), favoritesJson);
      }
      return true;
    } catch (e) {
      print('Error updating local favorites: $e');
      return false;
    }
  }

  // Check if product is favorite (sync)
  static bool isFavorite(String productId) {
    if (_prefs == null || !_initialized) {
      print('FavoritesManager not initialized in isFavorite');
      return false;
    }

    try {
      final favorites = getFavoriteIdsSync();
      return favorites.contains(productId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Toggle favorite status (with server sync)
  static Future<bool> toggleFavorite(String productId) async {
    await _ensureInitialized();
    if (_prefs == null || _currentUserId == null) return false;

    try {
      final isCurrentlyFavorite = isFavorite(productId);
      print('Toggling favorite for $productId, currently: $isCurrentlyFavorite');

      if (isCurrentlyFavorite) {
        return await removeFromFavorites(productId);
      } else {
        return await addToFavorites(productId);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Get favorites count
  static int getFavoritesCount() {
    final favorites = getFavoriteIdsSync();
    return favorites.length;
  }

  // Clear all favorites (with server sync)
  static Future<bool> clearAllFavorites() async {
    await _ensureInitialized();
    if (_prefs == null || _currentUserId == null) return false;

    try {
      // Get all favorites to remove them one by one from server
      final favorites = getFavoriteIdsSync();

      for (String productId in favorites) {
        try {
          await ApiService.favorites.removeFavorite(productId);
        } catch (_) {
          // Continue even if one fails
        }
      }

      // Clear local storage
      return await _prefs!.remove(_getUserFavoritesKey());
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }

  // Clear user preferences on logout
  static Future<void> clearUserPreferences() async {
    await _ensureInitialized();
    if (_currentUserId != null && _prefs != null) {
      try {
        await _prefs!.remove(_getUserFavoritesKey());
      } catch (e) {
        print('Error clearing user preferences: $e');
      }
      _currentUserId = null;
    }
  }

  // Check if FavoritesManager is properly initialized
  static bool get isInitialized => _initialized && _prefs != null;
}