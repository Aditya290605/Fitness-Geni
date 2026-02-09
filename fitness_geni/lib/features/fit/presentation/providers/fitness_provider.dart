import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/fitness_service.dart';
import '../../../../core/services/health_fitness_service.dart';

/// State for fitness/activity data
class FitnessState {
  final bool isLoading;
  final bool hasPermission;
  final bool isAvailable;
  final ActivityData activityData;
  final String? error;
  final String platformName;

  const FitnessState({
    this.isLoading = false,
    this.hasPermission = false,
    this.isAvailable = false,
    required this.activityData,
    this.error,
    this.platformName = 'Health',
  });

  factory FitnessState.initial() =>
      FitnessState(activityData: ActivityData.empty());

  FitnessState copyWith({
    bool? isLoading,
    bool? hasPermission,
    bool? isAvailable,
    ActivityData? activityData,
    String? error,
    String? platformName,
  }) {
    return FitnessState(
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      isAvailable: isAvailable ?? this.isAvailable,
      activityData: activityData ?? this.activityData,
      error: error,
      platformName: platformName ?? this.platformName,
    );
  }

  /// Convenience getters for quick access
  int get stepsToday => activityData.stepsToday;
  double get caloriesBurned => activityData.caloriesBurnedToday;
  double get distanceKm => activityData.distanceKmToday;
  List<int> get weeklySteps => activityData.weeklySteps;
}

/// Notifier for fitness state management
class FitnessNotifier extends StateNotifier<FitnessState> {
  final FitnessService _service;
  bool _hasCheckedPermissions = false;

  FitnessNotifier(this._service) : super(FitnessState.initial()) {
    // Set platform name immediately
    state = state.copyWith(platformName: _service.platformName);
  }

  /// Initialize and check availability + permissions
  Future<void> initialize() async {
    if (_hasCheckedPermissions) return;

    try {
      state = state.copyWith(isLoading: true);

      // Check if health platform is available
      final isAvailable = await _service.isAvailable();
      if (!isAvailable) {
        state = state.copyWith(
          isLoading: false,
          isAvailable: false,
          hasPermission: false,
        );
        debugPrint('🏃 FitnessNotifier: Platform not available');
        return;
      }

      // Check existing permissions
      final hasPerms = await _service.hasPermissions();
      state = state.copyWith(isAvailable: true, hasPermission: hasPerms);

      _hasCheckedPermissions = true;

      // If we have permissions, load data
      if (hasPerms) {
        await loadActivityData();
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('🏃 FitnessNotifier: Initialize error - $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Request health permissions from user
  Future<bool> requestPermissions() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final granted = await _service.requestPermissions();
      state = state.copyWith(hasPermission: granted, isLoading: false);

      // If granted, load data
      if (granted) {
        await loadActivityData();
      }

      return granted;
    } catch (e) {
      debugPrint('🏃 FitnessNotifier: Permission error - $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Load today's activity data
  Future<void> loadActivityData({bool force = false}) async {
    if (state.isLoading && !force) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final data = await _service.getTodayActivity();
      state = state.copyWith(activityData: data, isLoading: false);

      debugPrint('🏃 FitnessNotifier: Loaded activity data');
    } catch (e) {
      debugPrint('🏃 FitnessNotifier: Load error - $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh data (for pull-to-refresh)
  Future<void> refresh() async {
    await loadActivityData(force: true);
  }
}

/// Provider for FitnessService
final fitnessServiceProvider = Provider<FitnessService>((ref) {
  return createFitnessService();
});

/// Provider for fitness state
final fitnessProvider = StateNotifierProvider<FitnessNotifier, FitnessState>((
  ref,
) {
  final service = ref.watch(fitnessServiceProvider);
  return FitnessNotifier(service);
});
