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
/// Calm, premium design following Fitness Geni UI guidelines
class FitScreen extends ConsumerStatefulWidget {
  const FitScreen({super.key});

  @override
  ConsumerState<FitScreen> createState() => _FitScreenState();
}

class _FitScreenState extends ConsumerState<FitScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize fitness provider on first load
    Future.microtask(() {
      ref.read(fitnessProvider.notifier).initialize();
      ref.read(perfectDaysProvider.notifier).loadPerfectDays();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fitnessState = ref.watch(fitnessProvider);
    final mealState = ref.watch(mealProvider);
    final perfectDaysState = ref.watch(perfectDaysProvider);
    final profile = ref.watch(currentProfileProvider);

    // Nutrition targets from profile
    final proteinTarget = (profile?.dailyProtein ?? 150).toDouble();
    final proteinConsumed = mealState.consumedProtein;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(fitnessProvider.notifier).refresh();
            await ref.read(perfectDaysProvider.notifier).refresh();
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 20),

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

                const SizedBox(height: 8),

                // Weekly Activity Section
                _buildSectionHeader(
                  'Weekly Activity',
                  icon: Icons.show_chart_rounded,
                ),
                const SizedBox(height: 12),
                WeeklyActivityChart(
                  weeklySteps: fitnessState.weeklySteps,
                  hasData:
                      fitnessState.hasPermission &&
                      fitnessState.weeklySteps.any((s) => s > 0),
                ),
                const SizedBox(height: 28),

                // Perfect Days Section
                _buildSectionHeader('Perfect Days', icon: Icons.star_rounded),
                const SizedBox(height: 12),
                PerfectDaysHeatmap(
                  perfectDays: perfectDaysState.perfectDays,
                  isLoading: perfectDaysState.isLoading,
                ),
                const SizedBox(height: 32),
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
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Track your progress and stay motivated',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
