import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/controllers/marketplace_controller.dart';

// Egypt governorates — matches EGYPT_GOVERNORATES on the web
const _governorates = [
  'Cairo', 'Alexandria', 'Giza', 'Qalyubia', 'Sharqia', 'Dakahlia',
  'Beheira', 'Kafr El Sheikh', 'Gharbia', 'Monufia', 'Damietta',
  'Port Said', 'Ismailia', 'Suez', 'North Sinai', 'South Sinai',
  'Matrouh', 'Faiyum', 'Beni Suef', 'Minya', 'Assiut', 'Sohag',
  'Qena', 'Luxor', 'Aswan', 'Red Sea', 'New Valley',
];

class MpFilterSheet extends StatefulWidget {
  final MarketplaceController controller;
  const MpFilterSheet({super.key, required this.controller});

  static Future<void> show(BuildContext context, MarketplaceController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MpFilterSheet(controller: controller),
    );
  }

  @override
  State<MpFilterSheet> createState() => _MpFilterSheetState();
}

class _MpFilterSheetState extends State<MpFilterSheet> {
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;
  String? _city;
  String? _condition;
  String? _type;
  double? _minPrice;
  double? _maxPrice;
  DateTime? _startDate;
  DateTime? _endDate;
  int? _minRating;

  @override
  void initState() {
    super.initState();
    final c = widget.controller;
    _city      = c.selectedCity.value;
    _condition = c.selectedCondition.value;
    _type      = c.selectedType.value;
    _minPrice  = c.minPrice.value;
    _maxPrice  = c.maxPrice.value;
    _startDate = c.startDate.value;
    _endDate   = c.endDate.value;
    _minRating = c.minRating.value;
    _minCtrl   = TextEditingController(text: _minPrice?.toStringAsFixed(0) ?? '');
    _maxCtrl   = TextEditingController(text: _maxPrice?.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final c = widget.controller;
    c.selectedCity.value      = _city;
    c.selectedCondition.value = _condition;
    c.selectedType.value      = _type;
    c.minPrice.value          = _minCtrl.text.isNotEmpty ? double.tryParse(_minCtrl.text) : null;
    c.maxPrice.value          = _maxCtrl.text.isNotEmpty ? double.tryParse(_maxCtrl.text) : null;
    c.startDate.value         = _startDate;
    c.endDate.value           = _endDate;
    c.minRating.value         = _minRating;
    c.applyFilters();
    Navigator.pop(context);
  }

  void _clear() {
    widget.controller.clearFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scroll) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          controller: scroll,
          padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Handle
            Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
            )),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Filters', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColor.primaryColor)),
              TextButton(onPressed: _clear, child: Text('Clear All', style: TextStyle(color: AppColor.fourthColor))),
            ]),
            const SizedBox(height: 20),

            // ── City (Governorate dropdown)
            _label('City / Governorate', isDark),
            const SizedBox(height: 8),
            _dropdown(
              value: _city,
              hint: 'Select governorate',
              items: _governorates,
              isDark: isDark,
              onChanged: (v) => setState(() => _city = v),
            ),
            const SizedBox(height: 20),

            // ── Condition
            _label('Condition', isDark),
            const SizedBox(height: 8),
            _chipGroup(
              options: const {'New': 'new', 'Like New': 'like_new', 'Good': 'good', 'Used': 'used', 'Fair': 'fair'},
              selected: _condition,
              isDark: isDark,
              onTap: (v) => setState(() => _condition = _condition == v ? null : v),
            ),
            const SizedBox(height: 20),

            // ── Type
            _label('Listing Type', isDark),
            const SizedBox(height: 8),
            _chipGroup(
              options: const {'Standard': 'standard', 'Premium': 'premium'},
              selected: _type,
              isDark: isDark,
              onTap: (v) => setState(() => _type = _type == v ? null : v),
            ),
            const SizedBox(height: 20),

            // ── Price Range
            _label('Price Range (EGP/day)', isDark),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _priceField(_minCtrl, 'Min', isDark)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('–', style: TextStyle(color: Colors.grey[500], fontSize: 20))),
              Expanded(child: _priceField(_maxCtrl, 'Max', isDark)),
            ]),
            const SizedBox(height: 20),

            // ── Availability (Date Range)
            _label('Availability', isDark),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _datePicker(
                label: _startDate == null ? 'Start date' : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                isDark: isDark,
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) setState(() => _startDate = d);
                },
                onClear: _startDate != null ? () => setState(() { _startDate = null; _endDate = null; }) : null,
              )),
              const SizedBox(width: 10),
              Expanded(child: _datePicker(
                label: _endDate == null ? 'End date' : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                isDark: isDark,
                onTap: _startDate == null ? null : () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
                    firstDate: _startDate!.add(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) setState(() => _endDate = d);
                },
                onClear: _endDate != null ? () => setState(() => _endDate = null) : null,
              )),
            ]),
            const SizedBox(height: 20),

            // ── Min Rating
            _label('Minimum Rating', isDark),
            const SizedBox(height: 8),
            Row(children: List.generate(5, (i) {
              final star = i + 1;
              final on = _minRating != null && star <= _minRating!;
              return GestureDetector(
                onTap: () => setState(() => _minRating = _minRating == star ? null : star),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(on ? Icons.star_rounded : Icons.star_border_rounded,
                    color: on ? const Color(0xFFF59E0B) : Colors.grey[400], size: 32),
                ),
              );
            })),
            if (_minRating != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('$_minRating★ & above', style: TextStyle(color: AppColor.fourthColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 32),

            // ── Apply button
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.fourthColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _label(String text, bool isDark) => Text(text, style: TextStyle(
    fontWeight: FontWeight.w700, fontSize: 14,
    color: isDark ? Colors.white70 : AppColor.darkText,
  ));

  Widget _dropdown(
      {required String? value, required String hint, required List<String> items,
       required bool isDark, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: Text(hint, style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400])),
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          style: TextStyle(color: isDark ? Colors.white : AppColor.darkText, fontSize: 14),
          onChanged: onChanged,
          items: [
            DropdownMenuItem<String?>(value: null, child: Text('All cities', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[500]))),
            ...items.map((g) => DropdownMenuItem<String?>(value: g, child: Text(g))),
          ],
        ),
      ),
    );
  }

  Widget _chipGroup({required Map<String, String> options, required String? selected,
      required bool isDark, required ValueChanged<String> onTap}) {
    return Wrap(spacing: 8, runSpacing: 8, children: options.entries.map((e) {
      final on = selected == e.value;
      return GestureDetector(
        onTap: () => onTap(e.value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: on ? AppColor.fourthColor : (isDark ? Colors.grey[800] : Colors.grey[100]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(e.key, style: TextStyle(
            color: on ? Colors.white : (isDark ? Colors.white70 : AppColor.mediumText),
            fontWeight: on ? FontWeight.w700 : FontWeight.w500, fontSize: 13,
          )),
        ),
      );
    }).toList());
  }

  Widget _priceField(TextEditingController ctrl, String hint, bool isDark) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: TextStyle(color: isDark ? Colors.white : AppColor.darkText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400]),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _datePicker({required String label, required bool isDark, VoidCallback? onTap, VoidCallback? onClear}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(Icons.calendar_today_rounded, size: 16, color: isDark ? Colors.white38 : Colors.grey[500]),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(
            color: onTap == null ? (isDark ? Colors.white24 : Colors.grey[300]) : (isDark ? Colors.white70 : AppColor.darkText),
            fontSize: 12,
          ))),
          if (onClear != null)
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close_rounded, size: 16, color: isDark ? Colors.white38 : Colors.grey[400]),
            ),
        ]),
      ),
    );
  }
}
