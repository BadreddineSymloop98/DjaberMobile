import '../../core/utils/json.dart';

/// A product category — the merchant's own grouping.
///
/// `GET /api/user-stock/categories` → `{ categories }`. Every field the list
/// returns is here except `description` and the timestamps, which no mobile
/// screen shows.
///
/// `color` is a hex string the web uses for a dot next to the name. It is kept
/// but **not rendered**: brief §21.3 says colour marks the module, and a
/// merchant-chosen colour on a filter chip would compete with the six accents
/// that already mean something. It is here so a future screen that wants it
/// does not need a model change.
class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    this.color,
    this.productCount,
  });

  final String id;
  final String name;
  final String? color;

  /// From `_count.products`, when the endpoint includes it.
  final int? productCount;

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    final count = Json.mapOrNull(json['_count']);
    return ProductCategory(
      id: Json.str(json['id']),
      name: Json.str(json['name']),
      color: Json.strOrNull(json['color']),
      productCount: count == null ? null : Json.intOrNull(count['products']),
    );
  }
}

/// A unit of measure — `Piece` / `pc`, `Kilogram` / `kg`.
///
/// `GET /api/user-stock/units` → `{ units }`. The list mixes the platform's
/// defaults (`userId: null`, `isDefault: true`) with the merchant's own, and
/// the endpoint returns both together, so nothing has to merge them here.
class ProductUnit {
  const ProductUnit({
    required this.id,
    required this.name,
    required this.abbreviation,
    this.isDefault = false,
  });

  final String id;
  final String name;

  /// The short form, shown on a product row where `name` would not fit.
  final String abbreviation;

  final bool isDefault;

  /// `Kilogram (kg)` — how the picker lists it, so a merchant can recognise
  /// either the word or the symbol they know it by.
  String get label =>
      abbreviation.isEmpty || abbreviation == name ? name : '$name ($abbreviation)';

  factory ProductUnit.fromJson(Map<String, dynamic> json) => ProductUnit(
        id: Json.str(json['id']),
        name: Json.str(json['name']),
        abbreviation: Json.str(json['abbreviation']),
        isDefault: Json.boolOf(json['isDefault']),
      );
}
