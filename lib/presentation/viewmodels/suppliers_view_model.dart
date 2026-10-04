import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../data/models/supplier.dart';
import '../../data/repositories/supplier_repository.dart';
import 'base_view_model.dart';

/// *Statut* in the filter sheet.
enum SupplierStatusFilter { all, active, inactive }

/// The filter sheet's values; the dates live on the screen's own chips.
class SupplierFilters {
  const SupplierFilters({
    this.status = SupplierStatusFilter.all,
    this.minPurchases,
    this.maxPurchases,
    this.minSpent,
    this.maxSpent,
  });

  final SupplierStatusFilter status;
  final int? minPurchases;
  final int? maxPurchases;
  final double? minSpent;

  /// Applied by the server whenever it is a number, 0 included.
  final double? maxSpent;

  /// The web's `activeFilterCount`: each range counts once.
  int get activeCount =>
      (status != SupplierStatusFilter.all ? 1 : 0) +
      ((minPurchases ?? 0) > 0 || (maxPurchases ?? 0) > 0 ? 1 : 0) +
      ((minSpent ?? 0) > 0 || maxSpent != null ? 1 : 0);

  bool get isEmpty => activeCount == 0;

  @override
  bool operator ==(Object other) =>
      other is SupplierFilters &&
      other.status == status &&
      other.minPurchases == minPurchases &&
      other.maxPurchases == maxPurchases &&
      other.minSpent == minSpent &&
      other.maxSpent == maxSpent;

  @override
  int get hashCode => Object.hash(status, minPurchases, maxPurchases, minSpent, maxSpent);
}

/// `Fournisseurs` — the web's `stock/suppliers` page.
///
/// Search, filters and dates all go to the server. The three figures are
/// computed from what it returned, as the web computes them.
class SuppliersViewModel extends BaseViewModel {
  SuppliersViewModel({required SupplierRepository suppliers}) : _suppliers = suppliers;

  final SupplierRepository _suppliers;

  List<Supplier> _list = const [];
  List<Supplier> get suppliers => _list;

  String _search = '';
  SupplierFilters _filters = const SupplierFilters();
  DateTime? _startDate;
  DateTime? _endDate;

  SupplierFilters get filters => _filters;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  bool get isNarrowed =>
      _search.trim().isNotEmpty || !_filters.isEmpty || _startDate != null || _endDate != null;

  int get totalCount => _list.length;
  int get activeCount => _list.where((s) => s.isActive).length;
  int get withPurchasesCount => _list.where((s) => s.purchaseCount > 0).length;

  /// Lower-cased names from the last **unfiltered** load. A duplicate name is a
  /// bare 500 on update, so the form checks against these first.
  Set<String> _knownNames = const {};
  Set<String> get knownNames => _knownNames;

  Future<void> load() async {
    final narrowed = isNarrowed;
    await run(
      () => _suppliers.list(
        search: _search,
        isActive: switch (_filters.status) {
          SupplierStatusFilter.all => null,
          SupplierStatusFilter.active => true,
          SupplierStatusFilter.inactive => false,
        },
        startDate: _startDate,
        endDate: _endDate,
        minPurchases: _filters.minPurchases,
        maxPurchases: _filters.maxPurchases,
        minTotalSpent: _filters.minSpent,
        maxTotalSpent: _filters.maxSpent,
      ),
      onSuccess: (value) {
        _list = value;
        if (!narrowed) _knownNames = {for (final s in value) s.name.trim().toLowerCase()};
      },
      silent: _loadedOnce,
      tag: 'suppliers',
    );
    _loadedOnce = true;
    safeNotify();
  }

  void setSearch(String value) {
    if (value == _search) return;
    _search = value;
    load();
  }

  void applyFilters(SupplierFilters value) {
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

  Future<Result<void>> delete(Supplier supplier) async {
    final result = await _suppliers.delete(supplier.id);
    if (isDisposed) return result;
    if (result.isSuccess) await load();
    return result;
  }
}

/// `Supplier details`. There is no read-one route, so the supplier comes from
/// the list: handed over by the list screen when it opens the details, and
/// re-read from the list on refresh, after an edit, or when the screen is
/// reached without it (a deep link, the splash replaying).
class SupplierDetailViewModel extends BaseViewModel {
  SupplierDetailViewModel({
    required SupplierRepository suppliers,
    required this.supplierId,
    Supplier? initial,
  })  : _suppliers = suppliers,
        _supplier = initial;

  final SupplierRepository _suppliers;
  final String supplierId;

  Supplier? _supplier;
  Supplier? get supplier => _supplier;

  bool _notFound = false;

  /// The id matched no supplier — deleted for good elsewhere, or not this
  /// merchant's.
  bool get notFound => _notFound;

  Future<void> load() async {
    final silent = _supplier != null;
    await run<Supplier?>(
      () => _suppliers.find(supplierId),
      onSuccess: (value) {
        _notFound = value == null;
        if (value != null) _supplier = value;
      },
      silent: silent,
      tag: 'supplierDetail',
    );
    safeNotify();
  }

  /// Exposed for the screen's error line after a silent refresh.
  AppException? get refreshError => _supplier == null ? null : error;
}
