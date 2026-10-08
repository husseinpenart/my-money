import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  ApiClient(this.tokenStorage)
    : dio = Dio(
        BaseOptions(
          baseUrl: 'http://192.168.1.185:8085/api',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          // Content-Type عمداً اینجا نیست؛ در _buildOptions بر اساس نوع data ست می‌شود
          headers: {'Accept': 'application/json'},
        ),
      );

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    CancelToken? cancelToken,
  }) {
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: _buildOptions(requiresAuth),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data, // Map یا FormData
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    CancelToken? cancelToken,
  }) {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: _buildOptions(requiresAuth, data: data),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data, // Map یا FormData
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    CancelToken? cancelToken,
  }) {
    return dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: _buildOptions(requiresAuth, data: data),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    CancelToken? cancelToken,
  }) {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: _buildOptions(requiresAuth, data: data),
    );
  }

  Options _buildOptions(bool requiresAuth, {Object? data}) {
    final token = tokenStorage.getToken();
    final headers = <String, dynamic>{};

    if (requiresAuth && token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // FormData → Dio خودش multipart + boundary را می‌گذارد
    // بقیه → JSON (فقط وقتی بدنه داریم)
    final String? contentType = data is FormData
        ? null
        : (data != null ? Headers.jsonContentType : null);

    return Options(headers: headers, contentType: contentType);
  }
}
