import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../models/product.dart';

/// Products, against `/api/user-stock/products`.
///
/// The same endpoints the web calls from `src/app/dashboard/stock/products`.
class ProductRepository {
  ProductRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `POST /api/user-stock/products` → **201** `{ product }`.
  ///
  /// **What the server enforces** (`user-stock.controller.ts:385`), because it
  /// is stricter than the form looks and the messages come back as plain
  /// `{ error }` strings:
  ///
  /// - `sku` and `name` required, trimmed, max 255
  /// - `description` max 5000
  /// - `costPrice` **> 0** — not merely present
  /// - `sellingPrice` **> 0** and **>= costPrice**
  /// - `quantity` **> 0**, unless the product has variants
  /// - a duplicate SKU is a **400**, not a 409 — `@@unique([userId, sku])`
  ///
  /// Creating with a quantity also writes an `in` stock movement reasoned
  /// "Initial stock", in the same transaction. So this one call is what puts
  /// the first row in the merchant's movement history.
  ///
  /// [categoryId] and [unitId] are optional on the web too, which is what
  /// makes the tutorial's shortened form produce a complete product rather
  /// than a stub.
  Future<Result<Product>> create({
    required String sku,
    required String name,
    String? description,
    required double costPrice,
    required double sellingPrice,
    required int quantity,
    int minQuantity = 0,
    String? categoryId,
    String? unitId,
  }) {
    return _api.post<Product>(
      Api.products,
      body: {
        'sku': sku.trim(),
        'name': name.trim(),
        // Omitted rather than sent empty: the column is nullable and the
        // controller runs it through `validateString`, which would store "".
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'costPrice': costPrice,
        'sellingPrice': sellingPrice,
        'quantity': quantity,
        'minQuantity': minQuantity,
        'categoryId': ?categoryId,
        'unitId': ?unitId,
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        // The controller answers `{ product }`; a bare object is tolerated
        // too, so a future route returning it unwrapped still parses.
        final product = map['product'];
        return Product.fromJson(
          product is Map<String, dynamic> ? product : map,
        );
      },
    );
  }
}
