import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Premium green bar chart showing last 7 days of steps
/// Rounded bars with green gradient, step labels above bars,
/// today highlighted, weekly summary row at top
class WeeklyActivityChart extends StatelessWidget {
  final List<int> weeklySteps;
  final bool hasData;

  const WeeklyActivityChart({
    super.key,
    required this.weeklySteps,
    this.hasData = true,
  });

  // Green palette for the chart
  static const Color _greenMain = Color(0xFF10B981);
  static const Color _greenLight = Color(0xFF34D399);
  static const Color _greenVeryLight = Color(0xFFD1FAE5);
  static const Color _greenDark = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    final steps = weeklySteps.length == 7 ? weeklySteps : List.filled(7, 0);
    final maxSteps = steps.reduce((a, b) => a > b ? a : b);
    final totalSteps = steps.fold(0, (sum, s) => sum + s);
    final avgSteps = totalSteps ~/ 7;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: _greenMain.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary row
          _buildSummaryRow(totalSteps, avgSteps),
          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 200,
            child: hasData && maxSteps > 0
                ? _buildBarChart(steps, maxSteps)
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(int totalSteps, int avgSteps) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: _greenVeryLight.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _greenMain.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.directions_walk_rounded,
                    size: 20,
                    color: _greenDark,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatNumber(totalSteps),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _greenDark,
                      ),
                    ),
                    const Text(
                      'Total Steps',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _greenGlow,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatNumber(avgSteps),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Daily Avg',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<int> steps, int maxSteps) {
    final yMax = (maxSteps * 1.35).toDouble();
    final today = DateTime.now().weekday; // 1=Mon, 7=Sun
    final todayIndex = today - 1;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: yMax,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFF1F2937),
            tooltipRoundedRadius: 10,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dayNames = [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday',
              ];
              return BarTooltipItem(
                '${dayNames[group.x]}\n',
                const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: '${steps[group.x]} steps',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < 7 && steps[index] > 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      _formatCompact(steps[index]),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: index == todayIndex
                            ? _greenDark
                            : AppColors.textTertiary,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final index = value.toInt();
                if (index >= 0 && index < 7) {
                  final isToday = index == todayIndex;
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          days[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isToday
                                ? _greenDark
                                : AppColors.textTertiary,
                          ),
                        ),
                        if (isToday)
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: _greenMain,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          drawHorizontalLine: true,
          horizontalInterval: yMax / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border.withValues(alpha: 0.25),
            strokeWidth: 1,
            dashArray: [6, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (index) {
          final isToday = index == todayIndex;
          final stepVal = steps[index].toDouble();

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: stepVal > 0 ? stepVal : yMax * 0.02,
                width: 28,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
                gradient: LinearGradient(
                  colors: stepVal > 0
                      ? (isToday
                            ? [_greenLight, _greenDark]
                            : [_greenLight, _greenMain])
                      : [
                          AppColors.border.withValues(alpha: 0.3),
                          AppColors.border.withValues(alpha: 0.2),
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: yMax,
                  color: _greenVeryLight.withValues(alpha: 0.25),
                ),
              ),
            ],
          );
        }),
      ),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _greenVeryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              size: 32,
              color: _greenMain.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No activity data yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Connect Health to track your steps',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  String _formatCompact(int number) {
    if (number >= 1000) {
      final k = number / 1000;
      return k >= 10 ? '${k.toInt()}k' : '${k.toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  // Referenced in summary row
  static const Color _greenGlow = _greenMain;
}
