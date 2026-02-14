import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wheel_picker/wheel_picker.dart';

/// Height input screen - White theme with primaryGreen accents
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

class _HeightScreenState extends State<HeightScreen> {
  late int _currentFeet;
  late int _currentInches;

  // Theme colors
  static const Color primaryGreen = Color(0xFF3D6B4A);
  static const Color lightGreenBg = Color(0xFFEDF5F0);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color cardBorder = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    final heightInCm = widget.initialHeight ?? 170.0;
    final totalInches = (heightInCm / 2.54).round();
    _currentFeet = totalInches ~/ 12;
    _currentInches = totalInches % 12;
    if (_currentFeet < 4) _currentFeet = 5;
    if (_currentFeet > 7) _currentFeet = 5;
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
                'assets/images/height.png',
                width: 56,
                height: 56,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Title
          const Text(
            'How Tall Are You?',
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
            'Helps calculate your ideal metrics',
            style: TextStyle(fontSize: 15, color: textGrey, height: 1.4),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Dual wheel picker card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: lightGreenBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cardBorder),
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
                            color: primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'feet',
                            style: TextStyle(
                              color: primaryGreen,
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
                                        ? primaryGreen
                                        : textGrey.withOpacity(0.4),
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
                    color: cardBorder,
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
                            color: primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'inches',
                            style: TextStyle(
                              color: primaryGreen,
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
                                        ? primaryGreen
                                        : textGrey.withOpacity(0.4),
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

          const SizedBox(height: 10),

          // Height in cm
          Center(
            child: Text(
              '≈ ${_getHeightInCm().round()} cm',
              style: TextStyle(
                fontSize: 14,
                color: primaryGreen.withOpacity(0.7),
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
                child: _buildPrimaryButton(
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
