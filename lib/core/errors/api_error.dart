import 'package:dio/dio.dart';

class ApiError implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? fieldErrors;

  ApiError({required this.message, this.statusCode, this.fieldErrors});

  factory ApiError.fromDioException(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;

      // Handle {"error": "message"} format
      if (data.containsKey('error')) {
        return ApiError(
          message: data['error'] as String,
          statusCode: e.response?.statusCode,
        );
      }

      // Handle {"field": ["error1", "error2"]} format
      final fieldErrors = <String, List<String>>{};
      data.forEach((key, value) {
        if (value is List) {
          fieldErrors[key] = value.cast<String>();
        } else if (value is String) {
          fieldErrors[key] = [value];
        }
      });

      if (fieldErrors.isNotEmpty) {
        // Create a readable message from all errors
        final errorMessages = fieldErrors.entries
            .map((e) => '${e.key}: ${e.value.join(", ")}')
            .join('\n');
        return ApiError(
          message: errorMessages,
          statusCode: e.response?.statusCode,
          fieldErrors: fieldErrors,
        );
      }
    }

    // Default error messages based on DioException type
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        return ApiError(
          message:
              'Server error (${e.response?.statusCode ?? 'unknown'}). Please try again later.',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return ApiError(message: 'Request cancelled');
      case DioExceptionType.connectionError:
        return ApiError(
          message: 'Cannot connect to server. Please check:\n'
              '1. Backend server is running\n'
              '2. Your internet connection\n'
              '3. Firewall settings',
        );
      case DioExceptionType.unknown:
        if (e.message?.contains('XMLHttpRequest') ?? false) {
          return ApiError(
            message:
                'Cannot connect to server. Please ensure the backend is running.',
          );
        }
        if (e.message?.contains('SocketException') ?? false) {
          return ApiError(message: 'No internet connection');
        }
        return ApiError(
          message:
              'Connection error. Please check if the backend server is running.',
        );
      default:
        return ApiError(message: e.message ?? 'Unknown error occurred');
    }
  }

  @override
  String toString() => message;
}
