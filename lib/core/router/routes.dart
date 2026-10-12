import 'session.dart';

/// Caminhos das rotas. Nunca colocar dados de saúde (alergias, gravidade,
/// status) em caminhos ou query strings.
abstract final class AppRoutes {
  static const splash = '/splash';

  static const welcome = '/welcome';
  static const signUp = '/sign-up';
  static const signIn = '/sign-in';
  static const forgotPassword = '/forgot-password';
  static const verifyEmail = '/verify-email';
  static const resetPassword = '/reset-password';

  static const onboardingAllergies = '/onboarding/allergies';
  static const onboardingGroup = '/onboarding/group';

  static const home = '/home';
  static const scanner = '/scanner';
  static const group = '/group';
  static const profile = '/profile';

  static const newMember = '/group/member/new';
  static const editMember = '/group/member/:id';
  static const profileAllergies = '/profile/allergies';
  static const paywall = '/paywall';
  static const result = '/result/:barcode';
  static const productSubmission = '/product-submission/:barcode';

  static String editMemberFor(String id) => '/group/member/$id';
  static String resultFor(String barcode) => '/result/$barcode';
  static String productSubmissionFor(String barcode) =>
      '/product-submission/$barcode';

  /// Acessíveis sem login.
  static const public = {welcome, signUp, signIn, forgotPassword};
}

/// Para onde mandar o usuário em [path], ou `null` para deixar.
String? sessionRedirect(SessionStatus status, String path) {
  String? onlyAt(String route) => path == route ? null : route;

  return switch (status) {
    SessionLoading() || ProfileUnavailable() => onlyAt(AppRoutes.splash),
    SignedOut() => AppRoutes.public.contains(path) ? null : AppRoutes.welcome,
    AwaitingVerification() => onlyAt(AppRoutes.verifyEmail),
    RecoveringPassword() => onlyAt(AppRoutes.resetPassword),
    NeedsOnboarding() => onlyAt(AppRoutes.onboardingAllergies),
    // Pronto: telas de acesso não fazem mais sentido. O onboarding continua
    // acessível (o passo 2 vem depois do consentimento).
    Ready() =>
      AppRoutes.public.contains(path) ||
              path == AppRoutes.verifyEmail ||
              path == AppRoutes.resetPassword ||
              path == AppRoutes.splash
          ? AppRoutes.home
          : null,
  };
}
