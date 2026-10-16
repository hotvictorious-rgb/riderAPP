// lib/core/network/api_exceptions.dart
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(message: 'Connection timed out. Check mobile network signal.');
      case DioExceptionType.badResponse:
        final statusCode = dioError.response?.statusCode;
        final data = dioError.response?.data;

        // ZERO-KNOWLEDGE SECURITY MASKING:
        // Mask 500 server crashes and unhandled exceptions to prevent stack trace/database leakage
        if (statusCode != null && statusCode >= 500) {
          return ApiException(
            message: 'An unexpected server error occurred. Please try again later.',
            statusCode: statusCode,
          );
        } else if (statusCode == 401) {
          return ApiException(
            message: 'Authentication required or session expired.',
            statusCode: 401,
          );
        } else if (statusCode == 403) {
          return ApiException(
            message: 'Access denied. You do not have permission for this terminal.',
            statusCode: 403,
          );
        }

        if (data is Map && data.containsKey('message')) {
          return ApiException(
            message: data['message'].toString(),
            statusCode: statusCode,
          );
        }
        return ApiException(
          message: 'Request failed. Please verify credentials.',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.');
      default:
        return ApiException(message: 'Network offline. Please check internet connection.');
    }
  }

  @override
  String toString() => message;
}
