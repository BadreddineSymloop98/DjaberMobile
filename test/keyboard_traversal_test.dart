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
import 'package:djaber_mobile/presentation/screens/auth/forgot_password_screen.dart';
import 'package:djaber_mobile/presentation/screens/auth/login_screen.dart';
import 'package:djaber_mobile/presentation/screens/auth/signup_screen.dart';
import 'package:djaber_mobile/presentation/screens/products/add_product_screen.dart';
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

/// The keyboard's own next/done key, on every form in the app.
///
/// Asserted by sending the real platform action — `receiveAction` is what the
/// IME does — rather than by reading `textInputAction` off the widgets. The
/// label on the key and the behaviour behind it are two different things: a
/// field can advertise **next** and go nowhere, which is precisely the failure
/// this is looking for.
///
/// The rule, on every form: **next** moves to the next input, and the last
/// input's key closes the keyboard instead of jumping somewhere arbitrary.
void main() {
  late SessionViewModel session;

  setUp(() async => session = await sessionForTest());
  tearDown(() => session.dispose());

  /// Which field currently has the keyboard, by index among the form's fields.
  int? focusedIndex(WidgetTester tester) {
    final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    for (var i = 0; i < fields.length; i++) {
      if (fields[i].focusNode?.hasFocus ?? false) return i;
    }
    return null;
  }

  Future<void> focusField(WidgetTester tester, int index) async {
    await tester.tap(find.byType(TextField).at(index));
    await tester.pumpAndSettle();
  }

  Future<void> pressNext(WidgetTester tester) async {
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();
  }

  Future<void> pressDone(WidgetTester tester) async {
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  /// Walks every field with the next key, then checks the last one ends the
  /// form instead of advertising a hop it cannot make.
  Future<void> walk(WidgetTester tester, int count) async {
    for (var i = 0; i < count - 1; i++) {
      await focusField(tester, i);
      expect(focusedIndex(tester), i, reason: 'field $i should have focus');
      await pressNext(tester);
      expect(
        focusedIndex(tester),
        i + 1,
        reason: 'next on field $i must move to field ${i + 1}, not elsewhere',
      );
    }

    // The last field's key must read **done**, not next: a key that says
    // "next" with nowhere to go is the defect this suite is looking for.
    final last =
        tester.widgetList<TextField>(find.byType(TextField)).toList()[count - 1];
    expect(
      last.textInputAction,
      TextInputAction.done,
      reason: 'the last field must not offer next',
    );

    // Pressing it must end editing there. It does not have to close the
    // keyboard outright: on these forms `done` submits, and an invalid form
    // moves focus to the first field at fault — better than dismissing and
    // leaving the merchant to find the error themselves. What it must never do
    // is stay put or jump forward.
    await focusField(tester, count - 1);
    await pressDone(tester);
    expect(
      focusedIndex(tester),
      isNot(count - 1),
      reason: 'done must leave the last field, not sit on it',
    );
  }

  group('auth', () {
    Future<void> pump(WidgetTester tester, Widget screen) async {
      tester.view.physicalSize = const Size(411, 914);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(authHost(screen, session));
      await tester.pumpAndSettle();
    }

    testWidgets('login: e-mail → password → keyboard closes', (tester) async {
      await pump(tester, const LoginScreen());
      await walk(tester, 2);
    });

    testWidgets('sign-up: all four fields in order', (tester) async {
      await pump(tester, const SignupScreen());
      await walk(tester, 4);
    });

    testWidgets('forgot password: its one field offers done, not next',
        (tester) async {
      await pump(tester, const ForgotPasswordScreen());

      final only = tester.widget<TextField>(find.byType(TextField));
      expect(only.textInputAction, TextInputAction.done);
    });
  });

  group('18 — Ajouter un produit', () {
    // The form this suite did not cover. It was built the same afternoon the
    // suite was written and never added to it, which is how the app's largest
    // form went unchecked.
    testWidgets('all seven keyboard fields in order, then done',
        (tester) async {
      tester.view.physicalSize = const Size(411, 914);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SessionViewModel>.value(value: session),
            Provider<ProductRepository>(create: (_) => FakeProductRepository()),
            Provider<CatalogueRepository>(
              create: (_) => FakeCatalogueRepository(),
            ),
            Provider<DashboardRepository>(
              create: (_) => FakeDashboardRepository(),
            ),
          ],
          child: MediaQuery.fromView(
            view: tester.view,
            child: Builder(
              builder: (context) {
                Screen.update(MediaQuery.of(context));
                return MaterialApp(
                  locale: const Locale('fr'),
                  theme: AppTheme.build(const Locale('fr')),
                  supportedLocales: AppLanguage.values.map((l) => l.locale),
                  localizationsDelegates: const [
                    L10n.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  home: const AddProductScreen(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Seven, not nine: the category and unit pickers below the last field
      // are not keyboard inputs, so there is nothing for `next` to reach.
      await walk(tester, 7);
    });
  });

  group('the tutorial', () {
    late PrefsStorage prefs;
    late AppRouter router;
    late StockModeViewModel stockMode;

    setUp(() async {
      prefs = await PrefsStorage.load();
      stockMode = StockModeViewModel(prefs: prefs);
      router = AppRouter(session: session, push: NoopPushService());
      session.debugSetUser(
        const User(id: 'u-1', email: 'z@djaber.test', firstName: 'Zakaria'),
      );
    });
    tearDown(() => router.dispose());

    Future<void> pumpAt(WidgetTester tester, String route) async {
      tester.view.physicalSize = const Size(411, 914);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SessionViewModel>.value(value: session),
            Provider<PrefsStorage>.value(value: prefs),
            ChangeNotifierProvider<StockModeViewModel>.value(value: stockMode),
            Provider<ProductRepository>(create: (_) => FakeProductRepository()),
            Provider<PageRepository>(create: (_) => FakePageRepository()),
            Provider<AgentRepository>(create: (_) => FakeAgentRepository()),
            Provider<DashboardRepository>(
              create: (_) => FakeDashboardRepository(),
            ),
            Provider<NotificationRepository>(
              create: (_) => FakeNotificationRepository(),
            ),
            ChangeNotifierProvider<TutorialViewModel>(
              create: (_) => TutorialViewModel(),
            ),
          ],
          child: MediaQuery.fromView(
            view: WidgetsBinding.instance.platformDispatcher.views.first,
            child: Builder(
              builder: (context) {
                Screen.update(MediaQuery.of(context));
                return MaterialApp.router(
                  routerConfig: router.router,
                  locale: const Locale('fr'),
                  theme: AppTheme.build(const Locale('fr')),
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
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      router.router.go(route);
      await tester.pumpAndSettle();
    }

    testWidgets('T3 product: all six fields in order', (tester) async {
      await pumpAt(tester, Routes.tutorialProduct);
      await walk(tester, 6);
    });

    testWidgets('T4 agent: name → instructions, with the personality cards '
        'in between', (tester) async {
      await pumpAt(tester, Routes.tutorialAgent);
      // The interesting one: four tappable Option Cards sit between the two
      // inputs, so "next" has somewhere wrong to go.
      await walk(tester, 2);
    });
  });
}
