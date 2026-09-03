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

  /// The language the app opens in before anyone chooses one.
  ///
  /// French, not the web's English. The web defaults to English because it also
  /// serves a marketing site; the app is only ever opened by an Algerian
  /// merchant, and French is the working language of the design and the one
  /// this market's back-office software is normally in.
  ///
  /// This is not the final answer — the market is Arabic-first, and a first-run
  /// language step is still needed. Until it exists, French is the least wrong
  /// default rather than the right one.
  static const fallback = french;

  static AppLanguage fromCode(String? code) => values.firstWhere(
        (l) => l.code == code,
        orElse: () => fallback,
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

  // Deliberately no "adopt the device locale on first run". It was written and
  // removed: it is unreferenced, and it would silently defeat the French
  // default above on any handset set to English or Arabic. The first-run
  // language step is the right answer, and it does not exist yet.
}
