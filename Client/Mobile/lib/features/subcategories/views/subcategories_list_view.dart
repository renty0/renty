import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';
import '../controllers/subcategories_controller.dart';

/// Subcategories list + inline editor (matching web's subcategory-list + subcategory-editor).
class SubcategoriesListView extends StatelessWidget {
  const SubcategoriesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SubcategoriesController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text('Subcategories',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context, ctrl, null),
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text('Add',
            style: AppTextStyles.button.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.subcategories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.subcategories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_tree_outlined, size: 80, color: AppColors.gray300),
                const SizedBox(height: 24),
                Text('No subcategories yet',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.gray500)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadSubcategories,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: ctrl.subcategories.length,
            itemBuilder: (_, i) {
              final sub = ctrl.subcategories[i];
              final name = ctrl.getLocalizedName(sub);
              final catName = ctrl.getCategoryName(sub);
              final id = sub['id']?.toString() ?? '';

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
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.account_tree_outlined, color: AppColors.accent),
                  ),
                  title: Text(name,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w700)),
                  subtitle: catName.isNotEmpty
                      ? Text(catName,
                          style: AppTextStyles.captionSmall
                              .copyWith(color: AppColors.gray500))
                      : null,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _showEditor(context, ctrl, sub);
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

  void _showEditor(BuildContext context, SubcategoriesController ctrl,
      Map<String, dynamic>? existing) {
    final nameEnCtrl = TextEditingController(
        text: existing?['nameEn']?.toString() ?? '');
    final nameArCtrl = TextEditingController(
        text: existing?['nameAr']?.toString() ?? '');
    final categoryIdCtrl = TextEditingController(
        text: existing?['categoryId']?.toString() ?? '');

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
              Text(existing != null ? 'Edit Subcategory' : 'New Subcategory',
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
              const SizedBox(height: 14),
              CustomTextField(
                  label: 'Category ID',
                  controller: categoryIdCtrl,
                  prefixIcon: const Icon(Icons.category_outlined)),
              const SizedBox(height: 24),
              Obx(() => LoadingButton(
                    text: existing != null ? 'Update' : 'Create',
                    isLoading: ctrl.isSubmitting.value,
                    onPressed: () async {
                      final payload = <String, dynamic>{
                        'nameEn': nameEnCtrl.text.trim(),
                        'nameAr': nameArCtrl.text.trim(),
                        'categoryId': categoryIdCtrl.text.trim(),
                      };
                      bool ok;
                      if (existing != null) {
                        ok = await ctrl.updateSubcategory(
                            existing['id'].toString(), payload);
                      } else {
                        ok = await ctrl.createSubcategory(payload);
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
      BuildContext context, SubcategoriesController ctrl, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Subcategory', style: AppTextStyles.heading3),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: TextStyle(color: AppColors.gray500))),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ctrl.deleteSubcategory(id);
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
