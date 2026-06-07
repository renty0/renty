import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:renty/api/lib/api.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/services/api_service.dart';

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
  final _dailyPriceCtrl = TextEditingController();
  final _weeklyPriceCtrl = TextEditingController();
  final _monthlyPriceCtrl = TextEditingController();
  final _depositCtrl = TextEditingController(text: '0');
  final _locationCtrl = TextEditingController();

  String _type = 'standard';
  String _condition = 'good';
  String? _city;
  int? _categoryId;
  int? _subcategoryId;
  int? _brandId;

  List<ProductCategoryDto> _categories = [];
  List<ProductSubcategoryDto> _subcategories = [];
  List<_BrandOption> _brands = [];
  final List<_ExistingImage> _existingImages = [];
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
    'Cairo', 'Giza', 'Alexandria', 'Dakahlia', 'Red Sea', 'Beheira',
    'Fayoum', 'Gharbiya', 'Ismailia', 'Monufia', 'Minya', 'Qalubiya',
    'New Valley', 'Suez', 'Aswan', 'Assiut', 'Beni Suef', 'Port Said',
    'Damietta', 'Sharkia', 'South Sinai', 'Kafr El Sheikh', 'Matrouh',
    'Luxor', 'Qena', 'North Sinai', 'Sohag',
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    for (final c in [_titleEnCtrl, _titleArCtrl, _descEnCtrl, _descArCtrl,
        _dailyPriceCtrl, _weeklyPriceCtrl, _monthlyPriceCtrl, _depositCtrl, _locationCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAll() async {
    try {
      final results = await Future.wait([
        ApiService.categories.getCategories(1, 100),
        ApiService.brands.getBrands(1, 100),
        ApiService.items.getItemById(widget.itemId),
      ]);
      if (!mounted) return;
      final catRes = results[0] as ApiResponseOfListOfProductCategoryDto?;
      final brandRes = results[1] as ApiResponseOfListOfBrandDto?;
      final itemRes = results[2] as ApiResponseOfItemDetailDto?;

      _categories = catRes?.data ?? [];
      if (brandRes?.data != null) {
        _brands = brandRes!.data!.map((b) => _BrandOption(id: b.id, name: b.nameEn ?? b.nameAr ?? '')).toList();
      }

      final item = itemRes?.data;
      if (item == null) throw Exception('Item not found');

      _titleEnCtrl.text = item.titleEn ?? '';
      _titleArCtrl.text = item.titleAr ?? '';
      _descEnCtrl.text = item.descEn ?? '';
      _descArCtrl.text = item.descAr ?? '';
      _depositCtrl.text = item.defaultDeposit?.toString() ?? '0';
      _locationCtrl.text = item.location ?? '';
      _type = item.type ?? 'standard';
      _condition = item.condition ?? 'good';
      _city = item.city;
      _categoryId = item.category?.id;
      _subcategoryId = item.subcategory?.id;
      _brandId = item.brand?.id;

      for (final p in item.pricing) {
        switch (p.pricingType?.toLowerCase()) {
          case 'daily': _dailyPriceCtrl.text = p.price?.toString() ?? ''; break;
          case 'weekly': _weeklyPriceCtrl.text = p.price?.toString() ?? ''; break;
          case 'monthly': _monthlyPriceCtrl.text = p.price?.toString() ?? ''; break;
        }
      }

      _existingImages.clear();
      for (final img in item.images) {
        if (img.id != null) {
          _existingImages.add(_ExistingImage(id: img.id!, url: img.imageUrl ?? '', isPrimary: img.isPrimary ?? false));
        }
      }

      if (_categoryId != null) await _loadSubcategories(_categoryId!);

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load item', backgroundColor: Colors.red.withOpacity(0.9), colorText: Colors.white);
    }
  }

  Future<void> _loadSubcategories(int categoryId) async {
    try {
      final res = await ApiService.subcategories.getSubcategoriesByCategory(categoryId, 1, 100);
      if (mounted) setState(() { _subcategories = res?.data ?? []; });
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xFile == null) return;
    setState(() => _pickedImages.add(_PickedImage(file: File(xFile.path), isPrimary: _existingImages.isEmpty && _pickedImages.isEmpty)));
  }

  void _removeExisting(int i) {
    setState(() {
      final wasPrimary = _existingImages[i].isPrimary;
      _existingImages.removeAt(i);
      if (wasPrimary && _existingImages.isNotEmpty) _existingImages[0].isPrimary = true;
      else if (wasPrimary && _pickedImages.isNotEmpty) _pickedImages[0].isPrimary = true;
    });
  }

  void _removeNew(int i) {
    setState(() {
      final wasPrimary = _pickedImages[i].isPrimary;
      _pickedImages.removeAt(i);
      if (wasPrimary && _existingImages.isNotEmpty) _existingImages[0].isPrimary = true;
      else if (wasPrimary && _pickedImages.isNotEmpty) _pickedImages[0].isPrimary = true;
    });
  }

  void _setPrimaryExisting(int i) {
    setState(() {
      for (var e in _existingImages) { e.isPrimary = false; }
      for (var e in _pickedImages) { e.isPrimary = false; }
      _existingImages[i].isPrimary = true;
    });
  }

  void _setPrimaryNew(int i) {
    setState(() {
      for (var e in _existingImages) { e.isPrimary = false; }
      for (var e in _pickedImages) { e.isPrimary = false; }
      _pickedImages[i].isPrimary = true;
    });
  }

  Future<List<CreateItemImageCommand>?> _uploadNewImages() async {
    final cmds = <CreateItemImageCommand>[];
    for (int i = 0; i < _pickedImages.length; i++) {
      final img = _pickedImages[i];
      try {
        final filePath = img.file.path;
        final filename = filePath.split(Platform.pathSeparator).last;
        final ext = filename.split('.').last.toLowerCase();
        final mime = const {'jpg':'jpeg','jpeg':'jpeg','png':'png','gif':'gif','webp':'webp'}[ext] ?? 'jpeg';
        final mp = await http.MultipartFile.fromPath('file', filePath, filename: filename, contentType: MediaType('image', mime));
        final res = await ApiService.media.uploadMedia(file: mp);
        if (res?.data?.id != null) {
          cmds.add(CreateItemImageCommand(imageId: res!.data!.id, isPrimary: img.isPrimary));
        } else { return null; }
      } catch (_) { return null; }
    }
    return cmds;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      // Upload new images
      final newImgCmds = await _uploadNewImages();
      if (newImgCmds == null && _pickedImages.isNotEmpty) {
        Get.snackbar('Error', 'Image upload failed', backgroundColor: Colors.red.withOpacity(0.9), colorText: Colors.white);
        setState(() => _isSaving = false);
        return;
      }

      // Build combined image list
      final allImages = <CreateItemImageCommand>[
        ..._existingImages.map((e) => CreateItemImageCommand(imageId: e.id, isPrimary: e.isPrimary)),
        ...?newImgCmds,
      ];

      final pricing = <CreateItemPricingCommand>[];
      if (_dailyPriceCtrl.text.isNotEmpty) pricing.add(CreateItemPricingCommand(pricingType: 'daily', price: num.tryParse(_dailyPriceCtrl.text)));
      if (_weeklyPriceCtrl.text.isNotEmpty) pricing.add(CreateItemPricingCommand(pricingType: 'weekly', price: num.tryParse(_weeklyPriceCtrl.text)));
      if (_monthlyPriceCtrl.text.isNotEmpty) pricing.add(CreateItemPricingCommand(pricingType: 'monthly', price: num.tryParse(_monthlyPriceCtrl.text)));

      final cmd = UpdateItemCommand(
        itemId: widget.itemId,
        titleEn: _titleEnCtrl.text.trim(),
        titleAr: _titleArCtrl.text.trim().isEmpty ? null : _titleArCtrl.text.trim(),
        descEn: _descEnCtrl.text.trim(),
        descAr: _descArCtrl.text.trim().isEmpty ? null : _descArCtrl.text.trim(),
        type: _type, condition: _condition,
        defaultDeposit: num.tryParse(_depositCtrl.text),
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        city: _city,
        categoryId: _categoryId, subcategoryId: _subcategoryId, brandId: _brandId,
        pricing: pricing, images: allImages,
      );

      await ApiService.items.updateItem(widget.itemId, cmd);
      if (!mounted) return;
      Get.snackbar('Success', 'Item updated', backgroundColor: Colors.green.withOpacity(0.9), colorText: Colors.white);
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      Get.snackbar('Error', 'Update failed: ${e.message ?? e.code}', backgroundColor: Colors.red.withOpacity(0.9), colorText: Colors.white);
    } catch (_) {
      Get.snackbar('Error', 'Failed to update item', backgroundColor: Colors.red.withOpacity(0.9), colorText: Colors.white);
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
        surfaceTintColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: isDark ? Colors.white : AppColor.primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColor.primaryColor)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColor.fourthColor))
          : Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
              _sec(isDark, 'General Information', Icons.info_outline_rounded, [
                _tf(_titleEnCtrl, 'Title (English) *', 'Enter item name', isDark, req: true),
                const SizedBox(height: 14),
                _tf(_titleArCtrl, 'Title (Arabic) *', 'أدخل اسم العنصر', isDark, req: true, dir: TextDirection.rtl),
                const SizedBox(height: 14),
                _tf(_descEnCtrl, 'Description (English)', 'Describe your item...', isDark, lines: 3),
                const SizedBox(height: 14),
                _tf(_descArCtrl, 'Description (Arabic)', 'وصف العنصر...', isDark, lines: 3, dir: TextDirection.rtl),
              ]),
              const SizedBox(height: 16),
              _sec(isDark, 'Photos', Icons.photo_library_rounded, [
                if (_existingImages.isNotEmpty || _pickedImages.isNotEmpty)
                  SizedBox(height: 110, child: ListView(scrollDirection: Axis.horizontal, children: [
                    ..._existingImages.asMap().entries.map((e) => _existingThumb(e.key, isDark)),
                    ..._pickedImages.asMap().entries.map((e) => _newThumb(e.key, isDark)),
                  ])),
                if (_existingImages.isNotEmpty || _pickedImages.isNotEmpty) const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
                  label: Text(_existingImages.isEmpty && _pickedImages.isEmpty ? 'Add Photos' : 'Add More'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.fourthColor,
                    side: BorderSide(color: AppColor.fourthColor.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                if (_existingImages.isNotEmpty || _pickedImages.isNotEmpty)
                  Padding(padding: const EdgeInsets.only(top: 8), child: Text('Tap ★ to set primary', style: TextStyle(fontSize: 11, color: Colors.grey[500]))),
              ]),
              const SizedBox(height: 16),
              _sec(isDark, 'Pricing', Icons.attach_money_rounded, [
                Row(children: [
                  Expanded(child: _tf(_dailyPriceCtrl, 'Daily (EGP) *', '0', isDark, req: true, kb: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _tf(_depositCtrl, 'Deposit (EGP)', '0', isDark, kb: TextInputType.number)),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _tf(_weeklyPriceCtrl, 'Weekly', 'Optional', isDark, kb: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _tf(_monthlyPriceCtrl, 'Monthly', 'Optional', isDark, kb: TextInputType.number)),
                ]),
              ]),
              const SizedBox(height: 16),
              _sec(isDark, 'Details', Icons.tune_rounded, [
                Row(children: [
                  Expanded(child: _dd<String>('Type', _type, isDark,
                    _typeOptions.map((o) => DropdownMenuItem(value: o['value'], child: Text(o['label']!))).toList(),
                    (v) => setState(() => _type = v!))),
                  const SizedBox(width: 12),
                  Expanded(child: _dd<String>('Condition', _condition, isDark,
                    _conditionOptions.map((o) => DropdownMenuItem(value: o['value'], child: Text(o['label']!))).toList(),
                    (v) => setState(() => _condition = v!))),
                ]),
                const SizedBox(height: 14),
                _dd<String>('City', _city, isDark,
                  _governorates.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  (v) => setState(() => _city = v), hint: 'Select city'),
                const SizedBox(height: 14),
                _tf(_locationCtrl, 'Location Details', 'e.g. Maadi, Street 9', isDark),
              ]),
              const SizedBox(height: 16),
              _sec(isDark, 'Organization', Icons.category_rounded, [
                _dd<int>('Category *', _categoryId, isDark,
                  _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nameEn ?? c.nameAr ?? ''))).toList(),
                  (v) { setState(() { _categoryId = v; _subcategoryId = null; _subcategories = []; }); if (v != null) _loadSubcategories(v); },
                  hint: 'Select category'),
                const SizedBox(height: 14),
                _dd<int>('Subcategory *', _subcategoryId, isDark,
                  _subcategories.map((s) => DropdownMenuItem(value: s.id, child: Text(s.nameEn ?? s.nameAr ?? ''))).toList(),
                  _categoryId == null ? null : (v) => setState(() => _subcategoryId = v),
                  hint: _categoryId == null ? 'Select category first' : 'Select subcategory'),
                const SizedBox(height: 14),
                _dd<int>('Brand', _brandId, isDark,
                  _brands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                  (v) => setState(() => _brandId = v), hint: 'Optional'),
              ]),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: AppColor.fourthColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text('Cancel', style: TextStyle(color: AppColor.fourthColor, fontWeight: FontWeight.w700)),
                )),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColor.fourthColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                  child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                )),
              ]),
              const SizedBox(height: 32),
            ])),
    );
  }

  Widget _existingThumb(int i, bool isDark) {
    final img = _existingImages[i];
    return Padding(padding: const EdgeInsets.only(right: 10), child: Stack(children: [
      GestureDetector(onTap: () => _setPrimaryExisting(i), child: Container(
        width: 100, height: 100,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: img.isPrimary ? AppColor.fourthColor : Colors.transparent, width: 2.5)),
        child: ClipRRect(borderRadius: BorderRadius.circular(10), child: CachedNetworkImage(imageUrl: img.url, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.broken_image))),
      )),
      Positioned(bottom: 4, left: 4, child: Icon(img.isPrimary ? Icons.star_rounded : Icons.star_border_rounded, size: 20, color: img.isPrimary ? Colors.amber : Colors.white70)),
      Positioned(top: 2, right: 2, child: GestureDetector(onTap: () => _removeExisting(i), child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)))),
    ]));
  }

  Widget _newThumb(int i, bool isDark) {
    final img = _pickedImages[i];
    return Padding(padding: const EdgeInsets.only(right: 10), child: Stack(children: [
      GestureDetector(onTap: () => _setPrimaryNew(i), child: Container(
        width: 100, height: 100,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: img.isPrimary ? AppColor.fourthColor : Colors.transparent, width: 2.5), image: DecorationImage(image: FileImage(img.file), fit: BoxFit.cover)),
      )),
      Positioned(bottom: 4, left: 4, child: Icon(img.isPrimary ? Icons.star_rounded : Icons.star_border_rounded, size: 20, color: img.isPrimary ? Colors.amber : Colors.white70)),
      Positioned(top: 2, right: 2, child: GestureDetector(onTap: () => _removeNew(i), child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)))),
    ]));
  }

  Widget _sec(bool isDark, String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 12, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColor.fourthColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: AppColor.fourthColor)),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColor.primaryColor)),
        ]),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }

  Widget _tf(TextEditingController c, String label, String hint, bool isDark, {bool req = false, int lines = 1, TextInputType? kb, TextDirection? dir}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColor.mediumText)),
      const SizedBox(height: 6),
      TextFormField(controller: c, maxLines: lines, keyboardType: kb, textDirection: dir,
        style: TextStyle(color: isDark ? Colors.white : AppColor.darkText, fontSize: 14),
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400], fontSize: 14),
          filled: true, fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColor.fourthColor, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
        validator: req ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null),
    ]);
  }

  Widget _dd<T>(String label, T? value, bool isDark, List<DropdownMenuItem<T>> items, ValueChanged<T?>? onChanged, {String? hint}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColor.mediumText)),
      const SizedBox(height: 6),
      Container(padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white12 : Colors.grey[300]!)),
        child: DropdownButtonHideUnderline(child: DropdownButton<T>(
          value: items.any((i) => i.value == value) ? value : null, isExpanded: true,
          hint: Text(hint ?? 'Select...', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400], fontSize: 14)),
          dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          style: TextStyle(color: isDark ? Colors.white : AppColor.darkText, fontSize: 14),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.white54 : Colors.grey[600]),
          items: items, onChanged: onChanged))),
    ]);
  }
}

class _ExistingImage {
  final String id;
  final String url;
  bool isPrimary;
  _ExistingImage({required this.id, required this.url, this.isPrimary = false});
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
