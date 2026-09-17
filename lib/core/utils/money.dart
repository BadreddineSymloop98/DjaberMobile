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

  /// A figure that must not be rounded — `1 800 DA`, `933,33 DA`,
  /// `−333,33 DA`.
  ///
  /// The margin summary is the one place decimals carry meaning: the backend
  /// divides a fixed expense by the quantity on hand, so `12 600 / 15` really
  /// is `840`, and rounding a per-unit cost to the dinar hides what the
  /// merchant is checking. Whole figures still print whole, as the frame does.
  static String exact(double amount, String localeTag) {
    final rounded = double.parse(amount.toStringAsFixed(2));
    final pattern = rounded == rounded.roundToDouble() ? '#,##0' : '#,##0.00';
    return '${intl.NumberFormat(pattern, localeTag).format(rounded)} DA';
  }

  /// A signed percentage as the margin line prints it — `−13,9 %`, `25,0 %`.
  ///
  /// Uses the real minus sign, not a hyphen, for the same reason the rest of
  /// the app does: at 13px a hyphen reads as a dash in a list of figures.
  static String percent(double value, String localeTag) {
    final text = intl.NumberFormat('#,##0.0', localeTag).format(value.abs());
    return '${value < 0 ? '−' : ''}$text %';
  }
}
