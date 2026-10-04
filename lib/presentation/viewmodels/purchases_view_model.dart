import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../data/models/order.dart';
import '../../data/models/purchase.dart';
import '../../data/models/sale.dart';
import '../../data/models/stock_overview.dart';
import '../../data/models/supplier.dart';
import '../../data/repositories/purchase_repository.dart';
import '../../data/repositories/supplier_repository.dart';
import 'base_view_model.dart';

/// The filter sheet's values. The quick chips (*Tous · Payés · À payer*) and
/// the two date chips set some of the same ones from the screen.
class PurchaseFilters {
  const PurchaseFilters({
    this.status,
    this.payment,
    this.supplierId,
    this.hasRemaining = false,
    this.minTotal,
    this.maxTotal,
  });

  final PurchaseStatus? status;

  /// Ignored by the server while [hasRemaining] is set.
  final PaymentStatus? payment;
  final String? supplierId;
  final bool hasRemaining;
  final double? minTotal;
  final double? maxTotal;

  static const maxCeiling = 1000000.0;

  int get activeCount =>
      (status != null ? 1 : 0) +
      (payment != null && !hasRemaining ? 1 : 0) +
      (supplierId != null ? 1 : 0) +
      (hasRemaining ? 1 : 0) +
      ((minTotal ?? 0) > 0 || (maxTotal ?? maxCeiling) < maxCeiling ? 1 : 0);

  bool get isEmpty => activeCount == 0;

  double? get sentMaxTotal => maxTotal == null || maxTotal! >= maxCeiling ? null : maxTotal;

  PurchaseFilters withPayment(PaymentStatus? payment, {required bool hasRemaining}) =>
      PurchaseFilters(
        status: status,
        payment: payment,
        supplierId: supplierId,
        hasRemaining: hasRemaining,
        minTotal: minTotal,
        maxTotal: maxTotal,
      );

  @override
  bool operator ==(Object other) =>
      other is PurchaseFilters &&
      other.status == status &&
      other.payment == payment &&
      other.supplierId == supplierId &&
      other.hasRemaining == hasRemaining &&
      other.minTotal == minTotal &&
      other.maxTotal == maxTotal;

  @override
  int get hashCode => Object.hash(status, payment, supplierId, hasRemaining, minTotal, maxTotal);
}

/// The three quick chips above the list.
enum PurchaseQuickFilter { all, paid, toPay }

/// `Achats` — the web's `stock/purchases`.
///
/// The four figures are the server's for the chosen period (decided
/// 2026-10-04: the Sales screen's period chips, default *Mois*). The list
/// pages in as it scrolls.
class PurchasesViewModel extends BaseViewModel {
  PurchasesViewModel({required PurchaseRepository purchases, required SupplierRepository suppliers})
    : _purchases = purchases,
      _suppliers = suppliers;

  final PurchaseRepository _purchases;
  final SupplierRepository _suppliers;

  static const pageSize = 30;

  List<Purchase> _list = const [];
  List<Purchase> get purchases => _list;

  int _total = 0;
  int get total => _total;

  PurchaseStats? _stats;
  PurchaseStats? get stats => _stats;

  SalePeriod _period = SalePeriod.month;
  SalePeriod get period => _period;

  /// For the sheet's supplier picker. Loaded once; a failure only empties it.
  List<Supplier> _supplierList = const [];
  List<Supplier> get suppliers => _supplierList;

  String _search = '';
  PurchaseFilters _filters = const PurchaseFilters();
  DateTime? _startDate;
  DateTime? _endDate;

  PurchaseFilters get filters => _filters;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  bool _loadingMore = false;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _list.length < _total;

  /// Bumped by every fresh query, so a late page is dropped.
  int _query = 0;

  bool get isNarrowed =>
      _search.trim().isNotEmpty || !_filters.isEmpty || _startDate != null || _endDate != null;

  bool isQuickSelected(PurchaseQuickFilter value) => switch (value) {
    PurchaseQuickFilter.all => _filters.payment == null && !_filters.hasRemaining,
    PurchaseQuickFilter.paid => _filters.payment == PaymentStatus.paid && !_filters.hasRemaining,
    PurchaseQuickFilter.toPay => _filters.hasRemaining,
  };

  Future<Result<PurchasePage>> _page(int offset) => _purchases.list(
    search: _search,
    status: _filters.status,
    paymentStatus: _filters.payment,
    hasRemaining: _filters.hasRemaining,
    supplierId: _filters.supplierId,
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
        _list = value.purchases;
        _total = value.total;
      },
      silent: _loadedOnce,
      tag: 'purchases',
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
      final known = {for (final p in _list) p.id};
      _list = [
        ..._list,
        for (final p in page.purchases)
          if (!known.contains(p.id)) p,
      ];
      _total = page.total;
    }
    safeNotify();
  }

  Future<void> loadStats() async {
    final period = _period;
    final result = await _purchases.stats(period);
    if (isDisposed || period != _period) return;
    if (result.valueOrNull case final value?) {
      _stats = value;
      safeNotify();
    }
  }

  Future<void> loadSuppliers() async {
    if (_supplierList.isNotEmpty) return;
    final result = await _suppliers.list();
    if (isDisposed) return;
    if (result.valueOrNull case final value?) {
      _supplierList = value;
      safeNotify();
    }
  }

  Future<void> reload() => Future.wait([load(), loadStats()]);

  void setPeriod(SalePeriod value) {
    if (value == _period) return;
    _period = value;
    _stats = null;
    safeNotify();
    loadStats();
  }

  void setSearch(String value) {
    if (value == _search) return;
    _search = value;
    load();
  }

  void setQuick(PurchaseQuickFilter value) {
    applyFilters(switch (value) {
      PurchaseQuickFilter.all => _filters.withPayment(null, hasRemaining: false),
      PurchaseQuickFilter.paid => _filters.withPayment(PaymentStatus.paid, hasRemaining: false),
      PurchaseQuickFilter.toPay => _filters.withPayment(null, hasRemaining: true),
    });
  }

  void applyFilters(PurchaseFilters value) {
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

  /// A row the receive sheet or the detail changed: swapped in place at once,
  /// then the figures follow.
  void replace(Purchase updated) {
    _list = [for (final p in _list) p.id == updated.id ? updated.keepingLabelsOf(p) : p];
    safeNotify();
    loadStats();
  }

  final Set<String> _deleting = {};
  bool isDeleting(Purchase purchase) => _deleting.contains(purchase.id);

  /// `DELETE /purchases/{id}`. A 404 means it already went: the row goes too.
  Future<Result<void>> delete(Purchase purchase) async {
    if (!_deleting.add(purchase.id)) return const Result.success(null);
    safeNotify();
    final result = await _purchases.delete(purchase.id);
    if (isDisposed) return result;
    _deleting.remove(purchase.id);
    final error = result.errorOrNull;
    if (error == null || error is NotFoundException) {
      _list = [
        for (final p in _list)
          if (p.id != purchase.id) p,
      ];
      _total = _total > 0 ? _total - 1 : 0;
      safeNotify();
      await loadStats();
    } else {
      safeNotify();
    }
    return result;
  }
}
