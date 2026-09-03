import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/forgot_password_view_model.dart';
import '../../widgets/app_text_field.dart';
import 'auth_scaffold.dart';

/// `07 — Mot de passe oublié`.
///
/// The web's two-column marketing panel (`auth.forgot.reset.*`, `secure.title`,
/// `verify.*`) is dropped — desktop furniture. The one fact worth keeping from
/// it is the expiry note, which sits under the button here rather than in a
/// side panel.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => ForgotPasswordViewModel(),
        child: const _ForgotPasswordView(),
      );
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView();

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final model = context.watch<ForgotPasswordViewModel>();

    String? emailError() => switch (model.visibleError(model.email)) {
          null => null,
          FieldError.required => l10n.authErrEmailRequired,
          FieldError.invalidEmail => l10n.authErrInvalidEmail,
          FieldError.tooShort => l10n.authErrInvalidEmail,
        };

    void send() {
      if (!model.submit()) return;
      // Nothing is dispatched — no reset endpoint exists on the backend. The
      // flow moves to its sent state so the screens can be reviewed end to
      // end; wiring it up is one call in this method.
      context.go(Routes.passwordSent, extra: model.submittedEmail);
    }

    return AuthScaffold(
      leading: AuthBackLink(
        label: l10n.authForgotBack,
        onTap: () => context.go(Routes.login),
      ),
      title: l10n.authForgotTitle,
      subtitle: l10n.authForgotSubtitle,
      footer: AuthFooter(
        question: l10n.authForgotRemember,
        action: l10n.authForgotBack,
        onTap: () => context.go(Routes.login),
      ),
      children: [
        AppTextField(
          isRequired: true,
          label: l10n.authForgotEmail,
          controller: model.email.controller,
          focusNode: model.email.focusNode,
          placeholder: l10n.authForgotEmailPlaceholder,
          errorText: emailError(),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            LengthLimitingTextInputFormatter(254),
          ],
          onSubmitted: (_) => send(),
        ),
        SizedBox(height: AppSpacing.beforeAction),
        AuthSubmitButton(label: l10n.authForgotSubmit, onPressed: send),
        SizedBox(height: AppSpacing.sm),
        Text(
          l10n.authForgotSecure,
          style: AppText.labelMeta,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
