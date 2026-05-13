import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';

/// Edit Item page — loads existing item detail and allows updating text fields + pricing.
/// Uses PUT /api/v1/items/{id} via UpdateItemCommand.
class EditItemPage extends StatefulWidget {
  final String itemId;
  const EditItemPage({super.key, required this.itemId});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  final _titleEnCtrl = TextEditingController();
  final _titleArCtrl = TextEditingController();
  final _descEnCtrl = TextEditingController();
  final _descArCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _dailyPriceCtrl = TextEditingController();
  final _weeklyPriceCtrl = TextEditingController();
  final _monthlyPriceCtrl = TextEditingController();

  String? _selectedType;
  String? _selectedCondition;
  int? _categoryId;
  int? _subcategoryId;
  int? _brandId;

  // Existing images (kept as-is from the API)
  List<CreateItemImageCommand> _existingImages = [];

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  @override
  void dispose() {
    _titleEnCtrl.dispose();
    _titleArCtrl.dispose();
    _descEnCtrl.dispose();
    _descArCtrl.dispose();
    _depositCtrl.dispose();
    _locationCtrl.dispose();
    _cityCtrl.dispose();
    _dailyPriceCtrl.dispose();
    _weeklyPriceCtrl.dispose();
    _monthlyPriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadItem() async {
    try {
      final resp = await ApiService.items.getItemById(widget.itemId);
      final item = resp?.data;
      if (item == null) throw Exception('Item not found');
      if (!mounted) return;

      setState(() {
        _titleEnCtrl.text = item.titleEn ?? '';
        _titleArCtrl.text = item.titleAr ?? '';
        _descEnCtrl.text = item.descEn ?? '';
        _descArCtrl.text = item.descAr ?? '';
        _depositCtrl.text = item.defaultDeposit?.toString() ?? '';
        _locationCtrl.text = item.location ?? '';
        _cityCtrl.text = item.city ?? '';
        _selectedType = item.type;
        _selectedCondition = item.condition;
        _categoryId = item.category?.id;
        _subcategoryId = item.subcategory?.id;
        _brandId = item.brand?.id;

        // Pre-populate pricing
        for (final p in item.pricing) {
          switch (p.pricingType?.toLowerCase()) {
            case 'daily':
              _dailyPriceCtrl.text = p.price?.toString() ?? '';
              break;
            case 'weekly':
              _weeklyPriceCtrl.text = p.price?.toString() ?? '';
              break;
            case 'monthly':
              _monthlyPriceCtrl.text = p.price?.toString() ?? '';
              break;
          }
        }

        // Keep existing images
        _existingImages = item.images
            .where((img) => img.id != null)
            .map((img) => CreateItemImageCommand(
                  imageId: img.id,
                  isPrimary: img.isPrimary ?? false,
                ))
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load item details',
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white);
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      // Build pricing list
      final pricing = <CreateItemPricingCommand>[];
      if (_dailyPriceCtrl.text.isNotEmpty) {
        pricing.add(CreateItemPricingCommand(
          pricingType: 'daily',
          price: num.tryParse(_dailyPriceCtrl.text),
        ));
      }
      if (_weeklyPriceCtrl.text.isNotEmpty) {
        pricing.add(CreateItemPricingCommand(
          pricingType: 'weekly',
          price: num.tryParse(_weeklyPriceCtrl.text),
        ));
      }
      if (_monthlyPriceCtrl.text.isNotEmpty) {
        pricing.add(CreateItemPricingCommand(
          pricingType: 'monthly',
          price: num.tryParse(_monthlyPriceCtrl.text),
        ));
      }

      final command = UpdateItemCommand(
        itemId: widget.itemId,
        titleEn: _titleEnCtrl.text.trim(),
        titleAr: _titleArCtrl.text.trim().isEmpty ? null : _titleArCtrl.text.trim(),
        descEn: _descEnCtrl.text.trim(),
        descAr: _descArCtrl.text.trim().isEmpty ? null : _descArCtrl.text.trim(),
        type: _selectedType,
        condition: _selectedCondition,
        defaultDeposit: num.tryParse(_depositCtrl.text),
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        categoryId: _categoryId,
        subcategoryId: _subcategoryId,
        brandId: _brandId,
        pricing: pricing,
        images: _existingImages,
      );

      await ApiService.items.updateItem(widget.itemId, command);

      if (!mounted) return;
      Get.snackbar('Success', 'Item updated successfully',
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white);
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      Get.snackbar('Error', 'Update failed: ${e.message ?? e.code}',
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update item',
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColor.backgroundcolor;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Edit Item', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColor.fourthColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title section
                    _sectionHeader('Item Details', Icons.edit_outlined, isDark),
                    const SizedBox(height: 12),
                    _card(cardColor, isDark, [
                      _field('Title (English)', _titleEnCtrl, isDark,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                      const SizedBox(height: 14),
                      _field('Title (Arabic)', _titleArCtrl, isDark),
                      const SizedBox(height: 14),
                      _field('Description (English)', _descEnCtrl, isDark, maxLines: 3),
                      const SizedBox(height: 14),
                      _field('Description (Arabic)', _descArCtrl, isDark, maxLines: 3),
                    ]),

                    const SizedBox(height: 24),

                    // Type & Condition
                    _sectionHeader('Classification', Icons.category_outlined, isDark),
                    const SizedBox(height: 12),
                    _card(cardColor, isDark, [
                      _dropdown('Type', _selectedType, ['rent', 'sell', 'both'],
                          (v) => setState(() => _selectedType = v), isDark),
                      const SizedBox(height: 14),
                      _dropdown('Condition', _selectedCondition,
                          ['new', 'like_new', 'good', 'used', 'fair'],
                          (v) => setState(() => _selectedCondition = v), isDark),
                    ]),

                    const SizedBox(height: 24),

                    // Pricing
                    _sectionHeader('Pricing', Icons.payments_outlined, isDark),
                    const SizedBox(height: 12),
                    _card(cardColor, isDark, [
                      _field('Daily Price (EGP)', _dailyPriceCtrl, isDark,
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 14),
                      _field('Weekly Price (EGP)', _weeklyPriceCtrl, isDark,
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 14),
                      _field('Monthly Price (EGP)', _monthlyPriceCtrl, isDark,
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 14),
                      _field('Security Deposit (EGP)', _depositCtrl, isDark,
                          keyboardType: TextInputType.number),
                    ]),

                    const SizedBox(height: 24),

                    // Location
                    _sectionHeader('Location', Icons.location_on_outlined, isDark),
                    const SizedBox(height: 12),
                    _card(cardColor, isDark, [
                      _field('Location', _locationCtrl, isDark),
                      const SizedBox(height: 14),
                      _field('City', _cityCtrl, isDark),
                    ]),

                    const SizedBox(height: 32),

                    // Save
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 3,
                          disabledBackgroundColor: AppColor.borderGray,
                        ),
                        child: _isSaving
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Save Changes',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Helpers ──

  Widget _sectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.fourthColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColor.fourthColor),
        ),
        const SizedBox(width: 12),
        Text(title, style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColor.darkText,
        )),
      ],
    );
  }

  Widget _card(Color cardColor, bool isDark, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _field(String label, TextEditingController ctrl, bool isDark, {
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : AppColor.darkText, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white54 : AppColor.mediumText, fontSize: 14),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.fourthColor, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _dropdown(String label, String? value, List<String> options,
      ValueChanged<String?> onChanged, bool isDark) {
    return DropdownButtonFormField<String>(
      value: options.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white54 : AppColor.mediumText, fontSize: 14),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColor.fourthColor, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      style: TextStyle(color: isDark ? Colors.white : AppColor.darkText, fontSize: 15),
      items: options.map((o) => DropdownMenuItem(
        value: o,
        child: Text(o.replaceAll('_', ' ').capitalize!),
      )).toList(),
      onChanged: onChanged,
    );
  }
}
