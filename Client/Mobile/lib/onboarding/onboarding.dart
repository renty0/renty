import 'package:flutter/material.dart';
import 'package:renty/core/constant/app_colors.dart';
import 'package:renty/core/constant/imgaeasset.dart';
import 'package:renty/main.dart';
import 'package:get/get.dart';

class OnBoarding extends StatelessWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // App Logo
              Image.asset(
                AppImageAsset.logo,
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 40),

              // App Title
              Text(
                "Welcome to Renty".tr,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // App Description
              Text(
                "Your go-to platform for renting anything you need — "
                "from electronics and clothing to tools and vehicles. "
                "Save money, earn passive income, and access more with less.".tr,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColor.grey,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    // Mark onboarding as completed
                    await sharedPref.setString("step", "1");
                    Navigator.of(context).pushReplacementNamed("/login");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Continue".tr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
