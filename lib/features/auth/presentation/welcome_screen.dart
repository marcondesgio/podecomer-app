import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                l10n.appTitle,
                style: textTheme.displaySmall?.copyWith(color: scheme.primary),
              ),
              const SizedBox(height: 12),
              Text(l10n.tagline, style: textTheme.headlineSmall),
              const Spacer(),
              Text(l10n.supportDisclaimer, style: textTheme.bodySmall),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push(AppRoutes.signUp),
                child: Text(l10n.start),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.push(AppRoutes.signIn),
                child: Text(l10n.haveAccountSignIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
