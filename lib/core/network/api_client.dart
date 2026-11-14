// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio _dio;
  final StorageService _storageService;
  Function()? onUnauthorizedCallback;

  ApiClient(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _storageService.getApiBaseUrl() ?? ApiEndpoints.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Terminal-Type': AppConstants.terminalType,
          'X-Terminal-Client': 'rider_mobile_terminal',
          'X-Required-Role': 'rider',
          'X-App-Version': AppConstants.appVersion,
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.baseUrl = _storageService.getApiBaseUrl() ?? ApiEndpoints.baseUrl;
          options.headers['X-Terminal-Client'] = 'rider_mobile_terminal';
          options.headers['X-Required-Role'] = 'rider';
          options.headers['X-App-Version'] = AppConstants.appVersion;
          final token = _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final hadToken = _storageService.getToken();
            if (hadToken != null && hadToken.isNotEmpty) {
              await _storageService.clearToken();
              if (onUnauthorizedCallback != null) {
                onUnauthorizedCallback!();
              }
            }
          }
          final parsed = ApiException.fromDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: parsed,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  StorageService get storageService => _storageService;

  void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.delete(path, data: data, queryParameters: queryParameters);
  }
}
