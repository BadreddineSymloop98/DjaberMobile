import '../../core/error/app_exception.dart';
import '../../data/models/agent.dart';
import '../../data/repositories/agent_repository.dart';
import 'base_view_model.dart';

/// `14 — Agents IA`: the merchant's agents — pausing, resuming, deleting.
///
/// **A list**, as the frame and the web draw it. How many agents a merchant
/// may hold is their plan's limit, enforced by the backend when one is
/// created, so nothing here assumes there is only one. No agent at all is a
/// real state — deleted from the web, say — and is what the screen's empty
/// state is for.
class AgentsViewModel extends BaseViewModel {
  AgentsViewModel({required AgentRepository agents}) : _agents = agents;

  final AgentRepository _agents;

  List<Agent> _list = const [];

  /// Newest first, as the backend lists them.
  List<Agent> get agents => _list;

  bool _loadedOnce = false;

  /// True until the first answer — success or failure — has arrived, so the
  /// screen shows a spinner rather than a flash of the empty state.
  bool get isFirstLoad => !_loadedOnce;

  String? _busyId;

  /// The agent being paused, resumed or deleted. One change at a time: while
  /// it runs, the other cards wait.
  String? get busyAgentId => _busyId;

  AppException? _toggleError;

  /// Why the last pause or resume failed. Kept apart from [error], which is
  /// the load's: a failed toggle must not replace the cards with an error.
  AppException? get toggleError => _toggleError;

  /// Fetches the agents. Silent after the first load, so pull-to-refresh
  /// keeps the cards on screen.
  Future<void> load() async {
    await run(
      _agents.list,
      onSuccess: (rows) => _list = List.unmodifiable(rows),
      isEmpty: () => _list.isEmpty,
      silent: _loadedOnce,
      tag: 'agents',
    );
    _loadedOnce = true;
    safeNotify();
    await refreshMetrics();
  }

  Map<String, int> _pending = const {};

  /// Conversations this agent flagged and nobody has handled — the badge on
  /// its alert icon.
  int pendingFor(String agentId) => _pending[agentId] ?? 0;

  /// Re-reads every agent's pending count, in parallel. Quiet on failure: a
  /// missing badge is not worth an error over the cards, and a count that
  /// could not be re-read keeps its last value.
  Future<void> refreshMetrics() async {
    final current = _list;
    if (current.isEmpty) {
      _pending = const {};
      safeNotify();
      return;
    }
    final results = await Future.wait(current.map((a) => _agents.metrics(a.id)));
    if (isDisposed) return;
    final next = <String, int>{};
    for (var i = 0; i < current.length; i++) {
      final id = current[i].id;
      final count = results[i].valueOrNull?.insightsPending ?? _pending[id];
      if (count != null) next[id] = count;
    }
    _pending = next;
    safeNotify();
  }

  AppException? _deleteError;
  AppException? get deleteError => _deleteError;

  /// Deletes [agent]. True when it is gone; the last one gone leaves the
  /// screen on its empty state.
  Future<bool> deleteAgent(Agent agent) async {
    if (_busyId != null) return false;

    _busyId = agent.id;
    _deleteError = null;
    safeNotify();

    final result = await _agents.delete(agent.id);
    if (isDisposed) return false;

    _busyId = null;
    if (result.isFailure) {
      _deleteError = result.errorOrNull;
      safeNotify();
      return false;
    }
    _list = List.unmodifiable(_list.where((a) => a.id != agent.id));
    _pending = Map.of(_pending)..remove(agent.id);
    safeNotify();
    return true;
  }

  /// Pauses [agent] if active, resumes it if paused. Answers the agent as the
  /// backend now has it, or null when nothing changed.
  Future<Agent?> toggleActive(Agent agent) async {
    if (_busyId != null) return null;

    _busyId = agent.id;
    _toggleError = null;
    safeNotify();

    final result = await _agents.setActive(
      agentId: agent.id,
      isActive: !agent.isActive,
    );
    if (isDisposed) return null;

    _busyId = null;
    final updated = result.valueOrNull;
    if (updated != null) {
      _list = List.unmodifiable([
        for (final a in _list) a.id == updated.id ? updated : a,
      ]);
    } else {
      _toggleError = result.errorOrNull;
    }
    safeNotify();
    return updated;
  }
}
