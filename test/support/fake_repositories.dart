import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/core/error/result.dart';
import 'package:djaber_mobile/data/models/agent.dart';
import 'package:djaber_mobile/data/models/connected_page.dart';
import 'package:djaber_mobile/data/models/conversation.dart';
import 'package:djaber_mobile/data/models/dashboard_stats.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/dashboard_repository.dart';
import 'package:djaber_mobile/data/repositories/page_repository.dart';

import 'auth_host.dart';

/// Repositories that answer from memory instead of the network.
///
/// Subclasses of the real ones rather than interfaces: the screen and the view
/// model depend on the concrete types, and overriding the three methods that
/// matter keeps the rest — the parsing, the endpoint constants — honest.
///
/// Each one can be told to fail, because a partial failure is a state
/// `09 — Accueil` is specifically built to survive: one dead endpoint must not
/// take the whole screen with it.
class FakeDashboardRepository extends DashboardRepository {
  FakeDashboardRepository({
    this.stats0 = const DashboardStats(),
    this.sales0 = const SalesStats(),
    this.conversations = const {},
    this.statsFails = false,
    this.salesFails = false,
  }) : super(api: apiForTest());

  final DashboardStats stats0;
  final SalesStats sales0;

  /// Keyed by our own page row id, as [DashboardRepository.conversationsFor]
  /// takes it.
  final Map<String, List<Conversation>> conversations;

  final bool statsFails;
  final bool salesFails;

  /// Page ids asked for, in order — so a test can prove the queue fans out
  /// across every connected Page rather than only the first.
  final asked = <String>[];

  @override
  Future<Result<DashboardStats>> stats() async => statsFails
      ? const Result.failure(ServerException('unreachable'))
      : Result.success(stats0);

  @override
  Future<Result<SalesStats>> salesStats() async => salesFails
      ? const Result.failure(ServerException('unreachable'))
      : Result.success(sales0);

  @override
  Future<Result<List<Conversation>>> conversationsFor(String pageId) async {
    asked.add(pageId);
    final rows = conversations[pageId];
    return rows == null
        ? const Result.failure(ServerException('unreachable'))
        : Result.success(rows);
  }
}

class FakePageRepository extends PageRepository {
  FakePageRepository({this.pages = const [], this.fails = false})
      : super(api: apiForTest());

  final List<ConnectedPage> pages;
  final bool fails;

  @override
  Future<Result<List<ConnectedPage>>> list() async => fails
      ? const Result.failure(ServerException('unreachable'))
      : Result.success(pages);
}

class FakeAgentRepository extends AgentRepository {
  FakeAgentRepository({this.agents = const [], this.fails = false})
      : super(api: apiForTest());

  final List<Agent> agents;
  final bool fails;

  @override
  Future<Result<List<Agent>>> list() async =>
      fails ? const Result.failure(ServerException('unreachable')) : Result.success(agents);
}
