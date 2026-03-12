import '../domain/api_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthState {
  const AuthState({required this.status, this.user, this.error});

  final AuthStatus status;
  final ApiUser? user;
  final String? error;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    ApiUser? user,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }

  static const AuthState initial = AuthState(status: AuthStatus.unknown);
}
