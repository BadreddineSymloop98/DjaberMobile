import '../../core/utils/validators.dart';
import 'form_draft_store.dart';
import 'form_field_model.dart';

/// The sign-in form.
///
/// UI only for now — [submit] validates and stops. Wiring it to
/// `SessionViewModel.signIn` is the next step and touches nothing here except
/// the body of `submit`.
class LoginViewModel extends FormViewModel {
  LoginViewModel({FormDraftStore? drafts}) {
    attachFields();
    // The address and the remember-me choice survive the splash; the
    // password never does.
    final saved = keepDraft(drafts, 'login', {'email': email});
    final remember = saved['rememberMe'];
    if (remember != null) _rememberMe = remember == 'true';
  }

  final email = FormFieldModel(validator: Validators.email);

  /// Login checks only that a password was typed — the backend does the same,
  /// so an account created before the 8-character rule can still sign in.
  final password = FormFieldModel(validator: Validators.password);

  bool _rememberMe = true;
  bool get rememberMe => _rememberMe;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  @override
  List<FormFieldModel> get fields => [email, password];

  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    saveDraft();
    safeNotify();
  }

  @override
  Map<String, String> get draftExtras => {'rememberMe': '$_rememberMe'};

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    safeNotify();
  }
}
