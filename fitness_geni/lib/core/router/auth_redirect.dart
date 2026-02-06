import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../constants/app_constants.dart';

/// Auth-aware redirect logic for GoRouter
///
/// Determines where users should be redirected based on:
/// - Authentication status (logged in or not)
/// - Onboarding completion (has profile data or not)
/// - Current route attempting to access
String? authRedirect(BuildContext context, GoRouterState state, WidgetRef ref) {
  // Read current auth state
  final isAuthenticated = ref.read(isAuthenticatedProvider);
  final currentProfile = ref.read(currentProfileProvider);

  // Determine what route user is trying to access
  final isGoingToSplash = state.matchedLocation == AppConstants.routeSplash;
  final isGoingToLogin = state.matchedLocation == AppConstants.routeLogin;
  final isGoingToSignup = state.matchedLocation == AppConstants.routeSignup;
  final isGoingToOnboarding =
      state.matchedLocation == AppConstants.routeOnboarding;
  final isGoingToMain = state.matchedLocation == AppConstants.routeMain;

  // Allow splash screen for everyone (brief loading screen)
  if (isGoingToSplash) {
    return null;
  }

  // ========================================
  // UNAUTHENTICATED USERS
  // ========================================
  if (!isAuthenticated) {
    // Allow access to login and signup screens only
    if (isGoingToLogin || isGoingToSignup) {
      return null; // No redirect needed
    }

    // Redirect to login for any other route
    return AppConstants.routeLogin;
  }

  // ========================================
  // AUTHENTICATED USERS
  // ========================================

  // Check if onboarding is complete (profile has goal field populated)
  final hasCompletedOnboarding = currentProfile?.goal != null;

  if (!hasCompletedOnboarding) {
    // User is authenticated but hasn't completed onboarding

    // If trying to access main app, redirect to onboarding
    if (isGoingToMain) {
      return AppConstants.routeOnboarding;
    }

    // If trying to access login/signup, redirect to onboarding
    if (isGoingToLogin || isGoingToSignup) {
      return AppConstants.routeOnboarding;
    }

    // Allow onboarding screen
    return null;
  }

  // User is authenticated AND has completed onboarding

  // Don't allow access to auth screens
  if (isGoingToLogin || isGoingToSignup || isGoingToOnboarding) {
    return AppConstants.routeMain;
  }

  // Allow access to main app
  return null; // No redirect needed
}
