import '../../core/error/app_exception.dart';
import '../../core/utils/logger.dart';
import '../../data/models/connected_page.dart';
import '../../data/repositories/agent_repository.dart';
import '../../data/repositories/page_repository.dart';
import 'base_view_model.dart';

/// `T5 — Connecter la page`: fetching the auth URL, then reconciling what came
/// back and attaching it to the agent.
class TutorialConnectViewModel extends BaseViewModel {
  TutorialConnectViewModel({
    required PageRepository pages,
    required AgentRepository agents,
  })  : _pages = pages,
        _agents = agents;

  final PageRepository _pages;
  final AgentRepository _agents;

  /// Which button is waiting, so only that one shows a spinner.
  PagePlatform? _busyPlatform;
  PagePlatform? get busyPlatform => _busyPlatform;

  /// True after the merchant refused inside Meta's dialog. Distinct from an
  /// error: nothing broke, and the screen says so gently rather than in red.
  bool _wasDenied = false;
  bool get wasDenied => _wasDenied;

  /// True when Meta granted but the backend could not save the page — its
  /// callback page reported an error. The callback answers `200` either way,
  /// so without reading that report a failure looked exactly like a success.
  bool _failed = false;
  bool get failed => _failed;

  /// True when the grant went through but no page can be named as the one
  /// just connected — the merchant picked none, or nothing new was saved.
  /// Said plainly, rather than passing an old page off as the new one.
  bool _nothingNew = false;
  bool get nothingNew => _nothingNew;

  /// True when the page is connected but could not be attached to the agent.
  ///
  /// Not a failure of the step — see [finishConnect] — but the merchant is
  /// told, because an unlinked page is one the agent does not answer on.
  bool _linkFailed = false;
  bool get linkFailed => _linkFailed;

  AppException? _submitError;
  AppException? get submitError => _submitError;

  /// The pages that existed **before** the merchant went to Meta.
  ///
  /// Kept so the one they just connected can be told apart afterwards. The
  /// callback does not say which Facebook page was chosen — the merchant picks
  /// it inside Meta's own dialog — so the way to identify it is to diff the
  /// list.
  List<String> _knownPageIds = const [];

  /// False when that snapshot could not be taken, which leaves nothing to
  /// diff against.
  bool _hasSnapshot = false;

  /// Asks the backend for Meta's dialog URL. Returns null on failure.
  Future<String?> startConnect(PagePlatform platform) async {
    _wasDenied = false;
    _failed = false;
    _nothingNew = false;
    _linkFailed = false;
    _submitError = null;
    _busyPlatform = platform;
    safeNotify();

    // Snapshot first: if this fails we have not sent the merchant anywhere.
    final existing = (await _pages.list()).valueOrNull;
    _hasSnapshot = existing != null;
    _knownPageIds = existing?.map((p) => p.id).toList() ?? const [];

    final url = await run(
      () => _pages.authUrlFor(platform),
      onError: (error) => _submitError = error,
      tag: 'authUrl',
    );

    _busyPlatform = null;
    safeNotify();
    return url;
  }

  /// The merchant closed the dialog without granting.
  void connectAbandoned({required bool denied}) {
    _busyPlatform = null;
    _wasDenied = denied;
    safeNotify();
  }

  /// The backend reported that it could not save the page. [reason] is its
  /// own English text, so it goes to the log rather than the screen.
  void connectFailed(String? reason) {
    Log.w(
      'page connection failed on the backend: ${reason ?? 'no reason given'}',
      tag: 'pages',
    );
    _busyPlatform = null;
    _failed = true;
    safeNotify();
  }

  /// Reconciles after a granted flow: find the new page, attach it to the
  /// agent, and hand it back. Null when no page can be named — [nothingNew]
  /// says so — or when the list could not be fetched.
  ///
  /// The attach is **not** allowed to fail the step. A page that is connected
  /// but not yet linked is a recoverable state the merchant can fix from the
  /// agent's settings; blocking them at the last step of the tutorial over it
  /// would be worse than carrying on. It is reported through [linkFailed].
  Future<ConnectedPage?> finishConnect({
    required PagePlatform platform,
    OAuthCallbackReport? report,
    String? agentId,
  }) async {
    _submitError = null;
    _nothingNew = false;
    _linkFailed = false;

    final pages = await run(
      _pages.list,
      onError: (error) => _submitError = error,
      tag: 'pagesAfterConnect',
    );
    if (pages == null) return null;

    final connected = _identify(pages, platform: platform, report: report);
    if (connected == null) {
      _nothingNew = true;
      safeNotify();
      return null;
    }

    _linkFailed = !await _linkToAgent(pages, agentId);
    safeNotify();
    return connected;
  }

  /// Which page the merchant just connected, or null when none can be named.
  ///
  /// In order: a page on this platform that was not there before — the
  /// ordinary case; an Instagram account the callback named, which covers
  /// reconnecting one already listed; with no snapshot to diff against, the
  /// newest page on this platform; and a reconnect of the merchant's only page
  /// on this platform, when the callback confirmed it saved one.
  ///
  /// **Never an old page just because nothing new arrived.** That used to be
  /// the fallback, and a connection that saved nothing was announced as a
  /// success with a page connected long before.
  ConnectedPage? _identify(
    List<ConnectedPage> pages, {
    required PagePlatform platform,
    OAuthCallbackReport? report,
  }) {
    // A Facebook grant also saves any Instagram account linked to the page,
    // so the platform the merchant chose narrows the list first.
    final onPlatform =
        pages.where((p) => p.platform == platform).toList(growable: false);
    if (onPlatform.isEmpty) return null;

    if (_hasSnapshot) {
      final fresh = onPlatform
          .where((p) => !_knownPageIds.contains(p.id))
          .toList(growable: false);
      if (fresh.isNotEmpty) return _newest(fresh);
    }

    final username = report?.username;
    if (username != null) {
      for (final page in onPlatform) {
        if (page.pageName == username) return page;
      }
    }

    if (!_hasSnapshot) return _newest(onPlatform);

    final savedSome =
        report != null && report.succeeded && (report.pageCount ?? 1) > 0;
    if (savedSome && onPlatform.length == 1) return onPlatform.single;

    return null;
  }

  /// Attaches every connected page to the agent. False when that did not
  /// happen.
  ///
  /// [agentId] is null when `T4` moved on without creating an agent — the
  /// account already had one. One agent per user is enforced, so that agent is
  /// the only one listed, and the page is linked to it rather than to nothing.
  Future<bool> _linkToAgent(List<ConnectedPage> pages, String? agentId) async {
    var id = agentId;
    if (id == null) {
      final agents = (await _agents.list()).valueOrNull;
      if (agents == null || agents.isEmpty) {
        Log.w('no agent to link the page to', tag: 'pages');
        return false;
      }
      id = agents.first.id;
    }

    // Every page the agent should answer on, not just the new one: the
    // controller replaces the whole set rather than appending.
    final result = await _agents.setPages(
      agentId: id,
      pageIds: pages.map((p) => p.id).toList(growable: false),
    );
    final error = result.errorOrNull;
    if (error != null) {
      Log.w(
        'linking pages to the agent failed: ${error.code ?? error.message}',
        tag: 'pages',
      );
      return false;
    }
    return true;
  }

  /// The most recently created of [pages]. Rows without a date keep their
  /// order.
  static ConnectedPage _newest(List<ConnectedPage> pages) {
    final sorted = [...pages]..sort((a, b) {
        final left = a.createdAt;
        final right = b.createdAt;
        if (left == null || right == null) return 0;
        return right.compareTo(left);
      });
    return sorted.first;
  }
}
