import 'dart:io';
import 'package:renty/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Show exit confirmation dialog with app theme styling
Future<bool> alertExitApp(BuildContext context) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  bool? shouldExit = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: isDark ? Color(0xFF2C2520) : AppColor.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Color(0xFF2C2520), Color(0xFF1A1614)]
                  : [Colors.white, AppColor.backgroundcolor.withOpacity(0.5)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with gradient background
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primaryColor.withOpacity(0.2),
                      AppColor.secondColor.withOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.exit_to_app_rounded,
                  size: 48,
                  color: AppColor.primaryColor,
                ),
              ),

              SizedBox(height: 20),

              // Title
              Text(
                "Exit App",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),

              SizedBox(height: 12),

              // Message
              Text(
                "Are you sure you want to exit?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColor.backgroundcolor : AppColor.grey,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 30),

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
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: AppColor.primaryColor,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Exit Button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
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
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "yes",
                          style: TextStyle(
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

/// Show exit confirmation dialog using GetX (Alternative method)
Future<bool> alertExitAppGetX() {
  return Get.defaultDialog<bool>(
    title: "Exit App",
    titleStyle: TextStyle(
      color: AppColor.primaryColor,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    middleText: "Are you sure you want to exit?",
    backgroundColor: AppColor.cardBackground,
    radius: 20,
    actions: [
      OutlinedButton(
        onPressed: () {
          Get.back(result: false);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColor.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Cancel",
          style: TextStyle(color: AppColor.primaryColor),
        ),
      ),
      ElevatedButton(
        onPressed: () {
          Get.back(result: true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text("Exit"),
      ),
    ],
  ).then((value) {
    if (value == true) {
      exit(0);
    }
    return Future.value(false);
  });
}