import 'package:flutter/widgets.dart';

import '../../core/error/result.dart';
import '../../core/utils/validators.dart';
import '../../data/models/delivery.dart';
import '../../data/repositories/delivery_repository.dart';
import 'base_view_model.dart';

/// One wilaya's editable prices — what the row shows against what is saved.
class FeeRowDraft {
  FeeRowDraft(this.saved)
      : home = TextEditingController(text: _text(saved.homePrice)),
        stopdesk = TextEditingController(text: _text(saved.stopdeskPrice)),
        returns = TextEditingController(text: _text(saved.returnPrice));

  DeliveryFeeRow saved;
  final TextEditingController home;
  final TextEditingController stopdesk;
  final TextEditingController returns;

  /// A save or a reset is running for this row.
  bool busy = false;

  static String _text(double v) => v == v.roundToDouble() ? '${v.round()}' : '$v';

  double? _parse(TextEditingController c) {
    final v = Validators.parseAmount(c.text);
    return v != null && v >= 0 ? v : null;
  }

  double? get homeValue => _parse(home);
  double? get stopdeskValue => _parse(stopdesk);
  double? get returnValue => _parse(returns);

  /// Every field holds a price the server accepts (a number ≥ 0).
  bool get isValid => homeValue != null && stopdeskValue != null && returnValue != null;

  /// Something differs from what is saved — *Enregistrer* shows.
  bool get isDirty =>
      homeValue != saved.homePrice || stopdeskValue != saved.stopdeskPrice || returnValue != saved.returnPrice;

  void reset(DeliveryFeeRow row) {
    saved = row;
    home.text = _text(row.homePrice);
    stopdesk.text = _text(row.stopdeskPrice);
    returns.text = _text(row.returnPrice);
  }

  void dispose() {
    home.dispose();
    stopdesk.dispose();
    returns.dispose();
  }
}

/// `Delivery fees per wilaya` (Figma `661:16208`) — the web's `stock/delivery/fees`.
///
/// The table is always 58 rows (defaults merged with the merchant's rules), so
/// the search filters what is loaded rather than asking the server.
class DeliveryFeesViewModel extends BaseViewModel {
  DeliveryFeesViewModel({required DeliveryRepository delivery}) : _delivery = delivery;

  final DeliveryRepository _delivery;

  final Map<int, FeeRowDraft> _drafts = {};
  List<int> _order = const [];

  String _search = '';

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  /// *Compléter les manquants* or *Tout réinitialiser* is running.
  bool _seeding = false;
  bool get isSeeding => _seeding;

  /// The rows the search keeps, in wilaya order.
  List<FeeRowDraft> get rows {
    final q = _search.trim().toLowerCase();
    return [
      for (final id in _order)
        if (q.isEmpty || _matches(_drafts[id]!.saved, q)) _drafts[id]!,
    ];
  }

  int get total => _order.length;

  bool get hasUnsaved => _drafts.values.any((d) => d.isDirty);

  static bool _matches(DeliveryFeeRow row, String q) =>
      row.name.toLowerCase().contains(q) || row.nameAr.contains(q) || row.code.contains(q) || '${row.wilayaId}' == q;

  Future<void> load() async {
    await run(
      _delivery.fees,
      onSuccess: _adopt,
      silent: _loadedOnce,
      tag: 'deliveryFees',
    );
    _loadedOnce = true;
    safeNotify();
  }

  /// Takes the server's table. A row with unsaved edits keeps them — a reload
  /// after another row's save must not wipe what the merchant is typing.
  void _adopt(List<DeliveryFeeRow> table) {
    for (final row in table) {
      final draft = _drafts[row.wilayaId];
      if (draft == null) {
        _drafts[row.wilayaId] = FeeRowDraft(row);
      } else if (!draft.isDirty) {
        draft.reset(row);
      } else {
        draft.saved = row;
      }
    }
    _order = [for (final row in table) row.wilayaId];
  }

  void setSearch(String value) {
    if (value == _search) return;
    _search = value;
    safeNotify();
  }

  /// A field changed: the row's buttons follow.
  void touched() => safeNotify();

  Future<Result<void>> save(FeeRowDraft draft) async {
    if (!draft.isValid) return const Result.success(null);
    draft.busy = true;
    safeNotify();
    final result = await _delivery.saveFee(
      wilayaId: draft.saved.wilayaId,
      homePrice: draft.homeValue!,
      stopdeskPrice: draft.stopdeskValue!,
      returnPrice: draft.returnValue!,
    );
    if (isDisposed) return result;
    draft.busy = false;
    if (result.isSuccess) {
      draft.reset(DeliveryFeeRow(
        wilayaId: draft.saved.wilayaId,
        code: draft.saved.code,
        name: draft.saved.name,
        nameAr: draft.saved.nameAr,
        homePrice: draft.homeValue!,
        stopdeskPrice: draft.stopdeskValue!,
        returnPrice: draft.returnValue!,
        isCustom: true,
      ));
    }
    safeNotify();
    return result;
  }

  /// *Réinitialiser* — drops the rule; the row reloads with the default.
  Future<Result<void>> resetRow(FeeRowDraft draft) async {
    draft.busy = true;
    safeNotify();
    final result = await _delivery.resetFee(draft.saved.wilayaId);
    if (isDisposed) return result;
    draft.busy = false;
    if (result.isSuccess) {
      // The default prices only exist server-side: read the table again, and
      // let this row take them even though it was the one just touched.
      final table = await _delivery.fees();
      if (isDisposed) return result;
      if (table.valueOrNull case final rows?) {
        final fresh = rows.where((r) => r.wilayaId == draft.saved.wilayaId).firstOrNull;
        if (fresh != null) draft.reset(fresh);
        _adopt(rows);
      }
    }
    safeNotify();
    return result;
  }

  /// [overwrite] false: *Compléter les manquants* (only wilayas without a
  /// rule). True: *Tout réinitialiser* (every custom price replaced). Returns
  /// how many rows the server wrote.
  Future<Result<int>> seed({required bool overwrite}) async {
    _seeding = true;
    safeNotify();
    final result = await _delivery.seedFees(overwrite: overwrite);
    if (isDisposed) return result;
    if (result.isSuccess && overwrite) {
      // Everything was replaced: unsaved edits are moot.
      for (final d in _drafts.values) {
        d.reset(d.saved);
      }
    }
    _seeding = false;
    await load();
    return result;
  }

  @override
  void dispose() {
    for (final d in _drafts.values) {
      d.dispose();
    }
    super.dispose();
  }
}
