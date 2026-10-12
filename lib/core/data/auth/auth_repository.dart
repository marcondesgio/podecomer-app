import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_providers.dart';

/// Usuário autenticado (só o que o app precisa).
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.emailConfirmed,
  });

  final String id;
  final String? email;
  final bool emailConfirmed;

  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.id == id &&
      other.email == email &&
      other.emailConfirmed == emailConfirmed;

  @override
  int get hashCode => Object.hash(id, email, emailConfirmed);
}

enum AuthEvent { signedIn, signedOut, passwordRecovery, updated }

class AuthChange {
  const AuthChange(this.event, this.user);

  final AuthEvent event;
  final AppUser? user;
}

enum SocialProvider { google, apple }

enum AuthFailureKind {
  invalidCredentials,
  emailNotConfirmed,
  weakPassword,
  rateLimited,
  network,
  notConfigured,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.kind);

  final AuthFailureKind kind;

  @override
  String toString() => 'AuthFailure($kind)';
}

abstract interface class AuthRepository {
  AppUser? get currentUser;
  Stream<AuthChange> get changes;

  /// `true` se ainda falta confirmar o e-mail.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<void> signIn({required String email, required String password});

  /// Abre o fluxo OAuth no navegador; o retorno chega por [changes].
  Future<void> signInWith(SocialProvider provider);
  Future<void> resendVerification(String email);

  /// Atualiza o usuário (ex.: depois de confirmar o e-mail em outro aparelho).
  Future<void> refreshUser();
  Future<void> sendPasswordReset(String email);
  Future<void> updatePassword(String password);
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._auth);

  final GoTrueClient _auth;

  static AppUser? _map(User? user) => user == null
      ? null
      : AppUser(
          id: user.id,
          email: user.email,
          emailConfirmed: user.emailConfirmedAt != null,
        );

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AuthChange> get changes => _auth.onAuthStateChange.map(
    (state) => AuthChange(switch (state.event) {
      AuthChangeEvent.passwordRecovery => AuthEvent.passwordRecovery,
      AuthChangeEvent.signedOut => AuthEvent.signedOut,
      AuthChangeEvent.signedIn ||
      AuthChangeEvent.initialSession => AuthEvent.signedIn,
      _ => AuthEvent.updated,
    }, _map(state.session?.user)),
  );

  @override
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) => _guard(() async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
      emailRedirectTo: authRedirectUrl,
    );
    return response.session == null || response.user?.emailConfirmedAt == null;
  });

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(() => _auth.signInWithPassword(email: email, password: password));

  @override
  Future<void> signInWith(SocialProvider provider) => _guard(
    () => _auth.signInWithOAuth(switch (provider) {
      SocialProvider.google => OAuthProvider.google,
      SocialProvider.apple => OAuthProvider.apple,
    }, redirectTo: authRedirectUrl),
  );

  @override
  Future<void> resendVerification(String email) => _guard(
    () => _auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: authRedirectUrl,
    ),
  );

  @override
  Future<void> refreshUser() => _guard(_auth.refreshSession);

  @override
  Future<void> sendPasswordReset(String email) => _guard(
    () => _auth.resetPasswordForEmail(email, redirectTo: authRedirectUrl),
  );

  @override
  Future<void> updatePassword(String password) =>
      _guard(() => _auth.updateUser(UserAttributes(password: password)));

  @override
  Future<void> signOut() => _guard(_auth.signOut);

  /// Traduz erros do Supabase sem expor detalhes (nada vai para log).
  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthRetryableFetchException {
      throw const AuthFailure(AuthFailureKind.network);
    } on AuthException catch (e) {
      throw AuthFailure(switch (e.code) {
        'invalid_credentials' => AuthFailureKind.invalidCredentials,
        'email_not_confirmed' => AuthFailureKind.emailNotConfirmed,
        'weak_password' => AuthFailureKind.weakPassword,
        'over_email_send_rate_limit' ||
        'over_request_rate_limit' => AuthFailureKind.rateLimited,
        _ => AuthFailureKind.unknown,
      });
    } on SocketException {
      throw const AuthFailure(AuthFailureKind.network);
    } on TimeoutException {
      throw const AuthFailure(AuthFailureKind.network);
    }
  }
}

/// Usado quando o `.env` não tem as chaves do Supabase: o app abre
/// deslogado e qualquer ação explica que falta configuração.
class UnconfiguredAuthRepository implements AuthRepository {
  const UnconfiguredAuthRepository();

  static Never _fail() =>
      throw const AuthFailure(AuthFailureKind.notConfigured);

  @override
  AppUser? get currentUser => null;
  @override
  Stream<AuthChange> get changes => const Stream.empty();
  @override
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async => _fail();
  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async => _fail();
  @override
  Future<void> signInWith(SocialProvider provider) async => _fail();
  @override
  Future<void> resendVerification(String email) async => _fail();
  @override
  Future<void> refreshUser() async => _fail();
  @override
  Future<void> sendPasswordReset(String email) async => _fail();
  @override
  Future<void> updatePassword(String password) async => _fail();
  @override
  Future<void> signOut() async {}
}
