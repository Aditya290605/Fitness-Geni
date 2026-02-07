import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/auth/profile_adapter.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/bmi_card.dart';
import '../widgets/daily_needs_card.dart';
import '../widgets/identity_card.dart';

/// Profile screen - Redesigned with prominent metrics
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use real data from Supabase instead of mock data
    final supabaseProfile = ref.watch(currentProfileProvider);

    if (supabaseProfile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Convert Supabase Profile to UserProfile for display
    final profile = supabaseProfile.toUserProfile();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Header
              Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // Identity Card - Compact
              IdentityCard(profile: profile),

              const SizedBox(height: 24),

              // HERO: BMI Card - Large and prominent
              BmiCard(profile: profile),

              const SizedBox(height: 20),

              // Section Header
              Text(
                'Daily Needs',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // HERO: Daily Needs - Side by side cards
              DailyNeedsCard(profile: profile),

              const SizedBox(height: 20),

              // Goal Card - Compact
              _buildGoalCard(context, profile),

              const SizedBox(height: 20),

              // Explanation
              _buildExplanationCard(context, profile),

              const SizedBox(height: 24),

              // Settings
              _buildSettingsSection(context, ref),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, profile) {
    IconData getGoalIcon() {
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.accent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(getGoalIcon(), color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Goal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.fitnessGoal,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard(BuildContext context, profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What This Means',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.goalExplanation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Profile - Coming Soon')),
                  );
                },
              ),
              Divider(
                height: 1,
                color: AppColors.border,
                indent: 16,
                endIndent: 16,
              ),
              _buildSettingsTile(
                context,
                icon: Icons.flag_outlined,
                title: 'Change Goal',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Change Goal - Coming Soon')),
                  );
                },
              ),
              Divider(
                height: 1,
                color: AppColors.border,
                indent: 16,
                endIndent: 16,
              ),
              _buildSettingsTile(
                context,
                icon: Icons.logout,
                title: 'Log Out',
                isDestructive: true,
                onTap: () => _showLogoutDialog(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }

  /// Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _performLogout(context, ref);
            },
            child: Text('Log Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  /// Perform logout operation
  Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) =>
            const Center(child: CircularProgressIndicator()),
      );

      // Logout via auth service
      final authService = ref.read(authServiceProvider);
      await authService.logout();

      // Dismiss loading indicator
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Navigate to login screen
      if (context.mounted) {
        context.go(AppConstants.routeLogin);
      }
    } catch (e) {
      // Dismiss loading indicator
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
