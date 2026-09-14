import 'package:intl/intl.dart' as intl;

/// Dinar figures, formatted the way the frames write them.
///
/// Lifted out of `home_screen.dart` when the products screens needed the same
/// two forms: `09 — Accueil`'s stock-value tile and `17 — Produits`'
/// subtitle print the identical number, and a second copy of the thresholds
/// would drift the moment one of them was tuned.
///
/// Digits follow the locale through `intl`. Plain `ar` uses **Western**
/// digits — its `ZERO_DIGIT` is `'0'` — so an Arabic merchant sees `1,24`,
/// not `١٫٢٤`, which is what the frames draw and what a merchant reading a
/// price list off a supplier's invoice expects.
class Money {
  const Money._();

  /// `1240000` → `1 240 000`, grouped for the locale.
  static String grouped(num value, String localeTag) =>
      intl.NumberFormat.decimalPattern(localeTag).format(value);

  /// `1 240 000` → `1,24` + `M DA`, the compact pair the frames use.
  ///
  /// The thresholds are the frames' own two examples — `1,24 M DA` and a bare
  /// `0 DA`. A tile is 175 wide at the design frame, so an ungrouped dinar
  /// figure runs off it long before a merchant's stock is worth much.
  static ({String value, String unit}) short(double amount, String localeTag) {
    if (amount >= 1000000) {
      return (
        value: intl.NumberFormat('#,##0.00', localeTag).format(amount / 1000000),
        unit: 'M DA',
      );
    }
    if (amount >= 10000) {
      return (
        value: intl.NumberFormat('#,##0.0', localeTag).format(amount / 1000),
        unit: 'K DA',
      );
    }
    return (
      value: intl.NumberFormat.decimalPattern(localeTag).format(amount.round()),
      unit: 'DA',
    );
  }

  /// The compact pair as one string — `1,24 M DA`. What a sentence needs.
  static String shortLabel(double amount, String localeTag) {
    final parts = short(amount, localeTag);
    return '${parts.value} ${parts.unit}';
  }

  /// A price on a product row: grouped, no decimals, with the unit. `2 400 DA`.
  ///
  /// Never compacted — a merchant checking a selling price needs the figure
  /// itself, and the rows have the width for it.
  static String price(double amount, String localeTag) =>
      '${grouped(amount.round(), localeTag)} DA';
}
