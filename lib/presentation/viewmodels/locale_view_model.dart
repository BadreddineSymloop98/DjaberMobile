import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/prefs_storage.dart';

/// The interface language, and the text direction that follows from it.
///
/// The three the platform ships, matching `LANGS` in `src/lib/i18n.ts`. Arabic
/// is RTL; the whole layout mirrors when it is selected.
enum AppLanguage {
  english('en', 'English', TextDirection.ltr),
  french('fr', 'Français', TextDirection.ltr),
  arabic('ar', 'العربية', TextDirection.rtl);

  const AppLanguage(this.code, this.nativeLabel, this.direction);

  final String code;

  /// Language names appear in their own language, as they do on the web.
  final String nativeLabel;
  final TextDirection direction;

  Locale get locale => Locale(code);
  bool get isRtl => direction == TextDirection.rtl;

  /// The language the app opens in when the handset asks for one this app
  /// does not speak.
  ///
  /// French, not the web's English. The web defaults to English because it
  /// also serves a marketing site; the app is only ever opened by an Algerian
  /// merchant, and French is the working language of the design and the one
  /// this market's back-office software is normally in.
  static const fallback = french;

  static AppLanguage fromCode(String? code) => values.firstWhere(
        (l) => l.code == code,
        orElse: () => fallback,
      );

  /// The handset's own language, if this app speaks it.
  ///
  /// **Only the first entry counts**, because on Android the platform has
  /// already decided by the time this runs.
  ///
  /// The list handed to Flutter is not the phone's. Android resolves it
  /// against the locales the app declares in its Android resources — this app
  /// declares only the default — and **moves its answer to the front**. A
  /// handset whose system list is `de-DE, en-US, ar-DZ, fr-FR` reaches Dart as
  /// `[en_US, de_DE, ar_DZ, fr_FR]`: nothing dropped, `en_US` promoted from
  /// second place to first. `Platform.localeName` and
  /// `PlatformDispatcher.locale` both report the same resolved `en_US`, so
  /// there is no way from Dart to see what the merchant actually set. Only
  /// `Resources.getSystem()`, which Android does not adjust per app, still
  /// holds it — and reading that needs native code we have chosen not to
  /// write.
  ///
  /// So walking further down the list buys nothing here: the entry the
  /// platform put first *is* the platform's answer, and a genuinely
  /// English-first handset is indistinguishable from a promoted one. An
  /// earlier version walked the whole list, which only mattered for a ranking
  /// Android never actually delivers.
  ///
  /// Matched on the language code alone, so `ar-DZ`, `ar-EG` and bare `ar`
  /// all land on Arabic — script and region do not change which of our three
  /// dictionaries applies.
  static AppLanguage fromDeviceLocales(Iterable<Locale> locales) {
    for (final locale in locales.take(1)) {
      for (final language in values) {
        if (language.code == locale.languageCode) return language;
      }
    }
    return fallback;
  }
}

/// Decides which language the app speaks, and keeps the API in step with it.
///
/// **The handset chooses, until the merchant does.** With no stored choice the
/// app takes the phone's own language if it is one of the three, and French
/// otherwise — so an Algerian merchant whose phone is in Arabic opens the app
/// in Arabic without being asked. A phone in Spanish gets French, which is the
/// working language of this market's back-office software.
///
/// The device is *followed*, not sampled once: [didChangeLocales] re-resolves
/// when the merchant changes the system language, so the app matches the phone
/// on the next frame rather than after a reinstall.
///
/// An explicit [setLanguage] outranks the handset **permanently**. It is
/// written to preferences, so it survives a restart and a logout — a merchant
/// who set Arabic should not get French back at the login screen — and from
/// then on the system language is ignored. Anything else would undo their
/// choice the next time they touched a phone setting.
///
/// Two things follow from a change and are done here rather than by callers:
/// the choice is persisted, and `Accept-Language` is set on the API client so
/// the backend's own messages come back in the same language — which now
/// matters, because the backend actually reads that header (brief §24.2).
class LocaleViewModel extends ChangeNotifier with WidgetsBindingObserver {
  LocaleViewModel({
    required PrefsStorage prefs,
    required ApiClient api,
    List<Locale>? deviceLocales,
  })  : _prefs = prefs,
        _api = api,
        _deviceOverride = deviceLocales {
    _resolve();
    // Only when actually running in an app. A caller that states the device
    // locales — a test — has nothing to observe, and requiring a widgets
    // binding just to construct a view model would make every unit test that
    // touches language a widget test.
    if (deviceLocales == null) WidgetsBinding.instance.addObserver(this);
  }

  final PrefsStorage _prefs;
  final ApiClient _api;

  /// Stands in for the platform's list, so a test can state what the handset
  /// asked for instead of trying to change the real device.
  final List<Locale>? _deviceOverride;

  /// `PlatformDispatcher.instance` rather than
  /// `WidgetsBinding.instance.platformDispatcher`: the former comes from
  /// `dart:ui` and needs no binding, so reading the handset's languages does
  /// not drag the whole widget layer into a unit test.
  List<Locale> get _deviceLocales =>
      _deviceOverride ?? PlatformDispatcher.instance.locales;

  void _resolve() {
    final stored = _prefs.localeCode;
    _hasExplicitChoice = stored != null;
    _language = _hasExplicitChoice
        ? AppLanguage.fromCode(stored)
        : AppLanguage.fromDeviceLocales(_deviceLocales);
    _api.setLanguage(_language.code);
  }

  /// The system language changed while the app was installed.
  ///
  /// Followed only when the merchant has not chosen for themselves.
  @override
  void didChangeLocales(List<Locale>? locales) {
    if (_hasExplicitChoice) return;
    final before = _language;
    _language = AppLanguage.fromDeviceLocales(locales ?? _deviceLocales);
    _api.setLanguage(_language.code);
    if (_language != before) notifyListeners();
  }

  @override
  void dispose() {
    if (_deviceOverride == null) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  late AppLanguage _language;
  late bool _hasExplicitChoice;

  AppLanguage get language => _language;
  Locale get locale => _language.locale;
  TextDirection get direction => _language.direction;
  bool get isRtl => _language.isRtl;

  /// False while the app is still following the handset.
  ///
  /// Once true the system language is ignored for good. A first-run language
  /// step, if one is ever built, would read this to know whether the current
  /// language was chosen or merely inherited.
  bool get hasExplicitChoice => _hasExplicitChoice;

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language && _hasExplicitChoice) return;
    _language = language;
    _hasExplicitChoice = true;
    _api.setLanguage(language.code);
    await _prefs.setLocaleCode(language.code);
    notifyListeners();
  }

  // This used to carry the opposite note — that adopting the device locale had
  // been written and removed, because it "would silently defeat the French
  // default on any handset set to English or Arabic". That was the whole point
  // once the decision changed: a merchant whose phone is in Arabic should not
  // have to find a setting to be spoken to in Arabic, and French remains the
  // answer for every handset this app does not speak. Reversed deliberately on
  // 2026-09-10.
  //
  // Narrowed on 2026-09-13 to the handset's *first* language only, once a
  // handset showed that Android resolves the list before Flutter sees it —
  // see [AppLanguage.fromDeviceLocales]. Following the device stands; ranking
  // the device's list does not, because the ranking is not the merchant's.
  //
  // The consequence was accepted rather than worked around: a phone set to a
  // language this app does not speak opens in **English**, not [fallback],
  // because Android picks English on our behalf and Dart cannot see past it.
  // `fallback` still covers the cases that do reach us.
}
