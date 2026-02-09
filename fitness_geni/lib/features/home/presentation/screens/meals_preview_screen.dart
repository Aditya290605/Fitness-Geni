import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/meal_creation_provider.dart';
import '../providers/meal_provider.dart';
import '../widgets/meal_card.dart';
import '../widgets/meal_detail_sheet.dart';

/// Preview screen showing generated meals with premium design
class MealsPreviewScreen extends ConsumerStatefulWidget {
  const MealsPreviewScreen({super.key});

  @override
  ConsumerState<MealsPreviewScreen> createState() => _MealsPreviewScreenState();
}

class _MealsPreviewScreenState extends ConsumerState<MealsPreviewScreen> {
  bool _isSaving = false;

  Future<void> _useMeals() async {
    final generatedMeals = ref.read(mealCreationProvider).generatedMeals;

    if (generatedMeals == null || generatedMeals.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      // Save meals to Supabase and reload with proper IDs
      final success = await ref
          .read(mealProvider.notifier)
          .saveMealsAndReload(generatedMeals);

      if (!success) {
        throw Exception('Failed to save meals');
      }

      // Reset creation state
      ref.read(mealCreationProvider.notifier).reset();

      if (mounted) {
        // Navigate back to home (pop twice - preview and create screens)
        Navigator.pop(context);
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Meals saved successfully!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving meals: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealCreationProvider);
    final meals = state.generatedMeals ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Preview Meals',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
                    // Title
                    const Text(
                      'Today\'s Generated Meals',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Review your personalized meal plan',
                      style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                    ),

                    const SizedBox(height: 24),

                    // Premium meal cards with detail popups
                    ...meals.map(
                      (meal) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: MealCard(
                          meal: meal,
                          onTap: () {
                            MealDetailSheet.show(
                              context,
                              meal: meal,
                              // In preview mode, don't show mark-as-done button
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons with improved design
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: _isSaving
                              ? Colors.grey.shade300
                              : Colors.black.withOpacity(0.2),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: _isSaving
                              ? Colors.grey.shade400
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Use meals button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _useMeals,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSaving
                            ? Colors.grey.shade400
                            : Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade400,
                        disabledForegroundColor: Colors.grey.shade600,
                      ),
                      child: _isSaving
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Saving...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Use These Meals',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
