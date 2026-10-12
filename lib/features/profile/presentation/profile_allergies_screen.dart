import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/account_providers.dart';
import '../../../core/engine/models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/allergy_selector.dart';
import '../../../core/widgets/common.dart';
import '../../../l10n/app_localizations.dart';

class ProfileAllergiesScreen extends ConsumerStatefulWidget {
  const ProfileAllergiesScreen({super.key});

  @override
  ConsumerState<ProfileAllergiesScreen> createState() =>
      _ProfileAllergiesScreenState();
}

class _ProfileAllergiesScreenState
    extends ConsumerState<ProfileAllergiesScreen> {
  late List<PersonAllergy> _allergies =
      ref.read(myProfileProvider).value?.allergies ?? [];
  var _busy = false;

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref.read(profileRepositoryProvider).saveAllergies(_allergies);
      ref.invalidate(myProfileProvider);
      if (mounted) context.pop();
    } on Object {
      if (mounted) {
        showMessage(context, AppLocalizations.of(context).genericError);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myAllergiesTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.screenMargin),
          children: [
            Text(l10n.myAllergiesHint),
            const SizedBox(height: 24),
            AllergySelector(
              value: _allergies,
              onChanged: (v) => setState(() => _allergies = v),
            ),
            const SizedBox(height: 32),
            BusyButton(label: l10n.save, busy: _busy, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
