import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/auth/profile_service.dart';
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

  void _previousPage() {
    if (_currentPage > 0) {
      debugPrint('⬅️ Moving to page ${_currentPage - 1}');
      _pageController.previousPage(
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

    // Get current user directly from Supabase (more reliable than stream provider)
    debugPrint('🔍 Checking authentication state...');
    final supabaseUser = Supabase.instance.client.auth.currentUser;

    debugPrint('Supabase user: ${supabaseUser?.email ?? 'NULL'}');

    if (supabaseUser == null) {
      debugPrint('❌ No authenticated user found');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Please log in again'),
            duration: Duration(seconds: 3),
          ),
        );
        // Navigate back to login
        context.go(AppConstants.routeLogin);
      }
      return;
    }

    final profile = UserProfile(
      weight: _weight!,
      height: _height!,
      gender: _gender!,
      dietType: _dietType!,
      fitnessGoal: _fitnessGoal!,
    );

    debugPrint('💾 Saving profile to Supabase for user: ${supabaseUser.id}');

    try {
      // Save to Supabase
      final profileService = ProfileService();
      await profileService.updateProfile(
        userId: supabaseUser.id,
        weightKg: _weight!.toInt(),
        heightCm: _height!.toInt(),
        gender: _gender!,
        dietType: _dietType!,
        goal: _fitnessGoal!,
      );

      // Also save locally for backward compatibility
      await _onboardingService.saveUserProfile(profile);

      if (mounted) {
        debugPrint('✅ Profile saved, navigating to main app');
        context.go(AppConstants.routeMain);
      }
    } catch (e) {
      debugPrint('❌ Failed to save profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: ${e.toString()}')),
        );
      }
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
                  onBack: null, // First page, no back
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
                  onBack: _previousPage,
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
                  onBack: _previousPage,
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
                  onBack: _previousPage,
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
                  onBack: _previousPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
