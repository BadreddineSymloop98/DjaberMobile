import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../models/catalogue.dart';

/// The two lookup lists the product form needs: categories and units.
///
/// One repository for both because neither is a screen of its own on mobile —
/// they exist to fill the pickers on `18 — Ajouter un produit`, and are read
/// together in the same pass. Managing them (create, rename, delete) stays on
/// the web, which is where a merchant sets up their catalogue's shape; the
/// endpoints for it are in [Api] but nothing here calls them.
class CatalogueRepository {
  CatalogueRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /api/user-stock/categories` → `{ categories }`.
  ///
  /// A merchant's own categories only — the endpoint scopes to the caller, and
  /// there are no platform defaults, so a new account gets an empty list. The
  /// form treats that as "no category", not as a failure.
  Future<Result<List<ProductCategory>>> categories() {
    return _api.get<List<ProductCategory>>(
      Api.categories,
      parse: (json) => Json.listAt(
        json as Map<String, dynamic>,
        'categories',
        ProductCategory.fromJson,
      ),
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
}
