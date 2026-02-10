import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wheel_picker/wheel_picker.dart';

/// Premium height input screen - Dark emerald green with glassmorphism
class HeightScreen extends StatefulWidget {
  final double? initialHeight;
  final Function(double) onHeightSelected;
  final VoidCallback? onBack;

  const HeightScreen({
    super.key,
    this.initialHeight,
    required this.onHeightSelected,
    this.onBack,
  });

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen>
    with SingleTickerProviderStateMixin {
  late int _currentFeet;
  late int _currentInches;
  late AnimationController _glowController;

  // Theme colors
  static const Color accentGreen = Color(0xFF4ADE80);
  static const Color accentGreenDark = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    final heightInCm = widget.initialHeight ?? 170.0;
    final totalInches = (heightInCm / 2.54).round();
    _currentFeet = totalInches ~/ 12;
    _currentInches = totalInches % 12;
    if (_currentFeet < 4) _currentFeet = 5;
    if (_currentFeet > 7) _currentFeet = 5;

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

  double _getHeightInCm() {
    final totalInches = (_currentFeet * 12) + _currentInches;
    return totalInches * 2.54;
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
                    'assets/images/height.png',
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
            'How Tall Are You?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'Helps calculate your ideal metrics',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.6),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Glassmorphism dual wheel picker card
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
                  child: Row(
                    children: [
                      // Feet Picker
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: accentGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'feet',
                                style: TextStyle(
                                  color: accentGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: WheelPicker(
                                builder: (context, index) {
                                  final feet = 4 + index;
                                  final isSelected = feet == _currentFeet;
                                  return Center(
                                    child: Text(
                                      '$feet',
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
                                                  color: accentGreen
                                                      .withOpacity(0.5),
                                                  blurRadius: 16,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                itemCount: 4,
                                initialIndex: _currentFeet - 4,
                                onIndexChanged: (index, type) {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _currentFeet = 4 + index;
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

                      // Divider
                      Container(
                        width: 1,
                        height: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 40),
                        color: Colors.white.withOpacity(0.1),
                      ),

                      // Inches Picker
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: accentGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'inches',
                                style: TextStyle(
                                  color: accentGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: WheelPicker(
                                builder: (context, index) {
                                  final inches = index;
                                  final isSelected = inches == _currentInches;
                                  return Center(
                                    child: Text(
                                      '$inches',
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
                                                  color: accentGreen
                                                      .withOpacity(0.5),
                                                  blurRadius: 16,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                itemCount: 12,
                                initialIndex: _currentInches,
                                onIndexChanged: (index, type) {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _currentInches = index;
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
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Height in cm
          Center(
            child: Text(
              '≈ ${_getHeightInCm().round()} cm',
              style: TextStyle(
                fontSize: 14,
                color: accentGreen.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Button Row
          Row(
            children: [
              if (widget.onBack != null) ...[
                Expanded(
                  child: _buildOutlineButton(
                    label: 'Previous',
                    onPressed: widget.onBack!,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: _buildGreenButton(
                  label: 'Continue',
                  onPressed: () => widget.onHeightSelected(_getHeightInCm()),
                ),
              ),
            ],
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

  Widget _buildOutlineButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}
