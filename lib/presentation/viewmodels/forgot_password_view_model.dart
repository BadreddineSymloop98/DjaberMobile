import '../../core/utils/validators.dart';
import 'form_field_model.dart';

/// The password-reset request form.
///
/// **There is nothing to send it to.** `backend/src/routes/auth.routes.ts`
/// exposes register, login and profile — no reset endpoint exists, and the
/// web's own `/forgot-password` page calls nothing either. So [submit]
/// validates the address and the screen moves to its sent state; no email is
/// dispatched, because nothing on the server can dispatch one.
///
/// That gap is the real blocker on this flow, not the UI.
class ForgotPasswordViewModel extends FormViewModel {
  ForgotPasswordViewModel() {
    attachFields();
  }

  final email = FormFieldModel(validator: Validators.email);

  @override
  List<FormFieldModel> get fields => [email];

  /// The address to show on the sent screen, trimmed.
  String get submittedEmail => email.value.trim();
}
