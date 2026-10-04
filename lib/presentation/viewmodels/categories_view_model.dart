import 'dart:ui' show Color;

import '../../core/error/result.dart';
import '../../data/models/catalogue.dart';
import '../../data/repositories/catalogue_repository.dart';
import 'base_view_model.dart';

/// The web's ten preset colours (`PRESET_COLORS` in
/// `stock/categories/page.tsx`), in its order. The last one, grey, is also the
/// backend's default.
const kCategoryPresetColors = <String>[
  '#EF4444', '#F97316', '#EAB308', '#22C55E', '#14B8A6',
  '#3B82F6', '#6366F1', '#A855F7', '#EC4899', '#6B7280',
];

/// The backend's default colour for a category, `#6B7280`.
const kCategoryDefaultColor = '#6B7280';

/// `#RRGGBB` → [Color]. Anything unreadable — the backend stores the colour
/// without validating it — falls back to the default grey rather than
/// throwing on a row.
Color categoryColor(String? hex) {
  final value = (hex ?? '').trim().replaceFirst('#', '');
  if (value.length == 6) {
    final parsed = int.tryParse(value, radix: 16);
    if (parsed != null) return Color(0xFF000000 | parsed);
  }
  return const Color(0xFF6B7280);
}

/// A colour as the backend should store it: `#RRGGBB`, capitals. Null when the
/// text is not a six-digit hex.
///
/// Capitals matter: the list's colour filter is an **exact** match on the
/// stored string, and the presets are capitals.
String? normalizeCategoryColor(String text) {
  final value = text.trim().replaceFirst('#', '').toUpperCase();
  if (!RegExp(r'^[0-9A-F]{6}$').hasMatch(value)) return null;
  return '#$value';
}

/// Tri-state for *A une description* — the web's `'' | 'true' | 'false'`.
enum DescriptionFilter { all, yes, no }

/// The filter sheet's values. Immutable, so the sheet can edit a draft and the
/// screen can tell whether the draft differs from what is applied.
class CategoryFilters {
  const CategoryFilters({
    this.minProducts,
    this.maxProducts,
    this.description = DescriptionFilter.all,
    this.colors = const {},
  });

  final int? minProducts;
  final int? maxProducts;
  final DescriptionFilter description;
  final Set<String> colors;

  /// How many filters are on — the web's `activeFilterCount`, which counts the
  /// product range as one.
  int get activeCount =>
      ((minProducts ?? 0) > 0 || maxProducts != null ? 1 : 0) +
      (description != DescriptionFilter.all ? 1 : 0) +
      (colors.isNotEmpty ? 1 : 0);

  bool get isEmpty => activeCount == 0;

  CategoryFilters copyWith({
    int? Function()? minProducts,
    int? Function()? maxProducts,
    DescriptionFilter? description,
    Set<String>? colors,
  }) =>
      CategoryFilters(
        minProducts: minProducts == null ? this.minProducts : minProducts(),
        maxProducts: maxProducts == null ? this.maxProducts : maxProducts(),
        description: description ?? this.description,
        colors: colors ?? this.colors,
      );

  @override
  bool operator ==(Object other) =>
      other is CategoryFilters &&
      other.minProducts == minProducts &&
      other.maxProducts == maxProducts &&
      other.description == description &&
      other.colors.length == colors.length &&
      other.colors.containsAll(colors);

  @override
  int get hashCode => Object.hash(minProducts, maxProducts, description, Object.hashAllUnordered(colors));
}

/// `Catégories` — the web's `stock/categories` page.
///
/// Every filter is server-side, as on the web: the search debounces into
/// `?search=`, the sheet's values into `hasDescription`, `color`,
/// `minProducts` and `maxProducts`. Nothing is filtered on the phone.
class CategoriesViewModel extends BaseViewModel {
  CategoriesViewModel({required CatalogueRepository catalogue}) : _catalogue = catalogue;

  final CatalogueRepository _catalogue;

  List<ProductCategory> _categories = const [];
  List<ProductCategory> get categories => _categories;

  String _search = '';
  String get search => _search;

  CategoryFilters _filters = const CategoryFilters();
  CategoryFilters get filters => _filters;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  /// True when the list is narrowed — the empty state then says "no match"
  /// rather than "no categories yet".
  bool get isNarrowed => _search.trim().isNotEmpty || !_filters.isEmpty;

  /// Every name the merchant has, lower-cased, from the last **unfiltered**
  /// load. The form checks a name against it before sending, because a
  /// duplicate on update comes back as a bare 500.
  Set<String> _knownNames = const {};
  Set<String> get knownNames => _knownNames;

  /// Silent after the first load, so a search or a filter keeps the current
  /// rows on screen until the new ones arrive.
  Future<void> load() async {
    final narrowed = isNarrowed;
    await run(
      () => _catalogue.categories(
        search: _search,
        hasDescription: switch (_filters.description) {
          DescriptionFilter.all => null,
          DescriptionFilter.yes => true,
          DescriptionFilter.no => false,
        },
        colors: _filters.colors.toList(),
        minProducts: _filters.minProducts,
        maxProducts: _filters.maxProducts,
      ),
      onSuccess: (value) {
        _categories = value;
        if (!narrowed) {
          _knownNames = {for (final c in value) c.name.trim().toLowerCase()};
        }
      },
      silent: _loadedOnce,
      tag: 'categories',
    );
    _loadedOnce = true;
    safeNotify();
  }

  void setSearch(String value) {
    if (value == _search) return;
    _search = value;
    load();
  }

  void applyFilters(CategoryFilters filters) {
    if (filters == _filters) return;
    _filters = filters;
    load();
  }

  /// `DELETE`, then a reload. Returns the failure, or null.
  Future<Result<void>> delete(ProductCategory category) async {
    final result = await _catalogue.deleteCategory(category.id);
    if (isDisposed) return result;
    if (result.isSuccess) await load();
    return result;
  }
}
