import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../data/auth_api.dart';
import 'auth_state.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.read(dioProvider));
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  bool _bootstrapped = false;

  @override
  AuthState build() => AuthState.initial;

  Future<void> bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    final token = await ref.read(tokenStorageProvider).readToken();
    if (token == null || token.isEmpty) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final user = await ref.read(authApiProvider).me();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await ref.read(tokenStorageProvider).clearToken();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final (token, user) = await ref
          .read(authApiProvider)
          .login(username: username, password: password);
      await ref.read(tokenStorageProvider).saveToken(token);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authApiProvider).logout();
    } catch (_) {
      // If API logout fails, still clear local token.
    }

    await ref.read(tokenStorageProvider).clearToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> handleUnauthorized() async {
    await ref.read(tokenStorageProvider).clearToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
