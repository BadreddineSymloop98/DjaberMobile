import '../../core/error/result.dart';
import '../../data/models/connected_page.dart';
import '../../data/models/conversation.dart';
import '../../data/models/conversation_thread.dart';
import '../../data/repositories/inbox_repository.dart';
import '../../data/repositories/page_repository.dart';
import 'base_view_model.dart';

/// The web inbox's four tabs, plus [needsHuman].
enum InboxFilter {
  all,

  /// *À traiter* — not on the web. The conversations the AI handed over and
  /// that wait for the merchant: `aiPaused`, whatever the status (a handover is
  /// `resolved`), except archived ones — archiving is the merchant setting the
  /// conversation aside.
  needsHuman,

  active,
  resolved,
  archived,
}

/// `10 — Boîte de réception` — the web's `/dashboard/inbox`.
///
/// One page at a time, as on the web: the connected pages, the one selected
/// (the route's `pageId`, else the first), and its conversations. The tabs,
/// their counts and the search all work on what was loaded, as the web's do.
class InboxViewModel extends BaseViewModel {
  InboxViewModel({
    required PageRepository pages,
    required InboxRepository inbox,
    String? initialPageId,
  })  : _pageRepository = pages,
        _inbox = inbox,
        _selectedId = initialPageId;

  final PageRepository _pageRepository;
  final InboxRepository _inbox;

  List<ConnectedPage> _pages = const [];
  List<ConnectedPage> get pages => _pages;
  bool get hasPages => _pages.isNotEmpty;

  String? _selectedId;

  /// The page shown — the requested one when it is connected, else the first.
  ConnectedPage? get selectedPage {
    for (final page in _pages) {
      if (page.id == _selectedId) return page;
    }
    return _pages.isEmpty ? null : _pages.first;
  }

  List<Conversation> _conversations = const [];
  bool get hasConversations => _conversations.isNotEmpty;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  /// Another page was picked and its conversations are on their way.
  bool _switching = false;
  bool get isSwitching => _switching;

  /// Bumped by every conversations request, so a slow answer for the page the
  /// merchant just left cannot overwrite the page they are now on.
  int _request = 0;

  InboxFilter _filter = InboxFilter.all;
  InboxFilter get filter => _filter;

  String _query = '';
  String get query => _query;

  bool _syncing = false;
  bool get isSyncing => _syncing;

  /// Set by a successful sync in this visit; the web's "synced 2m ago".
  DateTime? _lastSyncedAt;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  int count(InboxFilter filter) => _conversations.where((c) => _matches(c, filter)).length;

  /// The selected tab, then the search on the name or the last message.
  List<Conversation> get visible {
    final needle = _query.trim().toLowerCase();
    return _conversations.where((c) {
      if (!_matches(c, _filter)) return false;
      if (needle.isEmpty) return true;
      return (c.senderName ?? '').toLowerCase().contains(needle) ||
          (c.lastMessage ?? '').toLowerCase().contains(needle);
    }).toList(growable: false);
  }

  static bool _matches(Conversation conversation, InboxFilter filter) => switch (filter) {
        InboxFilter.all => true,
        InboxFilter.needsHuman => conversation.aiPaused && !conversation.isArchived,
        InboxFilter.active => conversation.status == ConversationStatus.active.wire,
        InboxFilter.resolved => conversation.status == ConversationStatus.resolved.wire,
        InboxFilter.archived => conversation.status == ConversationStatus.archived.wire,
      };

  /// The pages, then the selected page's conversations. Silent after the
  /// first load, so a pull to refresh keeps the list while it asks.
  Future<void> load() async {
    await run(_loadAll, silent: _loadedOnce, tag: 'inbox');
    _loadedOnce = true;
    safeNotify();
  }

  Future<Result<void>> _loadAll() async {
    final pagesResult = await _pageRepository.list();
    final pages = pagesResult.valueOrNull;
    if (pages == null) return Result<void>.failure(pagesResult.errorOrNull!);
    _pages = pages;

    final page = selectedPage;
    _selectedId = page?.id;
    if (page == null) {
      _conversations = const [];
      return const Result<void>.success(null);
    }

    final request = ++_request;
    final result = await _inbox.conversations(page.id);
    if (request != _request) return const Result<void>.success(null);
    final rows = result.valueOrNull;
    if (rows == null) return Result<void>.failure(result.errorOrNull!);
    _conversations = rows;
    return const Result<void>.success(null);
  }

  /// Re-reads the selected page's conversations — after a conversation was
  /// opened, a sync, or the app coming back. A failure keeps the list and
  /// sets [error], so the screen can say the list may be out of date.
  Future<void> refreshConversations() async {
    final page = selectedPage;
    if (page == null) return load();
    final request = ++_request;
    final result = await _inbox.conversations(page.id);
    if (isDisposed || request != _request) return;
    final rows = result.valueOrNull;
    if (rows != null) {
      _conversations = rows;
      clearError();
    } else {
      setError(result.errorOrNull);
    }
    safeNotify();
  }

  Future<void> selectPage(String pageId) async {
    if (_loadedOnce && pageId == selectedPage?.id) return;
    _selectedId = pageId;
    _conversations = const [];
    _lastSyncedAt = null;
    _switching = true;
    clearError();
    safeNotify();

    final request = ++_request;
    final result = await _inbox.conversations(pageId);
    if (isDisposed || request != _request) return;
    _switching = false;
    final rows = result.valueOrNull;
    if (rows != null) {
      _conversations = rows;
    } else {
      setError(result.errorOrNull);
    }
    safeNotify();
  }

  void setFilter(InboxFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    safeNotify();
  }

  void setQuery(String query) {
    if (_query == query) return;
    _query = query;
    safeNotify();
  }

  /// Pulls the page's latest threads from Meta, then re-reads the list —
  /// always, as the web does: a sync that failed halfway still stored the
  /// threads it reached. Null when there is nothing to sync or one is running.
  Future<Result<InboxSyncResult>?> sync() async {
    final page = selectedPage;
    if (page == null || _syncing) return null;
    _syncing = true;
    safeNotify();

    final result = await _inbox.sync(page.id);
    if (isDisposed) return result;
    if (result.valueOrNull != null) _lastSyncedAt = DateTime.now();
    await refreshConversations();
    _syncing = false;
    safeNotify();
    return result;
  }
}
