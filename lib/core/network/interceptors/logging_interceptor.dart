import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  // Sensitive headers that should never be logged
  static const _sensitiveHeaders = [
    'authorization',
    'cookie',
    'set-cookie',
    'x-auth-token',
    'api-key',
    'x-api-key',
  ];

  // Sensitive keys in request/response bodies
  static const _sensitiveKeys = [
    'password',
    'token',
    'access_token',
    'refresh_token',
    'secret',
    'api_key',
    'apiKey',
    'credit_card',
    'ssn',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('🚀 REQUEST[${options.method}] => ${options.uri}');
      print('Headers: ${_sanitizeHeaders(options.headers)}');
      if (options.data != null) {
        print('Data: ${_sanitizeData(options.data)}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print(
        '✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
      );
      print('Data: ${_sanitizeData(response.data)}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print(
        '❌ ERROR[${err.response?.statusCode}] => ${err.requestOptions.uri}',
      );
      print('Error Type: ${err.type}');
      print('Message: ${err.message}');
      print('Error: ${err.error}');

      if (err.response != null) {
        print('Response Status: ${err.response?.statusCode}');
        print(
          'Response Headers: ${_sanitizeHeaders(err.response!.headers.map)}',
        );
        if (err.response?.data != null) {
          print('Response Data: ${_sanitizeData(err.response?.data)}');
        }
      } else {
        print('❗ No response received - likely network/CORS issue');
      }

      // Additional browser-specific debugging
      if (err.type == DioExceptionType.connectionError) {
        print('🌐 Connection Error Details:');
        print('   - Check browser DevTools Network tab for CORS errors');
        print('   - Verify backend CORS headers allow this origin');
        print('   - Ensure backend SSL certificate is valid');
      }
    }
    handler.next(err);
  }

  /// Remove sensitive headers from logging
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, dynamic>{};
    headers.forEach((key, value) {
      if (_sensitiveHeaders.contains(key.toLowerCase())) {
        sanitized[key] = '***REDACTED***';
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  /// Remove sensitive data from request/response bodies
  dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      final sanitized = <String, dynamic>{};
      data.forEach((key, value) {
        if (_sensitiveKeys.contains(key.toString().toLowerCase())) {
          sanitized[key] = '***REDACTED***';
        } else if (value is Map || value is List) {
          sanitized[key] = _sanitizeData(value);
        } else {
          sanitized[key] = value;
        }
      });
      return sanitized;
    } else if (data is List) {
      return data.map((item) => _sanitizeData(item)).toList();
    }
    return data;
  }
}
