import 'package:djaber_mobile/app/router.dart';
import 'package:djaber_mobile/app/routes.dart';
import 'package:djaber_mobile/core/services/push_service.dart';
import 'package:djaber_mobile/core/storage/prefs_storage.dart';
import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/data/models/stock_mode.dart';
import 'package:djaber_mobile/data/models/user.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/dashboard_repository.dart';
import 'package:djaber_mobile/data/repositories/page_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/tutorial/tutorial_intro_screen.dart';
import 'package:djaber_mobile/presentation/screens/tutorial/tutorial_mode_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/stock_mode_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/tutorial_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';
import 'support/fake_repositories.dart';

/// Where a newly created account is sent, and what gets it out again.
///
/// The rule lives in the router's redirect, not on any screen, so these run
/// against the real router rather than a screen in isolation.
void main() {
  const user = User(
    id: 'u-1',
    email: 'zakaria@djaber.ai',
    firstName: 'Zakaria',
    lastName: 'Amrani',
  );

  late SessionViewModel session;
  late PrefsStorage prefs;
  late StockModeViewModel stockMode;
  late ProductRepository products;
  late PageRepository pages;
  late AgentRepository agents;
  late AppRouter router;

  Future<void> boot({bool tutorialPending = false}) async {
    session = await sessionForTest(
      prefsValues: {
        'onboarding_seen': true,
        if (tutorialPending) 'tutorial_pending': true,
      },
    );
    prefs = await prefsForTest();
    stockMode = StockModeViewModel(prefs: prefs);
    products = ProductRepository(api: apiForTest());
    pages = PageRepository(api: apiForTest());
    agents = AgentRepository(api: apiForTest());
    router = AppRouter(session: session, push: NoopPushService());
  }

  tearDown(() {
    router.dispose();
    session.dispose();
  });

  String location() =>
      router.router.routerDelegate.currentConfiguration.uri.path;

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const locale = Locale('fr');
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SessionViewModel>.value(value: session),
          Provider<PrefsStorage>.value(value: prefs),
          ChangeNotifierProvider<StockModeViewModel>.value(value: stockMode),
          Provider<ProductRepository>.value(value: products),
          Provider<PageRepository>.value(value: pages),
          Provider<AgentRepository>.value(value: agents),
          // Home is one of the destinations these redirects land on, and it
          // reads the dashboard. Answers from memory — this suite is about
          // where a navigation goes, not about what home shows once there.
          Provider<DashboardRepository>(
            create: (_) => FakeDashboardRepository(),
          ),
          ChangeNotifierProvider<TutorialViewModel>(
            create: (_) => TutorialViewModel(),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router.router,
          locale: locale,
          theme: AppTheme.build(locale),
          supportedLocales: AppLanguage.values.map((l) => l.locale),
          localizationsDelegates: const [
            L10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => ScreenInitializer(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  test('the tutorial is not a public route', () async {
    await boot(); // so the shared tearDown has something to dispose
    // It creates real records against a session; reaching it signed out would
    // be meaningless.
    expect(Routes.publicPaths.contains(Routes.tutorial), isFalse);
    expect(Routes.publicPaths.contains(Routes.tutorialMode), isFalse);
  });

  testWidgets('a merchant who owes the tutorial lands on it, not home',
      (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    await pumpApp(tester);

    expect(location(), Routes.tutorial);
    expect(find.byType(TutorialIntroScreen), findsOneWidget);
  });

  testWidgets('the tutorial cannot be stepped around with a go(home)',
      (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    await pumpApp(tester);

    // The redirect applies to every route, not only the public ones — a
    // `go` to a private path must not slip past it.
    router.router.go(Routes.home);
    await tester.pumpAndSettle();
    expect(location(), Routes.tutorial);
  });

  testWidgets('a merchant who does not owe it goes straight to home',
      (tester) async {
    await boot();
    session.debugSetUser(user);
    await pumpApp(tester);

    expect(location(), Routes.home);
  });

  testWidgets('back does not close the app from a step', (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    await pumpApp(tester);

    router.router.go(Routes.tutorialMode);
    await tester.pumpAndSettle();

    // Steps are reached with `go`, which replaces rather than pushes, so
    // there is nothing to pop and the pop would reach Android and close the
    // app — losing whatever the merchant had typed. On `T3` that is six
    // fields. Swallowed instead.
    final popped = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(popped, isTrue, reason: 'the route must consume the pop');
    expect(location(), Routes.tutorialMode);
  });

  testWidgets('back walks the intro pages instead of closing the app',
      (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    await pumpApp(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    // Forward to the second page...
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text(l10n.tutorialStockTitle), findsOneWidget);

    // ...then back, which should agree with the swipe rather than exit.
    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();

    expect(find.text(l10n.tutorialWelcomeTitle), findsOneWidget);
    expect(location(), Routes.tutorial);
  });

  testWidgets('Passer skips the intro, not the tutorial', (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    await pumpApp(tester);
    expect(location(), Routes.tutorial);

    final l10n = await L10n.delegate.load(const Locale('fr'));
    await tester.tap(find.text(l10n.commonSkip));
    await tester.pumpAndSettle();

    // Straight to the first step — the intro only explains, so skipping it
    // costs nothing. The setup steps themselves stay mandatory...
    expect(location(), Routes.tutorialMode);
    // ...and the hold is still armed, so home is still out of reach.
    expect(session.tutorialPending, isTrue);
  });

  testWidgets('Commencer hands over to the first step, flag still pending',
      (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    await pumpApp(tester);

    final l10n = await L10n.delegate.load(const Locale('fr'));
    await tester.tap(find.byType(FilledButton)); // T1a -> T1b
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton)); // T1b -> T1c
    await tester.pumpAndSettle();
    expect(find.text(l10n.commonStart), findsOneWidget);

    await tester.tap(find.byType(FilledButton)); // T1c -> T2
    await tester.pumpAndSettle();

    expect(location(), Routes.tutorialMode);
    // Being told what the tutorial is does not count as having done it.
    expect(session.tutorialPending, isTrue);
  });

  testWidgets('T2 Continuer saves the mode and moves to the product step',
      (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    await pumpApp(tester);

    router.router.go(Routes.tutorialMode);
    await tester.pumpAndSettle();
    expect(find.byType(TutorialModeScreen), findsOneWidget);

    final l10n = await L10n.delegate.load(const Locale('fr'));
    await tester.tap(find.text(l10n.stockModeAdvanced));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.commonContinue));
    await tester.pumpAndSettle();

    expect(location(), Routes.tutorialProduct);
    // Persisted, not just held in the widget: the next step, and the app
    // after it, read this back off the device.
    expect(prefs.stockMode, StockMode.advanced);
    expect(session.tutorialPending, isTrue);
  });

  testWidgets('a step offers no way out either', (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    await pumpApp(tester);

    router.router.go(Routes.tutorialMode);
    await tester.pumpAndSettle();

    // No `Passer` on any step, and the merchant stays where they are.
    final l10n = await L10n.delegate.load(const Locale('fr'));
    expect(find.text(l10n.commonSkip), findsNothing);
    expect(location(), Routes.tutorialMode);
    expect(session.tutorialPending, isTrue);
  });

  testWidgets('T5 can be deferred, and that is the one exception',
      (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    await pumpApp(tester);

    router.router.go(Routes.tutorialConnect);
    await tester.pumpAndSettle();

    final l10n = await L10n.delegate.load(const Locale('fr'));
    await tester.tap(find.text(l10n.connectLater));
    await tester.pumpAndSettle();

    // Leaves the step behind...
    expect(location(), Routes.tutorialReady);
    // ...recorded, not silently dropped: home's Démarrer checklist shows the
    // step as still outstanding (brief §21.10).
    expect(prefs.pageConnectionDeferred, isTrue);

    // The tutorial is closed by `T6`, not by the deferral itself.
    await tester.tap(find.text(l10n.tutorialReadySubmit));
    await tester.pumpAndSettle();
    expect(location(), Routes.home);
    expect(session.tutorialPending, isFalse);
  });

  testWidgets('deferring still ends on T6, but does not claim the agent is live',
      (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    await pumpApp(tester);

    router.router.go(Routes.tutorialConnect);
    await tester.pumpAndSettle();

    final l10n = await L10n.delegate.load(const Locale('fr'));
    await tester.tap(find.text(l10n.connectLater));
    await tester.pumpAndSettle();

    expect(location(), Routes.tutorialReady);
    // "Votre agent est en ligne" would be false with no Page connected.
    expect(find.text(l10n.tutorialReadyTitle), findsNothing);
    expect(find.text(l10n.tutorialReadyTitlePending), findsOneWidget);
    // And the step it names stays on the list, unticked.
    expect(find.text(l10n.tutorialStepPage), findsOneWidget);
  });

  testWidgets('T6 is the exit for a completed run — flag cleared, app opened',
      (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    await pumpApp(tester);

    router.router.go(Routes.tutorialReady);
    await tester.pumpAndSettle();

    final l10n = await L10n.delegate.load(const Locale('fr'));
    await tester.tap(find.text(l10n.tutorialReadySubmit));
    await tester.pumpAndSettle();

    expect(location(), Routes.home);
    // Cleared, not merely navigated away from: it must not come back on the
    // next launch.
    expect(session.tutorialPending, isFalse);
  });

  testWidgets('completeTutorial releases the hold but does not navigate',
      (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    await pumpApp(tester);
    expect(location(), Routes.tutorial);

    await session.completeTutorial();
    await tester.pumpAndSettle();

    // Still on the tutorial: `/tutorial` is not a public path, so once the
    // flag clears the redirect has no reason to move anyone. Clearing the
    // flag *releases* the merchant, it does not transport them — the call
    // site navigates, the way every sign-out call site pushes its own route.
    // `T6 — Prêt` will need its own `go` for the same reason.
    expect(location(), Routes.tutorial);
    expect(session.tutorialPending, isFalse);

    // And the hold really is gone: a destination that was bounced back to the
    // tutorial a moment ago now sticks.
    router.router.go(Routes.home);
    await tester.pumpAndSettle();
    expect(location(), Routes.home);
  });

testWidgets('a returning merchant re-enters at the step they reached, not '
      'at the intro', (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    // They got as far as connecting a page last time.
    await session.rememberTutorialStep(Routes.tutorialConnect);
    await pumpApp(tester);

    // The redirect used to answer `Routes.tutorial` here, which walked them
    // back into T4 — a step that cannot be repeated, because one agent per
    // user is enforced. There was no `Passer`, no sign-out and no way to
    // reach T5's deferral, so the only exits were clearing app data or
    // signing up again.
    expect(location(), Routes.tutorialConnect);
  });

  testWidgets('and a deep link still cannot step around it — it lands on the '
      'remembered step', (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    await session.rememberTutorialStep(Routes.tutorialAgent);
    await pumpApp(tester);

    router.router.go(Routes.home);
    await tester.pumpAndSettle();

    expect(location(), Routes.tutorialAgent);
  });

  testWidgets('signing out drops the flag with the session', (tester) async {
    await boot(tutorialPending: true);
    session.debugSetUser(user);
    await pumpApp(tester);

    await session.signOut();
    await tester.pumpAndSettle();

    // Otherwise the next merchant to sign in on this handset inherits
    // someone else's half-finished tutorial.
    expect(session.tutorialPending, isFalse);
    expect(location(), Routes.login);
  });
}
