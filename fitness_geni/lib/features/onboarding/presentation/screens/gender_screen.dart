import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/selection_card.dart';
import '../../../../core/widgets/custom_button.dart';

/// Gender selection screen - Premium UI
class GenderScreen extends StatefulWidget {
  final String? initialGender;
  final Function(String) onGenderSelected;

  const GenderScreen({
    super.key,
    this.initialGender,
    required this.onGenderSelected,
  });

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialGender;
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
              const SizedBox(height: 40),

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
                    Icons.person_outline,
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'What\'s your gender?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'This helps us provide better recommendations',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Options
              SelectionCard(
                icon: Icons.male,
                title: 'Male',
                subtitle: '',
                isSelected: _selectedGender == 'Male',
                onTap: () {
                  setState(() {
                    _selectedGender = 'Male';
                  });
                },
              ),

              const SizedBox(height: 16),

              SelectionCard(
                icon: Icons.female,
                title: 'Female',
                subtitle: '',
                isSelected: _selectedGender == 'Female',
                onTap: () {
                  setState(() {
                    _selectedGender = 'Female';
                  });
                },
              ),

              const SizedBox(height: 16),

              SelectionCard(
                icon: Icons.people,
                title: 'Other',
                subtitle: '',
                isSelected: _selectedGender == 'Other',
                onTap: () {
                  setState(() {
                    _selectedGender = 'Other';
                  });
                },
              ),

              const Spacer(),

              CustomButton(
                text: 'Continue',
                onPressed: _selectedGender != null
                    ? () => widget.onGenderSelected(_selectedGender!)
                    : null,
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
