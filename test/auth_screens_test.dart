import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/auth/login_screen.dart';
import 'package:djaber_mobile/presentation/screens/auth/signup_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// These screens are the first in the app with a keyboard, a scroll view and a
/// bottom-pinned footer at the same time — the combination that silently
/// produces an unbounded-height layout error.
void main() {
  Widget host(Widget screen, {Locale locale = const Locale('fr')}) {
    return MaterialApp(
      locale: locale,
      theme: AppTheme.build(locale),
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        Screen.update(MediaQuery.of(context));
        return child!;
      },
      home: screen,
    );
  }

  for (final size in const [
    Size(360, 640), // the low end of the market
    Size(411, 914), // the emulator
    Size(320, 568), // narrower still
  ]) {
    testWidgets('login renders at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(host(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    });

    testWidgets('signup renders at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(host(const SignupScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Création de compte'), findsOneWidget);
      expect(find.text('Créer le compte'), findsOneWidget);
    });
  }

  testWidgets('login survives the keyboard taking half the screen',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(const LoginScreen()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping submit on an empty form shows both errors',
      (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('L’e-mail est requis'), findsNothing);

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('L’e-mail est requis'), findsOneWidget);
    expect(find.text('Le mot de passe est requis'), findsOneWidget);
  });

  testWidgets('the email error appears as you type and clears when valid',
      (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(const LoginScreen()));
    await tester.pumpAndSettle();

    final email = find.byType(TextField).first;
    await tester.enterText(email, 'amina@');
    await tester.pumpAndSettle();
    expect(find.text('Veuillez saisir une adresse e-mail valide'), findsOneWidget);

    await tester.enterText(email, 'amina@shop.dz');
    await tester.pumpAndSettle();
    expect(find.text('Veuillez saisir une adresse e-mail valide'), findsNothing);
  });

  testWidgets('the signup password hint gives way to the error and back',
      (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(const SignupScreen()));
    await tester.pumpAndSettle();

    // The standing rule is visible before anything is typed.
    expect(find.text('AU MOINS 8 CARACTÈRES'), findsOneWidget);

    final password = find.byType(TextField).last;
    await tester.enterText(password, 'court');
    await tester.pumpAndSettle();
    expect(
      find.text('Le mot de passe doit contenir au moins 8 caractères'),
      findsOneWidget,
    );
    expect(find.text('AU MOINS 8 CARACTÈRES'), findsNothing,
        reason: 'error and hint share a slot so the field keeps its height');

    await tester.enterText(password, 'motdepasse');
    await tester.pumpAndSettle();
    expect(find.text('AU MOINS 8 CARACTÈRES'), findsOneWidget);
  });

  testWidgets('the name fields reject digits at the keyboard', (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(const SignupScreen()));
    await tester.pumpAndSettle();

    final firstName = find.byType(TextField).first;
    await tester.enterText(firstName, 'Amina123');
    await tester.pumpAndSettle();

    expect(find.text('Amina'), findsOneWidget);
  });

  testWidgets('the email field refuses whitespace', (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(const LoginScreen()));
    await tester.pumpAndSettle();

    // The classic paste-from-another-app case.
    await tester.enterText(find.byType(TextField).first, ' amina@shop.dz ');
    await tester.pumpAndSettle();

    expect(find.text('amina@shop.dz'), findsOneWidget);
  });
}
