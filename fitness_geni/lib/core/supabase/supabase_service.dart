import 'package:supabase_flutter/supabase_flutter.dart';

/// Base service class with common error handling for Supabase operations
abstract class SupabaseService {
  /// Parse Supabase errors into user-friendly messages
  String parseError(Object error) {
    if (error is AuthException) {
      return _parseAuthError(error);
    } else if (error is PostgrestException) {
      return _parsePostgrestError(error);
    } else {
      // Generic network or unknown error
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Parse authentication errors
  String _parseAuthError(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      return 'Invalid email or password';
    } else if (message.contains('email not confirmed')) {
      return 'Please confirm your email address';
    } else if (message.contains('user already registered') ||
        message.contains('already exists')) {
      return 'An account with this email already exists';
    } else if (message.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else if (message.contains('session') && message.contains('expired')) {
      return 'Your session has expired. Please login again.';
    } else {
      // Don't expose internal error details
      return 'Authentication failed. Please try again.';
    }
  }

  /// Parse database errors
  String _parsePostgrestError(PostgrestException error) {
    final message = error.message.toLowerCase();

    if (message.contains('duplicate') || message.contains('unique constraint')) {
      return 'This record already exists';
    } else if (message.contains('foreign key')) {
      return 'Invalid reference. Please try again.';
    } else if (message.contains('not found')) {
      return 'Record not found';
    } else {
      // Don't expose internal error details
      return 'Database operation failed. Please try again.';
    }
  }

  /// Check if error is network-related
  bool isNetworkError(Object error) {
    if (error is AuthException) {
      return error.message.toLowerCase().contains('network');
    }
    return false;
  }
}
