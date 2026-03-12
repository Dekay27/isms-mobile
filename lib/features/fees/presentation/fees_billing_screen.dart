import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/platform_adaptive.dart';
import '../application/fees_providers.dart';
import '../domain/fees_models.dart';

class FeesBillingScreen extends ConsumerStatefulWidget {
  const FeesBillingScreen({super.key});

  @override
  ConsumerState<FeesBillingScreen> createState() => _FeesBillingScreenState();
}

class _FeesBillingScreenState extends ConsumerState<FeesBillingScreen> {
  final _academicYearController = TextEditingController();
  final _semesterController = TextEditingController();
  final _searchController = TextEditingController();

  int _page = 1;
  String? _appliedAcademicYear;
  String? _appliedSemester;
  DateTime? _appliedDateFrom;
  DateTime? _appliedDateTo;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _academicYearController.dispose();
    _semesterController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = FeesBillingQuery(
      page: _page,
      academicYear: _appliedAcademicYear,
      semester: _appliedSemester,
      dateFrom: _toIsoDate(_appliedDateFrom),
      dateTo: _toIsoDate(_appliedDateTo),
    );

    final asyncPage = ref.watch(feesBillingProvider(query));
    final isCupertino = isCupertinoPlatform(context);

    if (isCupertino) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Fee Billing'),
        ),
        child: SafeArea(
          child: asyncPage.when(
            loading: () => const _LoadingView(
              isCupertino: true,
              title: 'Loading billing records',
              subtitle: 'This may take a few seconds on slower networks.',
            ),
            error: (error, _) => _ErrorView(
              isCupertino: true,
              message: error.toString(),
              onRetry: () => ref.invalidate(feesBillingProvider(query)),
            ),
            data: (pageData) {
              final visibleRows = _filterRows(
                pageData.rows,
                search: _searchController.text,
                dateFrom: _appliedDateFrom,
                dateTo: _appliedDateTo,
              );
              final totals = _BillingTotals.fromRows(visibleRows);

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () async =>
                        ref.refresh(feesBillingProvider(query).future),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _FiltersCard(
                            isCupertino: true,
                            academicYearController: _academicYearController,
                            semesterController: _semesterController,
                            searchController: _searchController,
                            dateFrom: _appliedDateFrom,
                            dateTo: _appliedDateTo,
                            onPickFromDate: () async => _pickDate(isFrom: true),
                            onPickToDate: () async => _pickDate(isFrom: false),
                            onApply: _applyFilters,
                            onClear: _clearFilters,
                          ),
                          const SizedBox(height: 12),
                          _PageHeader(
                            isCupertino: true,
                            title: 'Admission No: ${pageData.admissionNo}',
                            meta: pageData.meta,
                            showingCount: visibleRows.length,
                            onPrev: pageData.meta.currentPage > 1
                                ? () => setState(
                                    () => _page = pageData.meta.currentPage - 1,
                                  )
                                : null,
                            onNext:
                                pageData.meta.currentPage <
                                    pageData.meta.lastPage
                                ? () => setState(
                                    () => _page = pageData.meta.currentPage + 1,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _TotalsCard(isCupertino: true, totals: totals),
                          const SizedBox(height: 12),
                          if (visibleRows.isEmpty)
                            _EmptyView(
                              isCupertino: true,
                              title: pageData.rows.isEmpty
                                  ? 'No billing records found'
                                  : 'No records match your search/filters',
                              subtitle: pageData.rows.isEmpty
                                  ? 'Try changing year/semester/date filters or checking another page.'
                                  : 'Adjust your search text or filter values and try again.',
                            )
                          else
                            ...visibleRows.map(
                              (row) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _BillingCard(
                                  isCupertino: true,
                                  row: row,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Fee Billing')),
      body: asyncPage.when(
        loading: () => const _LoadingView(
          isCupertino: false,
          title: 'Loading billing records',
          subtitle: 'This may take a few seconds on slower networks.',
        ),
        error: (error, _) => _ErrorView(
          isCupertino: false,
          message: error.toString(),
          onRetry: () => ref.invalidate(feesBillingProvider(query)),
        ),
        data: (pageData) {
          final visibleRows = _filterRows(
            pageData.rows,
            search: _searchController.text,
            dateFrom: _appliedDateFrom,
            dateTo: _appliedDateTo,
          );
          final totals = _BillingTotals.fromRows(visibleRows);

          return RefreshIndicator(
            onRefresh: () async =>
                ref.refresh(feesBillingProvider(query).future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _FiltersCard(
                  isCupertino: false,
                  academicYearController: _academicYearController,
                  semesterController: _semesterController,
                  searchController: _searchController,
                  dateFrom: _appliedDateFrom,
                  dateTo: _appliedDateTo,
                  onPickFromDate: () async => _pickDate(isFrom: true),
                  onPickToDate: () async => _pickDate(isFrom: false),
                  onApply: _applyFilters,
                  onClear: _clearFilters,
                ),
                const SizedBox(height: 12),
                _PageHeader(
                  isCupertino: false,
                  title: 'Admission No: ${pageData.admissionNo}',
                  meta: pageData.meta,
                  showingCount: visibleRows.length,
                  onPrev: pageData.meta.currentPage > 1
                      ? () => setState(
                          () => _page = pageData.meta.currentPage - 1,
                        )
                      : null,
                  onNext: pageData.meta.currentPage < pageData.meta.lastPage
                      ? () => setState(
                          () => _page = pageData.meta.currentPage + 1,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                _TotalsCard(isCupertino: false, totals: totals),
                const SizedBox(height: 12),
                if (visibleRows.isEmpty)
                  _EmptyView(
                    isCupertino: false,
                    title: pageData.rows.isEmpty
                        ? 'No billing records found'
                        : 'No records match your search/filters',
                    subtitle: pageData.rows.isEmpty
                        ? 'Try changing year/semester/date filters or checking another page.'
                        : 'Adjust your search text or filter values and try again.',
                  )
                else
                  ...visibleRows.map(
                    (row) => _BillingCard(isCupertino: false, row: row),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<FeeBillingRow> _filterRows(
    List<FeeBillingRow> rows, {
    required String search,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    final searchTerm = search.trim().toLowerCase();

    return rows.where((row) {
      final balDate = _tryParseDate(row.balanceDate);
      if (dateFrom != null &&
          balDate != null &&
          balDate.isBefore(_startOfDay(dateFrom))) {
        return false;
      }
      if (dateTo != null &&
          balDate != null &&
          balDate.isAfter(_endOfDay(dateTo))) {
        return false;
      }
      if (searchTerm.isEmpty) return true;

      final narration = (row.narration ?? '').toLowerCase();
      final fee = (row.feeDescription ?? '').toLowerCase();
      return narration.contains(searchTerm) || fee.contains(searchTerm);
    }).toList();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = isFrom
        ? (_appliedDateFrom ?? now)
        : (_appliedDateTo ?? _appliedDateFrom ?? now);

    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );

    if (selected == null) return;

    setState(() {
      if (isFrom) {
        _appliedDateFrom = selected;
        if (_appliedDateTo != null && _appliedDateTo!.isBefore(selected)) {
          _appliedDateTo = selected;
        }
      } else {
        _appliedDateTo = selected;
        if (_appliedDateFrom != null && _appliedDateFrom!.isAfter(selected)) {
          _appliedDateFrom = selected;
        }
      }
      _page = 1;
    });
  }

  void _applyFilters() {
    setState(() {
      _appliedAcademicYear = _emptyToNull(_academicYearController.text);
      _appliedSemester = _emptyToNull(_semesterController.text);
      _page = 1;
    });
  }

  void _clearFilters() {
    _academicYearController.clear();
    _semesterController.clear();
    _searchController.clear();

    setState(() {
      _appliedAcademicYear = null;
      _appliedSemester = null;
      _appliedDateFrom = null;
      _appliedDateTo = null;
      _page = 1;
    });
  }
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({
    required this.isCupertino,
    required this.academicYearController,
    required this.semesterController,
    required this.searchController,
    required this.dateFrom,
    required this.dateTo,
    required this.onPickFromDate,
    required this.onPickToDate,
    required this.onApply,
    required this.onClear,
  });

  final bool isCupertino;
  final TextEditingController academicYearController;
  final TextEditingController semesterController;
  final TextEditingController searchController;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final Future<void> Function() onPickFromDate;
  final Future<void> Function() onPickToDate;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filters & Search',
          style: isCupertino
              ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
              : Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        if (isCupertino)
          CupertinoTextField(
            controller: searchController,
            placeholder: 'Search narration / fee description',
          )
        else
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Search narration / fee description',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        const SizedBox(height: 10),
        if (isCupertino)
          CupertinoTextField(
            controller: academicYearController,
            placeholder: 'Academic Year',
          )
        else
          TextField(
            controller: academicYearController,
            decoration: const InputDecoration(labelText: 'Academic Year'),
          ),
        const SizedBox(height: 10),
        if (isCupertino)
          CupertinoTextField(
            controller: semesterController,
            placeholder: 'Semester',
          )
        else
          TextField(
            controller: semesterController,
            decoration: const InputDecoration(labelText: 'Semester'),
          ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (isCupertino)
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                onPressed: onPickFromDate,
                child: Text('From: ${_prettyDate(dateFrom)}'),
              )
            else
              OutlinedButton.icon(
                onPressed: onPickFromDate,
                icon: const Icon(Icons.date_range),
                label: Text('From: ${_prettyDate(dateFrom)}'),
              ),
            if (isCupertino)
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                onPressed: onPickToDate,
                child: Text('To: ${_prettyDate(dateTo)}'),
              )
            else
              OutlinedButton.icon(
                onPressed: onPickToDate,
                icon: const Icon(Icons.date_range),
                label: Text('To: ${_prettyDate(dateTo)}'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (isCupertino)
              CupertinoButton.filled(
                onPressed: onApply,
                child: const Text('Apply'),
              )
            else
              ElevatedButton(onPressed: onApply, child: const Text('Apply')),
            if (isCupertino)
              CupertinoButton(onPressed: onClear, child: const Text('Clear'))
            else
              OutlinedButton(onPressed: onClear, child: const Text('Clear')),
          ],
        ),
      ],
    );

    return _AdaptiveCard(isCupertino: isCupertino, child: content);
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.isCupertino, required this.totals});

  final bool isCupertino;
  final _BillingTotals totals;

  @override
  Widget build(BuildContext context) {
    return _AdaptiveCard(
      isCupertino: isCupertino,
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          Text('Visible Rows: ${totals.count}'),
          Text('Total Payable: ${_money(totals.totalPayable)}'),
          Text('Total Paid: ${_money(totals.totalPaid)}'),
          Text('Total Balance: ${_money(totals.totalBalance)}'),
        ],
      ),
    );
  }
}

class _BillingCard extends StatelessWidget {
  const _BillingCard({required this.isCupertino, required this.row});

  final bool isCupertino;
  final FeeBillingRow row;

  @override
  Widget build(BuildContext context) {
    return _AdaptiveCard(
      isCupertino: isCupertino,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${row.academicYear ?? '-'}  |  ${row.semester ?? '-'}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text('Fee: ${row.feeDescription ?? '-'}'),
          Text('Payable: ${_money(row.amountPayable)}'),
          Text('Paid: ${_money(row.amountPaid)}'),
          Text('Balance: ${_money(row.balance)}'),
          Text('Narration: ${row.narration ?? '-'}'),
          Text('Balance Date: ${row.balanceDate ?? '-'}'),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.isCupertino,
    required this.title,
    required this.meta,
    required this.showingCount,
    this.onPrev,
    this.onNext,
  });

  final bool isCupertino;
  final String title;
  final FeesPageMeta meta;
  final int showingCount;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return _AdaptiveCard(
      isCupertino: isCupertino,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: isCupertino
                ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                : Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Page ${meta.currentPage} of ${meta.lastPage}  |  Server total: ${meta.total}  |  Showing: $showingCount',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              if (isCupertino)
                CupertinoButton(
                  onPressed: onPrev,
                  child: const Text('Previous'),
                )
              else
                OutlinedButton(
                  onPressed: onPrev,
                  child: const Text('Previous'),
                ),
              if (isCupertino)
                CupertinoButton(onPressed: onNext, child: const Text('Next'))
              else
                OutlinedButton(onPressed: onNext, child: const Text('Next')),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdaptiveCard extends StatelessWidget {
  const _AdaptiveCard({required this.isCupertino, required this.child});

  final bool isCupertino;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isCupertino) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1A696CFF)),
        ),
        child: child,
      );
    }

    return Card(
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({
    required this.isCupertino,
    required this.title,
    required this.subtitle,
  });

  final bool isCupertino;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isCupertino
                ? const CupertinoActivityIndicator()
                : const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              title,
              style: isCupertino
                  ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                  : Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.isCupertino,
    required this.title,
    required this.subtitle,
  });

  final bool isCupertino;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _AdaptiveCard(
      isCupertino: isCupertino,
      child: Column(
        children: [
          Icon(
            isCupertino ? CupertinoIcons.archivebox : Icons.inbox_outlined,
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: isCupertino
                ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                : Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.isCupertino,
    required this.message,
    required this.onRetry,
  });

  final bool isCupertino;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = isCupertino
        ? CupertinoButton.filled(onPressed: onRetry, child: const Text('Retry'))
        : ElevatedButton(onPressed: onRetry, child: const Text('Retry'));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCupertino
                  ? CupertinoIcons.exclamationmark_circle
                  : Icons.cloud_off,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Could not load fee billing',
              style: isCupertino
                  ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                  : Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            retry,
          ],
        ),
      ),
    );
  }
}

class _BillingTotals {
  const _BillingTotals({
    required this.count,
    required this.totalPayable,
    required this.totalPaid,
    required this.totalBalance,
  });

  final int count;
  final double totalPayable;
  final double totalPaid;
  final double totalBalance;

  factory _BillingTotals.fromRows(List<FeeBillingRow> rows) {
    final totalPayable = rows.fold<double>(
      0,
      (sum, row) => sum + (row.amountPayable ?? 0),
    );
    final totalPaid = rows.fold<double>(
      0,
      (sum, row) => sum + (row.amountPaid ?? 0),
    );
    final totalBalance = rows.fold<double>(
      0,
      (sum, row) => sum + (row.balance ?? 0),
    );

    return _BillingTotals(
      count: rows.length,
      totalPayable: totalPayable,
      totalPaid: totalPaid,
      totalBalance: totalBalance,
    );
  }
}

String _money(double? value) {
  if (value == null) return '-';
  return value.toStringAsFixed(2);
}

String _prettyDate(DateTime? value) {
  if (value == null) return 'Any';
  return _toIsoDate(value) ?? 'Any';
}

String? _toIsoDate(DateTime? value) {
  if (value == null) return null;
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

DateTime? _tryParseDate(String? input) {
  if (input == null || input.trim().isEmpty) return null;
  return DateTime.tryParse(input.trim());
}

DateTime _startOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _endOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day, 23, 59, 59, 999);

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
