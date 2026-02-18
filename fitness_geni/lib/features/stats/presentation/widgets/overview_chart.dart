import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/models/daily_history_model.dart';

enum ChartFilter { weekly, monthly, yearly }

/// Premium curved line/area chart showing meal completion over time.
/// White background with green gradient lines and shaded area fill,
/// plus a Weekly / Monthly / Yearly filter dropdown.
class OverviewChart extends StatefulWidget {
  final List<DailyHistory> history; // newest-first

  const OverviewChart({super.key, required this.history});

  @override
  State<OverviewChart> createState() => _OverviewChartState();
}

class _OverviewChartState extends State<OverviewChart> {
  ChartFilter _filter = ChartFilter.weekly;

  // ── Data colors ───────────────────────────────────────────────────
  static const _lineColor = Color(0xFF2E7D32);
  static const _lineColorLight = Color(0xFF66BB6A);
  static const _textDark = Color(0xFF1B1B1B);
  static const _textMuted = Color(0xFF9E9E9E);

  // ── Aggregate history into chart data points ──────────────────────
  List<_ChartPoint> _buildPoints() {
    if (widget.history.isEmpty) return [];

    switch (_filter) {
      case ChartFilter.weekly:
        return _buildWeeklyPoints();
      case ChartFilter.monthly:
        return _buildMonthlyPoints();
      case ChartFilter.yearly:
        return _buildYearlyPoints();
    }
  }

  List<_ChartPoint> _buildWeeklyPoints() {
    final days = widget.history.take(7).toList().reversed.toList();
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return List.generate(days.length, (i) {
      final d = days[i];
      return _ChartPoint(
        label: dayLabels[d.date.weekday - 1],
        totalMeals: d.totalMeals.toDouble(),
        completedMeals: d.completedMeals.toDouble(),
      );
    });
  }

  List<_ChartPoint> _buildMonthlyPoints() {
    final monthLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    final Map<int, List<DailyHistory>> byMonth = {};

    for (final d in widget.history) {
      final monthsAgo =
          (now.year - d.date.year) * 12 + (now.month - d.date.month);
      if (monthsAgo >= 0 && monthsAgo < 12) {
        byMonth.putIfAbsent(d.date.month, () => []).add(d);
      }
    }

    final points = <_ChartPoint>[];
    for (var i = 11; i >= 0; i--) {
      final month = ((now.month - i - 1) % 12) + 1;
      final days = byMonth[month] ?? [];
      final total = days.fold<double>(0, (s, d) => s + d.totalMeals);
      final completed = days.fold<double>(0, (s, d) => s + d.completedMeals);
      points.add(
        _ChartPoint(
          label: monthLabels[month - 1],
          totalMeals: total,
          completedMeals: completed,
        ),
      );
    }
    return points;
  }

  List<_ChartPoint> _buildYearlyPoints() {
    final Map<int, List<DailyHistory>> byYear = {};

    for (final d in widget.history) {
      byYear.putIfAbsent(d.date.year, () => []).add(d);
    }

    final years = byYear.keys.toList()..sort();
    final recentYears = years.length > 5
        ? years.sublist(years.length - 5)
        : years;

    return recentYears.map((year) {
      final days = byYear[year]!;
      final total = days.fold<double>(0, (s, d) => s + d.totalMeals);
      final completed = days.fold<double>(0, (s, d) => s + d.completedMeals);
      return _ChartPoint(
        label: '$year',
        totalMeals: total,
        completedMeals: completed,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final points = _buildPoints();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              _buildFilterDropdown(),
            ],
          ),

          const SizedBox(height: 24),

          // ── Chart ──
          SizedBox(
            height: 160,
            child: points.length < 2
                ? const Center(
                    child: Text(
                      'Not enough data yet',
                      style: TextStyle(color: _textMuted, fontSize: 14),
                    ),
                  )
                : _buildLineChart(points),
          ),
        ],
      ),
    );
  }

  // ── Filter dropdown ───────────────────────────────────────────────
  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ChartFilter>(
          value: _filter,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _textDark,
            size: 18,
          ),
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: _textDark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          isDense: true,
          items: ChartFilter.values.map((f) {
            return DropdownMenuItem(value: f, child: Text(_filterLabel(f)));
          }).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _filter = v);
          },
        ),
      ),
    );
  }

  String _filterLabel(ChartFilter f) {
    switch (f) {
      case ChartFilter.weekly:
        return 'Weekly';
      case ChartFilter.monthly:
        return 'Monthly';
      case ChartFilter.yearly:
        return 'Yearly';
    }
  }

  // ── Smooth line chart with green shaded area ──────────────────────
  Widget _buildLineChart(List<_ChartPoint> points) {
    final maxY =
        points.fold<double>(
          0,
          (prev, p) => max(prev, max(p.totalMeals, p.completedMeals)),
        ) *
        1.2;
    final safeMaxY = maxY == 0 ? 10.0 : maxY;

    final completedSpots = List.generate(
      points.length,
      (i) => FlSpot(i.toDouble(), points[i].completedMeals),
    );

    final totalSpots = List.generate(
      points.length,
      (i) => FlSpot(i.toDouble(), points[i].totalMeals),
    );

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: safeMaxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: safeMaxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: const Color(0xFFF0F0F0), strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= points.length) {
                  return const SizedBox.shrink();
                }
                final isLast = idx == points.length - 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: isLast
                        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
                        : null,
                    decoration: isLast
                        ? BoxDecoration(
                            color: _lineColor,
                            borderRadius: BorderRadius.circular(10),
                          )
                        : null,
                    child: Text(
                      points[idx].label,
                      style: TextStyle(
                        color: isLast ? Colors.white : _textMuted,
                        fontSize: 11,
                        fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1B5E20),
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final isCompleted = spot.barIndex == 0;
                return LineTooltipItem(
                  '${spot.y.toInt()} ${isCompleted ? "done" : "total"}',
                  TextStyle(
                    color: isCompleted
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          // Completed meals — solid green line with green shaded area
          LineChartBarData(
            spots: completedSpots,
            isCurved: true,
            curveSmoothness: 0.35,
            preventCurveOverShooting: true,
            gradient: const LinearGradient(
              colors: [_lineColor, _lineColorLight],
            ),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index == completedSpots.length - 1) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Colors.white,
                    strokeWidth: 3,
                    strokeColor: _lineColor,
                  );
                }
                return FlDotCirclePainter(
                  radius: 0,
                  color: Colors.transparent,
                  strokeWidth: 0,
                  strokeColor: Colors.transparent,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _lineColorLight.withValues(alpha: 0.4),
                  _lineColorLight.withValues(alpha: 0.15),
                  _lineColorLight.withValues(alpha: 0.02),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Total meals — dashed lighter green line
          LineChartBarData(
            spots: totalSpots,
            isCurved: true,
            curveSmoothness: 0.35,
            preventCurveOverShooting: true,
            color: _lineColorLight.withValues(alpha: 0.4),
            barWidth: 2,
            dotData: const FlDotData(show: false),
            dashArray: [6, 4],
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _lineColorLight.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }
}

/// Internal data point for the chart
class _ChartPoint {
  final String label;
  final double totalMeals;
  final double completedMeals;

  const _ChartPoint({
    required this.label,
    required this.totalMeals,
    required this.completedMeals,
  });
}
