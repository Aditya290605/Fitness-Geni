import 'dart:math';
import 'package:flutter/material.dart';

/// Semicircular BMI gauge dial with colored segments and a needle pointer
class BmiGaugePainter extends CustomPainter {
  final double bmi;
  final double minBmi;
  final double maxBmi;

  BmiGaugePainter({required this.bmi, this.minBmi = 10, this.maxBmi = 40});

  // Segment colors matching the reference
  static const _segments = [
    _Segment(
      0.0,
      0.30,
      Color(0xFF3B82F6),
      Color(0xFF60A5FA),
    ), // Underweight - Blue
    _Segment(
      0.30,
      0.55,
      Color(0xFF10B981),
      Color(0xFF34D399),
    ), // Normal - Green
    _Segment(
      0.55,
      0.75,
      Color(0xFFF59E0B),
      Color(0xFFFBBF24),
    ), // Overweight - Orange
    _Segment(0.75, 1.0, Color(0xFFEF4444), Color(0xFFF87171)), // Obese - Red
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = size.width * 0.42;
    const startAngle = pi; // 180°
    const sweepAngle = pi; // 180° arc
    const strokeWidth = 18.0;

    // Draw colored arc segments
    for (final seg in _segments) {
      final segStart = startAngle + sweepAngle * seg.startFraction;
      final segSweep = sweepAngle * (seg.endFraction - seg.startFraction);

      final paint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: segStart,
          endAngle: segStart + segSweep,
          colors: [seg.startColor, seg.endColor],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        segStart,
        segSweep,
        false,
        paint,
      );
    }

    // Draw rounded end caps on the arc
    final capPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      0.01,
      false,
      capPaint,
    );

    final capPaintEnd = Paint()
      ..color = const Color(0xFFF87171)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepAngle - 0.01,
      0.01,
      false,
      capPaintEnd,
    );

    // Draw track shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      shadowPaint,
    );

    // Calculate needle angle from BMI
    final clampedBmi = bmi.clamp(minBmi, maxBmi);
    final fraction = (clampedBmi - minBmi) / (maxBmi - minBmi);
    final needleAngle = startAngle + sweepAngle * fraction;

    // Needle: starts from 40% of radius (near center) and reaches to 92% (near arc)
    final needleInner = radius * 0.25;
    final needleOuter = radius - 6;
    final needleStart = Offset(
      center.dx + needleInner * cos(needleAngle),
      center.dy + needleInner * sin(needleAngle),
    );
    final needleTip = Offset(
      center.dx + needleOuter * cos(needleAngle),
      center.dy + needleOuter * sin(needleAngle),
    );

    // Draw needle shadow
    final needleShadow = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawLine(
      Offset(needleStart.dx + 1, needleStart.dy + 2),
      Offset(needleTip.dx + 1, needleTip.dy + 2),
      needleShadow,
    );

    // Draw needle
    final needlePaint = Paint()
      ..color = const Color(0xFF374151)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(needleStart, needleTip, needlePaint);

    // Draw small pivot dot at the needle base
    final pivotPos = Offset(
      center.dx + (needleInner - 4) * cos(needleAngle),
      center.dy + (needleInner - 4) * sin(needleAngle),
    );

    final pivotShadow = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(pivotPos, 6, pivotShadow);

    final pivotOuter = Paint()..color = const Color(0xFF374151);
    canvas.drawCircle(pivotPos, 5, pivotOuter);

    final pivotInner = Paint()..color = Colors.white;
    canvas.drawCircle(pivotPos, 2.5, pivotInner);

    // Draw small tick marks on the arc
    final tickPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= 20; i++) {
      final tickFraction = i / 20;
      final angle = startAngle + sweepAngle * tickFraction;
      final isLong = i % 5 == 0;
      final outerR = radius + strokeWidth / 2 - 2;
      final innerR = outerR - (isLong ? 8 : 5);

      final outerPoint = Offset(
        center.dx + outerR * cos(angle),
        center.dy + outerR * sin(angle),
      );
      final innerPoint = Offset(
        center.dx + innerR * cos(angle),
        center.dy + innerR * sin(angle),
      );

      canvas.drawLine(outerPoint, innerPoint, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BmiGaugePainter oldDelegate) {
    return oldDelegate.bmi != bmi;
  }
}

class _Segment {
  final double startFraction;
  final double endFraction;
  final Color startColor;
  final Color endColor;

  const _Segment(
    this.startFraction,
    this.endFraction,
    this.startColor,
    this.endColor,
  );
}

/// Widget wrapper for the BMI gauge
class BmiGaugeWidget extends StatelessWidget {
  final double bmi;
  final String category;
  final String description;

  const BmiGaugeWidget({
    super.key,
    required this.bmi,
    required this.category,
    this.description = '',
  });

  Color _getCategoryColor() {
    switch (category) {
      case 'Underweight':
        return const Color(0xFF3B82F6);
      case 'Normal':
        return const Color(0xFF10B981);
      case 'Overweight':
        return const Color(0xFFF59E0B);
      case 'Obese':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Text(
            'BMI',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: const Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 8),

          // Gauge — arc only, text is below
          SizedBox(
            height: 130,
            width: double.infinity,
            child: CustomPaint(
              size: const Size(double.infinity, 130),
              painter: BmiGaugePainter(bmi: bmi),
            ),
          ),

          const SizedBox(height: 6),

          // BMI value below the gauge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                bmi.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'kg/m²',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ),

          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9CA3AF),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
