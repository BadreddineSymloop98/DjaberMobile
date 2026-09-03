import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/services/push_service.dart';
import '../core/utils/logger.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/viewmodels/session_view_model.dart';
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
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, _) => const PlaceholderScreen(title: 'Connexion'),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (_, _) => const PlaceholderScreen(title: 'Créer un compte'),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => const PlaceholderScreen(
          title: 'Mot de passe oublié',
          // The web ships this page but it calls no endpoint, and the backend
          // has no reset route. Needs building on both sides.
          detail: 'No backend endpoint exists yet',
        ),
      ),

      // The five bottom-nav destinations of brief §16. They live in a
      // ShellRoute so the custom nav bar is built once and does not rebuild
      // or animate when the tab changes.
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, _, child) => PlaceholderShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (_, _) => const PlaceholderScreen(title: 'Accueil'),
          ),
          GoRoute(
            path: Routes.queue,
            builder: (_, _) => const PlaceholderScreen(title: 'File'),
          ),
          GoRoute(
            path: Routes.inbox,
            builder: (_, _) => const PlaceholderScreen(title: 'Boîte'),
          ),
          GoRoute(
            path: Routes.stock,
            builder: (_, _) => const PlaceholderScreen(title: 'Stock'),
          ),
          GoRoute(
            path: Routes.orders,
            builder: (_, _) => const PlaceholderScreen(title: 'Commandes'),
          ),
        ],
      ),

      // Pushed over the shell — full screen, with the nav bar hidden.
      GoRoute(
        path: Routes.conversation,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => PlaceholderScreen(
          title: 'Conversation',
          detail: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: Routes.product,
        parentNavigatorKey: _rootKey,
        builder: (_, state) => PlaceholderScreen(
          title: 'Produit',
          detail: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: Routes.notifications,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const PlaceholderScreen(title: 'Notifications'),
      ),
      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const PlaceholderScreen(title: 'Réglages'),
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
      return location == Routes.splash ? null : Routes.splash;
    }

    if (status == AuthStatus.signedOut) {
      if (isPublic && location != Routes.splash) return null;
      return _session.onboardingSeen ? Routes.login : Routes.onboarding;
    }

    // Signed in.
    final pending = _pendingDeepLink;
    if (pending != null) {
      _pendingDeepLink = null;
      Log.i('opening deep link $pending', tag: 'push');
      return pending;
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
