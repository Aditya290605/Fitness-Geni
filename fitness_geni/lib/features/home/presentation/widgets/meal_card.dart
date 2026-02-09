import 'package:flutter/material.dart';
import '../../domain/models/meal.dart';

/// Clean, premium meal card with white background and left-aligned image
class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;

  const MealCard({super.key, required this.meal, required this.onTap});

  // Get meal-specific image based on time/type
  String _getMealImage() {
    final time = meal.time.toLowerCase();
    if (time.contains('breakfast') || time.contains('morning')) {
      return 'assets/images/breakfast.png';
    } else if (time.contains('lunch') || time.contains('afternoon')) {
      return 'assets/images/lunch.png';
    } else if (time.contains('dinner') || time.contains('night')) {
      return 'assets/images/dinner.png';
    } else {
      return 'assets/images/breakfast.png'; // Default
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: meal.isDone ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: meal.isDone ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(meal.isDone ? 0.02 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(meal.isDone ? 0.01 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left side - Meal Image with checkmark overlay when done
                    Stack(
                      children: [
                        Opacity(
                          opacity: 0.95,
                          child: Container(
                          
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ColorFiltered(
                                colorFilter: meal.isDone
                                    ? ColorFilter.mode(
                                        Colors.grey.withOpacity(0.5),
                                        BlendMode.saturation,
                                      )
                                    : const ColorFilter.mode(
                                        Colors.transparent,
                                        BlendMode.multiply,
                                      ),
                                child: Image.asset(
                                  _getMealImage(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Checkmark overlay when done
                        if (meal.isDone)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 14),

                  // Right side - Meal details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Meal name
                        Text(
                          meal.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: meal.isDone
                                ? Colors.grey.shade600
                                : Colors.black87,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 10),

                        // Nutrition values - side by side
                        Row(
                          children: [
                            _buildNutritionItem(
                              '${meal.calories ?? 0}',
                              'Calories',
                            ),
                            const SizedBox(width: 16),
                            _buildNutritionItem(
                              '${meal.protein?.toStringAsFixed(0) ?? 0}g',
                              'Protein',
                            ),
                            const SizedBox(width: 16),
                            _buildNutritionItem(
                              '${meal.carbs?.toStringAsFixed(0) ?? 0}g',
                              'Carbs',
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // View Meal Details button
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: meal.isDone
                                  ? Colors.grey.shade400
                                  : Colors.black,
                              foregroundColor: meal.isDone
                                  ? Colors.grey.shade600
                                  : Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              meal.isDone ? 'Completed' : 'View Meal Details',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildNutritionItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: meal.isDone ? Colors.grey.shade500 : Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: meal.isDone
                ? Colors.grey.shade400
                : Colors.black.withOpacity(0.5),
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
