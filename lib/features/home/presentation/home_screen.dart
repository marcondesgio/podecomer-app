import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/account_providers.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/labels.dart';
import '../../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(myProfileProvider).value;
    final members = ref.watch(groupMembersProvider).value ?? const [];
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final people = [
      (profile.name, profile.avatarPath, profile.allergies),
      for (final m in members) (m.name, m.avatarPath, m.allergies),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.screenMargin),
          children: [
            Text(l10n.helloName(profile.name), style: textTheme.headlineMedium),
            Text(l10n.homeQuestion),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(l10n.myGroupLabel, style: textTheme.titleMedium),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.group),
                  child: Text(l10n.edit),
                ),
              ],
            ),
            SizedBox(
              height: 128,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: people.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, i) {
                  final (name, avatar, allergies) = people[i];
                  return SizedBox(
                    width: 96,
                    child: Column(
                      children: [
                        PersonAvatar(name: name, avatarPath: avatar),
                        const SizedBox(height: 4),
                        Text(name, overflow: TextOverflow.ellipsis),
                        for (final a in allergies.take(2))
                          Text(
                            l10n.allergen(a.allergen),
                            style: textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l10n.checkProduct),
              onPressed: () => context.push(AppRoutes.scanner),
            ),
          ],
        ),
      ),
    );
  }
}
