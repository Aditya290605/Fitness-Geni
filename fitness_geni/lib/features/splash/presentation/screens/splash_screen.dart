import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Splash screen - First screen shown on app launch
/// Displays app branding and determines initial navigation route
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  /// Determine navigation based on onboarding status
  /// - If first time: show onboarding
  /// - Otherwise: show login
  Future<void> _navigateToNextScreen() async {
    // Wait 2 seconds for splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if onboarding has been completed
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted =
        prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;

    if (!mounted) return;

    if (onboardingCompleted) {
      // User has seen onboarding, go to login
      context.go(AppConstants.routeLogin);
    } else {
      // First time user, show onboarding
      context.go(AppConstants.routeOnboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryLight.withValues(alpha: 0.3),
              AppColors.primary.withValues(alpha: 0.2),
              AppColors.background,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo (using default icon for now)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // App Name
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // App Tagline
              Text(
                AppConstants.appTagline,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
