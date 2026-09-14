import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../models/agent.dart';

/// The merchant's AI agent, against `/api/user-stock/agents`.
class AgentRepository {
  AgentRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `POST /api/user-stock/agents` → `{ agent }`.
  ///
  /// Only `name` is required; everything else has a server default, which is
  /// what lets the tutorial ask for three fields and still produce a working
  /// agent.
  ///
  /// > **One agent per user is enforced.** The controller counts first and
  /// > answers `400 { error: 'Agent limit reached', message: 'You already
  /// > have an agent…' }`. A merchant who already has one cannot create a
  /// > second, so a tutorial re-run must expect this.
  ///
  /// [pageIds] are **our** page row ids, not Meta's. Passing a page that
  /// belongs to someone else is a 400.
  Future<Result<Agent>> create({
    required String name,
    required AgentPersonality personality,
    String? customInstructions,
    List<String> pageIds = const [],
  }) {
    return _api.post<Agent>(
      Api.agents,
      body: {
        'name': name.trim(),
        'personality': personality.wireName,
        if (customInstructions != null && customInstructions.trim().isNotEmpty)
          'customInstructions': customInstructions.trim(),
        if (pageIds.isNotEmpty) 'pageIds': pageIds,
      },
      parse: _parseAgent,
    );
  }

  /// `PUT /api/user-stock/agents/:id` with `pageIds`.
  ///
  /// How a Page connected *after* the agent gets attached to it — the
  /// tutorial's order, since the agent is step 3 and the page is step 4. The
  /// controller replaces the whole set rather than appending, so callers pass
  /// every page the agent should answer on, not just the new one.
  Future<Result<Agent>> setPages({
    required String agentId,
    required List<String> pageIds,
  }) {
    return _api.put<Agent>(
      Api.agent(agentId),
      body: {'pageIds': pageIds},
      parse: _parseAgent,
    );
  }

  /// `GET /api/user-stock/agents` → `{ agents: [...] }`.
  Future<Result<List<Agent>>> list() {
    return _api.get<List<Agent>>(
      Api.agents,
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final rows = map['agents'];
        if (rows is! List) return const <Agent>[];
        return rows
            .whereType<Map<String, dynamic>>()
            .map(Agent.fromJson)
            .toList(growable: false);
      },
    );
  }

  static Agent _parseAgent(dynamic json) {
    final map = json as Map<String, dynamic>;
    final agent = map['agent'];
    return Agent.fromJson(agent is Map<String, dynamic> ? agent : map);
  }
}
