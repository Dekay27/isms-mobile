import 'package:dio/dio.dart';

import '../domain/api_user.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<(String, ApiUser)> login({
    required String username,
    required String password,
    String deviceName = 'flutter-mobile',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: {
        'username': username,
        'password': password,
        'device_name': deviceName,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid login response.');
    }

    final token = (data['access_token'] ?? '') as String;
    final userMap =
        (data['user'] ?? <String, dynamic>{}) as Map<String, dynamic>;

    if (token.isEmpty) {
      throw Exception('Login response missing token.');
    }

    return (token, ApiUser.fromMap(userMap));
  }

  Future<ApiUser> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/auth/me');
    final data = response.data?['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid me response.');
    }
    return ApiUser.fromMap(data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _dio.post(
      '/api/v1/auth/change-password',
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<void> logout() async {
    await _dio.post('/api/v1/auth/logout');
  }
}
