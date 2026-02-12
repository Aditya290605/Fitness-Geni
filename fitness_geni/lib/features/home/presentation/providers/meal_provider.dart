import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/services/meal_notification_service.dart';
import '../../../../core/services/meal_service.dart';
import '../../domain/models/meal.dart';

/// State for managing today's meals
class MealState {
  final List<Meal> meals;
  final bool isLoading;
  final String? error;

  const MealState({required this.meals, this.isLoading = false, this.error});

  int get completedCount => meals.where((m) => m.isDone).length;
  int get totalMeals => meals.length;
  double get progress => totalMeals > 0 ? completedCount / totalMeals : 0.0;

  // Calculate consumed nutrition from completed meals
  int get consumedCalories {
    return meals
        .where((m) => m.isDone)
        .fold(0, (sum, meal) => sum + (meal.calories ?? 0));
  }

  double get consumedProtein {
    return meals
        .where((m) => m.isDone)
        .fold(0.0, (sum, meal) => sum + (meal.protein ?? 0.0));
  }

  double get consumedCarbs {
    return meals
        .where((m) => m.isDone)
        .fold(0.0, (sum, meal) => sum + (meal.carbs ?? 0.0));
  }

  double get consumedFats {
    return meals
        .where((m) => m.isDone)
        .fold(0.0, (sum, meal) => sum + (meal.fats ?? 0.0));
  }

  MealState copyWith({List<Meal>? meals, bool? isLoading, String? error}) {
    return MealState(
      meals: meals ?? this.meals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for meal state management
class MealNotifier extends StateNotifier<MealState> {
  final MealService _mealService = MealService();
  final Ref _ref;
  bool _hasLoaded = false;

  // Don't load meals in constructor - this was causing auth logout on refresh
  MealNotifier(this._ref) : super(const MealState(meals: []));

  /// Load today's meals from Supabase
  /// Only loads once unless force is true
  Future<void> loadMeals({bool force = false}) async {
    if (_hasLoaded && !force) {
      return; // Already loaded
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get current user ID
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser == null) {
        state = const MealState(meals: [], isLoading: false);
        return;
      }

      // Fetch meals from Supabase
      final meals = await _mealService.fetchTodaysMeals(currentUser.id);

      state = state.copyWith(meals: meals, isLoading: false);
      _hasLoaded = true;

      // Re-evaluate notifications with updated meal state
      _evaluateNotifications();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Mark a meal as done
  Future<void> markMealDone(String mealId) async {
    try {
      // Optimistically update UI
      final updatedMeals = state.meals.map((meal) {
        if (meal.id == mealId) {
          return meal.copyWith(isDone: true);
        }
        return meal;
      }).toList();

      state = state.copyWith(meals: updatedMeals);

      // Persist to Supabase
      await _mealService.markMealDone(mealId, true);

      // Re-evaluate notifications — meal marked done may cancel a reminder
      _evaluateNotifications();
    } catch (e) {
      // Revert on error
      await loadMeals(force: true);
      rethrow;
    }
  }

  /// Reset all meals to pending
  void resetMeals() {
    final resetMeals = state.meals.map((meal) {
      return meal.copyWith(isDone: false);
    }).toList();

    state = state.copyWith(meals: resetMeals);
  }

  /// Set new meals (for meal generation)
  void setMeals(List<Meal> meals) {
    state = state.copyWith(meals: meals);
    _hasLoaded = true;
  }

  /// Save generated meals to Supabase and reload with proper IDs
  /// Returns true if successful, false otherwise
  Future<bool> saveMealsAndReload(List<Meal> generatedMeals) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get current user ID
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Save meals to Supabase
      await _mealService.saveMeals(currentUser.id, generatedMeals);

      // Reload meals from Supabase to get proper daily_plan_meal IDs
      await loadMeals(force: true);

      // Note: loadMeals(force: true) already calls _evaluateNotifications()
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Re-evaluate and schedule/cancel notifications based on current meal state.
  /// Fires asynchronously — does not block the caller.
  void _evaluateNotifications() {
    MealNotificationService.instance
        .evaluateAndSchedule(state.meals)
        .catchError((e) {
          debugPrint('⚠️ Notification evaluation failed: $e');
        });
  }
}

/// Provider for meal state
final mealProvider = StateNotifierProvider<MealNotifier, MealState>((ref) {
  return MealNotifier(ref);
});
