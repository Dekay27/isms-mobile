import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/results_api.dart';
import '../domain/results_models.dart';

final resultsSummaryProvider = FutureProvider<ResultsSummary>((ref) async {
  final data = await ref.read(resultsApiProvider).summary();
  return ResultsSummary.fromMap(data);
});

final resultsSemesterProvider =
    FutureProvider.family<SemesterResult, ResultsTermFilter>((
      ref,
      filter,
    ) async {
      final data = await ref
          .read(resultsApiProvider)
          .semester(
            academicYear: filter.academicYear,
            semesterId: filter.semesterId,
            semester: filter.semester,
          );
      return SemesterResult.fromMap(data);
    });

final resultsSlipProvider =
    FutureProvider.family<ResultSlip, ResultsTermFilter>((ref, filter) async {
      final data = await ref
          .read(resultsApiProvider)
          .slip(
            academicYear: filter.academicYear,
            semesterId: filter.semesterId,
            semester: filter.semester,
          );
      return ResultSlip.fromMap(data);
    });
