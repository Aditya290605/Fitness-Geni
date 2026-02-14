import 'package:flutter/material.dart';
import '../../domain/models/meal.dart';

/// Full-screen meal detail page with premium layout
class MealDetailSheet extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onMarkDone;

  const MealDetailSheet({super.key, required this.meal, this.onMarkDone});

  static Future<void> show(
    BuildContext context, {
    required Meal meal,
    VoidCallback? onMarkDone,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MealDetailSheet(meal: meal, onMarkDone: onMarkDone),
      ),
    );
  }

  String _getMealImage() {
    final time = meal.time.toLowerCase();
    if (time.contains('breakfast') || time.contains('morning')) {
      return 'assets/images/breakfast.png';
    } else if (time.contains('lunch') || time.contains('afternoon')) {
      return 'assets/images/lunch.png';
    } else if (time.contains('dinner') || time.contains('night')) {
      return 'assets/images/dinner.png';
    }
    return 'assets/images/breakfast.png';
  }

  String _getMealDescription() {
    final cal = meal.calories ?? 0;
    final p = meal.protein?.toStringAsFixed(0) ?? '0';
    final c = meal.carbs?.toStringAsFixed(0) ?? '0';
    final f = meal.fats?.toStringAsFixed(0) ?? '0';
    return 'A wholesome ${meal.time.toLowerCase()} meal with $cal kcal, '
        'packed with ${p}g protein, ${c}g carbs, and ${f}g fats. '
        'Made with ${meal.ingredients.length} fresh ingredients to fuel your day.';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final imageSize = screenWidth * 0.65;
    // Green area height
    const greenHeight = 260.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Header: green bg + large dish image ──
          SizedBox(
            height: greenHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Green background - full width, rounded bottom-left
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 1, 68, 20),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                      ),
                    ),
                  ),
                ),

                // Back button
                Positioned(
                  top: topPadding + 8,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),

                // Meal time label
                Positioned(
                  top: topPadding + 60,
                  left: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      meal.time.toLowerCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                // Dish image - large, half-clipped on the right edge
                // Extends below the green area
                Positioned(
                 
                  right: -(imageSize * 0.38),
                  top: topPadding + 5,
                  child: Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 30,

                          offset: const Offset(-5, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        
                        _getMealImage(), fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50,),

          // ── Scrollable content below header ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal name - below the green header, never overlaps
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 20),
                  // ── Description ──
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getMealDescription(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Nutrition info row ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildNutritionItem(
                          'Calories',
                          '${meal.calories ?? 0}',
                        ),
                        _buildNutritionItem(
                          'Protein',
                          '${meal.protein?.toStringAsFixed(0) ?? '0'}g',
                        ),
                        _buildNutritionItem(
                          'Carbs',
                          '${meal.carbs?.toStringAsFixed(0) ?? '0'}g',
                        ),
                        _buildNutritionItem(
                          'Fats',
                          '${meal.fats?.toStringAsFixed(0) ?? '0'}g',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Ingredients ──
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...meal.ingredients.map(
                    (ingredient) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 7),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Steps ──
                  const Text(
                    'Steps',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...meal.recipeSteps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                step,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // ── Action button ──
                  if (onMarkDone != null && !meal.isDone)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          onMarkDone!();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3D6B4A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Mark as Done',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    )
                  else if (meal.isDone)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF5F0),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFF3D6B4A).withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF3D6B4A),
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: Color(0xFF3D6B4A),
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
