import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../data/models/agent.dart';
import '../../data/models/agent_insight.dart';
import '../../data/repositories/agent_repository.dart';
import 'agent_insights_view_model.dart';
import 'base_view_model.dart';

/// What saving the instructions came to.
enum InstructionsSaveOutcome {
  saved,

  /// Saved, with lines the web appended while the merchant was editing kept
  /// at the end.
  savedWithWebChanges,

  /// Not saved: the instructions were rewritten elsewhere in a way that
  /// cannot be combined with the edit. [AgentDetailsViewModel.conflict] holds
  /// the newer text, and the merchant chooses.
  conflict,
  failed,
}

/// The agent's details: KPIs, its insights, and its custom instructions —
/// the web's `/dashboard/agents/{id}`.
class AgentDetailsViewModel extends BaseViewModel {
  AgentDetailsViewModel({
    required AgentRepository agents,
    required this.agentId,
  })  : _agents = agents,
        insights = AgentInsightsViewModel(agents: agents, agentId: agentId);

  final AgentRepository _agents;
  final String agentId;

  /// Pending by default, like the web.
  final AgentInsightsViewModel insights;

  Agent? _agent;
  Agent? get agent => _agent;

  AgentMetrics? _metrics;
  AgentMetrics? get metrics => _metrics;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  bool _editing = false;
  bool get isEditing => _editing;

  bool _saving = false;
  bool get isSaving => _saving;

  AppException? _saveError;
  AppException? get saveError => _saveError;

  final instructions = TextEditingController();

  /// The instructions the edit started from.
  ///
  /// **Why it is kept.** Saving sends the whole text, and the backend replaces
  /// what it holds. Meanwhile the web can change the same field — resolving an
  /// insight with an instruction appends `\n- <text>` to it (live docs,
  /// `PUT /agents/insights/{id}`). Without knowing what the edit was based on,
  /// a save from the phone silently erased what the web had just taught the
  /// agent. Comparing the server's current text with this one tells an append
  /// (kept) from a rewrite (the merchant decides).
  String _base = '';

  String? _conflict;

  /// The server's newer instructions, when a save found them rewritten.
  String? get conflict => _conflict;

  Future<void> load() async {
    await run(
      () => _agents.get(agentId),
      onSuccess: (agent) => _agent = agent,
      silent: _loadedOnce,
      tag: 'agentDetails',
    );
    await _loadMetrics();
    _loadedOnce = true;
    safeNotify();
    await insights.load();
  }

  Future<void> _loadMetrics() async {
    final result = await _agents.metrics(agentId);
    if (isDisposed) return;
    _metrics = result.valueOrNull ?? _metrics;
  }

  /// After an insight is resolved or dismissed: the counts moved, and a
  /// resolve with an instruction changed the agent's instructions too.
  Future<void> refreshAfterInsight() async {
    final result = await _agents.get(agentId);
    if (isDisposed) return;
    _agent = result.valueOrNull ?? _agent;
    await _loadMetrics();
    safeNotify();
  }

  /// Opens the editor on what the screen shows, then checks the server: the
  /// screen may have been open for a while. Newer text replaces the field only
  /// while the merchant has not typed anything yet.
  void startEditing() {
    _base = _agent?.customInstructions ?? '';
    instructions.text = _base;
    _editing = true;
    _saveError = null;
    _conflict = null;
    safeNotify();
    _catchUp();
  }

  Future<void> _catchUp() async {
    final result = await _agents.get(agentId);
    final latest = result.valueOrNull;
    if (isDisposed || !_editing || latest == null) return;
    _agent = latest;
    final server = latest.customInstructions ?? '';
    if (server != _base && instructions.text == _base) {
      _base = server;
      instructions.text = server;
    }
    safeNotify();
  }

  void cancelEditing() {
    _editing = false;
    _saveError = null;
    _conflict = null;
    safeNotify();
  }

  /// Saves the edit without losing what changed on the server since it began.
  ///
  /// Reads the agent first. Unchanged: the edit is saved. Only appended to —
  /// the web's insight resolve — the appended lines are added after the edit
  /// and saved together. Rewritten: nothing is saved; see [conflict].
  /// [overwrite] skips the check — the merchant chose their version.
  Future<InstructionsSaveOutcome> saveInstructions({bool overwrite = false}) async {
    if (_saving) return InstructionsSaveOutcome.failed;
    _saving = true;
    _saveError = null;
    safeNotify();

    var text = instructions.text.trim();
    var merged = false;

    if (!overwrite) {
      final latest = await _agents.get(agentId);
      if (isDisposed) return InstructionsSaveOutcome.failed;
      final current = latest.valueOrNull;
      if (current == null) {
        _saving = false;
        _saveError = latest.errorOrNull;
        safeNotify();
        return InstructionsSaveOutcome.failed;
      }
      _agent = current;
      final server = current.customInstructions ?? '';
      if (server.trim() != _base.trim()) {
        final added = appendedLines(base: _base, server: server);
        if (added == null) {
          _saving = false;
          _conflict = server;
          safeNotify();
          return InstructionsSaveOutcome.conflict;
        }
        if (added.isNotEmpty && !text.contains(added)) {
          text = text.isEmpty ? added : '$text\n$added';
          merged = true;
        }
      }
    }

    final result = await _agents.updateInstructions(agentId: agentId, instructions: text);
    if (isDisposed) return InstructionsSaveOutcome.failed;

    _saving = false;
    final updated = result.valueOrNull;
    if (updated == null) {
      _saveError = result.errorOrNull;
      safeNotify();
      return InstructionsSaveOutcome.failed;
    }
    _agent = updated;
    _editing = false;
    _conflict = null;
    safeNotify();
    return merged ? InstructionsSaveOutcome.savedWithWebChanges : InstructionsSaveOutcome.saved;
  }

  /// Takes the newer instructions into the editor instead of the edit, and
  /// bases the next save on them.
  void useLatest() {
    final server = _conflict;
    if (server == null) return;
    _base = server;
    instructions.text = server;
    _conflict = null;
    safeNotify();
  }

  /// What [server] added after [base], trimmed — empty when nothing was
  /// added; null when [server] no longer starts with [base], meaning the text
  /// was rewritten rather than appended to.
  static String? appendedLines({required String base, required String server}) {
    for (final start in [base, base.trimRight()]) {
      if (server.startsWith(start)) return server.substring(start.length).trim();
    }
    return null;
  }

  @override
  void dispose() {
    insights.dispose();
    instructions.dispose();
    super.dispose();
  }
}
