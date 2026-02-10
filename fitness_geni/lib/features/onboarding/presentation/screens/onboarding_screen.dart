import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/auth/profile_service.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/services/onboarding_service.dart';
import 'weight_screen.dart';
import 'height_screen.dart';
import 'gender_screen.dart';
import 'diet_type_screen.dart';
import 'fitness_goal_screen.dart';
import 'age_screen.dart';

/// Premium onboarding screen - Dark emerald green theme
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final OnboardingService _onboardingService = OnboardingService();

  // Onboarding colors matching login screen
  static const Color darkGreen = Color(0xFF0D1F15);
  static const Color midGreen = Color(0xFF1A3C2A);
  static const Color accentGreen = Color(0xFF4ADE80);
  static const Color accentGreenDark = Color(0xFF22C55E);

  int _currentPage = 0;
  bool _isSaving = false;
  double? _weight;
  double? _height;
  int? _age;
  String? _gender;
  String? _dietType;
  String? _fitnessGoal;

  late AnimationController _progressGlowController;

  @override
  void initState() {
    super.initState();
    _progressGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    debugPrint('🎯 OnboardingScreen initialized');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressGlowController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      debugPrint('➡️ Moving to page ${_currentPage + 1}');
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      debugPrint('⬅️ Moving to page ${_currentPage - 1}');
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    debugPrint('🎉 Completing onboarding...');
    debugPrint('Weight: $_weight, Height: $_height, Gender: $_gender');
    debugPrint('Diet: $_dietType, Goal: $_fitnessGoal');

    if (_weight == null ||
        _height == null ||
        _age == null ||
        _gender == null ||
        _dietType == null ||
        _fitnessGoal == null) {
      debugPrint('❌ Missing data, cannot complete onboarding');
      return;
    }

    setState(() => _isSaving = true);

    try {
      debugPrint('🔍 Checking authentication state...');
      final supabaseUser = Supabase.instance.client.auth.currentUser;

      debugPrint('Supabase user: ${supabaseUser?.email ?? 'NULL'}');

      if (supabaseUser == null) {
        debugPrint('❌ No authenticated user found');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error: Please log in again'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.go(AppConstants.routeLogin);
        }
        return;
      }

      final profile = UserProfile(
        weight: _weight!,
        height: _height!,
        age: _age!,
        gender: _gender!,
        dietType: _dietType!,
        fitnessGoal: _fitnessGoal!,
      );

      debugPrint('💾 Saving profile to Supabase for user: ${supabaseUser.id}');

      final profileService = ProfileService();
      await profileService.updateProfile(
        userId: supabaseUser.id,
        age: _age!,
        weightKg: _weight!.toInt(),
        heightCm: _height!.toInt(),
        gender: _gender!,
        dietType: _dietType!,
        goal: _fitnessGoal!,
      );

      await _onboardingService.saveUserProfile(profile);

      if (mounted) {
        debugPrint('✅ Profile saved, refreshing auth state...');

        final authService = ref.read(authServiceProvider);
        await authService.refreshProfile();

        await Future.delayed(const Duration(milliseconds: 300));

        debugPrint('✅ Auth state refreshed, navigating to main app');

        if (mounted) {
          context.go(AppConstants.routeMain);
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to save profile: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [midGreen, darkGreen],
            stops: [0.0, 0.6],
          ),
        ),
        child: Column(
          children: [
            // Premium progress indicator
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  children: [
                    // Step text
                    Text(
                      'Step ${_currentPage + 1} of 6',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Glowing progress bar
                    AnimatedBuilder(
                      animation: _progressGlowController,
                      builder: (context, child) {
                        final glowIntensity =
                            0.3 + (_progressGlowController.value * 0.4);
                        return Container(
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: accentGreen.withOpacity(
                                  glowIntensity * ((_currentPage + 1) / 6),
                                ),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: (_currentPage + 1) / 6,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                accentGreen,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        );
                      },
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
                    onBack: null,
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

                  // Step 3: Age
                  AgeScreen(
                    initialAge: _age,
                    onAgeSelected: (age) {
                      debugPrint('🎂 Age selected: $age');
                      setState(() {
                        _age = age;
                      });
                      _nextPage();
                    },
                    onBack: _previousPage,
                  ),

                  // Step 4: Gender
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

                  // Step 5: Diet Type
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

                  // Step 6: Fitness Goal
                  FitnessGoalScreen(
                    initialGoal: _fitnessGoal,
                    isLoading: _isSaving,
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
      ),
    );
  }
}
