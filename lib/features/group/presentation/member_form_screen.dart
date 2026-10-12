import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/data/account_providers.dart';
import '../../../core/data/group/group_repository.dart';
import '../../../core/data/people.dart';
import '../../../core/engine/models.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/allergy_selector.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/labels.dart';
import '../../../l10n/app_localizations.dart';

/// Cria ([memberId] nulo) ou edita um membro. Fecha com `true` ao salvar.
class MemberFormScreen extends ConsumerWidget {
  const MemberFormScreen({super.key, this.memberId});

  final String? memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = memberId;
    if (id == null) return const _MemberForm(member: null);

    final members = ref.watch(groupMembersProvider);
    return switch (members) {
      AsyncValue(:final value?) => _MemberForm(
        member: value.where((m) => m.id == id).firstOrNull,
      ),
      AsyncError() => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(AppLocalizations.of(context).genericError)),
      ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _MemberForm extends ConsumerStatefulWidget {
  const _MemberForm({required this.member});

  final GroupMember? member;

  @override
  ConsumerState<_MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends ConsumerState<_MemberForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.member?.name);
  late DateTime? _birthDate = widget.member?.birthDate;
  late Sex? _sex = widget.member?.sex;
  late List<PersonAllergy> _allergies = widget.member?.allergies ?? [];
  var _busy = false;

  bool get _isNew => widget.member == null;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(groupRepositoryProvider)
          .save(
            MemberDraft(
              id: widget.member?.id,
              name: _name.text.trim(),
              birthDate: _birthDate,
              sex: _sex,
              allergies: _allergies,
            ),
          );
      ref.invalidate(groupMembersProvider);
      if (mounted) context.pop(true);
    } on FreeMemberLimitReached {
      if (mounted) context.pushReplacement(AppRoutes.paywall);
    } on Object {
      if (mounted) {
        showMessage(context, AppLocalizations.of(context).genericError);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final member = widget.member!;
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDestructive(
      context,
      title: l10n.deleteMemberTitle(member.name),
      message: l10n.deleteMemberBody,
      confirmLabel: l10n.delete,
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(groupRepositoryProvider).delete(member.id);
      ref.invalidate(groupMembersProvider);
      if (mounted) context.pop(true);
    } on Object {
      if (mounted) showMessage(context, l10n.genericError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final name = _name.text.trim();
    final birthDate = _birthDate;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l10n.newMemberTitle : l10n.editMemberTitle),
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.screenMargin),
            children: [
              Center(child: PersonAvatar(name: name, radius: 36)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.nameLabel),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l10n.nameRequired : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.birthDateLabel),
                subtitle: Text(
                  birthDate == null
                      ? l10n.birthDateHelper
                      : DateFormat.yMd('pt_BR').format(birthDate),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await pickBirthDate(context, _birthDate);
                    if (picked != null) setState(() => _birthDate = picked);
                  },
                  child: Text(birthDate == null ? l10n.addAction : l10n.edit),
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.sexLabel, style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final sex in Sex.values)
                    ChoiceChip(
                      label: Text(l10n.sex(sex)),
                      selected: _sex == sex,
                      onSelected: (on) =>
                          setState(() => _sex = on ? sex : null),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                name.isEmpty
                    ? l10n.memberAllergiesDefault
                    : l10n.memberAllergies(name),
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              AllergySelector(
                value: _allergies,
                onChanged: (v) => setState(() => _allergies = v),
              ),
              const SizedBox(height: 32),
              BusyButton(label: l10n.save, busy: _busy, onPressed: _save),
              if (!_isNew) ...[
                const SizedBox(height: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: _busy ? null : _delete,
                  child: Text(l10n.removeFromGroup),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
