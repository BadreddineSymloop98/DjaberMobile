import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../app/routes.dart';
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

  /// Puts the app back behind the splash.
  ///
  /// Called when the app is backgrounded, so the splash plays on every return
  /// and not only on a cold start — Android keeps the process alive, so
  /// without this a merchant who task-switches away and back never sees it.
  ///
  /// The cost is real and worth knowing: it also sits in front of a tapped
  /// notification, which is the one path in this app measured in seconds. If
  /// that becomes a problem, gate this on how long the app was away rather
  /// than removing it.
  void resetBoot() {
    if (!_bootComplete || _splashHolds > 0) return;
    _bootComplete = false;
    safeNotify();
  }

  int _splashHolds = 0;

  /// Stops the splash from replaying while something on screen cannot be
  /// rebuilt after it.
  ///
  /// The replay makes the router rebuild its screens, and a window pushed on
  /// top of them — Facebook's login, the system file picker's caller — is
  /// dropped. Leaving the app is exactly what those flows make a merchant do:
  /// fetch a Facebook security code, browse to a photo. Pair every call with
  /// [releaseSplashReplay].
  void holdSplashReplay() => _splashHolds++;

  void releaseSplashReplay() {
    if (_splashHolds > 0) _splashHolds--;
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
    await startSession(user);
    return true;
  }

  /// Adopts a session whose token [AuthRepository] has already stored — after
  /// login, and after a password reset, which answers like login.
  Future<void> startSession(User user) async {
    _user = user;
    _setStatus(AuthStatus.signedIn);
    await _syncPushToken();
    // Login returns no credits; only /profile does. Fetched without awaiting
    // so the merchant reaches home immediately and the credit state fills in.
    unawaited(refreshProfile());
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
    // Armed here and nowhere else. The tutorial runs once, immediately after
    // account creation (brief §21.5) — signing in to an existing account, on
    // this handset or another, must never trigger it. Set before the status
    // flips, so the router's redirect sees it on the very first pass and the
    // merchant never lands on home first.
    await _prefs.setTutorialPending(true);
    _setStatus(AuthStatus.signedIn);
    await _syncPushToken();
    unawaited(refreshProfile());
    return true;
  }

  /// Refreshes the merchant record. Silent: it runs on resume and after
  /// signing in, and must not put a spinner over the home screen.
  ///
  /// Merged rather than assigned — `/profile` is the only endpoint that
  /// returns credits, and login is the only one that returns `isAdmin`, so
  /// replacing the record wholesale would keep discarding one or the other.
  Future<void> refreshProfile() async {
    final result = await _auth.fetchProfile();
    if (result case Success(:final value)) {
      _user = _user?.mergedWith(value) ?? value;
      safeNotify();
    }
  }

  /// Ends the session.
  ///
  /// Local only, like the web app: `src/lib/api.ts` drops `token` and `user`
  /// from localStorage and makes no request, because the backend has no logout
  /// route and the JWT is not revocable. Nothing here can fail on the network.
  Future<void> signOut() async {
    // Unregister before the token is cleared — afterwards the call cannot
    // authenticate, and the device keeps receiving another merchant's alerts
    // if the handset is shared. A no-op until Q5 picks a transport; the web
    // has no equivalent because it never registers a device.
    await _push.deleteToken();
    await _auth.signOut();
    _user = null;
    _setStatus(AuthStatus.signedOut);
  }

  /// The hard sign-out triggered by a 401 from anywhere in the app.
  ///
  /// Delegates to [signOut] so there is one way to end a session, the way
  /// `AuthContext` calls the same `logout()` for a deliberate sign-out and for
  /// a rejected token. The guard is ours: a burst of parallel requests can
  /// return several 401s, and without it each would run the teardown again.
  Future<void> onUnauthorized() async {
    if (_status != AuthStatus.signedIn) return;
    Log.i('401 — ending session', tag: 'auth');
    await signOut();
  }

  Future<void> completeOnboarding() async {
    await _prefs.setOnboardingSeen(true);
    safeNotify();
  }

  /// True while a newly created account still owes the first-run tutorial.
  /// The router reads this to hold a merchant on `/tutorial` until it is
  /// finished or skipped.
  bool get tutorialPending => _prefs.tutorialPending;

  /// Where a returning merchant should re-enter the tutorial.
  ///
  /// The furthest step they reached, or the intro if they have not started or
  /// the stored value is not a step this build knows. Validated rather than
  /// trusted — a stale route from an older build must not be handed to the
  /// router.
  String get tutorialResumeRoute {
    final stored = _prefs.tutorialStep;
    if (stored == null) return Routes.tutorial;
    return Routes.tutorialFlow.contains(stored) ? stored : Routes.tutorial;
  }

  /// How far the merchant has got, as an index into [Routes.tutorialFlow].
  /// `T6` reads it to tell a step it actually completed from one it only
  /// resumed past.
  int get tutorialStepIndex =>
      Routes.tutorialFlow.indexOf(tutorialResumeRoute);

  /// Records that a step is done and the next one is owed.
  ///
  /// Called by each step on success, **before** it navigates, so a process
  /// death between the write and the push still resumes forward rather than
  /// back. Never moves backwards: re-walking an earlier step must not undo
  /// progress already made.
  Future<void> rememberTutorialStep(String route) async {
    final next = Routes.tutorialFlow.indexOf(route);
    if (next < 0 || next <= tutorialStepIndex) return;
    await _prefs.setTutorialStep(route);
    safeNotify();
  }

  /// Ends the tutorial, whether it was completed or skipped. Notifies, because
  /// the router's redirect is what acts on it.
  Future<void> completeTutorial() async {
    await _prefs.setTutorialPending(false);
    // The step goes with the flag: leaving it behind would resume a merchant
    // who signs up again on this handset into the middle of a tutorial they
    // have never seen.
    await _prefs.setTutorialStep(null);
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

  /// Places a signed-in merchant without a network round trip, for tests.
  ///
  /// The alternative is stubbing Dio to fake a login response, which tests the
  /// HTTP client rather than the screen under test.
  /// Whether a token is still on the device.
  ///
  /// Exposed so a sign-out test can assert the token was cleared, not just
  /// that the in-memory session was dropped — signing out visually while
  /// leaving the token behind would restore the session on the next cold
  /// start.
  @visibleForTesting
  Future<bool> hasStoredSessionForTest() => _auth.hasStoredSession();

  @visibleForTesting
  void debugSetUser(User user) {
    _user = user;
    _bootComplete = true;
    _setStatus(AuthStatus.signedIn);
  }

  void _setStatus(AuthStatus value) {
    if (_status == value) return;
    _status = value;
    safeNotify();
  }
}
