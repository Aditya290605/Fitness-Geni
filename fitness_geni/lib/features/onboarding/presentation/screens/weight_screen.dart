import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';

/// Premium weight input screen with wheel picker
class WeightScreen extends StatefulWidget {
  final double? initialWeight;
  final Function(double) onWeightSelected;

  const WeightScreen({
    super.key,
    this.initialWeight,
    required this.onWeightSelected,
  });

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  late int _currentWeight;

  @override
  void initState() {
    super.initState();
    _currentWeight = (widget.initialWeight ?? 70.0).round();
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
                  child: Icon(
                    Icons.monitor_weight_outlined,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'What\'s your current weight?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'This helps us create a personalized plan',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Weight display
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
                      _currentWeight.toString(),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'kg',
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
                      final weight = 30 + index;
                      final isSelected = weight == _currentWeight;

                      return Center(
                        child: Text(
                          '$weight',
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
                    itemCount: 171, // 30 to 200 kg
                    initialIndex: _currentWeight - 30,
                    onIndexChanged: (index, type) {
                      setState(() {
                        _currentWeight = 30 + index;
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
                    widget.onWeightSelected(_currentWeight.toDouble()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
