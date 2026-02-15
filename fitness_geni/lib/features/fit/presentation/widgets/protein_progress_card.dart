import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';

/// Hero widget showing today's protein progress
/// Large circular indicator with gradient ring and bold center number
/// Green accent when goal is reached, premium card design
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
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: (_goalReached ? AppColors.success : AppColors.primary)
                .withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      (_goalReached
                              ? AppColors.success
                              : AppColors.textTertiary)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 16,
                  color: _goalReached
                      ? AppColors.success
                      : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 8),
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
          const SizedBox(height: 28),

          // Large circular progress indicator
          CircularPercentIndicator(
            radius: 90,
            lineWidth: 14,
            percent: _progress,
            animation: true,
            animationDuration: 800,
            circularStrokeCap: CircularStrokeCap.round,
            linearGradient: _goalReached
                ? const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  )
                : LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
            backgroundColor: AppColors.border.withValues(alpha: 0.35),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bold protein number
                Text(
                  '${proteinConsumed.toInt()}',
                  style: const TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w800,
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

          // Linear progress bar (secondary visual)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 6,
              width: 180,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppColors.border.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation(
                  _goalReached ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Status message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _goalReached
                  ? AppColors.success.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
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
