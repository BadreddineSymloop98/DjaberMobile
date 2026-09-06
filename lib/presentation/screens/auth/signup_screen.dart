import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/session_view_model.dart';
import '../../viewmodels/signup_view_model.dart';
import '../../widgets/app_text_field.dart';
import 'auth_error_message.dart';
import 'auth_scaffold.dart';

/// `06 — Créer un compte`.
///
/// Fields mirror `POST /api/auth/register`. Form behaviour only — nothing here
/// talks to the backend yet.
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => SignupViewModel(),
        child: const _SignupView(),
      );
}

class _SignupView extends StatelessWidget {
  const _SignupView();

  /// Letters, marks, spaces, hyphens and apostrophes — nothing else.
  ///
  /// Unicode-aware on purpose: `\p{L}` keeps Arabic and accented French names
  /// working, which `[a-zA-Z]` would reject. `\p{M}` keeps combining marks, so
  /// a decomposed "é" is not silently torn apart as it is typed.
  static final _nameFilter = FilteringTextInputFormatter.allow(
    RegExp(r"[\p{L}\p{M} '’\-]", unicode: true),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final model = context.watch<SignupViewModel>();
    final session = context.watch<SessionViewModel>();

    void submit() {
      if (!model.submit()) return;
      // `plan` is not collected here, so the backend defaults it to
      // "individual" — brief Q3 (owner or team) as a concrete gap.
      session.signUp(
        firstName: model.firstName.value.trim(),
        lastName: model.lastName.value.trim(),
        email: model.email.value.trim(),
        password: model.password.value,
      );
    }

    String? nameError(field, String message) =>
        switch (model.visibleError(field)) {
          null => null,
          _ => message,
        };

    String? emailError() => switch (model.visibleError(model.email)) {
          null => null,
          FieldError.required => l10n.authErrEmailRequired,
          FieldError.invalidEmail => l10n.authErrInvalidEmail,
          FieldError.tooShort => l10n.authErrPasswordTooShort,
        };

    String? passwordError() => switch (model.visibleError(model.password)) {
          null => null,
          FieldError.required => l10n.authErrPasswordRequired,
          FieldError.tooShort => l10n.authErrPasswordTooShort,
          FieldError.invalidEmail => l10n.authErrInvalidEmail,
        };

    return AuthScaffold(
      title: l10n.authSignupTitle,
      subtitle: l10n.authSignupSubtitle,
      footer: AuthFooter(
        question: l10n.authHaveAccount,
        action: l10n.authSigninLink,
        onTap: () => context.go(Routes.login),
      ),
      children: [
        // Prénom and Nom are stacked, not side by side. Half-width fields left
        // an error message no room — "Le prénom est requis" wrapped to two
        // lines under a 171dp field and shifted the one beside it.
        AppTextField(
          isRequired: true,
          label: l10n.authFirstName,
          controller: model.firstName.controller,
          focusNode: model.firstName.focusNode,
          placeholder: l10n.authFirstNamePlaceholder,
          errorText: nameError(model.firstName, l10n.authErrFirstNameRequired),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.givenName],
          inputFormatters: [_nameFilter, LengthLimitingTextInputFormatter(50)],
          onSubmitted: (_) => model.lastName.focusNode.requestFocus(),
        ),
        SizedBox(height: AppSpacing.lg),
        AppTextField(
          isRequired: true,
          label: l10n.authLastName,
          controller: model.lastName.controller,
          focusNode: model.lastName.focusNode,
          placeholder: l10n.authLastNamePlaceholder,
          errorText: nameError(model.lastName, l10n.authErrLastNameRequired),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.familyName],
          inputFormatters: [_nameFilter, LengthLimitingTextInputFormatter(50)],
          onSubmitted: (_) => model.email.focusNode.requestFocus(),
        ),
        SizedBox(height: AppSpacing.lg),
        AppTextField(
          isRequired: true,
          label: l10n.authEmail,
          controller: model.email.controller,
          focusNode: model.email.focusNode,
          placeholder: l10n.authEmailPlaceholder,
          errorText: emailError(),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            LengthLimitingTextInputFormatter(254),
          ],
          onSubmitted: (_) => model.password.focusNode.requestFocus(),
        ),
        SizedBox(height: AppSpacing.lg),
        AppTextField(
          isRequired: true,
          label: l10n.authPassword,
          controller: model.password.controller,
          focusNode: model.password.focusNode,
          placeholder: '••••••••',
          errorText: passwordError(),
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          inputFormatters: [LengthLimitingTextInputFormatter(128)],
          onSubmitted: (_) => submit(),
        ),
        SizedBox(height: AppSpacing.beforeAction),
        AuthErrorMessage(error: session.error),
        AuthSubmitButton(
          label: l10n.authSignupSubmit,
          onPressed: submit,
          isLoading: session.isBusy,
        ),
      ],
    );
  }
}
