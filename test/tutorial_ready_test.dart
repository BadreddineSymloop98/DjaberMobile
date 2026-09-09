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
  void seedAFullRun() {
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
    seedAFullRun();
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
    seedAFullRun();
    await pump(tester);

    final rows = tester.widgetList<ChecklistRow>(find.byType(ChecklistRow));
    expect(rows.length, 4);
    expect(rows.every((r) => r.done), isTrue);
  });

  testWidgets('a step with no record shows unticked rather than vanishing',
      (tester) async {
    // Only the agent was created — the merchant never finished the others.
    tutorial.agentCreated(const Agent(id: 'a-1', name: 'Assistant'));
    await pump(tester);

    final rows = tester.widgetList<ChecklistRow>(find.byType(ChecklistRow)).toList();
    // Still four lines: a checklist that silently drops one is worse.
    expect(rows.length, 4);
    // Mode is always ticked — it has a default. Agent is ticked. The product
    // and the page are not.
    expect(rows[0].done, isTrue);
    expect(rows[1].done, isFalse);
    expect(rows[2].done, isTrue);
    expect(rows[3].done, isFalse);
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
    seedAFullRun();
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
      seedAFullRun();
      await pump(tester, size: size);
      expect(tester.takeException(), isNull);
      expect(find.byType(ChecklistRow), findsNWidgets(4));
    });
  }

  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets('renders in ${locale.languageCode}', (tester) async {
      seedAFullRun();
      await pump(tester, size: const Size(320, 640), locale: locale);
      expect(tester.takeException(), isNull);
      final l10n = await L10n.delegate.load(locale);
      expect(find.text(l10n.tutorialReadySubmit), findsOneWidget);
    });
  }

  group('the Checklist Row Done state', () {
    testWidgets('swaps the numbered ring for a filled tick', (tester) async {
      seedAFullRun();
      await pump(tester);

      // The frame shows a tick, not the step number, once done.
      expect(find.text('✓'), findsNWidgets(4));
      expect(find.text('1'), findsNothing);
    });
  });
}
