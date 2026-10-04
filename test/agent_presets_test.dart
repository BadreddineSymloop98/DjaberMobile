import 'package:djaber_mobile/app/routes.dart';
import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/data/models/agent.dart';
import 'package:djaber_mobile/data/models/agent_draft.dart';
import 'package:djaber_mobile/data/models/agent_insight.dart';
import 'package:djaber_mobile/data/models/agent_preset.dart';
import 'package:djaber_mobile/data/models/ai_provider.dart';
import 'package:djaber_mobile/data/models/connected_page.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/page_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/agents/agent_new_screen.dart';
import 'package:djaber_mobile/presentation/screens/agents/agent_presets_screen.dart';
import 'package:djaber_mobile/presentation/screens/agents/agents_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:djaber_mobile/presentation/viewmodels/agent_create_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';
import 'support/fake_repositories.dart';

/// `15 — Agents · démarrer`: ready-made agents and "Partir de zéro".
void main() {
  const pages = [
    ConnectedPage(id: 'p-1', platform: PagePlatform.facebook, pageId: '1', pageName: 'Boutique'),
    ConnectedPage(id: 'p-2', platform: PagePlatform.instagram, pageId: '2', pageName: 'boutique.ig'),
  ];

  group('creating', () {
    test('a preset creates its full configuration on every connected page', () async {
      final agents = _Agents();
      final model = AgentPresetsViewModel(agents: agents, pages: FakePageRepository(pages: pages));
      addTearDown(model.dispose);

      final closer = AgentPreset.all.first;
      expect(await model.createFrom(closer), AgentCreateOutcome.created);

      final call = agents.creates.single;
      expect(call.name, 'Vendeur Pro');
      expect(call.personality, AgentPersonality.friendly);
      expect(call.pageIds, ['p-1', 'p-2']);
      expect(call.preset?.configuration['voiceTranscription'], isTrue);
      expect(call.instructions, contains('Algerian online store'));
    });

    test('a second agent is created, on the pages no agent holds yet', () async {
      final agents = _Agents(existing: true);
      final model = AgentPresetsViewModel(agents: agents, pages: FakePageRepository(pages: pages));
      addTearDown(model.dispose);

      expect(await model.createFrom(AgentPreset.all.last), AgentCreateOutcome.created);
      final call = agents.creates.single;
      expect(call.name, 'Réponse Express');
      expect(call.pageIds, ['p-2'], reason: 'p-1 already answers through Sara');
    });

    test('a plan limit comes back as such, with the backend error to show', () async {
      final agents = _Agents(limitReached: true);
      final model = AgentPresetsViewModel(agents: agents, pages: FakePageRepository(pages: pages));
      addTearDown(model.dispose);

      expect(await model.createFrom(AgentPreset.all.first), AgentCreateOutcome.limitReached);
      expect(model.createError?.code, 'PLAN_LIMIT_REACHED');
      expect(model.creatingKey, isNull);
    });

    test('from scratch: a name is required, then it creates on every page', () async {
      final agents = _Agents();
      final model = NewAgentViewModel(
        agents: agents,
        pages: FakePageRepository(pages: pages),
        products: FakeProductRepository(),
      );
      addTearDown(model.dispose);

      expect(await model.submitAndCreate(), isNull, reason: 'empty name');
      expect(agents.creates, isEmpty);

      model.name.controller.text = 'Sara';
      model.selectPersonality(AgentPersonality.casual);
      model.instructions.controller.text = 'Toujours vouvoyer';
      expect(await model.submitAndCreate(), AgentCreateOutcome.created);

      final call = agents.creates.single;
      expect(call.name, 'Sara');
      expect(call.personality, AgentPersonality.casual);
      expect(call.pageIds, ['p-1', 'p-2']);
      expect(call.preset, isNull);

      // The rest of the web form, at the web form's defaults.
      final body = agents.drafts.single.toJson();
      expect(body['aiModel'], 'gpt-4o-mini');
      expect(body['temperature'], 0.7);
      expect(body['maxTokens'], 1024);
      expect(body['responseDelay'], 3);
      expect(body['sellAllProducts'], isTrue);
      expect(body.containsKey('closingInstructions'), isFalse, reason: 'blank fields are left out');
    });

    test('from scratch: a page another agent holds is shown but never sent', () async {
      final agents = _Agents(existing: true);
      final model = NewAgentViewModel(
        agents: agents,
        pages: FakePageRepository(pages: pages),
        products: FakeProductRepository(),
      );
      addTearDown(model.dispose);
      await model.load();

      expect(model.takenBy('p-1'), 'Sara');
      expect(model.isPageSelected('p-1'), isFalse);
      expect(model.isPageSelected('p-2'), isTrue);
      model.togglePage('p-1');
      expect(model.isPageSelected('p-1'), isFalse, reason: 'a held page cannot be ticked');

      model.name.controller.text = 'Nour';
      model.selectModel('gpt-4o');
      model.setResponseDelay(0);
      expect(await model.submitAndCreate(), AgentCreateOutcome.created);
      final body = agents.drafts.single.toJson();
      expect(body['pageIds'], ['p-2']);
      expect(body['aiModel'], 'gpt-4o', reason: 'offered by the active providers');
      expect(body['responseDelay'], 1, reason: 'the backend reads 0 as unset and stores 3');
    });

    test('the draft clamps tokens and sends products only when not selling everything', () {
      const draft = AgentDraft(name: ' Sara ', maxTokens: 99999, sellAllProducts: false, productIds: ['x']);
      final body = draft.toJson();
      expect(body['name'], 'Sara');
      expect(body['maxTokens'], AgentDraft.maxTokensLimit);
      expect(body['productIds'], ['x']);
      expect(const AgentDraft(name: 'a', productIds: ['x']).toJson()['productIds'], isEmpty);
    });

    test('model costs round the way the web rounds them', () {
      expect(AiModelInfo.costPer1000('gpt-4o-mini'), '0.28');
      expect(AiModelInfo.costPer1000('claude-3-5-haiku-20241022'), '1.6');
      expect(AiModelInfo.costPer1000('unknown-model'), isNull);
      expect(AiModelInfo.label('unknown-model'), 'unknown-model');
    });
  });

  group('editing (15c)', () {
    const saved = AgentDraft(
      name: 'Sara',
      description: 'Vend des robes',
      personality: AgentPersonality.friendly,
      customInstructions: '- Vouvoyer',
      aiModel: 'gpt-4o',
      temperature: 0.6,
      maxTokens: 1200,
      sellAllProducts: false,
      pageIds: ['p-1'],
      productIds: ['x-1'],
    );

    NewAgentViewModel editor(_Agents agents) => NewAgentViewModel(
          agents: agents,
          pages: FakePageRepository(pages: pages),
          products: FakeProductRepository(),
          agentId: 'a-1',
        );

    test('the form opens on the agent as saved; its own page is not held', () async {
      final agents = _Agents(existing: true)..stored = saved;
      final model = editor(agents);
      addTearDown(model.dispose);
      await model.load();

      expect(model.name.value, 'Sara');
      expect(model.personality, AgentPersonality.friendly);
      expect(model.aiModel, 'gpt-4o');
      expect(model.tokens, 1200);
      expect(model.sellAllProducts, isFalse);
      expect(model.isProductSelected('x-1'), isTrue);
      expect(model.takenBy('p-1'), isNull, reason: 'Sara is the agent being edited');
      expect(model.isPageSelected('p-1'), isTrue);
      expect(model.isPageSelected('p-2'), isFalse, reason: 'no pre-ticking when editing');
      expect(model.hasChanges, isFalse, reason: 'reading the agent in is not a change');
    });

    test('a save sends only what changed, and a cleared text as null', () async {
      final agents = _Agents(existing: true)..stored = saved;
      final model = editor(agents);
      addTearDown(model.dispose);
      await model.load();

      model.setActive(false);
      model.description.controller.text = '';
      model.togglePage('p-2');
      expect(model.hasChanges, isTrue);

      expect(await model.submitAndSave(), AgentSaveOutcome.saved);
      final changes = agents.updates.single.changes;
      expect(changes.keys, unorderedEquals(['isActive', 'description', 'pageIds']));
      expect(changes['isActive'], isFalse);
      expect(changes['description'], isNull);
      expect(changes['pageIds'], ['p-1', 'p-2']);
      expect(model.hasChanges, isFalse);
    });

    test('nothing changed: nothing is sent', () async {
      final agents = _Agents(existing: true)..stored = saved;
      final model = editor(agents);
      addTearDown(model.dispose);
      await model.load();

      expect(await model.submitAndSave(), AgentSaveOutcome.unchanged);
      expect(agents.updates, isEmpty);
    });

    test('instructions the web appended meanwhile are kept', () async {
      final agents = _Agents(existing: true)..stored = saved;
      final model = editor(agents);
      addTearDown(model.dispose);
      await model.load();

      model.instructions.controller.text = '- Toujours vouvoyer';
      agents.stored = saved.withCustomInstructions('- Vouvoyer\n- Pas de livraison hors Algérie');

      expect(await model.submitAndSave(), AgentSaveOutcome.savedWithWebChanges);
      expect(agents.updates.single.changes['customInstructions'], '- Toujours vouvoyer\n- Pas de livraison hors Algérie');
    });

    test('a rewrite on the web stops the save until the merchant chooses', () async {
      final agents = _Agents(existing: true)..stored = saved;
      final model = editor(agents);
      addTearDown(model.dispose);
      await model.load();

      model.instructions.controller.text = '- Ma version';
      agents.stored = saved.withCustomInstructions('- Réécrit sur le web');

      expect(await model.submitAndSave(), AgentSaveOutcome.conflict);
      expect(agents.updates, isEmpty);
      expect(model.instructionsConflict, '- Réécrit sur le web');

      expect(await model.submitAndSave(overwrite: true), AgentSaveOutcome.saved);
      expect(agents.updates.single.changes['customInstructions'], '- Ma version');
    });

    test('taking the newer instructions makes them the base of the next save', () async {
      final agents = _Agents(existing: true)..stored = saved;
      final model = editor(agents);
      addTearDown(model.dispose);
      await model.load();

      model.instructions.controller.text = '- Ma version';
      agents.stored = saved.withCustomInstructions('- Réécrit sur le web');
      await model.submitAndSave();
      model.useLatestInstructions();

      expect(model.instructions.value, '- Réécrit sur le web');
      expect(model.hasChanges, isFalse);
    });

    test('an agent that cannot be read leaves an error to retry', () async {
      final agents = _Agents(existing: true);
      final model = editor(agents);
      addTearDown(model.dispose);
      await model.load();
      expect(model.loadError, isNotNull);
      expect(model.isLoaded, isFalse);

      agents.stored = saved;
      await model.retryLoad();
      expect(model.loadError, isNull);
      expect(model.name.value, 'Sara');
    });

    test('the draft reads the agent as the live docs show it', () {
      final draft = AgentDraft.fromJson({
        'name': 'Sara',
        'description': null,
        'personality': 'technical',
        'aiModel': 'gpt-4o-mini',
        'temperature': 0.7,
        'maxTokens': 1000,
        'sellAllProducts': false,
        'isActive': false,
        'pages': [
          {'pageId': 'p-9'},
        ],
        'products': [
          {'productId': 'pr-1', 'product': {'id': 'pr-1'}},
        ],
      });
      expect(draft.description, '');
      expect(draft.personality, AgentPersonality.technical);
      expect(draft.maxTokens, 1000);
      expect(draft.isActive, isFalse);
      expect(draft.pageIds, ['p-9']);
      expect(draft.productIds, ['pr-1']);
    });
  });

  group('back on the agents list', () {
    Future<L10n> pumpRouted(WidgetTester tester, _Agents agents) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      const locale = Locale('fr');
      final router = GoRouter(
        initialLocation: Routes.agents,
        routes: [
          GoRoute(path: Routes.agents, builder: (_, _) => const AgentsScreen()),
          GoRoute(path: Routes.agentNew, builder: (_, _) => const AgentPresetsScreen()),
          GoRoute(path: Routes.agentNewScratch, builder: (_, _) => const AgentNewScreen()),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AgentRepository>.value(value: agents),
            Provider<PageRepository>.value(value: FakePageRepository(pages: pages)),
            Provider<ProductRepository>.value(value: FakeProductRepository()),
          ],
          child: MediaQuery.fromView(
            view: tester.view,
            child: Builder(
              builder: (context) {
                Screen.update(MediaQuery.of(context));
                return MaterialApp.router(
                  locale: locale,
                  theme: AppTheme.build(locale),
                  supportedLocales: AppLanguage.values.map((l) => l.locale),
                  localizationsDelegates: const [
                    L10n.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  routerConfig: router,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return L10n.delegate.load(locale);
    }

    /// Lets the success toast run out, so no timer outlives the test.
    Future<void> settle(WidgetTester tester) async {
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    }

    testWidgets('a ready-made agent shows up without a manual refresh', (tester) async {
      final agents = _Agents();
      final l10n = await pumpRouted(tester, agents);

      await tester.tap(find.text(l10n.agentsEmptyCta));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.agentsPresetUse).first);
      await settle(tester);

      expect(find.byType(AgentPresetsScreen), findsNothing);
      expect(find.byType(AgentsScreen), findsOneWidget);
      expect(find.text(l10n.agentsEmptyCta), findsNothing);
      expect(find.text('Vendeur Pro'), findsOneWidget);
    });

    testWidgets('so does one started from scratch, two screens deep', (tester) async {
      final agents = _Agents();
      final l10n = await pumpRouted(tester, agents);

      await tester.tap(find.text(l10n.agentsEmptyCta));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text(l10n.agentsPresetScratch), 200);
      await tester.tap(find.text(l10n.agentsPresetScratch));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Sara');
      await tester.pump();
      await tester.tap(find.text(l10n.tutorialAgentSubmit));
      await settle(tester);

      expect(find.byType(AgentNewScreen), findsNothing);
      expect(find.byType(AgentPresetsScreen), findsNothing);
      expect(find.text(l10n.agentsEmptyCta), findsNothing);
      expect(find.text('Sara'), findsOneWidget);
    });

    testWidgets('with an agent already there, Nouvel agent adds a second', (tester) async {
      final agents = _Agents(existing: true);
      final l10n = await pumpRouted(tester, agents);

      await tester.scrollUntilVisible(find.text(l10n.agentsNewTitle), 200);
      await tester.tap(find.text(l10n.agentsNewTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.agentsPresetUse).first);
      await settle(tester);

      expect(find.byType(AgentPresetsScreen), findsNothing);
      expect(find.text('Sara'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Vendeur Pro'), 200);
      expect(find.text('Vendeur Pro'), findsOneWidget);
    });
  });

  group('layout', () {
    Future<void> pump(WidgetTester tester, Widget screen, Locale locale, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AgentRepository>.value(value: _Agents()),
            Provider<PageRepository>.value(value: FakePageRepository(pages: pages)),
            Provider<ProductRepository>.value(value: FakeProductRepository()),
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
                  home: screen,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('the four presets and the way to start from scratch', (tester) async {
      await pump(tester, const AgentPresetsScreen(), const Locale('fr'), const Size(390, 844));
      final l10n = await L10n.delegate.load(const Locale('fr'));
      for (final preset in AgentPreset.all) {
        await tester.scrollUntilVisible(find.text(preset.name), 200);
        expect(find.text(preset.name), findsOneWidget);
      }
      await tester.scrollUntilVisible(find.text(l10n.agentsPresetScratch), 200);
      expect(find.text(l10n.agentsPresetScratch), findsOneWidget);
    });

    for (final language in AppLanguage.values) {
      testWidgets('15 and the scratch form in ${language.code} at 320x640', (tester) async {
        await pump(tester, const AgentPresetsScreen(), language.locale, const Size(320, 640));
        expect(tester.takeException(), isNull);
        await pump(tester, const AgentNewScreen(), language.locale, const Size(320, 640));
        expect(tester.takeException(), isNull);
      });
    }
  });
}

class _Agents extends AgentRepository {
  _Agents({this.existing = false, this.limitReached = false}) : super(api: apiForTest());

  final bool existing;
  final bool limitReached;
  final creates = <({String name, AgentPersonality personality, String? instructions, List<String> pageIds, AgentPreset? preset})>[];

  @override
  Future<Result<List<Agent>>> list() async =>
      Result.success([
        if (existing) const Agent(id: 'a-1', name: 'Sara', pageIds: ['p-1']),
        for (final c in creates) Agent(id: 'a-new', name: c.name, personality: c.personality, pageIds: c.pageIds),
      ]);

  @override
  Future<Result<AgentMetrics>> metrics(String agentId) async => const Result.success(AgentMetrics());

  @override
  Future<Result<Agent>> create({
    required String name,
    required AgentPersonality personality,
    String? customInstructions,
    List<String> pageIds = const [],
    AgentPreset? preset,
  }) async {
    if (limitReached) {
      return const Result.failure(ForbiddenException('Agent limit reached', code: 'PLAN_LIMIT_REACHED'));
    }
    creates.add((name: name, personality: personality, instructions: customInstructions, pageIds: pageIds, preset: preset));
    return Result.success(Agent(id: 'a-new', name: name, personality: personality));
  }

  final drafts = <AgentDraft>[];

  @override
  Future<Result<Agent>> createFromDraft(AgentDraft draft) async {
    if (limitReached) {
      return const Result.failure(ForbiddenException('Agent limit reached', code: 'PLAN_LIMIT_REACHED'));
    }
    drafts.add(draft);
    creates.add((
      name: draft.name,
      personality: draft.personality,
      instructions: draft.customInstructions,
      pageIds: draft.pageIds,
      preset: null,
    ));
    return Result.success(Agent(id: 'a-new', name: draft.name, personality: draft.personality));
  }

  @override
  Future<Result<List<AiProvider>>> activeProviders() async => const Result.success([
        AiProvider(provider: 'openai', displayName: 'OpenAI', models: ['gpt-4o', 'gpt-4o-mini']),
      ]);

  /// The agent as the backend holds it, for the edit form. Change it after
  /// the form loaded to play the web changing the agent meanwhile.
  AgentDraft? stored;
  final updates = <({String id, Map<String, Object?> changes})>[];

  @override
  Future<Result<AgentDraft>> getDraft(String agentId) async {
    final agent = stored;
    return agent == null ? const Result.failure(ServerException('unreachable')) : Result.success(agent);
  }

  @override
  Future<Result<Agent>> update({required String agentId, required Map<String, Object?> changes}) async {
    updates.add((id: agentId, changes: changes));
    return Result.success(Agent(id: agentId, name: stored?.name ?? ''));
  }
}
