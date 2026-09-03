import 'package:shared_preferences/shared_preferences.dart';

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
  }
}
