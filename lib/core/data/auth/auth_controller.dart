import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../env.dart';
import 'auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => Env.hasSupabase
      ? SupabaseAuthRepository(Supabase.instance.client.auth)
      : const UnconfiguredAuthRepository(),
);

class AuthSnapshot {
  const AuthSnapshot({
    this.user,
    this.recoveringPassword = false,
    this.pendingVerificationEmail,
  });

  final AppUser? user;

  /// Abriu o link de recuperação de senha: só a tela de nova senha.
  final bool recoveringPassword;

  /// Cadastrou (ou tentou entrar) sem e-mail confirmado e sem sessão.
  final String? pendingVerificationEmail;
}

final authControllerProvider = NotifierProvider<AuthController, AuthSnapshot>(
  AuthController.new,
);

class AuthController extends Notifier<AuthSnapshot> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  AuthSnapshot build() {
    final repo = ref.watch(authRepositoryProvider);
    final subscription = repo.changes.listen(_onChange);
    ref.onDispose(subscription.cancel);
    return AuthSnapshot(user: repo.currentUser);
  }

  void _onChange(AuthChange change) {
    state = switch (change.event) {
      AuthEvent.signedOut => const AuthSnapshot(),
      AuthEvent.passwordRecovery => AuthSnapshot(
        user: change.user,
        recoveringPassword: true,
      ),
      AuthEvent.signedIn || AuthEvent.updated => AuthSnapshot(
        user: change.user,
        recoveringPassword: state.recoveringPassword,
        pendingVerificationEmail: change.user?.emailConfirmed ?? false
            ? null
            : state.pendingVerificationEmail,
      ),
    };
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final needsVerification = await _repo.signUp(
      name: name,
      email: email,
      password: password,
    );
    if (needsVerification) {
      state = AuthSnapshot(user: state.user, pendingVerificationEmail: email);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _repo.signIn(email: email, password: password);
    } on AuthFailure catch (e) {
      if (e.kind == AuthFailureKind.emailNotConfirmed) {
        state = AuthSnapshot(pendingVerificationEmail: email);
      }
      rethrow;
    }
  }

  /// "Já confirmei": atualiza a sessão, ou volta para o login se não houver.
  Future<void> recheckVerification() async {
    if (state.user == null) {
      state = const AuthSnapshot();
      return;
    }
    await _repo.refreshUser();
    final user = _repo.currentUser;
    state = AuthSnapshot(user: user);
  }

  /// "Usar outro e-mail".
  Future<void> cancelVerification() async {
    if (state.user != null) await _repo.signOut();
    state = const AuthSnapshot();
  }

  Future<void> updatePassword(String password) async {
    await _repo.updatePassword(password);
    state = AuthSnapshot(user: state.user);
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthSnapshot();
  }

  /// A sessão já foi encerrada por fora (ex.: conta excluída).
  void markSignedOut() => state = const AuthSnapshot();
}
