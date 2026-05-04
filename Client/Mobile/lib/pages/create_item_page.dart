import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';

/// Create/Add new item page — mirrors the Web's items-editor-page.
class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isLoadingData = true;

  // Text controllers
  final _titleEnCtrl = TextEditingController();
  final _titleArCtrl = TextEditingController();
  final _descEnCtrl = TextEditingController();
  final _descArCtrl = TextEditingController();
  final _dailyPriceCtrl = TextEditingController();
  final _weeklyPriceCtrl = TextEditingController();
  final _monthlyPriceCtrl = TextEditingController();
  final _depositCtrl = TextEditingController(text: '0');
  final _locationCtrl = TextEditingController();

  // Dropdown values
  String _type = 'standard';
  String _condition = 'good';
  String? _city;
  int? _categoryId;
  int? _subcategoryId;
  int? _brandId;

  // Loaded options
  List<ProductCategoryDto> _categories = [];
  List<ProductSubcategoryDto> _subcategories = [];
  List<_BrandOption> _brands = [];

  // Images
  final List<_PickedImage> _pickedImages = [];
  final _picker = ImagePicker();

  static const _typeOptions = [
    {'label': 'Standard', 'value': 'standard'},
    {'label': 'Premium', 'value': 'premium'},
  ];
  static const _conditionOptions = [
    {'label': 'New', 'value': 'new'},
    {'label': 'Like New', 'value': 'like_new'},
    {'label': 'Good', 'value': 'good'},
    {'label': 'Fair', 'value': 'fair'},
  ];
  static const _governorates = [
    'Cairo', 'Giza', 'Alexandria', 'Dakahlia', 'Red Sea',
    'Beheira', 'Fayoum', 'Gharbiya', 'Ismailia', 'Monufia',
    'Minya', 'Qalubiya', 'New Valley', 'Suez', 'Aswan',
    'Assiut', 'Beni Suef', 'Port Said', 'Damietta', 'Sharkia',
    'South Sinai', 'Kafr El Sheikh', 'Matrouh', 'Luxor',
    'Qena', 'North Sinai', 'Sohag',
  ];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _titleEnCtrl.dispose();
    _titleArCtrl.dispose();
    _descEnCtrl.dispose();
    _descArCtrl.dispose();
    _dailyPriceCtrl.dispose();
    _weeklyPriceCtrl.dispose();
    _monthlyPriceCtrl.dispose();
    _depositCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    try {
      final catRes = await ApiService.categories.getCategories(1, 100);
      final brandRes = await ApiService.brands.getBrands(1, 100);
      if (!mounted) return;
      setState(() {
        _categories = catRes?.data ?? [];
        if (brandRes?.data != null) {
          _brands = brandRes!.data!
              .map((b) => _BrandOption(id: b.id, name: b.nameEn ?? b.nameAr ?? ''))
              .toList();
        }
        _isLoadingData = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _loadSubcategories(int categoryId) async {
    try {
      final res = await ApiService.subcategories.getSubcategoriesByCategory(categoryId, 1, 100);
      if (!mounted) return;
      setState(() {
        _subcategories = res?.data ?? [];
        _subcategoryId = null;
      });
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xFile == null) return;
    setState(() {
      _pickedImages.add(_PickedImage(file: File(xFile.path), isPrimary: _pickedImages.isEmpty));
    });
  }

  void _removeImage(int index) {
    setState(() {
      final wasPrimary = _pickedImages[index].isPrimary;
      _pickedImages.removeAt(index);
      if (wasPrimary && _pickedImages.isNotEmpty) {
        _pickedImages[0].isPrimary = true;
      }
    });
  }

  void _setPrimary(int index) {
    setState(() {
      for (int i = 0; i < _pickedImages.length; i++) {
        _pickedImages[i].isPrimary = (i == index);
      }
    });
  }

  /// Upload all picked images to MediaApi, return list of CreateItemImageCommand
  Future<List<CreateItemImageCommand>?> _uploadImages() async {
    final commands = <CreateItemImageCommand>[];
    for (int i = 0; i < _pickedImages.length; i++) {
      final img = _pickedImages[i];
      try {
        final filePath = img.file.path;
        final filename = filePath.split(Platform.pathSeparator).last;
        final ext = filename.split('.').last.toLowerCase();
        // Map extension to MIME subtype
        final mimeSubtype = const {
          'jpg': 'jpeg', 'jpeg': 'jpeg', 'png': 'png',
          'gif': 'gif', 'webp': 'webp', 'bmp': 'bmp', 'heic': 'heic',
        }[ext] ?? 'jpeg';

        final multipart = await http.MultipartFile.fromPath(
          'file', filePath,
          filename: filename,
          contentType: MediaType('image', mimeSubtype),
        );
        final res = await ApiService.media.uploadMedia(file: multipart);
        if (res?.data?.id != null) {
          commands.add(CreateItemImageCommand(imageId: res!.data!.id, isPrimary: img.isPrimary));
        } else {
          Get.snackbar('Upload Failed', 'Could not upload image ${i + 1}',
              backgroundColor: Colors.red.withOpacity(0.9), colorText: Colors.white);
          return null;
        }
      } catch (e) {
        debugPrint('Image upload failed: $e');
        Get.snackbar('Upload Failed', 'Image ${i + 1}: ${e.toString().length > 100 ? e.toString().substring(0, 100) : e.toString()}',
            backgroundColor: Colors.red.withOpacity(0.9), colorText: Colors.white);
        return null;
      }
    }
    return commands;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImages.isEmpty) {
      Get.snackbar('Missing Photos', 'Please add at least one image for your item.',
          backgroundColor: Colors.orange.withOpacity(0.9), colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Upload images first
      final imageCommands = await _uploadImages();
      if (imageCommands == null) {
        // Upload failed — error already shown
        setState(() => _isSaving = false);
        return;
      }

      // 2. Build pricing
      final dailyPrice = double.tryParse(_dailyPriceCtrl.text) ?? 0;
      final weeklyPrice = double.tryParse(_weeklyPriceCtrl.text) ?? 0;
      final monthlyPrice = double.tryParse(_monthlyPriceCtrl.text) ?? 0;
      final deposit = double.tryParse(_depositCtrl.text) ?? 0;

      final pricing = <CreateItemPricingCommand>[
        CreateItemPricingCommand(pricingType: 'daily', price: dailyPrice),
        if (weeklyPrice > 0) CreateItemPricingCommand(pricingType: 'weekly', price: weeklyPrice),
        if (monthlyPrice > 0) CreateItemPricingCommand(pricingType: 'monthly', price: monthlyPrice),
      ];

      // 3. Create item
      final cmd = CreateItemCommand(
        titleEn: _titleEnCtrl.text.trim(),
        titleAr: _titleArCtrl.text.trim(),
        descEn: _descEnCtrl.text.trim().isEmpty ? null : _descEnCtrl.text.trim(),
        descAr: _descArCtrl.text.trim().isEmpty ? null : _descArCtrl.text.trim(),
        type: _type,
        condition: _condition,
        defaultDeposit: deposit,
        city: _city,
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        categoryId: _categoryId,
        subcategoryId: _subcategoryId,
        brandId: _brandId,
        pricing: pricing,
        images: imageCommands,
      );

      final res = await ApiService.items.createItem(cmd);
      if (!mounted) return;

      if (res != null && res.error != true) {
        Get.snackbar('Success', 'Item created successfully!',
            backgroundColor: Colors.green.withOpacity(0.9), colorText: Colors.white);
        Navigator.pop(context, true);
      } else {
        final msg = (res?.messages != null && res!.messages!.isNotEmpty)
            ? res.messages!.join(', ')
            : 'Failed to create item';
        Get.snackbar('Error', msg,
            backgroundColor: Colors.red.withOpacity(0.9), colorText: Colors.white);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', 'Server error (${e.code}): ${e.message ?? "Unknown"}',
          backgroundColor: Colors.red.withOpacity(0.9), colorText: Colors.white);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red.withOpacity(0.9), colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColor.backgroundcolor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: isDark ? Colors.white : AppColor.primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Item',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColor.primaryColor, letterSpacing: -0.3)),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: AppColor.fourthColor))
          : _buildForm(isDark),
    );
  }

  Widget _buildForm(bool isDark) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General Info
          _sectionCard(isDark, title: 'General Information', icon: Icons.info_outline_rounded, children: [
            _textField(controller: _titleEnCtrl, label: 'Title (English) *', hint: 'Enter item name', isDark: isDark, required: true),
            const SizedBox(height: 14),
            _textField(controller: _titleArCtrl, label: 'Title (Arabic) *', hint: 'أدخل اسم العنصر', isDark: isDark, required: true, textDirection: TextDirection.rtl),
            const SizedBox(height: 14),
            _textField(controller: _descEnCtrl, label: 'Description (English)', hint: 'Describe your item...', isDark: isDark, maxLines: 3),
            const SizedBox(height: 14),
            _textField(controller: _descArCtrl, label: 'Description (Arabic)', hint: 'وصف العنصر...', isDark: isDark, maxLines: 3, textDirection: TextDirection.rtl),
          ]),
          const SizedBox(height: 16),

          // Images
          _sectionCard(isDark, title: 'Photos', icon: Icons.photo_library_rounded, children: [
            if (_pickedImages.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _pickedImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _imageThumb(i, isDark),
                ),
              ),
            if (_pickedImages.isNotEmpty) const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
              label: Text(_pickedImages.isEmpty ? 'Add Photos' : 'Add More'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.fourthColor,
                side: BorderSide(color: AppColor.fourthColor.withOpacity(0.4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_pickedImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Tap the ★ to set primary image', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ),
          ]),
          const SizedBox(height: 16),

          // Pricing
          _sectionCard(isDark, title: 'Pricing', icon: Icons.attach_money_rounded, children: [
            Row(children: [
              Expanded(child: _textField(controller: _dailyPriceCtrl, label: 'Daily Price (EGP) *', hint: '0', isDark: isDark, required: true, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _textField(controller: _depositCtrl, label: 'Deposit (EGP)', hint: '0', isDark: isDark, keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _textField(controller: _weeklyPriceCtrl, label: 'Weekly Price', hint: 'Optional', isDark: isDark, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _textField(controller: _monthlyPriceCtrl, label: 'Monthly Price', hint: 'Optional', isDark: isDark, keyboardType: TextInputType.number)),
            ]),
          ]),
          const SizedBox(height: 16),

          // Details
          _sectionCard(isDark, title: 'Details', icon: Icons.tune_rounded, children: [
            Row(children: [
              Expanded(child: _dropdown<String>(label: 'Type', value: _type, isDark: isDark,
                  items: _typeOptions.map((o) => DropdownMenuItem(value: o['value'], child: Text(o['label']!))).toList(),
                  onChanged: (v) => setState(() => _type = v!))),
              const SizedBox(width: 12),
              Expanded(child: _dropdown<String>(label: 'Condition', value: _condition, isDark: isDark,
                  items: _conditionOptions.map((o) => DropdownMenuItem(value: o['value'], child: Text(o['label']!))).toList(),
                  onChanged: (v) => setState(() => _condition = v!))),
            ]),
            const SizedBox(height: 14),
            _dropdown<String>(label: 'City', value: _city, isDark: isDark, hint: 'Select a city',
                items: _governorates.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _city = v)),
            const SizedBox(height: 14),
            _textField(controller: _locationCtrl, label: 'Location Details', hint: 'e.g. Maadi, Street 9', isDark: isDark),
          ]),
          const SizedBox(height: 16),

          // Organization
          _sectionCard(isDark, title: 'Organization', icon: Icons.category_rounded, children: [
            _dropdown<int>(label: 'Category *', value: _categoryId, isDark: isDark, hint: 'Select category',
                items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nameEn ?? c.nameAr ?? ''))).toList(),
                onChanged: (v) { setState(() => _categoryId = v); if (v != null) _loadSubcategories(v); }),
            const SizedBox(height: 14),
            _dropdown<int>(label: 'Subcategory *', value: _subcategoryId, isDark: isDark,
                hint: _categoryId == null ? 'Select a category first' : 'Select subcategory',
                items: _subcategories.map((s) => DropdownMenuItem(value: s.id, child: Text(s.nameEn ?? s.nameAr ?? ''))).toList(),
                onChanged: _categoryId == null ? null : (v) => setState(() => _subcategoryId = v)),
            const SizedBox(height: 14),
            _dropdown<int>(label: 'Brand', value: _brandId, isDark: isDark, hint: 'Select brand (optional)',
                items: _brands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                onChanged: (v) => setState(() => _brandId = v)),
          ]),
          const SizedBox(height: 24),

          // Submit
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColor.fourthColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Cancel', style: TextStyle(color: AppColor.fourthColor, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.fourthColor, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Image thumbnail with delete & primary controls ──
  Widget _imageThumb(int index, bool isDark) {
    final img = _pickedImages[index];
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _setPrimary(index),
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: img.isPrimary ? AppColor.fourthColor : Colors.transparent, width: 2.5),
              image: DecorationImage(image: FileImage(img.file), fit: BoxFit.cover),
            ),
          ),
        ),
        // Primary star
        Positioned(
          bottom: 4, left: 4,
          child: Icon(img.isPrimary ? Icons.star_rounded : Icons.star_border_rounded,
              size: 20, color: img.isPrimary ? Colors.amber : Colors.white70),
        ),
        // Delete
        Positioned(
          top: 2, right: 2,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ── Reusable widgets ──

  Widget _sectionCard(bool isDark, {required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColor.fourthColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: AppColor.fourthColor),
          ),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColor.primaryColor)),
        ]),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _textField({required TextEditingController controller, required String label, required String hint, required bool isDark, bool required = false, int maxLines = 1, TextInputType? keyboardType, TextDirection? textDirection}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColor.mediumText)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller, maxLines: maxLines, keyboardType: keyboardType, textDirection: textDirection,
        style: TextStyle(color: isDark ? Colors.white : AppColor.darkText, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint, hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400], fontSize: 14),
          filled: true, fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColor.fourthColor, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
      ),
    ]);
  }

  Widget _dropdown<T>({required String label, required T? value, required bool isDark, required List<DropdownMenuItem<T>> items, required ValueChanged<T?>? onChanged, String? hint}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColor.mediumText)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey[300]!),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value, isExpanded: true,
            hint: Text(hint ?? 'Select...', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400], fontSize: 14)),
            dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            style: TextStyle(color: isDark ? Colors.white : AppColor.darkText, fontSize: 14),
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.white54 : Colors.grey[600]),
            items: items, onChanged: onChanged,
          ),
        ),
      ),
    ]);
  }
}

class _PickedImage {
  final File file;
  bool isPrimary;
  _PickedImage({required this.file, this.isPrimary = false});
}

class _BrandOption {
  final int? id;
  final String name;
  _BrandOption({required this.id, required this.name});
}
