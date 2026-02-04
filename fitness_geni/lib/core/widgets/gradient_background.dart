import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable gradient background widget
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({super.key, required this.child, this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              colors ??
              [
                AppColors.primaryLight.withValues(alpha: 0.15),
                AppColors.background,
                AppColors.primary.withValues(alpha: 0.05),
              ],
        ),
      ),
      child: child,
    );
  }
}
