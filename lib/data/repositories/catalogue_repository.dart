import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../models/catalogue.dart';

/// The catalogue's shape: categories and units.
///
/// One repository for both because they are read together to fill the pickers
/// on the product forms. Categories are also managed here — list with filters,
/// create, edit, delete — for the `Catégories` screen; units can be created
/// from the edit form's **+**.
class CatalogueRepository {
  CatalogueRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /api/user-stock/categories` → `{ categories }`.
  ///
  /// A merchant's own categories only — the endpoint scopes to the caller, and
  /// there are no platform defaults, so a new account gets an empty list. The
  /// form treats that as "no category", not as a failure.
  ///
  /// The filters are the categories screen's, and every one is applied by the
  /// server (live docs): [search] is a substring on the name, [hasDescription]
  /// keeps only categories with or without one, [colors] is an exact match on
  /// the stored hex (sent comma-separated), and [minProducts] / [maxProducts]
  /// bound `_count.products` — which counts **inactive** products too. The
  /// backend ignores a product bound of 0, so one is only sent above zero.
  ///
  /// No pagination: the endpoint returns every category, ordered by name.
  Future<Result<List<ProductCategory>>> categories({
    String? search,
    bool? hasDescription,
    List<String> colors = const [],
    int? minProducts,
    int? maxProducts,
  }) {
    return _api.get<List<ProductCategory>>(
      Api.categories,
      query: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (hasDescription != null) 'hasDescription': '$hasDescription',
        if (colors.isNotEmpty) 'color': colors.join(','),
        if (minProducts != null && minProducts > 0) 'minProducts': minProducts,
        if (maxProducts != null && maxProducts > 0) 'maxProducts': maxProducts,
      },
      parse: (json) => Json.listAt(
        json as Map<String, dynamic>,
        'categories',
        ProductCategory.fromJson,
      ),
    );
  }

  /// `POST /api/user-stock/categories` → **201** `{ category }`.
  ///
  /// `name` is required, trimmed, at most 255 and **unique per user** — a
  /// duplicate answers 400 *Category already exists* (not 409). `description`
  /// is trimmed and an empty one stored as null. `color` is stored as sent,
  /// with no hex validation server-side, so the form only ever sends
  /// `#RRGGBB` in capitals: the list's colour filter matches it exactly. The
  /// response carries no `_count`, which is why the screen reloads the list.
  Future<Result<ProductCategory>> createCategory({
    required String name,
    String? description,
    required String color,
  }) {
    return _api.post<ProductCategory>(
      Api.categories,
      body: {
        'name': name.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'color': color,
      },
      parse: _parseCategory,
    );
  }

  /// `PUT /api/user-stock/categories/{id}` → `{ category }`.
  ///
  /// Partial: `name` and `color` apply only when non-empty; `description`
  /// applies whenever the key is present, so it is **always sent** — `""` is
  /// the only way to clear it.
  ///
  /// Two differences from [createCategory], both documented: no length check
  /// runs on update, and a duplicate name is **not** mapped to 400 — it comes
  /// back as a 500 *Failed to update category*. The form checks names against
  /// the ones it knows before sending, which is the only way the merchant
  /// learns what was wrong.
  Future<Result<ProductCategory>> updateCategory(
    String categoryId, {
    required String name,
    String? description,
    required String color,
  }) {
    return _api.put<ProductCategory>(
      Api.category(categoryId),
      body: {
        'name': name.trim(),
        'description': description?.trim() ?? '',
        'color': color,
      },
      parse: _parseCategory,
    );
  }

  /// `DELETE /api/user-stock/categories/{id}` — a **hard** delete.
  ///
  /// The products that were in it are kept and lose their category
  /// (`onDelete: SetNull`). The backend has no guard on a category that still
  /// holds products, so the confirmation is where the merchant is told.
  Future<Result<void>> deleteCategory(String categoryId) {
    return _api.delete<void>(Api.category(categoryId), parse: (_) {});
  }

  static ProductCategory _parseCategory(dynamic json) {
    final map = json as Map<String, dynamic>;
    final category = map['category'];
    return ProductCategory.fromJson(
      category is Map<String, dynamic> ? category : map,
    );
  }

  /// `GET /api/user-stock/units` → `{ units }`.
  ///
  /// Unlike categories this is never empty: the platform seeds defaults
  /// (`userId: null`, `isDefault: true`) and the endpoint returns them
  /// alongside the merchant's own in one list.
  Future<Result<List<ProductUnit>>> units() {
    return _api.get<List<ProductUnit>>(
      Api.units,
      parse: (json) => Json.listAt(
        json as Map<String, dynamic>,
        'units',
        ProductUnit.fromJson,
      ),
    );
  }

  /// `POST /api/user-stock/units` → `{ unit }` — the web's *Add Custom Unit*,
  /// behind the **+** beside the unit picker on the edit form.
  ///
  /// Both fields are required and trimmed server-side; `name` is capped at 255
  /// and `abbreviation` at 20, and `name` must be unique **per user** (a
  /// duplicate is a 400, not a 409). The platform's own defaults live under
  /// `userId: null`, so a merchant may create a unit named like one of them —
  /// which is why this does not check the list it already has.
  Future<Result<ProductUnit>> createUnit({
    required String name,
    required String abbreviation,
  }) {
    return _api.post<ProductUnit>(
      Api.units,
      body: {
        'name': name.trim(),
        'abbreviation': abbreviation.trim(),
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final unit = map['unit'];
        return ProductUnit.fromJson(unit is Map<String, dynamic> ? unit : map);
      },
    );
  }
}
