import 'dart:io';
import 'package:renty/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:renty/core/utils/app_navigator.dart';

/// Show exit confirmation dialog with app theme styling
Future<bool> alertExitApp(BuildContext context) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  bool? shouldExit = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppColor.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [Colors.white, AppColor.backgroundcolor.withOpacity(0.5)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with gradient background
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [AppColor.fourthColor.withOpacity(0.3), AppColor.primaryColor.withOpacity(0.3)]
                        : [
                            AppColor.primaryColor.withOpacity(0.2),
                            AppColor.secondColor.withOpacity(0.2),
                          ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.exit_to_app_rounded,
                  size: 48,
                  color: isDark ? const Color(0xFF93C5FD) : AppColor.primaryColor,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                "Exit App".tr,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColor.primaryColor,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                "Are you sure you want to exit?".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : AppColor.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isDark ? Colors.white54 : AppColor.primaryColor,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "cancel".tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Exit Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColor.primaryColor,
                            AppColor.secondColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "yes".tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  if (shouldExit == true) {
    exit(0);
  }

  return Future.value(false);
}