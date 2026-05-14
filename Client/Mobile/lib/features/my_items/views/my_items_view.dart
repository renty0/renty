import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/my_items_controller.dart';
import 'item_editor_view.dart';

/// My Items list — owner's item management page.
class MyItemsView extends StatelessWidget {
  const MyItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MyItemsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text('My Items',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const ItemEditorView()),
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text('Add Item',
            style: AppTextStyles.button.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        elevation: 6,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.myItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.myItems.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadMyItems,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: ctrl.myItems.length,
            itemBuilder: (context, index) {
              final item = ctrl.myItems[index];
              return _MyItemCard(item: item, ctrl: ctrl);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.gray300),
            const SizedBox(height: 24),
            Text('No items yet',
                style:
                    AppTextStyles.heading3.copyWith(color: AppColors.gray500)),
            const SizedBox(height: 12),
            Text('Tap the + button to list your first item\nfor rent',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Individual item card with edit / delete actions.
class _MyItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final MyItemsController ctrl;

  const _MyItemCard({required this.item, required this.ctrl});

  String get _title => item['titleEn'] ?? item['titleAr'] ?? '';
  String get _imageUrl => item['primaryImage'] ?? '';
  num? get _price => item['dailyPrice'] as num?;
  String get _status => item['status']?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    final itemId = item['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Container(
              width: 110,
              height: 110,
              color: const Color(0xFFF8FAFC),
              child: _imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: _imageUrl,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => const Icon(
                          Icons.image_outlined, size: 36, color: AppColors.gray300),
                    )
                  : const Icon(Icons.image_outlined,
                      size: 36, color: AppColors.gray300),
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  if (_status.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(_status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _status.capitalizeFirst ?? _status,
                        style: AppTextStyles.captionSmall.copyWith(
                          color: _statusColor(_status),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  Text(_title,
                      style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  if (_price != null)
                    Text('$_price EGP/day',
                        style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontSize: 13)),
                ],
              ),
            ),
          ),

          // Actions
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 20, color: AppColors.primary),
                tooltip: 'Edit',
                onPressed: () {
                  Get.to(() => ItemEditorView(editItem: item));
                },
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 20, color: AppColors.danger),
                tooltip: 'Delete',
                onPressed: () =>
                    _confirmDelete(context, itemId?.toString() ?? ''),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Item', style: AppTextStyles.heading3),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: AppColors.gray500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ctrl.deleteItemAction(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available': return const Color(0xFF10B981);
      case 'rented': return const Color(0xFF3B82F6);
      case 'maintenance': return const Color(0xFFF59E0B);
      case 'inactive': return const Color(0xFF6B7280);
      default: return const Color(0xFF6B7280);
    }
  }
}
