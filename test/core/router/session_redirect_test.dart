import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/router/routes.dart';
import 'package:pode_comer/core/router/session.dart';

void main() {
  const protected = [
    AppRoutes.home,
    AppRoutes.group,
    AppRoutes.profile,
    AppRoutes.paywall,
    '/result/7891000100103',
    '/group/member/new',
  ];

  group('deslogado', () {
    for (final path in AppRoutes.public) {
      test('acessa $path', () {
        expect(sessionRedirect(const SignedOut(), path), isNull);
      });
    }
    for (final path in [...protected, AppRoutes.onboardingAllergies]) {
      test('$path → boas-vindas', () {
        expect(sessionRedirect(const SignedOut(), path), AppRoutes.welcome);
      });
    }
  });

  group('sem e-mail verificado: só a verificação', () {
    const status = AwaitingVerification('ana@email.com');
    test('fica na verificação', () {
      expect(sessionRedirect(status, AppRoutes.verifyEmail), isNull);
    });
    for (final path in [
      ...protected,
      ...AppRoutes.public,
      AppRoutes.onboardingAllergies,
    ]) {
      test('$path → verificação', () {
        expect(sessionRedirect(status, path), AppRoutes.verifyEmail);
      });
    }
  });

  test('recuperando senha: só a tela de nova senha', () {
    expect(
      sessionRedirect(const RecoveringPassword(), AppRoutes.home),
      AppRoutes.resetPassword,
    );
    expect(
      sessionRedirect(const RecoveringPassword(), AppRoutes.resetPassword),
      isNull,
    );
  });

  test('sem consentimento: só o onboarding de alergias', () {
    expect(
      sessionRedirect(const NeedsOnboarding(), AppRoutes.group),
      AppRoutes.onboardingAllergies,
    );
    expect(
      sessionRedirect(const NeedsOnboarding(), AppRoutes.onboardingAllergies),
      isNull,
    );
  });

  test('carregando ou erro de perfil: splash', () {
    expect(
      sessionRedirect(const SessionLoading(), AppRoutes.home),
      AppRoutes.splash,
    );
    expect(
      sessionRedirect(const ProfileUnavailable(), AppRoutes.group),
      AppRoutes.splash,
    );
  });

  group('pronto', () {
    for (final path in [
      ...AppRoutes.public,
      AppRoutes.verifyEmail,
      AppRoutes.splash,
    ]) {
      test('$path → início', () {
        expect(sessionRedirect(const Ready(), path), AppRoutes.home);
      });
    }
    for (final path in [...protected, AppRoutes.onboardingGroup]) {
      test('acessa $path', () {
        expect(sessionRedirect(const Ready(), path), isNull);
      });
    }
  });
}
