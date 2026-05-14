import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/brands_controller.dart';
import 'brand_editor_view.dart';

/// Brands list — view all brands with search + CRUD actions.
class BrandsListView extends StatelessWidget {
  const BrandsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BrandsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text('Brands',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const BrandEditorView()),
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text('Add Brand',
            style: AppTextStyles.button.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.brands.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.brands.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.branding_watermark_outlined,
                    size: 80, color: AppColors.gray300),
                const SizedBox(height: 24),
                Text('No brands yet',
                    style: AppTextStyles.heading3
                        .copyWith(color: AppColors.gray500)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadBrands,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: ctrl.brands.length,
            itemBuilder: (_, i) {
              final brand = ctrl.brands[i];
              return _BrandCard(brand: brand, ctrl: ctrl);
            },
          ),
        );
      }),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final Map<String, dynamic> brand;
  final BrandsController ctrl;
  const _BrandCard({required this.brand, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final name = ctrl.getLocalizedName(brand);
    final desc = ctrl.getLocalizedDesc(brand);
    final logoUrl = brand['logoUrl']?.toString();
    final id = brand['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: logoUrl != null && logoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(logoUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.branding_watermark, color: AppColors.primary)))
                : Icon(Icons.branding_watermark, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(desc,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') {
                Get.to(() => BrandEditorView(editBrand: brand));
              } else if (v == 'delete') {
                _confirmDelete(context, id);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Brand', style: AppTextStyles.heading3),
        content: const Text('Are you sure you want to delete this brand?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: TextStyle(color: AppColors.gray500))),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ctrl.deleteBrand(id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
