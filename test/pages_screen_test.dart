import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/data/models/agent.dart';
import 'package:djaber_mobile/data/models/connected_page.dart';
import 'package:djaber_mobile/data/models/page_summary.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/page_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/pages/pages_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/pages_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/fake_repositories.dart';

/// `12 — Pages connectées` and `13 — Connecter une page`.
void main() {
  const boutique = ConnectedPage(id: 'p-1', platform: PagePlatform.facebook, pageId: '1', pageName: 'Boutique Amel');
  const cosmetics = ConnectedPage(id: 'p-2', platform: PagePlatform.instagram, pageId: '2', pageName: 'amel.cosmetiques');

  const readySummary = PageSummary(
    conversations: 128,
    activeConversations: 12,
    unread: 3,
    messages7d: 340,
    incoming7d: 210,
    products: 128,
    agent: PageAgentStatus(
      id: 'a-1',
      name: 'Vendeur Pro',
      enabled: true,
      personality: AgentPersonality.friendly,
      hasInstructions: true,
    ),
  );

  group('the summary', () {
    test('reads the card as the live docs show it', () {
      final summary = PageSummary.fromJson({
        'pictureUrl': 'https://graph.facebook.com/v18.0/1/picture?type=large',
        'conversations': {'total': 142, 'active': 37, 'resolved': 98, 'archived': 7, 'unread': 5},
        'messages': {'last7d': 418, 'last24h': 63, 'incoming7d': 231, 'outgoing7d': 187},
        'products': 54,
        'agent': {
          'id': 'a-1',
          'name': 'Boutique Lina agent',
          'enabled': true,
          'autoReply': true,
          'personality': 'friendly',
          'hasInstructions': true,
        },
        'lastActivity': '2026-09-02T09:58:12.000Z',
      });
      expect(summary.conversations, 142);
      expect(summary.unread, 5);
      expect(summary.incoming7d, 231);
      expect(summary.products, 54);
      expect(summary.agent.isReady, isTrue);
      expect(summary.agent.personality, AgentPersonality.friendly);
      expect(summary.lastActivity, isNotNull);
    });

    test('an unlinked page has no agent id and is not ready', () {
      final summary = PageSummary.fromJson({
        'agent': {'id': null, 'name': null, 'enabled': false, 'personality': null, 'hasInstructions': false},
      });
      expect(summary.agent.id, isNull);
      expect(summary.agent.isReady, isFalse);
    });
  });

  group('connecting', () {
    test('a page new since the dialog opened counts as connected', () async {
      final repository = FakePageRepository(pages: [boutique]);
      final model = PagesViewModel(pages: repository, agents: FakeAgentRepository());
      addTearDown(model.dispose);
      await model.load();

      expect(await model.startConnect(PagePlatform.instagram), isNotNull);
      expect(model.connectingPlatform, PagePlatform.instagram);
      repository.pages = [boutique, cosmetics];

      expect(await model.afterGrant(PagePlatform.instagram), PageConnectOutcome.connected);
      expect(model.pages, hasLength(2));
      expect(model.connectingPlatform, isNull);
    });

    test('nothing new, and no confirmation from the callback: said plainly', () async {
      final repository = FakePageRepository(pages: [boutique]);
      final model = PagesViewModel(pages: repository, agents: FakeAgentRepository());
      addTearDown(model.dispose);
      await model.load();

      await model.startConnect(PagePlatform.facebook);
      expect(await model.afterGrant(PagePlatform.facebook), PageConnectOutcome.nothingNew);
    });

    test('reconnecting a page already listed counts when the callback saved one', () async {
      final repository = FakePageRepository(pages: [boutique]);
      final model = PagesViewModel(pages: repository, agents: FakeAgentRepository());
      addTearDown(model.dispose);
      await model.load();

      await model.startConnect(PagePlatform.facebook);
      final outcome = await model.afterGrant(
        PagePlatform.facebook,
        report: const OAuthCallbackReport(succeeded: true, pageCount: 1),
      );
      expect(outcome, PageConnectOutcome.connected);
    });
  });

  Future<FakePageRepository> pump(
    WidgetTester tester, {
    List<ConnectedPage> pages = const [],
    Map<String, PageSummary> summaries = const {},
    List<Agent> agents = const [],
    Locale locale = const Locale('fr'),
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = FakePageRepository(pages: pages, summaries: summaries);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PageRepository>.value(value: repository),
          Provider<AgentRepository>.value(value: FakeAgentRepository(agents: agents)),
        ],
        child: MediaQuery.fromView(
          view: tester.view,
          child: Builder(
            builder: (context) {
              Screen.update(MediaQuery.of(context));
              return MaterialApp(
                locale: locale,
                theme: AppTheme.build(locale),
                supportedLocales: AppLanguage.values.map((l) => l.locale),
                localizationsDelegates: const [
                  L10n.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: const PagesScreen(),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  /// The chip row scrolls sideways and the last chip starts past the edge on
  /// a phone, so it is brought into view before the tap — as a thumb would.
  Future<void> tapTab(WidgetTester tester, String label) async {
    final chip = find.descendant(of: find.byType(SingleChildScrollView), matching: find.text(label)).first;
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
  }

  group('on screen', () {
    testWidgets('13: no page — the empty panel and both ways to connect', (tester) async {
      await pump(tester);
      final l10n = await L10n.delegate.load(const Locale('fr'));

      expect(find.text(l10n.pagesTitle), findsOneWidget);
      expect(find.text(l10n.pagesEmptyTitle), findsOneWidget);
      expect(find.text(l10n.connectFacebook), findsOneWidget);
      expect(find.text(l10n.connectInstagram), findsOneWidget);
      expect(find.text(l10n.pagesStatTotal.toUpperCase()), findsNothing, reason: 'no strip without pages');
    });

    testWidgets('the connect buttons follow the chip', (tester) async {
      await pump(tester);
      final l10n = await L10n.delegate.load(const Locale('fr'));

      await tapTab(tester, l10n.platformInstagram);
      expect(find.text(l10n.connectInstagram), findsOneWidget);
      expect(find.text(l10n.connectFacebook), findsNothing);

      await tapTab(tester, l10n.platformFacebook);
      expect(find.text(l10n.connectFacebook), findsOneWidget);
      expect(find.text(l10n.connectInstagram), findsNothing);

      await tapTab(tester, l10n.pagesFilterAll);
      expect(find.text(l10n.connectFacebook), findsOneWidget);
      expect(find.text(l10n.connectInstagram), findsOneWidget);
    });

    testWidgets('the AI status is the linked agent\'s, as Agents IA shows it', (tester) async {
      // The summary says off (legacy settings); the agent on the page is active.
      await pump(
        tester,
        pages: [boutique],
        summaries: {'p-1': const PageSummary(agent: PageAgentStatus(enabled: false))},
        agents: const [
          Agent(
            id: 'a-1',
            name: 'Vendeur Pro',
            personality: AgentPersonality.friendly,
            customInstructions: '- Vouvoyer',
            pageIds: ['p-1'],
          ),
        ],
      );
      final l10n = await L10n.delegate.load(const Locale('fr'));

      expect(find.text(l10n.pageCardAiOn.toUpperCase()), findsOneWidget);
      expect(find.text('${l10n.pageCardAgentReady} · ${l10n.agentToneFriendly}'), findsOneWidget);
    });

    testWidgets('a paused agent on the page reads as AI off', (tester) async {
      await pump(
        tester,
        pages: [boutique],
        summaries: {'p-1': readySummary},
        agents: const [
          Agent(id: 'a-1', name: 'Vendeur Pro', isActive: false, customInstructions: '- Vouvoyer', pageIds: ['p-1']),
        ],
      );
      final l10n = await L10n.delegate.load(const Locale('fr'));

      expect(find.text(l10n.pageCardAiOff.toUpperCase()), findsOneWidget);
      expect(find.text(l10n.pageCardAgentGenerate), findsOneWidget);
    });

    testWidgets('12: the strip, the cards and their counters', (tester) async {
      await pump(
        tester,
        pages: [boutique, cosmetics],
        summaries: {'p-1': readySummary},
        agents: const [
          Agent(
            id: 'a-1',
            name: 'Vendeur Pro',
            personality: AgentPersonality.friendly,
            customInstructions: '- Vouvoyer',
            pageIds: ['p-1'],
          ),
        ],
      );
      final l10n = await L10n.delegate.load(const Locale('fr'));

      expect(find.text('Boutique Amel'), findsOneWidget);
      expect(find.text('2/∞'), findsOneWidget);
      expect(find.text('340'), findsOneWidget);
      expect(find.text(l10n.pageCardAgentRegenerate), findsOneWidget);

      // The second card sits below the fold: scroll the page list, not the tabs.
      final list = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first;
      await tester.scrollUntilVisible(find.text(l10n.pageCardAgentGenerate), 300, scrollable: list);
      expect(find.text('amel.cosmetiques'), findsOneWidget);
      // Its summary failed: identity with dashes, and Générer.
      expect(find.text('–'), findsWidgets);
      expect(find.text(l10n.pageCardAgentGenerate), findsOneWidget);
    });

    testWidgets('the platform tabs filter the cards', (tester) async {
      await pump(tester, pages: [boutique, cosmetics]);
      final l10n = await L10n.delegate.load(const Locale('fr'));

      await tapTab(tester, l10n.platformInstagram);
      expect(find.text('Boutique Amel'), findsNothing);
      expect(find.text('amel.cosmetiques'), findsOneWidget);
    });

    testWidgets('disconnecting asks first, then removes the card', (tester) async {
      final repository = await pump(tester, pages: [boutique]);
      final l10n = await L10n.delegate.load(const Locale('fr'));

      await tester.tap(find.bySemanticsLabel(l10n.pageCardActionDisconnect));
      await tester.pumpAndSettle();
      expect(find.text(l10n.pagesDisconnectTitle), findsOneWidget);

      await tester.tap(find.text(l10n.pagesDisconnectConfirm));
      await tester.pumpAndSettle();
      expect(repository.disconnected, ['p-1']);
      expect(find.text('Boutique Amel'), findsNothing);
      expect(find.text(l10n.pagesEmptyTitle), findsOneWidget);

      // Let the toast run out, so no timer outlives the test.
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });

    const sizes = {'320x640': Size(320, 640), '411x914': Size(411, 914)};
    for (final language in AppLanguage.values) {
      for (final size in sizes.entries) {
        testWidgets('12 and 13 in ${language.code} at ${size.key}', (tester) async {
          await pump(tester, locale: language.locale, size: size.value);
          expect(tester.takeException(), isNull);
          await pump(
            tester,
            pages: [boutique, cosmetics],
            summaries: {'p-1': readySummary},
            locale: language.locale,
            size: size.value,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
