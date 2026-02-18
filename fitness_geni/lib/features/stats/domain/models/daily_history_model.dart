import '../../../home/domain/models/meal.dart';

/// Model representing one day's nutrition and meal summary
class DailyHistory {
  final DateTime date;
  final int consumedCalories;
  final double consumedProtein;
  final double consumedCarbs;
  final double consumedFats;
  final int totalMeals;
  final int completedMeals;
  final List<String> mealNames;
  final List<Meal> meals; // Full meal objects for display

  const DailyHistory({
    required this.date,
    this.consumedCalories = 0,
    this.consumedProtein = 0.0,
    this.consumedCarbs = 0.0,
    this.consumedFats = 0.0,
    this.totalMeals = 0,
    this.completedMeals = 0,
    this.mealNames = const [],
    this.meals = const [],
  });

  /// Whether the user logged any meals this day
  bool get hasActivity => totalMeals > 0;

  /// Whether the user skipped (no plan at all)
  bool get isSkipped => !hasActivity;

  /// Percentage of meals completed
  double get completionRate =>
      totalMeals > 0 ? completedMeals / totalMeals : 0.0;
}
