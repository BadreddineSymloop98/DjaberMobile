import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/data/models/agent.dart';
import 'package:djaber_mobile/data/models/agent_insight.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/agents/agents_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_theme.dart';
import 'package:djaber_mobile/presentation/viewmodels/locale_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';

/// `14 — Agents IA`: the one agent, the empty state, and pausing.
void main() {
  // Shaped like `GET /api/user-stock/agents` in the live docs.
  final agentJson = <String, dynamic>{
    'id': 'a-1',
    'name': 'Sara',
    'description': 'Assistante de vente',
    'personality': 'friendly',
    'aiModel': 'gpt-4o-mini',
    'sellAllProducts': true,
    'isActive': true,
    'pages': [
      {
        'id': 'ap-1',
        'agentId': 'a-1',
        'pageId': 'p-1',
        'page': {
          'id': 'p-1',
          'pageName': 'Boutique Sara',
          'platform': 'facebook',
          'pageId': '1234567890',
          'isActive': true,
        },
      },
      {
        'id': 'ap-2',
        'agentId': 'a-1',
        'pageId': 'p-2',
        'page': {
          'id': 'p-2',
          'pageName': 'sara.shop',
          'platform': 'instagram',
          'pageId': '17841400000000000',
          'isActive': true,
        },
      },
    ],
    'products': [],
    '_count': {'pages': 2, 'products': 0},
  };

  Future<void> pump(
    WidgetTester tester,
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
                home: const AgentsScreen(),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the model', () {
    test('reads page names, platforms, the product count and the model', () {
      final agent = Agent.fromJson({
        ...agentJson,
        'sellAllProducts': false,
        '_count': {'pages': 2, 'products': 7},
      });

      expect(agent.pageIds, ['p-1', 'p-2']);
      expect(agent.pages.map((p) => p.name), ['Boutique Sara', 'sara.shop']);
      expect(agent.pages.last.isInstagram, isTrue);
      expect(agent.productCount, 7);
      expect(agent.aiModel, 'gpt-4o-mini');
    });
  });

  group('layout', () {
    const sizes = {'320x640': Size(320, 640), '411x914': Size(411, 914)};
    for (final language in AppLanguage.values) {
      for (final size in sizes.entries) {
        testWidgets('agent card in ${language.code} at ${size.key}',
            (tester) async {
          await pump(
            tester,
            _Agents(rows: [Agent.fromJson(agentJson)]),
            locale: language.locale,
            size: size.value,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('empty state in ${language.code} at ${size.key}',
            (tester) async {
          await pump(
            tester,
            _Agents(),
            locale: language.locale,
            size: size.value,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  testWidgets('shows the agent: status, stats and the pages it answers on',
      (tester) async {
    await pump(tester, _Agents(rows: [Agent.fromJson(agentJson)]));
    final l10n = await L10n.delegate.load(const Locale('fr'));

    expect(find.text('Sara'), findsOneWidget);
    expect(find.text(l10n.agentsActive.toUpperCase()), findsOneWidget);
    expect(find.text(l10n.agentsAllProducts), findsOneWidget);
    expect(find.text('gpt-4o-mini'), findsOneWidget);
    expect(find.text('Boutique Sara'), findsOneWidget);
    expect(find.text('sara.shop'), findsOneWidget);
    // With an agent, another is added from `Nouvel agent`, not the empty state.
    expect(find.text(l10n.agentsEmptyCta), findsNothing);
    expect(find.text(l10n.agentsNewTitle), findsOneWidget);
  });

  testWidgets('with no agent, says so and offers to create one',
      (tester) async {
    await pump(tester, _Agents());
    final l10n = await L10n.delegate.load(const Locale('fr'));

    expect(find.text(l10n.agentsEmptyTitle), findsOneWidget);
    expect(find.text(l10n.agentsEmptyCta), findsOneWidget);
  });

  testWidgets('every agent gets its card, and pausing one leaves the other',
      (tester) async {
    final karim = Agent.fromJson({
      ...agentJson,
      'id': 'a-2',
      'name': 'Karim',
      'pages': [],
      '_count': {'pages': 0, 'products': 0},
    });
    final agents = _Agents(rows: [Agent.fromJson(agentJson), karim]);
    await pump(tester, agents);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    expect(find.text('Sara'), findsOneWidget);
    await tester.scrollUntilVisible(find.text(l10n.agentsNewTitle), 200);
    expect(find.text('Karim'), findsOneWidget);
    expect(find.text(l10n.agentsNewTitle), findsOneWidget);

    await tester.tap(find.text(l10n.agentsPause).last);
    await tester.pumpAndSettle();

    expect(agents.toggles, [(agentId: 'a-2', isActive: false)]);
    expect(find.text(l10n.agentsResume), findsOneWidget);
  });

  testWidgets('a failed load offers a retry that recovers', (tester) async {
    final agents = _Agents(rows: [Agent.fromJson(agentJson)], failFirst: true);
    await pump(tester, agents);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    expect(find.text(l10n.commonRetry), findsOneWidget);
    expect(find.text('Sara'), findsNothing);

    await tester.tap(find.text(l10n.commonRetry));
    await tester.pumpAndSettle();

    expect(find.text('Sara'), findsOneWidget);
  });

  testWidgets('pausing sends isActive false and shows the paused state',
      (tester) async {
    final agents = _Agents(rows: [Agent.fromJson(agentJson)]);
    await pump(tester, agents);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    await tester.ensureVisible(find.text(l10n.agentsPause));
    await tester.tap(find.text(l10n.agentsPause));
    await tester.pumpAndSettle();

    expect(agents.toggles, [(agentId: 'a-1', isActive: false)]);
    expect(find.text(l10n.agentsInactive.toUpperCase()), findsOneWidget);
    expect(find.text(l10n.agentsResume), findsOneWidget);
  });

  testWidgets('a failed pause keeps the card as it was', (tester) async {
    final agents =
        _Agents(rows: [Agent.fromJson(agentJson)], toggleFails: true);
    await pump(tester, agents);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    await tester.ensureVisible(find.text(l10n.agentsPause));
    await tester.tap(find.text(l10n.agentsPause));
    await tester.pumpAndSettle();

    expect(find.text(l10n.agentsActive.toUpperCase()), findsOneWidget);
    expect(find.text(l10n.agentsPause), findsOneWidget);
  });
}

class _Agents extends AgentRepository {
  _Agents({
    this.rows = const [],
    this.failFirst = false,
    this.toggleFails = false,
  }) : super(api: apiForTest());

  final List<Agent> rows;
  final bool failFirst;
  final bool toggleFails;
  final toggles = <({String agentId, bool isActive})>[];
  int _lists = 0;

  @override
  Future<Result<List<Agent>>> list() async {
    _lists++;
    if (failFirst && _lists == 1) {
      return const Result.failure(ServerException('unreachable'));
    }
    return Result.success(rows);
  }

  @override
  Future<Result<AgentMetrics>> metrics(String agentId) async =>
      const Result.success(AgentMetrics());

  @override
  Future<Result<Agent>> setActive({
    required String agentId,
    required bool isActive,
  }) async {
    toggles.add((agentId: agentId, isActive: isActive));
    if (toggleFails) {
      return const Result.failure(ServerException('Failed to update agent'));
    }
    final current = rows.firstWhere((a) => a.id == agentId);
    return Result.success(
      Agent(
        id: current.id,
        name: current.name,
        description: current.description,
        personality: current.personality,
        sellAllProducts: current.sellAllProducts,
        isActive: isActive,
        pageIds: current.pageIds,
        pages: current.pages,
        productCount: current.productCount,
        aiModel: current.aiModel,
      ),
    );
  }
}
