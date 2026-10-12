import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/auth/auth_controller.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/common.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_widgets.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      // Com e-mail pendente, o roteador leva à tela de verificação.
      await ref
          .read(authControllerProvider.notifier)
          .signUp(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          );
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
      title: l10n.signUpTitle,
      children: [
        const SocialSignInButtons(),
        Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: l10n.nameLabel),
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? l10n.nameRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(labelText: l10n.emailLabel),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (v) => validateEmail(l10n, v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  decoration: InputDecoration(labelText: l10n.passwordLabel),
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (v) => validatePassword(l10n, v),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                BusyButton(
                  label: l10n.createAccount,
                  busy: _busy,
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.pushReplacement(AppRoutes.signIn),
                  child: Text(l10n.haveAccountSignIn),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
