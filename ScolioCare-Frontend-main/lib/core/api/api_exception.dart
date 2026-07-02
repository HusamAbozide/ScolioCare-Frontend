import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  ApiException({
    required this.message,
    this.errorCode,
    this.statusCode,
  });

  factory ApiException.fromDioError(DioException error) {
    String message;
    String? errorCode;
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        errorCode = 'TIMEOUT';
        break;
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          message = data['message'] ?? 'An error occurred';
          errorCode = data['errorCode'];
        } else {
          message = _getMessageFromStatusCode(statusCode);
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        errorCode = 'CANCELLED';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection';
        errorCode = 'NO_CONNECTION';
        break;
      default:
        message = 'An unexpected error occurred';
        errorCode = 'UNKNOWN';
    }

    return ApiException(
      message: message,
      errorCode: errorCode,
      statusCode: statusCode,
    );
  }

  static String _getMessageFromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden';
      case 404:
        return 'Resource not found';
      case 409:
        return 'Conflict occurred';
      case 422:
        return 'Validation failed';
      case 500:
        return 'Server error. Please try again later.';
      case 503:
        return 'Service unavailable';
      default:
        return 'An error occurred';
    }
  }

  @override
  String toString() => message;
}
