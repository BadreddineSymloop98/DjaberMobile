import 'package:flutter/widgets.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// The message for a field-level problem on a tutorial form.
///
/// Shared by `T3` and `T4` rather than duplicated: the two forms use the same
/// validators, and the wording should not be able to drift between them.
String tutorialFieldMessage(FieldError error, L10n l10n) => switch (error) {
      FieldError.required => l10n.productErrRequired,
      FieldError.notANumber => l10n.productErrNotANumber,
      FieldError.mustBePositive => l10n.productErrMustBePositive,
      FieldError.belowCostPrice => l10n.productErrBelowCost,
      // Auth-form rules; no validator on these forms produces them.
      FieldError.invalidEmail || FieldError.tooShort => l10n.productErrRequired,
    };

/// The message for a failed create.
///
/// A transport failure gets the app's own wording, because there is no server
/// sentence to show. Anything the server refused shows **its** wording — the
/// backend answers `{ error: "SKU already exists" }` or
/// `{ error: "Agent limit reached" }`, which is more use than a generic
/// apology. Those strings are English, the same limitation the web has and
/// the one §21.6 records.
String tutorialSubmitMessage(AppException error, L10n l10n) => switch (error) {
      NetworkException() => l10n.errorNetwork,
      TimeoutException() => l10n.errorTimeout,
      ServerException() => l10n.errorServer,
      UnauthorizedException() => l10n.errorUnauthorized,
      _ => error.message,
    };

/// The form-level error line above a step's action.
///
/// Not a toast: the design has none, and a message that vanishes on a timer is
/// the wrong shape for something the merchant has to act on.
class TutorialErrorLine extends StatelessWidget {
  const TutorialErrorLine({super.key, required this.error});

  final AppException? error;

  @override
  Widget build(BuildContext context) {
    final current = error;
    if (current == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        tutorialSubmitMessage(current, L10n.of(context)),
        style: AppText.actionS.copyWith(color: AppColors.accentAlert),
        textAlign: TextAlign.center,
      ),
    );
  }
}
