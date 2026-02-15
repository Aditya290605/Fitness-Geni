import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Secondary activity stats card showing steps, calories, and distance
/// White card with colored icon badges and clean visual hierarchy
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
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
          const SizedBox(height: 18),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.directions_walk_rounded,
                  value: _formatNumber(steps),
                  label: 'Steps',
                  iconColor: AppColors.primary,
                  bgColor: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
              _Divider(),
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department_rounded,
                  value: _formatNumber(caloriesBurned.toInt()),
                  label: 'Calories',
                  iconColor: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFFEF3C7),
                ),
              ),
              _Divider(),
              Expanded(
                child: _StatTile(
                  icon: Icons.route_rounded,
                  value: distanceKm.toStringAsFixed(1),
                  label: 'km',
                  iconColor: const Color(0xFF3B82F6),
                  bgColor: const Color(0xFFDBEAFE),
                ),
              ),
            ],
          ),

          // No data message
          if (!hasData) ...[
            const SizedBox(height: 14),
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

/// Individual stat tile with colored icon background
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color bgColor;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
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
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.border.withValues(alpha: 0.0),
            AppColors.border.withValues(alpha: 0.5),
            AppColors.border.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
