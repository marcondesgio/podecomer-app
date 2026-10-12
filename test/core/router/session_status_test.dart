import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/data/account_providers.dart';
import 'package:pode_comer/core/data/auth/auth_controller.dart';
import 'package:pode_comer/core/data/auth/auth_repository.dart';
import 'package:pode_comer/core/router/session.dart';

import '../../support/account_fakes.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeProfileRepository profiles;
  late ProviderContainer container;

  void start({AppUser? user, bool consent = true}) {
    auth = FakeAuthRepository(currentUser: user);
    profiles = FakeProfileRepository(profileOf(consent: consent));
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(profiles),
      ],
    );
    addTearDown(container.dispose);
    // Mantém o controller vivo e ouvindo os eventos de auth.
    container.listen(sessionStatusProvider, (_, _) {});
  }

  /// Espera eventos e o carregamento do perfil terminarem.
  Future<SessionStatus> settled() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
      if (container.read(sessionStatusProvider) is! SessionLoading) break;
    }
    return container.read(sessionStatusProvider);
  }

  test('sem usuário → deslogado', () async {
    start();
    expect(await settled(), isA<SignedOut>());
  });

  test('cadastro sem sessão → aguardando verificação com o e-mail', () async {
    start();
    await container
        .read(authControllerProvider.notifier)
        .signUp(name: 'Ana', email: 'ana@email.com', password: '12345678');
    expect(await settled(), const AwaitingVerification('ana@email.com'));
  });

  test('login com e-mail não confirmado → aguardando verificação', () async {
    start();
    await expectLater(
      container
          .read(authControllerProvider.notifier)
          .signIn(email: 'pendente@email.com', password: 'x'),
      throwsA(isA<AuthFailure>()),
    );
    expect(await settled(), const AwaitingVerification('pendente@email.com'));
  });

  test('sessão com e-mail não confirmado → aguardando verificação', () async {
    start(
      user: const AppUser(id: 'u', email: 'a@b.com', emailConfirmed: false),
    );
    expect(await settled(), const AwaitingVerification('a@b.com'));
  });

  test('e-mail confirmado pelo deep link → sai da verificação', () async {
    start();
    await container
        .read(authControllerProvider.notifier)
        .signUp(name: 'Ana', email: 'ana@email.com', password: '12345678');
    auth.emit(AuthEvent.signedIn, confirmedUser);
    expect(await settled(), isA<Ready>());
  });

  test('confirmado sem consentimento → onboarding', () async {
    start(user: confirmedUser, consent: false);
    expect(await settled(), isA<NeedsOnboarding>());
  });

  test('confirmado com consentimento → pronto', () async {
    start(user: confirmedUser);
    expect(await settled(), isA<Ready>());
  });

  test('link de recuperação → recuperando senha', () async {
    start(user: confirmedUser);
    auth.emit(AuthEvent.passwordRecovery, confirmedUser);
    expect(await settled(), isA<RecoveringPassword>());

    await container
        .read(authControllerProvider.notifier)
        .updatePassword('nova-senha');
    expect(await settled(), isA<Ready>());
  });

  test('sair → deslogado', () async {
    start(user: confirmedUser);
    await settled();
    await container.read(authControllerProvider.notifier).signOut();
    expect(await settled(), isA<SignedOut>());
  });
}
