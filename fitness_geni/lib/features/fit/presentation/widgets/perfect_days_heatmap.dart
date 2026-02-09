import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Custom heatmap calendar showing "perfect days"
/// Green = all meals logged + protein goal achieved
/// Grey = incomplete day
/// Replaces flutter_heatmap_calendar due to Flutter compatibility issues
class PerfectDaysHeatmap extends StatelessWidget {
  final Map<DateTime, bool> perfectDays;
  final bool isLoading;

  const PerfectDaysHeatmap({
    super.key,
    required this.perfectDays,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayWeekday = DateTime(now.year, now.month, 1).weekday;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header
          Text(
            _getMonthName(now.month),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            children: [
              _LegendItem(color: AppColors.success, label: 'Perfect Day'),
              const SizedBox(width: 16),
              _LegendItem(color: AppColors.border, label: 'Incomplete'),
            ],
          ),
          const SizedBox(height: 16),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (day) => SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            _buildCalendarGrid(now, daysInMonth, firstDayWeekday),

          // Perfect days count
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, size: 18, color: AppColors.success),
                const SizedBox(width: 6),
                Text(
                  '${_countPerfectDays(now)} perfect days this month',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    DateTime now,
    int daysInMonth,
    int firstDayWeekday,
  ) {
    // Monday = 1, Sunday = 7
    final offset = firstDayWeekday - 1; // 0 for Monday, 6 for Sunday
    final totalCells = offset + daysInMonth;
    final weeks = (totalCells / 7).ceil();

    return Column(
      children: List.generate(weeks, (weekIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (dayIndex) {
              final cellIndex = weekIndex * 7 + dayIndex;
              final dayNumber = cellIndex - offset + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox(width: 32, height: 32);
              }

              final date = DateTime(now.year, now.month, dayNumber);
              final isPerfect = _isPerfectDay(date);
              final isToday = dayNumber == now.day;
              final isFuture = dayNumber > now.day;

              return _DayCell(
                day: dayNumber,
                isPerfect: isPerfect,
                isToday: isToday,
                isFuture: isFuture,
              );
            }),
          ),
        );
      }),
    );
  }

  bool _isPerfectDay(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return perfectDays[normalized] ?? false;
  }

  int _countPerfectDays(DateTime now) {
    return perfectDays.entries
        .where(
          (e) => e.key.year == now.year && e.key.month == now.month && e.value,
        )
        .length;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

/// Individual day cell in the calendar
class _DayCell extends StatelessWidget {
  final int day;
  final bool isPerfect;
  final bool isToday;
  final bool isFuture;

  const _DayCell({
    required this.day,
    required this.isPerfect,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (isFuture) {
      bgColor = AppColors.surfaceVariant;
      textColor = AppColors.textTertiary;
    } else if (isPerfect) {
      bgColor = AppColors.success;
      textColor = Colors.white;
    } else {
      bgColor = AppColors.border.withValues(alpha: 0.4);
      textColor = AppColors.textSecondary;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

/// Legend item showing color meaning
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
