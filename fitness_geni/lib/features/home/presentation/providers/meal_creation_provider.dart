import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/meal.dart';

/// Mode for meal generation
enum MealGenerationMode { ingredients, surprise }

/// State for meal creation
class MealCreationState {
  final MealGenerationMode? selectedMode;
  final List<String> ingredients;
  final List<Meal>? generatedMeals;
  final bool isGenerating;

  const MealCreationState({
    this.selectedMode,
    this.ingredients = const [],
    this.generatedMeals,
    this.isGenerating = false,
  });

  bool get canGenerate {
    if (selectedMode == null) return false;
    if (selectedMode == MealGenerationMode.ingredients) {
      return ingredients.isNotEmpty;
    }
    return true; // Surprise mode always ready
  }

  MealCreationState copyWith({
    MealGenerationMode? selectedMode,
    List<String>? ingredients,
    List<Meal>? generatedMeals,
    bool? isGenerating,
  }) {
    return MealCreationState(
      selectedMode: selectedMode ?? this.selectedMode,
      ingredients: ingredients ?? this.ingredients,
      generatedMeals: generatedMeals ?? this.generatedMeals,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }

  MealCreationState clearMode() {
    return MealCreationState(
      selectedMode: null,
      ingredients: const [],
      generatedMeals: generatedMeals,
      isGenerating: isGenerating,
    );
  }
}

/// Notifier for meal creation
class MealCreationNotifier extends StateNotifier<MealCreationState> {
  MealCreationNotifier() : super(const MealCreationState());

  void selectMode(MealGenerationMode mode) {
    state = state.copyWith(selectedMode: mode, ingredients: []);
  }

  void addIngredient(String ingredient) {
    if (ingredient.isEmpty) return;
    final trimmed = ingredient.trim();
    if (trimmed.isEmpty || state.ingredients.contains(trimmed)) return;

    state = state.copyWith(ingredients: [...state.ingredients, trimmed]);
  }

  void removeIngredient(String ingredient) {
    state = state.copyWith(
      ingredients: state.ingredients.where((i) => i != ingredient).toList(),
    );
  }

  Future<void> generateMeals() async {
    state = state.copyWith(isGenerating: true);

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock meal generation based on mode
    final meals = _mockGenerateMeals();

    state = state.copyWith(generatedMeals: meals, isGenerating: false);
  }

  List<Meal> _mockGenerateMeals() {
    if (state.selectedMode == MealGenerationMode.ingredients) {
      return _generateFromIngredients();
    } else {
      return _generateSurpriseMeals();
    }
  }

  List<Meal> _generateFromIngredients() {
    // Mock generation using ingredients
    final ingredientsText = state.ingredients.take(2).join(' & ');

    return [
      Meal(
        id: 'morning_${DateTime.now().millisecondsSinceEpoch}',
        name: '$ingredientsText Breakfast Bowl',
        time: 'Morning',
        ingredients: [
          ...state.ingredients.take(3),
          '1 cup milk',
          '1 tbsp honey',
        ],
        recipeSteps: [
          'Prepare your ${state.ingredients.first}',
          'Combine all ingredients in a bowl',
          'Mix well and enjoy fresh',
        ],
      ),
      Meal(
        id: 'afternoon_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Fresh $ingredientsText Salad',
        time: 'Afternoon',
        ingredients: [
          ...state.ingredients.take(4),
          '2 cups mixed greens',
          '2 tbsp olive oil dressing',
        ],
        recipeSteps: [
          'Wash and chop your ingredients',
          'Toss everything in a large bowl',
          'Drizzle with dressing and serve',
        ],
      ),
      Meal(
        id: 'night_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Cooked ${state.ingredients.first} Delight',
        time: 'Night',
        ingredients: [
          ...state.ingredients.take(3),
          '1 cup rice or quinoa',
          'Herbs and spices to taste',
        ],
        recipeSteps: [
          'Cook your base (rice or quinoa)',
          'Sauté your main ingredients',
          'Combine and season to perfection',
        ],
      ),
    ];
  }

  List<Meal> _generateSurpriseMeals() {
    // Mock balanced surprise meals
    return [
      const Meal(
        id: 'surprise_morning',
        name: 'Avocado Toast with Eggs',
        time: 'Morning',
        ingredients: [
          '2 slices whole grain bread',
          '1 ripe avocado',
          '2 eggs',
          'Cherry tomatoes',
          'Salt, pepper, chili flakes',
        ],
        recipeSteps: [
          'Toast the bread until golden',
          'Mash avocado with salt and pepper',
          'Fry or poach eggs to your liking',
          'Spread avocado, top with eggs and tomatoes',
          'Sprinkle with chili flakes and enjoy',
        ],
      ),
      const Meal(
        id: 'surprise_afternoon',
        name: 'Mediterranean Chickpea Bowl',
        time: 'Afternoon',
        ingredients: [
          '1 cup cooked chickpeas',
          '1 cup cucumber, diced',
          '1/2 cup cherry tomatoes',
          '1/4 cup feta cheese',
          '2 tbsp olive oil & lemon dressing',
        ],
        recipeSteps: [
          'Combine chickpeas, cucumber, and tomatoes',
          'Crumble feta cheese on top',
          'Drizzle with olive oil and lemon',
          'Toss gently and serve chilled',
        ],
      ),
      const Meal(
        id: 'surprise_night',
        name: 'Teriyaki Salmon with Broccoli',
        time: 'Night',
        ingredients: [
          '150g salmon fillet',
          '2 cups broccoli florets',
          '3 tbsp teriyaki sauce',
          '1 tsp sesame oil',
          'Sesame seeds for garnish',
        ],
        recipeSteps: [
          'Marinate salmon in teriyaki sauce for 10 min',
          'Steam broccoli until tender-crisp',
          'Pan-sear salmon 3-4 min each side',
          'Drizzle broccoli with sesame oil',
          'Plate together and garnish with sesame seeds',
        ],
      ),
    ];
  }

  void reset() {
    state = const MealCreationState();
  }
}

/// Provider for meal creation
final mealCreationProvider =
    StateNotifierProvider<MealCreationNotifier, MealCreationState>((ref) {
      return MealCreationNotifier();
    });
