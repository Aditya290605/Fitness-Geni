import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/nutrition_statistics_card.dart';
import '../../../home/presentation/widgets/meal_card.dart';
import '../../../home/presentation/widgets/meal_detail_sheet.dart';
import '../providers/stats_provider.dart';

/// Stats screen — shows meal history with horizontal date slider
/// Reuses NutritionStatisticsCard and MealCard from home page
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int _selectedIndex = 0; // 0 = today (newest-first in history)
  final ScrollController _dateScrollController = ScrollController();
  bool _hasScrolledToToday = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(statsProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  /// Scroll the date slider so today (last item in oldest-first list) is visible
  void _scrollToToday(int totalDays) {
    if (!_dateScrollController.hasClients || totalDays == 0) return;
    // Each item = 54 width + 8 margin = 62
    final itemWidth = 62.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final todayIndexInSlider = totalDays - 1; // last item = today
    final offset =
        (todayIndexInSlider * itemWidth) - screenWidth + itemWidth + 20;
    _dateScrollController.jumpTo(
      offset.clamp(0.0, _dateScrollController.position.maxScrollExtent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final profile = ref.watch(currentProfileProvider);

    // Auto-scroll to today once data loads
    if (!_hasScrolledToToday && stats.history.isNotEmpty) {
      _hasScrolledToToday = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToToday(stats.history.length);
      });
    }

    // Calculate nutrition targets
    final caloriesTarget = profile?.dailyCalories ?? 2000;
    final proteinTarget = (profile?.dailyProtein ?? 150).toDouble();
    final carbsTarget = (caloriesTarget * 0.45 / 4).roundToDouble();
    final fatTarget = (caloriesTarget * 0.25 / 9).roundToDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: stats.isLoading && stats.history.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : stats.error != null && stats.history.isEmpty
            ? _buildErrorState(stats.error!)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildHeader(),
                  ),

                  const SizedBox(height: 16),

                  // ── Bar graph: meal completion overview ──
                  if (stats.history.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildCompletionBarGraph(stats),
                    ),

                  const SizedBox(height: 20),

                  // Month label
                  if (stats.history.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat(
                              'MMMM yyyy',
                            ).format(stats.history[_selectedIndex].date),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Horizontal date slider
                  if (stats.history.isNotEmpty) _buildDateSlider(stats),

                  const SizedBox(height: 20),

                  // Scrollable content for selected date
                  Expanded(
                    child: _buildSelectedDayContent(
                      stats,
                      caloriesTarget,
                      proteinTarget,
                      carbsTarget,
                      fatTarget,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────
  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Track your daily progress',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ─── Completion bar graph (last 7 active days) ────────────────────
  Widget _buildCompletionBarGraph(StatsState stats) {
    // Take up to last 7 days from history (newest-first → first 7 items)
    final recentDays = stats.history.take(7).toList().reversed.toList();
    // oldest → newest for left-to-right display

    // Find max total meals for scaling bars
    final maxMeals = recentDays.fold<int>(
      1,
      (prev, d) => max(prev, d.totalMeals),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stats.activeDays} active',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Bar graph
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: recentDays.map((day) {
                final totalRatio = maxMeals > 0
                    ? day.totalMeals / maxMeals
                    : 0.0;
                final completedRatio = day.totalMeals > 0
                    ? day.completedMeals / day.totalMeals
                    : 0.0;
                final isToday = _isToday(day.date);
                final dayLabel = DateFormat('E').format(day.date);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Bar with gradient
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: day.hasActivity
                                  ? (totalRatio * 0.85 + 0.15)
                                  : 0.12,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: day.hasActivity
                                      ? LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.9),
                                            Colors.white.withValues(
                                              alpha:
                                                  0.3 + (completedRatio * 0.6),
                                            ),
                                          ],
                                        )
                                      : null,
                                  color: day.hasActivity
                                      ? null
                                      : Colors.white.withValues(alpha: 0.12),
                                  boxShadow: day.hasActivity
                                      ? [
                                          BoxShadow(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, -2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: day.hasActivity && completedRatio == 1.0
                                    ? Center(
                                        child: Icon(
                                          Icons.check_rounded,
                                          color: const Color(0xFF1B5E20),
                                          size: 14,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Day label
                        Text(
                          dayLabel.substring(0, min(3, dayLabel.length)),
                          style: TextStyle(
                            color: isToday
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Date slider ──────────────────────────────────────────────────
  Widget _buildDateSlider(StatsState stats) {
    // History is sorted newest-first, slider shows oldest-first
    final reversedHistory = stats.history.reversed.toList();
    final reversedSelectedIndex = reversedHistory.length - 1 - _selectedIndex;

    return SizedBox(
      height: 72,
      child: ListView.builder(
        controller: _dateScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: reversedHistory.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final day = reversedHistory[index];
          final isSelected = index == reversedSelectedIndex;
          final isToday = _isToday(day.date);
          final dayFormat = DateFormat('d');
          final weekdayFormat = DateFormat('EEE');

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = reversedHistory.length - 1 - index;
              });
            },
            child: Container(
              width: 54,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : isToday
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: isToday && !isSelected
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayFormat.format(day.date),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    weekdayFormat.format(day.date).toLowerCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : day.hasActivity
                          ? AppColors.success
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Selected day content ─────────────────────────────────────────
  Widget _buildSelectedDayContent(
    StatsState stats,
    int caloriesTarget,
    double proteinTarget,
    double carbsTarget,
    double fatTarget,
  ) {
    if (stats.history.isEmpty) {
      return const Center(
        child: Text(
          'No data yet',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final day = stats.history[_selectedIndex];
    final isToday = _isToday(day.date);

    return RefreshIndicator(
      onRefresh: () => ref.read(statsProvider.notifier).refresh(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nutrition Statistics Card (reused from home page)
            NutritionStatisticsCard(
              caloriesTarget: caloriesTarget,
              caloriesConsumed: day.consumedCalories,
              proteinTarget: proteinTarget,
              proteinConsumed: day.consumedProtein,
              carbsTarget: carbsTarget,
              carbsConsumed: day.consumedCarbs,
              fatTarget: fatTarget,
              fatConsumed: day.consumedFats,
            ),

            const SizedBox(height: 24),

            // Meals section
            Row(
              children: [
                Text(
                  isToday ? "Today's Meals" : 'Meals',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                if (day.hasActivity)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: day.completedMeals == day.totalMeals
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${day.completedMeals}/${day.totalMeals}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: day.completedMeals == day.totalMeals
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Meal cards or empty state
            if (!day.hasActivity)
              _buildNoMealsState()
            else
              ...day.meals.map(
                (meal) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: MealCard(
                    meal: meal,
                    onTap: () {
                      MealDetailSheet.show(
                        context,
                        meal: meal,
                        onMarkDone: isToday
                            ? () {
                                // Only allow marking done for today
                              }
                            : null,
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────
  Widget _buildNoMealsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.no_meals_outlined,
            size: 48,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Meals not created',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No meal plan was generated for this day',
            style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  // ─── Error state ──────────────────────────────────────────────────
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load stats',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(statsProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
