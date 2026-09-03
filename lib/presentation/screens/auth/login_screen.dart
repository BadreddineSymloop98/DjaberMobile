import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/login_view_model.dart';
import '../../widgets/app_text_field.dart';
import 'auth_scaffold.dart';

/// `05 — Connexion`.
///
/// Form behaviour only — [LoginViewModel.submit] validates and stops. Nothing
/// here talks to the backend yet.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => LoginViewModel(),
        child: const _LoginView(),
      );
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final model = context.watch<LoginViewModel>();

    // Exhaustive on FieldError, so adding a rule later fails to compile until
    // it has a message.
    String? emailError() => switch (model.visibleError(model.email)) {
          null => null,
          FieldError.required => l10n.authErrEmailRequired,
          FieldError.invalidEmail => l10n.authErrInvalidEmail,
          FieldError.tooShort => l10n.authErrPasswordTooShort,
        };

    String? passwordError() => switch (model.visibleError(model.password)) {
          null => null,
          FieldError.required => l10n.authErrPasswordRequired,
          FieldError.invalidEmail => l10n.authErrInvalidEmail,
          FieldError.tooShort => l10n.authErrPasswordTooShort,
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
          onSubmitted: (_) => model.submit(),
        ),
        SizedBox(height: AppSpacing.lg),
        _RememberMe(
          label: l10n.authRemember,
          value: model.rememberMe,
          onTap: model.toggleRememberMe,
        ),
        SizedBox(height: AppSpacing.beforeAction),
        AuthSubmitButton(label: l10n.authLoginSubmit, onPressed: model.submit),
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

/// The Checkbox component (`37:16`). Radius drops to 1px — at 16px a card
/// radius reads as a rounded blob, which is why the design specifies it.
class _RememberMe extends StatelessWidget {
  const _RememberMe({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4.1.w, // 16
            height: 4.1.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: value ? AppColors.textPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
              border: Border.all(
                color: AppColors.ruleStrong,
                width: AppStroke.hairline,
              ),
            ),
            child: value
                ? Text(
                    '✓',
                    style: AppText.labelMeta.copyWith(color: AppColors.ink),
                  )
                : null,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(label, style: AppText.actionS.copyWith(fontSize: 12.sp)),
        ],
      ),
    );
  }
}
