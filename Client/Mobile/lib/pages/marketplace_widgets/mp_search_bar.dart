import 'package:flutter/material.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/controllers/marketplace_controller.dart';

class MpSearchBar extends StatefulWidget {
  final MarketplaceController controller;
  final bool isDark;
  const MpSearchBar({super.key, required this.controller, required this.isDark});

  @override
  State<MpSearchBar> createState() => _MpSearchBarState();
}

class _MpSearchBarState extends State<MpSearchBar> {
  late final TextEditingController _ctrl;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.controller.searchTerm.value);
    _hasText = _ctrl.text.isNotEmpty;
    _ctrl.addListener(() {
      final has = _ctrl.text.isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    widget.controller.searchTerm.value = _ctrl.text.trim();
    widget.controller.applyFilters();
    FocusScope.of(context).unfocus();
  }

  void _clear() {
    _ctrl.clear();
    widget.controller.searchTerm.value = '';
    widget.controller.applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return TextField(
      controller: _ctrl,
      onSubmitted: (_) => _submit(),
      textInputAction: TextInputAction.search,
      style: TextStyle(
        color: isDark ? Colors.white : AppColor.darkText,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'What do you want to rent?',
        hintStyle: TextStyle(
          color: isDark ? Colors.white30 : Colors.grey[400],
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 20,
          color: isDark ? Colors.white38 : Colors.grey[400],
        ),
        suffixIcon: _hasText
            ? IconButton(
                onPressed: _clear,
                icon: Icon(Icons.close_rounded, size: 18,
                    color: isDark ? Colors.white54 : Colors.grey[500]),
              )
            : null,
        filled: true,
        fillColor: isDark ? const Color(0xFF252525) : const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide(color: AppColor.fourthColor.withOpacity(0.5), width: 1.5),
        ),
      ),
    );
  }
}
