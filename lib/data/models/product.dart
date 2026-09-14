import '../../core/utils/json.dart';

/// A stock item.
///
/// Fields are the `Product` model in `backend/prisma/schema.prisma`, read
/// through the tolerant helpers because `costPrice` and `sellingPrice` are
/// Prisma `Decimal(10,2)` columns and arrive as **strings** (`"1250.00"`),
/// while `quantity` and `minQuantity` are `Int` and arrive as numbers.
///
/// Only the subset the app currently needs is modelled. `category`,
/// `unitRef`, `images` and `variants` are relations the create response
/// includes but nothing reads yet; add them when a screen needs them rather
/// than carrying dead shape.
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

  /// Stock on hand.
  final int quantity;

  /// The low-stock alert threshold. Optional on creation, defaults to 0.
  final int minQuantity;

  /// Legacy free-text unit, kept by the backend for backward compatibility
  /// alongside the `unitId` relation. Defaults to `piece` server-side.
  final String unit;

  final bool hasVariants;
  final bool isActive;
  final String? categoryId;
  final String? unitId;
  final String? imageUrl;
  final DateTime? createdAt;

  /// Margin per unit, in DA. The backend guarantees selling >= cost on
  /// creation, so this is never negative for a freshly created product — but
  /// an edit can lower the selling price, so it is not assumed.
  double get margin => sellingPrice - costPrice;

  /// True when stock has fallen to the merchant's own alert threshold.
  /// `minQuantity` of 0 means no threshold was set, so nothing is low.
  bool get isLowStock => minQuantity > 0 && quantity <= minQuantity;

  bool get isOutOfStock => quantity <= 0;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
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
        imageUrl: Json.strOrNull(json['imageUrl']),
        createdAt: Json.dateOrNull(json['createdAt']),
      );
}
