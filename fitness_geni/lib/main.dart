import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'shared/presentation/main_navigation.dart';

void main() {
  runApp(
    // Wrap app with ProviderScope for Riverpod state management
    const ProviderScope(child: FitnessGeniApp()),
  );
}

/// Root application widget
class FitnessGeniApp extends StatelessWidget {
  const FitnessGeniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Apply centralized app theme
      theme: AppTheme.lightTheme,

      // Configure routing with GoRouter
      routerConfig: _router,
    );
  }
}

/// GoRouter configuration with all app routes
final GoRouter _router = GoRouter(
  initialLocation: AppConstants.routeSplash,
  routes: [
    // Splash Screen
    GoRoute(
      path: AppConstants.routeSplash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Login Screen
    GoRoute(
      path: AppConstants.routeLogin,
      builder: (context, state) => const LoginScreen(),
    ),

    // Signup Screen
    GoRoute(
      path: AppConstants.routeSignup,
      builder: (context, state) => const SignupScreen(),
    ),

    // Onboarding Screen
    GoRoute(
      path: AppConstants.routeOnboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Main App (Bottom Navigation)
    GoRoute(
      path: AppConstants.routeMain,
      builder: (context, state) => const MainNavigation(),
    ),
  ],
);
