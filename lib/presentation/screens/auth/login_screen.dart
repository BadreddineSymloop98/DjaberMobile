import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/form_draft_store.dart';
import '../../viewmodels/login_view_model.dart';
import '../../viewmodels/session_view_model.dart';
import '../../widgets/app_checkbox.dart';
import '../../widgets/app_text_field.dart';
import 'auth_error_message.dart';
import 'auth_scaffold.dart';

/// `05 — Connexion`.
///
/// Form behaviour only — [LoginViewModel.submit] validates and stops. Nothing
/// here talks to the backend yet.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        // Looked up optionally, so the screen still builds without the store.
        create: (context) =>
            LoginViewModel(drafts: context.read<FormDraftStore?>()),
        child: const _LoginView(),
      );
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final model = context.watch<LoginViewModel>();
    final session = context.watch<SessionViewModel>();

    void submit() {
      if (!model.submit()) return;
      // No navigation here. The router watches the session, so the redirect
      // moves to home the moment the status flips — one rule instead of a
      // `go` call on every success path.
      session.signIn(
        email: model.email.value.trim(),
        password: model.password.value,
      );
    }

    // Exhaustive on FieldError, so adding a rule later fails to compile until
    // it has a message.
    String? emailError() => switch (model.visibleError(model.email)) {
          null => null,
          FieldError.required => l10n.authErrEmailRequired,
          FieldError.invalidEmail => l10n.authErrInvalidEmail,
          FieldError.tooShort => l10n.authErrPasswordTooShort,
          // Product-form rules; no validator on this form can produce them.
          FieldError.notANumber ||
          FieldError.mustBePositive ||
          FieldError.belowCostPrice =>
            l10n.authErrEmailRequired,
        };

    String? passwordError() => switch (model.visibleError(model.password)) {
          null => null,
          FieldError.required => l10n.authErrPasswordRequired,
          FieldError.invalidEmail => l10n.authErrInvalidEmail,
          FieldError.tooShort => l10n.authErrPasswordTooShort,
          // Product-form rules; no validator on this form can produce them.
          FieldError.notANumber ||
          FieldError.mustBePositive ||
          FieldError.belowCostPrice =>
            l10n.authErrPasswordRequired,
        };

    return AuthScaffold(
      title: l10n.authLoginTitle,
      subtitle: l10n.authLoginSubtitle,
      footer: AuthFooter(
        question: l10n.authNoAccount,
        action: l10n.authSignupLink,
        onTap: () => context.go(Routes.signup),
      ),
      children: [
        AppTextField(
          label: l10n.authEmail,
          controller: model.email.controller,
          focusNode: model.email.focusNode,
          placeholder: l10n.authEmailPlaceholder,
          errorText: emailError(),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username, AutofillHints.email],
          // An address never contains a space, and one pasted in from another
          // app is the commonest reason a valid login is rejected. Blocked at
          // the keyboard rather than trimmed later, so what the merchant sees
          // is exactly what gets sent.
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            LengthLimitingTextInputFormatter(254),
          ],
          onSubmitted: (_) => model.password.focusNode.requestFocus(),
        ),
        SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: l10n.authPassword,
          controller: model.password.controller,
          focusNode: model.password.focusNode,
          placeholder: '••••••••',
          errorText: passwordError(),
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          // Deliberately no character filter. A space is a legal password
          // character, and stripping one would change the merchant's secret
          // without telling them. Only an upper bound.
          inputFormatters: [LengthLimitingTextInputFormatter(128)],
          onSubmitted: (_) => submit(),
        ),
        SizedBox(height: AppSpacing.lg),
        AppCheckbox(
          label: l10n.authRemember,
          value: model.rememberMe,
          onChanged: (_) => model.toggleRememberMe(),
        ),
        SizedBox(height: AppSpacing.lg),
        AuthErrorMessage(error: session.error),
        AuthSubmitButton(
          label: l10n.authLoginSubmit,
          onPressed: submit,
          isLoading: session.isBusy,
        ),
        SizedBox(height: AppSpacing.lg),
        Center(
          child: GestureDetector(
            onTap: () => context.go(Routes.forgotPassword),
            behavior: HitTestBehavior.opaque,
            child: Text(l10n.authForgot, style: AppText.link),
          ),
        ),
      ],
    );
  }
}

