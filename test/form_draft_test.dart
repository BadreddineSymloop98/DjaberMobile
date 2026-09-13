import 'package:djaber_mobile/app/router.dart';
import 'package:djaber_mobile/app/routes.dart';
import 'package:djaber_mobile/core/services/push_service.dart';
import 'package:djaber_mobile/core/storage/prefs_storage.dart';
import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/data/models/user.dart';
import 'package:djaber_mobile/data/repositories/catalogue_repository.dart';
import 'package:djaber_mobile/data/repositories/dashboard_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/products/add_product_screen.dart';
import 'package:djaber_mobile/presentation/screens/splash/splash_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:djaber_mobile/presentation/viewmodels/form_draft_store.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';
import 'support/fake_repositories.dart';

/// Leaving the app must not cost a merchant what they typed into a form.
///
/// On return the splash replays and the screen underneath is built again from
/// scratch. `FormDraftStore` carries the values across; the router brings a
/// signed-out merchant back to the form they were on.
void main() {
  const user = User(id: 'u-1', email: 'z@djaber.test', firstName: 'Zakaria');

  /// Lets the splash run its course. `pumpAndSettle` alone stops once no frame
  /// is pending, which is before the splash's minimum-display timer fires.
  Future<void> playSplash(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(SplashScreen.minimumDisplay);
    await tester.pumpAndSettle();
  }

  String textAt(WidgetTester tester, int index) => tester
      .widget<TextField>(find.byType(TextField).at(index))
      .controller!
      .text;

  group('auth forms, through the real router', () {
    late SessionViewModel session;
    late PrefsStorage prefs;
    late FormDraftStore drafts;
    late AppRouter router;

    setUp(() async {
      session = await sessionForTest(
        token: null,
        prefsValues: {'onboarding_seen': true},
      );
      prefs = await prefsForTest();
      drafts = FormDraftStore(session: session);
      router = AppRouter(session: session, push: NoopPushService());
    });

    tearDown(() {
      router.dispose();
      drafts.dispose();
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
      await playSplash(tester);
    }

    Future<void> go(WidgetTester tester, String route) async {
      router.router.go(route);
      await tester.pumpAndSettle();
    }

    /// What leaving the app does: the boot gate drops on pause, the splash
    /// plays on return, and then hands back.
    Future<void> leaveAndReturn(WidgetTester tester) async {
      session.resetBoot();
      await playSplash(tester);
    }

    testWidgets('sign-up comes back as sign-up, with all but the password',
        (tester) async {
      await pumpApp(tester);
      expect(location(), Routes.login);
      await go(tester, Routes.signup);

      const typed = ['Sara', 'Benali', 'sara@djaber.test', 'motdepasse1'];
      for (var i = 0; i < typed.length; i++) {
        await tester.enterText(find.byType(TextField).at(i), typed[i]);
      }
      await tester.pumpAndSettle();

      await leaveAndReturn(tester);

      expect(location(), Routes.signup, reason: 'used to come back as login');
      expect(textAt(tester, 0), 'Sara');
      expect(textAt(tester, 1), 'Benali');
      expect(textAt(tester, 2), 'sara@djaber.test');
      expect(textAt(tester, 3), isEmpty, reason: 'a password is never kept');
    });

    testWidgets('login keeps the address, never the password', (tester) async {
      await pumpApp(tester);

      await tester.enterText(find.byType(TextField).at(0), 'sara@djaber.test');
      await tester.enterText(find.byType(TextField).at(1), 'motdepasse1');
      await tester.pumpAndSettle();

      await leaveAndReturn(tester);

      expect(location(), Routes.login);
      expect(textAt(tester, 0), 'sara@djaber.test');
      expect(textAt(tester, 1), isEmpty);
    });

    testWidgets('forgot-password comes back with its address', (tester) async {
      await pumpApp(tester);
      await go(tester, Routes.forgotPassword);

      await tester.enterText(find.byType(TextField).first, 'sara@djaber.test');
      await tester.pumpAndSettle();

      await leaveAndReturn(tester);

      expect(location(), Routes.forgotPassword);
      expect(textAt(tester, 0), 'sara@djaber.test');
    });

    testWidgets('a form walked away from opens empty next time',
        (tester) async {
      await pumpApp(tester);
      await go(tester, Routes.signup);

      await tester.enterText(find.byType(TextField).first, 'Sara');
      await tester.pumpAndSettle();

      await go(tester, Routes.login);
      await go(tester, Routes.signup);

      expect(textAt(tester, 0), isEmpty);
    });
  });

  group('the add-product form', () {
    late SessionViewModel session;
    late FormDraftStore drafts;

    setUp(() async {
      session = await sessionForTest();
      drafts = FormDraftStore(session: session);
    });

    tearDown(() {
      drafts.dispose();
      session.dispose();
    });

    /// Hosts the form behind a switch, so a test can tear it down and bring it
    /// back the way a navigation does.
    Future<ValueNotifier<bool>> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(411, 914);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final shown = ValueNotifier(true);
      addTearDown(shown.dispose);
      await tester.pumpWidget(
        authHost(
          ValueListenableBuilder<bool>(
            valueListenable: shown,
            builder: (_, visible, _) =>
                visible ? const AddProductScreen() : const SizedBox.shrink(),
          ),
          session,
          extra: [
            Provider<ProductRepository>(create: (_) => FakeProductRepository()),
            Provider<CatalogueRepository>(
              create: (_) => FakeCatalogueRepository(),
            ),
            Provider<DashboardRepository>(
              create: (_) => FakeDashboardRepository(),
            ),
            Provider<FormDraftStore>.value(value: drafts),
          ],
        ),
      );
      await tester.pumpAndSettle();
      return shown;
    }

    Future<void> rebuild(WidgetTester tester, ValueNotifier<bool> shown) async {
      shown.value = false;
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      shown.value = true;
      await tester.pumpAndSettle();
    }

    testWidgets('keeps all seven values when the splash rebuilds it',
        (tester) async {
      // The boot gate is down, as it is from the moment the app is left.
      expect(session.isBootComplete, isFalse);
      final shown = await pump(tester);

      const typed = ['Sac cuir', 'SAC-01', 'Cuir', '1000', '1500', '12', '3'];
      for (var i = 0; i < typed.length; i++) {
        await tester.enterText(find.byType(TextField).at(i), typed[i]);
      }
      await tester.pumpAndSettle();

      await rebuild(tester, shown);

      for (var i = 0; i < typed.length; i++) {
        expect(textAt(tester, i), typed[i], reason: 'field $i was wiped');
      }
    });

    testWidgets('opens empty after the merchant left it themselves',
        (tester) async {
      session.debugSetUser(user); // boot complete: an ordinary navigation
      final shown = await pump(tester);

      await tester.enterText(find.byType(TextField).first, 'Sac cuir');
      await tester.pumpAndSettle();

      await rebuild(tester, shown);

      expect(textAt(tester, 0), isEmpty);
    });
  });

  test('drafts do not cross a change of account', () async {
    final session = await sessionForTest();
    final drafts = FormDraftStore(session: session);
    addTearDown(() {
      drafts.dispose();
      session.dispose();
    });

    session.debugSetUser(user);
    drafts.write('addProduct', {'name': 'Sac cuir'});

    await session.signOut();

    expect(drafts.read('addProduct'), isEmpty);
  });
}
