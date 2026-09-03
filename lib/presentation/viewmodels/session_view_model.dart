import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../core/services/device_info_service.dart';
import '../../core/services/push_service.dart';
import '../../core/storage/prefs_storage.dart';
import '../../core/utils/logger.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import 'base_view_model.dart';

/// Whether anyone is signed in. Drives the router's redirect.
enum AuthStatus {
  /// Startup — the stored token has not been checked yet. The splash shows.
  unknown,

  /// No session. Onboarding or login.
  signedOut,

  /// Signed in.
  signedIn,
}

/// App-wide session state: who is signed in, and the transitions in and out.
///
/// Lives above the router rather than on a screen, because the router's
/// redirect reads it and because a 401 on any request anywhere has to be able
/// to end the session.
class SessionViewModel extends BaseViewModel {
  SessionViewModel({
    required AuthRepository authRepository,
    required PrefsStorage prefs,
    required PushService push,
    required DeviceInfoService deviceInfo,
  })  : _auth = authRepository,
        _prefs = prefs,
        _push = push,
        _deviceInfo = deviceInfo;

  final AuthRepository _auth;
  final PrefsStorage _prefs;
  final PushService _push;
  final DeviceInfoService _deviceInfo;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  bool _bootComplete = false;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isSignedIn => _status == AuthStatus.signedIn;
  bool get onboardingSeen => _prefs.onboardingSeen;

  /// True once the splash has finished — the stored session has been checked
  /// *and* the launch animation has had its minimum time. The router's redirect
  /// holds every navigation on the splash until this flips, which is what stops
  /// a fast restore from cutting the logo animation mid-rise.
  bool get isBootComplete => _bootComplete;

  /// Called by the splash screen, and only by it.
  void markBootComplete() {
    if (_bootComplete) return;
    _bootComplete = true;
    safeNotify();
  }

  /// True when the merchant's AI credits are exhausted, which pauses the agent.
  /// The web dashboard banners this; on mobile it matters more, because it
  /// silently breaks the notification loop the app exists for.
  bool get isAgentPaused => _user?.isAgentPaused ?? false;

  DeviceInfoService get deviceInfo => _deviceInfo;

  /// Called once from `main`. Restores a session if a token is on the device
  /// and the server still honours it.
  Future<void> restore() async {
    if (!await _auth.hasStoredSession()) {
      _setStatus(AuthStatus.signedOut);
      return;
    }

    final result = await _auth.fetchProfile();
    result.fold(
      onSuccess: (user) {
        _user = user;
        _setStatus(AuthStatus.signedIn);
      },
      onFailure: (error) {
        // A rejected token is a real sign-out. A network failure is not — the
        // merchant opening the app in a dead zone must not be logged out, so
        // the stored session is kept and the profile is refetched later.
        if (error is UnauthorizedException) {
          Log.i('stored token rejected, signing out', tag: 'auth');
          signOut();
        } else {
          Log.w('profile unreachable, keeping session: $error', tag: 'auth');
          _setStatus(AuthStatus.signedIn);
        }
      },
    );
  }

  Future<bool> signIn({required String email, required String password}) async {
    final user = await run(
      () => _auth.login(email: email, password: password),
      tag: 'signIn',
    );
    if (user == null) return false;
    _user = user;
    _setStatus(AuthStatus.signedIn);
    await _syncPushToken();
    return true;
  }

  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final user = await run(
      () => _auth.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      ),
      tag: 'signUp',
    );
    if (user == null) return false;
    _user = user;
    _setStatus(AuthStatus.signedIn);
    await _syncPushToken();
    return true;
  }

  /// Refreshes the merchant record — credits, plan, company. Silent: it runs on
  /// resume and must not put a spinner over the home screen.
  Future<void> refreshProfile() async {
    final result = await _auth.fetchProfile();
    if (result case Success(:final value)) {
      _user = value;
      safeNotify();
    }
  }

  Future<void> signOut() async {
    // Unregister before the token is cleared — afterwards the call cannot
    // authenticate, and the device keeps receiving another merchant's alerts
    // if the handset is shared.
    await _push.deleteToken();
    await _auth.signOut();
    _user = null;
    _setStatus(AuthStatus.signedOut);
  }

  /// The hard sign-out triggered by a 401 from anywhere in the app.
  Future<void> onUnauthorized() async {
    if (_status != AuthStatus.signedIn) return;
    Log.i('401 — ending session', tag: 'auth');
    await _auth.signOut();
    _user = null;
    _setStatus(AuthStatus.signedOut);
  }

  Future<void> completeOnboarding() async {
    await _prefs.setOnboardingSeen(true);
    safeNotify();
  }

  /// No-op until a push transport is chosen (brief Q5). Kept on the sign-in
  /// path so wiring it later is one implementation, not a change here.
  Future<void> _syncPushToken() async {
    final token = await _push.getToken();
    if (token == null || token == _prefs.syncedDeviceToken) return;
    // TODO(Q5): POST Api.registerDevice with { token, platform } once the
    // backend accepts the chosen transport's token format. It currently
    // validates Expo tokens, which Flutter cannot produce.
    Log.d('push token ready but device registration is not wired', tag: 'push');
  }

  void _setStatus(AuthStatus value) {
    if (_status == value) return;
    _status = value;
    safeNotify();
  }
}
