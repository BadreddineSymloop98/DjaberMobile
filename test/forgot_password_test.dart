import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/core/utils/validators.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/auth/forgot_password_screen.dart';
import 'package:djaber_mobile/presentation/screens/auth/password_sent_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:djaber_mobile/presentation/viewmodels/forgot_password_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

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

  void sizeTo(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('the reset form', () {
    test('asks only for an email', () {
      final model = ForgotPasswordViewModel();
      addTearDown(model.dispose);
      expect(model.fields.length, 1);
    });

    test('will not submit without a valid address', () {
      final model = ForgotPasswordViewModel();
      addTearDown(model.dispose);

      expect(model.submit(), isFalse);
      expect(model.visibleError(model.email), FieldError.required);

      model.email.controller.text = 'amina@';
      expect(model.submit(), isFalse);
      expect(model.visibleError(model.email), FieldError.invalidEmail);

      model.email.controller.text = 'amina@shop.dz';
      expect(model.submit(), isTrue);
    });

    test('trims the address it hands on', () {
      final model = ForgotPasswordViewModel();
      addTearDown(model.dispose);
      model.email.controller.text = 'amina@shop.dz';
      expect(model.submittedEmail, 'amina@shop.dz');
    });
  });

  group('07 — Mot de passe oublié', () {
    for (final size in const [Size(320, 568), Size(360, 640), Size(411, 914)]) {
      testWidgets('renders at ${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
        sizeTo(tester, size);
        await tester.pumpWidget(host(const ForgotPasswordScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Mot de passe oublié ?'), findsOneWidget);
        expect(find.text('Envoyer le lien'), findsOneWidget);
        // The one fact kept from the web's desktop side panel.
        expect(
          find.text('Votre lien de réinitialisation est chiffré et expire dans 1 heure'),
          findsOneWidget,
        );
      });
    }

    testWidgets('has a back link and a footer link, both to login',
        (tester) async {
      sizeTo(tester, const Size(411, 914));
      await tester.pumpWidget(host(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      // Top and bottom, as in the frame.
      expect(find.text('Retour à la connexion'), findsNWidgets(2));
      expect(find.text('Vous vous souvenez de votre mot de passe ?'), findsOneWidget);
    });

    testWidgets('shows the error on submit and clears it when fixed',
        (tester) async {
      sizeTo(tester, const Size(411, 914));
      await tester.pumpWidget(host(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Envoyer le lien'));
      await tester.pumpAndSettle();
      expect(find.text('L’e-mail est requis'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'amina@shop.dz');
      await tester.pumpAndSettle();
      expect(find.text('L’e-mail est requis'), findsNothing);
    });

    testWidgets('the field refuses whitespace', (tester) async {
      sizeTo(tester, const Size(411, 914));
      await tester.pumpWidget(host(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), ' amina@shop.dz ');
      await tester.pumpAndSettle();
      expect(find.text('amina@shop.dz'), findsOneWidget);
    });

    testWidgets('renders in Arabic, right to left', (tester) async {
      sizeTo(tester, const Size(411, 914));
      await tester.pumpWidget(
        host(const ForgotPasswordScreen(), locale: const Locale('ar')),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(TextField))),
        TextDirection.rtl,
      );
    });
  });

  group('08 — E-mail envoyé', () {
    testWidgets('shows the address it was given', (tester) async {
      sizeTo(tester, const Size(411, 914));
      await tester.pumpWidget(
        host(const PasswordSentScreen(email: 'amina@shop.dz')),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Vérifiez votre e-mail'), findsOneWidget);
      expect(find.text('amina@shop.dz'), findsOneWidget);
      expect(find.text('Essayez une autre adresse e-mail'), findsOneWidget);
    });

    testWidgets('omits the address block when it has none', (tester) async {
      // A cold deep link arrives without the `extra`, so the screen must not
      // invent an address or render an empty box where one should be.
      sizeTo(tester, const Size(411, 914));
      await tester.pumpWidget(host(const PasswordSentScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Vérifiez votre e-mail'), findsOneWidget);
      expect(find.text('Essayez une autre adresse e-mail'), findsOneWidget);
    });

    testWidgets('a long address is truncated rather than overflowing',
        (tester) async {
      sizeTo(tester, const Size(320, 568));
      await tester.pumpWidget(
        host(
          const PasswordSentScreen(
            email: 'une.adresse.electronique.vraiment.tres.longue@entreprise.example.dz',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
