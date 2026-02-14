import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/meal_creation_provider.dart';
import '../widgets/ingredient_chip.dart';
import '../widgets/mode_selection_card.dart';
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
                      title: 'Surprise me with balanced meals',
                      description: 'Get a smart, balanced meal plan',
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
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'We\'ll generate a balanced set of meals based on your goal.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
