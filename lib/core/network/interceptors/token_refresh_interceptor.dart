import 'package:dio/dio.dart';
import 'package:habit_tracker/core/config/api_config.dart';
import 'package:habit_tracker/core/storage/secure_storage_service.dart';

class TokenRefreshInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorageService _storage;
  final void Function() _onRefreshFailed;

  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
      _pendingRequests = [];

  TokenRefreshInterceptor(
    this._dio,
    this._storage,
    this._onRefreshFailed,
  );

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 Unauthorized
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't retry auth endpoints
    if (err.requestOptions.path.contains('/auth/')) {
      return handler.next(err);
    }

    // If already refreshing, queue this request
    if (_isRefreshing) {
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      // Get refresh token
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      // Call refresh endpoint
      final response = await _dio.post(
        ApiConfig.getFullUrl(ApiConfig.authRefresh),
        data: {'refresh': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      // Save new tokens (with rotation)
      final newAccessToken = response.data['access'] as String;
      final newRefreshToken = response.data['refresh'] as String;
      await _storage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // Retry original request
      final retryResponse = await _retryRequest(err.requestOptions);
      handler.resolve(retryResponse);

      // Retry all pending requests
      for (final pending in _pendingRequests) {
        try {
          final response = await _retryRequest(pending.options);
          pending.handler.resolve(response);
        } catch (e) {
          pending.handler.reject(
            DioException(
              requestOptions: pending.options,
              error: e,
            ),
          );
        }
      }
      _pendingRequests.clear();
    } catch (refreshError) {
      // Refresh failed - clear tokens and notify app
      await _storage.clearTokens();
      _onRefreshFailed();

      // Reject original request
      handler.reject(err);

      // Reject all pending requests
      for (final pending in _pendingRequests) {
        pending.handler.reject(
          DioException(
            requestOptions: pending.options,
            error: 'Authentication failed',
          ),
        );
      }
      _pendingRequests.clear();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response> _retryRequest(RequestOptions options) async {
    // Get fresh access token
    final accessToken = await _storage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Retry the request
    return await _dio.fetch(options);
  }
}
