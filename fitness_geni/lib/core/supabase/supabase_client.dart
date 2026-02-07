import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Global Supabase client instance
late final SupabaseClient supabase;

/// Initialize Supabase client with configuration
Future<void> initializeSupabase() async {
  try {
    // Initialize config
    await SupabaseConfig.initialize();

    // Initialize Supabase with auth persistence
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce, // More secure auth flow
        autoRefreshToken: true, // Auto-refresh expired tokens
      ),
    );

    // Set global client instance
    supabase = Supabase.instance.client;

    debugPrint('✅ Supabase initialized with auth persistence');
  } catch (e) {
    debugPrint('❌ Failed to initialize Supabase: $e');
    throw Exception('Supabase initialization failed');
  }
}
