import 'package:flutter/material.dart';
import 'package:renty/core/constant/app_colors.dart';
export 'package:renty/utils/translations.dart';

/// Centralized navigation and notification service for standard Flutter.
/// Replaces GetX routing and Get.snackbar with clean, testable Flutter primitives.
class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static BuildContext? get context => navigatorKey.currentContext;

  /// Navigate to named route
  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Push replacement named
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// Push and clear stack (e.g. for logout or login redirect)
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName, {
    bool Function(Route<dynamic>)? predicate,
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Push a direct widget page (replaces Get.to(() => Widget()))
  static Future<T?> push<T extends Object?>(Widget page) {
    return navigatorKey.currentState!.push<T>(
      MaterialPageRoute<T>(builder: (_) => page),
    );
  }

  /// Go back
  static void pop<T extends Object?>([T? result]) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState!.pop<T>(result);
    }
  }

  /// Can pop check
  static bool canPop() => navigatorKey.currentState?.canPop() ?? false;

  /// Show standard styled snackbar (replaces Get.snackbar)
  static void showSnackBar(
    String title,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    Color? colorText,
    dynamic snackPosition,
    Widget? icon,
    SnackBarAction? action,
  }) {
    final state = messengerKey.currentState;
    if (state == null) return;

    state.hideCurrentSnackBar();

    final effectiveTextColor = textColor ?? colorText ?? Colors.white;

    final bg = backgroundColor ??
        (isError
            ? const Color(0xFFDC2626)
            : AppColor.primaryColor.withOpacity(0.95));

    state.showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 12),
            ] else if (isError) ...[
              const Icon(Icons.error_outline, color: Colors.white, size: 22),
              const SizedBox(width: 12),
            ] else ...[
              const Icon(Icons.info_outline, color: Colors.white, size: 22),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: effectiveTextColor,
                      ),
                    ),
                  if (message.isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        color: effectiveTextColor.withOpacity(0.9),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        action: action,
      ),
    );
  }
}
