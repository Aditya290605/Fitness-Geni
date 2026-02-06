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

  /// Check if session is valid (not expired)
  Future<bool> isSessionValid() async {
    final expiresAtStr = await _storage.read(key: _keyExpiresAt);
    if (expiresAtStr == null) return false;

    final expiresAt = int.tryParse(expiresAtStr);
    if (expiresAt == null) return false;

    // Check if session is expired (with 5 minute buffer)
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return expiresAt > (now + 300);
  }
}
