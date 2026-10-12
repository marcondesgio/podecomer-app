import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/auth/auth_controller.dart';
import '../../../core/data/auth/auth_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../l10n/app_localizations.dart';

/// Mensagem para o usuário; nunca expõe detalhes técnicos.
String authErrorMessage(AppLocalizations l10n, Object error) => switch (error) {
  AuthFailure(kind: AuthFailureKind.invalidCredentials) =>
    l10n.authInvalidCredentials,
  AuthFailure(kind: AuthFailureKind.weakPassword) => l10n.authWeakPassword,
  AuthFailure(kind: AuthFailureKind.rateLimited) => l10n.authRateLimited,
  AuthFailure(kind: AuthFailureKind.network) => l10n.networkError,
  AuthFailure(kind: AuthFailureKind.notConfigured) => l10n.authNotConfigured,
  _ => l10n.genericError,
};

String? validateEmail(AppLocalizations l10n, String? value) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value?.trim() ?? '')
    ? null
    : l10n.emailInvalid;

String? validatePassword(AppLocalizations l10n, String? value) =>
    (value ?? '').length >= 8 ? null : l10n.passwordTooShort;

/// Layout comum das telas de acesso.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.screenMargin),
        children: [
          if (title case final title?) ...[
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
          ],
          ...children,
        ],
      ),
    ),
  );
}

/// "Continuar com Google / Apple" + "ou com e-mail".
class SocialSignInButtons extends ConsumerStatefulWidget {
  const SocialSignInButtons({super.key});

  @override
  ConsumerState<SocialSignInButtons> createState() =>
      _SocialSignInButtonsState();
}

class _SocialSignInButtonsState extends ConsumerState<SocialSignInButtons> {
  SocialProvider? _busy;

  Future<void> _signIn(SocialProvider provider) async {
    setState(() => _busy = provider);
    try {
      await ref.read(authRepositoryProvider).signInWith(provider);
    } on Object catch (e) {
      if (mounted) {
        showMessage(context, authErrorMessage(AppLocalizations.of(context), e));
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget button(SocialProvider provider, IconData icon, String label) =>
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppSizes.minTouchTarget + 8),
          ),
          onPressed: _busy == null ? () => _signIn(provider) : null,
          icon: Icon(icon),
          label: Text(label),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        button(
          SocialProvider.google,
          Icons.g_mobiledata,
          l10n.continueWithGoogle,
        ),
        const SizedBox(height: 12),
        button(SocialProvider.apple, Icons.apple, l10n.continueWithApple),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(l10n.orWithEmail),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
