import 'package:dio/dio.dart';
import 'package:habit_tracker/core/storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth if explicitly requested (e.g., for connectivity checks)
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    // Skip auth endpoints
    if (options.path.contains('/auth/')) {
      return handler.next(options);
    }

    // Add Bearer token
    final accessToken = await _storage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }
}
