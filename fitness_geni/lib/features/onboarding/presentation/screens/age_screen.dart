import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';

/// Premium age input screen with wheel picker
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

  @override
  void initState() {
    super.initState();
    _currentAge = widget.initialAge ?? 25;
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
                    Icons.cake_outlined,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'How old are you?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Scroll to select your age',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Wheel Picker - Main focus
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
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Unit label
                      Text(
                        'years',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
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
                                  fontSize: isSelected ? 42 : 24,
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
                          itemCount: 81, // 10 to 90 years
                          initialIndex: _currentAge - 10,
                          onIndexChanged: (index, type) {
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

              const SizedBox(height: 32),

              CustomButton(
                text: 'Continue',
                onPressed: () => widget.onAgeSelected(_currentAge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
