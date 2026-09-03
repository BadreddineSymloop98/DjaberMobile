import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/auth/login_screen.dart';
import 'package:djaber_mobile/presentation/screens/onboarding/onboarding_artwork.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Two things that looked wrong on a handset and needed measuring rather than
/// eyeballing.
void main() {
  Widget host(Widget child, {Size size = const Size(411, 914)}) {
    const locale = Locale('fr');
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
      builder: (context, inner) {
        Screen.update(MediaQuery.of(context));
        return inner!;
      },
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('stock rows', () {
    testWidgets('every product name renders in exactly the same style',
        (tester) async {
      tester.view.physicalSize = const Size(411, 914);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(host(const StockArtwork()));
      await tester.pumpAndSettle();

      final names = ['Robe satin — Noir — M', 'Parfum Oud 50 ml', 'Sac cuir — Camel']
          .map((t) => tester.widget<Text>(find.text(t)).style!)
          .toList();

      // They look different on screen only because the stack fades — the
      // rows sit at 100%, 55% and 28% opacity, as the frame does. The type
      // itself must be identical.
      for (final style in names.skip(1)) {
        expect(style.fontSize, names.first.fontSize);
        expect(style.fontWeight, names.first.fontWeight);
        expect(style.fontFamily, names.first.fontFamily);
        expect(style.letterSpacing, names.first.letterSpacing);
      }
    });

    testWidgets('the row title matches the Figma Title style', (tester) async {
      tester.view.physicalSize = const Size(390, 844); // the design frame
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(host(const StockArtwork()));
      await tester.pumpAndSettle();

      final style = tester.widget<Text>(find.text('Parfum Oud 50 ml')).style!;
      // Geist Medium 14 — the file has one Title style and this is it.
      expect(style.fontSize, closeTo(14, 0.2));
      expect(style.fontWeight, FontWeight.w500);
      expect(style.fontFamily, 'Geist');
    });

    testWidgets('the three rows fade rather than resize', (tester) async {
      tester.view.physicalSize = const Size(411, 914);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(host(const StockArtwork()));
      await tester.pumpAndSettle();

      final opacities = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .map((o) => o.opacity)
          .toList();
      expect(opacities.take(3), [1.0, 0.55, 0.28]);
    });
  });

  group('login error message', () {
    testWidgets('is fully on screen and not overlapped by the row below',
        (tester) async {
      tester.view.physicalSize = const Size(411, 914);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          theme: AppTheme.build(const Locale('fr')),
          supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
          localizationsDelegates: const [
            L10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, inner) {
            Screen.update(MediaQuery.of(context));
            return inner!;
          },
          home: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      final error = find.text('Le mot de passe est requis');
      expect(error, findsOneWidget);

      final errorRect = tester.getRect(error);
      expect(errorRect.height, greaterThan(0));
      expect(errorRect.width, greaterThan(0));

      // Nothing sits on top of it: the checkbox below starts after it ends.
      final checkbox = tester.getRect(find.text('Se souvenir de moi'));
      expect(checkbox.top, greaterThanOrEqualTo(errorRect.bottom),
          reason: 'the row below must not overlap the message');

      // And it is inside the viewport, not scrolled off.
      expect(errorRect.top, greaterThanOrEqualTo(0));
      expect(errorRect.bottom, lessThanOrEqualTo(914));
    });
  });
}
