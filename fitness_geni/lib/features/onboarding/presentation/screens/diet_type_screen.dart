import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/selection_card.dart';
import '../../../../core/widgets/custom_button.dart';

/// Diet preference selection screen - Premium UI
class DietTypeScreen extends StatefulWidget {
  final String? initialDietType;
  final Function(String) onDietTypeSelected;

  const DietTypeScreen({
    super.key,
    this.initialDietType,
    required this.onDietTypeSelected,
  });

  @override
  State<DietTypeScreen> createState() => _DietTypeScreenState();
}

class _DietTypeScreenState extends State<DietTypeScreen> {
  String? _selectedDiet;

  @override
  void initState() {
    super.initState();
    _selectedDiet = widget.initialDietType;
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
                    Icons.restaurant_menu,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'What\'s your diet preference?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'We\'ll recommend meals based on your preference',
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
                      icon: Icons.eco,
                      title: 'Vegetarian',
                      subtitle: 'Plant-based diet with eggs & dairy',
                      isSelected: _selectedDiet == 'Vegetarian',
                      onTap: () {
                        setState(() {
                          _selectedDiet = 'Vegetarian';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SelectionCard(
                      icon: Icons.restaurant,
                      title: 'Non-Vegetarian',
                      subtitle: 'Includes meat, fish & plant-based foods',
                      isSelected: _selectedDiet == 'Non-Vegetarian',
                      onTap: () {
                        setState(() {
                          _selectedDiet = 'Non-Vegetarian';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SelectionCard(
                      icon: Icons.spa,
                      title: 'Vegan',
                      subtitle: 'Strictly plant-based diet',
                      isSelected: _selectedDiet == 'Vegan',
                      onTap: () {
                        setState(() {
                          _selectedDiet = 'Vegan';
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              CustomButton(
                text: 'Continue',
                onPressed: _selectedDiet != null
                    ? () => widget.onDietTypeSelected(_selectedDiet!)
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
