import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/platform_adaptive.dart';
import '../../auth/application/auth_controller.dart';
import '../application/results_providers.dart';
import '../domain/results_models.dart';

class ResultsSummaryScreen extends ConsumerWidget {
  const ResultsSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSummary = ref.watch(resultsSummaryProvider);
    final isCupertino = isCupertinoPlatform(context);

    if (isCupertino) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Results Summary'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => ref.invalidate(resultsSummaryProvider),
                child: const Icon(CupertinoIcons.refresh),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
                child: const Icon(CupertinoIcons.square_arrow_right),
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: asyncSummary.when(
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error, _) => _ErrorView(
              isCupertino: true,
              message: error.toString(),
              onRetry: () => ref.invalidate(resultsSummaryProvider),
            ),
            data: (summary) => CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async =>
                      ref.refresh(resultsSummaryProvider.future),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _OverviewCard(summary: summary, isCupertino: true),
                        const SizedBox(height: 12),
                        _LatestCard(summary: summary, isCupertino: true),
                        const SizedBox(height: 12),
                        Text(
                          'Terms',
                          style: CupertinoTheme.of(
                            context,
                          ).textTheme.navTitleTextStyle,
                        ),
                        const SizedBox(height: 8),
                        ...summary.terms.map(
                          (term) => _TermCard(term: term, isCupertino: true),
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
      appBar: AppBar(
        title: const Text('Results Summary'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(resultsSummaryProvider),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: asyncSummary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          isCupertino: false,
          message: error.toString(),
          onRetry: () => ref.invalidate(resultsSummaryProvider),
        ),
        data: (summary) => RefreshIndicator(
          onRefresh: () async => ref.refresh(resultsSummaryProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _OverviewCard(summary: summary, isCupertino: false),
              const SizedBox(height: 12),
              _LatestCard(summary: summary, isCupertino: false),
              const SizedBox(height: 12),
              Text('Terms', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...summary.terms.map(
                (term) => _TermCard(term: term, isCupertino: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.summary, required this.isCupertino});

  final ResultsSummary summary;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) {
    return _AdaptiveCard(
      isCupertino: isCupertino,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Admission No: ${summary.admissionNo}'),
          const SizedBox(height: 8),
          Text('Total Courses: ${summary.overall.coursesCount}'),
          Text(
            'Total Credits: ${summary.overall.totalCredits.toStringAsFixed(1)}',
          ),
        ],
      ),
    );
  }
}

class _LatestCard extends StatelessWidget {
  const _LatestCard({required this.summary, required this.isCupertino});

  final ResultsSummary summary;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) {
    final latest = summary.latest;

    return _AdaptiveCard(
      isCupertino: isCupertino,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Snapshot',
            style: isCupertino
                ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                : Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Year/Semester: ${latest.academicYear ?? '-'} / ${latest.semester ?? latest.semesterId ?? '-'}',
          ),
          Text('Programme: ${latest.programme ?? '-'}'),
          Text('Level: ${latest.level ?? '-'}'),
          Text('CGPA: ${latest.cgpa?.toStringAsFixed(2) ?? '-'}'),
          Text('FGPA: ${latest.fgpa?.toStringAsFixed(2) ?? '-'}'),
        ],
      ),
    );
  }
}

class _TermCard extends StatelessWidget {
  const _TermCard({required this.term, required this.isCupertino});

  final ResultsTermSummary term;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) {
    final filter = ResultsTermFilter(
      academicYear: term.academicYear,
      semesterId: term.semesterId,
      semester: term.semester,
    );

    final query = {
      'academic_year': filter.academicYear,
      'semester_id': filter.semesterId,
      if ((filter.semester ?? '').trim().isNotEmpty)
        'semester': filter.semester!,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _AdaptiveCard(
        isCupertino: isCupertino,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${term.academicYear}  |  ${term.semester ?? term.semesterId}',
            ),
            const SizedBox(height: 6),
            Text(
              'Courses: ${term.coursesCount}   Credits: ${term.totalCredits.toStringAsFixed(1)}',
            ),
            Text(
              'TGPA: ${term.tgpa?.toStringAsFixed(2) ?? '-'}  CGPA: ${term.cgpa?.toStringAsFixed(2) ?? '-'}',
            ),
            const SizedBox(height: 10),
            if (isCupertino)
              Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    onPressed: () => context.push(
                      Uri(
                        path: '/results/semester',
                        queryParameters: query,
                      ).toString(),
                    ),
                    child: const Text('View Semester'),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    onPressed: () => context.push(
                      Uri(
                        path: '/results/slip',
                        queryParameters: query,
                      ).toString(),
                    ),
                    child: const Text('View Slip'),
                  ),
                ],
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => context.push(
                      Uri(
                        path: '/results/semester',
                        queryParameters: query,
                      ).toString(),
                    ),
                    child: const Text('View Semester'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.push(
                      Uri(
                        path: '/results/slip',
                        queryParameters: query,
                      ).toString(),
                    ),
                    child: const Text('View Slip'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
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
              'Could not load summary',
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
