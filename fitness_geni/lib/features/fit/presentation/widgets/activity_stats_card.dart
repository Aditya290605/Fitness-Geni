import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Secondary activity stats card showing steps, calories, and distance
/// Clean horizontal layout with muted colors
/// Non-dominating visual presence (supportive to protein progress)
class ActivityStatsCard extends StatelessWidget {
  final int steps;
  final double caloriesBurned;
  final double distanceKm;
  final bool hasData;

  const ActivityStatsCard({
    super.key,
    required this.steps,
    required this.caloriesBurned,
    required this.distanceKm,
    this.hasData = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            'TODAY\'S ACTIVITY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.directions_walk_rounded,
                  value: _formatNumber(steps),
                  label: 'Steps',
                  iconColor: AppColors.primary,
                ),
              ),
              _Divider(),
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department_rounded,
                  value: _formatNumber(caloriesBurned.toInt()),
                  label: 'Calories',
                  iconColor: AppColors.warning,
                ),
              ),
              _Divider(),
              Expanded(
                child: _StatTile(
                  icon: Icons.route_rounded,
                  value: distanceKm.toStringAsFixed(1),
                  label: 'km',
                  iconColor: AppColors.info,
                ),
              ),
            ],
          ),

          // No data message
          if (!hasData) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Connect to Health to see your activity',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

/// Individual stat tile within the row
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: iconColor.withValues(alpha: 0.8)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Vertical divider between stat tiles
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.border.withValues(alpha: 0.5),
    );
  }
}
