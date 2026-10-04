import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/forgot_password_view_model.dart';
import '../../viewmodels/form_draft_store.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/back_scope.dart';
import 'auth_error_message.dart';
import 'auth_scaffold.dart';

/// `07 — Mot de passe oublié`.
///
/// Sends `POST /api/auth/forgot-password` (brief §25.18), then moves to `08`.
///
/// The web's two-column marketing panel (`auth.forgot.reset.*`, `secure.title`,
/// `verify.*`) is dropped — desktop furniture. The one fact worth keeping from
/// it is the expiry note, which sits under the button here rather than in a
/// side panel.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        // Looked up optionally, so the screen still builds without them.
        create: (context) => ForgotPasswordViewModel(
          auth: context.read<AuthRepository?>(),
          drafts: context.read<FormDraftStore?>(),
        ),
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
          // Product-form rules; no validator on this form can produce them.
          FieldError.notANumber ||
          FieldError.mustBePositive ||
          FieldError.belowCostPrice ||
          FieldError.mismatch =>
            l10n.authErrEmailRequired,
        };

    Future<void> send() async {
      if (!await model.send() || !context.mounted) return;
      context.go(Routes.passwordSent, extra: model.submittedEmail);
    }

    return AuthScaffold(
      // The same path as Android back: login, the route's parent.
      leading: AuthBackLink(
        label: l10n.authForgotBack,
        onTap: () => BackScope.back(context),
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
          // Ours while it applies; the server's for an address it refused.
          errorText: emailError() ?? model.emailServerError,
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
        // No connection, or `MAIL_NOT_CONFIGURED`, in the server's words.
        AuthErrorMessage(error: model.error),
        AuthSubmitButton(
          label: l10n.authForgotSubmit,
          onPressed: send,
          isLoading: model.isBusy,
        ),
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
