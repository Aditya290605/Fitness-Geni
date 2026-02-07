class GeminiConfig {
  // Gemini API configuration
  static const String apiKey = 'AIzaSyDbKHmio9PQr3IC5FCC1qSGWMr4zhEpwYI';
  static const String model = 'gemini-2.5-flash';

  // Request settings
  static const int maxRetries = 3;
  static const Duration timeout = Duration(seconds: 30);

  // Temperature controls creativity (0.0 - 1.0)
  static const double temperature = 0.7;

  // Top-p controls diversity
  static const double topP = 0.95;
}
