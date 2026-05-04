import 'package:flutter/material.dart';

class AppColor {
  // Grayscale
  static const Color grey = Color(0xff8e8e8e);
  static const Color grey2 = Color.fromARGB(255, 66, 66, 66);
  static const Color black = Color(0xff000000);
  static const Color whiteColor = Colors.white;

  // Primary Background
  static const Color backgroundcolor = Color(0xfff0f9ff); // $light-blue
  static const Color backgroundcolor2 = Color(0xffffffff); // $white

  // Primary Brand Colors
  static const Color primaryColor = Color(0xff1a365d); // $primary-color
  static const Color secondColor = Color(0xff153149); // $secondary-color
  static const Color thirdColor = Color(0xff183458); // $secondary-color-light
  static const Color fourthColor = Color(0xff2563eb); // $accent-color


  // Extra Tones
  static const Color earthBrown = Color(0xff2e2e2e); // $harvard-dark-gray
  static const Color desertSand = Color(0xfff5f5f5); // $harvard-gray
  static const Color terracotta = Color(0xff2563eb); // mapped to accent

  // Status Colors
  static const Color warningColor = Color(0xffdc2626); // $danger
  static const Color successColor = Color(0xff059669); // $success
  static const Color blackColor = Colors.black;

  // Card & Surface Colors
  static const Color cardBackground = Color(0xfffefdfb);
  static const Color cardShadow = Color(0x1a000000);

  // Neutral colors
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color mediumText = Color(0xFF666666);
  static const Color lightText = Color(0xFF999999);
  static const Color borderGray = Color(0xFFE0E0E0);
}

// Extended App Colors for Carpet Store
class AppColors {
  // Primary colors matching your logo
  static const Color primaryBurgundy = Color(0xff1a365d);
  static const Color secondaryBurgundy = Color(0xff153149);
  static const Color lightBurgundy = Color(0xff2563eb);
  static const Color darkBurgundy = Color(0xff183458);

  // Background colors
  static const Color creamBackground = Color(0xfff0f9ff);
  static const Color lightCream = Color(0xffffffff);
  static const Color warmBeige = Color(0xfff5f5f5);

  // Accent colors
  static const Color bronzeAccent = Color(0xff2563eb);
  static const Color earthBrown = Color(0xff2e2e2e);

  // Neutral colors
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color mediumText = Color(0xFF666666);
  static const Color lightText = Color(0xFF999999);
  static const Color borderGray = Color(0xFFE0E0E0);

  // Status colors
  static const Color success = Color(0xff059669);
  static const Color error = Color(0xffdc2626);
  static const Color warning = Color(0xffd97706);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBurgundy, secondaryBurgundy],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [creamBackground, lightCream],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// Extension to easily access theme colors
extension AppColorsExtension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
