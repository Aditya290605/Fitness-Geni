import 'package:flutter/material.dart';
import '../../domain/models/meal.dart';

/// Premium horizontal meal card with app-themed colored background
class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;

  const MealCard({super.key, required this.meal, required this.onTap});

  // Get meal-specific color based on time/type - matching app theme
  Color _getMealColor() {
    final time = meal.time.toLowerCase();
    if (time.contains('breakfast') || time.contains('morning')) {
      return const Color(0xFFF3E5F5); // Light purple for morning
    } else if (time.contains('lunch') || time.contains('afternoon')) {
      return const Color(0xFFE8EAF6); // Indigo tint for afternoon
    } else if (time.contains('dinner') || time.contains('night')) {
      return const Color(0xFFEDE7F6); // Deep purple tint for night
    } else {
      return const Color(0xFFF3E5F5); // Default light purple for snacks
    }
  }

  Color _getAccentColor() {
    final time = meal.time.toLowerCase();
    if (time.contains('breakfast') || time.contains('morning')) {
      return const Color(0xFF9C27B0); // Purple
    } else if (time.contains('lunch') || time.contains('afternoon')) {
      return const Color(0xFF5C6BC0); // Indigo
    } else if (time.contains('dinner') || time.contains('night')) {
      return const Color(0xFF673AB7); // Deep Purple
    } else {
      return const Color(0xFFAB47BC); // Light purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealColor = _getMealColor();
    final accentColor = _getAccentColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: mealColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles in background
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
            Positioned(
              right: 70,
              bottom: -20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Left side - Meal info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meal name
                        Text(
                          meal.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            decoration: meal.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: Colors.black54,
                            decorationThickness: 2,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Time badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            meal.time,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Nutrition info - labeled
                        Row(
                          children: [
                            _buildNutritionLabel(
                              'Cal',
                              '${meal.calories ?? 0}',
                              accentColor,
                            ),
                            const SizedBox(width: 12),
                            _buildNutritionLabel(
                              'Protein',
                              '${meal.protein?.toStringAsFixed(0) ?? 0}g',
                              accentColor,
                            ),
                            const SizedBox(width: 12),
                            _buildNutritionLabel(
                              'Carbs',
                              '${meal.carbs?.toStringAsFixed(0) ?? 0}g',
                              accentColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right side - Visual element with nutrition highlight
                  Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accentColor.withValues(alpha: 0.9),
                          accentColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main calorie display
                        Text(
                          '${meal.calories ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'kcal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Status indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: meal.isDone
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            meal.isDone ? 'Done' : 'Pending',
                            style: TextStyle(
                              color: meal.isDone ? accentColor : Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionLabel(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color.withValues(alpha: 0.8),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
