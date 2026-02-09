import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/supabase/supabase_client.dart';

/// Perfect day definition:
/// - All meals for the day were logged and completed
/// - Protein goal was achieved (consumed >= target)

/// State for perfect days data
class PerfectDaysState {
  final bool isLoading;
  final Map<DateTime, bool> perfectDays;
  final String? error;

  const PerfectDaysState({
    this.isLoading = false,
    this.perfectDays = const {},
    this.error,
  });

  PerfectDaysState copyWith({
    bool? isLoading,
    Map<DateTime, bool>? perfectDays,
    String? error,
  }) {
    return PerfectDaysState(
      isLoading: isLoading ?? this.isLoading,
      perfectDays: perfectDays ?? this.perfectDays,
      error: error,
    );
  }
}

/// Notifier for loading perfect days from meal history
class PerfectDaysNotifier extends StateNotifier<PerfectDaysState> {
  final Ref _ref;

  PerfectDaysNotifier(this._ref) : super(const PerfectDaysState());

  /// Load perfect days for the current month
  Future<void> loadPerfectDays() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final currentUser = _ref.read(currentUserProvider);
      if (currentUser == null) {
        state = state.copyWith(isLoading: false, perfectDays: {});
        return;
      }

      final profile = _ref.read(currentProfileProvider);
      final proteinTarget = profile?.dailyProtein ?? 150;

      // Get the start of current month and 2 months back
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - 2, 1);
      final endDate = DateTime(now.year, now.month, now.day);

      // Fetch daily plans with completion status
      final response = await supabase
          .from('daily_plans')
          .select('''
            date,
            consumed_protein,
            daily_plan_meals!inner (
              is_completed
            )
          ''')
          .eq('user_id', currentUser.id)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0]);

      final Map<DateTime, bool> perfectDays = {};

      for (final plan in response as List) {
        final dateStr = plan['date'] as String;
        final date = DateTime.parse(dateStr);
        final normalizedDate = DateTime(date.year, date.month, date.day);

        // Check if protein goal was reached
        final consumedProtein =
            (plan['consumed_protein'] as num?)?.toDouble() ?? 0;
        final proteinGoalMet = consumedProtein >= proteinTarget;

        // Check if all meals were completed
        final meals = plan['daily_plan_meals'] as List? ?? [];
        final allMealsCompleted =
            meals.isNotEmpty &&
            meals.every((meal) => meal['is_completed'] == true);

        // Perfect day = protein goal met + all meals completed
        perfectDays[normalizedDate] = proteinGoalMet && allMealsCompleted;
      }

      state = state.copyWith(isLoading: false, perfectDays: perfectDays);

      debugPrint(
        '🗓️ PerfectDays: Loaded ${perfectDays.length} days, '
        '${perfectDays.values.where((v) => v).length} perfect',
      );
    } catch (e) {
      debugPrint('🗓️ PerfectDays: Error loading - $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh perfect days data
  Future<void> refresh() async {
    await loadPerfectDays();
  }
}

/// Provider for perfect days state
final perfectDaysProvider =
    StateNotifierProvider<PerfectDaysNotifier, PerfectDaysState>((ref) {
      return PerfectDaysNotifier(ref);
    });
