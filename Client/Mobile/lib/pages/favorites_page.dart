import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/core/controllers/main_navigation_controller.dart';
import 'package:renty/utils/favorites_manager.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isLoading = true;
  List<FavoriteItemDto> _favorites = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.favorites.getMyFavorites();
      if (!mounted) return;
      if (response != null && response.data != null) {
        setState(() {
          _favorites = List<FavoriteItemDto>.from(response.data!.items ?? []);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load favorites'.tr;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(String itemId, {bool showFeedback = true}) async {
    // Optimistic removal — remove from list immediately
    final removedIndex = _favorites.indexWhere((f) => f.id == itemId);
    FavoriteItemDto? removedItem;
    if (removedIndex != -1) {
      removedItem = _favorites[removedIndex];
      if (mounted) {
        setState(() {
          _favorites.removeAt(removedIndex);
        });
      }
    }

    try {
      await ApiService.favorites.removeFavorite(itemId);
    } on ApiException catch (e) {
      // 404/400 means already not in favorites — treat as success
      if (e.code != 404 && e.code != 400) {
        // Real error — revert the optimistic removal
        if (removedItem != null && mounted) {
          setState(() {
            _favorites.insert(
                removedIndex.clamp(0, _favorites.length), removedItem!);
          });
        }
        _showSnackbar('Failed to remove favorite'.tr, isError: true);
        return;
      }
    } catch (e) {
      // Real error — revert the optimistic removal
      if (removedItem != null && mounted) {
        setState(() {
          _favorites.insert(
              removedIndex.clamp(0, _favorites.length), removedItem!);
        });
      }
      _showSnackbar('Failed to remove favorite'.tr, isError: true);
      return;
    }

    // Update local cache in background
    FavoritesManager.syncFavoritesFromServer();

    if (showFeedback && mounted) {
      _showSnackbar('Removed from favorites'.tr, isError: false);
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          isError ? Icons.error_outline : Icons.heart_broken_rounded,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: isError ? const Color(0xFFDC2626) : AppColor.primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('My Favorites'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor))
          : _errorMessage != null
              ? _buildError(isDark)
              : _favorites.isEmpty
                  ? _buildEmpty(isDark)
                  : RefreshIndicator(
                      onRefresh: _loadFavorites,
                      color: AppColor.primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _favorites.length,
                        itemBuilder: (context, index) =>
                            _buildFavoriteCard(_favorites[index], isDark),
                      ),
                    ),
    );
  }

  Widget _buildFavoriteCard(FavoriteItemDto favorite, bool isDark) {
    return Dismissible(
      key: Key(favorite.id ?? '${favorite.hashCode}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade300, Colors.red.shade600],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text('Remove'.tr, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        if (favorite.id != null) {
          await _removeFavorite(favorite.id!);
        }
        // Always return false — we handle removal in setState ourselves
        return false;
      },
      child: GestureDetector(
        onTap: () {
          if (favorite.id != null) {
            Get.toNamed('/item-detail', arguments: {'itemId': favorite.id});
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Item Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: favorite.primaryImage != null &&
                        favorite.primaryImage!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: favorite.primaryImage!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildPlaceholder(isDark),
                        errorWidget: (_, __, ___) => _buildPlaceholder(isDark),
                      )
                    : _buildPlaceholder(isDark),
              ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favorite.title ?? 'Untitled'.tr,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColor.darkText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (favorite.dailyPrice != null)
                      Text(
                        '@price EGP / day'.trParams({
                          'price': favorite.dailyPrice!.toStringAsFixed(0),
                        }),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColor.fourthColor,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (favorite.city != null)
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14,
                              color: isDark
                                  ? Colors.white54
                                  : AppColor.lightText),
                          const SizedBox(width: 4),
                          Text(
                            favorite.city!,
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white54
                                    : AppColor.mediumText),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Remove Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    if (favorite.id != null) {
                      _removeFavorite(favorite.id!);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.favorite, color: Colors.red, size: 26),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : AppColor.borderGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.image, color: Colors.grey[400], size: 32),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_border,
                size: 56, color: Colors.red.withOpacity(0.4)),
          ),
          const SizedBox(height: 20),
          Text('No Favorites Yet'.tr,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColor.darkText)),
          const SizedBox(height: 8),
          Text('Items you favorite will appear here'.tr,
              style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : AppColor.mediumText)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              try {
                final nav = Get.find<MainNavigationController>();
                nav.currentIndex.value = 1; // Marketplace tab
              } catch (_) {}
            },
            icon: const Icon(Icons.storefront_rounded, size: 20),
            label: Text('Browse Items'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.fourthColor,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_errorMessage!,
              style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : AppColor.mediumText)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadFavorites,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text('Retry'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.fourthColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
