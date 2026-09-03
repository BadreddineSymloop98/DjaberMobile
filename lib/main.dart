import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'core/network/api_client.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/device_info_service.dart';
import 'core/services/push_service.dart';
import 'core/storage/prefs_storage.dart';
import 'core/storage/secure_storage.dart';
import 'core/utils/logger.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/theme/app_colors.dart';
import 'presentation/viewmodels/session_view_model.dart';

void main() {
  // `runZonedGuarded` catches what `FlutterError.onError` does not — an
  // uncaught async error in a repository or a stream. Without it those are
  // silent in release, which is how a merchant ends up with an app that
  // quietly stops updating.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        Log.e(
          details.exceptionAsString(),
          tag: 'flutter',
          stackTrace: details.stack,
        );
      };

      await SystemChrome.setPreferredOrientations([
        // Portrait only. Every screen in the design is a phone frame, and the
        // merchant uses this one-handed while standing with a customer.
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.ink,
        systemNavigationBarIconBrightness: Brightness.light,
      ));

      final bootstrap = await _bootstrap();
      runApp(
        MultiProvider(
          providers: AppProviders.build(
            prefs: bootstrap.prefs,
            secureStorage: bootstrap.secureStorage,
            deviceInfo: bootstrap.deviceInfo,
            connectivity: bootstrap.connectivity,
            push: bootstrap.push,
            api: bootstrap.api,
            session: bootstrap.session,
          ),
          child: DjaberApp(router: bootstrap.router),
        ),
      );
    },
    (error, stack) => Log.e('uncaught', tag: 'zone', error: error, stackTrace: stack),
  );
}

/// Everything that must exist before the first frame.
///
/// Assembled here rather than lazily in the provider tree because of one
/// circular dependency: [ApiClient] has to end the session on a 401, and
/// [SessionViewModel] needs an [ApiClient] to make requests. Constructing both
/// in order and handing the client a callback breaks the cycle in one visible
/// place instead of hiding it behind a lazy proxy.
Future<_Bootstrap> _bootstrap() async {
  final prefs = await PrefsStorage.load();
  final secureStorage = SecureStorage();
  final deviceInfo = await DeviceInfoService.load();

  final connectivity = ConnectivityService();
  await connectivity.init();

  // No transport yet — brief §7/Q5. The app runs, and escalations do not
  // arrive. See `core/services/push_service.dart`.
  final push = NoopPushService();
  await push.initialize();

  // Filled in immediately below, once the session exists.
  late final SessionViewModel session;

  final api = ApiClient(
    storage: secureStorage,
    onUnauthorized: () => session.onUnauthorized(),
  );

  session = SessionViewModel(
    authRepository: AuthRepository(
      api: api,
      secureStorage: secureStorage,
      prefs: prefs,
    ),
    prefs: prefs,
    push: push,
    deviceInfo: deviceInfo,
  );

  final router = AppRouter(session: session, push: push);

  Log.i(
    'boot · ${deviceInfo.platform} · ${deviceInfo.manufacturer} '
    '${deviceInfo.model} · v${deviceInfo.versionLabel}',
    tag: 'app',
  );
  if (deviceInfo.needsAutostartGuidance) {
    Log.w(
      '${deviceInfo.manufacturer} handset — push needs autostart / battery '
      'exemption to be reliable (brief §9).',
      tag: 'push',
    );
  }

  // Restores the stored session and reads any notification that launched the
  // app. Both are awaited so the router's first redirect already knows where
  // the merchant belongs, rather than flashing login and then correcting.
  await session.restore();
  await router.consumeLaunchNotification();

  return _Bootstrap(
    prefs: prefs,
    secureStorage: secureStorage,
    deviceInfo: deviceInfo,
    connectivity: connectivity,
    push: push,
    api: api,
    session: session,
    router: router,
  );
}

class _Bootstrap {
  const _Bootstrap({
    required this.prefs,
    required this.secureStorage,
    required this.deviceInfo,
    required this.connectivity,
    required this.push,
    required this.api,
    required this.session,
    required this.router,
  });

  final PrefsStorage prefs;
  final SecureStorage secureStorage;
  final DeviceInfoService deviceInfo;
  final ConnectivityService connectivity;
  final PushService push;
  final ApiClient api;
  final SessionViewModel session;
  final AppRouter router;
}
