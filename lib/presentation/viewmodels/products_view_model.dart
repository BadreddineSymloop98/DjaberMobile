import '../../core/error/result.dart';
import '../../data/models/catalogue.dart';
import '../../data/models/dashboard_stats.dart';
import '../../data/models/product.dart';
import '../../data/repositories/catalogue_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/product_repository.dart';
import 'base_view_model.dart';

/// Which slice of the catalogue the list is showing.
///
/// A sealed hierarchy rather than an enum plus a nullable id, because "all",
/// "low stock" and "this category" are three shapes, not three values, and the
/// screen has to render a chip per category without inventing enum cases at
/// runtime.
sealed class ProductFilter {
  const ProductFilter();

  static const all = AllProducts();
  static const lowStock = LowStockOnly();
}

class AllProducts extends ProductFilter {
  const AllProducts();
}

class LowStockOnly extends ProductFilter {
  const LowStockOnly();
}

class InCategory extends ProductFilter {
  const InCategory(this.category);

  final ProductCategory category;

  // Value equality on the id, so re-tapping the chip a merchant is already on
  // is a no-op rather than a second identical request. The other two cases get
  // this for free by being const singletons.
  @override
  bool operator ==(Object other) =>
      other is InCategory && other.category.id == category.id;

  @override
  int get hashCode => category.id.hashCode;
}

/// `17 — Produits`.
///
/// | What the screen shows | Source |
/// |---|---|
/// | Subtitle: product count, stock value | `GET /api/user-stock/dashboard` |
/// | Filter chips | `GET /api/user-stock/categories` |
/// | The rows, and the count beside the section label | `GET /api/user-stock/products` |
///
/// The two numbers in the subtitle deliberately come from the dashboard rather
/// than from the list: they describe the whole catalogue, and must not change
/// when a filter narrows what is on screen. The count next to the section
/// label is the opposite — it is the filter's own total, so it does.
///
/// **Every filter and the search go to the server.** Filtering a fetched page
/// client-side would be wrong the moment a merchant has more products than one
/// page holds: they would search fifty rows and be told there is no match.
class ProductsViewModel extends BaseViewModel {
  ProductsViewModel({
    required ProductRepository products,
    required CatalogueRepository catalogue,
    required DashboardRepository dashboard,
  })  : _products = products,
        _catalogue = catalogue,
        _dashboard = dashboard;

  final ProductRepository _products;
  final CatalogueRepository _catalogue;
  final DashboardRepository _dashboard;

  List<Product> _rows = const [];
  List<ProductCategory> _categories = const [];
  DashboardStats _stats = const DashboardStats();
  int _total = 0;
  ProductFilter _filter = ProductFilter.all;
  String _search = '';

  List<Product> get rows => _rows;
  List<ProductCategory> get categories => _categories;
  DashboardStats get stats => _stats;

  /// How many products match the current filter, across every page — not how
  /// many are in [rows].
  int get total => _total;

  ProductFilter get filter => _filter;
  String get search => _search;

  /// True when the catalogue is genuinely empty, as opposed to filtered down
  /// to nothing. The two need different copy: one invites adding a first
  /// product, the other says the filter found nothing.
  bool get isCatalogueEmpty =>
      _rows.isEmpty && _search.isEmpty && _filter is AllProducts;

  /// True while the first load is still running and there is nothing to show.
  /// A refresh does not set it — see [BaseViewModel.run]'s `silent`.
  bool get isFirstLoad => isBusy && !_loadedOnce;
  bool _loadedOnce = false;

  /// The first load: the figures, the chips and the first page at once.
  Future<void> load() async {
    await run(
      _loadAll,
      silent: _loadedOnce,
      isEmpty: () => _rows.isEmpty,
      tag: 'products',
    );
    _loadedOnce = true;
    safeNotify();
  }

  /// The three calls are independent, so they go together and are folded
  /// separately.
  ///
  /// A merchant whose categories endpoint fails still gets their products —
  /// the chips simply come back as `Tous` and `Stock faible` with no category
  /// row. The dashboard failing costs the subtitle its two figures and nothing
  /// else. **Only the product list is allowed to fail the screen**, because it
  /// *is* the screen; the other two are annotations on it.
  Future<Result<void>> _loadAll() async {
    final results = await Future.wait([
      _dashboard.stats(),
      _catalogue.categories(),
      _products.list(),
    ]);

    if (results[0] case Success(:final value)) {
      _stats = value as DashboardStats;
    }
    if (results[1] case Success(:final value)) {
      _categories = value as List<ProductCategory>;
    }
    if (results[2] case Success(:final value)) {
      final page = value as ProductPage;
      _rows = page.products;
      _total = page.total;
      return const Result<void>.success(null);
    }
    return Result<void>.failure(results[2].errorOrNull!);
  }

  /// Re-fetches the list for the current filter and search.
  ///
  /// [silent] keeps the rows on screen while it runs, which is what a search
  /// keystroke needs: replacing the list with a spinner on every letter makes
  /// the screen strobe.
  Future<void> _reload({bool silent = false}) async {
    final active = _filter;
    await run(
      () => _products.list(
        search: _search,
        categoryId: active is InCategory ? active.category.id : null,
        lowStock: active is LowStockOnly,
      ),
      onSuccess: (page) {
        // Dropped if the merchant changed the filter while this was in
        // flight: a slow answer for `Stock faible` must not overwrite the
        // rows for the category they have since tapped.
        if (_filter != active) return;
        _rows = page.products;
        _total = page.total;
      },
      isEmpty: () => _rows.isEmpty,
      silent: silent,
      tag: 'listProducts',
    );
  }

  Future<void> refresh() => _reload();

  Future<void> selectFilter(ProductFilter value) async {
    if (value == _filter) return;
    _filter = value;
    safeNotify();
    await _reload(silent: true);
  }

  /// Called from the search field's debounce, not from every keystroke — see
  /// the screen.
  Future<void> setSearch(String value) async {
    if (value == _search) return;
    _search = value;
    safeNotify();
    await _reload(silent: true);
  }

  /// After a product has been created: the list *and* the figures are both
  /// stale, and the subtitle saying "128 products" over 129 rows is the kind
  /// of small lie that makes a screen feel broken.
  Future<void> reloadAfterCreate() async {
    final stats = await _dashboard.stats();
    if (isDisposed) return;
    if (stats case Success(:final value)) _stats = value;
    await _reload(silent: true);
  }
}
