import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../auth/auth_state.dart';
import '../config/gemini_config.dart';
import '../utils/nutrition_calculator.dart';
import '../../features/home/domain/models/meal.dart';

/// Service for generating meals using Gemini AI
class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: GeminiConfig.model,
      apiKey: GeminiConfig.apiKey,
      generationConfig: GenerationConfig(
        temperature: GeminiConfig.temperature,
        topP: GeminiConfig.topP,
        maxOutputTokens: 65536,
      ),
    );
  }

  /// Generate personalized meals based on user profile
  Future<List<Meal>> generateMeals({
    required Profile userProfile,
    List<String>? ingredients,
  }) async {
    try {
      debugPrint('🤖 Generating meals with Gemini AI (one at a time)...');

      final nutritionTargets = NutritionCalculator.calculateNutritionTargets(
        userProfile,
      );
      final dailyCalories = nutritionTargets['calories']!;
      final dailyProtein = nutritionTargets['protein']!;
      final dailyCarbs = nutritionTargets['carbs']!;
      final dailyFats = nutritionTargets['fat']!;

      final dietType = userProfile.dietType?.toLowerCase() ?? 'veg';
      final goal = userProfile.goal ?? 'maintenance';

      final ingredientText = ingredients != null && ingredients.isNotEmpty
          ? 'Must use: ${ingredients.join(', ')}. Add extras as needed.'
          : 'Use common Indian ingredients.';

      // Calculate per-meal targets
      final mealConfigs = [
        {'time': 'breakfast', 'calPct': 0.30, 'label': 'Breakfast'},
        {'time': 'lunch', 'calPct': 0.40, 'label': 'Lunch'},
        {'time': 'dinner', 'calPct': 0.30, 'label': 'Dinner'},
      ];

      final meals = <Meal>[];

      for (final config in mealConfigs) {
        final pct = config['calPct'] as double;
        final mealTime = config['time'] as String;
        final label = config['label'] as String;
        final cal = (dailyCalories * pct).round();
        final pro = (dailyProtein * pct).round();
        final carb = (dailyCarbs * pct).round();
        final fat = (dailyFats * pct).round();

        debugPrint('📝 Generating $label...');

        final prompt =
            '''
Return ONLY a JSON object for one $label meal. No markdown, no code blocks, no extra text.

$dietType diet, goal=$goal. $ingredientText
Target: ${cal}kcal, ${pro}g protein, ${carb}g carbs, ${fat}g fat.

Need: 5-6 ingredients with qty, 4-5 detailed steps (full sentences with timing). No emojis. No special chars. Plain text only.

{"name":"Meal Name","time":"$mealTime","ingredients":["100g item","2 eggs"],"recipeSteps":["Heat oil in pan over medium heat for 1 minute.","Add onions and saute for 3 minutes until golden."],"nutrition":{"calories":$cal,"protein":$pro,"carbs":$carb,"fats":$fat}}
''';

        try {
          final response = await _model.generateContent([Content.text(prompt)]);

          if (response.text == null) {
            debugPrint('⚠️ No response for $label, skipping');
            continue;
          }

          debugPrint('✅ $label response: ${response.text!.length} chars');

          final meal = _parseSingleMeal(response.text!);
          if (meal != null) {
            meals.add(meal);
            debugPrint('✅ Parsed $label: ${meal.name}');
          }
        } catch (e) {
          debugPrint('⚠️ Failed to generate $label: $e');
          // Continue with remaining meals
        }
      }

      if (meals.isEmpty) {
        throw Exception('Failed to generate any meals. Please try again.');
      }

      debugPrint('✅ Total meals generated: ${meals.length}');
      return meals;
    } catch (e) {
      debugPrint('❌ Gemini AI error: $e');
      rethrow;
    }
  }

  /// Parse a single meal JSON response
  Meal? _parseSingleMeal(String response) {
    try {
      String clean = response.trim();

      // Remove markdown code fences
      if (clean.startsWith('```json')) {
        clean = clean.substring(7);
      } else if (clean.startsWith('```')) {
        clean = clean.substring(3);
      }
      if (clean.endsWith('```')) {
        clean = clean.substring(0, clean.length - 3);
      }
      clean = clean.trim();

      // Find the JSON object boundaries
      final start = clean.indexOf('{');
      final end = clean.lastIndexOf('}');
      if (start == -1 || end == -1 || end <= start) {
        debugPrint('⚠️ No valid JSON object found in response');
        return null;
      }
      clean = clean.substring(start, end + 1);

      final mealJson = json.decode(clean) as Map<String, dynamic>;

      // Handle both flat and nested formats
      Map<String, dynamic> meal;
      if (mealJson.containsKey('meals')) {
        final mealsList = mealJson['meals'] as List;
        if (mealsList.isEmpty) return null;
        meal = mealsList[0] as Map<String, dynamic>;
      } else {
        meal = mealJson;
      }

      final nutrition = meal['nutrition'] as Map<String, dynamic>;

      return Meal(
        id: '',
        name: meal['name'] as String,
        time: meal['time'] as String,
        ingredients: (meal['ingredients'] as List).cast<String>(),
        recipeSteps: (meal['recipeSteps'] as List).cast<String>(),
        calories: nutrition['calories'] as int,
        protein: (nutrition['protein'] as num).toDouble(),
        carbs: (nutrition['carbs'] as num).toDouble(),
        fats: (nutrition['fats'] as num).toDouble(),
      );
    } catch (e) {
      debugPrint('❌ Error parsing single meal: $e');
      debugPrint(
        'Response: ${response.length > 500 ? response.substring(0, 500) : response}',
      );
      return null;
    }
  }
}
