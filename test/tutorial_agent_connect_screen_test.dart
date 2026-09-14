import 'package:djaber_mobile/data/models/agent.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/page_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/tutorial/tutorial_agent_screen.dart';
import 'package:djaber_mobile/presentation/screens/tutorial/tutorial_connect_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_colors.dart';
import 'package:djaber_mobile/presentation/theme/app_typography.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/tutorial_view_model.dart';
import 'package:djaber_mobile/presentation/widgets/option_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';

/// `T4 — Agent IA` and `T5 — Connecter la page` on screen.
void main() {
  late SessionViewModel session;

  setUp(() async {
    session = await sessionForTest();
  });

  tearDown(() => session.dispose());

  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    Size size = const Size(390, 844),
    Locale locale = const Locale('fr'),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = apiForTest();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AgentRepository>.value(value: AgentRepository(api: api)),
          Provider<PageRepository>.value(value: PageRepository(api: api)),
          ChangeNotifierProvider<TutorialViewModel>(
            create: (_) => TutorialViewModel(),
          ),
        ],
        child: authHost(screen, session, locale: locale),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Every label in the mono style must be uppercase.
  ///
  /// The mono style's tracking is designed for caps and the frames set these
  /// headings in them. `AppTextField` uppercases its own label, but a
  /// standalone `Text` does not — and on `T4` that left "Personnalité" sitting
  /// in sentence case among a screen of uppercase labels. Found by running the
  /// app on a handset, so it is pinned here.
  void expectMonoLabelsUppercase(WidgetTester tester) {
    for (final widget in tester.widgetList<Text>(find.byType(Text))) {
      final data = widget.data;
      if (data == null || widget.style?.fontFamily != 'JetBrainsMono') continue;
      final hasLetters = data.toLowerCase() != data.toUpperCase();
      if (hasLetters && data != data.toUpperCase()) {
        fail('mono label is not uppercase: "$data"');
      }
    }
  }

  group('T4 — Agent IA', () {
    testWidgets('carries the name, four tones and instructions',
        (tester) async {
      await pump(tester, const TutorialAgentScreen());
      final l10n = await L10n.delegate.load(const Locale('fr'));

      expect(find.byType(OptionCard), findsNWidgets(4));
      expect(find.text(l10n.agentToneProfessional), findsOneWidget);
      expect(find.text(l10n.agentToneTechnical), findsOneWidget);
      expect(find.text(l10n.tutorialAgentSubmit), findsOneWidget);
      expect(find.text(l10n.tutorialStepCounter(3, 4)), findsOneWidget);
    });

    testWidgets('Professionnel is preselected — the column default',
        (tester) async {
      await pump(tester, const TutorialAgentScreen());
      final l10n = await L10n.delegate.load(const Locale('fr'));

      final cards = tester.widgetList<OptionCard>(find.byType(OptionCard));
      final selected = cards.where((c) => c.selected).toList();
      expect(selected.length, 1);
      expect(selected.single.label, l10n.agentToneProfessional);
    });

    testWidgets('choosing another tone moves the badge', (tester) async {
      await pump(tester, const TutorialAgentScreen());
      final l10n = await L10n.delegate.load(const Locale('fr'));

      await tester.tap(find.text(l10n.agentToneCasual));
      await tester.pumpAndSettle();

      final cards = tester.widgetList<OptionCard>(find.byType(OptionCard));
      expect(cards.where((c) => c.selected).single.label,
          l10n.agentToneCasual);
      expect(find.text(l10n.commonActive), findsOneWidget);
    });

    testWidgets('the tone cards carry no icon, as the frame draws them',
        (tester) async {
      await pump(tester, const TutorialAgentScreen());
      for (final card in tester.widgetList<OptionCard>(find.byType(OptionCard))) {
        expect(card.icon, isNull);
      }
    });

    testWidgets('mono labels are uppercase', (tester) async {
      await pump(tester, const TutorialAgentScreen());
      expectMonoLabelsUppercase(tester);
    });
  });

  group('T5 — Connecter la page', () {
    testWidgets('lists the three permissions and both connect buttons',
        (tester) async {
      await pump(tester, const TutorialConnectScreen());
      final l10n = await L10n.delegate.load(const Locale('fr'));

      expect(find.text(l10n.connectPermissionPages), findsOneWidget);
      expect(find.text(l10n.connectPermissionMessages), findsOneWidget);
      expect(find.text(l10n.connectPermissionInfo), findsOneWidget);
      expect(find.text(l10n.connectFacebook), findsOneWidget);
      expect(find.text(l10n.connectInstagram), findsOneWidget);
      expect(find.text(l10n.tutorialStepCounter(4, 4)), findsOneWidget);
    });

    testWidgets('mono labels are uppercase', (tester) async {
      await pump(tester, const TutorialConnectScreen());
      expectMonoLabelsUppercase(tester);
    });

    testWidgets('offers a way out — the only step that does', (tester) async {
      await pump(tester, const TutorialConnectScreen());
      final l10n = await L10n.delegate.load(const Locale('fr'));

      // T5 is the only step that depends on a third party: the merchant may
      // have no Page yet, or Meta may not grant access. Without this the app
      // is unopenable for them.
      expect(find.text(l10n.connectLater), findsOneWidget);
    });

    testWidgets('the way out is a link, not a third button', (tester) async {
      await pump(tester, const TutorialConnectScreen());
      final l10n = await L10n.delegate.load(const Locale('fr'));

      // An escape hatch, not an alternative action — it must not compete with
      // the two Meta connections, or it reads as a third platform.
      final later = tester.widget<Text>(find.text(l10n.connectLater));
      expect(later.style!.fontSize, AppText.link.fontSize);
      expect(later.style!.color, AppColors.textSecondary);
    });
  });

  group('the wizard state', () {
    test('carries what each step created, and resets', () {
      final state = TutorialViewModel();
      expect(state.hasAgent, isFalse);

      state.agentCreated(const Agent(id: 'a-1', name: 'Assistant'));
      expect(state.agent!.id, 'a-1');
      expect(state.hasAgent, isTrue);

      // So a second run in the same session does not inherit the first's.
      state.reset();
      expect(state.hasAgent, isFalse);
      expect(state.hasPage, isFalse);
      expect(state.hasProduct, isFalse);
    });
  });
}
