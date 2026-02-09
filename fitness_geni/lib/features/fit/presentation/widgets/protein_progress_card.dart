import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';

/// Hero widget showing today's protein progress
/// Large circular indicator with bold center number
/// Green accent when goal is reached
class ProteinProgressCard extends StatelessWidget {
  final double proteinConsumed;
  final double proteinTarget;

  const ProteinProgressCard({
    super.key,
    required this.proteinConsumed,
    required this.proteinTarget,
  });

  double get _progress => proteinTarget > 0
      ? (proteinConsumed / proteinTarget).clamp(0.0, 1.0)
      : 0.0;

  bool get _goalReached => proteinConsumed >= proteinTarget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 18,
                color: _goalReached
                    ? AppColors.success
                    : AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'PROTEIN TODAY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Large circular progress indicator
          CircularPercentIndicator(
            radius: 90,
            lineWidth: 14,
            percent: _progress,
            animation: true,
            animationDuration: 800,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: _goalReached ? AppColors.success : AppColors.primary,
            backgroundColor: AppColors.border.withValues(alpha: 0.5),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bold protein number
                Text(
                  '${proteinConsumed.toInt()}',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'of ${proteinTarget.toInt()}g',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Status message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _goalReached
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _goalReached
                  ? '🎉 Goal reached!'
                  : '${(proteinTarget - proteinConsumed).toInt()}g to go',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _goalReached ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
