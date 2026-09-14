import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'auth_scaffold.dart';

/// `08 — E-mail envoyé`.
///
/// No form, no state — the confirmation half of the reset flow. The address is
/// shown on its own surface so it can be checked at a glance, which is the
/// whole point of the screen: catching the typo that would otherwise leave a
/// merchant waiting for an email that went nowhere.
class PasswordSentScreen extends StatelessWidget {
  const PasswordSentScreen({super.key, this.email});

  /// The address the link was sent to.
  ///
  /// Passed as go_router `extra` rather than a path or query parameter — an
  /// email address does not belong in a URL, even an in-app one. The cost is
  /// that a cold deep link arrives without it, which is why the address block
  /// is omitted rather than assumed when this is null.
  final String? email;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final address = email?.trim();

    return AuthScaffold(
      leading: AuthBackLink(
        label: l10n.authForgotBack,
        onTap: () => context.go(Routes.login),
      ),
      title: l10n.authSentTitle,
      subtitle: l10n.authSentMessage,
      footer: AuthFooter(
        question: l10n.authForgotRemember,
        action: l10n.authForgotBack,
        onTap: () => context.go(Routes.login),
      ),
      children: [
        if (address != null && address.isNotEmpty) ...[
          _AddressBlock(address: address),
          SizedBox(height: AppSpacing.md),
        ],
        Text(l10n.authForgotSecure, style: AppText.labelMeta),
        SizedBox(height: 4.27.h), // 36
        Text(l10n.authSentNoReceive, style: AppText.bodyS),
        SizedBox(height: AppSpacing.sm),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: GestureDetector(
            // Back to the form rather than resending, since nothing can be
            // resent — and a typo is the likeliest reason nothing arrived.
            onTap: () => context.go(Routes.forgotPassword),
            behavior: HitTestBehavior.opaque,
            child: Text(l10n.authSentTryAnother, style: AppText.link),
          ),
        ),
      ],
    );
  }
}

/// The address on a flat surface of its own — the same shape as a text field,
/// so it reads as the value that was entered rather than as body copy.
class _AddressBlock extends StatelessWidget {
  const _AddressBlock({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSize.control,
      alignment: AlignmentDirectional.centerStart,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
      ),
      child: Text(
        address,
        style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
