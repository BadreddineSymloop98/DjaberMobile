import 'dart:async';

import 'package:djaber_mobile/app/route_observer.dart';
import 'package:djaber_mobile/app/router.dart';
import 'package:djaber_mobile/app/routes.dart';
import 'package:djaber_mobile/core/services/push_service.dart';
import 'package:djaber_mobile/core/storage/prefs_storage.dart';
import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/data/models/user.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/catalogue_repository.dart';
import 'package:djaber_mobile/data/repositories/dashboard_repository.dart';
import 'package:djaber_mobile/data/repositories/notification_repository.dart';
import 'package:djaber_mobile/data/repositories/page_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/splash/splash_replay_overlay.dart';
import 'package:djaber_mobile/presentation/screens/splash/splash_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:djaber_mobile/presentation/viewmodels/form_draft_store.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/stock_mode_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';
import 'support/fake_repositories.dart';

/// Leaving the app and coming back must not cost the merchant anything they
/// typed — on a page, in a bottom sheet, anywhere. The splash still plays on
/// the way back; it just must not take the screens down to do it.
void main() {
  const user = User(id: 'u-1', email: 'z@djaber.test', firstName: 'Zakaria');

  late SessionViewModel session;
  late PrefsStorage prefs;
  late StockModeViewModel stockMode;
  late FormDraftStore drafts;
  late AppRouter router;

  setUp(() async {
    session = await sessionForTest(prefsValues: {'onboarding_seen': true});
    prefs = await prefsForTest();
    stockMode = StockModeViewModel(prefs: prefs);
    drafts = FormDraftStore(session: session);
    router = AppRouter(session: session, push: NoopPushService());
    session.debugSetUser(user);
  });

  tearDown(() {
    router.dispose();
    drafts.dispose();
    session.dispose();
  });

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
          Provider<ProductRepository>(create: (_) => FakeProductRepository()),
          Provider<CatalogueRepository>(create: (_) => FakeCatalogueRepository()),
          Provider<DashboardRepository>(create: (_) => FakeDashboardRepository()),
          Provider<NotificationRepository>(create: (_) => FakeNotificationRepository()),
          Provider<PageRepository>(create: (_) => FakePageRepository()),
          Provider<AgentRepository>(create: (_) => FakeAgentRepository()),
          Provider<FormDraftStore>.value(value: drafts),
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
          // As `app.dart` builds it.
          builder: (context, child) => ScreenInitializer(
            child: SplashReplayOverlay(child: child ?? const SizedBox.shrink()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The app is left, then opened again: the splash plays for its full time.
  Future<void> leaveAndReturn(WidgetTester tester) async {
    session.replaySplash();
    await tester.pump();
    await tester.pump(SplashScreen.minimumDisplay);
    await tester.pumpAndSettle();
  }

  const sheetField = Key('sheet-field');

  /// A sheet with a field, opened the way every sheet in the app is: pageless,
  /// over the screen, on the root navigator.
  void openSheet() {
    final context = router.router.routerDelegate.navigatorKey.currentContext!;
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const Padding(
          padding: EdgeInsets.all(16),
          child: TextField(key: sheetField),
        ),
      ),
    );
  }

  testWidgets('an open bottom sheet and what was typed in it come back', (tester) async {
    await pumpApp(tester);
    router.router.go(Routes.products);
    await tester.pumpAndSettle();
    openSheet();
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(sheetField), 'Livraison à 18h');
    await tester.pumpAndSettle();

    await leaveAndReturn(tester);

    expect(find.byKey(sheetField), findsOneWidget, reason: 'the sheet was dropped');
    expect(find.text('Livraison à 18h'), findsOneWidget);
  });

  testWidgets('the stack under the screen survives too, so back still goes where it went',
      (tester) async {
    await pumpApp(tester);
    router.router.go(Routes.products);
    await tester.pumpAndSettle();
    unawaited(router.router.push(Routes.productNew));
    await tester.pumpAndSettle();

    await leaveAndReturn(tester);

    final matches = router.router.routerDelegate.currentConfiguration.matches;
    expect(matches.map((m) => m.matchedLocation), containsAllInOrder([Routes.products, Routes.productNew]));
  });

  testWidgets('the splash still plays on the way back', (tester) async {
    await pumpApp(tester);
    router.router.go(Routes.products);
    await tester.pumpAndSettle();

    session.replaySplash();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(SplashScreen.minimumDisplay);
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets('back does nothing while the splash plays, as it did on the route',
      (tester) async {
    await pumpApp(tester);
    router.router.go(Routes.products);
    await tester.pumpAndSettle();
    unawaited(router.router.push(Routes.productNew));
    await tester.pumpAndSettle();

    session.replaySplash();
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump(SplashScreen.minimumDisplay);
    await tester.pumpAndSettle();

    expect(router.router.routerDelegate.currentConfiguration.last.matchedLocation, Routes.productNew);
  });

  testWidgets('the tab on screen is told to refresh once the splash is over', (tester) async {
    await pumpApp(tester);
    var returns = 0;
    void count() => returns++;
    shellReturns.addListener(count);
    addTearDown(() => shellReturns.removeListener(count));

    session.replaySplash();
    await tester.pump();
    expect(returns, 0, reason: 'not while the logo is still up');

    await tester.pump(SplashScreen.minimumDisplay);
    await tester.pumpAndSettle();
    expect(returns, 1);
  });
}
