import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../models/agent.dart';
import '../models/agent_draft.dart';
import '../models/agent_insight.dart';
import '../models/agent_preset.dart';
import '../models/ai_provider.dart';

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
    AgentPreset? preset,
  }) {
    return _api.post<Agent>(
      Api.agents,
      body: {
        'name': name.trim(),
        'personality': personality.wireName,
        if (customInstructions != null && customInstructions.trim().isNotEmpty)
          'customInstructions': customInstructions.trim(),
        if (pageIds.isNotEmpty) 'pageIds': pageIds,
        // A ready-made agent carries the rest of its configuration — model,
        // voice and vision, delay, product template, closing and hand-off.
        if (preset != null) ...preset.configuration,
      },
      parse: _parseAgent,
    );
  }

  /// `POST /api/user-stock/agents` with the full form — `15b — Partir de
  /// zéro`, which mirrors the web's agent form section for section.
  Future<Result<Agent>> createFromDraft(AgentDraft draft) {
    return _api.post<Agent>(Api.agents, body: draft.toJson(), parse: _parseAgent);
  }

  /// `GET /api/user-stock/ai-providers/active` → `{ providers }`: the models
  /// the administrator has switched on, for the form's model picker.
  Future<Result<List<AiProvider>>> activeProviders() {
    return _api.get<List<AiProvider>>(
      Api.aiProvidersActive,
      parse: (json) => Json.list((json as Map<String, dynamic>)['providers'], AiProvider.fromJson),
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

  /// `PUT /api/user-stock/agents/:id` with `isActive` → `{ agent }`.
  ///
  /// `false` pauses the agent: per the live docs the webhook stops
  /// auto-replying on its pages, and it can still be tested. A partial update,
  /// so nothing else on the agent changes.
  Future<Result<Agent>> setActive({
    required String agentId,
    required bool isActive,
  }) {
    return _api.put<Agent>(
      Api.agent(agentId),
      body: {'isActive': isActive},
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

  /// `GET /api/user-stock/agents/:id` → `{ agent }`. `404` for someone
  /// else's agent.
  Future<Result<Agent>> get(String agentId) {
    return _api.get<Agent>(Api.agent(agentId), parse: _parseAgent);
  }

  /// `GET /api/user-stock/agents/:id/metrics` → `{ metrics }`, computed live.
  Future<Result<AgentMetrics>> metrics(String agentId) {
    return _api.get<AgentMetrics>(
      Api.agentMetrics(agentId),
      parse: (json) {
        final metrics = (json as Map<String, dynamic>)['metrics'];
        return AgentMetrics.fromJson(
          metrics is Map<String, dynamic> ? metrics : const {},
        );
      },
    );
  }

  /// `GET /api/user-stock/agents/:id/insights` → `{ insights }`, newest first.
  ///
  /// [status] null lists every insight, whatever its state.
  Future<Result<List<AgentInsight>>> insights(
    String agentId, {
    InsightStatus? status,
  }) {
    return _api.get<List<AgentInsight>>(
      Api.agentInsights(agentId),
      query: {if (status != null) 'status': status.wireName},
      parse: (json) {
        final rows = (json as Map<String, dynamic>)['insights'];
        if (rows is! List) return const <AgentInsight>[];
        return rows
            .whereType<Map<String, dynamic>>()
            .map(AgentInsight.fromJson)
            .toList(growable: false);
      },
    );
  }

  /// `PUT /api/user-stock/agents/insights/:id`.
  ///
  /// Resolving with a non-blank [newInstruction] appends it, as a bullet, to
  /// the agent's custom instructions — the agent learns the answer. Dismissing
  /// ignores it.
  Future<Result<void>> resolveInsight({
    required String insightId,
    required bool dismiss,
    String? newInstruction,
  }) {
    final instruction = newInstruction?.trim() ?? '';
    return _api.put<void>(
      Api.agentInsight(insightId),
      body: {
        'action': dismiss ? 'dismiss' : 'resolve',
        if (!dismiss && instruction.isNotEmpty) 'newInstruction': instruction,
      },
    );
  }

  /// `POST /api/user-stock/agents/:id/test` → `{ response }`.
  ///
  /// A dry run: no credits, no real orders, nothing stored — so [history] is
  /// the whole conversation so far, sent every time.
  Future<Result<String>> test({
    required String agentId,
    required String message,
    required List<ChatTurn> history,
  }) {
    return _api.post<String>(
      Api.agentTest(agentId),
      body: {
        'message': message,
        'history': [for (final turn in history) turn.toJson()],
      },
      parse: (json) => Json.str((json as Map<String, dynamic>)['response']),
    );
  }

  /// `PUT /api/user-stock/agents/:id` with only `customInstructions`.
  Future<Result<Agent>> updateInstructions({
    required String agentId,
    required String instructions,
  }) {
    return _api.put<Agent>(
      Api.agent(agentId),
      body: {'customInstructions': instructions},
      parse: _parseAgent,
    );
  }

  /// `DELETE /api/user-stock/agents/:id`. Its page links and insights go with
  /// it; conversations stay. The merchant can create a new agent afterwards.
  Future<Result<void>> delete(String agentId) {
    return _api.delete<void>(Api.agent(agentId));
  }

  static Agent _parseAgent(dynamic json) {
    final map = json as Map<String, dynamic>;
    final agent = map['agent'];
    return Agent.fromJson(agent is Map<String, dynamic> ? agent : map);
  }
}
