import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/services/stats_history_service.dart';
import '../../domain/models/daily_history_model.dart';

/// State for the Stats screen
class StatsState {
  final bool isLoading;
  final List<DailyHistory> history;
  final String? error;

  const StatsState({
    this.isLoading = false,
    this.history = const [],
    this.error,
  });

  StatsState copyWith({
    bool? isLoading,
    List<DailyHistory>? history,
    String? error,
  }) {
    return StatsState(
      isLoading: isLoading ?? this.isLoading,
      history: history ?? this.history,
      error: error,
    );
  }

  // ── Derived summary stats ──

  /// Total days since account creation
  int get totalDays => history.length;

  /// Days where the user logged at least one meal
  int get activeDays => history.where((d) => d.hasActivity).length;

  /// Days with no meals logged
  int get skippedDays => totalDays - activeDays;

  /// Total meals completed across all days
  int get totalMealsCompleted =>
      history.fold(0, (sum, d) => sum + d.completedMeals);

  /// Average daily calories (only counting active days)
  double get avgDailyCalories {
    final active = history.where((d) => d.hasActivity).toList();
    if (active.isEmpty) return 0;
    return active.fold(0, (sum, d) => sum + d.consumedCalories) / active.length;
  }

  /// Average daily protein (only counting active days)
  double get avgDailyProtein {
    final active = history.where((d) => d.hasActivity).toList();
    if (active.isEmpty) return 0;
    return active.fold(0.0, (sum, d) => sum + d.consumedProtein) /
        active.length;
  }
}

/// Notifier that loads and manages stats history
class StatsNotifier extends StateNotifier<StatsState> {
  final Ref _ref;
  final StatsHistoryService _service = StatsHistoryService();

  StatsNotifier(this._ref) : super(const StatsState());

  /// Load full history from account creation to today
  Future<void> loadHistory() async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final currentUser = _ref.read(currentUserProvider);
      final profile = _ref.read(currentProfileProvider);

      if (currentUser == null) {
        state = state.copyWith(isLoading: false, history: []);
        return;
      }

      // Use profile createdAt or fallback to 30 days ago
      final accountCreatedAt =
          profile?.createdAt ??
          DateTime.now().subtract(const Duration(days: 30));

      final history = await _service.fetchAllHistory(
        userId: currentUser.id,
        accountCreatedAt: accountCreatedAt,
      );

      state = state.copyWith(isLoading: false, history: history);

      debugPrint(
        '📊 Stats loaded: ${history.length} days, '
        '${state.activeDays} active, ${state.skippedDays} skipped',
      );
    } catch (e) {
      debugPrint('❌ Stats error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh stats data
  Future<void> refresh() async {
    state = state.copyWith(isLoading: false); // Reset loading lock
    await loadHistory();
  }
}

/// Provider for stats state
final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier(ref);
});
