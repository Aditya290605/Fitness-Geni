import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/meal_provider.dart';
import '../providers/fitness_provider.dart';
import '../providers/perfect_days_provider.dart';
import '../widgets/protein_progress_card.dart';
import '../widgets/activity_stats_card.dart';
import '../widgets/health_permission_banner.dart';
import '../widgets/weekly_activity_chart.dart';
import '../widgets/perfect_days_heatmap.dart';

/// Fitness screen - Activity tracking with nutrition integration
/// Premium white theme with polished section design
class FitScreen extends ConsumerStatefulWidget {
  const FitScreen({super.key});

  @override
  ConsumerState<FitScreen> createState() => _FitScreenState();
}

class _FitScreenState extends ConsumerState<FitScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(fitnessProvider.notifier).initialize();
      ref.read(perfectDaysProvider.notifier).loadPerfectDays();
      ref.read(mealProvider.notifier).loadMeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fitnessState = ref.watch(fitnessProvider);
    final mealState = ref.watch(mealProvider);
    final perfectDaysState = ref.watch(perfectDaysProvider);
    final profile = ref.watch(currentProfileProvider);

    final proteinTarget = (profile?.dailyProtein ?? 150).toDouble();
    final proteinConsumed = mealState.consumedProtein;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(fitnessProvider.notifier).refresh(),
              ref.read(perfectDaysProvider.notifier).refresh(),
              ref.read(mealProvider.notifier).loadMeals(force: true),
            ]);
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Header
                _buildHeader(),
                const SizedBox(height: 28),

                // Protein Progress - PRIMARY HERO
                ProteinProgressCard(
                  proteinConsumed: proteinConsumed,
                  proteinTarget: proteinTarget,
                ),
                const SizedBox(height: 18),

                // Activity Stats - SECONDARY
                ActivityStatsCard(
                  steps: fitnessState.stepsToday,
                  caloriesBurned: fitnessState.caloriesBurned,
                  distanceKm: fitnessState.distanceKm,
                  hasData: fitnessState.hasPermission,
                ),
                const SizedBox(height: 16),

                // Health Permission Banner (conditional)
                if (fitnessState.isAvailable && !fitnessState.hasPermission)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: HealthPermissionBanner(
                      platformName: fitnessState.platformName,
                      isLoading: fitnessState.isLoading,
                      onConnectPressed: () {
                        ref.read(fitnessProvider.notifier).requestPermissions();
                      },
                    ),
                  ),

                const SizedBox(height: 12),

                // Weekly Activity Section
                _buildSectionHeader(
                  'Weekly Activity',
                  icon: Icons.bar_chart_rounded,
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(height: 14),
                WeeklyActivityChart(
                  weeklySteps: fitnessState.weeklySteps,
                  hasData:
                      fitnessState.hasPermission &&
                      fitnessState.weeklySteps.any((s) => s > 0),
                ),
                const SizedBox(height: 32),

                // Perfect Days Section
                _buildSectionHeader(
                  'Perfect Days',
                  icon: Icons.star_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(height: 14),
                PerfectDaysHeatmap(
                  perfectDays: perfectDaysState.perfectDays,
                  isLoading: perfectDaysState.isLoading,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Fitness',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Track your progress and stay motivated',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title, {
    required IconData icon,
    Color? color,
  }) {
    final iconColor = color ?? AppColors.primary;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
