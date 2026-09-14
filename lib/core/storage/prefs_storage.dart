import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/stock_mode.dart';

/// Non-secret device preferences: chosen language, onboarding state, the last
/// notification permission prompt, and similar.
///
/// Loaded once at startup so every read afterwards is synchronous — a language
/// or theme lookup during `build` cannot be a `Future`.
class PrefsStorage {
  PrefsStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<PrefsStorage> load() async =>
      PrefsStorage(await SharedPreferences.getInstance());

  static const _kLocale = 'locale_code';
  static const _kOnboardingSeen = 'onboarding_seen';
  static const _kTutorialPending = 'tutorial_pending';

  static const _kPageDeferred = 'page_connection_deferred';

  /// Spelled the way the web spells it in `localStorage`, not in this file's
  /// snake_case, so the two platforms name the same preference the same way.
  static const _kStockMode = 'stockMode';
  static const _kLastPageId = 'last_page_id';
  static const _kPushPromptShown = 'push_prompt_shown';
  static const _kDeviceTokenSynced = 'device_token_synced';

  /// Null means "follow the system locale".
  String? get localeCode => _prefs.getString(_kLocale);
  Future<void> setLocaleCode(String? code) async {
    if (code == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, code);
    }
  }

  bool get onboardingSeen => _prefs.getBool(_kOnboardingSeen) ?? false;
  Future<void> setOnboardingSeen(bool value) =>
      _prefs.setBool(_kOnboardingSeen, value);

  /// Whether this merchant still owes the first-run tutorial.
  ///
  /// Set when an account is **created**, never on sign-in. The distinction
  /// matters: an existing merchant signing in on a new handset has no local
  /// state either, so "the flag was never set" cannot be read as "they have
  /// not done it" — only account creation can arm it (brief §21.5, the
  /// tutorial "runs once, immediately after account creation").
  ///
  /// Stays set until the tutorial is finished or skipped, so quitting halfway
  /// resumes rather than silently dropping it.
  bool get tutorialPending => _prefs.getBool(_kTutorialPending) ?? false;
  Future<void> setTutorialPending(bool value) =>
      _prefs.setBool(_kTutorialPending, value);

  /// True when the merchant reached the end of the tutorial without connecting
  /// a Page, and chose to do it later.
  ///
  /// `T5` is the only step that can be deferred, because it is the only one
  /// that depends on something outside the product: Meta has to grant access,
  /// the merchant has to *have* a Page, and it may belong to someone else.
  /// The other three steps either cannot fail or fail only transiently.
  ///
  /// This is what keeps deferral from being silent. Home's `Démarrer`
  /// checklist reads it to show the step as still outstanding — see brief
  /// §21.10. **Nothing reads it yet**, because `09 — Accueil` is still a stub.
  bool get pageConnectionDeferred => _prefs.getBool(_kPageDeferred) ?? false;
  Future<void> setPageConnectionDeferred(bool value) =>
      _prefs.setBool(_kPageDeferred, value);

  /// How much of the stock module to show. A device preference, exactly as on
  /// the web — see [StockMode]. Defaults to Simple, the web's own default.
  StockMode get stockMode => StockMode.fromName(_prefs.getString(_kStockMode));
  Future<void> setStockMode(StockMode mode) =>
      _prefs.setString(_kStockMode, mode.wireName);

  /// Which connected Page the merchant was last looking at, so the inbox opens
  /// where they left it instead of on a picker.
  String? get lastPageId => _prefs.getString(_kLastPageId);
  Future<void> setLastPageId(String? id) async {
    if (id == null) {
      await _prefs.remove(_kLastPageId);
    } else {
      await _prefs.setString(_kLastPageId, id);
    }
  }

  bool get pushPromptShown => _prefs.getBool(_kPushPromptShown) ?? false;
  Future<void> setPushPromptShown(bool value) =>
      _prefs.setBool(_kPushPromptShown, value);

  /// The push token last successfully registered with the backend, so the app
  /// only re-registers when it actually changed.
  String? get syncedDeviceToken => _prefs.getString(_kDeviceTokenSynced);
  Future<void> setSyncedDeviceToken(String? token) async {
    if (token == null) {
      await _prefs.remove(_kDeviceTokenSynced);
    } else {
      await _prefs.setString(_kDeviceTokenSynced, token);
    }
  }

  /// Clears device state on logout but keeps the language choice — a merchant
  /// who set the app to Arabic should not get French back at the login screen.
  Future<void> clearSession() async {
    await _prefs.remove(_kLastPageId);
    await _prefs.remove(_kDeviceTokenSynced);
    // Belong to the account that was signed in, not to the handset. Left
    // behind, they would put the next merchant to sign in on this device into
    // someone else's half-finished tutorial, or show them someone else's
    // outstanding page connection.
    await _prefs.remove(_kTutorialPending);
    await _prefs.remove(_kPageDeferred);
  }
}
