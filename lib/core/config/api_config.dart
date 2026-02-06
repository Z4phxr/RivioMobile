import 'package:habit_tracker/core/config/env_config.dart';

/// Centralized API configuration for all HTTP requests
/// Supports development and production environments
class ApiConfig {
  // API Version - Update this when backend API version changes
  static const String apiVersion = '/api/v1';

  /// Get base URL (delegates to EnvironmentConfig for environment detection)
  /// Returns either http://localhost:8000 (dev) or https://rivio.up.railway.app (prod)
  static String get baseUrl => EnvironmentConfig.baseUrl;

  /// Full API base URL with version
  /// Uses EnvironmentConfig to determine the correct base URL
  static String get apiBaseUrl => '${EnvironmentConfig.baseUrl}$apiVersion';

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Common headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Authentication endpoints
  static const String authLogin = '/auth/login/';
  static const String authRegister = '/auth/register/';
  static const String authLogout = '/auth/logout/';
  static const String authRefresh = '/auth/refresh/';
  static const String authVerify = '/auth/verify/';
  static const String authDeleteAccount = '/auth/delete-account/';

  // Habit endpoints
  static const String habits = '/habits/';
  static const String habitsAdd = '/habits/add_habit/';
  static const String habitsToggle = '/habits/toggle/';
  static String habitsUpdate(int id) => '/habits/update/$id/';
  static String habitsDelete(int id) => '/habits/delete/$id/';
  static String habitsArchive(int id) => '/habits/archive/$id/';

  // Sleep endpoints
  static const String sleep = '/sleep/';
  static const String sleepList = '/sleep/list/';
  static const String sleepDeleteDay = '/sleep/delete_day/';

  // Mood endpoints
  static const String mood = '/mood/';
  static const String moodList = '/mood/list/';
  static const String moodDeleteDay = '/mood/delete_day/';
  static const String moodTrackDay = '/track/mood/day/';
  static const String moodTrackWeek = '/track/mood/week/';
  static const String moodTrackMonth = '/track/mood/month/';

  // Sleep track endpoints
  static const String sleepTrackDay = '/track/sleep/day/';
  static const String sleepTrackWeek = '/track/sleep/week/';
  static const String sleepTrackMonth = '/track/sleep/month/';

  // Helper methods to build full URLs
  static String getFullUrl(String endpoint) => '$apiBaseUrl$endpoint';

  /// Build URL with query parameters
  static String buildUrlWithQuery(
    String endpoint,
    Map<String, String>? queryParams,
  ) {
    final fullUrl = getFullUrl(endpoint);
    if (queryParams == null || queryParams.isEmpty) {
      return fullUrl;
    }

    final uri = Uri.parse(fullUrl);
    final newUri = uri.replace(queryParameters: queryParams);
    return newUri.toString();
  }

  // Environment helpers
  static bool get isDevelopment => EnvironmentConfig.isDevelopment;
  static bool get isProduction => EnvironmentConfig.isProduction;

  // Logging configuration
  static bool get enableLogging => EnvironmentConfig.enableLogging;
}
