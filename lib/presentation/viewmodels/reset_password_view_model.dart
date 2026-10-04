import '../../core/error/app_exception.dart';
import '../../core/utils/validators.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import 'form_field_model.dart';

/// Where `08b — Nouveau mot de passe` is.
enum ResetPhase {
  /// `GET /api/auth/reset-password/{token}` is running.
  checking,

  /// The link works: the new password.
  ready,

  /// The link is malformed, unknown, used or expired. Only a new one helps.
  linkDead,

  /// The check could not reach the server. Retry.
  unreachable,
}

/// `08b — Nouveau mot de passe`: check the e-mail's link, then set the password.
///
/// **Reached only from the link**, never from a button in the app: Android
/// hands `https://djaber.vercel.app/reset-password?token=…` (an App Link) or
/// `djaber://app/reset-password?token=…` (the web page's intent) to the app,
/// and the router opens this with the token. Anywhere else, the web app's own
/// page does the same job.
///
/// The link is checked **before** the password is asked for, as the API
/// suggests, so a dead link says "request a new one" before anything is typed.
/// A successful save answers like login: [AuthRepository.resetPassword] stores
/// the token and the screen hands the user to the session.
class ResetPasswordViewModel extends FormViewModel {
  ResetPasswordViewModel({AuthRepository? auth, required String token})
      : _auth = auth,
        _token = tokenFrom(token) {
    attachFields();
    // Not even shaped like a token: nothing to check.
    if (_token == null) _phase = ResetPhase.linkDead;
  }

  final AuthRepository? _auth;
  final String? _token;

  /// Never kept as a draft, and neither is [confirm].
  final password = FormFieldModel(validator: Validators.newPassword);

  /// The same password again. A single hidden entry lets one typo set a
  /// password nobody knows — found out only at the next sign-in.
  late final confirm = FormFieldModel(validator: Validators.matches(() => password.value));

  @override
  List<FormFieldModel> get fields => [password, confirm];

  /// Both entered, valid and identical: the button is enabled.
  bool get canSubmit => password.isValid && confirm.isValid;

  ResetPhase _phase = ResetPhase.checking;
  ResetPhase get phase => _phase;

  /// The server's own message for the password, on a 400.
  String? get passwordServerError => error?.fieldMessage('password');

  static final _tokenPattern = RegExp(r'^[a-f0-9]{64}$');

  /// The link's `token` query parameter, if it is one: 64 hex characters.
  static String? tokenFrom(String text) {
    final token = text.trim().toLowerCase();
    return _tokenPattern.hasMatch(token) ? token : null;
  }

  /// Checks the token. Safe to call again from *Retry*.
  Future<void> verify() async {
    final token = _token;
    if (token == null) return;
    final auth = _auth;
    if (auth == null) {
      _phase = ResetPhase.ready;
      safeNotify();
      return;
    }

    _phase = ResetPhase.checking;
    clearError();
    safeNotify();

    final result = await auth.verifyResetToken(token);
    if (isDisposed) return;
    result.fold(
      onSuccess: (valid) {
        _phase = valid ? ResetPhase.ready : ResetPhase.linkDead;
        safeNotify();
      },
      onFailure: (error) {
        // Any 4xx on the check means the link itself is no good — invalid,
        // used or expired. Only a transport or server failure is worth
        // retrying.
        _phase = error.isRetryable ? ResetPhase.unreachable : ResetPhase.linkDead;
        setError(error);
      },
    );
  }

  /// Sets the password. Returns the signed-in user, or null.
  Future<User?> save() async {
    final token = _token;
    if (isBusy || _phase != ResetPhase.ready || token == null || !submit()) return null;
    final auth = _auth;
    if (auth == null) return null;

    final user = await run(
      () => auth.resetPassword(token: token, password: password.value),
      tag: 'resetPassword',
    );
    final failure = error;
    if (user == null && failure != null && _isDeadLink(failure)) {
      // The link died while the password was being typed — it expired, or was
      // used from another device. The form can no longer succeed.
      _phase = ResetPhase.linkDead;
      safeNotify();
    }
    return user;
  }

  static bool _isDeadLink(AppException error) =>
      error.code == 'AUTH_RESET_TOKEN_INVALID' ||
      error.code == 'AUTH_RESET_TOKEN_EXPIRED' ||
      error.fieldMessage('token') != null;
}
