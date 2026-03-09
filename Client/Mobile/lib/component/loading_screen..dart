import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:renty/core/constant/imgaeasset.dart';
import 'package:renty/core/constant/app_colors.dart';

class LoadingScreen extends StatelessWidget {
  final String? message;
  final Duration? duration;

  const LoadingScreen({
    Key? key,
    this.message,
    this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundcolor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            Lottie.asset(
              AppImageAsset.animationLoading,
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 30),

            // Loading Message
            if (message != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColor.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Loading Indicator
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}