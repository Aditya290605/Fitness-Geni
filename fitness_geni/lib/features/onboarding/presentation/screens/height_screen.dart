import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';

/// Premium height input screen - Feet and Inches
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

  @override
  void initState() {
    super.initState();

    // Convert cm to feet and inches
    final heightInCm = widget.initialHeight ?? 170.0;
    final totalInches = (heightInCm / 2.54).round();
    _currentFeet = totalInches ~/ 12;
    _currentInches = totalInches % 12;

    // Ensure valid range (4'0" to 7'11")
    if (_currentFeet < 4) _currentFeet = 5;
    if (_currentFeet > 7) _currentFeet = 5;
  }

  double _getHeightInCm() {
    // Convert feet and inches to cm
    final totalInches = (_currentFeet * 12) + _currentInches;
    return totalInches * 2.54;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.height, size: 56, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'What\'s your height?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Scroll to select your height',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Dual Wheel Pickers - Feet and Inches
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Feet Picker
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'feet',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Expanded(
                              child: WheelPicker(
                                builder: (context, index) {
                                  final feet = 4 + index; // 4 to 7 feet
                                  final isSelected = feet == _currentFeet;

                                  return Center(
                                    child: Text(
                                      '$feet',
                                      style: TextStyle(
                                        fontSize: isSelected ? 42 : 24,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary
                                                  .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: 4, // 4, 5, 6, 7
                                initialIndex: _currentFeet - 4,
                                onIndexChanged: (index, type) {
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
                        color: AppColors.border.withValues(alpha: 0.3),
                      ),

                      // Inches Picker
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'inches',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Expanded(
                              child: WheelPicker(
                                builder: (context, index) {
                                  final inches = index; // 0 to 11
                                  final isSelected = inches == _currentInches;

                                  return Center(
                                    child: Text(
                                      '$inches',
                                      style: TextStyle(
                                        fontSize: isSelected ? 42 : 24,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary
                                                  .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: 12, // 0 to 11
                                initialIndex: _currentInches,
                                onIndexChanged: (index, type) {
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

              const SizedBox(height: 16),

              // Current height in cm (small display)
              Text(
                '≈ ${_getHeightInCm().round()} cm',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Navigation buttons
              Row(
                children: [
                  if (widget.onBack != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onBack,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppColors.border, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Previous',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: CustomButton(
                      text: 'Continue',
                      onPressed: () =>
                          widget.onHeightSelected(_getHeightInCm()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
