import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Onboarding screen - Shown only on first app launch
/// Explains what the app does with 3-4 simple screens
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  /// Mark onboarding as completed and navigate to login
  Future<void> _onDone(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingCompleted, true);

    if (context.mounted) {
      context.go(AppConstants.routeLogin);
    }
  }

  /// Skip onboarding and go to login
  void _onSkip(BuildContext context) => _onDone(context);

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        // Page 1: Welcome
        PageViewModel(
          title: 'Welcome to ${AppConstants.appName}',
          body:
              'Simple fitness & diet guidance made for you. No complexity, just results.',
          image: _buildImage(Icons.waving_hand, AppColors.primary),
          decoration: _getPageDecoration(),
        ),

        // Page 2: Made for You
        PageViewModel(
          title: 'Made for Everyday People',
          body:
              'Not just for gym-goers. Designed for everyone who wants to be healthier and feel better.',
          image: _buildImage(Icons.people_alt, AppColors.primaryDark),
          decoration: _getPageDecoration(),
        ),

        // Page 3: Vegetarian Friendly
        PageViewModel(
          title: 'Vegetarian Friendly',
          body:
              'Specially designed with vegetarians in mind. Get personalized guidance that fits your lifestyle.',
          image: _buildImage(Icons.eco, AppColors.success),
          decoration: _getPageDecoration(),
        ),
      ],

      onDone: () => _onDone(context),
      onSkip: () => _onSkip(context),

      showSkipButton: true,
      skip: Text(
        AppConstants.skip,
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
      ),
      next: Icon(Icons.arrow_forward, color: AppColors.primary),
      done: Text(
        AppConstants.getStarted,
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
      ),

      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: AppColors.primary,
        color: AppColors.border,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),

      curve: Curves.easeInOut,
      controlsMargin: const EdgeInsets.all(16),
      globalBackgroundColor: AppColors.background,
    );
  }

  /// Build icon image for onboarding page
  Widget _buildImage(IconData icon, Color color) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Icon(icon, size: 120, color: color),
      ),
    );
  }

  /// Get page decoration for consistent styling
  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      bodyTextStyle: TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      imagePadding: const EdgeInsets.only(top: 80, bottom: 40),
      pageColor: AppColors.background,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 24),
      titlePadding: const EdgeInsets.only(top: 16, bottom: 16),
    );
  }
}
