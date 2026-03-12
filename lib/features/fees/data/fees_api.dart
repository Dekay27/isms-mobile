import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

final feesApiProvider = Provider<FeesApi>((ref) {
  return FeesApi(ref.read(dioProvider));
});

class FeesApi {
  FeesApi(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> summary() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/fees/summary',
    );

    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> payments({
    int page = 1,
    int perPage = 20,
    String? academicYear,
    String? dateFrom,
    String? dateTo,
  }) async {
    final query = <String, dynamic>{'page': page, 'per_page': perPage};

    final year = academicYear?.trim();
    if (year != null && year.isNotEmpty) {
      query['academic_year'] = year;
    }

    final from = dateFrom?.trim();
    if (from != null && from.isNotEmpty) {
      query['date_from'] = from;
    }

    final to = dateTo?.trim();
    if (to != null && to.isNotEmpty) {
      query['date_to'] = to;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/fees/payments',
      queryParameters: query,
    );

    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> billing({
    int page = 1,
    int perPage = 20,
    String? academicYear,
    String? semester,
  }) async {
    final query = <String, dynamic>{'page': page, 'per_page': perPage};

    final year = academicYear?.trim();
    if (year != null && year.isNotEmpty) {
      query['academic_year'] = year;
    }

    final sem = semester?.trim();
    if (sem != null && sem.isNotEmpty) {
      query['semester'] = sem;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/fees/billing',
      queryParameters: query,
    );

    return response.data ?? <String, dynamic>{};
  }
}
