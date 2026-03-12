import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fees_api.dart';
import '../domain/fees_models.dart';

final feesSummaryProvider = FutureProvider<FeesSummary>((ref) async {
  final response = await ref.read(feesApiProvider).summary();
  return FeesSummary.fromEnvelope(response);
});

final feesPaymentsProvider =
    FutureProvider.family<FeesPaymentsPage, FeesPaymentsQuery>((
      ref,
      query,
    ) async {
      final response = await ref
          .read(feesApiProvider)
          .payments(
            page: query.page,
            perPage: query.perPage,
            academicYear: query.academicYear,
            dateFrom: query.dateFrom,
            dateTo: query.dateTo,
          );
      return FeesPaymentsPage.fromEnvelope(response);
    });

final feesBillingProvider =
    FutureProvider.family<FeesBillingPage, FeesBillingQuery>((
      ref,
      query,
    ) async {
      final response = await ref
          .read(feesApiProvider)
          .billing(
            page: query.page,
            perPage: query.perPage,
            academicYear: query.academicYear,
            semester: query.semester,
          );
      return FeesBillingPage.fromEnvelope(response);
    });
