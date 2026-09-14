import 'package:flutter/foundation.dart';

import '../../data/models/agent.dart';
import '../../data/models/connected_page.dart';
import '../../data/models/product.dart';

/// What the tutorial has created so far.
///
/// The four steps each create a real record, and the later ones need what the
/// earlier ones made: the page connected in step 4 has to be attached to the
/// agent created in step 3, and `T6 — Prêt` lists all four with what was
/// actually created rather than generic ticks.
///
/// Registered for the life of the tutorial rather than app-wide, and dropped
/// when it ends. It is **not** persistence: quitting the app loses it, and the
/// merchant restarts at `T1a` — the coarse resume [PrefsStorage.tutorialPending]
/// provides. Real per-step resume would mean reading the created records back
/// from the server, which is a larger question than this holds.
class TutorialViewModel extends ChangeNotifier {
  Product? _product;
  Agent? _agent;
  ConnectedPage? _page;

  Product? get product => _product;
  Agent? get agent => _agent;
  ConnectedPage? get page => _page;

  /// The stock mode is not held here — it is an app-wide preference that
  /// outlives the tutorial, so it lives in `StockModeViewModel`.
  bool get hasProduct => _product != null;
  bool get hasAgent => _agent != null;
  bool get hasPage => _page != null;

  void productCreated(Product product) {
    _product = product;
    notifyListeners();
  }

  void agentCreated(Agent agent) {
    _agent = agent;
    notifyListeners();
  }

  void pageConnected(ConnectedPage page) {
    _page = page;
    notifyListeners();
  }

  /// Called when the tutorial finishes or is abandoned, so a second run in the
  /// same session does not inherit the first one's records.
  void reset() {
    _product = null;
    _agent = null;
    _page = null;
    notifyListeners();
  }
}
