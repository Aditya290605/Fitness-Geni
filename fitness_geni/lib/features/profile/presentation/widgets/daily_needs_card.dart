import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/user_profile.dart';

/// Daily needs card - Prominent display
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
            // Calories
            Expanded(
              child: _buildNeedCard(
                context,
                icon: Icons.local_fire_department,
                label: 'CALORIES',
                value: profile.dailyCalories.toString(),
                unit: 'kcal',
                color: const Color(0xFFEF4444), // Red for fire
              ),
            ),

            const SizedBox(width: 16),

            // Protein
            Expanded(
              child: _buildNeedCard(
                context,
                icon: Icons.fitness_center,
                label: 'PROTEIN',
                value: profile.dailyProteinG.round().toString(),
                unit: 'g',
                color: AppColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Row 2: Carbs (full width)
        _buildNeedCard(
          context,
          icon: Icons.bakery_dining_outlined,
          label: 'CARBOHYDRATES',
          value:
              '${(profile.dailyCalories * 0.5 / 4).round()}', // Rough estimate: 50% of calories from carbs
          unit: 'g',
          color: const Color(0xFFF59E0B), // Amber for carbs
        ),
      ],
    );
  }

  Widget _buildNeedCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),

          const SizedBox(height: 16),

          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: color.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 8),

          // Value - Responsive
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
