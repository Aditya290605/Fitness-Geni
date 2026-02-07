/// Meal model for daily meal tracking
class Meal {
  final String id;
  final String name;
  final String time; // e.g., "Morning", "Afternoon", "Night"
  final List<String> ingredients;
  final List<String> recipeSteps;
  final bool isDone;
  final String? userId; // For Supabase tracking
  final String? date; // For Supabase tracking

  // Nutrition information (from AI)
  final int? calories;
  final double? protein; // in grams
  final double? carbs; // in grams
  final double? fats; // in grams

  const Meal({
    required this.id,
    required this.name,
    required this.time,
    required this.ingredients,
    required this.recipeSteps,
    this.isDone = false,
    this.userId,
    this.date,
    this.calories,
    this.protein,
    this.carbs,
    this.fats,
  });

  Meal copyWith({
    String? id,
    String? name,
    String? time,
    List<String>? ingredients,
    List<String>? recipeSteps,
    bool? isDone,
    String? userId,
    String? date,
    int? calories,
    double? protein,
    double? carbs,
    double? fats,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      ingredients: ingredients ?? this.ingredients,
      recipeSteps: recipeSteps ?? this.recipeSteps,
      isDone: isDone ?? this.isDone,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson({String? userId, String? date}) {
    return {
      'id': id,
      'user_id': userId ?? this.userId,
      'name': name,
      'time': time,
      'ingredients': ingredients,
      'recipe_steps': recipeSteps,
      'is_done': isDone,
      'date': date ?? this.date,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fats != null) 'fats': fats,
    };
  }

  /// Create from JSON (Supabase response)
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      time: json['time'] as String,
      ingredients: (json['ingredients'] as List).cast<String>(),
      recipeSteps: (json['recipe_steps'] as List).cast<String>(),
      isDone: json['is_done'] as bool? ?? false,
      userId: json['user_id'] as String?,
      date: json['date'] as String?,
      calories: json['calories'] as int?,
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fats: (json['fats'] as num?)?.toDouble(),
    );
  }
}
