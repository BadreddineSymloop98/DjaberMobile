import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/network/api_client.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/device_info_service.dart';
import '../core/services/push_service.dart';
import '../core/storage/prefs_storage.dart';
import '../core/storage/secure_storage.dart';
import '../data/repositories/auth_repository.dart';
import '../presentation/viewmodels/locale_view_model.dart';
import '../presentation/viewmodels/session_view_model.dart';

/// Dependency injection.
///
/// `provider` does both jobs here — object graph and state — rather than
/// pairing it with a service locator. One mechanism means one lookup rule, and
/// it keeps everything a screen depends on visible in the widget tree instead
/// of hidden in a global registry.
///
/// The layering is strict, bottom up:
///
///   storage & services  →  ApiClient  →  repositories  →  view models
///
/// Anything that lives for the whole app is registered here. A view model that
/// belongs to a single screen is *not* — it is created by that screen with its
/// own `ChangeNotifierProvider`, so its state dies with the screen instead of
/// leaking into the next one.
class AppProviders {
  const AppProviders._();

  static List<SingleChildWidget> build({
    required PrefsStorage prefs,
    required SecureStorage secureStorage,
    required DeviceInfoService deviceInfo,
    required ConnectivityService connectivity,
    required PushService push,
    required ApiClient api,
    required SessionViewModel session,
  }) {
    return [
      // ---- Infrastructure. Already constructed in `main`, because the app
      // cannot start without them and `ApiClient` needs a session to call on
      // a 401 — a circular dependency that is resolved once, there, rather
      // than papered over with a lazy proxy here.
      Provider<PrefsStorage>.value(value: prefs),
      Provider<SecureStorage>.value(value: secureStorage),
      Provider<DeviceInfoService>.value(value: deviceInfo),
      Provider<PushService>.value(value: push),
      Provider<ApiClient>.value(value: api),

      ChangeNotifierProvider<ConnectivityService>.value(value: connectivity),

      // ---- Repositories. Stateless, so `Provider` rather than
      // `ChangeNotifierProvider`: they answer questions, they do not hold
      // screen state.
      Provider<AuthRepository>(
        create: (context) => AuthRepository(
          api: context.read<ApiClient>(),
          secureStorage: context.read<SecureStorage>(),
          prefs: context.read<PrefsStorage>(),
        ),
      ),

      // ---- App-wide view models.
      ChangeNotifierProvider<SessionViewModel>.value(value: session),
      ChangeNotifierProvider<LocaleViewModel>(
        create: (context) => LocaleViewModel(
          prefs: context.read<PrefsStorage>(),
          api: context.read<ApiClient>(),
        ),
      ),
    ];
  }
}

/// Shorthands so screens read as `context.session` rather than
/// `context.watch<SessionViewModel>()`.
///
/// `watch` rebuilds, `read` does not — the distinction that decides whether a
/// screen updates, so it is spelled out in the names rather than left to the
/// call site.
extension AppContext on BuildContext {
  SessionViewModel get session => watch<SessionViewModel>();
  SessionViewModel get sessionOnce => read<SessionViewModel>();

  LocaleViewModel get localeModel => watch<LocaleViewModel>();
  LocaleViewModel get localeModelOnce => read<LocaleViewModel>();

  ConnectivityService get connectivity => watch<ConnectivityService>();

  ApiClient get api => read<ApiClient>();
  PrefsStorage get prefs => read<PrefsStorage>();
  DeviceInfoService get deviceInfo => read<DeviceInfoService>();
}
