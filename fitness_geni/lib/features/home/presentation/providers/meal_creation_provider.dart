import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/services/gemini_service.dart';
import '../../domain/models/meal.dart';

/// Mode for meal generation
enum MealGenerationMode { ingredients, surprise }

/// State for meal creation
class MealCreationState {
  final MealGenerationMode? selectedMode;
  final List<String> ingredients;
  final List<Meal>? generatedMeals;
  final bool isGenerating;
  final String? error;

  const MealCreationState({
    this.selectedMode,
    this.ingredients = const [],
    this.generatedMeals,
    this.isGenerating = false,
    this.error,
  });

  bool get canGenerate {
    if (selectedMode == null) return false;
    if (selectedMode == MealGenerationMode.ingredients) {
      return ingredients.length >= 2; // Require at least 2 ingredients
    }
    return true; // Surprise mode always ready
  }

  MealCreationState copyWith({
    MealGenerationMode? selectedMode,
    List<String>? ingredients,
    List<Meal>? generatedMeals,
    bool? isGenerating,
    String? error,
  }) {
    return MealCreationState(
      selectedMode: selectedMode ?? this.selectedMode,
      ingredients: ingredients ?? this.ingredients,
      generatedMeals: generatedMeals ?? this.generatedMeals,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
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

  MealCreationState clearError() {
    return copyWith(error: null);
  }
}

/// Notifier for meal creation
class MealCreationNotifier extends StateNotifier<MealCreationState> {
  final Ref _ref;
  final GeminiService _geminiService = GeminiService();

  MealCreationNotifier(this._ref) : super(const MealCreationState());

  void selectMode(MealGenerationMode mode) {
    state = state.copyWith(selectedMode: mode, ingredients: [], error: null);
  }

  void addIngredient(String ingredient) {
    if (ingredient.isEmpty) return;
    final trimmed = ingredient.trim();
    if (trimmed.isEmpty || state.ingredients.contains(trimmed)) return;

    state = state.copyWith(
      ingredients: [...state.ingredients, trimmed],
      error: null,
    );
  }

  void removeIngredient(String ingredient) {
    state = state.copyWith(
      ingredients: state.ingredients.where((i) => i != ingredient).toList(),
    );
  }

  /// Generate meals using Gemini AI
  Future<void> generateMeals() async {
    try {
      state = state.copyWith(isGenerating: true, error: null);

      // Get user profile
      final currentProfile = _ref.read(currentProfileProvider);
      if (currentProfile == null) {
        throw Exception('User profile not found');
      }

      // Call Gemini AI
      final meals = await _geminiService.generateMeals(
        userProfile: currentProfile,
        ingredients: state.selectedMode == MealGenerationMode.ingredients
            ? state.ingredients
            : null,
      );

      // Store generated meals in state (not saved to Supabase yet)
      state = state.copyWith(generatedMeals: meals, isGenerating: false);
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Reset state
  void reset() {
    state = const MealCreationState();
  }
}

/// Provider for meal creation
final mealCreationProvider =
    StateNotifierProvider<MealCreationNotifier, MealCreationState>((ref) {
      return MealCreationNotifier(ref);
    });
