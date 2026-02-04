/// User profile model
class UserProfile {
  final String id;
  final String name;
  final int age;
  final double heightCm;
  final double weightKg;
  final String gender;
  final String fitnessGoal; // 'Weight Loss', 'Weight Gain', 'Maintain'
  final String? photoUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.gender,
    required this.fitnessGoal,
    this.photoUrl,
  });

  /// Calculate BMI (Body Mass Index)
  double get bmi {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Get BMI category
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// Get soft BMI description
  String get bmiDescription {
    switch (bmiCategory) {
      case 'Underweight':
        return 'Your BMI falls in the underweight range';
      case 'Normal':
        return 'Your BMI falls in the normal range';
      case 'Overweight':
        return 'Your BMI falls in the overweight range';
      case 'Obese':
        return 'Your BMI indicates obesity';
      default:
        return 'Your BMI is calculated';
    }
  }

  /// Calculate daily protein needs (g) - rough estimate
  double get dailyProteinG {
    // Basic formula: 1.6g per kg for active individuals
    return weightKg * 1.6;
  }

  /// Calculate daily calorie needs - rough estimate
  int get dailyCalories {
    // Simple BMR calculation (Mifflin-St Jeor)
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }

    // Light activity multiplier
    return (bmr * 1.375).round();
  }

  /// Get goal explanation
  String get goalExplanation {
    switch (fitnessGoal) {
      case 'Weight Loss':
        return 'Focusing on balanced meals and consistency can help you reach a healthy weight. Small, sustainable changes work best.';
      case 'Weight Gain':
        return 'Building muscle and gaining healthy weight takes time. Balanced nutrition and regular meals are key to your success.';
      case 'Maintain':
        return 'Maintaining your current weight means keeping up good habits. Balanced meals and consistency will keep you on track.';
      default:
        return 'Stay consistent with balanced meals to reach your fitness goals.';
    }
  }

  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    double? heightCm,
    double? weightKg,
    String? gender,
    String? fitnessGoal,
    String? photoUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      gender: gender ?? this.gender,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
