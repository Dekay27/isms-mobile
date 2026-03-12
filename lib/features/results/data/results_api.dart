import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

final resultsApiProvider = Provider<ResultsApi>((ref) {
  return ResultsApi(ref.read(dioProvider));
});

class ResultsApi {
  ResultsApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> summary() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/results/summary',
    );
    return (response.data?['data'] ?? <String, dynamic>{})
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> semester({
    required String academicYear,
    required String semesterId,
    String? semester,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/results/semester',
      queryParameters: {
        'academic_year': academicYear,
        'semester_id': semesterId,
        if ((semester ?? '').trim().isNotEmpty) 'semester': semester,
      },
    );
    return (response.data?['data'] ?? <String, dynamic>{})
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> slip({
    required String academicYear,
    required String semesterId,
    String? semester,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/results/slip',
      queryParameters: {
        'academic_year': academicYear,
        'semester_id': semesterId,
        if ((semester ?? '').trim().isNotEmpty) 'semester': semester,
      },
    );
    return (response.data?['data'] ?? <String, dynamic>{})
        as Map<String, dynamic>;
  }
}
