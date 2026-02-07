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
        maxOutputTokens: 8192, // Increased for complete responses
        responseMimeType: 'application/json', // Force JSON responses
        responseSchema: Schema.object(
          properties: {
            'meals': Schema.array(
              items: Schema.object(
                properties: {
                  'name': Schema.string(description: 'Meal name'),
                  'time': Schema.enumString(
                    enumValues: ['breakfast', 'lunch', 'dinner'],
                  ),
                  'ingredients': Schema.array(items: Schema.string()),
                  'recipeSteps': Schema.array(items: Schema.string()),
                  'nutrition': Schema.object(
                    properties: {
                      'calories': Schema.integer(),
                      'protein': Schema.number(),
                      'carbs': Schema.number(),
                      'fats': Schema.number(),
                    },
                    requiredProperties: [
                      'calories',
                      'protein',
                      'carbs',
                      'fats',
                    ],
                  ),
                },
                requiredProperties: [
                  'name',
                  'time',
                  'ingredients',
                  'recipeSteps',
                  'nutrition',
                ],
              ),
            ),
          },
          requiredProperties: ['meals'],
        ),
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
Generate 3 meals in JSON format:

Profile: Age ${profile.age ?? 25}, ${profile.weightKg ?? 70}kg, ${profile.heightCm ?? 170}cm, Goal: $goal, Diet: $dietType
Targets: ${dailyCalories}kcal, ${dailyProtein}g protein, ${dailyCarbs}g carbs, ${dailyFats}g fat

$ingredientsSection

Requirements:
- 3 meals: Breakfast (30% cal), Lunch (40% cal), Dinner (30% cal)
- Budget-friendly, quick (under 30min), Indian cuisine
- Each meal: max 5 ingredients, max 3 recipe steps
- time field MUST be: "breakfast", "lunch", or "dinner" (lowercase only)

JSON Format (NO markdown, NO explanations):
{
  "meals": [
    {
      "name": "Meal Name",
      "time": "breakfast",
      "ingredients": ["item with qty"],
      "recipeSteps": ["brief step"],
      "nutrition": {"calories": 500, "protein": 20, "carbs": 60, "fats": 15}
    },
    {"name": "Lunch", "time": "lunch", "ingredients": [], "recipeSteps": [], "nutrition": {}},
    {"name": "Dinner", "time": "dinner", "ingredients": [], "recipeSteps": [], "nutrition": {}}
  ]
}

Return ONLY the JSON object.
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
          id: '', // Will be populated by database UUID
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
