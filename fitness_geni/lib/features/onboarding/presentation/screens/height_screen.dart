import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';

/// Premium height input screen with wheel picker
class HeightScreen extends StatefulWidget {
  final double? initialHeight;
  final Function(double) onHeightSelected;

  const HeightScreen({
    super.key,
    this.initialHeight,
    required this.onHeightSelected,
  });

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  late int _currentHeight;

  @override
  void initState() {
    super.initState();
    _currentHeight = (widget.initialHeight ?? 170.0).round();
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

              const SizedBox(height: 20),

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
                'We need this to calculate your health metrics',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Height display
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _currentHeight.toString(),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'cm',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Wheel Picker
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
                  child: WheelPicker(
                    builder: (context, index) {
                      final height = 100 + index;
                      final isSelected = height == _currentHeight;

                      return Center(
                        child: Text(
                          '$height',
                          style: TextStyle(
                            fontSize: isSelected ? 28 : 20,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                          ),
                        ),
                      );
                    },
                    itemCount: 151, // 100 to 250 cm
                    initialIndex: _currentHeight - 100,
                    onIndexChanged: (index, type) {
                      setState(() {
                        _currentHeight = 100 + index;
                      });
                    },
                    style: WheelPickerStyle(
                      itemExtent: 60,
                      squeeze: 1.1,
                      diameterRatio: 1.5,
                      surroundingOpacity: 0.4,
                      magnification: 1.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              CustomButton(
                text: 'Continue',
                onPressed: () =>
                    widget.onHeightSelected(_currentHeight.toDouble()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
