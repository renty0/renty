import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';
import '../controllers/categories_controller.dart';

/// Categories list + inline editor (matching web's category-list + category-editor).
class CategoriesListView extends StatelessWidget {
  const CategoriesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CategoriesController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text('Categories',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context, ctrl, null),
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text('Add Category',
            style: AppTextStyles.button.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 80, color: AppColors.gray300),
                const SizedBox(height: 24),
                Text('No categories yet',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.gray500)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadCategories,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: ctrl.categories.length,
            itemBuilder: (_, i) {
              final cat = ctrl.categories[i];
              final name = ctrl.getLocalizedName(cat);
              final id = cat['id']?.toString() ?? '';
              final icon = cat['icon']?.toString();

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gray100),
                ),
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon != null ? Icons.category : Icons.category_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(name,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w700)),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _showEditor(context, ctrl, cat);
                      if (v == 'delete') _confirmDelete(context, ctrl, id);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showEditor(BuildContext context, CategoriesController ctrl,
      Map<String, dynamic>? existing) {
    final nameEnCtrl = TextEditingController(
        text: existing?['nameEn']?.toString() ?? '');
    final nameArCtrl = TextEditingController(
        text: existing?['nameAr']?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: AppColors.gray300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(existing != null ? 'Edit Category' : 'New Category',
                  style: AppTextStyles.heading2.copyWith(fontSize: 20)),
              const SizedBox(height: 20),
              CustomTextField(
                  label: 'Name (English)',
                  controller: nameEnCtrl,
                  prefixIcon: const Icon(Icons.label_outline)),
              const SizedBox(height: 14),
              CustomTextField(
                  label: 'Name (Arabic)',
                  controller: nameArCtrl,
                  prefixIcon: const Icon(Icons.label_outline)),
              const SizedBox(height: 24),
              Obx(() => LoadingButton(
                    text: existing != null ? 'Update' : 'Create',
                    isLoading: ctrl.isSubmitting.value,
                    onPressed: () async {
                      final payload = <String, dynamic>{
                        'nameEn': nameEnCtrl.text.trim(),
                        'nameAr': nameArCtrl.text.trim(),
                      };
                      bool ok;
                      if (existing != null) {
                        ok = await ctrl.updateCategory(
                            existing['id'].toString(), payload);
                      } else {
                        ok = await ctrl.createCategory(payload);
                      }
                      if (ok && context.mounted) Navigator.of(context).pop();
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, CategoriesController ctrl, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Category', style: AppTextStyles.heading3),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: TextStyle(color: AppColors.gray500))),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ctrl.deleteCategory(id);
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
