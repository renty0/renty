import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static late SharedPreferences _prefs;
  static String? _currentUserId;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  static String _getLanguageKey() {
    return 'selected_language_${_currentUserId ?? 'default'}';
  }

  static Locale getCurrentLocale() {
    final languageCode = getCurrentLanguageCode();
    return Locale(languageCode);
  }

  static Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_getLanguageKey(), languageCode);
  }

  static String getCurrentLanguageCode() {
    final savedLanguage = _prefs.getString(_getLanguageKey());
    if (savedLanguage != null) {
      return savedLanguage;
    }
    // Fallback to mobile system language
    try {
      final systemLanguage = ui.PlatformDispatcher.instance.locale.languageCode;
      if (systemLanguage == 'ar') {
        return 'ar';
      }
    } catch (_) {}
    return 'en';
  }

  static bool isArabic() {
    return getCurrentLanguageCode() == 'ar';
  }

  static bool isEnglish() {
    return getCurrentLanguageCode() == 'en';
  }

  static List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
    ];
  }

  static Future<void> clearUserPreferences() async {
    if (_currentUserId != null) {
      await _prefs.remove(_getLanguageKey());
    }
  }
}