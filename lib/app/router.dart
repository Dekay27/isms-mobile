import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/application/auth_state.dart';
import '../features/auth/presentation/change_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/fees/presentation/fees_billing_screen.dart';
import '../features/fees/presentation/fees_payments_screen.dart';
import '../features/fees/presentation/fees_summary_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/programme_context/presentation/programme_context_screen.dart';
import '../features/results/domain/results_models.dart';
import '../features/results/presentation/results_semester_screen.dart';
import '../features/results/presentation/results_slip_screen.dart';
import '../features/results/presentation/results_summary_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/change-password',
        builder: (_, _) => const ChangePasswordScreen(),
      ),
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      GoRoute(
        path: '/programme-context',
        builder: (_, _) => const ProgrammeContextScreen(),
      ),
      GoRoute(
        path: '/results',
        builder: (_, _) => const ResultsSummaryScreen(),
      ),
      GoRoute(
        path: '/results/semester',
        builder: (_, state) {
          final academicYear =
              (state.uri.queryParameters['academic_year'] ?? '').trim();
          final semesterId = (state.uri.queryParameters['semester_id'] ?? '')
              .trim();
          final semester = state.uri.queryParameters['semester'];

          if (academicYear.isEmpty || semesterId.isEmpty) {
            return const _MissingTermParamsScreen();
          }

          return ResultsSemesterScreen(
            filter: ResultsTermFilter(
              academicYear: academicYear,
              semesterId: semesterId,
              semester: semester,
            ),
          );
        },
      ),
      GoRoute(
        path: '/results/slip',
        builder: (_, state) {
          final academicYear =
              (state.uri.queryParameters['academic_year'] ?? '').trim();
          final semesterId = (state.uri.queryParameters['semester_id'] ?? '')
              .trim();
          final semester = state.uri.queryParameters['semester'];

          if (academicYear.isEmpty || semesterId.isEmpty) {
            return const _MissingTermParamsScreen();
          }

          return ResultsSlipScreen(
            filter: ResultsTermFilter(
              academicYear: academicYear,
              semesterId: semesterId,
              semester: semester,
            ),
          );
        },
      ),
      GoRoute(path: '/fees', builder: (_, _) => const FeesSummaryScreen()),
      GoRoute(
        path: '/fees/payments',
        builder: (_, _) => const FeesPaymentsScreen(),
      ),
      GoRoute(
        path: '/fees/billing',
        builder: (_, _) => const FeesBillingScreen(),
      ),
    ],
    redirect: (_, state) {
      final isLoading =
          authState.status == AuthStatus.unknown ||
          authState.status == AuthStatus.loading;
      if (isLoading) {
        return null;
      }

      final isLoggedIn = authState.isAuthenticated;
      final isOnLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isOnLogin) {
        return '/login';
      }

      if (isLoggedIn && isOnLogin) {
        return '/';
      }

      return null;
    },
  );
});

class _MissingTermParamsScreen extends StatelessWidget {
  const _MissingTermParamsScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Missing required term parameters (academic_year and semester_id).',
          ),
        ),
      ),
    );
  }
}
