import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/services/onboarding_service.dart';
import 'weight_screen.dart';
import 'height_screen.dart';
import 'gender_screen.dart';
import 'diet_type_screen.dart';
import 'fitness_goal_screen.dart';

/// Main onboarding screen - Clean and simple
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingService _onboardingService = OnboardingService();

  int _currentPage = 0;
  double? _weight;
  double? _height;
  String? _gender;
  String? _dietType;
  String? _fitnessGoal;

  @override
  void initState() {
    super.initState();
    debugPrint('🎯 OnboardingScreen initialized');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      debugPrint('➡️ Moving to page ${_currentPage + 1}');
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    debugPrint('🎉 Completing onboarding...');
    debugPrint('Weight: $_weight, Height: $_height, Gender: $_gender');
    debugPrint('Diet: $_dietType, Goal: $_fitnessGoal');

    if (_weight == null ||
        _height == null ||
        _gender == null ||
        _dietType == null ||
        _fitnessGoal == null) {
      debugPrint('❌ Missing data, cannot complete onboarding');
      return;
    }

    final profile = UserProfile(
      weight: _weight!,
      height: _height!,
      gender: _gender!,
      dietType: _dietType!,
      fitnessGoal: _fitnessGoal!,
    );

    debugPrint('💾 Saving profile...');
    final success = await _onboardingService.saveUserProfile(profile);

    if (success && mounted) {
      debugPrint('✅ Profile saved, navigating to main app');
      context.go(AppConstants.routeMain);
    } else {
      debugPrint('❌ Failed to save profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 OnboardingScreen building, currentPage: $_currentPage');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Progress indicator
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Step ${_currentPage + 1} of 5',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 5,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
                debugPrint('📄 Page changed to: $page');
              },
              children: [
                // Step 1: Weight
                WeightScreen(
                  initialWeight: _weight,
                  onWeightSelected: (weight) {
                    debugPrint('⚖️ Weight selected: $weight kg');
                    setState(() {
                      _weight = weight;
                    });
                    _nextPage();
                  },
                ),

                // Step 2: Height
                HeightScreen(
                  initialHeight: _height,
                  onHeightSelected: (height) {
                    debugPrint('📏 Height selected: $height cm');
                    setState(() {
                      _height = height;
                    });
                    _nextPage();
                  },
                ),

                // Step 3: Gender
                GenderScreen(
                  initialGender: _gender,
                  onGenderSelected: (gender) {
                    debugPrint('👤 Gender selected: $gender');
                    setState(() {
                      _gender = gender;
                    });
                    _nextPage();
                  },
                ),

                // Step 4: Diet Type
                DietTypeScreen(
                  initialDietType: _dietType,
                  onDietTypeSelected: (dietType) {
                    debugPrint('🥗 Diet type selected: $dietType');
                    setState(() {
                      _dietType = dietType;
                    });
                    _nextPage();
                  },
                ),

                // Step 5: Fitness Goal
                FitnessGoalScreen(
                  initialGoal: _fitnessGoal,
                  onGoalSelected: (goal) {
                    debugPrint('🎯 Goal selected: $goal');
                    setState(() {
                      _fitnessGoal = goal;
                    });
                    _completeOnboarding();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
