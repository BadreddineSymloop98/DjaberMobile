import 'package:djaber_mobile/app/routes.dart';
import 'package:djaber_mobile/core/storage/prefs_storage.dart';
import 'package:djaber_mobile/data/models/agent.dart';
import 'package:djaber_mobile/data/models/connected_page.dart';
import 'package:djaber_mobile/data/models/product.dart';
import 'package:djaber_mobile/data/models/stock_mode.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/tutorial/tutorial_ready_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_colors.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/stock_mode_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/tutorial_view_model.dart';
import 'package:djaber_mobile/presentation/widgets/checklist_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';

/// `T6 — Prêt`: the closing screen, and the Done state of the Checklist Row.
void main() {
  late SessionViewModel session;
  late PrefsStorage prefs;
  late StockModeViewModel stockMode;
  late TutorialViewModel tutorial;

  setUp(() async {
    session = await sessionForTest();
    prefs = await prefsForTest();
    stockMode = StockModeViewModel(prefs: prefs);
    tutorial = TutorialViewModel();
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
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TutorialViewModel>.value(value: tutorial),
        ],
        child: authHost(
          const TutorialReadyScreen(),
          session,
          locale: locale,
          prefs: prefs,
          stockMode: stockMode,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// What a full run leaves behind.
  ///
  /// The records **and** the progress marker: each step persists its own
  /// completion before navigating, so by the time a merchant reaches `T6` the
  /// stored step is `tutorialReady`. `done` is read from that rather than
  /// from the records, because the records do not survive a force-quit and the
  /// work on the server does.
  Future<void> seedAFullRun() async {
    await session.rememberTutorialStep(Routes.tutorialReady);
    tutorial.productCreated(
      const Product(id: 'p-1', sku: 'PRD-001', name: 'Robe satin — Noir'),
    );
    tutorial.agentCreated(
      const Agent(
        id: 'a-1',
        name: 'Assistant de vente',
        personality: AgentPersonality.professional,
      ),
    );
    tutorial.pageConnected(
      const ConnectedPage(
        id: 'pg-1',
        platform: PagePlatform.facebook,
        pageId: '178',
        pageName: 'Boutique Amel',
      ),
    );
  }

  testWidgets('shows what each step actually created', (tester) async {
    await seedAFullRun();
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    expect(find.text(l10n.tutorialReadyTitle), findsOneWidget);
    // Not a generic confirmation — the real records.
    expect(find.text('Robe satin — Noir'), findsOneWidget);
    expect(find.text('Assistant de vente · Professionnel'), findsOneWidget);
    expect(find.text('Boutique Amel'), findsOneWidget);
    expect(find.text(l10n.tutorialReadyModeSimple), findsOneWidget);
  });

  testWidgets('all four rows are ticked after a full run', (tester) async {
    await seedAFullRun();
    await pump(tester);

    final rows = tester.widgetList<ChecklistRow>(find.byType(ChecklistRow));
    expect(rows.length, 4);
    expect(rows.every((r) => r.done), isTrue);
  });

  testWidgets('a resumed run ticks what was completed even though the '
      'records are gone', (tester) async {
    // The case this screen used to get wrong. `TutorialViewModel` is
    // in-memory, so a merchant who force-quit after `T4` and came back has no
    // records at all — but they did create a product and an agent, and those
    // are on the server. Reading `done` off the records told them they had
    // done nothing.
    await session.rememberTutorialStep(Routes.tutorialConnect);
    await pump(tester);

    final rows = tester.widgetList<ChecklistRow>(find.byType(ChecklistRow))
        .toList();
    expect(rows.length, 4);
    expect(rows[0].done, isTrue, reason: 'mode was chosen');
    expect(rows[1].done, isTrue, reason: 'the product exists on the server');
    expect(rows[2].done, isTrue, reason: 'the agent exists on the server');
    expect(rows[3].done, isFalse, reason: 'the page step was never reached');

    // Ticked, but honest about not knowing what: no invented detail.
    expect(find.text('Robe satin — Noir'), findsNothing);
    expect(find.text('Boutique Amel'), findsNothing);
  });

  testWidgets('an unstarted run ticks nothing past the mode', (tester) async {
    // Straight from the intro to here should be impossible, but if it happens
    // the screen must not claim work that was never done.
    await pump(tester);

    final rows = tester.widgetList<ChecklistRow>(find.byType(ChecklistRow))
        .toList();
    expect(rows.map((r) => r.done).toList(), [false, false, false, false]);
  });

  testWidgets('deferring the page leaves that one line unticked, even though '
      'the step was reached', (tester) async {
    // The one step that can be reached and still not done — so it is the one
    // that cannot be inferred from progress alone.
    await session.rememberTutorialStep(Routes.tutorialReady);
    await prefs.setPageConnectionDeferred(true);
    await pump(tester);

    final rows = tester.widgetList<ChecklistRow>(find.byType(ChecklistRow))
        .toList();
    expect(rows[3].done, isFalse);
    // And a checklist that drops the line would be worse than one admitting it.
    expect(rows.length, 4);
  });

  testWidgets('the mode line follows the app-wide preference', (tester) async {
    await stockMode.setMode(StockMode.advanced);
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    expect(find.text(l10n.tutorialReadyModeAdvanced), findsOneWidget);
    expect(find.text(l10n.tutorialReadyModeSimple), findsNothing);
  });

  testWidgets('it carries no wizard chrome', (tester) async {
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    // The steps are done; there is nothing left to skip, and no step to count.
    expect(find.text(l10n.commonSkip), findsNothing);
    expect(find.text(l10n.tutorialStepCounter(4, 4)), findsNothing);
  });

  Iterable<BoxDecoration> ringsColoured(WidgetTester tester, Color colour) =>
      tester
          .widgetList<Container>(find.byType(Container))
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.border?.top.color == colour);

  testWidgets('the live mark uses signal/live, not white', (tester) async {
    await seedAFullRun();
    await pump(tester);

    expect(ringsColoured(tester, AppColors.live), isNotEmpty);
  });

  group('reached without connecting a page', () {
    testWidgets('it still ends here, and says what is outstanding',
        (tester) async {
      // Everything but the page — the merchant chose *Connecter plus tard*.
      tutorial.productCreated(
        const Product(id: 'p-1', sku: 'PRD-001', name: 'Robe satin'),
      );
      tutorial.agentCreated(const Agent(id: 'a-1', name: 'Assistant'));
      await pump(tester);
      final l10n = await L10n.delegate.load(const Locale('fr'));

      // The screen is reached...
      expect(find.text(l10n.tutorialReadySubmit), findsOneWidget);
      // ...but does not claim the agent is answering anyone.
      expect(find.text(l10n.tutorialReadyTitle), findsNothing);
      expect(find.text(l10n.tutorialReadyTitlePending), findsOneWidget);

      // The page step is on the list and unticked.
      final rows =
          tester.widgetList<ChecklistRow>(find.byType(ChecklistRow)).toList();
      expect(rows.length, 4);
      expect(rows[3].done, isFalse);

      // And `live` is not spent on "nearly".
      expect(ringsColoured(tester, AppColors.live), isEmpty);
      expect(ringsColoured(tester, AppColors.textMuted), isNotEmpty);
    });
  });

  for (final size in const [Size(320, 640), Size(360, 740)]) {
    testWidgets('renders without overflow at ${size.width.toInt()} wide',
        (tester) async {
      await seedAFullRun();
      await pump(tester, size: size);
      expect(tester.takeException(), isNull);
      expect(find.byType(ChecklistRow), findsNWidgets(4));
    });
  }

  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets('renders in ${locale.languageCode}', (tester) async {
      await seedAFullRun();
      await pump(tester, size: const Size(320, 640), locale: locale);
      expect(tester.takeException(), isNull);
      final l10n = await L10n.delegate.load(locale);
      expect(find.text(l10n.tutorialReadySubmit), findsOneWidget);
    });
  }

  group('the Checklist Row Done state', () {
    testWidgets('swaps the numbered ring for a filled tick', (tester) async {
      await seedAFullRun();
      await pump(tester);

      // The frame shows a tick, not the step number, once done.
      expect(find.text('✓'), findsNWidgets(4));
      expect(find.text('1'), findsNothing);
    });
  });
}
