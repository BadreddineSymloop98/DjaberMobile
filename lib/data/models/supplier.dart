import '../../core/utils/json.dart';

/// A supplier — `Supplier` in the schema, as `GET /api/user-stock/suppliers`
/// returns it with `_count.purchases` and `totalSpent`.
///
/// **There is no `GET /suppliers/{id}`.** The list row is the richest shape the
/// backend has, and the create / update responses carry neither the purchase
/// count nor the spend — so a screen that needs those reads the list.
class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.notes,
    this.isActive = true,
    this.purchaseCount = 0,
    this.totalSpent = 0,
    this.createdAt,
  });

  final String id;

  /// Unique per merchant — a duplicate is a 400 on create and a **500** on
  /// update (live docs).
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? notes;

  /// False once "deleted": the delete is **soft**, and the list returns
  /// inactive suppliers alongside active ones unless asked not to.
  final bool isActive;

  /// `_count.purchases`.
  final int purchaseCount;

  /// Sum of the purchases' totals — a JSON number here, not a Decimal string.
  final double totalSpent;

  /// Shown as *Membre depuis*.
  final DateTime? createdAt;

  String get initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    final first = String.fromCharCode(words.first.runes.first);
    if (words.length == 1) return first.toUpperCase();
    return (first + String.fromCharCode(words.last.runes.first)).toUpperCase();
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    final count = Json.mapOrNull(json['_count']);
    return Supplier(
      id: Json.str(json['id']),
      name: Json.str(json['name']),
      email: _blank(Json.strOrNull(json['email'])),
      phone: _blank(Json.strOrNull(json['phone'])),
      address: _blank(Json.strOrNull(json['address'])),
      notes: _blank(Json.strOrNull(json['notes'])),
      isActive: Json.boolOf(json['isActive'], true),
      purchaseCount: count == null ? 0 : Json.intOf(count['purchases']),
      totalSpent: Json.dbl(json['totalSpent']),
      createdAt: Json.dateOrNull(json['createdAt']),
    );
  }

  static String? _blank(String? value) => value == null || value.trim().isEmpty ? null : value;
}
