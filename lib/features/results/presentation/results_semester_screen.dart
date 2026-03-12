import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/platform_adaptive.dart';
import '../application/results_providers.dart';
import '../domain/results_models.dart';

class ResultsSemesterScreen extends ConsumerWidget {
  const ResultsSemesterScreen({super.key, required this.filter});

  final ResultsTermFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSemester = ref.watch(resultsSemesterProvider(filter));
    final isCupertino = isCupertinoPlatform(context);

    if (isCupertino) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Semester Results'),
        ),
        child: SafeArea(
          child: asyncSemester.when(
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error, _) => _ErrorView(
              isCupertino: true,
              message: error.toString(),
              onRetry: () => ref.invalidate(resultsSemesterProvider(filter)),
            ),
            data: (data) => CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async =>
                      ref.refresh(resultsSemesterProvider(filter).future),
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
                                '${data.term.academicYear} / ${data.term.semester ?? data.term.semesterId}',
                                style: CupertinoTheme.of(
                                  context,
                                ).textTheme.navTitleTextStyle,
                              ),
                              const SizedBox(height: 6),
                              Text('Courses: ${data.rows.length}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...data.rows.map(
                          (row) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AdaptiveCard(
                              isCupertino: true,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${row.courseCode ?? '-'} - ${row.courseName ?? '-'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Credit: ${_f(row.noOfCredit)}  Class: ${_f(row.classScore)}  Exam: ${_f(row.examScore)}  Total: ${_f(row.totalScore)}',
                                  ),
                                  Text(
                                    'Grade: ${row.grade ?? '-'}  GPA: ${_f(row.gpa)}  Remark: ${row.remark ?? '-'}',
                                  ),
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
      appBar: AppBar(title: const Text('Semester Results')),
      body: asyncSemester.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          isCupertino: false,
          message: error.toString(),
          onRetry: () => ref.invalidate(resultsSemesterProvider(filter)),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async =>
              ref.refresh(resultsSemesterProvider(filter).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: Text(
                    '${data.term.academicYear} / ${data.term.semester ?? data.term.semesterId}',
                  ),
                  subtitle: Text('Courses: ${data.rows.length}'),
                ),
              ),
              const SizedBox(height: 12),
              ...data.rows.map(
                (row) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${row.courseCode ?? '-'} - ${row.courseName ?? '-'}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Credit: ${_f(row.noOfCredit)}  Class: ${_f(row.classScore)}  Exam: ${_f(row.examScore)}  Total: ${_f(row.totalScore)}',
                        ),
                        Text(
                          'Grade: ${row.grade ?? '-'}  GPA: ${_f(row.gpa)}  Remark: ${row.remark ?? '-'}',
                        ),
                      ],
                    ),
                  ),
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
              'Could not load semester results',
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
