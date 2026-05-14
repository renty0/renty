import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';
import '../controllers/my_items_controller.dart';

/// Create / Edit item form — matching the web items-editor-page.
class ItemEditorView extends StatefulWidget {
  final Map<String, dynamic>? editItem;

  const ItemEditorView({super.key, this.editItem});

  @override
  State<ItemEditorView> createState() => _ItemEditorViewState();
}

class _ItemEditorViewState extends State<ItemEditorView> {
  late final MyItemsController _ctrl;
  final _formKey = GlobalKey<FormState>();

  final _titleEnCtrl = TextEditingController();
  final _titleArCtrl = TextEditingController();
  final _descEnCtrl = TextEditingController();
  final _descArCtrl = TextEditingController();
  final _depositCtrl = TextEditingController(text: '0');
  final _dailyPriceCtrl = TextEditingController(text: '0');
  final _locationCtrl = TextEditingController();

  String _selectedType = 'standard';
  String _selectedCondition = 'good';
  String? _selectedCity;
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  int? _selectedBrandId;

  bool get _isEditMode => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<MyItemsController>()) {
      Get.put(MyItemsController());
    }
    _ctrl = Get.find<MyItemsController>();

    if (_isEditMode) {
      _populateForm(widget.editItem!);
    }
  }

  void _populateForm(Map<String, dynamic> item) {
    _titleEnCtrl.text = item['titleEn'] ?? '';
    _titleArCtrl.text = item['titleAr'] ?? '';
    _descEnCtrl.text = item['descEn'] ?? item['descriptionEn'] ?? '';
    _descArCtrl.text = item['descAr'] ?? item['descriptionAr'] ?? '';
    _depositCtrl.text = (item['defaultDeposit'] ?? 0).toString();
    _dailyPriceCtrl.text = (item['dailyPrice'] ?? item['pricePerDay'] ?? 0).toString();
    _locationCtrl.text = item['location'] ?? '';
    _selectedType = item['type'] ?? 'standard';
    _selectedCondition = item['condition'] ?? 'good';
    _selectedCity = item['city'];

    final cat = item['category'] as Map<String, dynamic>?;
    _selectedCategoryId = cat?['id'] as int?;

    final sub = item['subcategory'] as Map<String, dynamic>?;
    _selectedSubcategoryId = sub?['id'] as int?;

    final brand = item['brand'] as Map<String, dynamic>?;
    _selectedBrandId = brand?['id'] as int?;
  }

  @override
  void dispose() {
    _titleEnCtrl.dispose();
    _titleArCtrl.dispose();
    _descEnCtrl.dispose();
    _descArCtrl.dispose();
    _depositCtrl.dispose();
    _dailyPriceCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final payload = <String, dynamic>{
      'titleEn': _titleEnCtrl.text.trim(),
      'titleAr': _titleArCtrl.text.trim(),
      'descEn': _descEnCtrl.text.trim(),
      'descAr': _descArCtrl.text.trim(),
      'type': _selectedType,
      'condition': _selectedCondition,
      'defaultDeposit': num.tryParse(_depositCtrl.text.trim()) ?? 0,
      'location': _locationCtrl.text.trim(),
      'city': _selectedCity,
      'subcategoryId': _selectedSubcategoryId,
      'categoryId': _selectedCategoryId,
      'brandId': _selectedBrandId,
      'pricing': [
        {
          'pricingType': 'daily',
          'price': num.tryParse(_dailyPriceCtrl.text.trim()) ?? 0,
        }
      ],
      'images': [],
    };

    bool success;
    if (_isEditMode) {
      final id = widget.editItem!['id'].toString();
      payload['itemId'] = id;
      success = await _ctrl.updateItem(id, payload);
    } else {
      success = await _ctrl.createItem(payload);
    }

    if (success && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Item' : 'New Item',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section: Basic Info ──
              _sectionHeader('Basic Information'),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Title (English)',
                controller: _titleEnCtrl,
                prefixIcon: const Icon(Icons.title),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Title (Arabic)',
                controller: _titleArCtrl,
                prefixIcon: const Icon(Icons.translate),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Description (English)',
                controller: _descEnCtrl,
                prefixIcon: const Icon(Icons.description_outlined),
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Description (Arabic)',
                controller: _descArCtrl,
                prefixIcon: const Icon(Icons.description),
                maxLines: 3,
              ),

              const SizedBox(height: 28),

              // ── Section: Type & Condition ──
              _sectionHeader('Type & Condition'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDropdown(
                    'Type',
                    MyItemsController.typeOptions,
                    _selectedType,
                    (v) => setState(() => _selectedType = v!),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdown(
                    'Condition',
                    MyItemsController.conditionOptions,
                    _selectedCondition,
                    (v) => setState(() => _selectedCondition = v!),
                  )),
                ],
              ),

              const SizedBox(height: 28),

              // ── Section: Pricing ──
              _sectionHeader('Pricing'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Daily Price (EGP)',
                      controller: _dailyPriceCtrl,
                      prefixIcon: const Icon(Icons.attach_money),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final n = num.tryParse(v);
                        if (n == null || n <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Deposit (EGP)',
                      controller: _depositCtrl,
                      prefixIcon: const Icon(Icons.security),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Section: Category ──
              _sectionHeader('Category'),
              const SizedBox(height: 12),
              Obx(() => _buildObjectDropdown(
                    'Category',
                    _ctrl.categories,
                    _selectedCategoryId,
                    (v) => setState(() {
                      _selectedCategoryId = v;
                      _selectedSubcategoryId = null;
                    }),
                  )),
              const SizedBox(height: 14),
              Obx(() {
                final subs =
                    _ctrl.getSubcategoriesForCategory(_selectedCategoryId);
                return _buildObjectDropdown(
                  'Subcategory',
                  subs,
                  _selectedSubcategoryId,
                  (v) => setState(() => _selectedSubcategoryId = v),
                );
              }),
              const SizedBox(height: 14),
              Obx(() => _buildObjectDropdown(
                    'Brand (optional)',
                    _ctrl.brands,
                    _selectedBrandId,
                    (v) => setState(() => _selectedBrandId = v),
                  )),

              const SizedBox(height: 28),

              // ── Section: Location ──
              _sectionHeader('Location'),
              const SizedBox(height: 12),
              _buildDropdown(
                'City',
                MyItemsController.governorates,
                _selectedCity,
                (v) => setState(() => _selectedCity = v),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Address / Location Details',
                controller: _locationCtrl,
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),

              const SizedBox(height: 32),

              // ── Submit ──
              Obx(() => LoadingButton(
                    text: _isEditMode ? 'Update Item' : 'Create Item',
                    isLoading: _ctrl.isSaving.value,
                    onPressed: _submit,
                  )),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3.copyWith(fontSize: 16),
    );
  }

  Widget _buildDropdown<T>(
      String label, List<T> items, T? value, ValueChanged<T?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value != null && items.contains(value) ? value : null,
          isExpanded: true,
          hint: Text(label, style: AppTextStyles.bodySmall),
          items: items.map((item) {
            final display = item.toString().replaceAll('_', ' ');
            return DropdownMenuItem(
              value: item,
              child: Text(display.capitalizeFirst ?? display,
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildObjectDropdown(
    String label,
    List<dynamic> items,
    int? value,
    ValueChanged<int?> onChanged,
  ) {
    final hasValue = value != null && items.any((i) => i['id'] == value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: hasValue ? value : null,
          isExpanded: true,
          hint: Text(label, style: AppTextStyles.bodySmall),
          items: items.map<DropdownMenuItem<int>>((item) {
            final id = item['id'] as int? ?? 0;
            final name = item['nameEn'] ?? item['nameAr'] ?? item['name'] ?? '';
            return DropdownMenuItem(
              value: id,
              child: Text(name,
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
