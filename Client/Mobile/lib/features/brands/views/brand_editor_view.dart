import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';
import '../controllers/brands_controller.dart';

/// Brand editor — create or edit a brand (matches web brand-editor).
class BrandEditorView extends StatefulWidget {
  final Map<String, dynamic>? editBrand;
  const BrandEditorView({super.key, this.editBrand});

  @override
  State<BrandEditorView> createState() => _BrandEditorViewState();
}

class _BrandEditorViewState extends State<BrandEditorView> {
  final _ctrl = Get.find<BrandsController>();
  final _nameEnCtrl = TextEditingController();
  final _nameArCtrl = TextEditingController();
  final _descEnCtrl = TextEditingController();
  final _descArCtrl = TextEditingController();

  bool get _isEditMode => widget.editBrand != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final b = widget.editBrand!;
      _nameEnCtrl.text = b['nameEn']?.toString() ?? '';
      _nameArCtrl.text = b['nameAr']?.toString() ?? '';
      _descEnCtrl.text = b['descEn']?.toString() ?? b['description']?.toString() ?? '';
      _descArCtrl.text = b['descAr']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameArCtrl.dispose();
    _descEnCtrl.dispose();
    _descArCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameEnCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Brand name is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final payload = <String, dynamic>{
      'nameEn': _nameEnCtrl.text.trim(),
      'nameAr': _nameArCtrl.text.trim(),
      'descEn': _descEnCtrl.text.trim(),
      'descAr': _descArCtrl.text.trim(),
    };

    bool success;
    if (_isEditMode) {
      final id = widget.editBrand!['id'].toString();
      success = await _ctrl.updateBrand(id, payload);
    } else {
      success = await _ctrl.createBrand(payload);
    }
    if (success && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Brand' : 'New Brand',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(label: 'Name (English)', controller: _nameEnCtrl,
                prefixIcon: const Icon(Icons.label_outline)),
            const SizedBox(height: 16),
            CustomTextField(label: 'Name (Arabic)', controller: _nameArCtrl,
                prefixIcon: const Icon(Icons.label_outline)),
            const SizedBox(height: 16),
            CustomTextField(label: 'Description (English)', controller: _descEnCtrl,
                prefixIcon: const Icon(Icons.description_outlined), maxLines: 3),
            const SizedBox(height: 16),
            CustomTextField(label: 'Description (Arabic)', controller: _descArCtrl,
                prefixIcon: const Icon(Icons.description_outlined), maxLines: 3),
            const SizedBox(height: 32),
            Obx(() => LoadingButton(
                  text: _isEditMode ? 'Update Brand' : 'Create Brand',
                  isLoading: _ctrl.isSubmitting.value,
                  onPressed: _submit,
                )),
          ],
        ),
      ),
    );
  }
}
