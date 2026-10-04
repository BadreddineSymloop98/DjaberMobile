/// *Statut* in the products filter sheet.
///
/// Two values, not the web's three. The web offers *Tous / Actif / Inactif*,
/// but the endpoint lists active products by default and `isActive=false`
/// switches to inactive ones **only** — "there is no way to list both at once"
/// (live docs) — so the web's *Tous* shows exactly what *Actif* does.
enum ProductStatusFilter { active, inactive }

/// The web's products filter panel (`stock/products/page.tsx`), minus what the
/// chip row on `17 — Produits` already covers — one category, low stock.
///
/// Immutable, so the sheet edits a draft and the screen compares it with what
/// is applied. Null means "no bound".
class ProductFilters {
  const ProductFilters({
    this.status = ProductStatusFilter.active,
    this.minPrice,
    this.maxPrice,
    this.minCost,
    this.maxCost,
    this.minQty,
    this.maxQty,
    this.minProfit,
    this.maxProfit,
    this.minMargin,
    this.maxMargin,
  });

  final ProductStatusFilter status;

  /// Selling price, DA. The server ignores a bound of 0 or less.
  final double? minPrice;
  final double? maxPrice;

  /// Cost price, DA. Ignored at 0 or less, as the price.
  final double? minCost;
  final double? maxCost;

  /// Stock on hand. Ignored at 0 or less.
  final int? minQty;
  final int? maxQty;

  /// Net profit per unit, DA — selling price less the true cost, expenses
  /// included, as `GET …/margins` computes it. Legitimately negative or 0.
  final double? minProfit;
  final double? maxProfit;

  /// Margin, percent. Legitimately negative or 0.
  final double? minMargin;
  final double? maxMargin;

  static bool _positive(num? v) => v != null && v > 0;

  /// The web's `activeFilterCount`: the status and each range count once.
  int get activeCount =>
      (status == ProductStatusFilter.inactive ? 1 : 0) +
      (_positive(minPrice) || _positive(maxPrice) ? 1 : 0) +
      (_positive(minCost) || _positive(maxCost) ? 1 : 0) +
      (_positive(minQty) || _positive(maxQty) ? 1 : 0) +
      (minProfit != null || maxProfit != null ? 1 : 0) +
      (minMargin != null || maxMargin != null ? 1 : 0);

  bool get isEmpty => activeCount == 0;

  /// The query `GET /products` reads. Only what narrows the list is sent: a
  /// price, cost or quantity bound of 0 is ignored server-side, so it is left
  /// out; a profit or margin bound is sent whatever its sign.
  Map<String, Object> toQuery() => {
        if (status == ProductStatusFilter.inactive) 'isActive': 'false',
        if (_positive(minPrice)) 'minPrice': _number(minPrice!),
        if (_positive(maxPrice)) 'maxPrice': _number(maxPrice!),
        if (_positive(minCost)) 'minCost': _number(minCost!),
        if (_positive(maxCost)) 'maxCost': _number(maxCost!),
        if (_positive(minQty)) 'minQty': minQty!,
        if (_positive(maxQty)) 'maxQty': maxQty!,
        if (minProfit != null) 'minProfit': _number(minProfit!),
        if (maxProfit != null) 'maxProfit': _number(maxProfit!),
        if (minMargin != null) 'minMargin': _number(minMargin!),
        if (maxMargin != null) 'maxMargin': _number(maxMargin!),
      };

  /// `1000`, not `1000.0`, in the URL — the same number either way to the
  /// server's `Number()`, but the logs read cleaner.
  static num _number(double v) => v == v.roundToDouble() ? v.round() : v;

  @override
  bool operator ==(Object other) =>
      other is ProductFilters &&
      other.status == status &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.minCost == minCost &&
      other.maxCost == maxCost &&
      other.minQty == minQty &&
      other.maxQty == maxQty &&
      other.minProfit == minProfit &&
      other.maxProfit == maxProfit &&
      other.minMargin == minMargin &&
      other.maxMargin == maxMargin;

  @override
  int get hashCode => Object.hash(
        status,
        minPrice,
        maxPrice,
        minCost,
        maxCost,
        minQty,
        maxQty,
        minProfit,
        maxProfit,
        minMargin,
        maxMargin,
      );
}
