import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/services/meal_catalog_service.dart';
import '../../../../core/utils/adaptive_macro_engine.dart';
import '../../../../core/utils/nutrition_calculator.dart';
import '../../domain/models/catalog_meal.dart';
import '../../domain/models/meal.dart';

/// State for the catalog meal selection screen.
class MealCatalogState {
  final Map<String, List<CatalogMeal>> allCandidates;
  final Map<String, List<ScoredMeal>> options;
  final Map<String, CatalogMeal?> selections;
  final MacroBudget daily;
  final String goal;
  final Set<String> yesterdayMealIds;
  final Map<String, int> starvationLevels;
  final bool isLoading;
  final String? error;

  const MealCatalogState({
    this.allCandidates = const {},
    this.options = const {},
    this.selections = const {
      'breakfast': null,
      'lunch': null,
      'snack': null,
      'dinner': null,
    },
    this.daily = MacroBudget.zero,
    this.goal = 'maintain',
    this.yesterdayMealIds = const {},
    this.starvationLevels = const {},
    this.isLoading = false,
    this.error,
  });

  /// Computed remaining budget — never stored (INV-8).
  MacroBudget get remaining {
    final consumed = selections.values.whereType<CatalogMeal>().fold(
      MacroBudget.zero,
      (sum, m) {
        return sum +
            MacroBudget(
              cal: m.calories.toDouble(),
              prot: m.protein,
              carbs: m.carbs,
              fats: m.fats,
            );
      },
    );
    return daily - consumed;
  }

  int get completedSelections =>
      selections.values.where((v) => v != null).length;

  bool get allSelected => completedSelections == 4;

  /// Check if AI fallback was needed for any section.
  bool get hasAiFallback => starvationLevels.values.any((l) => l == 3);

  MealCatalogState copyWith({
    Map<String, List<CatalogMeal>>? allCandidates,
    Map<String, List<ScoredMeal>>? options,
    Map<String, CatalogMeal?>? selections,
    MacroBudget? daily,
    String? goal,
    Set<String>? yesterdayMealIds,
    Map<String, int>? starvationLevels,
    bool? isLoading,
    String? error,
  }) {
    return MealCatalogState(
      allCandidates: allCandidates ?? this.allCandidates,
      options: options ?? this.options,
      selections: selections ?? this.selections,
      daily: daily ?? this.daily,
      goal: goal ?? this.goal,
      yesterdayMealIds: yesterdayMealIds ?? this.yesterdayMealIds,
      starvationLevels: starvationLevels ?? this.starvationLevels,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for the catalog meal selection flow.
/// Handles generation, selection, and reactive re-scoring.
class MealCatalogNotifier extends StateNotifier<MealCatalogState> {
  final Ref _ref;
  final MealCatalogService _service = MealCatalogService();

  MealCatalogNotifier(this._ref) : super(const MealCatalogState());

  /// Generate initial meal options from the catalog.
  Future<bool> generateOptions() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // ① Get profile and daily targets
      final profile = _ref.read(currentProfileProvider);
      if (profile == null) {
        throw Exception('Profile not found. Please complete your profile.');
      }

      final targets = NutritionCalculator.calculateNutritionTargets(profile);
      final daily = MacroBudget(
        cal: (targets['calories'] ?? 0).toDouble(),
        prot: (targets['protein'] ?? 0).toDouble(),
        carbs: (targets['carbs'] ?? 0).toDouble(),
        fats: (targets['fat'] ?? 0).toDouble(),
      );

      if (daily.cal <= 0) {
        throw Exception('Please complete your profile to generate meals.');
      }

      final goal = profile.goal ?? 'maintain';
      // Map profile diet type to DB values
      // Profile stores: 'Vegetarian', 'Non-Vegetarian', 'Vegan'
      // DB meals_catalog stores: 'veg', 'nonveg'
      final rawDiet = (profile.dietType ?? '').toLowerCase();
      final List<String> dietTypes;
      if (rawDiet.contains('non')) {
        // Non-Vegetarian → can eat both veg and nonveg
        dietTypes = ['veg', 'nonveg'];
      } else {
        // Vegetarian / Vegan / default → veg only
        dietTypes = ['veg'];
      }
      debugPrint('🥗 Diet: "${profile.dietType}" → DB filter: $dietTypes');

      // Load yesterday's meals
      final yesterdayIds = await _loadYesterdayMeals();

      // ② Fetch candidates
      final candidates = await _service.fetchCandidates(
        dailyCalories: daily.cal.round(),
        dietTypes: dietTypes,
      );

      if (candidates == null) {
        // Catalog empty → signal AI fallback needed
        state = state.copyWith(isLoading: false);
        return false;
      }

      // ④⑤ Compute initial targets with conservation
      final sectionTargets = AdaptiveMacroEngine.computeInitialTargets(
        daily,
        goal,
      );

      // ⑥ Initial deficits (all 1.0, no selections yet)
      final deficits = AdaptiveMacroEngine.computeDeficits(daily, daily);
      final weights = AdaptiveMacroEngine.computeWeights(deficits, goal, 0);

      // Score all sections
      final options = <String, List<ScoredMeal>>{};
      final starvation = <String, int>{};

      for (var i = 0; i < AdaptiveMacroEngine.sections.length; i++) {
        final section = AdaptiveMacroEngine.sections[i];
        final sectionCandidates = candidates[section] ?? [];
        final target = sectionTargets[section] ?? MacroBudget.zero;

        final (scored, level) = AdaptiveMacroEngine.scoreSection(
          candidates: sectionCandidates,
          sectionTarget: target,
          weights: weights,
          goal: goal,
          userId: profile.id,
          sectionIndex: i,
          completedSelections: 0,
          yesterdayMealIds: yesterdayIds,
        );

        options[section] = scored;
        starvation[section] = level;
      }

      state = state.copyWith(
        allCandidates: candidates,
        options: options,
        selections: {
          'breakfast': null,
          'lunch': null,
          'snack': null,
          'dinner': null,
        },
        daily: daily,
        goal: goal,
        yesterdayMealIds: yesterdayIds,
        starvationLevels: starvation,
        isLoading: false,
      );

      debugPrint('✅ Generated meal options from catalog');
      return true;
    } catch (e) {
      debugPrint('❌ Error generating catalog options: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// User selects a meal in a section → re-score all unselected sections.
  void selectMeal(String mealType, CatalogMeal? meal) {
    // Update selection
    final newSelections = Map<String, CatalogMeal?>.from(state.selections);
    newSelections[mealType] = meal;

    // Compute remaining from actual selections (INV-8)
    final consumed = newSelections.values.whereType<CatalogMeal>().fold(
      MacroBudget.zero,
      (sum, m) {
        return sum +
            MacroBudget(
              cal: m.calories.toDouble(),
              prot: m.protein,
              carbs: m.carbs,
              fats: m.fats,
            );
      },
    );
    final remaining = state.daily - consumed;

    final completedSelections = newSelections.values
        .where((v) => v != null)
        .length;
    final remainingSections = 4 - completedSelections;

    if (remainingSections == 0) {
      // All selected, no re-scoring needed
      state = state.copyWith(selections: newSelections);
      return;
    }

    // ⑥ Recompute weights from ACTUAL remaining
    final deficits = AdaptiveMacroEngine.computeDeficits(
      remaining,
      state.daily,
    );
    final weights = AdaptiveMacroEngine.computeWeights(
      deficits,
      state.goal,
      completedSelections,
    );

    // Re-score unselected sections
    final newOptions = Map<String, List<ScoredMeal>>.from(state.options);
    final newStarvation = Map<String, int>.from(state.starvationLevels);
    final profile = _ref.read(currentProfileProvider);
    final userId = profile?.id ?? '';

    for (var i = 0; i < AdaptiveMacroEngine.sections.length; i++) {
      final section = AdaptiveMacroEngine.sections[i];
      if (newSelections[section] != null) continue; // Already selected

      final sectionTarget = AdaptiveMacroEngine.computeSectionTarget(
        remaining,
        remainingSections,
      );

      final (scored, level) = AdaptiveMacroEngine.scoreSection(
        candidates: state.allCandidates[section] ?? [],
        sectionTarget: sectionTarget,
        weights: weights,
        goal: state.goal,
        userId: userId,
        sectionIndex: i,
        completedSelections: completedSelections,
        yesterdayMealIds: state.yesterdayMealIds,
      );

      newOptions[section] = scored;
      newStarvation[section] = level;
    }

    state = state.copyWith(
      selections: newSelections,
      options: newOptions,
      starvationLevels: newStarvation,
    );
  }

  /// Convert selected catalog meals to Meal objects for the existing save flow.
  List<Meal> toMealList() {
    final mealTimeMap = {
      'breakfast': 'breakfast',
      'lunch': 'lunch',
      'snack': 'snack',
      'dinner': 'dinner',
    };

    return state.selections.entries.where((e) => e.value != null).map((e) {
      final section = e.key;
      final cm = e.value!;
      return Meal(
        id: '',
        name: cm.name,
        time: mealTimeMap[section] ?? section,
        ingredients: cm.ingredients,
        recipeSteps: cm.steps,
        calories: cm.calories,
        protein: cm.protein,
        carbs: cm.carbs,
        fats: cm.fats,
      );
    }).toList();
  }

  /// Save yesterday's meal IDs for diversity.
  Future<void> saveYesterdayMeals() async {
    final ids = state.selections.values
        .whereType<CatalogMeal>()
        .map((m) => m.id)
        .toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('yesterday_meals', ids);
  }

  Future<Set<String>> _loadYesterdayMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('yesterday_meals') ?? [];
    return ids.toSet();
  }

  void reset() {
    state = const MealCatalogState();
  }
}

/// Provider for meal catalog state.
final mealCatalogProvider =
    StateNotifierProvider<MealCatalogNotifier, MealCatalogState>((ref) {
      return MealCatalogNotifier(ref);
    });
