import 'package:flutter/foundation.dart';

import '../../core/storage/prefs_storage.dart';
import '../../data/models/stock_mode.dart';

/// Holds the chosen stock mode and persists it.
///
/// App-wide, and registered globally alongside [LocaleViewModel], because the
/// mode is not a property of any one screen — it decides what several of them
/// show. On the web it filters the whole stock section of the sidebar
/// (`dashboard/layout.tsx`, `filteredStockNavItems`), and it will do the same
/// job here: the menu, `16 — Aperçu du stock`, and the stock-mode section of
/// `11 — Paramètres` all read it.
///
/// **There is no network call.** The web keeps this in `localStorage` — no
/// column in `schema.prisma`, no endpoint — so [PrefsStorage] is the faithful
/// equivalent rather than a placeholder for an API that exists. A consequence
/// worth knowing: the preference is per-device, so a merchant who chooses
/// Advanced on the phone still gets whatever their browser has.
///
/// A `ChangeNotifier` rather than a plain getter on [PrefsStorage] so a screen
/// can *watch* it: changing the mode in settings has to re-render whatever is
/// already on screen, not wait for the next push of a route.
class StockModeViewModel extends ChangeNotifier {
  StockModeViewModel({required PrefsStorage prefs}) : _prefs = prefs {
    _mode = _prefs.stockMode;
  }

  final PrefsStorage _prefs;

  late StockMode _mode;

  /// Simple until the merchant chooses otherwise — the web's own default.
  StockMode get mode => _mode;

  /// The question nearly every caller actually asks. Reads better at a call
  /// site than comparing against an enum value, and keeps the enum from
  /// leaking into every widget that only wants to hide a section.
  bool get isAdvanced => _mode == StockMode.advanced;

  bool get isSimple => _mode == StockMode.simple;

  Future<void> setMode(StockMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    await _prefs.setStockMode(mode);
    notifyListeners();
  }
}
