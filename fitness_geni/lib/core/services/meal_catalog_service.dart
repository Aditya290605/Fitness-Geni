import 'package:flutter/foundation.dart';
import '../supabase/supabase_client.dart';
import '../supabase/supabase_service.dart';
import '../../features/home/domain/models/catalog_meal.dart';

/// Service for fetching meals from the pre-built meals_catalog table.
/// Uses a single optimized query with progressive fallback for edge cases.
class MealCatalogService extends SupabaseService {
  /// Fetch all eligible catalog meals with progressive calorie range widening.
  ///
  /// Returns meals grouped by meal_type, or null if catalog is empty
  /// (triggers AI fallback upstream).
  Future<Map<String, List<CatalogMeal>>?> fetchCandidates({
    required int dailyCalories,
    required List<String> dietTypes,
  }) async {
    try {
      debugPrint('📥 Fetching meal catalog (daily: $dailyCalories kcal)');
      debugPrint('🔎 Diet types filter: $dietTypes');

      // ── DIAGNOSTIC: test raw access with NO filters ──
      try {
        final rawTest = await supabase
            .from('meals_catalog')
            .select('id, name, diet_type, calories')
            .limit(5);
        debugPrint('🧪 RAW TEST (no filters, limit 5): ${rawTest.length} rows');
        for (final row in rawTest) {
          debugPrint(
            '   → ${row['name']} | diet=${row['diet_type']} | cal=${row['calories']}',
          );
        }
      } catch (e) {
        debugPrint('🧪 RAW TEST FAILED: $e');
      }
      // ── END DIAGNOSTIC ──

      // Progressive fallback steps
      final steps = [
        (0.10, 0.45), // Step 1: standard
        (0.07, 0.55), // Step 2: widen 40%
        (0.05, 0.65), // Step 3: widen further
        (0.00, 1.00), // Step 4: unrestricted
      ];

      for (final (lo, hi) in steps) {
        final minCal = (dailyCalories * lo).round();
        final maxCal = (dailyCalories * hi).round();

        debugPrint('🔍 Trying range: $minCal–$maxCal kcal');

        final response = await supabase
            .from('meals_catalog')
            .select()
            .inFilter('diet_type', dietTypes)
            .gte('calories', minCal)
            .lte('calories', maxCal)
            .order('meal_type');

        final meals = (response as List)
            .map((json) => CatalogMeal.fromJson(json as Map<String, dynamic>))
            .toList();

        debugPrint('✅ Fetched ${meals.length} meals');

        // Group by meal_type
        final grouped = _groupByMealType(meals);

        // Minimum viability: at least 2 candidates per section
        final allViable = grouped.values.every((list) => list.length >= 2);

        if (allViable) {
          for (final entry in grouped.entries) {
            debugPrint('  📋 ${entry.key}: ${entry.value.length} candidates');
          }
          return grouped;
        }

        debugPrint('⚠️ Not enough candidates, widening range...');
      }

      // All steps exhausted
      debugPrint('❌ Catalog insufficient for all sections');
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching meal catalog: $e');
      throw Exception(parseError(e));
    }
  }

  /// Group meals by meal_type. Ensures all 4 types have entries (possibly empty).
  Map<String, List<CatalogMeal>> _groupByMealType(List<CatalogMeal> meals) {
    final grouped = <String, List<CatalogMeal>>{
      'breakfast': [],
      'lunch': [],
      'snack': [],
      'dinner': [],
    };

    for (final meal in meals) {
      grouped[meal.mealType]?.add(meal);
    }

    return grouped;
  }
}
