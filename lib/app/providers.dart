import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/network/api_client.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/device_info_service.dart';
import '../core/services/push_service.dart';
import '../core/storage/prefs_storage.dart';
import '../core/storage/secure_storage.dart';
import '../data/repositories/agent_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/billing_repository.dart';
import '../data/repositories/catalogue_repository.dart';
import '../data/repositories/client_repository.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/inbox_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/page_repository.dart';
import '../data/repositories/product_repository.dart';
import '../presentation/viewmodels/form_draft_store.dart';
import '../presentation/viewmodels/locale_view_model.dart';
import '../presentation/viewmodels/session_view_model.dart';
import '../presentation/viewmodels/stock_mode_view_model.dart';
import '../presentation/viewmodels/tutorial_view_model.dart';

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
      Provider<ProductRepository>(
        create: (context) => ProductRepository(api: context.read<ApiClient>()),
      ),
      // Categories and units — the two lookup lists the product form fills
      // its pickers from.
      Provider<CatalogueRepository>(
        create: (context) =>
            CatalogueRepository(api: context.read<ApiClient>()),
      ),
      Provider<ClientRepository>(
        create: (context) => ClientRepository(api: context.read<ApiClient>()),
      ),
      Provider<AgentRepository>(
        create: (context) => AgentRepository(api: context.read<ApiClient>()),
      ),
      Provider<PageRepository>(
        create: (context) => PageRepository(api: context.read<ApiClient>()),
      ),
      Provider<DashboardRepository>(
        create: (context) =>
            DashboardRepository(api: context.read<ApiClient>()),
      ),
      // Conversations, replies, status and sync — `10` and `10b`.
      Provider<InboxRepository>(
        create: (context) => InboxRepository(api: context.read<ApiClient>()),
      ),
      Provider<NotificationRepository>(
        create: (context) =>
            NotificationRepository(api: context.read<ApiClient>()),
      ),
      // Plans and checkout — `11 — Paramètres`.
      Provider<BillingRepository>(
        create: (context) => BillingRepository(api: context.read<ApiClient>()),
      ),
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

      // App-wide because the mode decides what several screens show, not one:
      // the menu, the stock overview, and the settings section that changes
      // it. A device preference, not a backend field — see [StockModeViewModel].
      ChangeNotifierProvider<StockModeViewModel>(
        create: (context) => StockModeViewModel(
          prefs: context.read<PrefsStorage>(),
        ),
      ),

      // What the tutorial has created so far. App-wide only because the four
      // steps are separate routes; it is reset when the tutorial ends.
      ChangeNotifierProvider<TutorialViewModel>(
        create: (_) => TutorialViewModel(),
      ),

      // Unsent form values that must survive the splash replaying on return —
      // see [FormDraftStore]. A plain `Provider`: nothing redraws on a draft.
      Provider<FormDraftStore>(
        create: (_) => FormDraftStore(session: session),
        dispose: (_, store) => store.dispose(),
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

  /// Watch when a screen's *content* depends on the mode — hiding a section,
  /// filtering a list. Read when only an action does.
  StockModeViewModel get stockMode => watch<StockModeViewModel>();
  StockModeViewModel get stockModeOnce => read<StockModeViewModel>();

  ConnectivityService get connectivity => watch<ConnectivityService>();

  ApiClient get api => read<ApiClient>();
  PrefsStorage get prefs => read<PrefsStorage>();
  DeviceInfoService get deviceInfo => read<DeviceInfoService>();
}
