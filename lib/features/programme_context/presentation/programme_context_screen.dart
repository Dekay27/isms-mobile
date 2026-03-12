import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../application/programme_context_provider.dart';
import '../domain/programme_context.dart';

class ProgrammeContextScreen extends ConsumerWidget {
  const ProgrammeContextScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(programmeContextProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programme Context'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(programmeContextProvider),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh context',
          ),
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: contextAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ContextError(
          message: error.toString(),
          onRetry: () => ref.invalidate(programmeContextProvider),
        ),
        data: (model) => RefreshIndicator(
          onRefresh: () async => ref.refresh(programmeContextProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderCard(model: model),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Current Context',
                rows: [
                  _row('Academic Year', model.academicYear),
                  _row('Semester', _join(model.semesterId, model.semester)),
                  _row('Level', _join(model.level, model.levelDescription)),
                  _row('Status', model.status),
                  _row('Intake', model.intake),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Programme Structure',
                rows: [
                  _row(
                    'Programme',
                    _join(model.programmeCode, model.programmeName),
                  ),
                  _row(
                    'Department',
                    _join(model.departmentCode, model.departmentName),
                  ),
                  _row('Faculty', _join(model.facultyCode, model.facultyName)),
                  _row('School', model.school),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Performance Snapshot',
                rows: [
                  _row('CGPA', _fmtNum(model.cgpa)),
                  _row('FGPA', _fmtNum(model.fgpa)),
                  _row('FGPA Status', model.fgpaStatus?.toString()),
                  _row('Last Result Year', model.lastResultAcademicYear),
                  _row(
                    'Last Result Semester',
                    _join(model.lastResultSemesterId, model.lastResultSemester),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Meta',
                rows: [
                  _row('Admission No', model.admissionNo),
                  _row('Form No', model.formNo),
                  _row('As Of', model.asOf),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _InfoRow _row(String label, String? value) => _InfoRow(label, value);

  static String? _fmtNum(double? value) {
    if (value == null) return null;
    return value.toStringAsFixed(2);
  }

  static String? _join(String? left, String? right) {
    final l = left?.trim();
    final r = right?.trim();
    if ((l == null || l.isEmpty) && (r == null || r.isEmpty)) return null;
    if (l == null || l.isEmpty) return r;
    if (r == null || r.isEmpty) return l;
    return '$l - $r';
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.model});

  final ProgrammeContext model;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              model.studentName ?? model.admissionNo ?? 'Student',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text('Admission No: ${model.admissionNo ?? '-'}'),
            if ((model.formNo ?? '').isNotEmpty)
              Text('Form No: ${model.formNo}'),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.rows});

  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ...rows
                .where((row) => (row.value ?? '').trim().isNotEmpty)
                .map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            '${row.label}:',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(child: Text(row.value ?? '-')),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _ContextError extends StatelessWidget {
  const _ContextError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 10),
            Text(
              'Could not load programme context',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow(this.label, this.value);

  final String label;
  final String? value;
}
