import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/user_profile.dart';

/// Hero BMI card - Large and prominent
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
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getBmiColor().withValues(alpha: 0.15),
            _getBmiColor().withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getBmiColor().withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getBmiColor().withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Label
          Text(
            'YOUR BMI',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: _getBmiColor().withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 16),

          // Huge BMI value
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                profile.bmi.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  color: _getBmiColor(),
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'kg/m²',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _getBmiColor().withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _getBmiColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getBmiColor().withValues(alpha: 0.3)),
            ),
            child: Text(
              profile.bmiCategory.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: _getBmiColor(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            profile.bmiDescription,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
