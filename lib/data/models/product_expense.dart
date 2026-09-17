import '../../core/utils/json.dart';

/// What a product expense is for.
///
/// The backend's own enum, verbatim — `marketing, shipping, packaging,
/// customs, storage, other` — and the six options the web's select offers, in
/// its order. A value outside the list is a 400, so the picker never sends
/// anything else.
enum ExpenseCategory {
  marketing('marketing'),
  shipping('shipping'),
  packaging('packaging'),
  customs('customs'),
  storage('storage'),
  other('other');

  const ExpenseCategory(this.wire);

  /// What the request carries and the response returns.
  final String wire;

  /// Falls back to [other] rather than throwing: an unknown category means the
  /// backend grew one, and a row the app cannot name is still a row the
  /// merchant spent money on.
  static ExpenseCategory parse(String? value) => values.firstWhere(
        (category) => category.wire == value,
        orElse: () => ExpenseCategory.other,
      );
}

/// One cost booked against a product — `ProductExpense` in the schema.
///
/// `GET /api/user-stock/products/{id}/expenses` → `{ expenses }`, newest first.
/// `amount` is a `Decimal(10,2)` and arrives as a **string**, like the product's
/// prices, so it goes through the tolerant reader.
class ProductExpense {
  const ProductExpense({
    required this.id,
    required this.category,
    required this.amount,
    this.description,
    this.isPerUnit = false,
    this.date,
  });

  final String id;
  final ExpenseCategory category;
  final double amount;
  final String? description;

  /// True when [amount] applies to **each unit sold**; false when it is a
  /// fixed total spread over the product's current quantity. It is the one
  /// field that changes what the margin figures mean, which is why the row
  /// carries a `/ UNITÉ` tag for it.
  final bool isPerUnit;

  final DateTime? date;

  factory ProductExpense.fromJson(Map<String, dynamic> json) => ProductExpense(
        id: Json.str(json['id']),
        category: ExpenseCategory.parse(Json.strOrNull(json['category'])),
        amount: Json.dbl(json['amount']),
        description: Json.strOrNull(json['description']),
        isPerUnit: Json.boolOf(json['isPerUnit']),
        date: Json.dateOrNull(json['date']),
      );
}

/// What the expenses do to the product's margin — `GET …/margins`.
///
/// Every field is computed server-side and arrives as a JSON number. The app
/// does **not** recompute any of it: the backend's formula floors the quantity
/// at 1 to avoid dividing by zero, and re-deriving that here would drift the
/// moment the formula changes.
///
/// One thing worth knowing when reading these on a variant product: the
/// backend uses the **parent's** prices and ignores the variants' own.
class ProductMargins {
  const ProductMargins({
    this.costPrice = 0,
    this.sellingPrice = 0,
    this.totalExpenses = 0,
    this.expensePerUnit = 0,
    this.trueCost = 0,
    this.netMargin = 0,
    this.marginPercent = 0,
  });

  final double costPrice;
  final double sellingPrice;

  /// `fixedTotal + perUnitTotal × quantity`.
  final double totalExpenses;

  /// `fixedTotal / quantity + perUnitTotal`.
  final double expensePerUnit;

  /// `costPrice + expensePerUnit` — what one unit really costs.
  final double trueCost;

  /// `sellingPrice - trueCost`, per unit. **Legitimately negative**, and the
  /// sample in the Figma frame is: expenses can outrun the margin.
  final double netMargin;

  /// `netMargin / sellingPrice × 100`, or 0 when nothing is sold for.
  final double marginPercent;

  factory ProductMargins.fromJson(Map<String, dynamic> json) => ProductMargins(
        costPrice: Json.dbl(json['costPrice']),
        sellingPrice: Json.dbl(json['sellingPrice']),
        totalExpenses: Json.dbl(json['totalExpenses']),
        expensePerUnit: Json.dbl(json['expensePerUnit']),
        trueCost: Json.dbl(json['trueCost']),
        netMargin: Json.dbl(json['netMargin']),
        marginPercent: Json.dbl(json['marginPercent']),
      );
}
