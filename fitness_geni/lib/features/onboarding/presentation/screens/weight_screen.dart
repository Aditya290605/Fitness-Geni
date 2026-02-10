import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wheel_picker/wheel_picker.dart';

/// Premium weight input screen - Dark emerald green theme with glassmorphism
class WeightScreen extends StatefulWidget {
  final double? initialWeight;
  final Function(double) onWeightSelected;
  final VoidCallback? onBack;

  const WeightScreen({
    super.key,
    this.initialWeight,
    required this.onWeightSelected,
    this.onBack,
  });

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen>
    with SingleTickerProviderStateMixin {
  late int _currentWeight;
  late AnimationController _glowController;

  // Theme colors
  static const Color accentGreen = Color(0xFF4ADE80);
  static const Color accentGreenDark = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    _currentWeight = (widget.initialWeight ?? 70.0).round();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          // Hero image with glassmorphic circle
          Center(
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(
                      color: accentGreen.withOpacity(
                        0.2 + _glowController.value * 0.2,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentGreen.withOpacity(
                          0.15 + _glowController.value * 0.15,
                        ),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/scale.png',
                    width: 56,
                    height: 56,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // Title
          const Text(
            'Your Starting Point',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            "Let's personalize your fitness journey",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.6),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Glassmorphism wheel picker card
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Unit label
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'kg',
                          style: TextStyle(
                            color: accentGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      // Picker
                      Expanded(
                        child: WheelPicker(
                          builder: (context, index) {
                            final weight = 30 + index;
                            final isSelected = weight == _currentWeight;

                            return Center(
                              child: Text(
                                '$weight',
                                style: TextStyle(
                                  fontSize: isSelected ? 48 : 24,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? accentGreen
                                      : Colors.white.withOpacity(0.3),
                                  shadows: isSelected
                                      ? [
                                          Shadow(
                                            color: accentGreen.withOpacity(0.5),
                                            blurRadius: 16,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            );
                          },
                          itemCount: 171,
                          initialIndex: _currentWeight - 30,
                          onIndexChanged: (index, type) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _currentWeight = 30 + index;
                            });
                          },
                          style: WheelPickerStyle(
                            itemExtent: 70,
                            squeeze: 1.1,
                            diameterRatio: 1.5,
                            surroundingOpacity: 0.4,
                            magnification: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Motivational microcopy
          Center(
            child: Text(
              'This helps us tailor workouts just for you',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.45),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Premium green gradient button
          _buildGreenButton(
            label: 'Continue',
            onPressed: () => widget.onWeightSelected(_currentWeight.toDouble()),
          ),
        ],
      ),
    );
  }

  Widget _buildGreenButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [accentGreen, accentGreenDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentGreen.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D1F15),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
