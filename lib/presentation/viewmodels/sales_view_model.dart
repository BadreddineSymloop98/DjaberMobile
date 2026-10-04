import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../data/models/order.dart';
import '../../data/models/sale.dart';
import '../../data/repositories/sale_repository.dart';
import 'base_view_model.dart';

/// The filter sheet's values. The quick chips (*Tous · Payées · Restant à
/// payer*) and the two date chips set some of the same ones from the screen.
class SaleFilters {
  const SaleFilters({
    this.payment,
    this.method,
    this.hasRemaining = false,
    this.minTotal,
    this.maxTotal,
  });

  /// Ignored by the server while [hasRemaining] is set, so the sheet greys it
  /// out rather than letting it look applied.
  final PaymentStatus? payment;
  final PaymentMethod? method;
  final bool hasRemaining;
  final double? minTotal;
  final double? maxTotal;

  /// The web's slider ceiling — a max at it means "no maximum".
  static const maxCeiling = 1000000.0;

  int get activeCount =>
      (payment != null && !hasRemaining ? 1 : 0) +
      (method != null ? 1 : 0) +
      (hasRemaining ? 1 : 0) +
      ((minTotal ?? 0) > 0 || (maxTotal ?? maxCeiling) < maxCeiling ? 1 : 0);

  bool get isEmpty => activeCount == 0;

  double? get sentMaxTotal => maxTotal == null || maxTotal! >= maxCeiling ? null : maxTotal;

  @override
  bool operator ==(Object other) =>
      other is SaleFilters &&
      other.payment == payment &&
      other.method == method &&
      other.hasRemaining == hasRemaining &&
      other.minTotal == minTotal &&
      other.maxTotal == maxTotal;

  @override
  int get hashCode => Object.hash(payment, method, hasRemaining, minTotal, maxTotal);
}

/// The three quick chips above the list — the web's payment quick filter.
enum SaleQuickFilter { all, paid, remaining }

/// `Ventes` — the web's `stock/sales`.
///
/// The four figures are the server's (`GET /sales/stats`) for the chosen
/// period, and do not follow the search or the filters. The list pages in as
/// it scrolls: walk-in sales pile up far faster than orders.
class SalesViewModel extends BaseViewModel {
  SalesViewModel({required SaleRepository sales}) : _sales = sales;

  final SaleRepository _sales;

  static const pageSize = 30;

  List<Sale> _list = const [];
  List<Sale> get sales => _list;

  int _total = 0;
  int get total => _total;

  SaleStats? _stats;
  SaleStats? get stats => _stats;

  /// The web opens on *Mois*.
  SalePeriod _period = SalePeriod.month;
  SalePeriod get period => _period;

  String _search = '';
  SaleFilters _filters = const SaleFilters();
  DateTime? _startDate;
  DateTime? _endDate;

  SaleFilters get filters => _filters;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  bool _loadingMore = false;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _list.length < _total;

  /// Bumped by every fresh query, so a page that answers after the query
  /// changed is dropped instead of being appended to the wrong list.
  int _query = 0;

  bool get isNarrowed =>
      _search.trim().isNotEmpty || !_filters.isEmpty || _startDate != null || _endDate != null;

  /// *En attente* or *Partielle* chosen in the sheet lights none of the three.
  bool isQuickSelected(SaleQuickFilter value) => switch (value) {
    SaleQuickFilter.all => _filters.payment == null && !_filters.hasRemaining,
    SaleQuickFilter.paid => _filters.payment == PaymentStatus.paid && !_filters.hasRemaining,
    SaleQuickFilter.remaining => _filters.hasRemaining,
  };

  Future<Result<SalePage>> _page(int offset) => _sales.list(
    search: _search,
    paymentStatus: _filters.payment,
    paymentMethod: _filters.method,
    hasRemaining: _filters.hasRemaining,
    startDate: _startDate,
    endDate: _endDate,
    minTotal: _filters.minTotal,
    maxTotal: _filters.sentMaxTotal,
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
        _list = value.sales;
        _total = value.total;
      },
      silent: _loadedOnce,
      tag: 'sales',
    );
    _loadedOnce = true;
    safeNotify();
  }

  /// The next page, when the list nears its end. One at a time; a failure
  /// leaves the rows already shown and is retried by the next scroll.
  Future<void> loadMore() async {
    if (_loadingMore || !hasMore || !_loadedOnce) return;
    final query = _query;
    _loadingMore = true;
    safeNotify();
    final result = await _page(_list.length);
    if (isDisposed || query != _query) return;
    _loadingMore = false;
    if (result.valueOrNull case final page?) {
      final known = {for (final s in _list) s.id};
      // A sale recorded since the first page shifts every offset by one; the
      // overlap is dropped rather than shown twice.
      _list = [
        ..._list,
        for (final s in page.sales)
          if (!known.contains(s.id)) s,
      ];
      _total = page.total;
    }
    safeNotify();
  }

  Future<void> loadStats() async {
    final period = _period;
    final result = await _sales.stats(period);
    if (isDisposed || period != _period) return;
    if (result.valueOrNull case final value?) {
      _stats = value;
      safeNotify();
    }
  }

  Future<void> reload() => Future.wait([load(), loadStats()]);

  void setPeriod(SalePeriod value) {
    if (value == _period) return;
    _period = value;
    // The old period's figures would read as this one's while it loads.
    _stats = null;
    safeNotify();
    loadStats();
  }

  void setSearch(String value) {
    if (value == _search) return;
    _search = value;
    load();
  }

  void setQuick(SaleQuickFilter value) {
    applyFilters(switch (value) {
      SaleQuickFilter.all => _copy(payment: null, hasRemaining: false),
      SaleQuickFilter.paid => _copy(payment: PaymentStatus.paid, hasRemaining: false),
      SaleQuickFilter.remaining => _copy(payment: null, hasRemaining: true),
    });
  }

  SaleFilters _copy({required PaymentStatus? payment, required bool hasRemaining}) => SaleFilters(
    payment: payment,
    method: _filters.method,
    hasRemaining: hasRemaining,
    minTotal: _filters.minTotal,
    maxTotal: _filters.maxTotal,
  );

  void applyFilters(SaleFilters value) {
    if (value == _filters) return;
    _filters = value;
    load();
  }

  void setStartDate(DateTime? value) {
    if (value == _startDate) return;
    _startDate = value;
    load();
  }

  void setEndDate(DateTime? value) {
    if (value == _endDate) return;
    _endDate = value;
    load();
  }

  final Set<String> _deleting = {};
  bool isDeleting(Sale sale) => _deleting.contains(sale.id);

  /// `DELETE /sales/{id}`. A 404 means it already went (another device): the
  /// row goes too, and the caller says so instead of showing an error.
  ///
  /// A partial sale is first brought back to 0 received (`PUT amountPaid: 0`,
  /// which removes its caisse income), since the server refuses to delete a
  /// sale with money on it. If that step fails nothing has changed; if the
  /// delete then fails the sale is left at 0 received, and the list reloads so
  /// the row says so.
  Future<Result<void>> delete(Sale sale) async {
    if (!_deleting.add(sale.id)) return const Result.success(null);
    safeNotify();
    if (sale.needsPaymentReset) {
      final reset = await _sales.update(sale.id, amountPaid: 0);
      if (isDisposed) return const Result.success(null);
      if (reset.errorOrNull case final error? when error is! NotFoundException) {
        _deleting.remove(sale.id);
        safeNotify();
        return Result.failure(error);
      }
    }
    final result = await _sales.delete(sale.id);
    if (isDisposed) return result;
    _deleting.remove(sale.id);
    final error = result.errorOrNull;
    if (error == null || error is NotFoundException) {
      _list = [
        for (final s in _list)
          if (s.id != sale.id) s,
      ];
      _total = _total > 0 ? _total - 1 : 0;
      safeNotify();
      await loadStats();
    } else {
      safeNotify();
      if (sale.needsPaymentReset) await reload();
    }
    return result;
  }
}
