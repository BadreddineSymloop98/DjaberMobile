import 'package:djaber_mobile/core/network/api_client.dart';
import 'package:djaber_mobile/core/services/device_info_service.dart';
import 'package:djaber_mobile/core/services/push_service.dart';
import 'package:djaber_mobile/core/storage/prefs_storage.dart';
import 'package:djaber_mobile/core/storage/secure_storage.dart';
import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/data/repositories/auth_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/stock_mode_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A real [SessionViewModel] wired to dependencies that touch nothing.
///
/// Real rather than a mock, because the screens read `isBusy` and `error`
/// straight off it and a stub would let those getters drift from the ones the
/// app actually uses.
///
/// Nothing here reaches the network: no test in this suite submits a valid
/// form, so the API client is constructed but never called. A test that *does*
/// need a request should stub Dio rather than extend this.
///
/// Both stores are given in-memory mocks. The secure one is seeded with a
/// token on purpose, so a sign-out test can assert the token was actually
/// removed rather than only that the in-memory session was dropped.
Future<SessionViewModel> sessionForTest({
  String? token = 'test-token',
  Map<String, Object> prefsValues = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefsValues);
  FlutterSecureStorage.setMockInitialValues(
    token == null ? {} : {'auth_token': token},
  );
  final prefs = await PrefsStorage.load();
  final secure = SecureStorage();

  late final SessionViewModel session;
  final api = ApiClient(
    storage: secure,
    onUnauthorized: () => session.onUnauthorized(),
  );

  session = SessionViewModel(
    authRepository:
        AuthRepository(api: api, secureStorage: secure, prefs: prefs),
    prefs: prefs,
    push: NoopPushService(),
    deviceInfo: const DeviceInfoService.fake(),
  );
  return session;
}

/// Wraps a screen in the app's real theme, localisations and session, and
/// keeps [Screen] current so the `.h` / `.w` extension resolves.
/// A [PrefsStorage] over the same mock store [sessionForTest] set up.
///
/// A second instance rather than the session's own: `SharedPreferences` hands
/// back one shared store per test, so both wrappers read and write the same
/// values and the session's view of a flag cannot drift from the screen's.
Future<PrefsStorage> prefsForTest() => PrefsStorage.load();

/// An [ApiClient] for a repository a screen needs in its provider tree.
///
/// Constructed and never called: no test that uses it submits a form that
/// reaches the network. A test that *does* need a request should inject a
/// stubbed `Dio` through [ApiClient.new]'s `dio` parameter rather than reuse
/// this.
ApiClient apiForTest() => ApiClient(
      storage: SecureStorage(),
      onUnauthorized: () async {},
    );

Widget authHost(
  Widget screen,
  SessionViewModel session, {
  Locale locale = const Locale('fr'),
  PrefsStorage? prefs,
  StockModeViewModel? stockMode,
  List<SingleChildWidget> extra = const [],
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SessionViewModel>.value(value: session),
      if (prefs != null) Provider<PrefsStorage>.value(value: prefs),
      if (stockMode != null)
        ChangeNotifierProvider<StockModeViewModel>.value(value: stockMode),
      // Whatever the screen under test reads beyond the session — its
      // repositories, usually as the fakes in `fake_repositories.dart`.
      ...extra,
    ],
    // Mirrors `app.dart`: `MediaQuery.fromView` sits **above** `MaterialApp`
    // so `Screen` is live before the theme is built. The theme is constructed
    // in `MaterialApp`'s own constructor, which runs before anything in
    // `MaterialApp.builder` — without this the theme sizes every control
    // against a zero-width screen and buttons lay out at **zero height**.
    //
    // It bit here for real: a tap on a themed button silently missed, and the
    // auth suite's "the button matches the input height" assertion had been
    // passing vacuously at 0 == 0. `Screen` is static, so whether a test saw
    // the bug depended on whether an earlier test in the same process had
    // warmed it.
    child: MediaQuery.fromView(
      view: WidgetsBinding.instance.platformDispatcher.views.first,
      child: Builder(
        builder: (context) {
          Screen.update(MediaQuery.of(context));
          return _host(screen, locale);
        },
      ),
    ),
  );
}

Widget _host(Widget screen, Locale locale) => MaterialApp(
      locale: locale,
      theme: AppTheme.build(locale),
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        Screen.update(MediaQuery.of(context));
        return child!;
      },
      home: screen,
    );
