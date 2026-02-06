import 'package:flutter/foundation.dart';
import '../supabase/supabase_client.dart';
import '../supabase/supabase_service.dart';
import 'auth_state.dart';
import 'session_manager.dart';

/// Authentication service handling all auth operations
class AuthService extends SupabaseService {
  final SessionManager _sessionManager = SessionManager.instance;

  /// Sign up a new user with email and password
  Future<AuthState> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Create user via Supabase Auth
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      final userId = authResponse.user!.id;

      // 2. Create profile in profiles table
      await supabase.from('profiles').insert({'id': userId, 'name': name});

      // 3. Fetch the created profile
      final profileData = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = Profile.fromJson(profileData);

      // 4. Save session if available
      if (authResponse.session != null) {
        await _sessionManager.saveSession(authResponse.session!);
      }

      // 5. Return authenticated state
      final user = User(id: userId, email: authResponse.user!.email ?? email);

      debugPrint('✅ Signup successful for user: ${user.email}');
      return AuthState.authenticated(user: user, profile: profile);
    } catch (e) {
      debugPrint('❌ Signup error: $e');
      throw Exception(parseError(e));
    }
  }

  /// Login with email and password
  Future<AuthState> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Authenticate via Supabase
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to login');
      }

      final userId = authResponse.user!.id;

      // 2. Fetch user profile
      final profileData = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = Profile.fromJson(profileData);

      // 3. Save session
      if (authResponse.session != null) {
        await _sessionManager.saveSession(authResponse.session!);
      }

      // 4. Return authenticated state
      final user = User(id: userId, email: authResponse.user!.email ?? email);

      debugPrint('✅ Login successful for user: ${user.email}');
      return AuthState.authenticated(user: user, profile: profile);
    } catch (e) {
      debugPrint('❌ Login error: $e');
      throw Exception(parseError(e));
    }
  }

  /// Logout current user
  Future<AuthState> logout() async {
    try {
      // 1. Sign out from Supabase
      await supabase.auth.signOut();

      // 2. Clear local session
      await _sessionManager.clearSession();

      debugPrint('✅ Logout successful');
      return const AuthState.unauthenticated();
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      throw Exception(parseError(e));
    }
  }

  /// Restore session on app launch
  Future<AuthState> restoreSession() async {
    try {
      debugPrint('🔄 Attempting to restore session...');

      // 1. Check if session is valid
      final isValid = await _sessionManager.isSessionValid();
      if (!isValid) {
        debugPrint('❌ No valid session found');
        return const AuthState.unauthenticated();
      }

      // 2. Get current session from Supabase
      final session = supabase.auth.currentSession;
      if (session == null) {
        debugPrint('❌ No active Supabase session');
        await _sessionManager.clearSession();
        return const AuthState.unauthenticated();
      }

      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        debugPrint('❌ No current user');
        await _sessionManager.clearSession();
        return const AuthState.unauthenticated();
      }

      // 3. Fetch user profile
      final profileData = await supabase
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .single();

      final profile = Profile.fromJson(profileData);

      // 4. Return authenticated state
      final user = User(id: currentUser.id, email: currentUser.email ?? '');

      debugPrint('✅ Session restored for user: ${user.email}');
      return AuthState.authenticated(user: user, profile: profile);
    } catch (e) {
      debugPrint('❌ Session restoration error: $e');
      await _sessionManager.clearSession();
      return const AuthState.unauthenticated();
    }
  }

  /// Get current auth state stream
  Stream<AuthState> get authStateStream {
    return supabase.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;

      if (user == null) {
        return const AuthState.unauthenticated();
      }

      try {
        // Fetch profile when auth state changes
        final profileData = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        final profile = Profile.fromJson(profileData);
        final authUser = User(id: user.id, email: user.email ?? '');

        return AuthState.authenticated(user: authUser, profile: profile);
      } catch (e) {
        debugPrint('❌ Error fetching profile in auth stream: $e');
        return const AuthState.unauthenticated();
      }
    });
  }
}
