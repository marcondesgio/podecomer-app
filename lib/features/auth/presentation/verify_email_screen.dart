import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/auth/auth_controller.dart';
import '../../../core/router/session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_widgets.dart';

/// Única tela acessível enquanto o e-mail não é confirmado. A confirmação
/// chega pelo deep link e o roteador sai daqui sozinho.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const _cooldown = 60;
  var _secondsLeft = 0;
  var _busy = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } on Object catch (e) {
      if (mounted) {
        showMessage(context, authErrorMessage(AppLocalizations.of(context), e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend(String email) => _run(() async {
    await ref.read(authRepositoryProvider).resendVerification(email);
    if (!mounted) return;
    showMessage(context, AppLocalizations.of(context).resent);
    setState(() => _secondsLeft = _cooldown);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _secondsLeft <= 1) timer.cancel();
      if (mounted) setState(() => _secondsLeft--);
    });
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final status = ref.watch(sessionStatusProvider);
    final email = status is AwaitingVerification ? status.email : null;
    final controller = ref.read(authControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.screenMargin),
          children: [
            const SizedBox(height: 48),
            Icon(
              Icons.mark_email_unread_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(l10n.verifyEmailTitle, style: textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(l10n.verifyEmailBody),
            if (email != null) Text(email, style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(l10n.verifyEmailHint, style: textTheme.bodySmall),
            const SizedBox(height: 32),
            BusyButton(
              label: l10n.alreadyConfirmed,
              busy: _busy,
              onPressed: () => _run(controller.recheckVerification),
            ),
            const SizedBox(height: 8),
            if (email != null)
              OutlinedButton(
                onPressed: _busy || _secondsLeft > 0
                    ? null
                    : () => _resend(email),
                child: Text(
                  _secondsLeft > 0 ? l10n.resendIn(_secondsLeft) : l10n.resend,
                ),
              ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => _run(controller.cancelVerification),
              child: Text(l10n.useAnotherEmail),
            ),
          ],
        ),
      ),
    );
  }
}
