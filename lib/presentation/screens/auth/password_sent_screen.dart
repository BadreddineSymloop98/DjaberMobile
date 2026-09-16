import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_scope.dart';
import 'auth_scaffold.dart';

/// `08 — E-mail envoyé`.
///
/// The address is shown on its own surface so it can be checked at a glance,
/// which is the whole point of the screen: catching the typo that would
/// otherwise leave a merchant waiting for an email that went nowhere.
///
/// **Neutral on purpose.** `POST /api/auth/forgot-password` answers the same
/// whether or not the account exists, so the copy says a link was sent *if* an
/// account exists — the web's "we've sent a link to" would claim what the
/// server does not tell us.
///
/// Two ways on: **resend** (to the same address, after the server's own
/// 60-second guard) and **try another address**. The reset itself is the
/// e-mail's link: it opens `08b` when Android hands it to the app, or the web
/// app's page otherwise. Nothing here leads to `08b`.
class PasswordSentScreen extends StatefulWidget {
  const PasswordSentScreen({super.key, this.email});

  /// The address the link was sent to.
  ///
  /// Passed as go_router `extra` rather than a path or query parameter — an
  /// email address does not belong in a URL, even an in-app one. The cost is
  /// that a cold deep link, or the splash handing this screen back, arrives
  /// without it: the address block and *resend* are then omitted rather than
  /// guessed.
  final String? email;

  /// Seconds before *resend* is offered. Within 60 seconds of the last request
  /// the server silently sends nothing, so an earlier tap would look like it
  /// worked and deliver no e-mail.
  static const resendCooldown = 60;

  @override
  State<PasswordSentScreen> createState() => _PasswordSentScreenState();
}

class _PasswordSentScreenState extends State<PasswordSentScreen> {
  Timer? _timer;
  int _secondsLeft = 0;
  bool _resending = false;

  String? get _address {
    final address = widget.email?.trim();
    return address == null || address.isEmpty ? null : address;
  }

  @override
  void initState() {
    super.initState();
    // The request that opened this screen has just gone out.
    if (_address != null) _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    _secondsLeft = PasswordSentScreen.resendCooldown;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  Future<void> _resend() async {
    final address = _address;
    final auth = context.read<AuthRepository?>();
    if (address == null || auth == null || _resending || _secondsLeft > 0) return;
    final l10n = L10n.of(context);

    setState(() => _resending = true);
    final result = await auth.requestPasswordReset(address);
    if (!mounted) return;
    setState(() => _resending = false);
    result.fold(
      onSuccess: (_) {
        AppToast.success(context, l10n.authSentResent);
        setState(_startCooldown);
      },
      onFailure: (error) => AppToast.info(context, apiErrorMessage(error, l10n)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final address = _address;

    return AuthScaffold(
      // The same path as Android back: login, the route's parent.
      leading: AuthBackLink(
        label: l10n.authForgotBack,
        onTap: () => BackScope.back(context),
      ),
      title: l10n.authSentTitle,
      subtitle: l10n.authSentMessage,
      footer: AuthFooter(
        question: l10n.authForgotRemember,
        action: l10n.authForgotBack,
        onTap: () => context.go(Routes.login),
      ),
      children: [
        if (address != null) ...[
          _AddressBlock(address: address),
          SizedBox(height: AppSpacing.md),
        ],
        // What to do next: the link, not anything in this screen.
        Text(l10n.authSentNextStep, style: AppText.bodyS),
        SizedBox(height: AppSpacing.sm),
        Text(l10n.authForgotSecure, style: AppText.labelMeta),
        SizedBox(height: 4.27.h), // 36
        Text(l10n.authSentNoReceive, style: AppText.bodyS),
        SizedBox(height: AppSpacing.sm),
        if (address != null) ...[
          _TextLink(
            label: _secondsLeft > 0 ? l10n.authSentResendIn(_secondsLeft) : l10n.authSentResend,
            onTap: _secondsLeft > 0 || _resending ? null : _resend,
          ),
          SizedBox(height: AppSpacing.sm),
        ],
        // A typo is the likeliest reason nothing arrived.
        _TextLink(
          label: l10n.authSentTryAnother,
          onTap: () => context.go(Routes.forgotPassword),
        ),
      ],
    );
  }
}

/// An inline link, start-aligned. Muted while it cannot be used.
class _TextLink extends StatelessWidget {
  const _TextLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Semantics(
        button: true,
        enabled: enabled,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Text(
            label,
            style: enabled ? AppText.link : AppText.link.copyWith(color: AppColors.textMuted),
          ),
        ),
      ),
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
