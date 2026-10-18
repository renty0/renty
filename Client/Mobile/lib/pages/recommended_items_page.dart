import 'package:flutter/material.dart';
import 'package:renty/core/utils/app_navigator.dart';
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
  final _entries = <RecommendationEntryDto>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.recommendations.getRecommendationsV1();
      if (response != null && response.data != null) {
        setState(() {
          _entries.clear();
          _entries.addAll(response.data!.recommendations);
        });
      }
    } catch (e) {
      debugPrint('RecommendedItemsPage error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Recommended Items'.tr),
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
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_outlined, size: 56, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text('No items found'.tr,
                          style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColor.fourthColor,
                  onRefresh: _loadItems,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _entries.length,
                      itemBuilder: (_, i) {
                        final entry = _entries[i];
                        final mappedItem = ItemListDto(
                          id: entry.item?.id,
                          titleEn: entry.item?.title,
                          titleAr: entry.item?.title,
                          dailyPrice: entry.item?.price,
                          primaryImage: entry.item?.image,
                          city: entry.item?.city,
                        );
                        return HomeItemCard(
                          item: mappedItem,
                          onTap: () async {
                            if (entry.id != null) {
                              try {
                                await ApiService.recommendations.recordRecommendationClick(entry.id!);
                              } catch (e) {
                                debugPrint('Error recording click: $e');
                              }
                            }
                            AppNavigator.pushNamed('/item-detail', arguments: {'itemId': mappedItem.id});
                          },
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
