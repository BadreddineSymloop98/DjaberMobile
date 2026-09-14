import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

/// Transient confirmation that a write succeeded.
///
/// ## Why this is success-only
///
/// Failures stay where they are — the inline line above the button
/// (`AuthErrorMessage`, `TutorialErrorLine`). The two are different kinds of
/// message and want different shapes: an error is something the merchant has
/// to act on, so it must still be on screen while they retype, and a toast
/// that fades on a timer is the wrong container for it. A success is something
/// to acknowledge and then get out of the way, which is exactly what a toast
/// is for. Decided 2026-09-10.
///
/// ## Why writes only
///
/// Nothing raises this on a read. Home issues five requests in one
/// `Future.wait` on load and again on every pull-to-refresh; a toast per
/// request would stack five at launch and turn the confirmation into noise.
/// Only an action the merchant deliberately took gets one.
///
/// ## Where it renders
///
/// Through the root `ScaffoldMessenger` that `MaterialApp` installs, so the
/// toast **survives the navigation that follows it**. That is deliberate: each
/// tutorial step confirms and advances in the same gesture, so the toast is
/// raised on the step that did the work and read on the one after it. Calling
/// it before `go()` is therefore correct, not a race.
///
/// Styling comes from `snackBarTheme` in [AppTheme] — `surfaceHigh` on a
/// `rule` hairline, floating, card radius — so this adds no new colour, radius
/// or type size. The only thing it contributes is the leading tick, in
/// `signal/live`, which is the same mark `T6` uses for a completed step.
class AppToast {
  const AppToast._();

  /// How long a confirmation stays up.
  ///
  /// Shorter than Flutter's 4s default. It is read in passing on the screen
  /// after the one that raised it, and it must not still be sitting over that
  /// screen's own content while the merchant starts the next step.
  static const Duration _duration = Duration(seconds: 3);

  /// Confirms that a write went through.
  ///
  /// [message] is already localised — pass an `l10n` getter, never a literal.
  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.live);

  /// States a fact that is neither a success nor a failure — *"pas encore
  /// disponible"*, *"sur le web"*.
  ///
  /// Nothing was attempted, so a tick would be a lie and the alert red would
  /// be alarm over a screen that simply does not exist yet. The mark is muted
  /// and the copy carries the whole message.
  static void info(BuildContext context, String message) =>
      _show(context, message, AppColors.textMuted);

  static void _show(BuildContext context, String message, Color markColor) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    // A screen driven in a test without a Scaffold above it should not crash
    // on a confirmation. The same reasoning as looking the router up only on
    // the success path: feedback must not be what makes a screen untestable.
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: _duration,
          content: Row(
            children: [
              AppIcon(
                AppIcons.check,
                size: 16,
                color: markColor,
              ),
              SizedBox(width: AppSpacing.sm),
              // Long copy wraps rather than being clipped; the row is as tall
              // as the text needs.
              Expanded(
                child: Text(
                  message,
                  style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
