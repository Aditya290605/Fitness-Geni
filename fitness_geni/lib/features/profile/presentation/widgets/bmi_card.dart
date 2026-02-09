import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/user_profile.dart';

/// Premium BMI Card with glassmorphism and animated feel
class BmiCard extends StatelessWidget {
  final UserProfile profile;

  const BmiCard({super.key, required this.profile});

  Color _getBmiColor() {
    switch (profile.bmiCategory) {
      case 'Underweight':
        return const Color(0xFF3B82F6); // Blue
      case 'Normal':
        return const Color(0xFF10B981); // Green
      case 'Overweight':
        return const Color(0xFFF59E0B); // Orange
      case 'Obese':
        return const Color(0xFFEF4444); // Red
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bmiColor = _getBmiColor();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: bmiColor.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: bmiColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  bmiColor.withOpacity(0.15),
                  bmiColor.withOpacity(0.08),
                  Colors.white.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.4, 1.0],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: bmiColor.withOpacity(0.3), width: 2),
            ),
            child: Column(
              children: [
                // Floating label with glow
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: bmiColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: bmiColor.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Text(
                    'YOUR BMI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                      color: bmiColor.withOpacity(0.8),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Giant BMI value with glow effect
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [bmiColor, bmiColor.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        profile.bmi.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                          letterSpacing: -3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'kg/m²',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Category badge - premium pill style
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        bmiColor.withOpacity(0.2),
                        bmiColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: bmiColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: bmiColor.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    profile.bmiCategory.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: bmiColor,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Description with better styling
                Text(
                  profile.bmiDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
