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
              recipe_steps
            )
          ''')
          .eq('daily_plan_id', dailyPlan['id'])
          .order('meal_time');

      debugPrint('✅ Fetched ${response.length} meals from Supabase');

      return (response as List).map((json) {
        final mealData = json['meals'] as Map<String, dynamic>;
        return Meal(
          id: json['id'] as String, // daily_plan_meals ID
          name: mealData['name'] as String,
          time: json['meal_time'] as String,
          ingredients: (mealData['ingredients'] as List).cast<String>(),
          recipeSteps: (mealData['recipe_steps'] as List).cast<String>(),
          isDone: json['is_completed'] as bool? ?? false,
          userId: userId,
          date: today,
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
            .eq('meal_time', meal.time)
            .maybeSingle();

        String mealId;

        if (existingMeal != null) {
          mealId = existingMeal['id'] as String;
        } else {
          // Create new meal in catalog
          final newMeal = await supabase
              .from('meals')
              .insert({
                'name': meal.name,
                'meal_time': meal.time,
                'ingredients': meal.ingredients,
                'recipe_steps': meal.recipeSteps,
                'created_by': userId,
              })
              .select('id')
              .single();

          mealId = newMeal['id'] as String;
        }

        // Link meal to today's plan
        await supabase.from('daily_plan_meals').insert({
          'daily_plan_id': dailyPlan['id'],
          'meal_id': mealId,
          'meal_time': meal.time,
          'is_completed': false,
        });
      }

      debugPrint('✅ Successfully saved ${meals.length} meals');
    } catch (e) {
      debugPrint('❌ Error saving meals: $e');
      throw Exception(parseError(e));
    }
  }

  /// Mark a meal as done or undone
  Future<void> markMealDone(String dailyPlanMealId, bool isDone) async {
    try {
      debugPrint(
        '✏️ Marking daily_plan_meal $dailyPlanMealId as done: $isDone',
      );

      final updateData = {
        'is_completed': isDone,
        if (isDone) 'completed_at': DateTime.now().toIso8601String(),
      };

      await supabase
          .from('daily_plan_meals')
          .update(updateData)
          .eq('id', dailyPlanMealId);

      debugPrint('✅ Meal status updated');
    } catch (e) {
      debugPrint('❌ Error updating meal status: $e');
      throw Exception(parseError(e));
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
}
