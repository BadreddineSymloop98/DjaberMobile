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
///
/// **Unsent drafts.** A step's form lives in its screen, and the screen does
/// not survive the merchant leaving the app: on return the splash replays
/// (`SessionViewModel.resetBoot` runs on pause), the router swaps the step out
/// for it, and the step comes back as a new, empty screen. Changing the phone's
/// language in Settings is the everyday way to hit that. So `T3` and `T4` hand
/// their unsent values here as they close and take them back as they open.
/// Held in memory like everything else here — a process death still loses them.
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

  /// Unsent form values, by step route, then by field.
  final Map<String, Map<String, String>> _drafts = {};

  /// What [step] left unsent when it last closed. Empty when nothing was.
  Map<String, String> draftFor(String step) => _drafts[step] ?? const {};

  /// Keeps [values] until [step] opens again.
  ///
  /// Notifies nobody, deliberately: nothing on screen shows a draft, and this
  /// is called from a screen's `dispose`, while the tree is being torn down.
  void saveDraft(String step, Map<String, String> values) {
    _drafts[step] = Map.unmodifiable(values);
  }

  /// Drops [step]'s draft once the step has succeeded — its values are spent.
  void clearDraft(String step) {
    _drafts.remove(step);
  }

  /// Called when the tutorial finishes or is abandoned, so a second run in the
  /// same session does not inherit the first one's records.
  void reset() {
    _product = null;
    _agent = null;
    _page = null;
    _drafts.clear();
    notifyListeners();
  }
}
