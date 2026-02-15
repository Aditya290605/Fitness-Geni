import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Custom heatmap calendar showing "perfect days"
/// Green = all meals logged + protein goal achieved
/// Grey = incomplete day
/// Refined design with larger cells, softer greens, and polished legend
class PerfectDaysHeatmap extends StatelessWidget {
  final Map<DateTime, bool> perfectDays;
  final bool isLoading;

  const PerfectDaysHeatmap({
    super.key,
    required this.perfectDays,
    this.isLoading = false,
  });

  static const Color _perfectGreen = Color(0xFF10B981);
  static const Color _perfectGreenLight = Color(0xFFD1FAE5);

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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header + legend row
          Row(
            children: [
              Text(
                _getMonthName(now.month),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              _LegendItem(color: _perfectGreen, label: 'Perfect'),
              const SizedBox(width: 12),
              _LegendItem(
                color: AppColors.border.withValues(alpha: 0.5),
                label: 'Incomplete',
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (day) => SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
            padding: const EdgeInsets.only(top: 18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _perfectGreenLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: _perfectGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_countPerfectDays(now)} perfect day${_countPerfectDays(now) == 1 ? '' : 's'} this month',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
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
    final offset = firstDayWeekday - 1;
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
                return const SizedBox(width: 36, height: 36);
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

/// Individual day cell in the calendar — larger, more rounded
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
      bgColor = AppColors.surfaceVariant.withValues(alpha: 0.5);
      textColor = AppColors.textTertiary.withValues(alpha: 0.6);
    } else if (isPerfect) {
      bgColor = const Color(0xFF10B981);
      textColor = Colors.white;
    } else {
      bgColor = AppColors.border.withValues(alpha: 0.3);
      textColor = AppColors.textSecondary;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(color: AppColors.primary, width: 2.5)
            : null,
        boxShadow: isPerfect && !isFuture
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday || isPerfect
                ? FontWeight.bold
                : FontWeight.w500,
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
