import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/backend_message.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The one function that turns a failed request into what a merchant reads.
///
/// It replaces `authErrorMessage` and `tutorialSubmitMessage`, which used to
/// differ only in which English substrings they matched. The backend's error
/// contract made both obsolete: `message` arrives translated, so there is
/// nothing to choose and no reason for two screens to choose differently.
///
/// The whole policy:
///
/// - **Transport failures get the app's copy.** Nothing reached the server, so
///   there is no server sentence — and "check your connection" is advice only
///   the app can give.
/// - **Everything else shows `message`.** A 400, 403, 409 or 422 tells the
///   merchant exactly what to fix, and flattening that into "une erreur s'est
///   produite" is the difference between them fixing their own order and
///   phoning support.
/// - **`errorGeneric` is the last resort**, for a body with no message at all.
///
/// Deliberately **not** here: any branch on `error.message`. The text changes
/// with the locale, so matching it is a bug waiting for an Arabic merchant.
/// Branch on the type or on [AppException.code].
String apiErrorMessage(AppException error, L10n l10n) => switch (error) {
      NetworkException() => l10n.errorNetwork,
      TimeoutException() => l10n.errorTimeout,
      // A 5xx message is honest but unhelpful ("notre faute"); the app's own
      // wording pairs better with the Retry these carry.
      ServerException() => preciseBackendMessage(error) ?? l10n.errorServer,
      _ => preciseBackendMessage(error) ?? l10n.errorGeneric,
    };

/// The form-level error line, above the primary button.
///
/// Not a toast: a message that vanishes on a timer is the wrong shape for
/// something the merchant has to act on — they need it still there while they
/// retype. `AppToast` handles the other direction, confirmations.
///
/// On a validation failure this line shows the contract's summary
/// (*"Certains champs sont invalides…"*) while each faulted input carries its
/// own message from [AppException.fieldMessages]. The two are complementary:
/// the line says something is wrong, the fields say what.
class ApiErrorLine extends StatelessWidget {
  const ApiErrorLine({super.key, required this.error});

  final AppException? error;

  @override
  Widget build(BuildContext context) {
    final current = error;
    if (current == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        apiErrorMessage(current, L10n.of(context)),
        style: AppText.actionS.copyWith(color: AppColors.accentAlert),
        textAlign: TextAlign.center,
      ),
    );
  }
}
