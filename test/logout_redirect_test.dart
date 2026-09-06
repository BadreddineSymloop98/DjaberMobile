import 'package:djaber_mobile/app/router.dart';
import 'package:djaber_mobile/app/routes.dart';
import 'package:djaber_mobile/core/services/push_service.dart';
import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/data/models/user.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';

/// Signing out has to *land* somewhere, and nothing on the home screen makes
/// that happen — the router's redirect does, by watching the session. So the
/// behaviour worth testing is the redirect, not the button.
void main() {
  late SessionViewModel session;
  late AppRouter router;

  setUp(() async {
    session = await sessionForTest();
    router = AppRouter(session: session, push: NoopPushService());
  });

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

  testWidgets('a signed-in merchant lands on home', (tester) async {
    session.debugSetUser(const User(
      id: 'u-1',
      email: 'amina@shop.dz',
      firstName: 'Amina',
    ));
    await pumpApp(tester);

    expect(location(), Routes.home);
    expect(find.text('Bon retour, Amina'), findsOneWidget);
  });

  testWidgets('tapping sign out returns them to login', (tester) async {
    session.debugSetUser(const User(
      id: 'u-1',
      email: 'amina@shop.dz',
      firstName: 'Amina',
    ));
    await pumpApp(tester);
    expect(location(), Routes.home);

    await tester.tap(find.text('Déconnexion'));
    await tester.pumpAndSettle();

    // Onboarding has been seen in this flow only if prefs say so; a fresh
    // install has not, so the redirect sends them to onboarding instead.
    // Either way they must leave home.
    expect(location(), isNot(Routes.home));
    expect(session.isSignedIn, isFalse);
  });

  testWidgets('after onboarding has been seen, sign out lands on login',
      (tester) async {
    await session.completeOnboarding();
    session.debugSetUser(const User(
      id: 'u-1',
      email: 'amina@shop.dz',
      firstName: 'Amina',
    ));
    await pumpApp(tester);

    await tester.tap(find.text('Déconnexion'));
    await tester.pumpAndSettle();

    expect(location(), Routes.login);
    expect(find.text('Connexion'), findsOneWidget);
  });

  testWidgets('and the token is gone, so a restart does not sign them back in',
      (tester) async {
    await session.completeOnboarding();
    session.debugSetUser(const User(id: 'u-1', email: 'amina@shop.dz'));
    await pumpApp(tester);

    expect(await session.hasStoredSessionForTest(), isTrue);

    await tester.tap(find.text('Déconnexion'));
    await tester.pumpAndSettle();

    expect(await session.hasStoredSessionForTest(), isFalse);
  });
}
