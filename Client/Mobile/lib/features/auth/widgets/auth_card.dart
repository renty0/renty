import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// White glassmorphism card matching the web's auth containers
/// (24px radius, shadow, slide-up animation).
class AuthCard extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const AuthCard({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 30, end: 0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutQuart,
      builder: (context, offset, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutQuart,
          builder: (context, opacity, innerChild) {
            return Transform.translate(
              offset: Offset(0, offset),
              child: Opacity(
                opacity: opacity,
                child: innerChild,
              ),
            );
          },
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 440,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 50,
              offset: const Offset(0, 25),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: child,
        ),
      ),
    );
  }
}
