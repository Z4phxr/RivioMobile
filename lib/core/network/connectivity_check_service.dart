import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:habit_tracker/core/config/api_config.dart';

/// Service for checking backend connectivity
/// Use this to verify the app can reach the API server
class ConnectivityCheckService {
  final Dio _dio;

  ConnectivityCheckService(this._dio);

  /// Performs a lightweight connectivity check to the backend
  /// Returns a ConnectivityCheckResult with status and details
  Future<ConnectivityCheckResult> checkBackendConnectivity() async {
    final startTime = DateTime.now();

    try {
      // Try health endpoint first (most backends have this)
      Response? response;
      String endpoint = '';

      // Try /health/ endpoint
      try {
        endpoint = '/health/';
        response = await _dio.get(
          ApiConfig.getFullUrl(endpoint),
          options: Options(
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            // Skip auth interceptor for health check
            extra: {'skipAuth': true},
          ),
        );
      } catch (e) {
        // If health endpoint doesn't exist, try auth/verify
        endpoint = ApiConfig.authVerify;
        response = await _dio.get(
          ApiConfig.getFullUrl(endpoint),
          options: Options(
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            validateStatus: (status) => status != null && status < 500,
          ),
        );
      }

      final duration = DateTime.now().difference(startTime);

      return ConnectivityCheckResult(
        isConnected: true,
        statusCode: response.statusCode ?? 0,
        baseUrl: ApiConfig.baseUrl,
        apiBaseUrl: ApiConfig.apiBaseUrl,
        endpoint: endpoint,
        responseTime: duration,
        message: 'Backend is reachable',
        environment: ApiConfig.isDevelopment ? 'development' : 'production',
      );
    } on DioException catch (e) {
      final duration = DateTime.now().difference(startTime);

      return ConnectivityCheckResult(
        isConnected: false,
        statusCode: e.response?.statusCode ?? 0,
        baseUrl: ApiConfig.baseUrl,
        apiBaseUrl: ApiConfig.apiBaseUrl,
        endpoint: e.requestOptions.path,
        responseTime: duration,
        message: _getErrorMessage(e),
        errorDetails: e.toString(),
        environment: ApiConfig.isDevelopment ? 'development' : 'production',
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime);

      return ConnectivityCheckResult(
        isConnected: false,
        statusCode: 0,
        baseUrl: ApiConfig.baseUrl,
        apiBaseUrl: ApiConfig.apiBaseUrl,
        endpoint: '',
        responseTime: duration,
        message: 'Unexpected error: ${e.toString()}',
        errorDetails: e.toString(),
        environment: ApiConfig.isDevelopment ? 'development' : 'production',
      );
    }
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout - backend not responding';
      case DioExceptionType.sendTimeout:
        return 'Send timeout - request took too long';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout - response took too long';
      case DioExceptionType.badCertificate:
        return 'SSL certificate error';
      case DioExceptionType.connectionError:
        return 'Connection error - cannot reach backend';
      case DioExceptionType.badResponse:
        return 'Bad response (${e.response?.statusCode ?? "unknown"})';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.unknown:
        return 'Unknown error: ${e.message}';
    }
  }

  /// Logs the connectivity check result in debug mode
  /// Safe to call from app startup or debug screens
  static void logConnectivityResult(ConnectivityCheckResult result) {
    if (kDebugMode) {
      print('=== Backend Connectivity Check ===');
      print('Environment: ${result.environment}');
      print('Base URL: ${result.baseUrl}');
      print('API Base URL: ${result.apiBaseUrl}');
      print('Endpoint: ${result.endpoint}');
      print('Connected: ${result.isConnected}');
      print('Status Code: ${result.statusCode}');
      print('Response Time: ${result.responseTime.inMilliseconds}ms');
      print('Message: ${result.message}');
      if (result.errorDetails != null) {
        print('Error Details: ${result.errorDetails}');
      }
      print('================================');
    }
  }
}

/// Result of a connectivity check
class ConnectivityCheckResult {
  final bool isConnected;
  final int statusCode;
  final String baseUrl;
  final String apiBaseUrl;
  final String endpoint;
  final Duration responseTime;
  final String message;
  final String? errorDetails;
  final String environment;

  ConnectivityCheckResult({
    required this.isConnected,
    required this.statusCode,
    required this.baseUrl,
    required this.apiBaseUrl,
    required this.endpoint,
    required this.responseTime,
    required this.message,
    this.errorDetails,
    required this.environment,
  });

  @override
  String toString() {
    return 'ConnectivityCheckResult(isConnected: $isConnected, '
        'statusCode: $statusCode, baseUrl: $baseUrl, '
        'responseTime: ${responseTime.inMilliseconds}ms, message: $message)';
  }
}
