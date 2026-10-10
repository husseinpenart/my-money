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

  Future<dynamic> resetPassword({
    required String phoneNumber,
    required String recoveryCode,
    required String newPassword,
    required String confirmedPassword,
  }) async {
    final Response<dynamic> response = await apiClient.post<dynamic>(
      '/AuthControllers/reset-password',
      requiresAuth: false,
      data: {
        'phoneNumber': phoneNumber,
        'recoveryCode': recoveryCode,
        'newPassword': newPassword,
        'confirmedPassword': confirmedPassword,
      },
    );
    return response.data;
  }

  Future<dynamic> generateRecoveryCode({
    required String currentPassword,
  }) async {
    final Response<dynamic> response = await apiClient.post<dynamic>(
      '/AuthControllers/recovery-code',
      data: {'currentPassword': currentPassword},
    );
    return response.data;
  }
}
