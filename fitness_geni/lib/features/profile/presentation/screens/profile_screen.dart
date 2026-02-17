import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/auth/profile_adapter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/meal_notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/bmi_gauge_painter.dart';

/// Premium Profile Screen — Next-level UI with BMI gauge, daily intake rings
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabaseProfile = ref.watch(currentProfileProvider);

    if (supabaseProfile == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final profile = supabaseProfile.toUserProfile();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 22),

              // 1. User Info Card
              _buildUserCard(profile),

              const SizedBox(height: 20),

              // 2. BMI Gauge Dial
              BmiGaugeWidget(
                bmi: profile.bmi,
                category: profile.bmiCategory,
                description: profile.bmiDescription,
              ),

              const SizedBox(height: 20),

              // 3. Daily Intake Section
              _buildDailyIntakeSection(profile),

              const SizedBox(height: 20),

              // 4. Goal Card
              _buildGoalCard(profile),

              const SizedBox(height: 24),

              // 5. Settings Section
              _buildSettingsSection(context, ref),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 1. USER CARD — Premium glassmorphism-inspired
  // ─────────────────────────────────────────────
  Widget _buildUserCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 184, 183, 183),
            const Color.fromARGB(255, 45, 45, 45).withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with glowing ring
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: Center(
                child: Text(
                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildInfoPill(
                      '${profile.age} yrs',
                      Icons.cake_rounded,
                      const Color(0xFFEC4899),
                    ),
                    _buildInfoPill(
                      '${profile.heightCm.round()} cm',
                      Icons.height_rounded,
                      const Color(0xFF3B82F6),
                    ),
                    _buildInfoPill(
                      '${profile.weightKg.round()} kg',
                      Icons.monitor_weight_outlined,
                      const Color(0xFF10B981),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 3. DAILY INTAKE
  // ─────────────────────────────────────────────
  Widget _buildDailyIntakeSection(dynamic profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Daily Targets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 20),

          // 4 circular rings in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNutrientRing(
                label: 'Calories',
                value: profile.dailyCalories.toString(),
                unit: 'kcal',
                color: const Color(0xFFEF4444),
                bgColor: const Color(0xFFFEE2E2),
                icon: Icons.local_fire_department_rounded,
              ),
              _buildNutrientRing(
                label: 'Protein',
                value: '${profile.dailyProteinG.round()}',
                unit: 'g',
                color: const Color(0xFF06B6D4),
                bgColor: const Color(0xFFCFFAFE),
                icon: Icons.fitness_center_rounded,
              ),
              _buildNutrientRing(
                label: 'Carbs',
                value: '${(profile.dailyCalories * 0.5 / 4).round()}',
                unit: 'g',
                color: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFEF3C7),
                icon: Icons.grain_rounded,
              ),
              _buildNutrientRing(
                label: 'Fats',
                value: '${(profile.dailyCalories * 0.25 / 9).round()}',
                unit: 'g',
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFEDE9FE),
                icon: Icons.water_drop_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRing({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Column(
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
          ),
        ),

        const SizedBox(height: 10),

        // Circular ring with icon
        CircularPercentIndicator(
          radius: 36,
          lineWidth: 5.5,
          percent: 1.0,
          animation: true,
          animationDuration: 1200,
          backgroundColor: bgColor,
          progressColor: color,
          circularStrokeCap: CircularStrokeCap.round,
          center: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
        ),

        const SizedBox(height: 10),

        // Value
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // 4. GOAL CARD
  // ─────────────────────────────────────────────
  Widget _buildGoalCard(dynamic profile) {
    IconData goalIcon;
    String goalDescription;

    switch (profile.fitnessGoal) {
      case 'Weight Loss':
        goalIcon = Icons.trending_down_rounded;
        goalDescription = 'Aim for a healthy caloric deficit.';
        break;
      case 'Weight Gain':
        goalIcon = Icons.trending_up_rounded;
        goalDescription = 'Aim to gain lean mass.';
        break;
      case 'Maintain':
        goalIcon = Icons.trending_flat_rounded;
        goalDescription = 'Keep your current weight steady.';
        break;
      default:
        goalIcon = Icons.flag_rounded;
        goalDescription = 'Stay consistent with your meals.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(goalIcon, color: Colors.white, size: 28),
          ),

          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Goal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.fitnessGoal,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  goalDescription,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Chevron
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.5),
            size: 24,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 5. SETTINGS
  // ─────────────────────────────────────────────
  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingsTile(
                Icons.person_outline_rounded,
                'Edit Profile',
                () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Coming Soon')));
                },
              ),
              _buildDivider(),
              _buildSettingsTile(Icons.flag_outlined, 'Change Goal', () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Coming Soon')));
              }),
              _buildDivider(),
              _buildSettingsTile(
                Icons.notifications_none_rounded,
                'Notifications',
                () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Coming Soon')));
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                Icons.logout_rounded,
                'Log Out',
                () => _showLogoutDialog(context, ref),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? const Color(0xFFEF4444) : AppColors.primary;
    final bgColor = isDestructive
        ? const Color(0xFFFEE2E2)
        : AppColors.primary.withOpacity(0.08);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? const Color(0xFFEF4444)
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary.withOpacity(0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
    );
  }

  // ─────────────────────────────────────────────
  // LOGOUT FLOW
  // ─────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
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
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      final authService = ref.read(authServiceProvider);

      await MealNotificationService.instance.cancelAllNotifications();
      await MealNotificationService.instance.clearState();
      await authService.logout();

      if (context.mounted) {
        Navigator.pop(context);
        context.go(AppConstants.routeLogin);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }
}
