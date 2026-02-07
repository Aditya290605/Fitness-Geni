import 'package:flutter/foundation.dart';
import '../supabase/supabase_client.dart';
import '../supabase/supabase_service.dart';
import '../utils/nutrition_calculator.dart';
import 'auth_state.dart';

/// Service for managing user profile updates
class ProfileService extends SupabaseService {
  /// Update user profile with onboarding data
  Future<void> updateProfile({
    required String userId,
    required int age,
    required int weightKg,
    required int heightCm,
    required String gender,
    required String dietType,
    required String goal,
  }) async {
    try {
      // Calculate BMI
      final bmi = weightKg / ((heightCm / 100) * (heightCm / 100));

      // Create profile object for nutrition calculations
      final profile = Profile(
        id: userId,
        name: '', // Not needed for calculations
        age: age,
        weightKg: weightKg,
        heightCm: heightCm,
        gender: gender,
        goal: goal,
        bmi: bmi,
      );

      // Calculate daily nutrition targets
      final dailyCalories = NutritionCalculator.calculateDailyCalories(profile);
      final dailyProtein = NutritionCalculator.calculateDailyProtein(profile);
      final dailyCarbs = NutritionCalculator.calculateDailyCarbs(profile);
      final dailyFats = NutritionCalculator.calculateDailyFat(profile);

      debugPrint('📝 Updating profile for user: $userId');
      debugPrint('Age: $age, Weight: $weightKg kg, Height: $heightCm cm');
      debugPrint('Gender: $gender, Diet: $dietType, Goal: $goal');
      debugPrint('Calculated BMI: ${bmi.toStringAsFixed(2)}');
      debugPrint(
        'Daily targets: ${dailyCalories}kcal, ${dailyProtein}g protein, ${dailyCarbs}g carbs, ${dailyFats}g fat',
      );

      await supabase
          .from('profiles')
          .update({
            'age': age,
            'weight_kg': weightKg,
            'height_cm': heightCm,
            'gender': gender,
            'diet_type': dietType,
            'goal': goal,
            'bmi': bmi,
            'daily_calories': dailyCalories,
            'daily_protein': dailyProtein,
            'daily_carbs': dailyCarbs,
            'daily_fats': dailyFats,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      debugPrint('✅ Profile updated successfully with nutrition targets');
    } catch (e) {
      debugPrint('❌ Failed to update profile: $e');
      throw Exception(parseError(e));
    }
  }
}
