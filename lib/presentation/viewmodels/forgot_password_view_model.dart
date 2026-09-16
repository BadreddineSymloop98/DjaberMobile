import '../../core/utils/validators.dart';
import '../../data/repositories/auth_repository.dart';
import 'form_draft_store.dart';
import 'form_field_model.dart';

/// `07 — Mot de passe oublié`: the address, then `POST /api/auth/forgot-password`.
///
/// The server answers the same 200 whether or not an account exists, so
/// success only means "accepted" — `08` stays neutral about it. A failure is a
/// 400 on the address (its translated message goes under the field), a 503
/// when the server cannot send mail, or no connection; all three show on the
/// error line.
class ForgotPasswordViewModel extends FormViewModel {
  /// [auth] is optional so the screen still builds in a bare widget test; with
  /// none, [send] validates and reports success without a request.
  ForgotPasswordViewModel({AuthRepository? auth, FormDraftStore? drafts}) : _auth = auth {
    attachFields();
    keepDraft(drafts, 'forgotPassword', {'email': email});
  }

  final AuthRepository? _auth;

  final email = FormFieldModel(validator: Validators.email);

  @override
  List<FormFieldModel> get fields => [email];

  /// The address to send and to show on the sent screen, trimmed.
  String get submittedEmail => email.value.trim();

  /// The server's own message for the address, on a 400.
  String? get emailServerError => error?.fieldMessage('email');

  /// Validates, then asks for the e-mail. True once the server accepted it.
  Future<bool> send() async {
    if (isBusy || !submit()) return false;
    final auth = _auth;
    if (auth == null) return true;
    final accepted = await run(
      () => auth.requestPasswordReset(submittedEmail),
      tag: 'forgotPassword',
    );
    return accepted ?? false;
  }
}
