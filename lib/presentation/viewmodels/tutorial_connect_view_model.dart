import '../../core/error/app_exception.dart';
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

  AppException? _submitError;
  AppException? get submitError => _submitError;

  /// The pages that existed **before** the merchant went to Meta.
  ///
  /// Kept so the one they just connected can be told apart afterwards. The
  /// callback tells us nothing about which page was chosen — the merchant
  /// picks it inside Meta's own dialog — so the only way to identify it is to
  /// diff the list.
  List<String> _knownPageIds = const [];

  /// Asks the backend for Meta's dialog URL. Returns null on failure.
  Future<String?> startConnect(PagePlatform platform) async {
    _wasDenied = false;
    _submitError = null;
    _busyPlatform = platform;
    safeNotify();

    // Snapshot first: if this fails we have not sent the merchant anywhere.
    final existing = await _pages.list();
    _knownPageIds = existing.valueOrNull?.map((p) => p.id).toList() ?? const [];

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

  /// Reconciles after a granted flow: find the new page, attach it to the
  /// agent, and hand it back.
  ///
  /// The attach is **not** allowed to fail the step. A page that is connected
  /// but not yet linked is a recoverable state the merchant can fix from the
  /// agents screen; blocking them at the last step of the tutorial over it
  /// would be worse than carrying on.
  Future<ConnectedPage?> finishConnect({String? agentId}) async {
    _submitError = null;

    final pages = await run(
      _pages.list,
      onError: (error) => _submitError = error,
      tag: 'pagesAfterConnect',
    );
    if (pages == null || pages.isEmpty) return null;

    final connected = _newestUnknown(pages);
    if (connected == null) return null;

    if (agentId != null) {
      // Every page the agent should answer on, not just the new one: the
      // controller replaces the whole set rather than appending.
      await _agents.setPages(
        agentId: agentId,
        pageIds: pages.map((p) => p.id).toList(growable: false),
      );
    }

    return connected;
  }

  /// The page that was not there before, or — if the diff comes up empty
  /// because the snapshot failed — the most recently created one.
  ConnectedPage? _newestUnknown(List<ConnectedPage> pages) {
    final fresh =
        pages.where((p) => !_knownPageIds.contains(p.id)).toList(growable: false);
    final candidates = fresh.isNotEmpty ? fresh : pages;
    if (candidates.isEmpty) return null;

    final sorted = [...candidates]..sort((a, b) {
        final left = a.createdAt;
        final right = b.createdAt;
        if (left == null || right == null) return 0;
        return right.compareTo(left);
      });
    return sorted.first;
  }
}
