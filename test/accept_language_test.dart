import 'dart:ui' show Locale;

import 'package:dio/dio.dart';
import 'package:djaber_mobile/core/network/api_client.dart';
import 'package:djaber_mobile/core/storage/prefs_storage.dart';
import 'package:djaber_mobile/core/storage/secure_storage.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `Accept-Language` on the wire.
///
/// This header is the whole reason the backend's messages come back in the
/// merchant's language, so it is worth an actual assertion rather than a
/// reading of the code. It was also sent — correctly — for weeks while the
/// backend ignored it entirely, which is exactly the kind of thing that rots
/// unnoticed.
///
/// The ordering it depends on is not obvious: `LocaleViewModel` is registered
/// with a **lazy** `ChangeNotifierProvider`, so the header is only set once
/// something reads the model. What guarantees it happens first is that
/// `app.dart` does `context.watch<LocaleViewModel>()` while building
/// `MaterialApp` — during the first frame — whereas the splash screen defers
/// its `restore()` to `addPostFrameCallback`. Move that restore into
/// `initState` and the first request would go out unlabelled.
///
/// Every model here is handed the handset's languages explicitly, because
/// since 2026-09-10 they are what decides the answer: with no stored choice
/// the app speaks the phone's language if it is one of the three, and French
/// otherwise.
void main() {
  late List<RequestOptions> sent;
  late ApiClient api;
  late PrefsStorage prefs;

  Future<void> boot({String? storedLocale}) async {
    SharedPreferences.setMockInitialValues(
      storedLocale == null ? {} : {'locale_code': storedLocale},
    );
    FlutterSecureStorage.setMockInitialValues({});
    prefs = await PrefsStorage.load();

    sent = [];
    final dio = Dio()..httpClientAdapter = _Recorder(sent);
    api = ApiClient(
      storage: SecureStorage(),
      onUnauthorized: () async {},
      dio: dio,
    );
  }

  String? headerOf(RequestOptions options) =>
      options.headers['Accept-Language'] as String?;

  test('the handset decides when nothing is stored', () async {
    await boot();
    // Nothing has read the model yet — this mirrors the lazy provider.
    LocaleViewModel(prefs: prefs, api: api, deviceLocales: const [Locale('ar')]);

    await api.get<dynamic>('/api/auth/profile');
    expect(headerOf(sent.single), 'ar');
  });

  test('a handset in a language the app does not speak gets French',
      () async {
    await boot();
    LocaleViewModel(
      prefs: prefs,
      api: api,
      deviceLocales: const [Locale('es'), Locale('pt')],
    );

    await api.get<dynamic>('/api/auth/profile');
    expect(headerOf(sent.single), 'fr');
  });

  test('only the phone\'s first language is read, not the rest of its list',
      () async {
    await boot();
    // Android hands over a ranked list, and this used to walk all of it — so
    // this case resolved to Arabic. It no longer does.
    //
    // The handset settled it, and not the way the walk assumed. Android
    // resolves the list against the locales the app declares in its Android
    // resources and moves its answer to the front before Flutter sees
    // anything: a device whose system list is `de-DE,en-US,ar-DZ,fr-FR`
    // reaches Dart as `[en_US, de_DE, ar_DZ, fr_FR]`. So a list like the one
    // below — an unsupported language genuinely ranked first — is not
    // something Android delivers, and walking past the first entry only ever
    // second-guessed a decision the platform had already made.
    LocaleViewModel(
      prefs: prefs,
      api: api,
      deviceLocales: const [Locale('es'), Locale('ar'), Locale('fr')],
    );

    await api.get<dynamic>('/api/auth/profile');
    expect(headerOf(sent.single), 'fr');
  });

  test('a region does not change the dictionary — ar-DZ is Arabic', () async {
    await boot();
    LocaleViewModel(
      prefs: prefs,
      api: api,
      deviceLocales: const [Locale('ar', 'DZ')],
    );

    await api.get<dynamic>('/api/auth/profile');
    expect(headerOf(sent.single), 'ar');
  });

  test('a stored choice outranks the handset, permanently', () async {
    await boot(storedLocale: 'ar');
    // The phone says English; the merchant said Arabic. Theirs wins, or a
    // change to a phone setting would silently undo it.
    final model = LocaleViewModel(
      prefs: prefs,
      api: api,
      deviceLocales: const [Locale('en')],
    );

    await api.get<dynamic>('/api/pages');
    expect(headerOf(sent.single), 'ar');
    expect(model.hasExplicitChoice, isTrue);

    // And a later system-language change is ignored.
    model.didChangeLocales(const [Locale('en')]);
    await api.get<dynamic>('/api/pages');
    expect(headerOf(sent.last), 'ar');
  });

  test('while still following the handset, a system-language change is '
      'followed', () async {
    await boot();
    final model = LocaleViewModel(
      prefs: prefs,
      api: api,
      deviceLocales: const [Locale('fr')],
    );
    expect(model.hasExplicitChoice, isFalse);

    model.didChangeLocales(const [Locale('ar')]);

    await api.get<dynamic>('/api/pages');
    expect(headerOf(sent.single), 'ar');
    expect(model.locale.languageCode, 'ar');
  });

  test('changing the language changes it for subsequent requests', () async {
    await boot();
    final model = LocaleViewModel(
      prefs: prefs,
      api: api,
      deviceLocales: const [Locale('fr')],
    );

    await api.get<dynamic>('/api/pages');
    await model.setLanguage(AppLanguage.arabic);
    await api.get<dynamic>('/api/pages');
    await model.setLanguage(AppLanguage.english);
    await api.get<dynamic>('/api/pages');

    expect(sent.map(headerOf).toList(), ['fr', 'ar', 'en']);
  });

  test('it rides on writes too, not just reads — a validation failure has to '
      'come back translated', () async {
    await boot(storedLocale: 'ar');
    LocaleViewModel(
      prefs: prefs,
      api: api,
      deviceLocales: const [Locale('fr')],
    );

    await api.post<dynamic>('/api/user-stock/products', body: {'sku': 'X'});
    expect(headerOf(sent.single), 'ar');
    expect(sent.single.method, 'POST');
  });

  test('choosing the language already inherited from the handset pins it — '
      'the Settings cards must not leave it following the phone', () async {
    await boot();
    final model = LocaleViewModel(
      prefs: prefs,
      api: api,
      deviceLocales: const [Locale('fr')],
    );
    expect(model.hasExplicitChoice, isFalse);

    await model.setLanguage(AppLanguage.french);
    expect(model.hasExplicitChoice, isTrue);

    // The phone switches to Arabic; the app stays in French.
    model.didChangeLocales(const [Locale('ar')]);
    await api.get<dynamic>('/api/pages');
    expect(headerOf(sent.single), 'fr');
    expect(model.locale.languageCode, 'fr');
  });

  test('the choice survives a restart, because it is read back from prefs',
      () async {
    await boot();
    final model = LocaleViewModel(
      prefs: prefs,
      api: api,
      deviceLocales: const [Locale('fr')],
    );
    await model.setLanguage(AppLanguage.arabic);

    // A new process: same stored prefs, a fresh client and model.
    final dio = Dio()..httpClientAdapter = _Recorder(sent = []);
    final restarted = ApiClient(
      storage: SecureStorage(),
      onUnauthorized: () async {},
      dio: dio,
    );
    LocaleViewModel(
      prefs: await PrefsStorage.load(),
      api: restarted,
      // The phone is in French; the stored Arabic must still win.
      deviceLocales: const [Locale('fr')],
    );

    await restarted.get<dynamic>('/api/auth/profile');
    expect(headerOf(sent.single), 'ar');
  });
}

class _Recorder implements HttpClientAdapter {
  _Recorder(this.sent);

  final List<RequestOptions> sent;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    sent.add(options);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
