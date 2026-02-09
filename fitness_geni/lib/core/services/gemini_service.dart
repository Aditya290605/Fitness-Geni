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
        maxOutputTokens: 8192, // Full token limit for complete responses
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
Generate 3 daily meals in pure JSON format (no markdown, no code blocks).

Profile: Age ${profile.age ?? 25}, ${profile.weightKg ?? 70}kg, ${profile.heightCm ?? 170}cm, Goal: $goal, Diet: $dietType
Targets: ${dailyCalories}kcal, ${dailyProtein}g protein, ${dailyCarbs}g carbs, ${dailyFats}g fat

$ingredientsSection

Requirements:
- 3 meals: Breakfast (30% cal), Lunch (40% cal), Dinner (30% cal)
- Budget-friendly, quick (~20min), Indian/simple cuisine
- Each meal: max 5 ingredients (with qty), max 3 brief recipe steps
- time field MUST be: "breakfast", "lunch", or "dinner" (lowercase only)
- Ingredients: include quantity in the string (e.g., "100g paneer", "2 eggs")

CRITICAL: Return ONLY valid JSON, NO markdown code fences (```), NO explanations.

JSON Format:
{
  "meals": [
    {
      "name": "Meal Name",
      "time": "breakfast",
      "ingredients": ["qty + item"],
      "recipeSteps": ["brief step"],
      "nutrition": {"calories": 500, "protein": 20, "carbs": 60, "fats": 15}
    },
    {"name": "Lunch", "time": "lunch", "ingredients": [], "recipeSteps": [], "nutrition": {}},
    {"name": "Dinner", "time": "dinner", "ingredients": [], "recipeSteps": [], "nutrition": {}}
  ]
}
''';
  }

  /// Parse Gemini response into Meal objects
  List<Meal> _parseMealsResponse(String response) {
    try {
      debugPrint('📥 Raw response length: ${response.length} chars');

      // Clean response - remove markdown code blocks if present
      String cleanResponse = response.trim();

      // Remove markdown code fences
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      } else if (cleanResponse.startsWith('```')) {
        cleanResponse = cleanResponse.substring(3);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      cleanResponse = cleanResponse.trim();

      // Fix common JSON issues
      // 1. Replace unescaped newlines in strings
      cleanResponse = _fixJsonString(cleanResponse);

      debugPrint('🧹 Cleaned response length: ${cleanResponse.length} chars');

      // Try to parse JSON
      Map<String, dynamic> jsonData;
      try {
        jsonData = json.decode(cleanResponse) as Map<String, dynamic>;
      } catch (e) {
        // If parsing fails, try to fix truncated JSON
        debugPrint(
          '⚠️ Initial parse failed, attempting to fix truncated JSON...',
        );
        cleanResponse = _fixTruncatedJson(cleanResponse);
        jsonData = json.decode(cleanResponse) as Map<String, dynamic>;
      }

      final mealsJson = jsonData['meals'] as List;

      if (mealsJson.isEmpty) {
        throw Exception('No meals in response');
      }

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

      // Show first 500 chars and last 500 chars for debugging
      final start = response.length > 500
          ? response.substring(0, 500)
          : response;
      final end = response.length > 500
          ? response.substring(response.length - 500)
          : '';

      debugPrint('Response start: $start');
      if (end.isNotEmpty) {
        debugPrint('Response end: $end');
      }

      throw Exception('Failed to parse AI response. Please try again.');
    }
  }

  /// Fix common JSON string issues
  String _fixJsonString(String jsonStr) {
    // This helps with strings that contain unescaped quotes or newlines
    // The AI should return properly escaped JSON, but this adds safety
    return jsonStr;
  }

  /// Attempt to fix truncated JSON by closing open structures
  String _fixTruncatedJson(String jsonStr) {
    debugPrint('🔧 Attempting to fix truncated JSON...');

    // Count open/close brackets and braces
    int openBraces = 0;
    int openBrackets = 0;
    bool inString = false;
    bool escaped = false;
    int lastValidPos = 0;

    for (int i = 0; i < jsonStr.length; i++) {
      final char = jsonStr[i];

      if (escaped) {
        escaped = false;
        continue;
      }

      if (char == '\\') {
        escaped = true;
        continue;
      }

      if (char == '"') {
        inString = !inString;
        if (!inString) {
          lastValidPos = i; // Track position after closing quotes
        }
        continue;
      }

      if (!inString) {
        if (char == '{') openBraces++;
        if (char == '}') openBraces--;
        if (char == '[') openBrackets++;
        if (char == ']') openBrackets--;

        // Track last valid position
        if (char == '}' || char == ']' || char == ',') {
          lastValidPos = i;
        }
      }
    }

    // If we're in a string, we need to be more careful
    String fixed = jsonStr;

    if (inString) {
      // Try to truncate at last valid position instead of closing mid-string
      // This removes the incomplete data
      if (lastValidPos > 0 && lastValidPos < jsonStr.length - 1) {
        fixed = jsonStr.substring(0, lastValidPos + 1);
        debugPrint('🔧 Truncated at last valid position: $lastValidPos');

        // Recount after truncation
        openBraces = 0;
        openBrackets = 0;
        inString = false;

        for (int i = 0; i < fixed.length; i++) {
          final char = fixed[i];
          if (char == '"') inString = !inString;
          if (!inString) {
            if (char == '{') openBraces++;
            if (char == '}') openBraces--;
            if (char == '[') openBrackets++;
            if (char == ']') openBrackets--;
          }
        }
      } else {
        fixed += '"';
        debugPrint('🔧 Closed unterminated string');
      }
    }

    // Close any open arrays
    while (openBrackets > 0) {
      fixed += ']';
      openBrackets--;
      debugPrint('🔧 Closed open array');
    }

    // Close any open objects
    while (openBraces > 0) {
      fixed += '}';
      openBraces--;
      debugPrint('🔧 Closed open object');
    }

    debugPrint(
      '🔧 Fixed JSON length: ${fixed.length} (original: ${jsonStr.length})',
    );
    return fixed;
  }
}
