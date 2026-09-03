import '../../core/utils/validators.dart';
import 'form_field_model.dart';

/// The sign-up form.
///
/// Fields mirror `POST /api/auth/register`: firstName, lastName, email,
/// password — nothing more. The backend also accepts an optional `plan`, which
/// this screen does not collect.
///
/// UI only for now — [submit] validates and stops.
class SignupViewModel extends FormViewModel {
  SignupViewModel() {
    attachFields();
  }

  final firstName = FormFieldModel(validator: Validators.name);
  final lastName = FormFieldModel(validator: Validators.name);
  final email = FormFieldModel(validator: Validators.email);

  /// Sign-up enforces the 8-character minimum the backend does.
  final password = FormFieldModel(validator: Validators.newPassword);

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  @override
  List<FormFieldModel> get fields => [firstName, lastName, email, password];

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    safeNotify();
  }
}
