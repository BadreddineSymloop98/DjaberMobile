import 'package:djaber_mobile/presentation/screens/auth/login_screen.dart';
import 'package:djaber_mobile/presentation/screens/auth/signup_screen.dart';
import 'package:djaber_mobile/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_host.dart';

/// These screens are the first in the app with a keyboard, a scroll view and a
/// bottom-pinned footer at the same time — the combination that silently
/// produces an unbounded-height layout error.
void main() {
  late SessionViewModel session;

  setUp(() async => session = await sessionForTest());
  tearDown(() => session.dispose());

  Widget host(Widget screen, {Locale locale = const Locale('fr')}) =>
      authHost(screen, session, locale: locale);

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

  testWidgets('the signup password shows no hint, only errors',
      (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(const SignupScreen()));
    await tester.pumpAndSettle();

    // The hint was removed from the design; nothing states the rule up front.
    expect(find.text('AU MOINS 8 CARACTÈRES'), findsNothing);

    final password = find.byType(TextField).last;
    await tester.enterText(password, 'court');
    await tester.pumpAndSettle();
    expect(
      find.text('Le mot de passe doit contenir au moins 8 caractères'),
      findsOneWidget,
    );

    await tester.enterText(password, 'motdepasse');
    await tester.pumpAndSettle();
    expect(
      find.text('Le mot de passe doit contenir au moins 8 caractères'),
      findsNothing,
    );
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

  testWidgets('the button and the input are exactly the same height',
      (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(const LoginScreen()));
    await tester.pumpAndSettle();

    final button = tester.getSize(find.byType(FilledButton));
    // The Container that draws the input box is the TextField's parent.
    final input = tester.getSize(
      find
          .ancestor(of: find.byType(TextField).first, matching: find.byType(Container))
          .first,
    );

    expect(input.height, button.height,
        reason: 'both come from AppSize.control');
  });

  testWidgets('the auth button matches the onboarding button', (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(const LoginScreen()));
    await tester.pumpAndSettle();
    final authButton = tester.getSize(find.byType(FilledButton)).height;

    await tester.pumpWidget(host(const OnboardingScreen()));
    await tester.pumpAndSettle();
    final onboardingButton = tester.getSize(find.byType(FilledButton)).height;

    expect(authButton, onboardingButton);
  });

  testWidgets('the name fields are stacked, not side by side', (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(const SignupScreen()));
    await tester.pumpAndSettle();

    final firstName = tester.getRect(find.byType(TextField).at(0));
    final lastName = tester.getRect(find.byType(TextField).at(1));

    expect(lastName.top, greaterThan(firstName.bottom));
    expect(firstName.width, lastName.width);
    // Full width, not half: a half-width field left no room for its error.
    expect(firstName.width, greaterThan(411 / 2));
  });

  /// Measured rather than asserted against the token, so a change to how the
  /// gap is built still has to produce the number the frame specifies.
  Future<double> signupButtonGap(WidgetTester tester, Size frame) async {
    tester.view.physicalSize = frame;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(const SignupScreen()));
    await tester.pumpAndSettle();

    final lastField = tester.getRect(
      find
          .ancestor(
            of: find.byType(TextField).last,
            matching: find.byType(Container),
          )
          .first,
    );
    return tester.getRect(find.byType(FilledButton)).top - lastField.bottom;
  }

  testWidgets('the sign-up button sits 34 below the last field', (tester) async {
    // On the design frame the token resolves to the Figma number exactly.
    expect(await signupButtonGap(tester, const Size(390, 844)), closeTo(34, 0.5));
  });

  testWidgets('that gap scales with the screen', (tester) async {
    // On a wider handset it grows in proportion rather than staying put.
    expect(
      await signupButtonGap(tester, const Size(411, 914)),
      closeTo(34 * 411 / 390, 0.5),
    );
  });

  testWidgets('only sign-up marks its fields required', (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(const SignupScreen()));
    await tester.pumpAndSettle();
    expect(find.textContaining('*', findRichText: true), findsWidgets);

    await tester.pumpWidget(host(const LoginScreen()));
    await tester.pumpAndSettle();
    expect(find.textContaining('*', findRichText: true), findsNothing);
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
