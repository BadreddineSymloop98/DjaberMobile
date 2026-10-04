import 'package:djaber_mobile/core/storage/prefs_storage.dart';
import 'package:djaber_mobile/data/models/stock_mode.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/tutorial/tutorial_mode_screen.dart';
import 'package:djaber_mobile/presentation/screens/tutorial/tutorial_step_scaffold.dart';
import 'package:djaber_mobile/presentation/theme/app_colors.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/stock_mode_view_model.dart';
import 'package:djaber_mobile/presentation/widgets/option_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_host.dart';

/// `T2 — Mode stock` and the wizard shell it is the first user of.
void main() {
  late SessionViewModel session;
  late PrefsStorage prefs;
  late StockModeViewModel stockMode;

  setUp(() async {
    session = await sessionForTest();
    prefs = await prefsForTest();
    stockMode = StockModeViewModel(prefs: prefs);
  });

  tearDown(() => session.dispose());

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    Locale locale = const Locale('fr'),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      authHost(
        const TutorialModeScreen(),
        session,
        locale: locale,
        prefs: prefs,
        stockMode: stockMode,
      ),
    );
    await tester.pumpAndSettle();
  }

  OptionCard cardFor(WidgetTester tester, String label) => tester
      .widgetList<OptionCard>(find.byType(OptionCard))
      .firstWhere((c) => c.label == label);

  group('the wizard shell', () {
    testWidgets('shows the step counter and a segment per step',
        (tester) async {
      await pump(tester);
      final l10n = await L10n.delegate.load(const Locale('fr'));

      expect(find.text(l10n.tutorialStepCounter(1, 4)), findsOneWidget);
      expect(find.text('ÉTAPE 1 SUR 4'), findsOneWidget);
      expect(TutorialStepScaffold.stepCount, 4);
    });

    testWidgets('lights the segments up to and including the current step',
        (tester) async {
      await pump(tester);

      final segments = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.borderRadius != null && d.border == null)
          .toList();

      // On step 1 exactly one segment is lit; the other three are the muted
      // 40% the frames use.
      final lit = segments.where((d) => d.color == AppColors.textPrimary);
      expect(lit.length, 1);
      expect(
        segments.where((d) => d.color == AppColors.textMuted.withValues(alpha: 0.4)).length,
        3,
      );
    });

    testWidgets('the segments actually have height', (tester) async {
      await pump(tester);

      // Regression: the first build put a childless `DecoratedBox` inside an
      // `Expanded`, and the Row's default centre alignment gave it a loose
      // height constraint — so all four segments laid out at zero height and
      // the bar was invisible on the handset, while every colour assertion
      // above still passed. Measure the box, do not just find it.
      final segments = find.byType(DecoratedBox);
      final bars = tester
          .widgetList<DecoratedBox>(segments)
          .toList()
          .asMap()
          .keys
          .map((i) => tester.getSize(segments.at(i)))
          .where((s) => s.width > 20) // the four bars, not the card borders
          .toList();

      expect(bars, isNotEmpty);
      for (final bar in bars) {
        expect(bar.height, greaterThan(0));
      }
    });

    testWidgets('has no Passer, and the step counter is mono', (tester) async {
      await pump(tester);
      final l10n = await L10n.delegate.load(const Locale('fr'));

      // Every step frame draws a `Passer`; it is deliberately gone. The
      // tutorial is completed, not skipped.
      expect(find.text(l10n.commonSkip), findsNothing);
      // And the deferral belongs to `T5` alone — this step writes a device
      // preference and cannot fail, so it has nothing to defer.
      expect(find.text(l10n.connectLater), findsNothing);
      final counter =
          tester.widget<Text>(find.text(l10n.tutorialStepCounter(1, 4)));
      // Label/Meta: JetBrains Mono 9.
      expect(counter.style!.fontFamily, 'JetBrainsMono');
      expect(counter.style!.fontSize, 9);
    });
  });

  group('T2 — Mode stock', () {
    testWidgets('Simple is preselected, and only it carries the badge',
        (tester) async {
      await pump(tester);
      final l10n = await L10n.delegate.load(const Locale('fr'));

      // The web's default, and what the frame shows.
      expect(cardFor(tester, l10n.stockModeSimple).selected, isTrue);
      expect(cardFor(tester, l10n.stockModeAdvanced).selected, isFalse);
      expect(find.text(l10n.commonActive), findsOneWidget);
    });

    testWidgets('Simple is preselected even on a phone that remembers Avancé',
        (tester) async {
      // Someone chose Avancé on this handset before, then signed out; the
      // preference survives. The new account's tutorial must still start on
      // Simple.
      await prefs.setStockMode(StockMode.advanced);
      stockMode = StockModeViewModel(prefs: prefs);
      expect(stockMode.mode, StockMode.advanced);

      await pump(tester);
      final l10n = await L10n.delegate.load(const Locale('fr'));

      expect(cardFor(tester, l10n.stockModeSimple).selected, isTrue);
      expect(cardFor(tester, l10n.stockModeAdvanced).selected, isFalse);
      expect(find.text(l10n.commonActive), findsOneWidget);
    });

    testWidgets('tapping Avancé moves the selection', (tester) async {
      await pump(tester);
      final l10n = await L10n.delegate.load(const Locale('fr'));

      await tester.tap(find.text(l10n.stockModeAdvanced));
      await tester.pumpAndSettle();

      expect(cardFor(tester, l10n.stockModeAdvanced).selected, isTrue);
      expect(cardFor(tester, l10n.stockModeSimple).selected, isFalse);
      // Still exactly one badge — the bug the Figma frame for 11 Paramètres
      // has, where both cards read ACTIF, must not reach code.
      expect(find.text(l10n.commonActive), findsOneWidget);
    });

    testWidgets('the choice is not written until Continuer', (tester) async {
      await pump(tester);
      final l10n = await L10n.delegate.load(const Locale('fr'));

      await tester.tap(find.text(l10n.stockModeAdvanced));
      await tester.pumpAndSettle();

      // Backing out of the step must not leave the preference changed.
      expect(prefs.stockMode, StockMode.simple);
    });

    testWidgets('the card copy is the web i18n.ts strings, not the frame',
        (tester) async {
      await pump(tester);

      // page.dash.settings.simpleDesc / .advancedDesc, verbatim. The Figma
      // frame paraphrases these; the web is the source of truth (§17).
      expect(
        find.text(
          'Produits, Catégories & Commandes — gérez votre inventaire et '
          'commandes sans complexité.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Suite complète — Fournisseurs, Clients, Ventes, Achats, Caisse, '
          'Mouvements, Livraison et plus.',
        ),
        findsOneWidget,
      );
    });

    for (final size in const [Size(320, 640), Size(360, 740), Size(411, 914)]) {
      testWidgets('renders without overflow at ${size.width.toInt()} wide',
          (tester) async {
        await pump(tester, size: size);
        expect(tester.takeException(), isNull);
        expect(find.byType(OptionCard), findsNWidgets(2));
      });
    }

    for (final locale in const [Locale('fr'), Locale('en'), Locale('ar')]) {
      testWidgets('renders in ${locale.languageCode}', (tester) async {
        await pump(tester, size: const Size(320, 640), locale: locale);
        expect(tester.takeException(), isNull);

        final l10n = await L10n.delegate.load(locale);
        expect(find.text(l10n.stockModeSimple), findsOneWidget);
        expect(find.text(l10n.stockModeAdvanced), findsOneWidget);
        expect(find.text(l10n.commonContinue), findsOneWidget);
      });
    }
  });
}
