import 'package:flutter/widgets.dart';

import '../../../core/error/app_exception.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Turns a failed request into the message the web already shows.
///
/// Mirrors `translateBackendError` in `src/lib/i18n.ts`: the backend's own
/// strings are English and not localised, so they are matched on and replaced
/// rather than displayed. Matching on message text is fragile, which is why
/// the status code carries most of the weight and the text only distinguishes
/// the two cases that share a code.
String authErrorMessage(AppException error, L10n l10n) {
  final message = error.message.toLowerCase();

  return switch (error) {
    // 401 from login is only ever wrong credentials — the endpoint is public,
    // so it cannot mean an expired token.
    UnauthorizedException() => l10n.authErrInvalidCredentials,

    NetworkException() || TimeoutException() => l10n.authErrNetwork,

    // Registering a duplicate email comes back as 400, the same code as a
    // failed field validation, so here the text is the only discriminator.
    ValidationException() when message.contains('already exists') =>
      l10n.authErrUserExists,

    // A field-level 400 the client should have caught. Showing the server's
    // own wording is more use than a generic apology.
    ValidationException() => error.message,

    ServerException() => l10n.authErrUnknown,
    _ => l10n.authErrUnknown,
  };
}

/// The form-level error line, above the button.
///
/// Not a snackbar: the design has no toast, and a message that disappears on a
/// timer is the wrong shape for "your password was wrong" — the merchant needs
/// it to still be there while they retype. Styled like a field error so the
/// two read as the same kind of thing.
class AuthErrorMessage extends StatelessWidget {
  const AuthErrorMessage({super.key, required this.error});

  final AppException? error;

  @override
  Widget build(BuildContext context) {
    final current = error;
    if (current == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        authErrorMessage(current, L10n.of(context)),
        style: AppText.actionS.copyWith(color: AppColors.accentAlert),
        textAlign: TextAlign.center,
      ),
    );
  }
}
