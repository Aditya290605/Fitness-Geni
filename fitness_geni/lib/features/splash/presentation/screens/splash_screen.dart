import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/meal_notification_service.dart';
import '../../../home/presentation/providers/meal_provider.dart';

/// Premium Splash Screen - Green theme matching auth screens
///
/// This screen handles session restoration and navigates based on auth state:
/// - Authenticated + onboarding complete → Main app
/// - Authenticated + no onboarding → Onboarding screen
/// - Unauthenticated → Login screen
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Premium Color Palette
  static const Color primaryGreen = Color(0xFF3D6B4A);
  static const Color darkGreen = Color(0xFF2D5239);

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
    _restoreSessionAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _restoreSessionAndNavigate() async {
    // Show splash for at least 2 seconds for branding
    final minSplashDuration = Future.delayed(
      const Duration(milliseconds: 2000),
    );

    // Attempt to restore existing session
    final authService = ref.read(authServiceProvider);
    final authState = await authService.restoreSession();

    // Wait for minimum splash duration
    await minSplashDuration;

    if (!mounted) return;

    // Navigate based on restored auth state
    authState.map(
      loading: (_) {
        // Shouldn't happen, but fallback to login
        context.go(AppConstants.routeLogin);
      },
      authenticated: (authenticated) {
        // Check if onboarding is complete
        final hasCompletedOnboarding = authenticated.profile?.goal != null;
        if (hasCompletedOnboarding) {
          debugPrint('✅ Session restored - navigating to main app');

          // Trigger daily notification reset check in background
          _triggerNotificationCheck();

          context.go(AppConstants.routeMain);
        } else {
          debugPrint('✅ Session restored - needs onboarding');
          context.go(AppConstants.routeOnboarding);
        }
      },
      unauthenticated: (_) {
        debugPrint('ℹ️ No session - navigating to login');
        context.go(AppConstants.routeLogin);
      },
    );
  }

  /// Check if daily notification reset is needed and trigger evaluation.
  /// Runs in background — does not block navigation.
  void _triggerNotificationCheck() {
    final notifService = MealNotificationService.instance;
    notifService
        .checkDailyResetNeeded()
        .then((needsReset) {
          if (needsReset) {
            debugPrint(
              '🔔 Splash: Daily reset needed, loading meals for evaluation',
            );
            // Load meals and evaluate — the meal provider will call evaluateAndSchedule
            ref.read(mealProvider.notifier).loadMeals(force: true);
          }
        })
        .catchError((e) {
          debugPrint('⚠️ Splash: Notification check failed: $e');
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryGreen, darkGreen],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Icon
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/logo/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // App Name
                        const Text(
                          'Fitness Geni',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tagline
                        Text(
                          'Your AI Nutrition Partner',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Loading indicator
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
