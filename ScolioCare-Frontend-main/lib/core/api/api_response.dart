/// Standard API Response envelope matching backend specification
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? timestamp;
  final String? errorCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.timestamp,
    this.errorCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] as String?,
      timestamp: json['timestamp'] as String?,
      errorCode: json['errorCode'] as String?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T? value)? toJsonT) {
    return {
      'success': success,
      'data': toJsonT != null ? toJsonT(data) : data,
      'message': message,
      'timestamp': timestamp,
      'errorCode': errorCode,
    };
  }
}
