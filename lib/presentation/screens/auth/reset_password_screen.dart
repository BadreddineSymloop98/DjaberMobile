import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/reset_password_view_model.dart';
import '../../viewmodels/session_view_model.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_scope.dart';
import 'auth_error_message.dart';
import 'auth_scaffold.dart';

/// `08b — Nouveau mot de passe`, at `/reset-password?token=…`.
///
/// **Opened by the e-mail's link, and only by it.** There is no button to it
/// in the app: the link is the reset, wherever it opens. On a phone with the
/// app, Android hands it over — as a verified App Link, or through the web
/// page's `intent://` hand-off to `djaber://app/reset-password` — and the
/// router lands here with the token (brief §25.19). Without the app, or on a
/// computer, the web app's page does the same.
///
/// **The new password is typed twice**, as in the apps merchants already use:
/// the button stays disabled until both entries are valid and identical, so a
/// typo cannot silently become the account's password.
///
/// Open signed in or out: a merchant already signed in who resets is signed
/// in again with the account the link belongs to.
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, required this.token});

  /// The link's `token` query parameter.
  final String token;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) {
          final model = ResetPasswordViewModel(
            auth: context.read<AuthRepository?>(),
            token: token,
          );
          if (model.phase == ResetPhase.checking) unawaited(Future.microtask(model.verify));
          return model;
        },
        child: const _ResetPasswordView(),
      );
}

class _ResetPasswordView extends StatelessWidget {
  const _ResetPasswordView();

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final model = context.watch<ResetPasswordViewModel>();

    Future<void> save() async {
      if (!model.canSubmit) return;
      final session = context.read<SessionViewModel>();
      final user = await model.save();
      if (user == null || !context.mounted) return;
      AppToast.success(context, l10n.authResetDone);
      final router = GoRouter.of(context);
      await session.startSession(user);
      // Signed out, the redirect has already moved on. Signed in before, the
      // status did not change and nothing would.
      if (context.mounted) router.go(Routes.home);
    }

    // While the merchant is still typing, the rule stays a neutral hint rather
    // than a red error: "too short" after the first letter is not news. It
    // turns red once they have left the field or tried to send.
    String? passwordError() {
      final error = model.visibleError(model.password);
      if (error == FieldError.tooShort && model.password.hasFocus && !model.submitAttempted) {
        return model.passwordServerError;
      }
      return switch (error) {
        null => model.passwordServerError,
        FieldError.required => l10n.authErrPasswordRequired,
        FieldError.tooShort => l10n.authErrPasswordTooShort,
        // No validator on this field can produce these.
        FieldError.invalidEmail ||
        FieldError.notANumber ||
        FieldError.mustBePositive ||
        FieldError.belowCostPrice ||
        FieldError.mismatch =>
          l10n.authErrPasswordRequired,
      };
    }

    // Quiet while the second entry is still on its way to matching — empty, or
    // a correct beginning of the first. A real difference shows at once.
    String? confirmError() {
      final error = model.visibleError(model.confirm);
      final typed = model.confirm.value;
      final onTheWay = typed.isEmpty || model.password.value.startsWith(typed);
      if (!model.submitAttempted && model.confirm.hasFocus && onTheWay) return null;
      return switch (error) {
        null => null,
        FieldError.mismatch => l10n.authErrPasswordMismatch,
        FieldError.required => l10n.authErrPasswordRequired,
        // No validator on this field can produce these.
        FieldError.invalidEmail ||
        FieldError.tooShort ||
        FieldError.notANumber ||
        FieldError.mustBePositive ||
        FieldError.belowCostPrice =>
          l10n.authErrPasswordRequired,
      };
    }

    final phase = model.phase;

    return AuthScaffold(
      // The same path as Android back: login, the route's parent.
      leading: AuthBackLink(
        label: l10n.authForgotBack,
        onTap: () => BackScope.back(context),
      ),
      title: l10n.authResetTitle,
      subtitle: switch (phase) {
        ResetPhase.checking => l10n.authResetChecking,
        ResetPhase.ready || ResetPhase.unreachable => l10n.authResetSubtitle,
        ResetPhase.linkDead => l10n.authResetDeadSubtitle,
      },
      footer: AuthFooter(
        question: l10n.authForgotRemember,
        action: l10n.authForgotBack,
        onTap: () => context.go(Routes.login),
      ),
      children: switch (phase) {
        ResetPhase.checking => [
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: const Center(
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
                ),
              ),
            ),
          ],
        ResetPhase.ready => [
            AppTextField(
              isRequired: true,
              label: l10n.authResetPasswordLabel,
              controller: model.password.controller,
              focusNode: model.password.focusNode,
              placeholder: '••••••••',
              hint: l10n.authPasswordHint,
              errorText: passwordError(),
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              // Spaces are legal in a password; only the server's upper bound.
              inputFormatters: [LengthLimitingTextInputFormatter(128)],
              onSubmitted: (_) => model.confirm.focusNode.requestFocus(),
            ),
            SizedBox(height: AppSpacing.lg),
            AppTextField(
              isRequired: true,
              label: l10n.authResetConfirmLabel,
              controller: model.confirm.controller,
              focusNode: model.confirm.focusNode,
              placeholder: '••••••••',
              errorText: confirmError(),
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              inputFormatters: [LengthLimitingTextInputFormatter(128)],
              onSubmitted: (_) => save(),
            ),
            SizedBox(height: AppSpacing.beforeAction),
            AuthErrorMessage(error: model.error),
            AuthSubmitButton(
              label: l10n.authResetSubmit,
              onPressed: save,
              isLoading: model.isBusy,
              enabled: model.canSubmit,
            ),
          ],
        ResetPhase.linkDead => [
            // "Invalid or already used" / "expired", in the server's words.
            AuthErrorMessage(error: model.error),
            AuthSubmitButton(
              label: l10n.authResetRequestNew,
              onPressed: () => context.go(Routes.forgotPassword),
            ),
          ],
        ResetPhase.unreachable => [
            AuthErrorMessage(error: model.error),
            AuthSubmitButton(label: l10n.commonRetry, onPressed: model.verify),
          ],
      },
    );
  }
}
