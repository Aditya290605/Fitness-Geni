import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/meal.dart';

/// State for managing today's meals
class MealState {
  final List<Meal> meals;
  final bool isLoading;

  const MealState({required this.meals, this.isLoading = false});

  int get completedCount => meals.where((m) => m.isDone).length;
  int get totalMeals => meals.length;
  double get progress => totalMeals > 0 ? completedCount / totalMeals : 0.0;

  MealState copyWith({List<Meal>? meals, bool? isLoading}) {
    return MealState(
      meals: meals ?? this.meals,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier for meal state management
class MealNotifier extends StateNotifier<MealState> {
  MealNotifier() : super(_initialState());

  static MealState _initialState() {
    return MealState(
      meals: [
        const Meal(
          id: 'morning',
          name: 'Oatmeal with Berries',
          time: 'Morning',
          ingredients: [
            '1 cup rolled oats',
            '1 cup almond milk',
            '1/2 cup mixed berries',
            '1 tbsp honey',
            'Pinch of cinnamon',
          ],
          recipeSteps: [
            'Bring almond milk to a boil in a small pot',
            'Add oats and reduce heat to medium',
            'Cook for 5 minutes, stirring occasionally',
            'Top with berries, honey, and cinnamon',
            'Serve warm and enjoy!',
          ],
        ),
        const Meal(
          id: 'afternoon',
          name: 'Grilled Chicken Salad',
          time: 'Afternoon',
          ingredients: [
            '150g grilled chicken breast',
            '2 cups mixed greens',
            '1/2 cup cherry tomatoes',
            '1/4 cucumber, sliced',
            '2 tbsp olive oil dressing',
          ],
          recipeSteps: [
            'Season chicken with salt, pepper, and herbs',
            'Grill chicken until cooked through (6-8 min per side)',
            'Slice chicken into strips',
            'Toss greens, tomatoes, and cucumber in a bowl',
            'Top with chicken and drizzle with dressing',
          ],
        ),
        const Meal(
          id: 'night',
          name: 'Quinoa & Roasted Vegetables',
          time: 'Night',
          ingredients: [
            '1 cup cooked quinoa',
            '1 cup mixed vegetables (bell peppers, zucchini, carrots)',
            '2 tbsp olive oil',
            '1 tsp herbs (rosemary, thyme)',
            'Salt and pepper to taste',
          ],
          recipeSteps: [
            'Preheat oven to 400°F (200°C)',
            'Chop vegetables into bite-sized pieces',
            'Toss vegetables with olive oil, herbs, salt, and pepper',
            'Roast for 25-30 minutes until tender',
            'Serve over cooked quinoa',
          ],
        ),
      ],
    );
  }

  /// Mark a meal as done
  void markMealDone(String mealId) {
    final updatedMeals = state.meals.map((meal) {
      if (meal.id == mealId) {
        return meal.copyWith(isDone: true);
      }
      return meal;
    }).toList();

    state = state.copyWith(meals: updatedMeals);
  }

  /// Reset all meals to pending
  void resetMeals() {
    final resetMeals = state.meals.map((meal) {
      return meal.copyWith(isDone: false);
    }).toList();

    state = state.copyWith(meals: resetMeals);
  }
}

/// Provider for meal state
final mealProvider = StateNotifierProvider<MealNotifier, MealState>((ref) {
  return MealNotifier();
});
