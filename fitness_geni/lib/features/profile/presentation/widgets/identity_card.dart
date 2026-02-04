import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/user_profile.dart';

/// User identity card component
class IdentityCard extends StatelessWidget {
  final UserProfile profile;

  const IdentityCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Profile photo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: profile.photoUrl != null
                ? ClipOval(
                    child: Image.network(profile.photoUrl!, fit: BoxFit.cover),
                  )
                : Icon(Icons.person, size: 40, color: AppColors.primary),
          ),

          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.cake_outlined,
                  '${profile.age} years',
                  context,
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.height,
                  '${profile.heightCm.round()} cm',
                  context,
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Icons.monitor_weight_outlined,
                  '${profile.weightKg.round()} kg',
                  context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
