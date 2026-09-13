import 'dart:math' as math;

import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/data/models/agent.dart';
import 'package:djaber_mobile/data/models/connected_page.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/page_repository.dart';
import 'package:djaber_mobile/presentation/viewmodels/tutorial_connect_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_host.dart';

/// `T5` after Meta hands back: which page was just connected, and whether it
/// reached the agent.
void main() {
  ConnectedPage page(
    String id, {
    PagePlatform platform = PagePlatform.facebook,
    String name = 'Boutique',
    int day = 1,
  }) =>
      ConnectedPage(
        id: id,
        platform: platform,
        pageId: 'meta-$id',
        pageName: name,
        createdAt: DateTime(2026, 9, day),
      );

  const facebookSaved = OAuthCallbackReport(succeeded: true, pageCount: 1);

  Future<TutorialConnectViewModel> started(
    _Pages pages, {
    _Agents? agents,
    PagePlatform platform = PagePlatform.facebook,
  }) async {
    final model = TutorialConnectViewModel(
      pages: pages,
      agents: agents ?? _Agents(),
    );
    addTearDown(model.dispose);
    await model.startConnect(platform);
    return model;
  }

  test('a connection that saved nothing new is not announced with an old page',
      () async {
    // The bug: with nothing new in the list, the newest *existing* page used
    // to be handed back as the one just connected.
    final before = [page('p-1', day: 1), page('p-2', day: 2)];
    final agents = _Agents();
    final model = await started(_Pages([before, before]), agents: agents);

    final connected = await model.finishConnect(
      platform: PagePlatform.facebook,
      report: facebookSaved,
      agentId: 'a-1',
    );

    expect(connected, isNull);
    expect(model.nothingNew, isTrue);
    expect(agents.linked, isEmpty, reason: 'nothing to link');
  });

  test('nor when the callback could not be read', () async {
    final before = [page('p-1')];
    final model = await started(_Pages([before, before]));

    final connected = await model.finishConnect(
      platform: PagePlatform.facebook,
      agentId: 'a-1',
    );

    expect(connected, isNull);
    expect(model.nothingNew, isTrue);
  });

  test('the page that was not there before is the one connected', () async {
    final old = page('p-1', day: 5);
    final fresh = page('p-2', name: 'Nouvelle', day: 1);
    final agents = _Agents();
    final model = await started(
      _Pages([
        [old],
        [old, fresh],
      ]),
      agents: agents,
    );

    final connected = await model.finishConnect(
      platform: PagePlatform.facebook,
      report: facebookSaved,
      agentId: 'a-1',
    );

    expect(connected?.id, 'p-2');
    expect(model.nothingNew, isFalse);
    // Every page, not just the new one: the backend replaces the whole set.
    expect(agents.linked.single.pageIds, ['p-1', 'p-2']);
  });

  test(
      'a Facebook grant names the Facebook page, not the Instagram account '
      'saved with it', () async {
    final facebook = page('fb-1', day: 1);
    final instagram =
        page('ig-1', platform: PagePlatform.instagram, name: 'sara', day: 2);
    final model = await started(
      _Pages([
        [],
        [facebook, instagram],
      ]),
    );

    final connected = await model.finishConnect(
      platform: PagePlatform.facebook,
      report: facebookSaved,
      agentId: 'a-1',
    );

    expect(connected?.id, 'fb-1');
  });

  test('reconnecting an Instagram account already listed is found by name',
      () async {
    final account =
        page('ig-1', platform: PagePlatform.instagram, name: 'boutique.sara');
    final model = await started(
      _Pages([
        [account],
        [account],
      ]),
      platform: PagePlatform.instagram,
    );

    final connected = await model.finishConnect(
      platform: PagePlatform.instagram,
      report: const OAuthCallbackReport(
        succeeded: true,
        username: 'boutique.sara',
      ),
      agentId: 'a-1',
    );

    expect(connected?.id, 'ig-1');
  });

  test(
      'reconnecting the only Facebook page, as the callback confirms, is that '
      'page', () async {
    final only = page('p-1');
    final model = await started(
      _Pages([
        [only],
        [only],
      ]),
    );

    final connected = await model.finishConnect(
      platform: PagePlatform.facebook,
      report: facebookSaved,
      agentId: 'a-1',
    );

    expect(connected?.id, 'p-1');
  });

  test('but not when the callback says no page was saved', () async {
    final only = page('p-1');
    final model = await started(
      _Pages([
        [only],
        [only],
      ]),
    );

    final connected = await model.finishConnect(
      platform: PagePlatform.facebook,
      report: const OAuthCallbackReport(succeeded: true, pageCount: 0),
      agentId: 'a-1',
    );

    expect(connected, isNull);
    expect(model.nothingNew, isTrue);
  });

  test('with no snapshot to diff against, the newest page is the guess',
      () async {
    final model = await started(
      _Pages([
        null,
        [page('p-1', day: 1), page('p-2', day: 9)],
      ]),
    );

    final connected = await model.finishConnect(
      platform: PagePlatform.facebook,
      agentId: 'a-1',
    );

    expect(connected?.id, 'p-2');
  });

  test('a failed link does not fail the step, but is reported', () async {
    final agents = _Agents(linkFails: true);
    final model = await started(
      _Pages([
        [],
        [page('p-1')],
      ]),
      agents: agents,
    );

    final connected = await model.finishConnect(
      platform: PagePlatform.facebook,
      report: facebookSaved,
      agentId: 'a-1',
    );

    expect(connected?.id, 'p-1');
    expect(model.linkFailed, isTrue);
  });

  test("with no agent recorded, the page goes to the account's one agent",
      () async {
    // `T4` moves on without recording an agent when the account already has
    // one — which used to leave the page linked to nothing, silently.
    final agents = _Agents(agents: [_agent('a-9')]);
    final model = await started(
      _Pages([
        [],
        [page('p-1')],
      ]),
      agents: agents,
    );

    await model.finishConnect(
      platform: PagePlatform.facebook,
      report: facebookSaved,
    );

    expect(agents.linked.single.agentId, 'a-9');
    expect(model.linkFailed, isFalse);
  });

  test('with no agent at all, the missing link is reported', () async {
    final model = await started(
      _Pages([
        [],
        [page('p-1')],
      ]),
    );

    final connected = await model.finishConnect(
      platform: PagePlatform.facebook,
      report: facebookSaved,
    );

    expect(connected?.id, 'p-1');
    expect(model.linkFailed, isTrue);
  });

  test('a backend failure is its own state, and a new attempt clears it',
      () async {
    final model = await started(_Pages([[]]));

    model.connectFailed('Failed to connect pages');
    expect(model.failed, isTrue);
    expect(model.wasDenied, isFalse);

    await model.startConnect(PagePlatform.facebook);
    expect(model.failed, isFalse);
  });
}

Agent _agent(String id) => Agent.fromJson({'id': id, 'name': 'Sara'});

/// Answers `list()` from a script, one answer per call; the last one repeats.
/// A null answer is a failed request.
class _Pages extends PageRepository {
  _Pages(this.answers) : super(api: apiForTest());

  final List<List<ConnectedPage>?> answers;
  int _calls = 0;

  @override
  Future<Result<List<ConnectedPage>>> list() async {
    final answer = answers[math.min(_calls, answers.length - 1)];
    _calls++;
    return answer == null
        ? const Result.failure(ServerException('unreachable'))
        : Result.success(answer);
  }

  @override
  Future<Result<String>> authUrlFor(PagePlatform platform) async =>
      const Result.success('https://www.facebook.com/v18.0/dialog/oauth');
}

class _Agents extends AgentRepository {
  _Agents({this.agents = const [], this.linkFails = false})
      : super(api: apiForTest());

  final List<Agent> agents;
  final bool linkFails;
  final linked = <({String agentId, List<String> pageIds})>[];

  @override
  Future<Result<List<Agent>>> list() async => Result.success(agents);

  @override
  Future<Result<Agent>> setPages({
    required String agentId,
    required List<String> pageIds,
  }) async {
    linked.add((agentId: agentId, pageIds: pageIds));
    return linkFails
        ? const Result.failure(
            ServerException('One or more pages are already assigned'),
          )
        : Result.success(_agent(agentId));
  }
}
