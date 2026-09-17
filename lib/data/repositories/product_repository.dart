import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../models/product.dart';
import '../models/product_expense.dart';

/// How a stock adjustment moves the quantity — the backend's `type` enum, and
/// the web's three choices in its order.
enum StockAdjustType {
  /// Adds to what is there.
  stockIn('in'),

  /// Takes away, and fails with `Insufficient stock` when there is not enough.
  stockOut('out'),

  /// Sets the exact quantity; the movement records the signed difference.
  set('adjustment');

  const StockAdjustType(this.wire);

  final String wire;
}

/// One page of products, plus how many match the filter in total.
///
/// `total` is counted server-side against the same `where` clause, so it is
/// the number of matching products rather than the number returned — which is
/// what `17 — Produits` prints next to its section label.
typedef ProductPage = ({List<Product> products, int total});

/// A photo picked on the device, waiting to be uploaded.
///
/// Held as bytes rather than a path: the system picker can hand back a
/// document with no file path at all.
class ProductPhoto {
  const ProductPhoto({required this.name, required this.bytes});

  /// The file name, extension included — the backend accepts a file by it.
  final String name;
  final Uint8List bytes;

  /// Lowercase, without the dot. Empty when the name has none.
  String get extension {
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  }
}

/// Products, against `/api/user-stock/products`.
///
/// The same endpoints the web calls from `src/app/dashboard/stock/products`.
class ProductRepository {
  ProductRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /api/user-stock/products` → `{ products, total }`.
  ///
  /// **Every filter here is applied by the database, not by this client**, so
  /// paging stays correct when one is on. That includes [lowStock], which the
  /// controller resolves with a raw `quantity <= minQuantity` query rather
  /// than filtering the page it just fetched — an earlier version of that
  /// endpoint did the latter and returned half-empty pages.
  ///
  /// The response embeds `category`, `unitRef`, the primary image, expenses
  /// and active variants on every row. None of that is parsed: the row on
  /// `17` shows SKU, price and stock, and [Product] deliberately carries only
  /// what a screen reads.
  ///
  /// [limit] defaults to the endpoint's own 50. The screen asks for one page
  /// and offers no infinite scroll yet — a merchant on the individual plan has
  /// tens of products, not thousands — but [offset] is here so adding one is a
  /// parameter rather than a rewrite.
  Future<Result<ProductPage>> list({
    String? search,
    String? categoryId,
    bool lowStock = false,
    int limit = 50,
    int offset = 0,
  }) {
    return _api.get<ProductPage>(
      Api.products,
      query: {
        // Omitted rather than sent empty: `if (search)` on the server treats
        // "" as absent anyway, and a blank param in the URL is noise in logs.
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'categoryId': ?categoryId,
        // Only ever sent as 'true'. The controller tests the string, so
        // 'false' would read as truthy on any future rewrite that checks
        // presence instead of value.
        if (lowStock) 'lowStock': 'true',
        'limit': limit,
        'offset': offset,
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final rows = Json.list(map['products'], Product.fromJson);
        return (
          products: rows,
          // Falls back to the page length rather than 0: a future response
          // that drops `total` would otherwise make a full list read as
          // "0 products" in the header above it.
          total: Json.intOrNull(map['total']) ?? rows.length,
        );
      },
    );
  }

  /// `POST /api/user-stock/products` → **201** `{ product }`.
  ///
  /// **What the server enforces**, from the live Swagger's own account of the
  /// validation order (first failure wins, every one a 400):
  ///
  /// - `sku` and `name` required, trimmed
  /// - `costPrice` **> 0** — not merely present
  /// - `sellingPrice` **> 0** and **>= costPrice**
  /// - `quantity` **> 0**, unless `hasVariants` is truthy
  /// - a duplicate SKU — `@@unique([userId, sku])`
  ///
  /// Two length rules are **not** in that list, and that is the point: `name`
  /// and `sku` over 255 and `description` over 5000 raise outside the
  /// controller's validation try/catch, so they surface as a **500**, not a
  /// 400. A `categoryId` or `unitId` that does not exist is a 500 too — the
  /// controller checks neither existence nor ownership. Both are why this form
  /// caps its fields at the keyboard and only ever sends ids that came back
  /// from `/categories` and `/units`.
  ///
  /// A duplicate SKU is a **409** `PRODUCT_SKU_ALREADY_EXISTS`, with the
  /// taken value in `params.sku` — verified live and captured in
  /// `error_contract_test.dart`. **The Swagger says 400 `SKU already
  /// exists`, and the Swagger is stale**: that page is generated from the
  /// controller source, and the contract middleware rewrites what controllers
  /// emit. A bad login still answers
  /// `res.status(401).json({ error: 'Invalid credentials' })` in the source
  /// and arrives as `AUTH_INVALID_CREDENTIALS` with a translated message, so
  /// the documented per-route bodies describe the layer underneath the
  /// contract rather than the response. Trust the contract, not the page.
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
    bool hasVariants = false,
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
        // **Not persisted.** The live Swagger is explicit about it: the flag
        // "is only used to relax this check — it is NOT persisted; the stored
        // product always starts with hasVariants = false and the flag flips to
        // true automatically when the first variant is created."
        //
        // So it is sent for the one thing it does do — let a variant product
        // through with a quantity of 0, because the variants carry their own —
        // and the checkbox on `18` is honest about the rest: it does not
        // promise the product comes back marked.
        if (hasVariants) 'hasVariants': true,
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

  /// `GET /api/user-stock/products/{id}` → `{ product }` — the web's Product
  /// Details: category and unit, **every** image, **every** variant (active
  /// and inactive, oldest first) and the last 10 movements. Read-only.
  Future<Result<Product>> get(String productId) {
    return _api.get<Product>(
      Api.product(productId),
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final product = map['product'];
        return Product.fromJson(product is Map<String, dynamic> ? product : map);
      },
    );
  }

  /// `POST /api/user-stock/products/{id}/variants` → **201** `{ variant }` —
  /// the web's `createProductVariant`.
  ///
  /// Per the live docs, in one transaction the backend sets the product's
  /// `hasVariants`, recomputes its quantity as the sum of the active variants,
  /// and writes an `in` movement for [quantity] when it is above 0. `name` is
  /// required and unique per product (a duplicate is a 400); `sku` is optional
  /// and sent only when typed, as the web's `row.sku || undefined`. Numbers
  /// are clamped to `>= 0` server-side, with no selling-above-cost rule.
  Future<Result<ProductVariant>> createVariant({
    required String productId,
    required String name,
    String? sku,
    double costPrice = 0,
    double sellingPrice = 0,
    int quantity = 0,
    int minQuantity = 0,
  }) {
    return _api.post<ProductVariant>(
      Api.productVariants(productId),
      body: {
        'name': name.trim(),
        if (sku != null && sku.trim().isNotEmpty) 'sku': sku.trim(),
        'costPrice': costPrice,
        'sellingPrice': sellingPrice,
        'quantity': quantity,
        'minQuantity': minQuantity,
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final variant = map['variant'];
        return ProductVariant.fromJson(variant is Map<String, dynamic> ? variant : map);
      },
    );
  }

  /// `PUT /api/user-stock/products/{id}` → `{ product }` — the web's
  /// `updateProduct`, behind *Modifier le produit*.
  ///
  /// **A partial update, and two fields are not part of it.** The live docs are
  /// explicit: `quantity` and `hasVariants` "CANNOT be changed here — stock
  /// moves only through `POST /products/{id}/adjust` (or the variant
  /// endpoints)". That is the whole reason the edit form has no quantity field
  /// and locks a saved variant's: there is no route that would carry it.
  ///
  /// **The rules are looser than on create**, also from the docs: `costPrice`,
  /// `sellingPrice` and `minQuantity` need only be non-negative — neither
  /// `> 0` nor `sellingPrice >= costPrice` is enforced on update. The form
  /// keeps the cost/selling comparison anyway, because the web's own validator
  /// does and a product priced below cost is a mistake either way; it drops the
  /// must-be-positive rule, which the server no longer applies.
  ///
  /// **`description`, `categoryId` and `unitId` are sent even when empty.**
  /// They are applied *when the key is present*, and `""` clears the column —
  /// which is the only way to take a category back off a product. Contrast
  /// [create], which omits an empty description. `sku` and `name` are the
  /// opposite: applied only when non-empty, so they are never sent blank.
  ///
  /// **A duplicate SKU is a 500 here**, not the 409 [create] gets: the docs say
  /// so outright ("A duplicate `sku` is NOT mapped to 400: it surfaces as a
  /// 500"). Nothing in this client can tell that 500 from any other, so the
  /// screen shows the server's message as it comes.
  Future<Result<Product>> update(
    String productId, {
    required String sku,
    required String name,
    String? description,
    double? costPrice,
    double? sellingPrice,
    int? minQuantity,
    String? categoryId,
    String? unitId,
  }) {
    return _api.put<Product>(
      Api.product(productId),
      body: {
        'sku': sku.trim(),
        'name': name.trim(),
        // Present-but-empty clears the column. See the note above.
        'description': description?.trim() ?? '',
        'categoryId': categoryId ?? '',
        'unitId': unitId ?? '',
        'costPrice': ?costPrice,
        'sellingPrice': ?sellingPrice,
        'minQuantity': ?minQuantity,
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final product = map['product'];
        return Product.fromJson(product is Map<String, dynamic> ? product : map);
      },
    );
  }

  /// `PUT /api/user-stock/products/{id}/variants/{variantId}` → `{ variant }`.
  ///
  /// Partial, and — like [update] — **`quantity` is not in it**: a saved
  /// variant's stock moves through `…/variants/{variantId}/adjust`, which is
  /// the *Ajuster le stock* screen, not this form. `sku` is sent even when
  /// empty, because `""` is what clears it; `name` only when non-empty.
  ///
  /// A name another variant of the same product already holds is a **400**,
  /// which is why the form refuses duplicates before sending: on the web that
  /// 400 lands halfway through a multi-variant save, with the earlier rows
  /// already written.
  Future<Result<ProductVariant>> updateVariant({
    required String productId,
    required String variantId,
    required String name,
    String? sku,
    double costPrice = 0,
    double sellingPrice = 0,
    int minQuantity = 0,
  }) {
    return _api.put<ProductVariant>(
      Api.productVariant(productId, variantId),
      body: {
        'name': name.trim(),
        'sku': sku?.trim() ?? '',
        'costPrice': costPrice,
        'sellingPrice': sellingPrice,
        'minQuantity': minQuantity,
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final variant = map['variant'];
        return ProductVariant.fromJson(variant is Map<String, dynamic> ? variant : map);
      },
    );
  }

  /// `DELETE /api/user-stock/products/{id}/variants/{variantId}`.
  ///
  /// **A hard delete, and it moves stock.** Per the live docs, in one
  /// transaction the backend writes a parent-level `adjustment` movement of
  /// `-variant.quantity` reasoned "Variant deleted", removes the row, sets the
  /// product's `hasVariants` back to false if it was the last one, and
  /// recomputes the parent quantity from what remains.
  ///
  /// So removing a variant that holds stock *destroys that stock*. The edit
  /// form asks before it sends these, which the web does not.
  Future<Result<void>> deleteVariant({
    required String productId,
    required String variantId,
  }) {
    return _api.delete<void>(
      Api.productVariant(productId, variantId),
      parse: (_) {},
    );
  }

  /// `POST /api/user-stock/products/{id}/adjust` → `{ product, movement }`.
  ///
  /// The only way a variant-less product's stock moves. In one transaction,
  /// with row-level locking so concurrent calls cannot oversell, it changes the
  /// quantity and writes the matching `StockMovement`.
  ///
  /// [type] is the web's three choices:
  /// - `in` adds [quantity];
  /// - `out` removes it, and is **refused with a 400 `Insufficient stock`**
  ///   when the product holds less;
  /// - `adjustment` sets the quantity to exactly [quantity], the movement
  ///   recording the signed delta.
  ///
  /// **[quantity] must be greater than zero on this endpoint** — `0` fails the
  /// required-field check, so "adjust to zero" is impossible here (it is
  /// allowed on the variant route). A non-integer ends in a 500, which is why
  /// the form only lets digits through.
  ///
  /// A product with variants is refused (400): its quantity is derived from
  /// them, so [adjustVariantStock] is the route.
  Future<Result<Product>> adjustStock({
    required String productId,
    required StockAdjustType type,
    required int quantity,
    String? reason,
  }) {
    return _api.post<Product>(
      Api.productAdjust(productId),
      body: {
        'type': type.wire,
        'quantity': quantity,
        // Sent only when typed, as the web's `reason || undefined` does: the
        // column is stored verbatim on the movement and "" would read as a
        // reason that was given and left blank.
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final product = map['product'];
        return Product.fromJson(product is Map<String, dynamic> ? product : map);
      },
    );
  }

  /// `POST /api/user-stock/products/{id}/variants/{variantId}/adjust` →
  /// `{ variant, movement }`.
  ///
  /// The variant-level counterpart. Same three types; in one transaction it
  /// updates the variant, writes a movement carrying `variantId`, and
  /// **recomputes the parent's quantity** from the active variants.
  ///
  /// Two differences from [adjustStock], both from the live docs: `quantity: 0`
  /// **is** accepted here, so setting a variant to zero works; and the
  /// adjustment applies even to an inactive variant, whose stock the parent
  /// total then ignores.
  Future<Result<ProductVariant>> adjustVariantStock({
    required String productId,
    required String variantId,
    required StockAdjustType type,
    required int quantity,
    String? reason,
  }) {
    return _api.post<ProductVariant>(
      Api.productVariantAdjust(productId, variantId),
      body: {
        'type': type.wire,
        'quantity': quantity,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final variant = map['variant'];
        return ProductVariant.fromJson(variant is Map<String, dynamic> ? variant : map);
      },
    );
  }

  /// `DELETE /api/user-stock/products/{id}` — the web's Delete Product.
  ///
  /// **A soft delete.** It sets `isActive = false`: the product leaves the
  /// default list and the dashboard KPIs but stays readable at
  /// `GET /products/{id}`, and `PUT … { "isActive": true }` brings it back.
  /// Variants, expenses and stock movements are untouched, and no stock
  /// movement is written.
  ///
  /// One side effect is **not** reversible, and the docs are explicit: the
  /// image files under `uploads/products/` are deleted from disk while the
  /// `ProductImage` rows are kept, so a restored product comes back with dead
  /// image URLs. The confirmation says the action cannot be undone, which is
  /// the honest reading of that.
  Future<Result<void>> delete(String productId) {
    return _api.delete<void>(Api.product(productId), parse: (_) {});
  }

  /// `GET /api/user-stock/products/{id}/expenses` → `{ expenses }`, newest
  /// first. The web's expense panel.
  Future<Result<List<ProductExpense>>> expenses(String productId) {
    return _api.get<List<ProductExpense>>(
      Api.productExpenses(productId),
      parse: (json) => Json.listAt(
        json as Map<String, dynamic>,
        'expenses',
        ProductExpense.fromJson,
      ),
    );
  }

  /// `POST /api/user-stock/products/{id}/expenses` → **201** `{ expense }`.
  ///
  /// [amount] must be greater than zero (a 400 otherwise) and [category] one of
  /// the six the backend names — both are enforced by the form, which offers a
  /// picker rather than a text field for the category. `date` is left out so
  /// the server stamps now, as the web does: an invalid date is a 500 there.
  /// No stock movement is written.
  Future<Result<ProductExpense>> addExpense({
    required String productId,
    required ExpenseCategory category,
    required double amount,
    bool isPerUnit = false,
    String? description,
  }) {
    return _api.post<ProductExpense>(
      Api.productExpenses(productId),
      body: {
        'category': category.wire,
        'amount': amount,
        'isPerUnit': isPerUnit,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final expense = map['expense'];
        return ProductExpense.fromJson(
          expense is Map<String, dynamic> ? expense : map,
        );
      },
    );
  }

  /// `DELETE /api/user-stock/products/{id}/expenses/{expenseId}` — a **hard**
  /// delete, unlike the product's own.
  Future<Result<void>> deleteExpense({
    required String productId,
    required String expenseId,
  }) {
    return _api.delete<void>(
      Api.productExpense(productId, expenseId),
      parse: (_) {},
    );
  }

  /// `GET /api/user-stock/products/{id}/margins` → `{ margins }`.
  ///
  /// The true cost and net margin once the expenses are counted, computed
  /// server-side. See [ProductMargins] for the formula and its one surprise on
  /// variant products.
  Future<Result<ProductMargins>> margins(String productId) {
    return _api.get<ProductMargins>(
      Api.productMargins(productId),
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final margins = map['margins'];
        return ProductMargins.fromJson(
          margins is Map<String, dynamic> ? margins : map,
        );
      },
    );
  }

  /// `DELETE /api/user-stock/products/{id}/images/{imageId}` — the web's
  /// per-thumbnail ✕ in the edit modal, which removes the image immediately
  /// rather than on save.
  Future<Result<void>> deleteImage({
    required String productId,
    required String imageId,
  }) {
    return _api.delete<void>(
      Api.productImage(productId, imageId),
      parse: (_) {},
    );
  }

  /// `POST /api/user-stock/products/{id}/images` → `{ images }`, multipart.
  ///
  /// Every photo goes under the **same** field name, `images`. Per the live
  /// docs the backend accepts a file by the extension of its filename, 1 to 10
  /// at a time and 5 MB each — and answers a breach of any of those with a
  /// generic 500 rather than a 4xx, so the form checks all three before
  /// calling this. Returns how many images were saved.
  Future<Result<int>> uploadImages({
    required String productId,
    required List<ProductPhoto> photos,
  }) {
    final form = FormData();
    for (final photo in photos) {
      form.files.add(
        MapEntry(
          'images',
          MultipartFile.fromBytes(photo.bytes, filename: photo.name),
        ),
      );
    }
    return _api.postForm<int>(
      Api.productImages(productId),
      form: form,
      parse: (json) {
        final rows = (json as Map<String, dynamic>)['images'];
        return rows is List ? rows.length : 0;
      },
    );
  }
}
