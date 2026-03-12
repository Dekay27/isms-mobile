import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/platform_adaptive.dart';
import '../application/results_providers.dart';
import '../domain/results_models.dart';

class ResultsSlipScreen extends ConsumerWidget {
  const ResultsSlipScreen({super.key, required this.filter});

  final ResultsTermFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSlip = ref.watch(resultsSlipProvider(filter));
    final isCupertino = isCupertinoPlatform(context);

    if (isCupertino) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Result Slip'),
        ),
        child: SafeArea(
          child: asyncSlip.when(
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error, _) => _ErrorView(
              isCupertino: true,
              message: error.toString(),
              onRetry: () => ref.invalidate(resultsSlipProvider(filter)),
            ),
            data: (slip) => CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async =>
                      ref.refresh(resultsSlipProvider(filter).future),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _AdaptiveCard(
                          isCupertino: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slip.student.fullName ?? slip.admissionNo,
                                style: CupertinoTheme.of(
                                  context,
                                ).textTheme.navTitleTextStyle,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Programme: ${slip.student.programmeName ?? slip.student.programme ?? '-'}',
                              ),
                              Text('Level: ${slip.student.level ?? '-'}'),
                              Text(
                                'Term: ${slip.term.academicYear} / ${slip.term.semester ?? slip.term.semesterId}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AdaptiveCard(
                          isCupertino: true,
                          child: Wrap(
                            spacing: 18,
                            runSpacing: 8,
                            children: [
                              Text('Courses: ${slip.summary.coursesCount}'),
                              Text(
                                'Credits: ${slip.summary.totalCredits.toStringAsFixed(1)}',
                              ),
                              Text('Term GPA: ${_f(slip.summary.termGpa)}'),
                              Text('CGPA: ${_f(slip.summary.cgpa)}'),
                              Text('FGPA: ${_f(slip.summary.fgpa)}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...slip.rows.map(
                          (row) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _AdaptiveCard(
                              isCupertino: true,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${row.courseCode ?? '-'} - ${row.courseName ?? '-'}',
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Credit ${_f(row.noOfCredit)} | Score ${_f(row.totalScore)} | Grade ${row.grade ?? '-'}',
                                  ),
                                  Text('Remark: ${row.remark ?? '-'}'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Result Slip')),
      body: asyncSlip.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          isCupertino: false,
          message: error.toString(),
          onRetry: () => ref.invalidate(resultsSlipProvider(filter)),
        ),
        data: (slip) => RefreshIndicator(
          onRefresh: () async =>
              ref.refresh(resultsSlipProvider(filter).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slip.student.fullName ?? slip.admissionNo,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Programme: ${slip.student.programmeName ?? slip.student.programme ?? '-'}',
                      ),
                      Text('Level: ${slip.student.level ?? '-'}'),
                      Text(
                        'Term: ${slip.term.academicYear} / ${slip.term.semester ?? slip.term.semesterId}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Wrap(
                    spacing: 18,
                    runSpacing: 8,
                    children: [
                      Text('Courses: ${slip.summary.coursesCount}'),
                      Text(
                        'Credits: ${slip.summary.totalCredits.toStringAsFixed(1)}',
                      ),
                      Text('Term GPA: ${_f(slip.summary.termGpa)}'),
                      Text('CGPA: ${_f(slip.summary.cgpa)}'),
                      Text('FGPA: ${_f(slip.summary.fgpa)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...slip.rows.map(
                (row) => ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text(
                    '${row.courseCode ?? '-'} - ${row.courseName ?? '-'}',
                  ),
                  subtitle: Text(
                    'Credit ${_f(row.noOfCredit)} | Score ${_f(row.totalScore)} | Grade ${row.grade ?? '-'}',
                  ),
                  trailing: Text(row.remark ?? '-'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _f(double? v) => v == null ? '-' : v.toStringAsFixed(2);
}

class _AdaptiveCard extends StatelessWidget {
  const _AdaptiveCard({required this.child, required this.isCupertino});

  final Widget child;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) {
    if (isCupertino) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1A696CFF)),
        ),
        child: child,
      );
    }

    return Card(
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.isCupertino,
  });

  final String message;
  final VoidCallback onRetry;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) {
    final icon = isCupertino
        ? const Icon(CupertinoIcons.exclamationmark_circle, size: 40)
        : const Icon(Icons.error_outline, size: 40);

    final retry = isCupertino
        ? CupertinoButton.filled(onPressed: onRetry, child: const Text('Retry'))
        : ElevatedButton(onPressed: onRetry, child: const Text('Retry'));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              'Could not load result slip',
              style: isCupertino
                  ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                  : Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            retry,
          ],
        ),
      ),
    );
  }
}
