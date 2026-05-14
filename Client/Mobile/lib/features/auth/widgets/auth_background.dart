import 'package:flutter/material.dart';

/// Gradient background matching the web's auth page background
/// (radial gradient overlay on primary color).
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1628),
            Color(0xFF0C295E),
            Color(0xFF153149),
          ],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
