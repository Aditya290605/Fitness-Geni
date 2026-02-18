import 'package:flutter/foundation.dart';
import '../supabase/supabase_client.dart';
import '../supabase/supabase_service.dart';
import '../../features/stats/domain/models/daily_history_model.dart';
import '../../features/home/domain/models/meal.dart';

/// Service for fetching historical meal and nutrition data from Supabase
class StatsHistoryService extends SupabaseService {
  /// Fetch all daily history for a user from account creation to today
  ///
  /// Returns a list of [DailyHistory] entries for every day from
  /// [accountCreatedAt] to today, filling in zero-value entries for
  /// days with no data.
  Future<List<DailyHistory>> fetchAllHistory({
    required String userId,
    required DateTime accountCreatedAt,
  }) async {
    try {
      debugPrint('📊 Fetching meal history for user: $userId');

      final startDate = accountCreatedAt.toIso8601String().split('T')[0];
      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T')[0];

      // Fetch all daily plans with their meals (including full meal data)
      final response = await supabase
          .from('daily_plans')
          .select('''
            date,
            consumed_calories,
            consumed_protein,
            consumed_carbs,
            consumed_fats,
            daily_plan_meals (
              id,
              meal_time,
              is_completed,
              meals (
                id,
                name,
                meal_time,
                ingredients,
                recipe_steps,
                calories,
                protein,
                carbs,
                fats
              )
            )
          ''')
          .eq('user_id', userId)
          .gte('date', startDate)
          .lte('date', todayStr)
          .order('date', ascending: false);

      debugPrint('📊 Fetched ${response.length} daily plan records');

      // Build a map of date -> DailyHistory from DB data
      final Map<String, DailyHistory> historyMap = {};

      for (final plan in response as List) {
        final dateStr = plan['date'] as String;
        final date = DateTime.parse(dateStr);
        final normalizedDate = DateTime(date.year, date.month, date.day);

        final planMeals = plan['daily_plan_meals'] as List? ?? [];
        final totalMeals = planMeals.length;
        final completedMeals = planMeals
            .where((m) => m['is_completed'] == true)
            .length;

        // Extract meal names and build Meal objects
        final mealNames = <String>[];
        final meals = <Meal>[];

        for (final planMeal in planMeals) {
          final mealData = planMeal['meals'] as Map<String, dynamic>?;
          if (mealData != null) {
            final name = mealData['name'] as String? ?? '';
            if (name.isNotEmpty) mealNames.add(name);

            meals.add(
              Meal(
                id: planMeal['id'] as String? ?? '',
                name: name,
                time: planMeal['meal_time'] as String? ?? '',
                ingredients:
                    (mealData['ingredients'] as List?)?.cast<String>() ?? [],
                recipeSteps:
                    (mealData['recipe_steps'] as List?)?.cast<String>() ?? [],
                isDone: planMeal['is_completed'] as bool? ?? false,
                userId: userId,
                date: dateStr,
                calories: mealData['calories'] as int?,
                protein: (mealData['protein'] as num?)?.toDouble(),
                carbs: (mealData['carbs'] as num?)?.toDouble(),
                fats: (mealData['fats'] as num?)?.toDouble(),
              ),
            );
          }
        }

        // Sort meals by time order: morning -> afternoon -> night
        meals.sort((a, b) {
          int getOrder(String time) {
            final t = time.toLowerCase();
            if (t.contains('breakfast') || t.contains('morning')) return 1;
            if (t.contains('lunch') || t.contains('afternoon')) return 2;
            if (t.contains('dinner') || t.contains('night')) return 3;
            return 4;
          }

          return getOrder(a.time).compareTo(getOrder(b.time));
        });

        historyMap[dateStr] = DailyHistory(
          date: normalizedDate,
          consumedCalories: (plan['consumed_calories'] as int?) ?? 0,
          consumedProtein:
              (plan['consumed_protein'] as num?)?.toDouble() ?? 0.0,
          consumedCarbs: (plan['consumed_carbs'] as num?)?.toDouble() ?? 0.0,
          consumedFats: (plan['consumed_fats'] as num?)?.toDouble() ?? 0.0,
          totalMeals: totalMeals,
          completedMeals: completedMeals,
          mealNames: mealNames,
          meals: meals,
        );
      }

      // Fill in missing days from account creation to today
      final List<DailyHistory> fullHistory = [];
      final normalizedStart = DateTime(
        accountCreatedAt.year,
        accountCreatedAt.month,
        accountCreatedAt.day,
      );
      final normalizedToday = DateTime(today.year, today.month, today.day);

      for (
        var d = normalizedToday;
        !d.isBefore(normalizedStart);
        d = d.subtract(const Duration(days: 1))
      ) {
        final key = d.toIso8601String().split('T')[0];
        fullHistory.add(historyMap[key] ?? DailyHistory(date: d));
      }

      debugPrint(
        '📊 Built ${fullHistory.length} day history '
        '(${historyMap.length} active days)',
      );

      return fullHistory;
    } catch (e) {
      debugPrint('❌ Error fetching meal history: $e');
      throw Exception(parseError(e));
    }
  }

  @override
  String parseError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}
