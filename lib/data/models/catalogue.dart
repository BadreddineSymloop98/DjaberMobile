import '../../core/utils/json.dart';

/// A product category — the merchant's own grouping.
///
/// `GET /api/user-stock/categories` → `{ categories }`. Every field the list
/// returns is here except the timestamps.
///
/// `color` is a hex string the merchant picks. It is drawn **only on the
/// categories screen**, as the small square before the name that the Figma
/// frame draws. It stays off the filter chips on `17`: brief §21.3 says colour
/// marks the module, and a merchant-chosen colour there would compete with the
/// accents that already mean something.
class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.productCount,
  });

  final String id;
  final String name;

  /// Optional; the categories screen shows it under the name when set.
  final String? description;

  final String? color;

  /// From `_count.products`, when the endpoint includes it.
  final int? productCount;

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    final count = Json.mapOrNull(json['_count']);
    return ProductCategory(
      id: Json.str(json['id']),
      name: Json.str(json['name']),
      description: Json.strOrNull(json['description']),
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
