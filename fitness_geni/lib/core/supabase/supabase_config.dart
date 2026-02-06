import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration loaded from environment variables
class SupabaseConfig {
  SupabaseConfig._();

  static String? _supabaseUrl;
  static String? _supabaseAnonKey;

  /// Initialize configuration by loading from .env file
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    
    _supabaseUrl = dotenv.env['SUPABASE_URL'];
    _supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    _validateConfig();
  }

  /// Get Supabase project URL
  static String get supabaseUrl {
    if (_supabaseUrl == null) {
      throw Exception(
        'Supabase URL not configured. Make sure .env file exists and contains SUPABASE_URL.',
      );
    }
    return _supabaseUrl!;
  }

  /// Get Supabase anon public key
  static String get supabaseAnonKey {
    if (_supabaseAnonKey == null) {
      throw Exception(
        'Supabase Anon Key not configured. Make sure .env file exists and contains SUPABASE_ANON_KEY.',
      );
    }
    return _supabaseAnonKey!;
  }

  /// Validate that all required configuration values are present
  static void _validateConfig() {
    if (_supabaseUrl == null || _supabaseUrl!.isEmpty) {
      throw Exception(
        'SUPABASE_URL is missing in .env file. Please add your Supabase project URL.',
      );
    }

    if (_supabaseAnonKey == null || _supabaseAnonKey!.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY is missing in .env file. Please add your Supabase anon key.',
      );
    }

    // Basic URL validation
    if (!_supabaseUrl!.startsWith('https://') || !_supabaseUrl!.contains('.supabase.co')) {
      throw Exception(
        'Invalid SUPABASE_URL format. Expected format: https://xxxxx.supabase.co',
      );
    }

    // Basic JWT validation (should start with 'eyJ')
    if (!_supabaseAnonKey!.startsWith('eyJ')) {
      throw Exception(
        'Invalid SUPABASE_ANON_KEY format. The anon key should be a JWT token starting with "eyJ".',
      );
    }
  }
}
