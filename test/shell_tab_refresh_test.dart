import 'dart:async';

import 'package:djaber_mobile/app/route_observer.dart';
import 'package:djaber_mobile/presentation/screens/home/home_shell.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/auth_host.dart';

/// A tab refreshing when a screen pushed over the shell closes.
///
/// The bug this pins: `OrdersScreen` subscribed to [appRouteObserver] itself
/// and that **silently did nothing**. The tabs live on the shell's navigator,
/// while New order is pushed on the root one, so the root observer reports the
/// route underneath as the shell's page — never the tab inside it. A new order
/// therefore did not appear on the list until it was pulled down.
///
/// The shell is on the root navigator, so it does get the callback, and it
/// relays it through [shellReturns].
void main() {
  late SessionViewModel session;

  setUp(() async => session = await sessionForTest());
  tearDown(() => session.dispose());

  testWidgets('the shell relays a pop from the root navigator to the tab '
      'showing underneath', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var returns = 0;
    void count() => returns++;
    shellReturns.addListener(count);
    addTearDown(() => shellReturns.removeListener(count));

    final shellKey = GlobalKey<NavigatorState>();
    final router = GoRouter(
      initialLocation: '/home',
      observers: [appRouteObserver],
      routes: [
        // Mirrors `router.dart`: a ShellRoute with its own navigator, and the
        // pushed screen declared OUTSIDE it so it lands on the root.
        ShellRoute(
          navigatorKey: shellKey,
          builder: (_, _, child) => HomeShell(child: child),
          routes: [
            GoRoute(path: '/home', builder: (_, _) => const Text('tab')),
          ],
        ),
        GoRoute(path: '/pushed', builder: (_, _) => const Text('pushed')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(routerHost(router, session));
    await tester.pumpAndSettle();
    expect(find.text('tab'), findsOneWidget);
    expect(returns, 0);

    unawaited(router.push('/pushed'));
    await tester.pumpAndSettle();
    expect(find.text('pushed'), findsOneWidget);
    expect(returns, 0, reason: 'nothing has come back yet');

    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('tab'), findsOneWidget);
    expect(returns, 1, reason: 'the tab underneath is stale and must reload');
  });
}
