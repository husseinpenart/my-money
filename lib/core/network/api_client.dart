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
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: _buildOptions(requiresAuth),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _buildOptions(requiresAuth),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _buildOptions(requiresAuth),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _buildOptions(requiresAuth),
    );
  }

  Options _buildOptions(bool requiresAuth) {
    final token = tokenStorage.getToken();
    ;

    final headers = <String, dynamic>{};

    if (requiresAuth && token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return Options(headers: headers);
  }
}
