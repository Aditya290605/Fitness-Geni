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
        maxOutputTokens: 2048,
      ),
    );
  }

  /// Generate personalized meals based on user profile
  Future<List<Meal>> generateMeals({
    required Profile userProfile,
    List<String>? ingredients, // null for surprise mode
  }) async {
    try {
      debugPrint('🤖 Generating meals with Gemini AI...');

      final prompt = _buildPrompt(userProfile, ingredients);
      debugPrint('📝 Prompt length: ${prompt.length} chars');

      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text == null) {
        throw Exception('No response from Gemini AI');
      }

      debugPrint('✅ Received AI response');
      final meals = _parseMealsResponse(response.text!);

      debugPrint('✅ Parsed ${meals.length} meals');
      return meals;
    } catch (e) {
      debugPrint('❌ Gemini AI error: $e');
      rethrow;
    }
  }

  /// Build personalized prompt for Gemini
  String _buildPrompt(Profile profile, List<String>? ingredients) {
    final nutritionTargets = NutritionCalculator.calculateNutritionTargets(
      profile,
    );
    final dailyCalories = nutritionTargets['calories']!;
    final dailyProtein = nutritionTargets['protein']!;
    final dailyCarbs = nutritionTargets['carbs']!;
    final dailyFats = nutritionTargets['fat']!;

    final dietType = profile.dietType?.toLowerCase() ?? 'veg';
    final goal = profile.goal ?? 'maintenance';

    final ingredientsSection = ingredients != null && ingredients.isNotEmpty
        ? '''
INGREDIENT CONSTRAINTS:
- You MUST use these ingredients: ${ingredients.join(', ')}
- You can add other complementary ingredients to make complete meals
- Be creative but ensure most ingredients from the list are used
'''
        : '''
INGREDIENT FLEXIBILITY:
- Choose budget-friendly, commonly available ingredients
- Focus on whole foods and fresh ingredients
- Ensure variety across the three meals
''';

    return '''
You are a professional nutritionist and chef AI. Generate a personalized daily meal plan.

USER PROFILE:
- Age: ${profile.age ?? 25} years
- Height: ${profile.heightCm ?? 170}cm, Weight: ${profile.weightKg ?? 70}kg
- BMI: ${profile.bmi?.toStringAsFixed(1) ?? '23.0'}
- Goal: $goal
- Diet Type: $dietType (${dietType == 'veg' ? 'vegetarian only' : 'can include non-vegetarian'})

DAILY NUTRITION TARGETS:
- Total Calories: ${dailyCalories}kcal (distribute across 3 meals)
- Total Protein: ${dailyProtein}g
- Total Carbs: ${dailyCarbs}g  
- Total Fats: ${dailyFats}g

$ingredientsSection

MEAL REQUIREMENTS:
- Generate exactly 3 meals: Breakfast, Lunch, Dinner
- Each meal should be:
  * Budget-friendly (use common, affordable ingredients)
  * Easy to prepare (max 30 minutes cooking time)
  * Nutritionally balanced
  * Culturally appropriate for Indian cuisine
  * Delicious and appealing

NUTRITION DISTRIBUTION:
- Breakfast: ~30% of daily calories
- Lunch: ~40% of daily calories
- Dinner: ~30% of daily calories

OUTPUT FORMAT (STRICT JSON - NO MARKDOWN, NO CODE BLOCKS):
{
  "meals": [
    {
      "name": "Meal Name",
      "time": "Morning",
      "ingredients": ["ingredient 1 with quantity", "ingredient 2 with quantity", ...],
      "recipeSteps": ["step 1", "step 2", ...],
      "nutrition": {
        "calories": <number>,
        "protein": <number in grams>,
        "carbs": <number in grams>,
        "fats": <number in grams>
      }
    },
    {
      "name": "Meal Name",
      "time": "Afternoon",
      "ingredients": [...],
      "recipeSteps": [...],
      "nutrition": {...}
    },
    {
      "name": "Meal Name",
      "time": "Night",
      "ingredients": [...],
      "recipeSteps": [...],
      "nutrition": {...}
    }
  ]
}

CRITICAL: Return ONLY the JSON object. No markdown, no code blocks, no explanations. Just the raw JSON.
''';
  }

  /// Parse Gemini response into Meal objects
  List<Meal> _parseMealsResponse(String response) {
    try {
      // Clean response - remove markdown code blocks if present
      String cleanResponse = response.trim();
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      } else if (cleanResponse.startsWith('```')) {
        cleanResponse = cleanResponse.substring(3);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      cleanResponse = cleanResponse.trim();

      final jsonData = json.decode(cleanResponse) as Map<String, dynamic>;
      final mealsJson = jsonData['meals'] as List;

      return mealsJson.map((mealJson) {
        final meal = mealJson as Map<String, dynamic>;
        final nutrition = meal['nutrition'] as Map<String, dynamic>;

        return Meal(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              meal['time'].toString().substring(0, 1),
          name: meal['name'] as String,
          time: meal['time'] as String,
          ingredients: (meal['ingredients'] as List).cast<String>(),
          recipeSteps: (meal['recipeSteps'] as List).cast<String>(),
          calories: nutrition['calories'] as int,
          protein: (nutrition['protein'] as num).toDouble(),
          carbs: (nutrition['carbs'] as num).toDouble(),
          fats: (nutrition['fats'] as num).toDouble(),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error parsing Gemini response: $e');
      debugPrint('Response was: $response');
      throw Exception('Failed to parse AI response. Please try again.');
    }
  }
}
