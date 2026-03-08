import 'package:flutter/material.dart';
import 'package:renty/core/constant/app_colors.dart';
class CustomButtonOnBoarding extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomButtonOnBoarding({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      height: 40,
      child: MaterialButton(
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 0),
        textColor: Colors.white,
        onPressed: onPressed,
        color: AppColor.primaryColor,
        child: const Text("Continue"),
      ),
    );
  }
}