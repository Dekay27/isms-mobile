import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

final meApiProvider = Provider<MeApi>((ref) {
  return MeApi(ref.read(dioProvider));
});

class MeApi {
  MeApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> profile() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/me/profile');
    return (response.data?['data'] ?? <String, dynamic>{})
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> programmeContext() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/me/programme-context',
    );
    return (response.data?['data'] ?? <String, dynamic>{})
        as Map<String, dynamic>;
  }
}
