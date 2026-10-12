import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/account_providers.dart';
import '../../../core/data/auth/auth_controller.dart';
import '../../../core/router/session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Enquanto o perfil carrega; se falhar, oferece tentar de novo.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final failed = ref.watch(sessionStatusProvider) is ProfileUnavailable;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.screenMargin),
          child: Center(
            child: failed
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.profileUnavailable,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => ref.invalidate(myProfileProvider),
                        child: Text(l10n.retry),
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.read(authControllerProvider.notifier).signOut(),
                        child: Text(l10n.signOut),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
