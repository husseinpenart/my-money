// lib/feature/auth/data/auth_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:money/core/network/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<dynamic> register({
    required String name,
    required String phoneNumber,
    required String password,
    required String confirmedPassword,
  }) async {
    final Response<dynamic> response = await apiClient.post<dynamic>(
      '/AuthControllers/register',
      requiresAuth: false,
      data: {
        'name': name,
        'phoneNumber': phoneNumber,
        'password': password,
        'confirmedPassword': confirmedPassword,
      },
    );
print('>>> register payload: ${response.data}');
    return response.data;
  }

  Future<dynamic> login({
    required String phoneNumber,
    required String password,
  }) async {
    final Response<dynamic> response = await apiClient.post<dynamic>(
      '/AuthControllers/login',
      requiresAuth: false,
      data: {'phoneNumber': phoneNumber, 'password': password},
    );

    return response.data;
  }
}
