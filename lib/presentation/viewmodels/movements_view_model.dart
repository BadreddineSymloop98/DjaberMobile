import '../../core/error/result.dart';
import '../../data/models/product.dart';
import '../../data/models/stock_overview.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/purchase_repository.dart';
import 'base_view_model.dart';

/// The filter sheet's two values; the date chips live on the screen.
class MovementFilters {
  const MovementFilters({this.type, this.productId});

  final StockMovementType? type;
  final String? productId;

  int get activeCount => (type != null ? 1 : 0) + (productId != null ? 1 : 0);
  bool get isEmpty => activeCount == 0;

  @override
  bool operator ==(Object other) =>
      other is MovementFilters && other.type == type && other.productId == productId;

  @override
  int get hashCode => Object.hash(type, productId);
}

/// `Mouvements de stock` — the web's `stock/movements`: the whole ledger,
/// newest first, paged in as it scrolls (decided 2026-10-04, rather than the
/// frame's pager).
class MovementsViewModel extends BaseViewModel {
  MovementsViewModel({required MovementRepository movements, required ProductRepository products})
    : _movements = movements,
      _products = products;

  final MovementRepository _movements;
  final ProductRepository _products;

  static const pageSize = 30;

  List<StockMovement> _list = const [];
  List<StockMovement> get movements => _list;

  int _total = 0;
  int get total => _total;

  List<Product> _productList = const [];
  List<Product> get products => _productList;

  MovementFilters _filters = const MovementFilters();
  DateTime? _startDate;
  DateTime? _endDate;

  MovementFilters get filters => _filters;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  bool _loadingMore = false;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _list.length < _total;

  int _query = 0;

  bool get isNarrowed => !_filters.isEmpty || _startDate != null || _endDate != null;

  Future<Result<MovementPage>> _page(int offset) => _movements.list(
    productId: _filters.productId,
    type: _filters.type,
    startDate: _startDate,
    endDate: _endDate,
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
        _list = value.movements;
        _total = value.total;
      },
      silent: _loadedOnce,
      tag: 'movements',
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
        for (final m in page.movements)
          if (!known.contains(m.id)) m,
      ];
      _total = page.total;
    }
    safeNotify();
  }

  /// For the sheet's product picker. Loaded once; a failure only empties it.
  Future<void> loadProducts() async {
    if (_productList.isNotEmpty) return;
    final result = await _products.list(limit: 200);
    if (isDisposed) return;
    if (result.valueOrNull case final page?) {
      _productList = page.products;
      safeNotify();
    }
  }

  void applyFilters(MovementFilters value) {
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
}
