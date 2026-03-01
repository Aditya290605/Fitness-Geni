import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/catalog_meal.dart';
import '../providers/meal_catalog_provider.dart';
import '../providers/meal_provider.dart';
import '../widgets/catalog_meal_card.dart';

/// Screen for selecting meals from catalog options.
/// Displays 4 sections (breakfast, lunch, snack, dinner) with scored options.
/// Options re-score reactively on user selection.
class CatalogMealSelectionScreen extends ConsumerStatefulWidget {
  const CatalogMealSelectionScreen({super.key});

  @override
  ConsumerState<CatalogMealSelectionScreen> createState() =>
      _CatalogMealSelectionScreenState();
}

class _CatalogMealSelectionScreenState
    extends ConsumerState<CatalogMealSelectionScreen> {
  bool _isSaving = false;

  static const _sectionMeta = {
    'breakfast': ('🌅', 'Breakfast'),
    'lunch': ('🌞', 'Lunch'),
    'snack': ('🍎', 'Snack'),
    'dinner': ('🌙', 'Dinner'),
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealCatalogProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Choose Your Meals'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: state.isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Finding perfect meals...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : state.error != null
          ? _buildError(state.error!)
          : _buildContent(state),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  ref.read(mealCatalogProvider.notifier).generateOptions(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(MealCatalogState state) {
    return Column(
      children: [
        // Remaining macro summary
        _buildRemainingSummary(state),

        // Section list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: 4,
            itemBuilder: (context, index) {
              final section = ['breakfast', 'lunch', 'snack', 'dinner'][index];
              return _buildSection(section, state);
            },
          ),
        ),

        // Continue button
        if (state.allSelected) _buildContinueButton(),
      ],
    );
  }

  Widget _buildRemainingSummary(MealCatalogState state) {
    final r = state.remaining;
    final d = state.daily;
    final selected = state.completedSelections;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$selected/4 selected',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${r.cal.round()} / ${d.cal.round()} kcal remaining',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: r.cal < 0 ? AppColors.error : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MacroProgress(
                label: 'Protein',
                remaining: r.prot,
                total: d.prot,
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 12),
              _MacroProgress(
                label: 'Carbs',
                remaining: r.carbs,
                total: d.carbs,
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 12),
              _MacroProgress(
                label: 'Fats',
                remaining: r.fats,
                total: d.fats,
                color: const Color(0xFFEF4444),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String section, MealCatalogState state) {
    final meta = _sectionMeta[section]!;
    final options = state.options[section] ?? [];
    final selected = state.selections[section];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Text(meta.$1, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                meta.$2,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (selected != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '✓ Selected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          if (options.isEmpty)
            _buildEmptySection()
          else
            _buildOptionsGrid(section, options, selected),
        ],
      ),
    );
  }

  Widget _buildEmptySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'No matching meals found',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildOptionsGrid(
    String section,
    List<ScoredMeal> options,
    CatalogMeal? selected,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.88,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final scored = options[index];
        final isSelected = selected?.id == scored.meal.id;

        return CatalogMealCard(
          meal: scored.meal,
          isSelected: isSelected,
          onTap: () {
            ref
                .read(mealCatalogProvider.notifier)
                .selectMeal(section, isSelected ? null : scored.meal);
          },
        );
      },
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveMeals,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Save Meals',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }

  Future<void> _saveMeals() async {
    setState(() => _isSaving = true);
    try {
      final notifier = ref.read(mealCatalogProvider.notifier);
      final meals = notifier.toMealList();

      // Save using existing MealProvider flow
      await ref.read(mealProvider.notifier).saveMealsAndReload(meals);

      // Save yesterday's meals for diversity
      await notifier.saveYesterdayMeals();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meals saved successfully! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

/// Progress indicator for a single macro.
class _MacroProgress extends StatelessWidget {
  final String label;
  final double remaining;
  final double total;
  final Color color;

  const _MacroProgress({
    required this.label,
    required this.remaining,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final consumed = total - remaining;
    final progress = total > 0 ? (consumed / total).clamp(0.0, 1.0) : 0.0;
    final isOver = remaining < 0;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                '${remaining.round()}g',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isOver ? AppColors.error : color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOver ? AppColors.error : color,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
