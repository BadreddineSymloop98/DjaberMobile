import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../data/models/agent.dart';
import '../../data/models/agent_draft.dart';
import '../../data/models/connected_page.dart';
import '../../data/models/conversation.dart';
import '../../data/models/page_detail.dart';
import '../../data/models/page_summary.dart';
import '../../data/repositories/agent_repository.dart';
import '../../data/repositories/inbox_repository.dart';
import '../../data/repositories/page_repository.dart';
import 'base_view_model.dart';
import 'inbox_view_model.dart';

/// The four sections of a page — the web's `/dashboard/page/[pageId]` tabs.
enum PageSection { overview, messages, aiSettings, history }

/// The page itself, for the header every section shares.
///
/// Opened from a card, the page is handed over and draws at once; from a deep
/// link it is looked up in the connected list. A page that is no longer
/// connected is reported as such rather than shown with stale data.
class PageHeaderViewModel extends BaseViewModel {
  PageHeaderViewModel({required PageRepository pages, required this.pageId, ConnectedPage? initial})
    : _pages = pages,
      _page = initial;

  final PageRepository _pages;
  final String pageId;

  ConnectedPage? _page;
  ConnectedPage? get page => _page;

  bool _gone = false;

  /// Disconnected since, or never this merchant's: nothing to show.
  bool get isGone => _gone;

  Future<void> load() async {
    if (_page != null) return;
    await run(
      _pages.list,
      onSuccess: (pages) {
        _page = pages.where((p) => p.id == pageId).firstOrNull;
        _gone = _page == null;
      },
      tag: 'pageHeader',
    );
  }
}

/// *Aperçu* — the page's insights, if Facebook gives them, and the two cards
/// that lead to the analysis and to the page's products.
class PageOverviewViewModel extends BaseViewModel {
  PageOverviewViewModel({required PageRepository pages, required this.pageId}) : _pages = pages;

  final PageRepository _pages;
  final String pageId;

  PageSummary? _summary;
  PageSummary? get summary => _summary;

  PageInsights? _insights;
  PageInsights? get insights => _insights;

  /// Graph refused (503), or answered with nothing: the frame's
  /// *Statistiques indisponibles* box replaces the figures.
  bool _insightsUnavailable = false;
  bool get insightsUnavailable => _insightsUnavailable;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  Future<void> load() async {
    final summary = _pages.summary(pageId);
    final insights = _pages.insights(pageId);
    await run(
      () => summary,
      onSuccess: (value) => _summary = value,
      silent: _loadedOnce,
      tag: 'pageOverview',
    );
    final result = await insights;
    if (isDisposed) return;
    final value = result.valueOrNull;
    _insights = value;
    _insightsUnavailable = value == null || value.isEmpty;
    _updatedAt = DateTime.now();
    _loadedOnce = true;
    safeNotify();
  }
}

/// *Messages* — this page's conversations, with the inbox's tabs and search.
class PageMessagesViewModel extends BaseViewModel {
  PageMessagesViewModel({required InboxRepository inbox, required this.pageId}) : _inbox = inbox;

  final InboxRepository _inbox;
  final String pageId;

  static const filters = [
    InboxFilter.all,
    InboxFilter.active,
    InboxFilter.resolved,
    InboxFilter.archived,
  ];

  List<Conversation> _all = const [];

  InboxFilter _filter = InboxFilter.all;
  InboxFilter get filter => _filter;

  String _query = '';

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  bool _syncing = false;
  bool get isSyncing => _syncing;

  bool get isNarrowed => _query.trim().isNotEmpty || _filter != InboxFilter.all;

  int count(InboxFilter filter) => _all.where((c) => _matches(c, filter)).length;

  List<Conversation> get visible {
    final needle = _query.trim().toLowerCase();
    return [
      for (final c in _all)
        if (_matches(c, _filter) &&
            (needle.isEmpty ||
                (c.senderName ?? '').toLowerCase().contains(needle) ||
                (c.lastMessage ?? '').toLowerCase().contains(needle)))
          c,
    ];
  }

  static bool _matches(Conversation c, InboxFilter filter) => switch (filter) {
    InboxFilter.all => true,
    InboxFilter.needsHuman => c.aiPaused && !c.isArchived,
    InboxFilter.active => c.status == ConversationStatus.active.wire,
    InboxFilter.resolved => c.status == ConversationStatus.resolved.wire,
    InboxFilter.archived => c.status == ConversationStatus.archived.wire,
  };

  Future<void> load() async {
    await run(
      () => _inbox.conversations(pageId),
      onSuccess: (value) => _all = value,
      silent: _loadedOnce,
      tag: 'pageMessages',
    );
    _loadedOnce = true;
    safeNotify();
  }

  /// Pull to refresh: fetch what Meta has first (the inbox's *Actualiser*),
  /// then read the list again. A failed sync still reloads what is stored.
  Future<AppException?> sync() async {
    if (_syncing) return null;
    _syncing = true;
    safeNotify();
    final result = await _inbox.sync(pageId);
    if (isDisposed) return null;
    _syncing = false;
    await load();
    return result.errorOrNull;
  }

  void setFilter(InboxFilter value) {
    _filter = value;
    safeNotify();
  }

  void setQuery(String value) {
    _query = value;
    safeNotify();
  }
}

/// *Paramètres IA* — the agent that answers on this page, read-only.
///
/// The live webhook answers through the **agent** linked to the page, not the
/// legacy per-page settings (live docs), so this shows the agent and sends
/// the merchant to it to change anything — as the web does.
class PageAiViewModel extends BaseViewModel {
  PageAiViewModel({required AgentRepository agents, required this.pageId}) : _agents = agents;

  final AgentRepository _agents;
  final String pageId;

  Agent? _agent;
  Agent? get agent => _agent;

  AgentDraft? _details;
  AgentDraft? get details => _details;

  int? _conversations;
  int? get conversations => _conversations;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  Future<void> load() async {
    await run(
      _agents.list,
      onSuccess: (agents) => _agent = agents.where((a) => a.pageIds.contains(pageId)).firstOrNull,
      silent: _loadedOnce,
      tag: 'pageAi',
    );
    final agent = _agent;
    if (agent != null && !isDisposed) {
      // Both at once; each is optional detail, so a failure only leaves a
      // tile blank.
      final draft = _agents.getDraft(agent.id);
      final metrics = _agents.metrics(agent.id);
      final draftResult = await draft;
      final metricsResult = await metrics;
      if (isDisposed) return;
      _details = draftResult.valueOrNull;
      _conversations = metricsResult.valueOrNull?.conversationCount;
    } else {
      _details = null;
      _conversations = null;
    }
    _loadedOnce = true;
    safeNotify();
  }
}

/// *Historique* — every message of the page, newest first, paged in as it
/// scrolls; the direction chips and the two dates apply at once (decided
/// 2026-10-04, like every other list, rather than the frame's *Appliquer*).
class PageHistoryViewModel extends BaseViewModel {
  PageHistoryViewModel({required PageRepository pages, required this.pageId}) : _pages = pages;

  final PageRepository _pages;
  final String pageId;

  static const pageSize = 50;

  List<PageHistoryMessage> _list = const [];
  List<PageHistoryMessage> get messages => _list;

  int _total = 0;
  int get total => _total;

  MessageDirection? _direction;
  MessageDirection? get direction => _direction;

  DateTime? _from;
  DateTime? _to;
  DateTime? get from => _from;
  DateTime? get to => _to;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  bool _loadingMore = false;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _list.length < _total;

  bool get isNarrowed => _direction != null || _from != null || _to != null;

  int _query = 0;

  Future<Result<PageHistoryPage>> _page(int offset) => _pages.history(
    pageId,
    direction: _direction,
    dateFrom: _from,
    dateTo: _to,
    limit: pageSize,
    offset: offset,
  );

  Future<void> load() async {
    final query = ++_query;
    _loadingMore = false;
    await run(
      () => _page(0),
      onSuccess: (value) {
        if (query != _query) return;
        _list = value.messages;
        _total = value.total;
      },
      silent: _loadedOnce,
      tag: 'pageHistory',
    );
    _loadedOnce = true;
    safeNotify();
  }

  Future<void> loadMore() async {
    if (_loadingMore || !hasMore || !_loadedOnce) return;
    final query = _query;
    _loadingMore = true;
    safeNotify();
    final result = await _page(_list.length);
    if (isDisposed || query != _query) return;
    _loadingMore = false;
    if (result.valueOrNull case final page?) {
      final known = {for (final m in _list) m.id};
      _list = [
        ..._list,
        for (final m in page.messages)
          if (!known.contains(m.id)) m,
      ];
      _total = page.total;
    }
    safeNotify();
  }

  void setDirection(MessageDirection? value) {
    if (value == _direction) return;
    _direction = value;
    load();
  }

  void setFrom(DateTime? value) {
    if (value == _from) return;
    _from = value;
    load();
  }

  void setTo(DateTime? value) {
    if (value == _to) return;
    _to = value;
    load();
  }
}
