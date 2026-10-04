import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/prefs_storage.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/utils/json.dart';
import '../models/user.dart';

/// Sign in, sign up, session restore, sign out.
///
/// The repository owns token persistence: nothing else writes to
/// [SecureStorage], so there is exactly one place where a session begins and
/// one where it ends.
class AuthRepository {
  AuthRepository({
    required ApiClient api,
    required SecureStorage secureStorage,
    required PrefsStorage prefs,
  })  : _api = api,
        _secure = secureStorage,
        _prefs = prefs;

  final ApiClient _api;
  final SecureStorage _secure;
  final PrefsStorage _prefs;

  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    final result = await _api.post<_AuthPayload>(
      Api.login,
      body: {'email': email.trim(), 'password': password},
      parse: _AuthPayload.parse,
    );
    return _persist(result);
  }

  Future<Result<User>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final result = await _api.post<_AuthPayload>(
      Api.register,
      body: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'password': password,
      },
      parse: _AuthPayload.parse,
    );
    return _persist(result);
  }

  /// `POST /api/auth/forgot-password` — e-mails a one-time reset link.
  ///
  /// **Always 200**, whether or not an account exists for [email], so the
  /// screen after it must stay neutral. The e-mail is written in the request's
  /// `Accept-Language`. Within 60 seconds of the last request the server sends
  /// nothing new; `503 MAIL_NOT_CONFIGURED` when outgoing mail is not set up.
  Future<Result<bool>> requestPasswordReset(String email) => _api.post<bool>(
        Api.forgotPassword,
        body: {'email': email.trim()},
        parse: (_) => true,
      );

  /// `GET /api/auth/reset-password/{token}` — whether a link can still be
  /// used. Does not consume it. A dead link is a `400`
  /// (`AUTH_RESET_TOKEN_INVALID` / `AUTH_RESET_TOKEN_EXPIRED`).
  Future<Result<bool>> verifyResetToken(String token) => _api.get<bool>(
        Api.resetPasswordToken(token),
        parse: (json) => Json.boolOf(Json.map(json)['valid']),
      );

  /// `POST /api/auth/reset-password` — sets the new password and burns the
  /// link. Answers like login, so the token is stored and the merchant is
  /// signed in.
  Future<Result<User>> resetPassword({
    required String token,
    required String password,
  }) async {
    final result = await _api.post<_AuthPayload>(
      Api.resetPassword,
      body: {'token': token, 'password': password},
      parse: _AuthPayload.parse,
    );
    return _persist(result);
  }

  /// Re-reads the merchant on launch when a token is already on the device.
  /// Also the credits check — `GET /api/auth/profile` is where the app learns
  /// the agent has been paused for lack of credits.
  Future<Result<User>> fetchProfile() => _api.get<User>(
        Api.profile,
        parse: (json) {
          final map = Json.map(json);
          return User.fromJson(Json.mapOrNull(map['user']) ?? map);
        },
      );

  /// True when a token is on the device. Says nothing about whether the server
  /// still honours it — [fetchProfile] is what settles that.
  Future<bool> hasStoredSession() async {
    final token = await _secure.readAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Ends the session locally. The caller unregisters the push device first —
  /// once the token is gone the unregister call cannot authenticate.
  Future<void> signOut() async {
    await _secure.clear();
    await _prefs.clearSession();
  }

  Future<Result<User>> _persist(Result<_AuthPayload> result) async {
    if (result case Success(:final value)) {
      await _secure.writeAuthToken(value.token);
      await _secure.writeUserId(value.user.id);
      return Result.success(value.user);
    }
    return Result.failure(result.errorOrNull!);
  }
}

/// `{ token, user }` — the shape login, register and reset-password return.
class _AuthPayload {
  const _AuthPayload(this.token, this.user);

  final String token;
  final User user;

  static _AuthPayload parse(dynamic json) {
    final map = Json.map(json);
    return _AuthPayload(
      Json.str(map['token']),
      User.fromJson(Json.mapOrNull(map['user']) ?? const {}),
    );
  }
}
