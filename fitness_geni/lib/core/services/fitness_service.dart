import 'package:flutter/foundation.dart';

/// Activity data from health platform (Apple Health or Google Fit)
class ActivityData {
  final int stepsToday;
  final double caloriesBurnedToday;
  final double distanceKmToday;
  final List<int> weeklySteps;
  final DateTime lastUpdated;

  const ActivityData({
    required this.stepsToday,
    required this.caloriesBurnedToday,
    required this.distanceKmToday,
    required this.weeklySteps,
    required this.lastUpdated,
  });

  /// Empty/default activity data
  factory ActivityData.empty() => ActivityData(
    stepsToday: 0,
    caloriesBurnedToday: 0,
    distanceKmToday: 0,
    weeklySteps: List.filled(7, 0),
    lastUpdated: DateTime.now(),
  );

  ActivityData copyWith({
    int? stepsToday,
    double? caloriesBurnedToday,
    double? distanceKmToday,
    List<int>? weeklySteps,
    DateTime? lastUpdated,
  }) {
    return ActivityData(
      stepsToday: stepsToday ?? this.stepsToday,
      caloriesBurnedToday: caloriesBurnedToday ?? this.caloriesBurnedToday,
      distanceKmToday: distanceKmToday ?? this.distanceKmToday,
      weeklySteps: weeklySteps ?? this.weeklySteps,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Abstract service interface for health data access
/// Platform-agnostic API for reading fitness data
abstract class FitnessService {
  /// Check if health permissions have been granted
  Future<bool> hasPermissions();

  /// Request health data permissions from the user
  /// Returns true if permissions were granted
  Future<bool> requestPermissions();

  /// Check if health platform is available on this device
  Future<bool> isAvailable();

  /// Get today's activity data
  Future<ActivityData> getTodayActivity();

  /// Get steps for the last N days (including today)
  Future<List<int>> getStepsForLastNDays(int days);

  /// Platform name for display purposes
  String get platformName;
}

/// Stub implementation when platform is not supported
class StubFitnessService implements FitnessService {
  @override
  Future<bool> hasPermissions() async => false;

  @override
  Future<bool> requestPermissions() async {
    debugPrint('🏃 FitnessService: Stub - no health platform available');
    return false;
  }

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<ActivityData> getTodayActivity() async => ActivityData.empty();

  @override
  Future<List<int>> getStepsForLastNDays(int days) async =>
      List.filled(days, 0);

  @override
  String get platformName => 'Unavailable';
}
