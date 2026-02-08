import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';

/// Premium statistics card showing nutrition progress with circular and linear indicators
class NutritionStatisticsCard extends StatelessWidget {
  final int caloriesTarget;
  final int caloriesConsumed;
  final double proteinTarget;
  final double proteinConsumed;
  final double carbsTarget;
  final double carbsConsumed;
  final double fatTarget;
  final double fatConsumed;
  final VoidCallback? onTap;

  const NutritionStatisticsCard({
    super.key,
    required this.caloriesTarget,
    required this.caloriesConsumed,
    required this.proteinTarget,
    required this.proteinConsumed,
    required this.carbsTarget,
    required this.carbsConsumed,
    required this.fatTarget,
    required this.fatConsumed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final caloriesLeft = (caloriesTarget - caloriesConsumed).clamp(
      0,
      caloriesTarget,
    );
    final caloriesProgress = caloriesTarget > 0
        ? (caloriesConsumed / caloriesTarget).clamp(0.0, 1.0)
        : 0.0;
    final proteinProgress = proteinTarget > 0
        ? (proteinConsumed / proteinTarget).clamp(0.0, 1.0)
        : 0.0;
    final carbsProgress = carbsTarget > 0
        ? (carbsConsumed / carbsTarget).clamp(0.0, 1.0)
        : 0.0;
    final fatProgress = fatTarget > 0
        ? (fatConsumed / fatTarget).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Statistics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 18,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Main content
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular progress for calories
                CircularPercentIndicator(
                  radius: 55,
                  lineWidth: 10,
                  percent: caloriesProgress,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Kcal left',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        caloriesLeft.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  progressColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 1200,
                ),

                const SizedBox(width: 32),

                // Nutrition bars
                Expanded(
                  child: Column(
                    children: [
                      _buildNutritionBar(
                        'Protein',
                        proteinProgress,
                        '${proteinConsumed.toStringAsFixed(0)}/${proteinTarget.toStringAsFixed(0)} g',
                      ),
                      const SizedBox(height: 14),
                      _buildNutritionBar(
                        'Carbs',
                        carbsProgress,
                        '${carbsConsumed.toStringAsFixed(0)}/${carbsTarget.toStringAsFixed(0)} g',
                      ),
                      const SizedBox(height: 14),
                      _buildNutritionBar(
                        'Fat',
                        fatProgress,
                        '${fatConsumed.toStringAsFixed(0)}/${fatTarget.toStringAsFixed(0)} g',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionBar(String label, double progress, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: 6,
          percent: progress,
          progressColor: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: 0.25),
          barRadius: const Radius.circular(10),
          animation: true,
          animationDuration: 1200,
        ),
      ],
    );
  }
}
