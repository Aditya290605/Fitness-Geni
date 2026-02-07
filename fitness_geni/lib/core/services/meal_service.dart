import 'package:flutter/foundation.dart';
import '../supabase/supabase_client.dart';
import '../supabase/supabase_service.dart';
import '../../features/home/domain/models/meal.dart';

/// Service for managing user meals with normalized schema
/// Uses: meals (catalog), daily_plans, daily_plan_meals (junction)
class MealService extends SupabaseService {
  /// Fetch today's meals for a specific user
  Future<List<Meal>> fetchTodaysMeals(String userId) async {
    try {
      debugPrint('📥 Fetching today\'s meals for user: $userId');

      final today = DateTime.now().toIso8601String().split('T')[0];

      // Get or create today's daily plan
      final dailyPlan = await _getOrCreateDailyPlan(userId, today);

      // Fetch meals for today's plan with JOIN
      final response = await supabase
          .from('daily_plan_meals')
          .select('''
            id,
            meal_time,
            is_completed,
            meal_id,
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
          ''')
          .eq('daily_plan_id', dailyPlan['id'])
          .order('meal_time');

      debugPrint('✅ Fetched ${response.length} meals from Supabase');

      return (response as List).map((json) {
        final mealData = json['meals'] as Map<String, dynamic>;
        final dailyPlanMealId = json['id'] as String?;

        debugPrint(
          '🔍 Daily plan meal ID: "$dailyPlanMealId" for meal: ${mealData['name']}',
        );

        if (dailyPlanMealId == null || dailyPlanMealId.isEmpty) {
          debugPrint('⚠️ WARNING: Empty or null ID detected!');
          debugPrint('Full JSON: $json');
        }

        return Meal(
          id: dailyPlanMealId ?? '', // daily_plan_meals ID
          name: mealData['name'] as String,
          time: json['meal_time'] as String,
          ingredients: (mealData['ingredients'] as List).cast<String>(),
          recipeSteps: (mealData['recipe_steps'] as List).cast<String>(),
          isDone: json['is_completed'] as bool? ?? false,
          userId: userId,
          date: today,
          calories: mealData['calories'] as int?,
          protein: (mealData['protein'] as num?)?.toDouble(),
          carbs: (mealData['carbs'] as num?)?.toDouble(),
          fats: (mealData['fats'] as num?)?.toDouble(),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error fetching meals: $e');
      throw Exception(parseError(e));
    }
  }

  /// Get or create a daily plan for a specific date
  Future<Map<String, dynamic>> _getOrCreateDailyPlan(
    String userId,
    String date,
  ) async {
    try {
      // Try to get existing plan
      final existing = await supabase
          .from('daily_plans')
          .select()
          .eq('user_id', userId)
          .eq('date', date)
          .maybeSingle();

      if (existing != null) {
        return existing;
      }

      // Create new plan
      final newPlan = await supabase
          .from('daily_plans')
          .insert({'user_id': userId, 'date': date})
          .select()
          .single();

      return newPlan;
    } catch (e) {
      debugPrint('❌ Error getting/creating daily plan: $e');
      rethrow;
    }
  }

  /// Save meals for a user (replaces existing meals for today)
  Future<void> saveMeals(String userId, List<Meal> meals) async {
    try {
      debugPrint('💾 Saving ${meals.length} meals for user: $userId');

      final today = DateTime.now().toIso8601String().split('T')[0];

      // Get or create today's daily plan
      final dailyPlan = await _getOrCreateDailyPlan(userId, today);

      // Delete existing daily_plan_meals for today
      await supabase
          .from('daily_plan_meals')
          .delete()
          .eq('daily_plan_id', dailyPlan['id']);

      debugPrint('🗑️ Deleted old daily_plan_meals');

      // Insert meals into meals catalog (or get existing)
      for (final meal in meals) {
        // Check if meal already exists in catalog
        final existingMeal = await supabase
            .from('meals')
            .select('id')
            .eq('name', meal.name)
            .eq('meal_time', _mapMealTimeToDb(meal.time))
            .maybeSingle();

        String mealId;

        if (existingMeal != null) {
          mealId = existingMeal['id'] as String;
        } else {
          // Create new meal in catalog
          final dbTime = _mapMealTimeToDb(meal.time);
          debugPrint(
            '🔍 Inserting meal with time: "$dbTime" (original: "${meal.time}")',
          );

          final newMeal = await supabase
              .from('meals')
              .insert({
                'name': meal.name,
                'meal_time': dbTime,
                'ingredients': meal.ingredients,
                'recipe_steps': meal.recipeSteps,
                'created_by': userId,
                'calories': meal.calories,
                'protein': meal.protein,
                'carbs': meal.carbs,
                'fats': meal.fats,
              })
              .select('id')
              .single();

          mealId = newMeal['id'] as String;
        }

        // Link meal to today's plan and get the daily_plan_meals ID
        await supabase
            .from('daily_plan_meals')
            .insert({
              'daily_plan_id': dailyPlan['id'],
              'meal_id': mealId,
              'meal_time': _mapMealTimeToDb(meal.time),
              'is_completed': false,
            })
            .select('id');
        // Note: We don't need to track the daily_plan_meals ID here
        // It will be fetched properly when we retrieve meals
      }

      debugPrint('✅ Successfully saved ${meals.length} meals');
    } catch (e) {
      debugPrint('❌ Error saving meals: $e');
      throw Exception(parseError(e));
    }
  }

  /// Mark a meal as done or undone, and update daily nutrition tracking
  Future<void> markMealDone(String dailyPlanMealId, bool isDone) async {
    try {
      debugPrint(
        '✏️ Marking daily_plan_meal $dailyPlanMealId as done: $isDone',
      );

      // Get the meal data with nutrition info
      final mealData = await supabase
          .from('daily_plan_meals')
          .select('''
            id,
            daily_plan_id,
            meals (
              calories,
              protein,
              carbs,
              fats
            )
          ''')
          .eq('id', dailyPlanMealId)
          .single();

      final dailyPlanId = mealData['daily_plan_id'] as String;
      final meal = mealData['meals'] as Map<String, dynamic>;

      final calories = (meal['calories'] as int?) ?? 0;
      final protein = (meal['protein'] as num?)?.toDouble() ?? 0.0;
      final carbs = (meal['carbs'] as num?)?.toDouble() ?? 0.0;
      final fats = (meal['fats'] as num?)?.toDouble() ?? 0.0;

      debugPrint(
        '📊 Meal nutrition: ${calories}kcal, ${protein}g protein, ${carbs}g carbs, ${fats}g fats',
      );

      // Update meal completion status
      final updateData = {
        'is_completed': isDone,
        if (isDone) 'completed_at': DateTime.now().toIso8601String(),
      };

      await supabase
          .from('daily_plan_meals')
          .update(updateData)
          .eq('id', dailyPlanMealId);

      // Update daily plan nutrition tracking
      if (isDone) {
        // Add nutrition when marking as done
        await supabase.rpc(
          'increment_daily_nutrition',
          params: {
            'plan_id': dailyPlanId,
            'cal': calories,
            'prot': protein,
            'carb': carbs,
            'fat': fats,
          },
        );
        debugPrint('✅ Added nutrition to daily totals');
      } else {
        // Subtract nutrition when unmarking
        await supabase.rpc(
          'decrement_daily_nutrition',
          params: {
            'plan_id': dailyPlanId,
            'cal': calories,
            'prot': protein,
            'carb': carbs,
            'fat': fats,
          },
        );
        debugPrint('✅ Subtracted nutrition from daily totals');
      }

      debugPrint('✅ Meal status and nutrition tracking updated');
    } catch (e) {
      debugPrint('❌ Error updating meal status: $e');
      throw Exception(parseError(e));
    }
  }

  /// Get daily nutrition progress (consumed vs targets)
  Future<Map<String, dynamic>> getDailyNutritionProgress(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Get daily plan with consumed nutrition
      final dailyPlan = await _getOrCreateDailyPlan(userId, today);

      final consumed = {
        'calories': dailyPlan['consumed_calories'] ?? 0,
        'protein': (dailyPlan['consumed_protein'] as num?)?.toDouble() ?? 0.0,
        'carbs': (dailyPlan['consumed_carbs'] as num?)?.toDouble() ?? 0.0,
        'fats': (dailyPlan['consumed_fats'] as num?)?.toDouble() ?? 0.0,
      };

      debugPrint('📊 Daily nutrition consumed: $consumed');
      return consumed;
    } catch (e) {
      debugPrint('❌ Error fetching nutrition progress: $e');
      return {'calories': 0, 'protein': 0.0, 'carbs': 0.0, 'fats': 0.0};
    }
  }

  /// Delete all meals for today for a specific user
  Future<void> deleteTodaysMeals(String userId) async {
    try {
      debugPrint('🗑️ Deleting today\'s meals for user: $userId');

      final today = DateTime.now().toIso8601String().split('T')[0];

      // Get today's daily plan
      final dailyPlan = await supabase
          .from('daily_plans')
          .select('id')
          .eq('user_id', userId)
          .eq('date', today)
          .maybeSingle();

      if (dailyPlan == null) {
        debugPrint('No daily plan for today');
        return;
      }

      // Delete daily_plan_meals
      await supabase
          .from('daily_plan_meals')
          .delete()
          .eq('daily_plan_id', dailyPlan['id']);

      debugPrint('✅ Today\'s meals deleted');
    } catch (e) {
      debugPrint('❌ Error deleting meals: $e');
      throw Exception(parseError(e));
    }
  }

  /// Map Gemini's meal times to database format
  /// breakfast -> morning, lunch -> afternoon, dinner -> night
  String _mapMealTimeToDb(String time) {
    final Map<String, String> timeMap = {
      'breakfast': 'morning',
      'lunch': 'afternoon',
      'dinner': 'night',
    };
    return timeMap[time.toLowerCase()] ?? time;
  }

  @override
  String parseError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}
