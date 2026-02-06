import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';
part 'auth_state.g.dart';

/// Auth state representing the current authentication status
@freezed
class AuthState with _$AuthState {
  const factory AuthState.loading() = AuthStateLoading;

  const factory AuthState.authenticated({
    required User user,
    required Profile profile,
  }) = AuthStateAuthenticated;

  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
}

/// User model - minimal authentication data
@freezed
class User with _$User {
  const factory User({required String id, required String email}) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// Profile model - user profile data stored in profiles table
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String name,
    DateTime? createdAt,
    // Onboarding fields
    int? age,
    @JsonKey(name: 'height_cm') int? heightCm,
    @JsonKey(name: 'weight_kg') int? weightKg,
    String? gender,
    @JsonKey(name: 'diet_type') String? dietType,
    String? goal,
    double? bmi,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
