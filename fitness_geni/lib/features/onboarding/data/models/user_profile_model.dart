import 'dart:convert';

/// User profile data model for onboarding
class UserProfile {
  final double weight; // in kg
  final double height; // in cm
  final int age; // in years
  final String gender; // Male, Female, Other
  final String dietType; // Vegetarian, Non-Vegetarian
  final String fitnessGoal; // Weight Loss, Bulking, Maintain

  const UserProfile({
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.dietType,
    required this.fitnessGoal,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'dietType': dietType,
      'fitnessGoal': fitnessGoal,
    };
  }

  /// Create from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      age: json['age'] as int,
      gender: json['gender'] as String,
      dietType: json['dietType'] as String,
      fitnessGoal: json['fitnessGoal'] as String,
    );
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory UserProfile.fromJsonString(String jsonString) {
    return UserProfile.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Create a copy with updated fields
  UserProfile copyWith({
    double? weight,
    double? height,
    int? age,
    String? gender,
    String? dietType,
    String? fitnessGoal,
  }) {
    return UserProfile(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      dietType: dietType ?? this.dietType,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
    );
  }

  /// Calculate BMI
  double get bmi => weight / ((height / 100) * (height / 100));
}
