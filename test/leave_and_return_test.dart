import 'dart:async';

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

/// Leaving the app and coming back: the splash replays, and what was on screen
/// has to survive it.
void main() {
  const user = User(id: 'u-1', email: 'z@djaber.test', firstName: 'Zakaria');

  group('holding the splash replay', () {
    test('a held replay leaves the boot gate up; releasing restores it',
        () async {
      final session = await sessionForTest();
      addTearDown(session.dispose);
      session.debugSetUser(user);

      // The Facebook window and the photo picker hold it while they are open.
      session.holdSplashReplay();
      session.resetBoot();
      expect(session.isBootComplete, isTrue, reason: 'replay was held');

      session.releaseSplashReplay();
      session.resetBoot();
      expect(session.isBootComplete, isFalse);
    });

    test('holds nest, and an extra release does not go negative', () async {
      final session = await sessionForTest();
      addTearDown(session.dispose);
      session.debugSetUser(user);

      session
        ..holdSplashReplay()
        ..holdSplashReplay()
        ..releaseSplashReplay();
      session.resetBoot();
      expect(session.isBootComplete, isTrue, reason: 'one hold remains');

      session
        ..releaseSplashReplay()
        ..releaseSplashReplay();
      session.holdSplashReplay();
      session.resetBoot();
      expect(session.isBootComplete, isTrue);
    });
  });

  group('add product, through the real router', () {
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

    String topLocation() =>
        router.router.routerDelegate.currentConfiguration.last.matchedLocation;

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
            Provider<CatalogueRepository>(
              create: (_) => FakeCatalogueRepository(),
            ),
            Provider<DashboardRepository>(
              create: (_) => FakeDashboardRepository(),
            ),
            Provider<NotificationRepository>(
              create: (_) => FakeNotificationRepository(),
            ),
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
            builder: (context, child) => ScreenInitializer(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('comes back as add product, with its values, not the list',
        (tester) async {
      await pumpApp(tester);
      router.router.go(Routes.products);
      await tester.pumpAndSettle();
      // Opened the way the list opens it: pushed on top.
      unawaited(router.router.push(Routes.productNew));
      await tester.pumpAndSettle();
      expect(topLocation(), Routes.productNew);

      await tester.enterText(find.byType(TextField).at(0), 'Sac cuir');
      await tester.enterText(find.byType(TextField).at(1), 'SAC-01');
      await tester.pumpAndSettle();

      // Leaving the app, then the splash on the way back.
      session.resetBoot();
      await tester.pump();
      await tester.pump(SplashScreen.minimumDisplay);
      await tester.pumpAndSettle();

      expect(topLocation(), Routes.productNew, reason: 'used to be /products');
      final fields = find.byType(TextField);
      expect(
        tester.widget<TextField>(fields.at(0)).controller!.text,
        'Sac cuir',
      );
      expect(tester.widget<TextField>(fields.at(1)).controller!.text, 'SAC-01');
    });
  });
}
