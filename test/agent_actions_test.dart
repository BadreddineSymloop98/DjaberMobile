import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/data/models/agent.dart';
import 'package:djaber_mobile/data/models/agent_insight.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/agents/agent_details_screen.dart';
import 'package:djaber_mobile/presentation/screens/agents/agent_test_chat_screen.dart';
import 'package:djaber_mobile/presentation/screens/agents/agents_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:djaber_mobile/presentation/viewmodels/agent_details_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/agent_insights_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/agent_test_chat_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/agents_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';

/// The agent card's four actions: pending issues, test chat, details, delete.
void main() {
  const sara = Agent(
    id: 'a-1',
    name: 'Sara',
    personality: AgentPersonality.friendly,
    customInstructions: '- Toujours vouvoyer',
    aiModel: 'gpt-4o-mini',
  );

  final pendingInsight = AgentInsight.fromJson({
    'id': 'i-1',
    'type': 'unknown_topic',
    'customerMessage': 'Vous livrez en France ?',
    'aiResponse': 'Je vérifie et je reviens vers vous.',
    'detail': 'International shipping',
    'status': 'pending',
    'createdAt': '2026-09-01T14:22:05.000Z',
    'conversation': {'senderId': '1', 'platform': 'facebook'},
  });

  group('the requests', () {
    late List<RequestOptions> sent;
    late AgentRepository repository;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({'auth_token': 't'});
      sent = [];
      final dio = Dio()
        ..httpClientAdapter = _StubAdapter((options) {
          sent.add(options);
          final body = switch (options.path) {
            final p when p.endsWith('/metrics') => {
                'metrics': {'conversationCount': 42, 'insightsPending': 3, 'lastActiveDate': null},
              },
            final p when p.endsWith('/insights') => {'insights': []},
            final p when p.endsWith('/test') => {'response': 'La montre est à 4500 DA.'},
            _ => {'success': true, 'agent': {'id': 'a-1', 'name': 'Sara'}},
          };
          return ResponseBody.fromString(jsonEncode(body), 200, headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          });
        });
      repository = AgentRepository(api: apiForTest(dio: dio));
    });

    test('metrics are read from { metrics }', () async {
      final result = await repository.metrics('a-1');
      expect(result.valueOrNull?.conversationCount, 42);
      expect(result.valueOrNull?.insightsPending, 3);
      expect(sent.single.path, '/api/user-stock/agents/a-1/metrics');
    });

    test('insights pass the status filter, and none for all', () async {
      await repository.insights('a-1', status: InsightStatus.pending);
      await repository.insights('a-1', status: null);
      expect(sent[0].queryParameters, {'status': 'pending'});
      expect(sent[1].queryParameters, isEmpty);
    });

    test('resolving sends the instruction; dismissing never does', () async {
      await repository.resolveInsight(insightId: 'i-1', dismiss: false, newInstruction: '  Pas de livraison hors Algérie ');
      await repository.resolveInsight(insightId: 'i-1', dismiss: true, newInstruction: 'ignored');
      await repository.resolveInsight(insightId: 'i-1', dismiss: false, newInstruction: '   ');
      expect(sent[0].method, 'PUT');
      expect(sent[0].path, '/api/user-stock/agents/insights/i-1');
      expect(sent[0].data, {'action': 'resolve', 'newInstruction': 'Pas de livraison hors Algérie'});
      expect(sent[1].data, {'action': 'dismiss'});
      expect(sent[2].data, {'action': 'resolve'});
    });

    test('a test message carries the whole history with roles', () async {
      final reply = await repository.test(
        agentId: 'a-1',
        message: 'Et la livraison ?',
        history: const [ChatTurn.user('Salam'), ChatTurn.agent('Salam !')],
      );
      expect(reply.valueOrNull, 'La montre est à 4500 DA.');
      expect(sent.single.data, {
        'message': 'Et la livraison ?',
        'history': [
          {'role': 'user', 'content': 'Salam'},
          {'role': 'assistant', 'content': 'Salam !'},
        ],
      });
    });

    test('delete and instructions hit the agent itself', () async {
      await repository.delete('a-1');
      await repository.updateInstructions(agentId: 'a-1', instructions: '- Vouvoyer');
      expect(sent[0].method, 'DELETE');
      expect(sent[0].path, '/api/user-stock/agents/a-1');
      expect(sent[1].method, 'PUT');
      expect(sent[1].data, {'customInstructions': '- Vouvoyer'});
    });
  });

  group('the view models', () {
    test('deleting leaves no agent; a failed delete keeps it', () async {
      final ok = AgentsViewModel(agents: _Agents(rows: [sara]));
      addTearDown(ok.dispose);
      await ok.load();
      expect(await ok.deleteAgent(sara), isTrue);
      expect(ok.agents, isEmpty);

      final failing = AgentsViewModel(agents: _Agents(rows: [sara], deleteFails: true));
      addTearDown(failing.dispose);
      await failing.load();
      expect(await failing.deleteAgent(sara), isFalse);
      expect(failing.agents.single.id, 'a-1');
      expect(failing.deleteError, isNotNull);
    });

    test('the pending count comes from the metrics', () async {
      final model = AgentsViewModel(agents: _Agents(rows: [sara], pending: 4));
      addTearDown(model.dispose);
      await model.load();
      expect(model.pendingFor('a-1'), 4);
    });

    test('resolving with an instruction sends it, then reloads', () async {
      final agents = _Agents(rows: [sara], insightRows: [pendingInsight]);
      final model = AgentInsightsViewModel(agents: agents, agentId: 'a-1');
      addTearDown(model.dispose);
      await model.load();
      expect(model.items, hasLength(1));

      model.startResolving('i-1');
      model.instructionController.text = 'Pas de livraison hors Algérie';
      expect(await model.resolve('i-1'), isTrue);

      expect(agents.resolutions.single, (id: 'i-1', dismiss: false, instruction: 'Pas de livraison hors Algérie'));
      expect(model.items, isEmpty, reason: 'no longer pending after the reload');
      expect(model.resolvingId, isNull);
    });

    // Plan 3: Details → Modifier, and while the field is open the web resolves
    // an insight with an instruction (appended as `\n- …`). Saving from the
    // phone used to send its old copy and erase what the web added.
    test('saving keeps lines the web appended while the editor was open', () async {
      final agents = _Agents(rows: [sara]);
      final model = AgentDetailsViewModel(agents: agents, agentId: 'a-1');
      addTearDown(model.dispose);
      await model.load();

      model.startEditing();
      await pumpEventQueue();
      model.instructions.text = '- Vouvoyer';
      agents.serverInstructions = '- Toujours vouvoyer\n- Pas de livraison hors Algérie';

      expect(await model.saveInstructions(), InstructionsSaveOutcome.savedWithWebChanges);
      expect(agents.savedInstructions.single, '- Vouvoyer\n- Pas de livraison hors Algérie');
      expect(model.isEditing, isFalse);
    });

    test('a rewrite elsewhere is never overwritten without the merchant choosing', () async {
      final agents = _Agents(rows: [sara]);
      final model = AgentDetailsViewModel(agents: agents, agentId: 'a-1');
      addTearDown(model.dispose);
      await model.load();

      model.startEditing();
      await pumpEventQueue();
      model.instructions.text = '- Ma version';
      agents.serverInstructions = '- Réécrit sur le web';

      expect(await model.saveInstructions(), InstructionsSaveOutcome.conflict);
      expect(agents.savedInstructions, isEmpty);
      expect(model.conflict, '- Réécrit sur le web');
      expect(model.isEditing, isTrue, reason: 'the edit stays open');

      model.useLatest();
      expect(model.instructions.text, '- Réécrit sur le web');
      expect(model.conflict, isNull);
      model.instructions.text = '- Réécrit sur le web\n- Ma version';
      expect(await model.saveInstructions(), InstructionsSaveOutcome.saved);
      expect(agents.savedInstructions.single, '- Réécrit sur le web\n- Ma version');
    });

    test('"replace with mine" saves the edit over the newer text', () async {
      final agents = _Agents(rows: [sara]);
      final model = AgentDetailsViewModel(agents: agents, agentId: 'a-1');
      addTearDown(model.dispose);
      await model.load();
      model.startEditing();
      await pumpEventQueue();
      model.instructions.text = '- Ma version';
      agents.serverInstructions = '- Réécrit sur le web';
      await model.saveInstructions();

      expect(await model.saveInstructions(overwrite: true), InstructionsSaveOutcome.saved);
      expect(agents.savedInstructions.single, '- Ma version');
    });

    test('opening the editor shows newer instructions while nothing is typed', () async {
      final agents = _Agents(rows: [sara]);
      final model = AgentDetailsViewModel(agents: agents, agentId: 'a-1');
      addTearDown(model.dispose);
      await model.load();

      agents.serverInstructions = '- Toujours vouvoyer\n- Ajouté sur le web';
      model.startEditing();
      expect(model.instructions.text, '- Toujours vouvoyer', reason: 'what the screen showed');
      await pumpEventQueue();
      expect(model.instructions.text, '- Toujours vouvoyer\n- Ajouté sur le web');
    });

    test('what counts as appended', () {
      expect(AgentDetailsViewModel.appendedLines(base: '- A', server: '- A\n- B'), '- B');
      expect(AgentDetailsViewModel.appendedLines(base: '', server: '\n- B'), '- B');
      expect(AgentDetailsViewModel.appendedLines(base: '- A\n', server: '- A\n- B'), '- B');
      expect(AgentDetailsViewModel.appendedLines(base: '- A', server: '- A'), '');
      expect(AgentDetailsViewModel.appendedLines(base: '- A', server: '- X\n- B'), isNull);
    });

    test('the test chat sends what came before, and keeps the reply', () async {
      final agents = _Agents(rows: [sara]);
      final chat = AgentTestChatViewModel(agents: agents, agentId: 'a-1');
      addTearDown(chat.dispose);

      chat.input.text = 'Salam';
      await chat.send();
      chat.input.text = 'Prix ?';
      await chat.send();

      expect(agents.testHistories[0], isEmpty);
      expect(agents.testHistories[1].map((t) => t.content), ['Salam', 'Réponse à Salam']);
      expect(chat.turns.map((t) => t.content), ['Salam', 'Réponse à Salam', 'Prix ?', 'Réponse à Prix ?']);
    });

    test('a failed test message keeps the message and says why', () async {
      final chat = AgentTestChatViewModel(agents: _Agents(rows: [sara], testFails: true), agentId: 'a-1');
      addTearDown(chat.dispose);
      chat.input.text = 'Salam';
      await chat.send();
      expect(chat.turns.single.content, 'Salam');
      expect(chat.lastError, isNotNull);
    });
  });

  Future<void> pump(
    WidgetTester tester,
    Widget screen,
    _Agents agents, {
    Locale locale = const Locale('fr'),
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Provider<AgentRepository>.value(
        value: agents,
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

  group('on screen', () {
    testWidgets('the card carries the four actions and the pending badge', (tester) async {
      await pump(tester, const AgentsScreen(), _Agents(rows: [sara], pending: 3));
      final l10n = await L10n.delegate.load(const Locale('fr'));

      for (final label in [
        l10n.agentsActionInsights,
        l10n.agentsActionTest,
        l10n.agentsActionDetails,
        l10n.agentsActionDelete,
      ]) {
        expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
      }
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('delete asks first, then leaves the empty state', (tester) async {
      final agents = _Agents(rows: [sara]);
      await pump(tester, const AgentsScreen(), agents);
      final l10n = await L10n.delegate.load(const Locale('fr'));

      await tester.tap(find.bySemanticsLabel(l10n.agentsActionDelete));
      await tester.pumpAndSettle();
      expect(find.text(l10n.agentsDeleteTitle), findsOneWidget);

      // Cancel changes nothing.
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      expect(agents.deleted, isEmpty);

      await tester.tap(find.bySemanticsLabel(l10n.agentsActionDelete));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.agentsDeleteConfirm));
      await tester.pumpAndSettle();

      expect(agents.deleted, ['a-1']);
      expect(find.text(l10n.agentsEmptyTitle), findsOneWidget);
    });

    testWidgets('the alert icon opens the pending issues', (tester) async {
      await pump(tester, const AgentsScreen(), _Agents(rows: [sara], pending: 1, insightRows: [pendingInsight]));
      final l10n = await L10n.delegate.load(const Locale('fr'));

      await tester.tap(find.bySemanticsLabel(l10n.agentsActionInsights));
      await tester.pumpAndSettle();

      expect(find.text('Vous livrez en France ?'), findsOneWidget);
      expect(find.text(l10n.agentsInsightResolve), findsOneWidget);
      expect(find.text(l10n.agentsInsightDismiss), findsOneWidget);
    });

    testWidgets('details show the KPIs and save edited instructions', (tester) async {
      final agents = _Agents(rows: [sara], pending: 2);
      await pump(tester, const AgentDetailsScreen(agentId: 'a-1'), agents);
      final l10n = await L10n.delegate.load(const Locale('fr'));

      // The KPI tile sets its label in capitals.
      expect(find.text(l10n.agentsDetailsConversations.toUpperCase()), findsOneWidget);
      expect(find.text('- Toujours vouvoyer'), findsOneWidget);

      await tester.ensureVisible(find.text(l10n.agentsDetailsEdit));
      await tester.tap(find.text(l10n.agentsDetailsEdit));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '- Vouvoyer\n- Livrer partout');
      await tester.ensureVisible(find.text(l10n.agentsDetailsSave));
      await tester.tap(find.text(l10n.agentsDetailsSave));
      await tester.pumpAndSettle();

      expect(agents.savedInstructions, ['- Vouvoyer\n- Livrer partout']);
    });

    testWidgets('the test chat shows the reply', (tester) async {
      await pump(tester, const AgentTestChatScreen(agentId: 'a-1', agent: sara), _Agents(rows: [sara]));
      final l10n = await L10n.delegate.load(const Locale('fr'));

      expect(find.text(l10n.agentsTestTitle('Sara')), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Salam');
      // One frame for the send button to see the typed text and enable itself.
      await tester.pump();
      await tester.tap(find.text(l10n.agentsTestSend));
      await tester.pumpAndSettle();

      expect(find.text('Salam'), findsOneWidget);
      expect(find.text('Réponse à Salam'), findsOneWidget);
    });

    const sizes = {'320x640': Size(320, 640), '411x914': Size(411, 914)};
    for (final language in AppLanguage.values) {
      for (final size in sizes.entries) {
        testWidgets('card with actions, details and chat in ${language.code} at ${size.key}', (tester) async {
          final agents = _Agents(rows: [sara], pending: 12, insightRows: [pendingInsight]);
          await pump(tester, const AgentsScreen(), agents, locale: language.locale, size: size.value);
          expect(tester.takeException(), isNull);
          await pump(tester, const AgentDetailsScreen(agentId: 'a-1'), agents, locale: language.locale, size: size.value);
          expect(tester.takeException(), isNull);
          await pump(tester, const AgentTestChatScreen(agentId: 'a-1', agent: sara), agents, locale: language.locale, size: size.value);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}

class _Agents extends AgentRepository {
  _Agents({
    this.rows = const [],
    this.pending = 0,
    List<AgentInsight> insightRows = const [],
    this.deleteFails = false,
    this.testFails = false,
  })  : _insights = List.of(insightRows),
        super(api: apiForTest());

  final List<Agent> rows;
  final int pending;
  final bool deleteFails;
  final bool testFails;
  final List<AgentInsight> _insights;

  final deleted = <String>[];
  final resolutions = <({String id, bool dismiss, String? instruction})>[];
  final testHistories = <List<ChatTurn>>[];
  final savedInstructions = <String>[];

  @override
  Future<Result<List<Agent>>> list() async => Result.success(rows);

  /// The instructions the backend holds now, when something other than this
  /// phone changed them — the web resolving an insight, say. Null: as in [rows].
  String? serverInstructions;

  @override
  Future<Result<Agent>> get(String agentId) async {
    final current = rows.firstWhere((a) => a.id == agentId);
    final server = serverInstructions;
    if (server == null) return Result.success(current);
    return Result.success(
      Agent(
        id: current.id,
        name: current.name,
        personality: current.personality,
        customInstructions: server,
        aiModel: current.aiModel,
      ),
    );
  }

  @override
  Future<Result<AgentMetrics>> metrics(String agentId) async => Result.success(
        AgentMetrics(
          conversationCount: 42,
          totalMessages: 610,
          messagesFromCustomers: 318,
          messagesFromAgent: 292,
          ordersCreated: 9,
          insightsPending: pending,
          insightsResolved: 11,
          lastActiveDate: DateTime(2026, 9, 2),
        ),
      );

  @override
  Future<Result<List<AgentInsight>>> insights(String agentId, {InsightStatus? status}) async =>
      Result.success(_insights.where((i) => status == null || i.status == status).toList());

  @override
  Future<Result<void>> resolveInsight({required String insightId, required bool dismiss, String? newInstruction}) async {
    resolutions.add((id: insightId, dismiss: dismiss, instruction: newInstruction));
    _insights.removeWhere((i) => i.id == insightId);
    return const Result.success(null);
  }

  @override
  Future<Result<String>> test({required String agentId, required String message, required List<ChatTurn> history}) async {
    testHistories.add(history);
    return testFails
        ? const Result.failure(ServerException('sandbox down'))
        : Result.success('Réponse à $message');
  }

  @override
  Future<Result<Agent>> updateInstructions({required String agentId, required String instructions}) async {
    savedInstructions.add(instructions);
    serverInstructions = instructions;
    final current = rows.firstWhere((a) => a.id == agentId);
    return Result.success(
      Agent(
        id: current.id,
        name: current.name,
        personality: current.personality,
        customInstructions: instructions,
        aiModel: current.aiModel,
      ),
    );
  }

  @override
  Future<Result<void>> delete(String agentId) async {
    if (deleteFails) return const Result.failure(ServerException('Failed to delete agent'));
    deleted.add(agentId);
    return const Result.success(null);
  }
}

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      handler(options);

  @override
  void close({bool force = false}) {}
}
