import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile.dart';

/// Profile state
class ProfileState {
  final UserProfile? profile;
  final bool isLoading;

  const ProfileState({this.profile, this.isLoading = false});

  ProfileState copyWith({UserProfile? profile, bool? isLoading}) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Profile notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(_initialState());

  static ProfileState _initialState() {
    // Mock user data for MVP
    return ProfileState(
      profile: UserProfile(
        id: 'user_001',
        name: 'Alex Johnson',
        age: 28,
        heightCm: 170, // 5'7"
        weightKg: 70, // ~154 lbs
        gender: 'Male',
        fitnessGoal: 'Weight Loss',
      ),
    );
  }

  void updateProfile(UserProfile profile) {
    state = state.copyWith(profile: profile);
  }
}

/// Provider for profile state
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier();
});
