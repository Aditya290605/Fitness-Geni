import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/selection_card.dart';
import '../../../../core/widgets/custom_button.dart';

/// Fitness goal selection screen - Premium UI
class FitnessGoalScreen extends StatefulWidget {
  final String? initialGoal;
  final Function(String) onGoalSelected;

  const FitnessGoalScreen({
    super.key,
    this.initialGoal,
    required this.onGoalSelected,
  });

  @override
  State<FitnessGoalScreen> createState() => _FitnessGoalScreenState();
}

class _FitnessGoalScreenState extends State<FitnessGoalScreen> {
  String? _selectedGoal;

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.initialGoal;
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
              const SizedBox(height: 16),

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
                    Icons.emoji_events,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'What\'s your fitness goal?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'We\'ll create a plan to help you achieve it',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Options
              Expanded(
                child: ListView(
                  children: [
                    SelectionCard(
                      icon: Icons.trending_down,
                      title: 'Lose Weight',
                      subtitle: 'Reduce body fat and get leaner',
                      isSelected: _selectedGoal == 'Lose Weight',
                      onTap: () {
                        setState(() {
                          _selectedGoal = 'Lose Weight';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SelectionCard(
                      icon: Icons.fitness_center,
                      title: 'Build Muscle',
                      subtitle: 'Gain strength and muscle mass',
                      isSelected: _selectedGoal == 'Build Muscle',
                      onTap: () {
                        setState(() {
                          _selectedGoal = 'Build Muscle';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SelectionCard(
                      icon: Icons.balance,
                      title: 'Stay Fit',
                      subtitle: 'Maintain current fitness level',
                      isSelected: _selectedGoal == 'Stay Fit',
                      onTap: () {
                        setState(() {
                          _selectedGoal = 'Stay Fit';
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              CustomButton(
                text: 'Get Started',
                onPressed: _selectedGoal != null
                    ? () => widget.onGoalSelected(_selectedGoal!)
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
