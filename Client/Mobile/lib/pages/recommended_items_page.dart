import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';
import 'package:renty/pages/home_widgets/home_item_card.dart';

class RecommendedItemsPage extends StatefulWidget {
  const RecommendedItemsPage({super.key});

  @override
  State<RecommendedItemsPage> createState() => _RecommendedItemsPageState();
}

class _RecommendedItemsPageState extends State<RecommendedItemsPage> {
  final _items = <ItemListDto>[];
  bool _isLoading = true;
  int _page = 1;
  int _totalPages = 1;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems({bool reset = true}) async {
    if (reset) {
      _page = 1;
      setState(() => _isLoading = true);
    } else {
      if (_loadingMore || _page >= _totalPages) return;
      setState(() => _loadingMore = true);
    }

    try {
      final response = await ApiService.items.getItems(_page, 20,
          sort: 'popular', sortOrder: 'desc');
      if (response != null) {
        final newItems = response.data ?? [];
        setState(() {
          if (reset) {
            _items.clear();
          }
          _items.addAll(newItems);
          _totalPages = response.pages ?? 1;
        });
      }
    } catch (e) {
      debugPrint('RecommendedItemsPage error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _loadingMore = false;
      });
    }
  }

  void _loadMore() {
    if (!_loadingMore && _page < _totalPages) {
      _page++;
      _loadItems(reset: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: const Text('Recommended Items'),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : AppColor.primaryColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColor.primaryColor,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColor.fourthColor))
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_outlined, size: 56, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text('No items found',
                          style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                    ],
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (scroll) {
                    if (scroll.metrics.pixels > scroll.metrics.maxScrollExtent - 200) {
                      _loadMore();
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    color: AppColor.fourthColor,
                    onRefresh: () => _loadItems(reset: true),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _items.length + (_loadingMore ? 2 : 0),
                        itemBuilder: (_, i) {
                          if (i >= _items.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColor.fourthColor),
                              ),
                            );
                          }
                          return HomeItemCard(item: _items[i]);
                        },
                      ),
                    ),
                  ),
                ),
    );
  }
}
