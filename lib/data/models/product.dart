import '../../core/config/app_config.dart';
import '../../core/utils/json.dart';

/// A stock item.
///
/// Fields are the `Product` model in `backend/prisma/schema.prisma`, read
/// through the tolerant helpers because `costPrice` and `sellingPrice` are
/// Prisma `Decimal(10,2)` columns and arrive as **strings** (`"1250.00"`),
/// while `quantity` and `minQuantity` are `Int` and arrive as numbers.
///
/// The relations are read when the response carries them: `GET /products`
/// embeds the primary image and the **active** variants, `GET /products/{id}`
/// every image and **every** variant, active or not (live docs). The create
/// response carries neither, so both lists stay empty there.
class Product {
  const Product({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    this.costPrice = 0,
    this.sellingPrice = 0,
    this.quantity = 0,
    this.minQuantity = 0,
    this.unit = 'piece',
    this.hasVariants = false,
    this.isActive = true,
    this.categoryId,
    this.unitId,
    this.imageUrl,
    this.createdAt,
    this.categoryName,
    this.unitName,
    this.unitAbbreviation,
    this.imageUrls = const [],
    this.variants = const [],
    this.variantCount,
  });

  final String id;

  /// Unique per user — the backend has `@@unique([userId, sku])`, and a clash
  /// comes back as a 400 saying "SKU already exists".
  final String sku;

  final String name;

  /// What the agent reads to sell the product. The web's own placeholder says
  /// so: *"Describe the product — the AI agent uses this to sell it."*
  final String? description;

  final double costPrice;
  final double sellingPrice;

  /// Stock on hand. For a product with variants the backend derives it: the
  /// sum of the **active** variants' quantities.
  final int quantity;

  /// The low-stock alert threshold. Optional on creation, defaults to 0.
  final int minQuantity;

  /// Legacy free-text unit, kept by the backend for backward compatibility
  /// alongside the `unitId` relation. Defaults to `piece` server-side.
  final String unit;

  /// **Set by the backend, not by the create call:** it turns true when the
  /// first variant is created and back to false when the last one is deleted.
  final bool hasVariants;

  final bool isActive;
  final String? categoryId;
  final String? unitId;
  final String? imageUrl;
  final DateTime? createdAt;

  /// `category.name`, when the response embeds the relation.
  final String? categoryName;

  /// `unitRef.name` / `unitRef.abbreviation`, when embedded.
  final String? unitName;
  final String? unitAbbreviation;

  /// Every image URL the response carried, primary first as the backend
  /// orders them. Absolute — a relative upload path is resolved against the
  /// API host, as the web does.
  final List<String> imageUrls;

  /// The variants the response carried. See the class note for which ones.
  final List<ProductVariant> variants;

  /// `_count.variants` — active **and** inactive — when the list embeds it.
  final int? variantCount;

  /// Margin per unit, in DA. The backend guarantees selling >= cost on
  /// creation, so this is never negative for a freshly created product — but
  /// an edit can lower the selling price, so it is not assumed.
  double get margin => sellingPrice - costPrice;

  /// True when stock has fallen to the merchant's own alert threshold.
  /// `minQuantity` of 0 means no threshold was set, so nothing is low.
  bool get isLowStock => minQuantity > 0 && quantity <= minQuantity;

  bool get isOutOfStock => quantity <= 0;

  /// The unit as the web's details modal prints it: `Piece (pc)`, else the
  /// legacy label.
  String get unitLabel {
    final name = unitName;
    if (name == null || name.isEmpty) return unit;
    final short = unitAbbreviation;
    return short == null || short.isEmpty ? name : '$name ($short)';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = Json.mapOrNull(json['category']);
    final unitRef = Json.mapOrNull(json['unitRef']);
    final count = Json.mapOrNull(json['_count']);
    final images = json['images'];
    final legacyImage = Json.strOrNull(json['imageUrl']);

    final urls = <String>[
      if (images is List)
        for (final image in images.whereType<Map<String, dynamic>>())
          if (Json.strOrNull(image['url']) case final url?) _absolute(url),
    ];
    // The web falls back to the legacy column when there is no gallery.
    if (urls.isEmpty && legacyImage != null) urls.add(_absolute(legacyImage));

    return Product(
      id: Json.str(json['id']),
      sku: Json.str(json['sku']),
      name: Json.str(json['name']),
      description: Json.strOrNull(json['description']),
      costPrice: Json.dbl(json['costPrice']),
      sellingPrice: Json.dbl(json['sellingPrice']),
      quantity: Json.intOf(json['quantity']),
      minQuantity: Json.intOf(json['minQuantity']),
      unit: Json.str(json['unit'], 'piece'),
      hasVariants: Json.boolOf(json['hasVariants']),
      isActive: Json.boolOf(json['isActive'], true),
      categoryId: Json.strOrNull(json['categoryId']),
      unitId: Json.strOrNull(json['unitId']),
      imageUrl: legacyImage,
      createdAt: Json.dateOrNull(json['createdAt']),
      categoryName: category == null ? null : Json.strOrNull(category['name']),
      unitName: unitRef == null ? null : Json.strOrNull(unitRef['name']),
      unitAbbreviation: unitRef == null ? null : Json.strOrNull(unitRef['abbreviation']),
      imageUrls: urls,
      variants: Json.list(json['variants'], ProductVariant.fromJson),
      variantCount: count == null ? null : Json.intOrNull(count['variants']),
    );
  }

  static String _absolute(String url) =>
      url.startsWith('http') ? url : '${AppConfig.apiBaseUrl}$url';
}

/// One variant of a product — `Rouge - L`.
///
/// `ProductVariant` in the schema, as `GET /products/{id}` and
/// `POST /products/{id}/variants` return it. Prices are Decimal strings, as on
/// the product.
class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.name,
    this.sku,
    this.costPrice = 0,
    this.sellingPrice = 0,
    this.quantity = 0,
    this.minQuantity = 0,
    this.isActive = true,
  });

  final String id;

  /// Unique per product — a duplicate is a 400.
  final String name;

  /// Optional; the backend does not check it for uniqueness.
  final String? sku;

  final double costPrice;
  final double sellingPrice;
  final int quantity;
  final int minQuantity;

  /// An inactive variant keeps its quantity but no longer counts in the
  /// product's total.
  final bool isActive;

  /// The web details table's low-stock marker: `quantity <= minQuantity`,
  /// exactly — so a variant with no threshold and no stock is marked too.
  bool get isAtThreshold => quantity <= minQuantity;

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: Json.str(json['id']),
        name: Json.str(json['name']),
        sku: Json.strOrNull(json['sku']),
        costPrice: Json.dbl(json['costPrice']),
        sellingPrice: Json.dbl(json['sellingPrice']),
        quantity: Json.intOf(json['quantity']),
        minQuantity: Json.intOf(json['minQuantity']),
        isActive: Json.boolOf(json['isActive'], true),
      );
}
