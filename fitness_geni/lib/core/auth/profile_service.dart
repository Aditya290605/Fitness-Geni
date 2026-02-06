import 'package:flutter/foundation.dart';
import '../supabase/supabase_client.dart';
import '../supabase/supabase_service.dart';

/// Service for managing user profile updates
class ProfileService extends SupabaseService {
  /// Update user profile with onboarding data
  Future<void> updateProfile({
    required String userId,
    required int weightKg,
    required int heightCm,
    required String gender,
    required String dietType,
    required String goal,
  }) async {
    try {
      // Calculate BMI
      final bmi = weightKg / ((heightCm / 100) * (heightCm / 100));

      debugPrint('📝 Updating profile for user: $userId');
      debugPrint('Weight: $weightKg kg, Height: $heightCm cm');
      debugPrint('Gender: $gender, Diet: $dietType, Goal: $goal');
      debugPrint('Calculated BMI: ${bmi.toStringAsFixed(2)}');

      await supabase
          .from('profiles')
          .update({
            'weight_kg': weightKg,
            'height_cm': heightCm,
            'gender': gender,
            'diet_type': dietType,
            'goal': goal,
            'bmi': bmi,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      debugPrint('✅ Profile updated successfully');
    } catch (e) {
      debugPrint('❌ Failed to update profile: $e');
      throw Exception(parseError(e));
    }
  }
}
