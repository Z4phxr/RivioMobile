import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/config/api_config.dart';
import 'package:habit_tracker/core/network/interceptors/auth_interceptor.dart';
import 'package:habit_tracker/core/network/interceptors/token_refresh_interceptor.dart';
import 'package:habit_tracker/core/network/interceptors/logging_interceptor.dart';
import 'package:habit_tracker/core/storage/secure_storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _storage;
  final void Function() _onTokenRefreshFailed;

  ApiClient(
    this._storage,
    this._onTokenRefreshFailed,
  ) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiBaseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          ...ApiConfig.defaultHeaders,
          // Ensure proper headers for CORS
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        // Enable following redirects and validate status
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add interceptors in order
    _dio.interceptors.addAll([
      AuthInterceptor(_storage),
      TokenRefreshInterceptor(_dio, _storage, _onTokenRefreshFailed),
      LoggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  // Convenience methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

// Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return ApiClient(
    storage,
    () {
      // Token refresh failed - tokens are already cleared by interceptor
      // The next auth check will naturally route to login
      debugPrint('🚫 ApiClient: Token refresh failed, tokens cleared');
    },
  );
});
