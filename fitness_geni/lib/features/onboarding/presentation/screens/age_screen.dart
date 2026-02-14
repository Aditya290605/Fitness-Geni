import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wheel_picker/wheel_picker.dart';

/// Age input screen - White theme with primaryGreen accents
class AgeScreen extends StatefulWidget {
  final int? initialAge;
  final Function(int) onAgeSelected;
  final VoidCallback? onBack;

  const AgeScreen({
    super.key,
    this.initialAge,
    required this.onAgeSelected,
    this.onBack,
  });

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  late int _currentAge;

  // Theme colors
  static const Color primaryGreen = Color(0xFF3D6B4A);
  static const Color lightGreenBg = Color(0xFFEDF5F0);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color cardBorder = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _currentAge = widget.initialAge ?? 25;
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
              child: const Icon(
                Icons.cake_outlined,
                size: 56,
                color: primaryGreen,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Title
          const Text(
            'Your Age',
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
            "We'll tailor recommendations to your stage",
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
                      'years',
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
                        final age = 10 + index;
                        final isSelected = age == _currentAge;

                        return Center(
                          child: Text(
                            '$age',
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
                      itemCount: 81,
                      initialIndex: _currentAge - 10,
                      onIndexChanged: (index, type) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _currentAge = 10 + index;
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

          const Center(
            child: Text(
              'Age helps us optimize your fitness plan',
              style: TextStyle(
                fontSize: 13,
                color: textGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 20),

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
                child: _buildPrimaryButton(
                  label: 'Continue',
                  onPressed: () => widget.onAgeSelected(_currentAge),
                ),
              ),
            ],
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
          color: lightGreenBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryGreen.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryGreen.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}
