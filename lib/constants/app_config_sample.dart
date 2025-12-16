/// App Configuration - Store sensitive data here
/// 
/// IMPORTANT: 
/// 1. Do NOT commit this file with real API keys to version control
/// 2. Add this file to .gitignore
/// 3. Create a template file (app_config.example.dart) for team members
/// 
/// For production, use environment variables:
/// flutter build apk --dart-define=API_KEY=your_key --dart-define=BASE_URL=your_url

class AppConfig {
  // Backend API URL
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'API URL HERE',
  );

  // Google Gemini AI API Key
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_GEMINI_API_KEY_HERE',
  );

  // App version
  static const String appVersion = '1.0.0';

  // Environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // Debug mode
  static bool get isDebug => environment == 'development';
  static bool get isProduction => environment == 'production';

  // API timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Validate configuration
  static void validate() {
    if (geminiApiKey.isEmpty || geminiApiKey == 'your_gemini_api_key_here') {
      throw Exception('⚠️ GEMINI_API_KEY chưa được cấu hình!');
    }

    if (baseUrl.isEmpty) {
      throw Exception('⚠️ BASE_URL chưa được cấu hình!');
    }
  }
}
