import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wheel_picker/wheel_picker.dart';

/// Weight input screen - White theme with primaryGreen accents
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

class _WeightScreenState extends State<WeightScreen> {
  late int _currentWeight;

  // Theme colors
  static const Color primaryGreen = Color(0xFF3D6B4A);
  static const Color lightGreenBg = Color(0xFFEDF5F0);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color cardBorder = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _currentWeight = (widget.initialWeight ?? 70.0).round();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          // Hero icon circle
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lightGreenBg,
                border: Border.all(color: primaryGreen.withOpacity(0.2)),
              ),
              child: Image.asset(
                'assets/images/scale.png',
                width: 56,
                height: 56,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Title
          const Text(
            'Your Starting Point',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textDark,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          const Text(
            "Let's personalize your fitness journey",
            style: TextStyle(fontSize: 15, color: textGrey, height: 1.4),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Wheel picker card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: lightGreenBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cardBorder),
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
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'kg',
                      style: TextStyle(
                        color: primaryGreen,
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
                                  ? primaryGreen
                                  : textGrey.withOpacity(0.4),
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

          const SizedBox(height: 12),

          // Motivational microcopy
          const Center(
            child: Text(
              'This helps us tailor workouts just for you',
              style: TextStyle(
                fontSize: 13,
                color: textGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Continue button
          _buildPrimaryButton(
            label: 'Continue',
            onPressed: () => widget.onWeightSelected(_currentWeight.toDouble()),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: primaryGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
