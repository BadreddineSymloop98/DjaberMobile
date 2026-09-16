import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../core/utils/logger.dart';
import '../../data/models/agent.dart';
import '../../data/models/connected_page.dart';
import '../../data/models/page_summary.dart';
import '../../data/repositories/agent_repository.dart';
import '../../data/repositories/page_repository.dart' show OAuthCallbackReport, PageRepository;
import 'base_view_model.dart';

/// The platform tabs over the cards.
enum PagesFilter { all, facebook, instagram }

/// What a granted connection came to.
enum PageConnectOutcome { connected, nothingNew }

/// `12 — Pages connectées`, and `13 — Connecter une page` when there are none:
/// the web's pages section (`/dashboard?section=pages`).
class PagesViewModel extends BaseViewModel {
  PagesViewModel({required PageRepository pages, required AgentRepository agents})
      : _pages = pages,
        _agents = agents;

  final PageRepository _pages;
  final AgentRepository _agents;

  /// Page id → the agent answering on it, from the agents list.
  ///
  /// **Why not the summary's `agent`.** The summary works its status out on
  /// its own — from the linked agent, or, with none linked, from legacy
  /// per-page AI settings — so a card could say *IA désactivée* while
  /// `14 — Agents IA` showed the same agent active. The agents list is the
  /// source Agents IA reads, so both screens now agree. Null when that list
  /// could not be had; the cards then fall back to the summary.
  Map<String, Agent>? _agentByPage;

  bool get agentsKnown => _agentByPage != null;

  Agent? agentFor(String pageId) => _agentByPage?[pageId];

  Future<void> _loadAgents() async {
    final result = await _agents.list();
    if (isDisposed) return;
    final agents = result.valueOrNull;
    // A failed refresh keeps what was known.
    if (agents == null) return;
    _agentByPage = {
      for (final agent in agents)
        // Connected pages only — a disconnected page keeps its link (§24.21).
        for (final id in agent.pages.isNotEmpty ? agent.connectedPages.map((p) => p.id) : agent.pageIds) id: agent,
    };
    safeNotify();
  }

  List<ConnectedPage> _rows = const [];
  List<ConnectedPage> get pages => _rows;

  final _summaries = <String, PageSummary>{};

  /// Null while a card's summary has not answered, or when it failed — the
  /// card then shows its identity with dashes, as the web's does.
  PageSummary? summaryFor(String pageId) => _summaries[pageId];

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  Future<void> load() async {
    await run(
      _pages.list,
      onSuccess: (rows) => _rows = rows,
      silent: _loadedOnce,
      tag: 'pages',
    );
    _loadedOnce = true;
    safeNotify();
    await Future.wait([_loadSummaries(), _loadAgents()]);
  }

  /// One summary per page, in parallel — the web loads each card's own.
  Future<void> _loadSummaries() async {
    final ids = [for (final page in _rows) page.id];
    final results = await Future.wait(ids.map(_pages.summary));
    if (isDisposed) return;
    for (var i = 0; i < ids.length; i++) {
      final summary = results[i].valueOrNull;
      if (summary != null) _summaries[ids[i]] = summary;
    }
    safeNotify();
  }

  /// After the agent behind a page changed elsewhere (generated, edited).
  Future<void> refreshSummaries() async {
    await Future.wait([_loadSummaries(), _loadAgents()]);
  }

  // ---- Filter ----

  PagesFilter _filter = PagesFilter.all;
  PagesFilter get filter => _filter;

  void setFilter(PagesFilter value) {
    if (_filter == value) return;
    _filter = value;
    safeNotify();
  }

  List<ConnectedPage> get visiblePages => switch (_filter) {
        PagesFilter.all => _rows,
        PagesFilter.facebook => [for (final p in _rows) if (p.platform == PagePlatform.facebook) p],
        PagesFilter.instagram => [for (final p in _rows) if (p.platform == PagePlatform.instagram) p],
      };

  int countOn(PagePlatform platform) => _rows.where((p) => p.platform == platform).length;

  // ---- Connecting ----

  PagePlatform? _connecting;

  /// The platform whose connection is in progress, so only its button spins.
  PagePlatform? get connectingPlatform => _connecting;

  AppException? _connectError;
  AppException? get connectError => _connectError;

  List<String> _before = const [];
  bool _hasSnapshot = false;

  /// Remembers the pages as they are, then asks for Meta's dialog URL. Null
  /// when the URL could not be had — [connectError] says why.
  ///
  /// The snapshot is what tells the new page apart afterwards: the callback
  /// does not say which Facebook page was picked inside Meta's dialog.
  Future<String?> startConnect(PagePlatform platform) async {
    if (_connecting != null) return null;
    _connecting = platform;
    _connectError = null;
    safeNotify();

    final current = (await _pages.list()).valueOrNull;
    _hasSnapshot = current != null;
    _before = [for (final page in current ?? const <ConnectedPage>[]) page.id];

    final result = await _pages.authUrlFor(platform);
    if (isDisposed) return null;
    final url = result.valueOrNull;
    if (url == null) {
      _connectError = result.errorOrNull;
      _connecting = null;
    }
    safeNotify();
    return url;
  }

  /// The dialog was closed, refused, or the backend could not save the page.
  void connectEnded({String? failure}) {
    if (failure != null) Log.w('page connection failed on the backend: $failure', tag: 'pages');
    _connecting = null;
    safeNotify();
  }

  /// Meta granted: reloads, and says whether a page came through.
  ///
  /// Connected when a page on [platform] is new since [startConnect], or — the
  /// merchant reconnecting a page they already had — when the backend's
  /// callback confirmed it saved one. Never an old page passed off as new.
  Future<PageConnectOutcome> afterGrant(
    PagePlatform platform, {
    OAuthCallbackReport? report,
  }) async {
    await load();
    _connecting = null;
    safeNotify();

    final onPlatform = [for (final p in _rows) if (p.platform == platform) p];
    final fresh = onPlatform.where((p) => !_before.contains(p.id));
    if (fresh.isNotEmpty || (!_hasSnapshot && onPlatform.isNotEmpty)) return PageConnectOutcome.connected;
    final savedSome = report != null && report.succeeded && (report.pageCount ?? 1) > 0;
    if (savedSome && onPlatform.isNotEmpty) return PageConnectOutcome.connected;
    return PageConnectOutcome.nothingNew;
  }

  // ---- Disconnecting ----

  String? _busyPageId;

  /// The page being disconnected; the other cards wait.
  String? get busyPageId => _busyPageId;

  AppException? _disconnectError;
  AppException? get disconnectError => _disconnectError;

  Future<bool> disconnect(ConnectedPage page) async {
    if (_busyPageId != null) return false;
    _busyPageId = page.id;
    _disconnectError = null;
    safeNotify();

    final result = await _pages.disconnect(page.id);
    if (isDisposed) return false;
    _busyPageId = null;
    final error = result.errorOrNull;
    if (error != null) {
      _disconnectError = error;
    } else {
      _rows = [for (final p in _rows) if (p.id != page.id) p];
      _summaries.remove(page.id);
    }
    safeNotify();
    return error == null;
  }
}

/// The web's generate-agent modal, step by step.
enum AgentGenPhase { idle, reading, analyzing, drafting, preview, applying }

/// Drafting an agent from one page's inbox, then applying it.
class GenerateAgentViewModel extends BaseViewModel {
  GenerateAgentViewModel({required PageRepository pages, required this.pageId}) : _pages = pages;

  final PageRepository _pages;
  final String pageId;

  AgentGenPhase _phase = AgentGenPhase.idle;
  AgentGenPhase get phase => _phase;

  bool get isWorking =>
      _phase == AgentGenPhase.reading || _phase == AgentGenPhase.analyzing || _phase == AgentGenPhase.drafting;

  GeneratedAgentDraft? _draft;
  GeneratedAgentDraft? get draft => _draft;

  AppException? _generateError;
  AppException? get generateError => _generateError;

  AppException? _applyError;
  AppException? get applyError => _applyError;

  /// The draft's instructions, editable before applying.
  final instructions = TextEditingController();

  final _timers = <Timer>[];

  Future<void> generate() async {
    if (_phase != AgentGenPhase.idle) return;
    _generateError = null;
    _phase = AgentGenPhase.reading;
    safeNotify();

    // One request; the web staggers the labels over it so a 10–30 s wait
    // reads as progress. Same timings.
    _timers
      ..add(Timer(const Duration(seconds: 1), () => _advance(AgentGenPhase.analyzing)))
      ..add(Timer(const Duration(milliseconds: 3500), () => _advance(AgentGenPhase.drafting)));

    final result = await _pages.generateAgent(pageId);
    _cancelTimers();
    if (isDisposed) return;

    final draft = result.valueOrNull;
    if (draft == null) {
      _generateError = result.errorOrNull;
      _phase = AgentGenPhase.idle;
    } else {
      _draft = draft;
      instructions.text = draft.customInstructions;
      _phase = AgentGenPhase.preview;
    }
    safeNotify();
  }

  void _advance(AgentGenPhase next) {
    if (isDisposed || !isWorking) return;
    _phase = next;
    safeNotify();
  }

  void discard() {
    _draft = null;
    _applyError = null;
    _phase = AgentGenPhase.idle;
    safeNotify();
  }

  /// True when an agent was created, false when one was updated; null when it
  /// failed — [applyError] says why — or there was nothing to apply.
  Future<bool?> apply() async {
    final draft = _draft;
    if (draft == null || _phase != AgentGenPhase.preview) return null;
    _applyError = null;
    _phase = AgentGenPhase.applying;
    safeNotify();

    final result = await _pages.applyAgent(pageId, draft, instructions: instructions.text);
    if (isDisposed) return result.valueOrNull;
    final created = result.valueOrNull;
    if (created == null) {
      _applyError = result.errorOrNull;
      _phase = AgentGenPhase.preview;
      safeNotify();
    }
    return created;
  }

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  @override
  void dispose() {
    _cancelTimers();
    instructions.dispose();
    super.dispose();
  }
}
