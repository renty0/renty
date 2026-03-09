import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static late SharedPreferences _prefs;
  static String? _currentUserId;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  static String _getThemeKey() {
    return 'theme_mode_${_currentUserId ?? 'default'}';
  }

  static ThemeMode getThemeMode() {
    final themeString = _prefs.getString(_getThemeKey()) ?? 'system';
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> setThemeMode(ThemeMode themeMode) async {
    String themeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }
    await _prefs.setString(_getThemeKey(), themeString);
  }

  static bool isDarkMode() {
    return getThemeMode() == ThemeMode.dark;
  }

  static bool isLightMode() {
    return getThemeMode() == ThemeMode.light;
  }

  static bool isSystemMode() {
    return getThemeMode() == ThemeMode.system;
  }

  static Future<void> clearUserPreferences() async {
    if (_currentUserId != null) {
      await _prefs.remove(_getThemeKey());
    }
  }
}

class AppThemes {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8b3c3c),
        brightness: Brightness.light,
        primary: const Color(0xFF8b3c3c),
        secondary: const Color(0xFFc26b6b),
        tertiary: const Color(0xFFd4a574),
        surface: const Color(0xFFFEFDFB),
        background: const Color(0xFFF1E9DB),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF1A1A1A),
        onBackground: const Color(0xFF1A1A1A),
      ),

      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF1E9DB),

      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF541d2c)),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFF8b3c3c)),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF8b3c3c)),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF1A1A1A), height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF666666), height: 1.4),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF8b3c3c),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: const Color(0x1a000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFFFEFDFB),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE8DCC8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8b3c3c), width: 2)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8b3c3c),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF8b3c3c),
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8b3c3c),
        brightness: Brightness.dark,
        primary: const Color(0xFFdf9696),
        secondary: const Color(0xFFc26b6b),
        tertiary: const Color(0xFFd4a574),
        surface: const Color(0xFF2C2520),
        background: const Color(0xFF1A1614),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: const Color(0xFFE8DCC8),
        onBackground: const Color(0xFFE8DCC8),
      ),

      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1614),

      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFE8DCC8)),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFFdf9696)),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFFdf9696)),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFE8DCC8)),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFE8DCC8)),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFE8DCC8), height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFB3B3B3), height: 1.4),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C2520),
        foregroundColor: Color(0xFFE8DCC8),
        elevation: 0,
        centerTitle: true,
      ),

      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF2C2520),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2520),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFdf9696), width: 2)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFdf9696),
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFdf9696),
        foregroundColor: Colors.black,
      ),
    );
  }
}