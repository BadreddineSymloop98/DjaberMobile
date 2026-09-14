import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../data/models/agent_insight.dart';
import '../../data/repositories/agent_repository.dart';
import 'base_view_model.dart';
import 'form_draft_store.dart';

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
    FormDraftStore? drafts,
    String? draftKey,
  })  : _agents = agents,
        _status = status,
        _drafts = draftKey == null ? null : drafts,
        _draftKey = draftKey ?? '' {
    _pending = _drafts?.read(_draftKey) ?? const {};
    instructionController.addListener(_saveDraft);
  }

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

  // ---- Draft ----
  //
  // On the details screen, leaving the app replays the splash and rebuilds the
  // screen: an open Résoudre field came back closed and empty. Which insight
  // was being resolved, and the instruction typed, are kept in the app's draft
  // store and put back once the list has loaded. The pending-issues sheet on
  // `14` passes no key, so it keeps nothing — the sheet itself does not
  // survive the splash.

  final FormDraftStore? _drafts;
  final String _draftKey;
  Map<String, String> _pending = const {};

  void _saveDraft() {
    final id = _resolvingId;
    _drafts?.write(
      _draftKey,
      id == null ? const {} : {'resolvingId': id, 'text': instructionController.text},
    );
  }

  void _restoreDraft() {
    final saved = _pending;
    _pending = const {};
    final id = saved['resolvingId'];
    // Only if that insight is still on the list — it may have been handled
    // on the web meanwhile.
    if (id == null || !_items.any((insight) => insight.id == id)) {
      _saveDraft();
      return;
    }
    _resolvingId = id;
    instructionController.text = saved['text'] ?? '';
    _saveDraft();
  }

  Future<void> load() async {
    await run(
      () => _agents.insights(agentId, status: _status),
      onSuccess: (rows) => _items = rows,
      isEmpty: () => _items.isEmpty,
      silent: _loadedOnce,
      tag: 'agentInsights',
    );
    if (_pending.isNotEmpty) _restoreDraft();
    _loadedOnce = true;
    safeNotify();
  }

  Future<void> setFilter(InsightStatus? status) async {
    if (_status == status && _loadedOnce) return;
    _status = status;
    _items = const [];
    _loadedOnce = false;
    _resolvingId = null;
    _saveDraft();
    safeNotify();
    await load();
  }

  void startResolving(String insightId) {
    _resolvingId = insightId;
    instructionController.clear();
    _saveDraft();
    safeNotify();
  }

  void cancelResolving() {
    _resolvingId = null;
    instructionController.clear();
    _saveDraft();
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
    _saveDraft();
    await load();
    return true;
  }

  @override
  void dispose() {
    // Kept only if the splash is what took the screen.
    if (_drafts != null) _drafts.release(_draftKey);
    instructionController.dispose();
    super.dispose();
  }
}
