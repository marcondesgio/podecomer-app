import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/auth/auth_controller.dart';
import '../../../core/widgets/common.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_widgets.dart';

/// Pede o link de recuperação. A resposta é sempre a mesma, exista a conta
/// ou não, para não revelar quem tem cadastro.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  var _busy = false;
  var _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordReset(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    } on Object catch (e) {
      if (mounted) {
        showMessage(context, authErrorMessage(AppLocalizations.of(context), e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthScaffold(
      title: l10n.forgotPasswordTitle,
      children: [
        if (_sent)
          Text(l10n.resetLinkSent)
        else
          Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.forgotPasswordBody),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(labelText: l10n.emailLabel),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (v) => validateEmail(l10n, v),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                BusyButton(
                  label: l10n.sendLink,
                  busy: _busy,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Aberta pelo link de recuperação (evento passwordRecovery).
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updatePassword(_password.text);
    } on Object catch (e) {
      if (mounted) {
        showMessage(context, authErrorMessage(AppLocalizations.of(context), e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthScaffold(
      title: l10n.resetPasswordTitle,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _password,
                decoration: InputDecoration(labelText: l10n.newPasswordLabel),
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) => validatePassword(l10n, v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirm,
                decoration: InputDecoration(
                  labelText: l10n.confirmPasswordLabel,
                ),
                obscureText: true,
                validator: (v) =>
                    v == _password.text ? null : l10n.passwordsDontMatch,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              BusyButton(
                label: l10n.savePassword,
                busy: _busy,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
