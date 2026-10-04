import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import 'base_view_model.dart';

/// The filter sheet's values. The status tabs and the two date chips live on
/// the screen itself, as the frame draws them.
class OrderFilters {
  const OrderFilters({
    this.confirmation,
    this.payment,
    this.hasRemaining = false,
    this.minTotal,
    this.maxTotal,
  });

  final ConfirmationStatus? confirmation;

  /// Ignored by the server while [hasRemaining] is set, so the sheet greys it
  /// out rather than letting it look applied.
  final PaymentStatus? payment;

  final bool hasRemaining;
  final double? minTotal;
  final double? maxTotal;

  /// The frame's slider bounds — a max at the ceiling means "no maximum", so
  /// it is not sent and does not count as a filter.
  static const maxCeiling = 1000000.0;

  int get activeCount =>
      (confirmation != null ? 1 : 0) +
      (payment != null && !hasRemaining ? 1 : 0) +
      (hasRemaining ? 1 : 0) +
      ((minTotal ?? 0) > 0 || (maxTotal ?? maxCeiling) < maxCeiling ? 1 : 0);

  bool get isEmpty => activeCount == 0;

  /// What actually goes on the wire for the amount bounds.
  double? get sentMaxTotal =>
      maxTotal == null || maxTotal! >= maxCeiling ? null : maxTotal;

  OrderFilters copyWith({
    ConfirmationStatus? confirmation,
    bool clearConfirmation = false,
    PaymentStatus? payment,
    bool clearPayment = false,
    bool? hasRemaining,
    double? minTotal,
    double? maxTotal,
  }) =>
      OrderFilters(
        confirmation: clearConfirmation ? null : (confirmation ?? this.confirmation),
        payment: clearPayment ? null : (payment ?? this.payment),
        hasRemaining: hasRemaining ?? this.hasRemaining,
        minTotal: minTotal ?? this.minTotal,
        maxTotal: maxTotal ?? this.maxTotal,
      );

  @override
  bool operator ==(Object other) =>
      other is OrderFilters &&
      other.confirmation == confirmation &&
      other.payment == payment &&
      other.hasRemaining == hasRemaining &&
      other.minTotal == minTotal &&
      other.maxTotal == maxTotal;

  @override
  int get hashCode => Object.hash(confirmation, payment, hasRemaining, minTotal, maxTotal);
}

/// `Commandes` — the web's `stock/orders` page, and the CMD tab.
///
/// **The four figures are the server's**, not derived from the loaded rows the
/// way every list before this one does it: `GET /orders/stats` is a real
/// endpoint here, and it counts the whole book rather than the page on screen.
/// So they do **not** follow the search or the filters, which is what the web
/// does too.
class OrdersViewModel extends BaseViewModel {
  OrdersViewModel({required OrderRepository orders}) : _orders = orders;

  final OrderRepository _orders;

  List<Order> _list = const [];
  List<Order> get orders => _list;

  int _total = 0;

  /// The server's count for the current query — what the subtitle reads.
  int get total => _total;

  OrderStats? _stats;
  OrderStats? get stats => _stats;

  /// Null is *Tous*. The web opens on **Nouveau**; the frame is drawn on
  /// *Tous* to show every status at once, and the frame wins (working rule:
  /// where the web and the Figma differ, follow the Figma).
  OrderStatus? _tab;
  OrderStatus? get tab => _tab;

  String _search = '';
  OrderFilters _filters = const OrderFilters();
  DateTime? _startDate;
  DateTime? _endDate;

  OrderFilters get filters => _filters;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  bool get isNarrowed =>
      _search.trim().isNotEmpty ||
      !_filters.isEmpty ||
      _tab != null ||
      _startDate != null ||
      _endDate != null;

  // ---- Selection ----

  final Set<String> _selected = {};
  Set<String> get selectedIds => Set.unmodifiable(_selected);
  int get selectedCount => _selected.length;
  bool isSelected(String id) => _selected.contains(id);

  bool get allSelected => _list.isNotEmpty && _selected.length == _list.length;

  void toggle(String id) {
    if (!_selected.remove(id)) _selected.add(id);
    safeNotify();
  }

  void toggleAll() {
    if (allSelected) {
      _selected.clear();
    } else {
      _selected
        ..clear()
        ..addAll(_list.map((o) => o.id));
    }
    safeNotify();
  }

  void clearSelection() {
    if (_selected.isEmpty) return;
    _selected.clear();
    safeNotify();
  }

  /// The statuses every selected order can legally move to — the intersection
  /// of each one's own allowed set.
  ///
  /// The intersection, not the union: a bulk button that is offered for a
  /// selection containing one order that cannot make the move would fail
  /// halfway and leave the merchant with a partial result. One terminal order
  /// in the selection empties this, which is correct.
  List<OrderStatus> get bulkAllowed {
    final chosen = _list.where((o) => _selected.contains(o.id)).toList();
    if (chosen.isEmpty) return const [];
    var allowed = chosen.first.allowedNext.toSet();
    for (final order in chosen.skip(1)) {
      allowed = allowed.intersection(order.allowedNext.toSet());
    }
    // A stable order, so the bar's buttons do not shuffle between selections.
    return [
      for (final status in OrderStatus.values)
        if (allowed.contains(status)) status,
    ];
  }

  Future<void> load() async {
    await run(
      () => _orders.list(
        search: _search,
        status: _tab,
        confirmationStatus: _filters.confirmation,
        paymentStatus: _filters.payment,
        hasRemaining: _filters.hasRemaining,
        startDate: _startDate,
        endDate: _endDate,
        minTotal: _filters.minTotal,
        maxTotal: _filters.sentMaxTotal,
      ),
      onSuccess: (value) {
        _list = value.orders;
        _total = value.total;
        // A row that is no longer on screen cannot stay selected, or a bulk
        // action would fire against something the merchant can no longer see.
        _selected.removeWhere((id) => !_list.any((o) => o.id == id));
      },
      silent: _loadedOnce,
      tag: 'orders',
    );
    _loadedOnce = true;
    safeNotify();
  }

  /// The figures. Separate from [load] so a filter change does not refetch
  /// them — they do not depend on the query.
  Future<void> loadStats() async {
    final result = await _orders.stats();
    if (isDisposed) return;
    if (result.valueOrNull case final value?) {
      _stats = value;
      safeNotify();
    }
  }

  Future<void> reload() async {
    await Future.wait([load(), loadStats()]);
  }

  void setTab(OrderStatus? value) {
    if (value == _tab) return;
    _tab = value;
    _selected.clear();
    load();
  }

  void setSearch(String value) {
    if (value == _search) return;
    _search = value;
    load();
  }

  void applyFilters(OrderFilters value) {
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

  /// Moves one order along, for the row's per-status button.
  ///
  /// Refuses a move the matrix does not allow rather than letting the server
  /// answer 400 — the button should never have been there.
  Future<Result<Order>> setStatus(Order order, OrderStatus status) async {
    if (!order.allowedNext.contains(status)) {
      return Result.failure(order.status.isTerminal
          ? const ValidationException('terminal order')
          : const ValidationException('illegal transition'));
    }
    final result = await _orders.update(order.id, status: status);
    if (isDisposed) return result;
    if (result.isSuccess) await reload();
    return result;
  }

  /// Applies [status] to every selected order, one request each.
  ///
  /// Returns how many failed. They are attempted independently on purpose: a
  /// server-side race on one order must not stop the other nine, and the bar
  /// reports the count rather than pretending they all went through.
  Future<int> applyBulk(OrderStatus status) async {
    final ids = _list
        .where((o) => _selected.contains(o.id) && o.allowedNext.contains(status))
        .map((o) => o.id)
        .toList();
    if (ids.isEmpty) return 0;

    final results = await Future.wait([
      for (final id in ids) _orders.update(id, status: status),
    ]);
    if (isDisposed) return 0;
    _selected.clear();
    await reload();
    return results.where((r) => r.isFailure).length;
  }

  Future<Result<void>> delete(Order order) async {
    final result = await _orders.delete(order.id);
    if (isDisposed) return result;
    if (result.isSuccess) {
      _selected.remove(order.id);
      await reload();
    }
    return result;
  }
}
