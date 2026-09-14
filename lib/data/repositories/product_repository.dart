import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../models/product.dart';

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
