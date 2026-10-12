import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/data/account_providers.dart';
import '../../../core/data/auth/auth_controller.dart';
import '../../../core/data/links.dart';
import '../../../core/data/people.dart';
import '../../../core/data/profile/profile_repository.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/allergy_selector.dart';
import '../../../core/widgets/common.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(myProfileProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : _ProfileBody(profile: profile),
    );
  }
}

class _ProfileBody extends ConsumerStatefulWidget {
  const _ProfileBody({required this.profile});

  final Profile profile;

  @override
  ConsumerState<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<_ProfileBody> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late DateTime? _birthDate = widget.profile.birthDate;
  var _busy = false;

  bool get _dirty =>
      _name.text.trim() != widget.profile.name ||
      _birthDate != widget.profile.birthDate;

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

  Future<void> _guard(Future<void> Function() action, {String? done}) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      if (mounted && done != null) showMessage(context, done);
    } on Object {
      if (mounted) showMessage(context, l10n.genericError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    await _guard(() async {
      await ref
          .read(profileRepositoryProvider)
          .update(name: _name.text.trim(), birthDate: _birthDate);
      ref.invalidate(myProfileProvider);
    }, done: AppLocalizations.of(context).saved);
  }

  Future<void> _changePhoto() async {
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.takePhoto),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.chooseFromGallery),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    // Pequena e em JPEG: é só a foto do perfil.
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );
    if (file == null || !mounted) return;
    await _guard(() async {
      await ref
          .read(profileRepositoryProvider)
          .uploadAvatar(await file.readAsBytes());
      ref.invalidate(myProfileProvider);
    });
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDestructive(
      context,
      title: l10n.deleteAccountTitle,
      message: l10n.deleteAccountBody,
      confirmLabel: l10n.deleteAccountConfirm,
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(profileRepositoryProvider).deleteAccount();
      // Sem sessão, o roteador volta para as boas-vindas.
      ref.read(authControllerProvider.notifier).markSignedOut();
    } on Object {
      if (mounted) showMessage(context, l10n.deleteAccountFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final profile = widget.profile;
    final email = ref.watch(authControllerProvider).user?.email;
    final birthDate = _birthDate;

    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.screenMargin),
        children: [
          Row(
            children: [
              Stack(
                children: [
                  PersonAvatar(
                    name: profile.name,
                    avatarPath: profile.avatarPath,
                    radius: 36,
                  ),
                  Positioned(
                    right: -8,
                    bottom: -8,
                    child: IconButton.filledTonal(
                      tooltip: l10n.changePhoto,
                      onPressed: _busy ? null : _changePhoto,
                      icon: const Icon(Icons.photo_camera_outlined, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: textTheme.titleLarge),
                    if (email != null) Text(email, style: textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.myAllergiesTitle,
                  style: textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.profileAllergies),
                child: Text(l10n.edit),
              ),
            ],
          ),
          AllergyChips(allergies: profile.allergies),
          const SizedBox(height: 24),
          TextFormField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.nameLabel),
            textCapitalization: TextCapitalization.words,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? l10n.nameRequired : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: email,
            enabled: false,
            decoration: InputDecoration(labelText: l10n.emailLabel),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.birthDateOptional),
            subtitle: birthDate == null
                ? null
                : Text(DateFormat.yMd('pt_BR').format(birthDate)),
            trailing: TextButton(
              onPressed: () async {
                final picked = await pickBirthDate(context, _birthDate);
                if (picked != null) setState(() => _birthDate = picked);
              },
              child: Text(birthDate == null ? l10n.addAction : l10n.edit),
            ),
          ),
          if (_dirty) ...[
            const SizedBox(height: 8),
            BusyButton(label: l10n.saveChanges, busy: _busy, onPressed: _save),
          ],
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.currentPlan,
                          style: textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        profile.plan == Plan.free
                            ? l10n.planFreeSummary
                            : l10n.planFamilySummary,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Text(
                    profile.plan == Plan.free ? l10n.planFree : l10n.planFamily,
                    style: textTheme.titleLarge,
                  ),
                  if (profile.plan == Plan.free)
                    TextButton(
                      onPressed: () => context.push(AppRoutes.paywall),
                      child: Text(l10n.knowFamilyPlan),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            onTap: () => openLink(LegalLinks.privacy),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.termsOfUse),
            onTap: () => openLink(LegalLinks.terms),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _busy
                ? null
                : () => ref.read(authControllerProvider.notifier).signOut(),
            child: Text(l10n.signOut),
          ),
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: _busy ? null : _deleteAccount,
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
  }
}
