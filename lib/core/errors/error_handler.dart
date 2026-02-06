import 'package:dio/dio.dart';
import 'api_error.dart';

class ErrorHandler {
  static String getUserMessage(Object error) {
    if (error is DioException) {
      return ApiError.fromDioException(error).message;
    }
    if (error is ApiError) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }

  static Map<String, String> getFieldErrors(Object error) {
    if (error is ApiError && error.fieldErrors != null) {
      return error.fieldErrors!.map(
        (key, value) => MapEntry(key, value.join(', ')),
      );
    }
    return {};
  }
}
