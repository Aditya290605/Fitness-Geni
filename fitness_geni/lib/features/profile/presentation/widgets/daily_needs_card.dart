import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/user_profile.dart';

/// Premium Daily Needs Card with glassmorphism
class DailyNeedsCard extends StatelessWidget {
  final UserProfile profile;

  const DailyNeedsCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Calories and Protein
        Row(
          children: [
            Expanded(
              child: _buildPremiumCard(
                context,
                icon: Icons.local_fire_department_rounded,
                label: 'CALORIES',
                value: profile.dailyCalories.toString(),
                unit: 'kcal',
                color: const Color(0xFFEF4444),
                gradient: [const Color(0xFFEF4444), const Color(0xFFF87171)],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildPremiumCard(
                context,
                icon: Icons.fitness_center_rounded,
                label: 'PROTEIN',
                value: profile.dailyProteinG.round().toString(),
                unit: 'g',
                color: const Color(0xFF06B6D4),
                gradient: [const Color(0xFF06B6D4), const Color(0xFF22D3EE)],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Row 2: Carbs and Fats
        Row(
          children: [
            Expanded(
              child: _buildPremiumCard(
                context,
                icon: Icons.grain_rounded,
                label: 'CARBS',
                value: '${(profile.dailyCalories * 0.5 / 4).round()}',
                unit: 'g',
                color: const Color(0xFFF59E0B),
                gradient: [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildPremiumCard(
                context,
                icon: Icons.water_drop_rounded,
                label: 'FATS',
                value: '${(profile.dailyCalories * 0.25 / 9).round()}',
                unit: 'g',
                color: const Color(0xFF8B5CF6),
                gradient: [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.12),
                  color.withOpacity(0.05),
                  Colors.white.withOpacity(0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.3, 1.0],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: color.withOpacity(0.25), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient Icon Circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradient[0].withOpacity(0.9),
                        gradient[1].withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),

                const SizedBox(height: 14),

                // Label
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: color.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 8),

                // Value with unit
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: gradient,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color.withOpacity(0.6),
                        ),
                      ),
                    ],
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
