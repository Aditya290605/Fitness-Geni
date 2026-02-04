/// Meal model for daily meal tracking
class Meal {
  final String id;
  final String name;
  final String time; // e.g., "Morning", "Afternoon", "Night"
  final List<String> ingredients;
  final List<String> recipeSteps;
  final bool isDone;

  const Meal({
    required this.id,
    required this.name,
    required this.time,
    required this.ingredients,
    required this.recipeSteps,
    this.isDone = false,
  });

  Meal copyWith({
    String? id,
    String? name,
    String? time,
    List<String>? ingredients,
    List<String>? recipeSteps,
    bool? isDone,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      ingredients: ingredients ?? this.ingredients,
      recipeSteps: recipeSteps ?? this.recipeSteps,
      isDone: isDone ?? this.isDone,
    );
  }
}
