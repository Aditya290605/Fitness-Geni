import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'fitness_service.dart';

/// Implementation of FitnessService using the health package
/// Automatically handles iOS (HealthKit) and Android (Health Connect)
class HealthFitnessService implements FitnessService {
  final Health _health = Health();
  bool _isInitialized = false;

  /// Get platform-specific data types
  List<HealthDataType> get _dataTypes {
    if (Platform.isAndroid) {
      // Android Health Connect types
      return [
        HealthDataType.STEPS,
        HealthDataType.TOTAL_CALORIES_BURNED,
        HealthDataType.DISTANCE_DELTA,
      ];
    } else {
      // iOS HealthKit types
      return [
        HealthDataType.STEPS,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.DISTANCE_WALKING_RUNNING,
      ];
    }
  }

  /// Request permissions for reading health data
  List<HealthDataAccess> get _permissions =>
      _dataTypes.map((e) => HealthDataAccess.READ).toList();

  /// Initialize the health platform
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    try {
      await _health.configure();
      _isInitialized = true;
      debugPrint('🏃 HealthFitnessService: Initialized successfully');
    } catch (e) {
      debugPrint('🏃 HealthFitnessService: Failed to initialize - $e');
    }
  }

  @override
  String get platformName {
    if (Platform.isIOS) return 'Apple Health';
    if (Platform.isAndroid) return 'Health Connect';
    return 'Health';
  }

  @override
  Future<bool> isAvailable() async {
    await _ensureInitialized();
    try {
      // On Android, check if Health Connect is installed
      if (Platform.isAndroid) {
        final status = await _health.getHealthConnectSdkStatus();
        debugPrint('🏃 Health Connect SDK status: $status');

        if (status == HealthConnectSdkStatus.sdkUnavailable) {
          debugPrint('🏃 Health Connect not installed, prompting install...');
          await _health.installHealthConnect();
          return false;
        }
        return status == HealthConnectSdkStatus.sdkAvailable;
      }
      // On iOS, HealthKit is always available
      return Platform.isIOS;
    } catch (e) {
      debugPrint('🏃 HealthFitnessService: isAvailable error - $e');
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    await _ensureInitialized();
    try {
      final hasPerms = await _health.hasPermissions(
        _dataTypes,
        permissions: _permissions,
      );
      debugPrint('🏃 HealthFitnessService: hasPermissions = $hasPerms');
      return hasPerms ?? false;
    } catch (e) {
      debugPrint('🏃 HealthFitnessService: hasPermissions error - $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    await _ensureInitialized();
    try {
      debugPrint(
        '🏃 HealthFitnessService: Requesting permissions for types: $_dataTypes',
      );

      if (Platform.isAndroid) {
        // Step 1: Request ACTIVITY_RECOGNITION runtime permission first
        // This is required before Health Connect can grant health permissions
        debugPrint('🏃 Requesting ACTIVITY_RECOGNITION runtime permission...');
        final activityResult = await Permission.activityRecognition.request();
        debugPrint('🏃 ACTIVITY_RECOGNITION result: $activityResult');

        // Step 2: Check if Health Connect is available
        final status = await _health.getHealthConnectSdkStatus();
        if (status != HealthConnectSdkStatus.sdkAvailable) {
          debugPrint('🏃 Health Connect not available, installing...');
          await _health.installHealthConnect();
          return false;
        }
      }

      // Step 3: Request Health Connect / HealthKit authorization
      debugPrint('🏃 Requesting health authorization...');
      final authorized = await _health.requestAuthorization(
        _dataTypes,
        permissions: _permissions,
      );

      debugPrint('🏃 HealthFitnessService: Authorization result = $authorized');
      return authorized;
    } catch (e) {
      debugPrint('🏃 HealthFitnessService: requestPermissions error - $e');
      return false;
    }
  }

  @override
  Future<ActivityData> getTodayActivity() async {
    await _ensureInitialized();

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {
      // Fetch today's steps
      final steps = await _health.getTotalStepsInInterval(midnight, now);

      // Fetch today's health data points
      final healthData = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: _dataTypes,
      );

      // Aggregate calories burned and distance
      double caloriesBurned = 0;
      double distanceKm = 0;

      for (final point in healthData) {
        // Handle calories (different types for iOS/Android)
        if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED ||
            point.type == HealthDataType.TOTAL_CALORIES_BURNED) {
          final value = point.value;
          if (value is NumericHealthValue) {
            caloriesBurned += value.numericValue.toDouble();
          }
        }
        // Handle distance (different types for iOS/Android)
        if (point.type == HealthDataType.DISTANCE_WALKING_RUNNING ||
            point.type == HealthDataType.DISTANCE_DELTA) {
          final value = point.value;
          if (value is NumericHealthValue) {
            // Convert meters to kilometers
            distanceKm += value.numericValue.toDouble() / 1000;
          }
        }
      }

      // Get weekly steps for the chart
      final weeklySteps = await getStepsForLastNDays(7);

      debugPrint(
        '🏃 Today: ${steps ?? 0} steps, $caloriesBurned cal, ${distanceKm.toStringAsFixed(2)} km',
      );

      return ActivityData(
        stepsToday: steps ?? 0,
        caloriesBurnedToday: caloriesBurned,
        distanceKmToday: distanceKm,
        weeklySteps: weeklySteps,
        lastUpdated: now,
      );
    } catch (e) {
      debugPrint('🏃 HealthFitnessService: getTodayActivity error - $e');
      return ActivityData.empty();
    }
  }

  @override
  Future<List<int>> getStepsForLastNDays(int days) async {
    await _ensureInitialized();

    final now = DateTime.now();
    final List<int> stepsPerDay = [];

    try {
      for (int i = days - 1; i >= 0; i--) {
        final dayStart = DateTime(now.year, now.month, now.day - i);
        final dayEnd = i == 0
            ? now
            : DateTime(now.year, now.month, now.day - i + 1);

        final steps = await _health.getTotalStepsInInterval(dayStart, dayEnd);
        stepsPerDay.add(steps ?? 0);
      }

      debugPrint('🏃 Weekly steps: $stepsPerDay');
      return stepsPerDay;
    } catch (e) {
      debugPrint('🏃 HealthFitnessService: getStepsForLastNDays error - $e');
      return List.filled(days, 0);
    }
  }
}

/// Factory to get the appropriate FitnessService for the current platform
FitnessService createFitnessService() {
  if (Platform.isIOS || Platform.isAndroid) {
    return HealthFitnessService();
  }
  return StubFitnessService();
}
