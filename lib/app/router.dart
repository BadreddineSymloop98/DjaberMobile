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
import '../presentation/screens/auth/reset_password_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/home/home_shell.dart';
import '../presentation/screens/inbox/conversation_screen.dart';
import '../presentation/screens/inbox/inbox_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/pages/pages_screen.dart';
import '../presentation/screens/products/add_product_screen.dart';
import '../presentation/screens/products/product_detail_screen.dart';
import '../presentation/screens/products/products_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/stock/stock_overview_screen.dart';
import '../presentation/screens/tutorial/tutorial_agent_screen.dart';
import '../presentation/screens/tutorial/tutorial_connect_screen.dart';
import '../presentation/screens/tutorial/tutorial_intro_screen.dart';
import '../presentation/screens/tutorial/tutorial_mode_screen.dart';
import '../presentation/screens/tutorial/tutorial_product_screen.dart';
import '../presentation/screens/tutorial/tutorial_ready_screen.dart';
import '../presentation/viewmodels/session_view_model.dart';
import '../presentation/widgets/back_scope.dart';
import '../presentation/widgets/placeholder_screen.dart';
import 'routes.dart';

/// The navigation graph and the redirect policy.
///
/// **Back is declared here.** Every page builder wraps its screen in a
/// [BackScope]: either the page's parent, used when nothing is below it, or
/// [BackScope.root] for the few screens where back really leaves the app
/// (home, login, onboarding, and the tutorial's roots). "Tap again to leave"
/// can show nowhere else.
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

  /// The auth screens worth handing back after the splash.
  ///
  /// The reset flow makes the merchant leave the app to read the e-mail, and
  /// the splash replays on every return, so the sent screen must come back
  /// too, or the merchant lands on login mid-flow. It returns without its
  /// address (a redirect cannot carry `extra`) and omits it. The reset screen
  /// is remembered with its query, so its `token` survives.
  static const _restorableAuthPaths = {
    Routes.login,
    Routes.signup,
    Routes.forgotPassword,
    Routes.passwordSent,
    Routes.resetPassword,
  };

  /// The bottom-nav tabs. They live on the shell navigator, so they are only
  /// ever reached with `go`: pushing one from a root-navigator page would add
  /// a second shell match with the same navigator key.
  static const _shellPaths = {
    Routes.home,
    Routes.queue,
    Routes.inbox,
    Routes.stock,
    Routes.orders,
  };

  static bool _isShellLocation(String location) =>
      _shellPaths.contains(Uri.parse(location).path);

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
    errorBuilder: (context, state) => BackScope(
      fallback: Routes.home,
      child: PlaceholderScreen(
        title: 'Route not found',
        detail: state.uri.toString(),
      ),
    ),
    routes: [
      GoRoute(
        path: Routes.splash,
        // Back is swallowed: no toast, no exit. The splash lasts about a
        // second, and during a replay the merchant is not at a root; the
        // screen they were on comes straight back after it.
        builder: (_, _) => const PopScope(canPop: false, child: SplashScreen()),
      ),
      // The signed-out roots: onboarding on first run, login after.
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const BackScope.root(child: OnboardingScreen()),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, _) => const BackScope.root(child: LoginScreen()),
      ),
      // Reached from login with `go`. Their parent is login, as their own
      // "back to login" links already say.
      GoRoute(
        path: Routes.signup,
        builder: (_, _) =>
            const BackScope(fallback: Routes.login, child: SignupScreen()),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => const BackScope(
          fallback: Routes.login,
          child: ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: Routes.passwordSent,
        // The address travels as `extra` so it never appears in a URL. A cold
        // deep link therefore arrives without it, and the screen omits the
        // address block rather than inventing one.
        builder: (_, state) => BackScope(
          fallback: Routes.login,
          child: PasswordSentScreen(
            email: state.extra is String ? state.extra as String : null,
          ),
        ),
      ),
      // `08b`, opened only by the e-mail's link (App Link or the web page's
      // intent). No token, nothing to reset: back to the request form. Keyed
      // by the token, so a second link opened over the screen checks afresh.
      GoRoute(
        path: Routes.resetPassword,
        redirect: (_, state) =>
            (state.uri.queryParameters['token'] ?? '').isEmpty ? Routes.forgotPassword : null,
        builder: (_, state) {
          final token = state.uri.queryParameters['token']!;
          return BackScope(
            fallback: Routes.login,
            child: ResetPasswordScreen(key: ValueKey(token), token: token),
          );
        },
      ),

      // The first-run tutorial. Outside the shell: it owns the whole screen
      // and has no bottom nav, because the merchant has nothing to navigate
      // to yet.
      //
      // Back through it. Steps that have created nothing go back one step:
      // T2 to the intro, T3 to T2, T6 to T5. The intro's first page, T4 and
      // T5 are roots, because the step below each is spent: T3 created a
      // product and T4 the one agent a merchant may have, so going back would
      // invite a duplicate or a 403. Leaving there is safe, since the furthest
      // step is persisted and a relaunch resumes it.
      GoRoute(
        path: Routes.tutorial,
        builder: (_, _) => const BackScope.root(child: TutorialIntroScreen()),
      ),
      GoRoute(
        path: Routes.tutorialMode,
        builder: (_, _) => const BackScope(
          fallback: Routes.tutorial,
          child: TutorialModeScreen(),
        ),
      ),
      GoRoute(
        path: Routes.tutorialProduct,
        builder: (_, _) => const BackScope(
          fallback: Routes.tutorialMode,
          child: TutorialProductScreen(),
        ),
      ),
      GoRoute(
        path: Routes.tutorialAgent,
        builder: (_, _) => const BackScope.root(child: TutorialAgentScreen()),
      ),
      GoRoute(
        path: Routes.tutorialConnect,
        builder: (_, _) =>
            const BackScope.root(child: TutorialConnectScreen()),
      ),
      GoRoute(
        path: Routes.tutorialReady,
        builder: (_, _) => const BackScope(
          fallback: Routes.tutorialConnect,
          child: TutorialReadyScreen(),
        ),
      ),

      // The five bottom-nav destinations of brief §16. They live in a
      // ShellRoute so the custom nav bar is built once and does not rebuild
      // or animate when the tab changes.
      ShellRoute(
        navigatorKey: _shellKey,
        // Home is the signed-in root. The other tabs are peers reached with
        // `go`, so none is ever below another, and back from any of them goes
        // home. Read on every build: the scope is a root exactly while Accueil
        // shows, and a tab change disarms a press armed on home.
        builder: (_, state, child) => BackScope(
          fallback: state.uri.path == Routes.home ? null : Routes.home,
          child: HomeShell(child: child),
        ),
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
            builder: (_, state) => InboxScreen(
              initialPageId: state.uri.queryParameters['pageId'],
            ),
          ),
          GoRoute(
            path: Routes.stock,
            builder: (_, _) => const StockOverviewScreen(),
          ),
          GoRoute(
            path: Routes.orders,
            builder: (context, _) =>
                PlaceholderScreen(title: L10n.of(context).navOrders),
          ),
        ],
      ),

      // Pushed over the shell: full screen, with the nav bar hidden. Opened
      // with `push` from a known origin, so back pops to it. The fallback is
      // the parent the URL implies, for a stack that has lost what was below.
      // `Produit` keeps its French placeholder title: no `l10n` key exists for
      // it, and inventing copy for a screen that does not exist would be copy
      // to approve twice.
      //
      // `10b`: pushed from the inbox, home's queue and a live notification.
      // Its parent is the inbox. A restored conversation loses the inbox's
      // page filter (the replay keeps only the path), which is accepted.
      GoRoute(
        path: Routes.conversation,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => BackScope(
          fallback: Routes.inbox,
          child: ConversationScreen(
            conversationId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: Routes.products,
        parentNavigatorKey: _rootKey,
        builder: (_, _) =>
            const BackScope(fallback: Routes.home, child: ProductsScreen()),
      ),
      GoRoute(
        path: Routes.agents,
        parentNavigatorKey: _rootKey,
        builder: (_, _) =>
            const BackScope(fallback: Routes.home, child: AgentsScreen()),
      ),
      GoRoute(
        path: Routes.pages,
        parentNavigatorKey: _rootKey,
        builder: (_, _) =>
            const BackScope(fallback: Routes.home, child: PagesScreen()),
      ),
      // Before /agents/:id, which would otherwise match `new`.
      GoRoute(
        path: Routes.agentNew,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const BackScope(
          fallback: Routes.agents,
          child: AgentPresetsScreen(),
        ),
      ),
      GoRoute(
        path: Routes.agentNewScratch,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const BackScope(
          fallback: Routes.agentNew,
          child: AgentNewScreen(),
        ),
      ),
      GoRoute(
        path: Routes.agent,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => BackScope(
          fallback: Routes.agents,
          child: AgentDetailsScreen(agentId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: Routes.agentTest,
        parentNavigatorKey: _rootKey,
        // The URL's own parent, the details page, like the edit form. The
        // chain goes details, then agents, then home, so it cannot loop.
        builder: (_, state) => BackScope(
          fallback: Routes.agentOf(state.pathParameters['id']!),
          child: AgentTestChatScreen(
            agentId: state.pathParameters['id']!,
            agent: state.extra is Agent ? state.extra as Agent : null,
          ),
        ),
      ),
      GoRoute(
        path: Routes.agentEdit,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => BackScope(
          fallback: Routes.agentOf(state.pathParameters['id']!),
          child: AgentEditScreen(agentId: state.pathParameters['id']!),
        ),
      ),
      // Declared before `/products/:id`, which would otherwise match it — see
      // [Routes.productNew].
      GoRoute(
        path: Routes.productNew,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const BackScope(
          fallback: Routes.products,
          child: AddProductScreen(),
        ),
      ),
      GoRoute(
        path: Routes.product,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => BackScope(
          fallback: Routes.products,
          child: ProductDetailScreen(productId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: Routes.order,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => BackScope(
          fallback: Routes.orders,
          child: PlaceholderScreen(
            title: L10n.of(context).navOrders,
            detail: state.pathParameters['id'],
          ),
        ),
      ),
      GoRoute(
        path: Routes.notifications,
        parentNavigatorKey: _rootKey,
        builder: (context, _) => BackScope(
          fallback: Routes.home,
          child: PlaceholderScreen(title: L10n.of(context).menuNotifications),
        ),
      ),
      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: _rootKey,
        builder: (_, _) =>
            const BackScope(fallback: Routes.home, child: SettingsScreen()),
      ),
    ],
  );

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
      if (location == Routes.resetPassword) {
        // A reset link, cold or while the app was in the background: kept
        // whole, because the token is in the query.
        _locationBeforeSplash = state.uri.toString();
      } else if (_session.isSignedIn
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
      if (resume != null && _restorableAuthPaths.contains(Uri.parse(resume).path)) {
        return resume;
      }
      return _session.onboardingSeen ? Routes.login : Routes.onboarding;
    }

    // Signed in. A tapped notification outranks wherever they happened to be —
    // it is a specific request, not a resumption.
    final pending = _pendingDeepLink;
    if (pending != null) {
      _pendingDeepLink = null;
      final resume = _locationBeforeSplash;
      _locationBeforeSplash = null;
      Log.i('opening deep link $pending', tag: 'push');
      // Tapped while a splash replay was running: give the merchant back the
      // screen they were on and push the notification's screen on top, so
      // back returns to it (and to a half-filled form's draft) instead of
      // falling back to the target's parent. A tab cannot be pushed, so it
      // replaces as before.
      if (resume != null &&
          resume != pending &&
          !_session.tutorialPending &&
          !_isShellLocation(pending)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(router.push(pending));
        });
        return resume;
      }
      return pending;
    }

    // A password-reset link is a specific request from outside the app, like
    // a notification: it opens even for a merchant already signed in (the
    // link may be for another account) and outranks the tutorial.
    if (location == Routes.resetPassword) return null;
    final resumeReset = _locationBeforeSplash;
    if (resumeReset != null && Uri.parse(resumeReset).path == Routes.resetPassword) {
      _locationBeforeSplash = null;
      return resumeReset;
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

    // A finished tutorial is never re-entered: not from a back fallback (T6's
    // back racing its own completion), a deep link or a replay.
    if (location.startsWith(Routes.tutorial)) return Routes.home;

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
  /// If the session is not ready — the app is cold-starting, the profile is
  /// still being fetched, or a splash replay is running — the destination is
  /// held in [_pendingDeepLink] and applied by the redirect once boot
  /// completes, instead of being dropped. A `go` during the replay would also
  /// overwrite the screen the replay is about to restore.
  ///
  /// With the app up, the screen is **pushed** over wherever the merchant is,
  /// so back returns there. Not when that screen is already on top (a second
  /// tap for the open conversation), not over another conversation (it
  /// replaces it, so threads do not pile up), and not for a tab, which can
  /// only be reached with `go`.
  void _listenForNotificationTaps() {
    _pushSubscription = _push.onMessageOpened.listen((message) {
      final route = message.route;
      if (route == null) return;
      if (!_session.isSignedIn || !_session.isBootComplete) {
        _pendingDeepLink = route;
        return;
      }
      if (_session.tutorialPending || _isShellLocation(route)) {
        router.go(route);
        return;
      }
      final current = router.routerDelegate.currentConfiguration;
      final top = current.matches.isEmpty ? null : current.last.matchedLocation;
      if (top == route) return;
      final conversationPrefix = Routes.conversationOf('');
      if (top != null &&
          top.startsWith(conversationPrefix) &&
          route.startsWith(conversationPrefix)) {
        unawaited(router.pushReplacement(route));
      } else {
        unawaited(router.push(route));
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
