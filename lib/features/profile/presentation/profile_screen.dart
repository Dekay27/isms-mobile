import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/platform_adaptive.dart';
import '../../auth/application/auth_controller.dart';
import '../application/profile_provider.dart';
import '../domain/student_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    if (isCupertinoPlatform(context)) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Profile'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => ref.invalidate(profileProvider),
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
          child: profileAsync.when(
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error, _) => _ProfileError(
              isCupertino: true,
              message: error.toString(),
              onRetry: () => ref.invalidate(profileProvider),
            ),
            data: (profile) => CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async => ref.refresh(profileProvider.future),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _HeaderCard(profile: profile, isCupertino: true),
                        const SizedBox(height: 12),
                        _SectionCard(
                          isCupertino: true,
                          title: 'Academic',
                          rows: [
                            _info('Admission No', profile.admissionNo),
                            _info('Form No', profile.formNo),
                            _info(
                              'Programme',
                              _join(
                                profile.programmeCode,
                                profile.programmeName,
                              ),
                            ),
                            _info(
                              'Level',
                              _join(profile.level, profile.levelDescription),
                            ),
                            _info(
                              'Semester',
                              _join(profile.semesterId, profile.semester),
                            ),
                            _info('School', profile.school),
                            _info('Academic Year', profile.academicYear),
                            _info('Status', profile.status),
                            _info('Intake', profile.intake),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _SectionCard(
                          isCupertino: true,
                          title: 'Structure',
                          rows: [
                            _info(
                              'Department',
                              _join(
                                profile.departmentCode,
                                profile.departmentName,
                              ),
                            ),
                            _info(
                              'Faculty',
                              _join(profile.facultyCode, profile.facultyName),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _SectionCard(
                          isCupertino: true,
                          title: 'Contact',
                          rows: [
                            _info('Telephone', profile.telephone),
                            _info('Telephone 1', profile.telephone1),
                            _info('Telephone 2', profile.telephone2),
                            _info('Email', profile.email),
                            _info('Email 2', profile.email2),
                            _info('Region', profile.region),
                            _info('Country', profile.countryOfOrigin),
                          ],
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
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(profileProvider),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh profile',
          ),
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ProfileError(
          isCupertino: false,
          message: error.toString(),
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (profile) => RefreshIndicator(
          onRefresh: () async => ref.refresh(profileProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderCard(profile: profile, isCupertino: false),
              const SizedBox(height: 12),
              _SectionCard(
                isCupertino: false,
                title: 'Academic',
                rows: [
                  _info('Admission No', profile.admissionNo),
                  _info('Form No', profile.formNo),
                  _info(
                    'Programme',
                    _join(profile.programmeCode, profile.programmeName),
                  ),
                  _info(
                    'Level',
                    _join(profile.level, profile.levelDescription),
                  ),
                  _info(
                    'Semester',
                    _join(profile.semesterId, profile.semester),
                  ),
                  _info('School', profile.school),
                  _info('Academic Year', profile.academicYear),
                  _info('Status', profile.status),
                  _info('Intake', profile.intake),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                isCupertino: false,
                title: 'Structure',
                rows: [
                  _info(
                    'Department',
                    _join(profile.departmentCode, profile.departmentName),
                  ),
                  _info(
                    'Faculty',
                    _join(profile.facultyCode, profile.facultyName),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                isCupertino: false,
                title: 'Contact',
                rows: [
                  _info('Telephone', profile.telephone),
                  _info('Telephone 1', profile.telephone1),
                  _info('Telephone 2', profile.telephone2),
                  _info('Email', profile.email),
                  _info('Email 2', profile.email2),
                  _info('Region', profile.region),
                  _info('Country', profile.countryOfOrigin),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _join(String? left, String? right) {
    final l = left?.trim();
    final r = right?.trim();
    if ((l == null || l.isEmpty) && (r == null || r.isEmpty)) return null;
    if (l == null || l.isEmpty) return r;
    if (r == null || r.isEmpty) return l;
    return '$l - $r';
  }

  static _InfoRow _info(String label, Object? value) =>
      _InfoRow(label, value?.toString());
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile, required this.isCupertino});

  final StudentProfile profile;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.fullName ?? _fallbackName(profile),
            style: isCupertino
                ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                : Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text('Admission No: ${profile.admissionNo}'),
          if ((profile.sex ?? '').isNotEmpty) Text('Gender: ${profile.sex}'),
        ],
      ),
    );

    if (isCupertino) {
      return Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1A696CFF)),
        ),
        child: child,
      );
    }

    return Card(child: child);
  }

  String _fallbackName(StudentProfile p) {
    return [
      p.surname,
      p.firstName,
      p.otherNames,
    ].where((x) => (x ?? '').trim().isNotEmpty).join(' ').trim();
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.rows,
    required this.isCupertino,
  });

  final String title;
  final List<_InfoRow> rows;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: isCupertino
                ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                : Theme.of(context).textTheme.titleMedium,
          ),
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
                        width: 130,
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
    );

    if (isCupertino) {
      return Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x1A696CFF)),
        ),
        child: body,
      );
    }

    return Card(child: body);
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({
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
            const SizedBox(height: 10),
            Text(
              'Could not load profile',
              style: isCupertino
                  ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                  : Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            retry,
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
