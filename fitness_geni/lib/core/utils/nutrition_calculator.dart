import 'dart:math';
import '../auth/auth_state.dart';

/// Utility class for calculating nutrition requirements
class NutritionCalculator {
  /// Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
  static double calculateBMR(Profile profile) {
    if (profile.weightKg == null ||
        profile.heightCm == null ||
        profile.age == null) {
      return 0;
    }

    final weight = profile.weightKg!;
    final height = profile.heightCm!;
    final age = profile.age!;

    // BMR = 10 * weight + 6.25 * height - 5 * age + s
    // s = +5 for males, -161 for females
    final genderOffset = profile.gender?.toLowerCase() == 'male' ? 5 : -161;

    return (10 * weight) + (6.25 * height) - (5 * age) + genderOffset;
  }

  /// Calculate TDEE (Total Daily Energy Expenditure)
  /// Assumes moderate activity level (1.55 multiplier)
  static double calculateTDEE(Profile profile, {double activityLevel = 1.55}) {
    final bmr = calculateBMR(profile);
    return bmr * activityLevel;
  }

  /// Calculate daily calorie target based on goal
  static int calculateDailyCalories(Profile profile) {
    final tdee = calculateTDEE(profile);

    switch (profile.goal?.toLowerCase()) {
      case 'weight_loss':
      case 'lose_weight':
        return (tdee - 500).round(); // 500 calorie deficit
      case 'muscle_gain':
      case 'gain_muscle':
        return (tdee + 300).round(); // 300 calorie surplus
      case 'maintenance':
      case 'maintain':
      default:
        return tdee.round();
    }
  }

  /// Calculate daily protein requirement in grams
  static int calculateDailyProtein(Profile profile) {
    if (profile.weightKg == null) return 0;

    final weight = profile.weightKg!;

    switch (profile.goal?.toLowerCase()) {
      case 'muscle_gain':
      case 'gain_muscle':
        return (weight * 2.0).round(); // 2g per kg for muscle gain
      case 'weight_loss':
      case 'lose_weight':
        return (weight * 1.8).round(); // 1.8g per kg to preserve muscle
      case 'maintenance':
      case 'maintain':
      default:
        return (weight * 1.6).round(); // 1.6g per kg for maintenance
    }
  }

  /// Calculate daily carb requirement in grams
  static int calculateDailyCarbs(Profile profile) {
    final calories = calculateDailyCalories(profile);
    final protein = calculateDailyProtein(profile);

    // Protein = 4 cal/g, Carbs = 4 cal/g, Fat = 9 cal/g
    // Assume 45% of remaining calories from carbs
    final proteinCalories = protein * 4;
    final remainingCalories = calories - proteinCalories;
    final carbCalories = remainingCalories * 0.45;

    return (carbCalories / 4).round();
  }

  /// Calculate daily fat requirement in grams
  static int calculateDailyFat(Profile profile) {
    final calories = calculateDailyCalories(profile);
    final protein = calculateDailyProtein(profile);
    final carbs = calculateDailyCarbs(profile);

    final proteinCalories = protein * 4;
    final carbCalories = carbs * 4;
    final fatCalories = calories - proteinCalories - carbCalories;

    return max(0, (fatCalories / 9).round());
  }

  /// Get comprehensive nutrition targets
  static Map<String, int> calculateNutritionTargets(Profile profile) {
    return {
      'calories': calculateDailyCalories(profile),
      'protein': calculateDailyProtein(profile),
      'carbs': calculateDailyCarbs(profile),
      'fat': calculateDailyFat(profile),
    };
  }
}
