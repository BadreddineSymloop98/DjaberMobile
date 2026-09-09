/// How much of the stock module the merchant sees.
///
/// **This is a device preference, not a backend field.** The web keeps it in
/// `localStorage` under `stockMode` and reads it in `dashboard/layout.tsx` to
/// filter its own nav; there is no column for it in `schema.prisma` and no
/// endpoint that sets it. Mobile therefore stores it in [PrefsStorage], which
/// is the same thing on this platform — not a stub standing in for a call.
///
/// A consequence worth knowing: because it is per-device, a merchant who sets
/// Advanced on the phone still gets whatever their browser has.
enum StockMode {
  /// The web's default. Products, categories and orders only.
  simple('simple'),

  /// Adds suppliers, clients, sales, purchases, caisse, movements, delivery.
  advanced('advanced');

  const StockMode(this.wireName);

  /// The string the web writes to `localStorage`. Kept identical so the two
  /// platforms could ever share it without a translation step.
  final String wireName;

  static StockMode fromName(String? value) => switch (value) {
        'advanced' => StockMode.advanced,
        _ => StockMode.simple,
      };
}
