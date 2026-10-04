import '../../core/error/app_exception.dart';
import '../../data/models/dashboard_stats.dart';
import '../../data/models/stock_overview.dart';
import '../../data/repositories/dashboard_repository.dart';
import 'base_view_model.dart';

/// `16 — Aperçu du stock` — the web's `/dashboard/stock`.
///
/// | What the screen shows | Source |
/// |---|---|
/// | The seven figures, the movements | `GET /api/user-stock/dashboard` |
/// | Ventes ce mois (Advanced) | `GET /api/user-stock/sales/stats?period=month` |
/// | Achats ce mois (Advanced) | `GET /api/user-stock/purchases/stats?period=month` |
///
/// The three go together, as on the web. Unlike the web — whose single
/// `Promise.all` turns any one failure into a page-wide error — only the
/// dashboard is required: a failed monthly block shows its own error line and
/// leaves the rest of the screen readable.
///
/// The monthly figures are loaded in Simple mode too, as the web does, so
/// switching to Advanced shows them at once instead of starting a request.
class StockOverviewViewModel extends BaseViewModel {
  StockOverviewViewModel({required DashboardRepository dashboard}) : _dashboard = dashboard;

  final DashboardRepository _dashboard;

  StockOverview? _overview;

  /// Null until the dashboard has loaded once; kept through a failed refresh.
  StockOverview? get overview => _overview;

  SalesStats? _sales;
  SalesStats? get sales => _sales;

  PurchaseStats? _purchases;
  PurchaseStats? get purchases => _purchases;

  AppException? _salesError;
  AppException? get salesError => _salesError;

  AppException? _purchasesError;
  AppException? get purchasesError => _purchasesError;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  Future<void> load() async {
    final sales = _dashboard.salesStats();
    final purchases = _dashboard.purchaseStats();
    await run(
      _dashboard.overview,
      onSuccess: (value) => _overview = value,
      silent: _loadedOnce,
      tag: 'stockOverview',
    );
    final salesResult = await sales;
    final purchasesResult = await purchases;
    if (isDisposed) return;
    _sales = salesResult.valueOrNull ?? _sales;
    _salesError = salesResult.errorOrNull;
    _purchases = purchasesResult.valueOrNull ?? _purchases;
    _purchasesError = purchasesResult.errorOrNull;
    _loadedOnce = true;
    safeNotify();
  }
}
