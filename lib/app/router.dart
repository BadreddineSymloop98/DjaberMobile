import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/services/push_service.dart';
import '../core/utils/logger.dart';
import '../data/models/agent.dart';
import '../l10n/gen/app_localizations.dart';
import '../presentation/screens/agents/agent_details_screen.dart';
import '../presentation/screens/agents/agent_new_screen.dart';
import '../presentation/screens/agents/agent_presets_screen.dart';
import '../presentation/screens/agents/agent_test_chat_screen.dart';
import '../presentation/screens/agents/agents_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/password_sent_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/home/home_shell.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/products/add_product_screen.dart';
import '../presentation/screens/products/products_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/tutorial/tutorial_agent_screen.dart';
import '../presentation/screens/tutorial/tutorial_connect_screen.dart';
import '../presentation/screens/tutorial/tutorial_intro_screen.dart';
import '../presentation/screens/tutorial/tutorial_mode_screen.dart';
import '../presentation/screens/tutorial/tutorial_product_screen.dart';
import '../presentation/screens/tutorial/tutorial_ready_screen.dart';
import '../presentation/viewmodels/session_view_model.dart';
import '../presentation/widgets/exit_guard.dart';
import '../presentation/widgets/placeholder_screen.dart';
import 'routes.dart';

/// The navigation graph and the redirect policy.
///
/// Splash and onboarding are built. Every other route is still wired to
/// [PlaceholderScreen] — building a screen means replacing one `builder` line.
class AppRouter {
  AppRouter({required SessionViewModel session, required PushService push})
      : _session = session,
        _push = push {
    _listenForNotificationTaps();
  }

  final SessionViewModel _session;
  final PushService _push;
  final _rootKey = GlobalKey<NavigatorState>();
  final _shellKey = GlobalKey<NavigatorState>();

  StreamSubscription<PushMessage>? _pushSubscription;

  /// A deep link that arrived before the router could act on it — a
  /// notification tapped from a cold start, or one that arrived while the
  /// session was still being restored. Consumed once the app is signed in.
  String? _pendingDeepLink;

  /// Where the merchant was when the splash took the screen back.
  ///
  /// The splash replays every time the app is backgrounded, so without this a
  /// merchant who glances at another app mid-conversation comes back to the
  /// home screen. Restored once the splash finishes.
  String? _locationBeforeSplash;

  /// The auth screens worth handing back after the splash — the three with a
  /// form. The sent screen is left out: it is built from the address it was
  /// opened with, which a redirect cannot carry.
  static const _restorableAuthPaths = {
    Routes.login,
    Routes.signup,
    Routes.forgotPassword,
  };

  /// Where the merchant actually is: the screen on top, not the one under it.
  ///
  /// A redirect is handed the location of the stack's base, so a screen
  /// opened with `push` — Add product over the product list — was remembered
  /// as the list, and the splash handed that back instead. The top match
  /// carries the pushed location itself.
  String _topLocation(String fallback) {
    final current = router.routerDelegate.currentConfiguration;
    if (current.isError || current.matches.isEmpty) return fallback;
    final top = current.last.matchedLocation;
    return Routes.publicPaths.contains(top) ? fallback : top;
  }

  late final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    refreshListenable: _session,
    redirect: _redirect,
    errorBuilder: (context, state) => PlaceholderScreen(
      title: 'Route not found',
      detail: state.uri.toString(),
    ),
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => _guard(const OnboardingScreen()),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, _) => _guard(const LoginScreen()),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (_, _) => _guard(const SignupScreen()),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => _guard(const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: Routes.passwordSent,
        // The address travels as `extra` so it never appears in a URL. A cold
        // deep link therefore arrives without it, and the screen omits the
        // address block rather than inventing one.
        builder: (_, state) => _guard(PasswordSentScreen(
          email: state.extra is String ? state.extra as String : null,
        )),
      ),

      // The first-run tutorial. Outside the shell: it owns the whole screen
      // and has no bottom nav, because the merchant has nothing to navigate
      // to yet.
      GoRoute(
        path: Routes.tutorial,
        builder: (_, _) => const TutorialIntroScreen(),
      ),
      GoRoute(
        path: Routes.tutorialMode,
        builder: (_, _) => const TutorialModeScreen(),
      ),
      GoRoute(
        path: Routes.tutorialProduct,
        builder: (_, _) => const TutorialProductScreen(),
      ),
      GoRoute(
        path: Routes.tutorialAgent,
        builder: (_, _) => const TutorialAgentScreen(),
      ),
      GoRoute(
        path: Routes.tutorialConnect,
        builder: (_, _) => const TutorialConnectScreen(),
      ),
      GoRoute(
        path: Routes.tutorialReady,
        builder: (_, _) => const TutorialReadyScreen(),
      ),

      // The five bottom-nav destinations of brief §16. They live in a
      // ShellRoute so the custom nav bar is built once and does not rebuild
      // or animate when the tab changes.
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, _, child) => _guard(HomeShell(child: child)),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (_, _) => const HomeScreen(),
          ),
          GoRoute(
            path: Routes.queue,
            builder: (context, _) =>
                PlaceholderScreen(title: L10n.of(context).navQueue),
          ),
          GoRoute(
            path: Routes.inbox,
            builder: (context, _) =>
                PlaceholderScreen(title: L10n.of(context).navInbox),
          ),
          GoRoute(
            path: Routes.stock,
            builder: (context, _) =>
                PlaceholderScreen(title: L10n.of(context).navStock),
          ),
          GoRoute(
            path: Routes.orders,
            builder: (context, _) =>
                PlaceholderScreen(title: L10n.of(context).navOrders),
          ),
        ],
      ),

      // Pushed over the shell — full screen, with the nav bar hidden.
      // `Conversation` and `Produit` keep their French placeholder titles:
      // no `l10n` key exists for either, and inventing copy for a screen that
      // does not exist would be copy to approve twice. `Produit` — the product
      // *detail* screen — is now reachable, from a row on `17`, which makes it
      // the next one worth building.
      GoRoute(
        path: Routes.conversation,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => _guard(PlaceholderScreen(
          title: 'Conversation',
          detail: state.pathParameters['id'],
        )),
      ),
      GoRoute(
        path: Routes.products,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => _guard(const ProductsScreen()),
      ),
      GoRoute(
        path: Routes.agents,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => _guard(const AgentsScreen()),
      ),
      // Pushed over the agents screen, so not guarded — back pops to it.
      // Before /agents/:id, which would otherwise match `new`.
      GoRoute(
        path: Routes.agentNew,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const AgentPresetsScreen(),
      ),
      GoRoute(
        path: Routes.agentNewScratch,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const AgentNewScreen(),
      ),
      GoRoute(
        path: Routes.agent,
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            AgentDetailsScreen(agentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.agentTest,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => AgentTestChatScreen(
          agentId: state.pathParameters['id']!,
          agent: state.extra is Agent ? state.extra as Agent : null,
        ),
      ),
      GoRoute(
        path: Routes.agentEdit,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => AgentEditScreen(agentId: state.pathParameters['id']!),
      ),
      // Declared before `/products/:id`, which would otherwise match it — see
      // [Routes.productNew]. Deliberately **not** wrapped in `ExitGuard`: it
      // is always pushed on top of the list, so back has somewhere to go and
      // a "tap again to leave" prompt would be a lie.
      GoRoute(
        path: Routes.productNew,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const AddProductScreen(),
      ),
      GoRoute(
        path: Routes.product,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => _guard(PlaceholderScreen(
          title: 'Produit',
          detail: state.pathParameters['id'],
        )),
      ),
      GoRoute(
        path: Routes.notifications,
        parentNavigatorKey: _rootKey,
        builder: (context, _) => _guard(
          PlaceholderScreen(title: L10n.of(context).menuNotifications),
        ),
      ),
      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: _rootKey,
        builder: (context, _) => _guard(
          PlaceholderScreen(title: L10n.of(context).menuSettings),
        ),
      ),
    ],
  );


  /// Wraps a top-level screen so back asks before closing the app.
  ///
  /// Applied to every screen a merchant can be sitting on with an empty
  /// navigation stack — which, because this app navigates with `go`, is all of
  /// them. **Not** applied to the splash (it lasts under two seconds and has
  /// nothing to lose) or to the tutorial, which has its own `PopScope`: there,
  /// back must not leave at all until a step is done.
  static Widget _guard(Widget child) => ExitGuard(child: child);

  /// Decides where a navigation actually lands.
  ///
  /// Three rules, in order: hold on the splash until the stored session has
  /// been checked; a signed-out merchant only reaches public routes; a
  /// signed-in one never sits on an auth screen.
  String? _redirect(BuildContext context, GoRouterState state) {
    final status = _session.status;
    final location = state.matchedLocation;
    final isPublic = Routes.publicPaths.contains(location);

    // The splash owns the boot: it runs the session restore and holds for the
    // minimum display time, then flips the gate. Until then nothing moves.
    if (!_session.isBootComplete) {
      if (location == Routes.splash) return null;
      // Remember a real destination so the splash hands it back afterwards:
      // a signed-in merchant's screen, or the auth form a signed-out one was
      // filling in. That form's values survive in `FormDraftStore`, but they
      // are no use on the wrong screen — sign-up used to come back as login.
      if (_session.isSignedIn
          ? !isPublic
          : _restorableAuthPaths.contains(location)) {
        _locationBeforeSplash =
            _session.isSignedIn ? _topLocation(location) : location;
      }
      return Routes.splash;
    }

    if (status == AuthStatus.signedOut) {
      final resume = _locationBeforeSplash;
      _locationBeforeSplash = null;
      if (isPublic && location != Routes.splash) return null;
      // Back to the auth form they left, when that is where they were. A
      // signed-in screen remembered before the session ended is not one.
      if (resume != null && _restorableAuthPaths.contains(resume)) {
        return resume;
      }
      return _session.onboardingSeen ? Routes.login : Routes.onboarding;
    }

    // Signed in. A tapped notification outranks wherever they happened to be —
    // it is a specific request, not a resumption.
    final pending = _pendingDeepLink;
    if (pending != null) {
      _pendingDeepLink = null;
      _locationBeforeSplash = null;
      Log.i('opening deep link $pending', tag: 'push');
      return pending;
    }

    // A merchant who has just created an account is walked through setup
    // before they reach the app (brief §21.5). This outranks resuming where
    // they were, and it applies to every route rather than only the public
    // ones — otherwise a deep link or a `go(home)` would step around it.
    //
    // It does not outrank a tapped notification, above: that is a specific
    // request from outside the app, and the tutorial will still be waiting.
    if (_session.tutorialPending) {
      if (location.startsWith(Routes.tutorial)) return null;
      // Dropped rather than kept: the remembered location is from before the
      // tutorial, and restoring it afterwards would bounce the merchant out
      // of the flow they had just finished.
      _locationBeforeSplash = null;
      // The furthest step reached, not the intro. Sending a returning
      // merchant back to the start looks harmless and is not: the walk
      // forward is not repeatable — `T4` creates an agent and one agent per
      // user is enforced, so they hit a 403 with no `Passer`, no sign-out and
      // no route to `T5`'s deferral. See [SessionViewModel.tutorialResumeRoute].
      return _session.tutorialResumeRoute;
    }

    final resume = _locationBeforeSplash;
    if (resume != null) {
      _locationBeforeSplash = null;
      return resume;
    }

    if (isPublic) return Routes.home;
    return null;
  }

  /// A notification tap becomes a navigation.
  ///
  /// If the session is not ready — the app is cold-starting, or the profile is
  /// still being fetched — the destination is held in [_pendingDeepLink] and
  /// applied by the next redirect, instead of being dropped. For a product
  /// whose value is measured in seconds, losing the link and landing on home
  /// is the failure worth engineering against.
  void _listenForNotificationTaps() {
    _pushSubscription = _push.onMessageOpened.listen((message) {
      final route = message.route;
      if (route == null) return;
      if (_session.isSignedIn) {
        router.go(route);
      } else {
        _pendingDeepLink = route;
      }
    });
  }

  /// Reads the notification that launched the app, if any. Called from `main`
  /// after the router exists.
  Future<void> consumeLaunchNotification() async {
    final message = await _push.getInitialMessage();
    final route = message?.route;
    if (route == null) return;
    _pendingDeepLink = route;
    if (_session.isSignedIn) router.go(route);
  }

  void dispose() {
    _pushSubscription?.cancel();
    router.dispose();
  }
}
