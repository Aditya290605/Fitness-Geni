import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/supabase/supabase_client.dart';
import 'core/router/auth_redirect.dart';
import 'core/services/meal_notification_service.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/get_started/presentation/screens/get_started_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'shared/presentation/main_navigation.dart';

/// Global navigator key for notification tap navigation
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await initializeSupabase();

  // Initialize local notification service (timezone + plugin + permissions)
  await MealNotificationService.instance.initialize();

  // Set notification tap callback → navigate to Home
  onNotificationTapGlobal = () {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go(AppConstants.routeMain);
    }
  };

  runApp(
    // Wrap app with ProviderScope for Riverpod state management
    const ProviderScope(child: FitnessGeniApp()),
  );
}

/// Root application widget with auth-aware routing
class FitnessGeniApp extends ConsumerWidget {
  const FitnessGeniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router provider to get auth-aware routing
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Apply centralized app theme
      theme: AppTheme.lightTheme,

      // Configure routing with auth-aware GoRouter
      routerConfig: router,
    );
  }
}

/// Router provider with auth-aware redirects
///
/// This provider creates a GoRouter that:
/// - Redirects based on authentication status
/// - Protects routes that require authentication
/// - Handles onboarding completion checks
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppConstants.routeSplash,

    // Auth-aware redirect logic
    redirect: (context, state) => authRedirect(context, state, ref),

    routes: [
      // Splash Screen
      GoRoute(
        path: AppConstants.routeSplash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Get Started Screen
      GoRoute(
        path: AppConstants.routeGetStarted,
        builder: (context, state) => const GetStartedScreen(),
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
});
