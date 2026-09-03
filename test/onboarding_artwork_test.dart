import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/onboarding/onboarding_artwork.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The onboarding artwork is the part most likely to break silently: it is
/// laid out inside the screen gutters, it carries text of three very different
/// lengths, and Arabic mirrors it. A fixed width here overflows a 320dp
/// handset — which is inside the range this market ships on, not an edge case.
void main() {
  /// The narrow end of the market: a 320×568 handset, minus the 20dp gutters.
  const smallPhone = Size(320, 568);

  Widget host(Widget artwork, Locale locale, Size size) {
    Screen.update(MediaQueryData(size: size));
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
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: artwork,
          ),
        ),
      ),
    );
  }

  final artworks = <String, Widget>{
    'conversation': const ConversationArtwork(),
    'escalation': const EscalationArtwork(),
    'shortcuts': const ShortcutsArtwork(),
  };

  for (final locale in const [Locale('en'), Locale('fr'), Locale('ar')]) {
    for (final entry in artworks.entries) {
      testWidgets(
        '${entry.key} fits a 320dp handset in ${locale.languageCode}',
        (tester) async {
          tester.view.physicalSize = smallPhone;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(host(entry.value, locale, smallPhone));
          await tester.pumpAndSettle();

          // A RenderFlex overflow is reported as an exception, so the absence
          // of one is the assertion.
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('artwork sizes to its content rather than filling the screen',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      host(const EscalationArtwork(), const Locale('en'), const Size(400, 900)),
    );
    await tester.pumpAndSettle();

    // Regression: the artwork column originally defaulted to MainAxisSize.max,
    // so the card stretched the full height of the slide.
    final card = tester.getSize(find.byType(EscalationArtwork));
    expect(card.height, lessThan(300));
  });

  testWidgets('Arabic mirrors the layout', (tester) async {
    await tester.pumpWidget(
      host(const ConversationArtwork(), const Locale('ar'), smallPhone),
    );
    await tester.pumpAndSettle();

    final direction = Directionality.of(
      tester.element(find.byType(ConversationArtwork)),
    );
    expect(direction, TextDirection.rtl);
  });
}
