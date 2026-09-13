import 'package:flutter/widgets.dart';

import '../../../core/error/app_exception.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../widgets/api_error_message.dart';

/// Auth's error copy, which is now just [apiErrorMessage].
///
/// This file used to mirror `translateBackendError` in `src/lib/i18n.ts`:
/// the backend's strings were English and unlocalised, so it matched
/// substrings — `already exists`, `invalid email or password` — and
/// substituted French of our own. **All of that is gone.** The backend's error
/// contract sends `message` already translated and a stable `code`, so
/// choosing copy from the server's wording is not just unnecessary, it is
/// wrong: the wording changes with the locale.
///
/// One consequence worth knowing: a wrong password on login now reads the
/// server's *"E-mail ou mot de passe incorrect."* rather than our
/// `authErrInvalidCredentials`. The two said the same thing; the server's
/// version is the one that also exists in Arabic.
String authErrorMessage(AppException error, L10n l10n) =>
    apiErrorMessage(error, l10n);

/// The form-level error line on the auth screens.
///
/// Kept as a name the auth screens already use; [ApiErrorLine] is the
/// implementation, shared with the tutorial.
class AuthErrorMessage extends StatelessWidget {
  const AuthErrorMessage({super.key, required this.error});

  final AppException? error;

  @override
  Widget build(BuildContext context) => ApiErrorLine(error: error);
}
