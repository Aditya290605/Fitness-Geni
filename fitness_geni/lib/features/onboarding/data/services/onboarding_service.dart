import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';
import '../../../../core/constants/app_constants.dart';

/// Service for managing user profile data
class OnboardingService {
  static const String _keyUserProfile = 'user_profile';
  static const String _keyOnboardingComplete =
      AppConstants.keyOnboardingCompleted;

  /// Save user profile to SharedPreferences
  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = profile.toJsonString();
      final result = await prefs.setString(_keyUserProfile, jsonString);

      // Mark onboarding as complete
      await prefs.setBool(_keyOnboardingComplete, true);

      return result;
    } catch (e) {
      return false;
    }
  }

  /// Load user profile from SharedPreferences
  Future<UserProfile?> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyUserProfile);

      if (jsonString == null) return null;

      return UserProfile.fromJsonString(jsonString);
    } catch (e) {
      return null;
    }
  }

  /// Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  /// Clear user profile data
  Future<bool> clearUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserProfile);
      await prefs.remove(_keyOnboardingComplete);
      return true;
    } catch (e) {
      return false;
    }
  }
}
