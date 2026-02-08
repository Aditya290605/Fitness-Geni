import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_provider.dart';
import '../providers/meal_provider.dart';
import '../widgets/nutrition_statistics_card.dart';
import '../widgets/meal_card.dart';
import '../widgets/meal_detail_sheet.dart';
import 'create_meals_screen.dart';

/// Home screen showing today's meal plan
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealState = ref.watch(mealProvider);
    final mealNotifier = ref.read(mealProvider.notifier);

    // Lazy load meals when home screen is accessed
    if (!mealState.isLoading &&
        mealState.meals.isEmpty &&
        mealState.error == null) {
      Future.microtask(() => mealNotifier.loadMeals());
    }

    // Get real user name and profile
    final currentProfile = ref.watch(currentProfileProvider);
    final userName = currentProfile?.name ?? 'there';

    // Calculate nutrition targets
    final caloriesTarget = currentProfile?.dailyCalories ?? 2000;
    final proteinTarget = (currentProfile?.dailyProtein ?? 150).toDouble();
    // Rough estimates for carbs and fats based on calorie distribution
    final carbsTarget = (caloriesTarget * 0.45 / 4)
        .roundToDouble(); // 45% of calories from carbs
    final fatTarget = (caloriesTarget * 0.25 / 9)
        .roundToDouble(); // 25% of calories from fats

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: mealState.meals.isEmpty
            ? _buildEmptyState(context)
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Header with personalized greeting
                    Text(
                      '${_getGreeting()}, $userName',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Here\'s your plan for today',
                      style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                    ),

                    const SizedBox(height: 28),

                    // Statistics card
                    NutritionStatisticsCard(
                      caloriesTarget: caloriesTarget,
                      caloriesConsumed: mealState.consumedCalories,
                      proteinTarget: proteinTarget,
                      proteinConsumed: mealState.consumedProtein,
                      carbsTarget: carbsTarget,
                      carbsConsumed: mealState.consumedCarbs,
                      fatTarget: fatTarget,
                      fatConsumed: mealState.consumedFats,
                      onTap: () {
                        // Navigate to statistics screen if available
                      },
                    ),

                    const SizedBox(height: 20),

                    // Create/Change meals button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateMealsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Create / Change Meals',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Section title
                    const Text(
                      'Today\'s Meals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Meal cards - sorted by time order
                    ...(() {
                      final sortedMeals = mealState.meals.toList()
                        ..sort((a, b) {
                          int getOrder(String time) {
                            final t = time.toLowerCase();
                            if (t.contains('breakfast') ||
                                t.contains('morning')) {
                              return 1;
                            }
                            if (t.contains('lunch') ||
                                t.contains('afternoon')) {
                              return 2;
                            }
                            if (t.contains('dinner') || t.contains('night')) {
                              return 3;
                            }
                            return 4; // snacks
                          }

                          return getOrder(a.time).compareTo(getOrder(b.time));
                        });
                      return sortedMeals.map(
                        (meal) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: MealCard(
                            meal: meal,
                            onTap: () {
                              MealDetailSheet.show(
                                context,
                                meal: meal,
                                onMarkDone: () {
                                  mealNotifier.markMealDone(meal.id);
                                },
                              );
                            },
                          ),
                        ),
                      );
                    })(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 80,
              color: const Color(0xFFCCCCCC),
            ),
            const SizedBox(height: 20),
            const Text(
              'No meals planned yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Generate your personalized meal plan to get started',
              style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateMealsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                label: const Text(
                  'Generate Today\'s Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
