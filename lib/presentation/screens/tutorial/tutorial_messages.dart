import 'package:flutter/widgets.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../widgets/api_error_message.dart';

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
      FieldError.invalidEmail || FieldError.tooShort || FieldError.mismatch => l10n.productErrRequired,
    };

/// The message for a failed create — now just [apiErrorMessage].
///
/// It used to end in `_ => error.message`, which put the backend's English
/// in front of a French merchant: `SKU already exists`, `Agent limit
/// reached`. The error contract fixed that at the source — those are now
/// `PRODUCT_SKU_ALREADY_EXISTS` and `PLAN_LIMIT_REACHED` with translated
/// messages — so the fallback is no longer a leak, it is the right answer.
String tutorialSubmitMessage(AppException error, L10n l10n) =>
    apiErrorMessage(error, l10n);

/// The form-level error line above a step's action.
///
/// Not a toast: the design has none, and a message that vanishes on a timer is
/// the wrong shape for something the merchant has to act on.
class TutorialErrorLine extends StatelessWidget {
  const TutorialErrorLine({super.key, required this.error});

  final AppException? error;

  @override
  Widget build(BuildContext context) => ApiErrorLine(error: error);
}
