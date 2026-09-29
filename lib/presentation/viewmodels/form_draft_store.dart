import 'session_view_model.dart';

/// Unsent form values that must outlive the screen showing them.
///
/// Leaving the app used to replay the splash as a route, and the router then
/// built whatever screen was open from scratch — so a form that kept its
/// values in its screen came back empty. A form registered here (see
/// `FormViewModel.keepDraft`) writes its values on every keystroke and reads
/// them back when it is built again.
///
/// **Since 2026-09-29 the replay is an overlay** (`SplashReplayOverlay`) and no
/// screen is torn down by it, so every form keeps its input without this —
/// including the many that never registered, and bottom sheets. What remains
/// here is a second line for a screen rebuilt while the splash plays. It is
/// in memory only, so it does not survive Android killing the process.
///
/// **Passwords are never kept.** Each form names the fields it keeps, and none
/// names a password: retyping one is a smaller cost than a password sitting in
/// memory for the life of the app.
///
/// **A draft survives the splash, not the merchant.** It is dropped when its
/// form goes away for any other reason — a merchant who walked away from a
/// form finds it empty next time — and every draft is dropped when the account
/// changes hands, so a product half-typed by one merchant cannot greet the next
/// one on a shared handset.
///
/// The tutorial's two steps keep theirs in `TutorialViewModel`, which is
/// dropped with the tutorial.
class FormDraftStore {
  FormDraftStore({required SessionViewModel session})
      : _session = session,
        _status = session.status {
    session.addListener(_onSessionChanged);
  }

  final SessionViewModel _session;
  AuthStatus _status;

  final Map<String, Map<String, String>> _drafts = {};

  /// What [form] left unsent. Empty when nothing was.
  Map<String, String> read(String form) => _drafts[form] ?? const {};

  void write(String form, Map<String, String> values) {
    _drafts[form] = Map.unmodifiable(values);
  }

  /// Called as a form goes away.
  ///
  /// The draft is kept only when the splash is playing — at launch, or again
  /// over the app after it was left. Any other departure is the merchant
  /// moving on, and the draft goes with it.
  void release(String form) {
    if (_session.isBootComplete && !_session.isReplayingSplash) _drafts.remove(form);
  }

  void _onSessionChanged() {
    final status = _session.status;
    if (status == _status) return;
    // Leaving `unknown` is the stored session being checked at startup, not
    // an account changing hands.
    final changedHands = _status != AuthStatus.unknown;
    _status = status;
    if (changedHands) _drafts.clear();
  }

  void dispose() => _session.removeListener(_onSessionChanged);
}
