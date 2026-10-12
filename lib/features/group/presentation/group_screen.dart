import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/account_providers.dart';
import '../../../core/data/group/group_repository.dart';
import '../../../core/data/people.dart';
import '../../../core/data/profile/profile_repository.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/allergy_selector.dart';
import '../../../core/widgets/common.dart';
import '../../../l10n/app_localizations.dart';

class GroupScreen extends ConsumerWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(myProfileProvider).value;
    final members = ref.watch(groupMembersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.groupTitle)),
      body: switch (members) {
        AsyncValue(:final value?) when profile != null => _GroupList(
          profile: profile,
          members: value,
        ),
        AsyncError() => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.genericError),
              TextButton(
                onPressed: () => ref.invalidate(groupMembersProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _GroupList extends ConsumerWidget {
  const _GroupList({required this.profile, required this.members});

  final Profile profile;
  final List<GroupMember> members;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    GroupMember member,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDestructive(
      context,
      title: l10n.deleteMemberTitle(member.name),
      message: l10n.deleteMemberBody,
      confirmLabel: l10n.delete,
    );
    if (!confirmed) return;
    try {
      await ref.read(groupRepositoryProvider).delete(member.id);
      ref.invalidate(groupMembersProvider);
    } on Object {
      if (context.mounted) showMessage(context, l10n.genericError);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final canAdd = profile.plan.allowsAnotherMember(members.length);
    final today = DateTime.now();

    return ListView(
      padding: const EdgeInsets.all(AppSizes.screenMargin),
      children: [
        Text(l10n.peopleCount(members.length + 1), style: textTheme.bodySmall),
        const SizedBox(height: 12),
        _PersonCard(
          avatar: PersonAvatar(
            name: profile.name,
            avatarPath: profile.avatarPath,
          ),
          title: l10n.youSuffix(profile.name),
          subtitle: l10n.accountOwner,
          allergies: AllergyChips(allergies: profile.allergies),
        ),
        for (final member in members)
          _PersonCard(
            key: ValueKey('member-${member.id}'),
            avatar: PersonAvatar(
              name: member.name,
              avatarPath: member.avatarPath,
            ),
            title: member.name,
            subtitle: switch (member.birthDate) {
              final birth? => l10n.ageYears(ageInYears(birth, today)),
              null => null,
            },
            allergies: AllergyChips(allergies: member.allergies),
            onTap: () => context.push(AppRoutes.editMemberFor(member.id)),
            trailing: PopupMenuButton<String>(
              onSelected: (action) => action == 'edit'
                  ? context.push(AppRoutes.editMemberFor(member.id))
                  : _delete(context, ref, member),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
              ],
            ),
          ),
        if (profile.plan == Plan.free) ...[
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(l10n.freePlanBanner, style: textTheme.bodySmall),
              TextButton(
                onPressed: () => context.push(AppRoutes.paywall),
                child: Text(l10n.seeFamilyPlan),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.person_add_alt_1),
          label: Text(l10n.addMember),
          // Acima do limite do plano, o paywall abre direto.
          onPressed: () =>
              context.push(canAdd ? AppRoutes.newMember : AppRoutes.paywall),
        ),
      ],
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    super.key,
    required this.avatar,
    required this.title,
    required this.allergies,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final Widget avatar;
  final String title;
  final String? subtitle;
  final Widget allergies;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    if (subtitle case final subtitle?)
                      Text(subtitle, style: textTheme.bodySmall),
                    const SizedBox(height: 8),
                    allergies,
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
