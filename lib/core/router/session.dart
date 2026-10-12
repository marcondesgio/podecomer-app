import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/account_providers.dart';
import '../data/auth/auth_controller.dart';

/// Em que ponto do acesso o usuário está; decide as rotas permitidas.
sealed class SessionStatus {
  const SessionStatus();
}

/// Perfil carregando.
final class SessionLoading extends SessionStatus {
  const SessionLoading();
}

final class SignedOut extends SessionStatus {
  const SignedOut();
}

/// Sem e-mail confirmado: só a tela de verificação.
final class AwaitingVerification extends SessionStatus {
  const AwaitingVerification(this.email);

  final String? email;

  @override
  bool operator ==(Object other) =>
      other is AwaitingVerification && other.email == email;

  @override
  int get hashCode => email.hashCode;
}

final class RecoveringPassword extends SessionStatus {
  const RecoveringPassword();
}

/// Sem consentimento de dados de saúde: onboarding de alergias.
final class NeedsOnboarding extends SessionStatus {
  const NeedsOnboarding();
}

final class Ready extends SessionStatus {
  const Ready();
}

/// Não foi possível carregar o perfil.
final class ProfileUnavailable extends SessionStatus {
  const ProfileUnavailable();
}

final sessionStatusProvider = Provider<SessionStatus>((ref) {
  final auth = ref.watch(authControllerProvider);
  if (auth.recoveringPassword) return const RecoveringPassword();

  final user = auth.user;
  if (user == null) {
    return auth.pendingVerificationEmail == null
        ? const SignedOut()
        : AwaitingVerification(auth.pendingVerificationEmail);
  }
  if (!user.emailConfirmed) return AwaitingVerification(user.email);

  // Mantém o último perfil durante recargas (ex.: após salvar).
  final profile = ref.watch(myProfileProvider);
  if (profile.value case final value?) {
    return value.hasHealthConsent ? const Ready() : const NeedsOnboarding();
  }
  return profile.hasError ? const ProfileUnavailable() : const SessionLoading();
});
