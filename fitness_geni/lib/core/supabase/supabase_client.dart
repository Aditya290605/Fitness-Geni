import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Global Supabase client instance
late final SupabaseClient supabase;

/// Initialize Supabase client with configuration
Future<void> initializeSupabase() async {
  try {
    // Ensure SupabaseConfig is initialized if its values are used directly
    // If supabaseUrl and supabaseAnonKey are global or static, this might not be needed here.
    // Assuming they are accessible directly or via SupabaseConfig.
    await SupabaseConfig.initialize(); // Keep this if supabaseUrl/anonKey come from SupabaseConfig

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl, // Use SupabaseConfig values
      anonKey: SupabaseConfig.supabaseAnonKey, // Use SupabaseConfig values
    );

    // Set global client instance
    supabase =
        Supabase.instance.client; // Re-add this line to set the global client

    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('❌ Failed to initialize Supabase: $e');
    throw Exception('Supabase initialization failed');
  }
}
