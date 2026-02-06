import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
import 'auth_state.dart';

/// Provider for AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Stream provider for authentication state
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateStream;
});

/// Provider for current user (computed from auth state)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.maybeWhen(
    data: (state) => state.maybeMap(
      authenticated: (authState) => authState.user,
      orElse: () => null,
    ),
    orElse: () => null,
  );
});

/// Provider for current user profile (computed from auth state)
final currentProfileProvider = Provider<Profile?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.maybeWhen(
    data: (state) => state.maybeMap(
      authenticated: (authState) => authState.profile,
      orElse: () => null,
    ),
    orElse: () => null,
  );
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.maybeWhen(
    data: (state) =>
        state.maybeMap(authenticated: (_) => true, orElse: () => false),
    orElse: () => false,
  );
});
