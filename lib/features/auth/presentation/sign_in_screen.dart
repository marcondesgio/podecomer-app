import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/auth/auth_controller.dart';
import '../../../core/data/auth/auth_repository.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/common.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_widgets.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(email: _email.text.trim(), password: _password.text);
    } on AuthFailure catch (e) {
      // E-mail não confirmado: o roteador já leva à verificação.
      if (mounted && e.kind != AuthFailureKind.emailNotConfirmed) {
        showMessage(context, authErrorMessage(AppLocalizations.of(context), e));
      }
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
      title: l10n.signInTitle,
      children: [
        const SocialSignInButtons(),
        Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  autofillHints: const [AutofillHints.password],
                  validator: (v) =>
                      (v ?? '').isEmpty ? l10n.passwordTooShort : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: Text(l10n.forgotPassword),
                  ),
                ),
                const SizedBox(height: 8),
                BusyButton(
                  label: l10n.signInAction,
                  busy: _busy,
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.pushReplacement(AppRoutes.signUp),
                  child: Text(l10n.noAccountSignUp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
