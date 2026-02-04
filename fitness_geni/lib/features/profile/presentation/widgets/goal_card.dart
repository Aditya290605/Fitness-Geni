import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/user_profile.dart';

/// Goal and daily needs card
class GoalCard extends StatelessWidget {
  final UserProfile profile;

  const GoalCard({super.key, required this.profile});

  IconData _getGoalIcon() {
    switch (profile.fitnessGoal) {
      case 'Weight Loss':
        return Icons.trending_down;
      case 'Weight Gain':
        return Icons.trending_up;
      case 'Maintain':
        return Icons.trending_flat;
      default:
        return Icons.flag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getGoalIcon(), color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Your Goal',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Goal
          Text(
            profile.fitnessGoal,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 20),

          // Divider
          Divider(color: AppColors.border.withValues(alpha: 0.5)),

          const SizedBox(height: 16),

          // Daily needs
          Text(
            'Estimated Daily Needs',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          _buildNeedRow(
            Icons.local_fire_department_outlined,
            'Calories',
            '~${profile.dailyCalories} kcal',
            context,
          ),

          const SizedBox(height: 8),

          _buildNeedRow(
            Icons.fitness_center_outlined,
            'Protein',
            '~${profile.dailyProteinG.round()} g',
            context,
          ),

          const SizedBox(height: 16),

          // Helper text
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Calculated based on your profile details',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNeedRow(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
