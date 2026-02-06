import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application environment enum
enum AppEnvironment {
  development,
  production,
}

/// Environment configuration service
/// Handles environment detection and provides easy access to environment-specific values
class EnvironmentConfig {
  static const String _developmentEnvName = 'development';
  static const String _productionEnvName = 'production';

  // Base URLs - change these if your backend URL changes
  static const String developmentBaseUrl = 'http://localhost:8000';
  static const String productionBaseUrl = 'https://rivio.up.railway.app';

  /// Get the current environment
  /// Priority:
  /// 1. Environment variable passed at compile time (e.g., --dart-define=ENV=prod)
  /// 2. Value from .env file
  /// 3. Default to development
  static AppEnvironment get currentEnvironment {
    // Try compile-time environment variable first
    const env = String.fromEnvironment('ENV', defaultValue: '');
    if (env.isNotEmpty) {
      return _parseEnvironment(env);
    }

    // Try .env file
    final envFromFile = dotenv.maybeGet('ENV');
    if (envFromFile != null && envFromFile.isNotEmpty) {
      return _parseEnvironment(envFromFile);
    }

    // Default to development
    return AppEnvironment.development;
  }

  /// Parse environment string to AppEnvironment enum
  static AppEnvironment _parseEnvironment(String env) {
    switch (env.toLowerCase().trim()) {
      case _productionEnvName:
      case 'prod':
      case 'release':
        return AppEnvironment.production;
      case _developmentEnvName:
      case 'dev':
      case 'debug':
      default:
        return AppEnvironment.development;
    }
  }

  /// Get base URL for current environment
  static String get baseUrl {
    // Try to load from .env file first (useful for dynamic configuration)
    final envBaseUrl = dotenv.maybeGet('API_BASE_URL');
    if (envBaseUrl != null && envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }

    // Fallback to hardcoded URLs based on environment
    return currentEnvironment == AppEnvironment.production
        ? productionBaseUrl
        : developmentBaseUrl;
  }

  /// Check if current environment is development
  static bool get isDevelopment =>
      currentEnvironment == AppEnvironment.development;

  /// Check if current environment is production
  static bool get isProduction =>
      currentEnvironment == AppEnvironment.production;

  /// Get logging enabled flag
  static bool get enableLogging {
    final enableLoggingStr = dotenv.maybeGet('ENABLE_LOGGING');
    if (enableLoggingStr != null) {
      return enableLoggingStr.toLowerCase() == 'true';
    }
    return isDevelopment;
  }

  /// Get a string representation of the current environment
  static String get environmentName {
    return isProduction ? 'Production' : 'Development';
  }

  /// Debug info for logging
  static String get debugInfo {
    return '''
╔════════════════════════════════════════╗
║     Environment Configuration         ║
╠════════════════════════════════════════╣
║ Environment: $environmentName
║ Base URL: ${baseUrl}
║ Logging: ${enableLogging}
╚════════════════════════════════════════╝
''';
  }
}
