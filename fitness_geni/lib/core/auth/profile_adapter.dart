import '../../../features/profile/domain/models/user_profile.dart';
import 'auth_state.dart';

/// Extension to convert Supabase Profile to UserProfile
extension ProfileToUserProfile on Profile {
  /// Convert Supabase Profile to UserProfile for display
  UserProfile toUserProfile() {
    return UserProfile(
      id: id,
      name: name,
      age: age ?? 0,
      heightCm: (heightCm ?? 0).toDouble(),
      weightKg: (weightKg ?? 0).toDouble(),
      gender: gender ?? 'Not Set',
      fitnessGoal: goal ?? 'Not Set',
      photoUrl: null, // Supabase profile doesn't have photo URL yet
    );
  }
}
