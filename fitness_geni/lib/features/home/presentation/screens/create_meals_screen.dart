import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/meal_catalog_provider.dart';
import '../providers/meal_creation_provider.dart';
import '../widgets/ingredient_chip.dart';
import '../widgets/mode_selection_card.dart';
import 'catalog_meal_selection_screen.dart';
import 'meal_loading_screen.dart';
import 'meals_preview_screen.dart';

/// Create meals screen - Mode selection and input
class CreateMealsScreen extends ConsumerStatefulWidget {
  const CreateMealsScreen({super.key});

  @override
  ConsumerState<CreateMealsScreen> createState() => _CreateMealsScreenState();
}

class _CreateMealsScreenState extends ConsumerState<CreateMealsScreen> {
  final _ingredientController = TextEditingController();

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text;
    if (ingredient.isNotEmpty) {
      ref.read(mealCreationProvider.notifier).addIngredient(ingredient);
      _ingredientController.clear();
    }
  }

  Future<void> _generateMeals() async {
    final state = ref.read(mealCreationProvider);

    // Validation for ingredients mode
    if (state.selectedMode == MealGenerationMode.ingredients &&
        state.ingredients.length < 2) {
      _showWarning('Please add at least 2 ingredients to generate meals');
      return;
    }

    // ─── CATALOG-FIRST FLOW (Surprise mode) ───
    if (state.selectedMode == MealGenerationMode.surprise) {
      await _generateFromCatalog();
      return;
    }

    // ─── AI FLOW (Ingredients mode) ───
    await _generateFromAI();
  }

  /// Generate meals from the pre-built catalog using the adaptive macro engine.
  /// Instant (~200ms), no AI call, deterministic.
  Future<void> _generateFromCatalog() async {
    // Navigate to catalog selection screen
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CatalogMealSelectionScreen(),
        ),
      );
    }

    // Trigger generation in the background
    final success = await ref
        .read(mealCatalogProvider.notifier)
        .generateOptions();

    if (!success && mounted) {
      // Catalog failed → fallback to AI
      Navigator.pop(context); // pop catalog screen
      _showWarning('Catalog unavailable, falling back to AI generation...');
      await _generateFromAI();
    }
  }

  /// Generate meals using Gemini AI (original flow).
  Future<void> _generateFromAI() async {
    // Navigate to loading screen immediately
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MealLoadingScreen()),
      );
    }

    try {
      // Generate meals with AI
      await ref.read(mealCreationProvider.notifier).generateMeals();

      if (mounted) {
        // Replace loading screen with preview screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MealsPreviewScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        // Pop loading screen and show error
        Navigator.pop(context);
        _showError('Failed to generate meals. Please try again.');
      }
    }
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealCreationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Create Meals'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question
                    Text(
                      'How do you want to generate your meals?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Mode selection cards
                    ModeSelectionCard(
                      icon: Icons.kitchen,
                      title: 'Based on ingredients I have',
                      description: 'Create meals from what you have at home',
                      isSelected:
                          state.selectedMode == MealGenerationMode.ingredients,
                      onTap: () {
                        ref
                            .read(mealCreationProvider.notifier)
                            .selectMode(MealGenerationMode.ingredients);
                      },
                    ),

                    const SizedBox(height: 12),

                    ModeSelectionCard(
                      icon: Icons.auto_awesome,
                      title: 'Smart Meal Engine',
                      description:
                          'Instant macro-optimized meals from our catalog',
                      isSelected:
                          state.selectedMode == MealGenerationMode.surprise,
                      onTap: () {
                        ref
                            .read(mealCreationProvider.notifier)
                            .selectMode(MealGenerationMode.surprise);
                      },
                    ),

                    const SizedBox(height: 32),

                    // Conditional content
                    if (state.selectedMode == MealGenerationMode.ingredients)
                      _buildIngredientsInput(state)
                    else if (state.selectedMode == MealGenerationMode.surprise)
                      _buildSurpriseHelper(),
                  ],
                ),
              ),
            ),

            // Generate button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Show ingredient count hint
                  if (state.selectedMode == MealGenerationMode.ingredients)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${state.ingredients.length}/2 ingredients added (minimum)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: state.ingredients.length >= 2
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: state.ingredients.length >= 2
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  CustomButton(
                    text: state.isGenerating
                        ? 'Generating with AI...'
                        : 'Generate Meals',
                    onPressed: state.canGenerate && !state.isGenerating
                        ? _generateMeals
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsInput(MealCreationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Ingredients',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // Input field
        TextField(
          controller: _ingredientController,
          decoration: InputDecoration(
            hintText: 'Add ingredients you have at home',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle),
              color: AppColors.primary,
              onPressed: _addIngredient,
            ),
          ),
          onSubmitted: (_) => _addIngredient(),
        ),

        if (state.ingredients.isNotEmpty) ...[
          const SizedBox(height: 16),

          // Ingredient chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.ingredients
                .map(
                  (ingredient) => IngredientChip(
                    ingredient: ingredient,
                    onRemove: () {
                      ref
                          .read(mealCreationProvider.notifier)
                          .removeIngredient(ingredient);
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSurpriseHelper() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.bolt, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Our smart engine will find macro-optimized meals from 79+ recipes instantly.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFeatureTag(Icons.restaurant_menu, '4 Sections'),
              const SizedBox(width: 8),
              _buildFeatureTag(Icons.tune, '4 Options Each'),
              const SizedBox(width: 8),
              _buildFeatureTag(Icons.speed, 'Instant'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
