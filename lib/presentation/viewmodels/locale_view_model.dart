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

  static AppLanguage fromCode(String? code) => values.firstWhere(
        (l) => l.code == code,
        orElse: () => english,
      );
}

/// Holds the chosen language and persists it.
///
/// Two things follow from a change and are done here rather than by callers:
/// the choice is written to preferences so it survives a restart *and a
/// logout* (a merchant who set Arabic should not get English back at the login
/// screen), and `Accept-Language` is set on the API client so backend-generated
/// copy comes back in the same language.
class LocaleViewModel extends ChangeNotifier {
  LocaleViewModel({required PrefsStorage prefs, required ApiClient api})
      : _prefs = prefs,
        _api = api {
    _language = AppLanguage.fromCode(_prefs.localeCode);
    _hasExplicitChoice = _prefs.localeCode != null;
    _api.setLanguage(_language.code);
  }

  final PrefsStorage _prefs;
  final ApiClient _api;

  late AppLanguage _language;
  late bool _hasExplicitChoice;

  AppLanguage get language => _language;
  Locale get locale => _language.locale;
  TextDirection get direction => _language.direction;
  bool get isRtl => _language.isRtl;

  /// False until the merchant picks a language themselves.
  ///
  /// The market is Arabic-first but the app defaults to the web's English, so
  /// a first-run language step is almost certainly needed. It is not built —
  /// this flag is what a first-run step would read.
  bool get hasExplicitChoice => _hasExplicitChoice;

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language && _hasExplicitChoice) return;
    _language = language;
    _hasExplicitChoice = true;
    _api.setLanguage(language.code);
    await _prefs.setLocaleCode(language.code);
    notifyListeners();
  }

  /// Adopts the device language on first run, when it is one the app speaks.
  /// Never overrides a choice the merchant made.
  Future<void> adoptDeviceLocale(Locale deviceLocale) async {
    if (_hasExplicitChoice) return;
    final match = AppLanguage.values
        .where((l) => l.code == deviceLocale.languageCode)
        .firstOrNull;
    if (match == null || match == _language) return;
    _language = match;
    _api.setLanguage(match.code);
    notifyListeners();
  }
}
