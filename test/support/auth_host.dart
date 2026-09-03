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
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A real [SessionViewModel] wired to dependencies that touch nothing.
///
/// Real rather than a mock, because the screens read `isBusy` and `error`
/// straight off it and a stub would let those getters drift from the ones the
/// app actually uses.
///
/// Nothing here reaches a platform channel or the network: `SharedPreferences`
/// is given mock values, `SecureStorage` only hits the Keystore when read or
/// written, and no test in this suite submits a valid form — so the API client
/// is constructed but never called. A test that *does* need a request should
/// stub Dio rather than extend this.
Future<SessionViewModel> sessionForTest() async {
  SharedPreferences.setMockInitialValues({});
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
Widget authHost(
  Widget screen,
  SessionViewModel session, {
  Locale locale = const Locale('fr'),
}) {
  return ChangeNotifierProvider<SessionViewModel>.value(
    value: session,
    child: MaterialApp(
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
    ),
  );
}
