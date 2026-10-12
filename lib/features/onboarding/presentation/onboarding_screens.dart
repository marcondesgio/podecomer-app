import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/account_providers.dart';
import '../../../core/engine/models.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/allergy_selector.dart';
import '../../../core/widgets/common.dart';
import '../../../l10n/app_localizations.dart';

/// Passo 1: alergias do titular + consentimento LGPD (obrigatório).
class OnboardingAllergiesScreen extends ConsumerStatefulWidget {
  const OnboardingAllergiesScreen({super.key});

  @override
  ConsumerState<OnboardingAllergiesScreen> createState() =>
      _OnboardingAllergiesScreenState();
}

class _OnboardingAllergiesScreenState
    extends ConsumerState<OnboardingAllergiesScreen> {
  var _allergies = <PersonAllergy>[];
  var _consent = false;
  var _busy = false;

  Future<void> _continue() async {
    setState(() => _busy = true);
    try {
      await ref.read(profileRepositoryProvider).completeOnboarding(_allergies);
      ref.invalidate(myProfileProvider);
      if (mounted) context.go(AppRoutes.onboardingGroup);
    } on Object {
      if (mounted) {
        showMessage(context, AppLocalizations.of(context).genericError);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _explainData() {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.howWeUseData),
        content: Text(l10n.howWeUseDataBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.screenMargin),
          children: [
            Text(l10n.onboardingStep1, style: textTheme.bodySmall),
            const SizedBox(height: 16),
            Text(l10n.myAllergiesTitle, style: textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(l10n.myAllergiesHint),
            const SizedBox(height: 24),
            AllergySelector(
              value: _allergies,
              onChanged: (v) => setState(() => _allergies = v),
            ),
            const SizedBox(height: 24),
            CheckboxListTile(
              key: const ValueKey('health-consent'),
              value: _consent,
              onChanged: (v) => setState(() => _consent = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.healthConsent),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _explainData,
                child: Text(l10n.howWeUseData),
              ),
            ),
            const SizedBox(height: 16),
            BusyButton(
              label: l10n.continueLabel,
              busy: _busy,
              onPressed: _consent ? _continue : null,
            ),
            if (!_consent) ...[
              const SizedBox(height: 8),
              Text(
                l10n.consentRequired,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Passo 2 (opcional): convida a adicionar membros.
class OnboardingGroupScreen extends StatelessWidget {
  const OnboardingGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.onboardingStep2, style: textTheme.bodySmall),
              const Spacer(),
              Icon(
                Icons.diversity_1_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(l10n.whoElseTitle, style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(l10n.whoElseBody),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  final saved = await context.push<bool>(AppRoutes.newMember);
                  if (saved == true && context.mounted) {
                    context.go(AppRoutes.home);
                  }
                },
                child: Text(l10n.addMember),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(l10n.skipForNow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
