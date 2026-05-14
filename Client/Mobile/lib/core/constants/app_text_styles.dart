import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App typography — matches the web Alexandria font system
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.alexandria();

  // Headings
  static TextStyle get heading1 => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        letterSpacing: -0.5,
      );

  static TextStyle get heading2 => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  static TextStyle get heading3 => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  // Body
  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.gray600,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.gray500,
      );

  // Captions
  static TextStyle get caption => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.gray500,
      );

  static TextStyle get captionSmall => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.gray400,
      );

  // Button
  static TextStyle get button => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      );

  // Link
  static TextStyle get link => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.accent,
      );

  // Input label
  static TextStyle get inputLabel => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.gray600,
      );

  // Error text
  static TextStyle get error => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.danger,
      );
}
