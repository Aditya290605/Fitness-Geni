import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages JWT session persistence using secure storage
class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _keyAccessToken = 'supabase_access_token';
  static const String _keyRefreshToken = 'supabase_refresh_token';
  static const String _keyExpiresAt = 'supabase_expires_at';

  /// Save session tokens securely
  Future<void> saveSession(Session session) async {
    try {
      await _storage.write(key: _keyAccessToken, value: session.accessToken);
      await _storage.write(key: _keyRefreshToken, value: session.refreshToken);
      await _storage.write(
        key: _keyExpiresAt,
        value: session.expiresAt?.toString(),
      );
    } catch (e) {
      throw Exception('Failed to save session: $e');
    }
  }

  /// Clear all session data
  Future<void> clearSession() async {
    try {
      await _storage.delete(key: _keyAccessToken);
      await _storage.delete(key: _keyRefreshToken);
      await _storage.delete(key: _keyExpiresAt);
    } catch (e) {
      throw Exception('Failed to clear session: $e');
    }
  }

  /// Check if session is valid, attempting token refresh if expired
  ///
  /// Instead of immediately failing on expired tokens, this tries to
  /// refresh the session via Supabase's built-in refresh mechanism.
  /// This allows sessions to survive long background periods.
  Future<bool> isSessionValid() async {
    // First check: do we have any stored session at all?
    final refreshToken = await _storage.read(key: _keyRefreshToken);
    if (refreshToken == null) {
      debugPrint('❌ SessionManager: No refresh token found');
      return false;
    }

    // Check if the current Supabase session is still active
    final currentSession = Supabase.instance.client.auth.currentSession;
    if (currentSession != null) {
      debugPrint('✅ SessionManager: Active Supabase session found');
      // Update stored tokens with latest values
      await saveSession(currentSession);
      return true;
    }

    // No active session — try refreshing using stored refresh token
    try {
      debugPrint('🔄 SessionManager: Attempting token refresh...');
      final response = await Supabase.instance.client.auth.refreshSession();
      if (response.session != null) {
        debugPrint('✅ SessionManager: Token refresh successful');
        await saveSession(response.session!);
        return true;
      }
    } catch (e) {
      debugPrint('❌ SessionManager: Token refresh failed: $e');
    }

    return false;
  }
}
