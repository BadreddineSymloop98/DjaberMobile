import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../data/models/agent.dart';
import '../../data/models/connected_page.dart';
import '../../data/models/conversation.dart';
import '../../data/models/dashboard_stats.dart';
import '../../data/repositories/agent_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/page_repository.dart';
import 'base_view_model.dart';

/// One step of the `Démarrer` checklist, and whether it is done.
///
/// Derived from what the merchant actually has, not stored anywhere — so it is
/// always true, and a merchant who did the work on the web sees it ticked here.
enum SetupStep { connectPage, addProducts, configureAgent, firstSale }

/// `09 — Accueil`.
///
/// Loads everything the screen shows in **one pass, in parallel**, then derives
/// the queue and the checklist from it. Nothing on this screen is sample data.
///
/// | Section | Source |
/// |---|---|
/// | Credits pill | `User.creditsUsed / creditsLimit`, from `/auth/profile` |
/// | À traiter | conversations with `aiPaused`, across every Page |
/// | Pages connectées | `GET /api/pages` |
/// | Produits, stock faible, valeur du stock | `GET /api/user-stock/dashboard` |
/// | Chiffre d'affaires 30j | `GET /api/user-stock/sales/stats?period=month` |
/// | Vos pages | `GET /api/pages` |
/// | Démarrer | derived from all of the above |
class HomeViewModel extends BaseViewModel {
  HomeViewModel({
    required DashboardRepository dashboard,
    required PageRepository pages,
    required AgentRepository agents,
  })  : _dashboard = dashboard,
        _pages = pages,
        _agents = agents;

  final DashboardRepository _dashboard;
  final PageRepository _pages;
  final AgentRepository _agents;

  DashboardStats _stats = const DashboardStats();
  SalesStats _sales = const SalesStats();
  List<ConnectedPage> _connectedPages = const [];
  List<Agent> _agentList = const [];
  List<Conversation> _queue = const [];

  DashboardStats get stats => _stats;
  SalesStats get sales => _sales;
  List<ConnectedPage> get pages => _connectedPages;

  /// Conversations the AI has handed over, newest first. The reason the app
  /// exists (brief §2).
  List<Conversation> get queue => _queue;

  bool get hasPages => _connectedPages.isNotEmpty;

  /// True while the first load is still running and there is nothing to show.
  /// A refresh does not set it — see [BaseViewModel.run]'s `silent`.
  bool get isFirstLoad => isBusy && !_loadedOnce;
  bool _loadedOnce = false;

  /// Whether each setup step is done.
  bool isStepDone(SetupStep step) => switch (step) {
        SetupStep.connectPage => _connectedPages.isNotEmpty,
        SetupStep.addProducts => _stats.totalProducts > 0,
        SetupStep.configureAgent => _agentList.isNotEmpty,
        SetupStep.firstSale => _sales.totalSales > 0,
      };

  /// Loads the whole screen. [silent] for the pull-to-refresh and the poll, so
  /// a refresh does not blank content the merchant is reading.
  Future<void> load({bool silent = false}) async {
    await run(
      _loadAll,
      silent: silent || _loadedOnce,
      tag: 'home',
    );
    _loadedOnce = true;
    safeNotify();
  }

  /// The four independent calls go together; the queue then needs the Pages,
  /// so it follows them.
  Future<Result<void>> _loadAll() async {
    final results = await Future.wait([
      _dashboard.stats(),
      _dashboard.salesStats(),
      _pages.list(),
      _agents.list(),
    ]);

    // A partial failure still fills in whatever did arrive: a merchant with a
    // working stock summary should not lose it because the sales endpoint was
    // slow. The first error is surfaced, the rest of the screen still renders.
    AppException? firstError;

    if (results[0] case Success(:final value)) {
      _stats = value as DashboardStats;
    } else {
      firstError ??= results[0].errorOrNull;
    }
    if (results[1] case Success(:final value)) {
      _sales = value as SalesStats;
    } else {
      firstError ??= results[1].errorOrNull;
    }
    if (results[2] case Success(:final value)) {
      _connectedPages = value as List<ConnectedPage>;
    } else {
      firstError ??= results[2].errorOrNull;
    }
    if (results[3] case Success(:final value)) {
      _agentList = value as List<Agent>;
    } else {
      firstError ??= results[3].errorOrNull;
    }

    await _loadQueue();

    return firstError == null
        ? const Result<void>.success(null)
        : Result<void>.failure(firstError);
  }

  /// Fans out across the connected Pages, because no endpoint lists
  /// conversations across all of them — see [DashboardRepository].
  ///
  /// A Page whose conversations fail to load is skipped rather than failing
  /// the queue: one unreachable Page must not hide the escalations on another.
  Future<void> _loadQueue() async {
    if (_connectedPages.isEmpty) {
      _queue = const [];
      return;
    }

    final perPage = await Future.wait(
      _connectedPages.map((page) => _dashboard.conversationsFor(page.id)),
    );

    final waiting = <Conversation>[
      for (final result in perPage)
        ...?result.valueOrNull?.where((c) => c.aiPaused),
    ];

    waiting.sort((a, b) {
      final left = a.lastActivity;
      final right = b.lastActivity;
      if (left == null || right == null) return 0;
      return right.compareTo(left);
    });

    _queue = waiting;
  }
}
