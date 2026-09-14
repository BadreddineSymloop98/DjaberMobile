import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../data/models/agent_insight.dart';
import '../../data/repositories/agent_repository.dart';
import 'base_view_model.dart';

/// An agent's insights — the conversations it flagged — and handling them.
///
/// Shared by the pending-issues sheet on `14 — Agents IA` and the insights
/// section of the agent's details, which is why the filter is a parameter
/// rather than fixed to pending.
class AgentInsightsViewModel extends BaseViewModel {
  AgentInsightsViewModel({
    required AgentRepository agents,
    required this.agentId,
    InsightStatus? status = InsightStatus.pending,
  })  : _agents = agents,
        _status = status;

  final AgentRepository _agents;
  final String agentId;

  InsightStatus? _status;

  /// The filter. Null lists every insight.
  InsightStatus? get status => _status;

  List<AgentInsight> _items = const [];
  List<AgentInsight> get items => _items;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  String? _resolvingId;

  /// The insight whose instruction field is open.
  String? get resolvingId => _resolvingId;

  String? _savingId;

  /// The insight being resolved or dismissed right now.
  String? get savingId => _savingId;

  AppException? _actionError;
  AppException? get actionError => _actionError;

  /// The instruction typed while resolving — appended to the agent's own
  /// instructions by the backend, so it learns the answer.
  final instructionController = TextEditingController();

  Future<void> load() async {
    await run(
      () => _agents.insights(agentId, status: _status),
      onSuccess: (rows) => _items = rows,
      isEmpty: () => _items.isEmpty,
      silent: _loadedOnce,
      tag: 'agentInsights',
    );
    _loadedOnce = true;
    safeNotify();
  }

  Future<void> setFilter(InsightStatus? status) async {
    if (_status == status && _loadedOnce) return;
    _status = status;
    _items = const [];
    _loadedOnce = false;
    _resolvingId = null;
    safeNotify();
    await load();
  }

  void startResolving(String insightId) {
    _resolvingId = insightId;
    instructionController.clear();
    safeNotify();
  }

  void cancelResolving() {
    _resolvingId = null;
    instructionController.clear();
    safeNotify();
  }

  /// Resolves [insightId], with the typed instruction if there is one.
  Future<bool> resolve(String insightId) =>
      _act(insightId, dismiss: false, instruction: instructionController.text);

  Future<bool> dismiss(String insightId) => _act(insightId, dismiss: true);

  Future<bool> _act(
    String insightId, {
    required bool dismiss,
    String? instruction,
  }) async {
    if (_savingId != null) return false;
    _savingId = insightId;
    _actionError = null;
    safeNotify();

    final result = await _agents.resolveInsight(
      insightId: insightId,
      dismiss: dismiss,
      newInstruction: instruction,
    );
    if (isDisposed) return false;

    _savingId = null;
    if (result.isFailure) {
      _actionError = result.errorOrNull;
      safeNotify();
      return false;
    }
    _resolvingId = null;
    instructionController.clear();
    await load();
    return true;
  }

  @override
  void dispose() {
    instructionController.dispose();
    super.dispose();
  }
}
