/// Model representing a meal from the pre-built meals_catalog table.
/// Used by the adaptive macro engine for smart meal selection.
class CatalogMeal {
  final String id;
  final String name;
  final String mealType; // breakfast | lunch | dinner | snack
  final String dietType; // veg | nonveg
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final int prepTime; // in minutes
  final List<String> ingredients;
  final List<String> steps;
  final List<String> tags;
  final String? imageUrl;

  const CatalogMeal({
    required this.id,
    required this.name,
    required this.mealType,
    required this.dietType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.prepTime,
    required this.ingredients,
    required this.steps,
    this.tags = const [],
    this.imageUrl,
  });

  /// Create from Supabase JSON response
  factory CatalogMeal.fromJson(Map<String, dynamic> json) {
    return CatalogMeal(
      id: json['id'] as String,
      name: json['name'] as String,
      mealType: json['meal_type'] as String,
      dietType: json['diet_type'] as String,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      prepTime: json['prep_time'] as int,
      ingredients: (json['ingredients'] as List).cast<String>(),
      steps: (json['steps'] as List).cast<String>(),
      tags: json['tags'] != null
          ? (json['tags'] as List).cast<String>()
          : const [],
      imageUrl: json['image_url'] as String?,
    );
  }
}

/// A catalog meal with a computed score from the adaptive macro engine.
class ScoredMeal {
  final CatalogMeal meal;
  double score;

  ScoredMeal({required this.meal, required this.score});
}

/// Represents macro budget values (calories, protein, carbs, fats).
/// Used for daily targets, section targets, and remaining tracking.
class MacroBudget {
  final double cal;
  final double prot;
  final double carbs;
  final double fats;

  const MacroBudget({
    required this.cal,
    required this.prot,
    required this.carbs,
    required this.fats,
  });

  static const zero = MacroBudget(cal: 0, prot: 0, carbs: 0, fats: 0);

  MacroBudget operator +(MacroBudget other) => MacroBudget(
    cal: cal + other.cal,
    prot: prot + other.prot,
    carbs: carbs + other.carbs,
    fats: fats + other.fats,
  );

  MacroBudget operator -(MacroBudget other) => MacroBudget(
    cal: cal - other.cal,
    prot: prot - other.prot,
    carbs: carbs - other.carbs,
    fats: fats - other.fats,
  );

  MacroBudget operator /(double divisor) => MacroBudget(
    cal: cal / divisor,
    prot: prot / divisor,
    carbs: carbs / divisor,
    fats: fats / divisor,
  );

  MacroBudget operator *(double factor) => MacroBudget(
    cal: cal * factor,
    prot: prot * factor,
    carbs: carbs * factor,
    fats: fats * factor,
  );

  /// Clamp all values to non-negative (INV-4)
  MacroBudget clampNonNegative() => MacroBudget(
    cal: cal < 0 ? 0 : cal,
    prot: prot < 0 ? 0 : prot,
    carbs: carbs < 0 ? 0 : carbs,
    fats: fats < 0 ? 0 : fats,
  );
}
