import '../../core/error/result.dart';
import '../../data/models/sale.dart';
import '../../data/repositories/sale_repository.dart';
import 'base_view_model.dart';

/// `Détail de la vente` — the web's sale modal, as a screen.
class SaleDetailViewModel extends BaseViewModel {
  SaleDetailViewModel({required SaleRepository sales, required this.saleId, Sale? initial})
    : _sales = sales,
      _sale = initial;

  final SaleRepository _sales;
  final String saleId;

  Sale? _sale;
  Sale? get sale => _sale;

  bool _marking = false;
  bool get isMarkingPaid => _marking;

  /// The list's row draws at once; the full record (every line's sku) is
  /// fetched behind it.
  Future<void> load() async {
    await run(
      () => _sales.get(saleId),
      onSuccess: (value) => _sale = value,
      silent: _sale != null,
      tag: 'saleDetail',
    );
    safeNotify();
  }

  /// Back from *Modifier*: the edit screen hands the saved sale back, so there
  /// is nothing to refetch.
  void adopt(Sale updated) {
    _sale = updated;
    safeNotify();
  }

  /// *Marquer comme payée* — the full total as cash received. Sent as an
  /// amount, not the legacy status, so it means the same thing whatever was
  /// recorded before; the server posts the caisse income.
  ///
  /// Null when there was nothing to do — no sale yet, or one already on its
  /// way.
  Future<Result<Sale>?> markPaid() async {
    final sale = _sale;
    if (sale == null || _marking) return null;
    _marking = true;
    safeNotify();
    final result = await _sales.update(sale.id, amountPaid: sale.total);
    if (isDisposed) return result;
    _marking = false;
    if (result.valueOrNull case final updated?) _sale = updated.keepingLinesOf(sale);
    safeNotify();
    return result;
  }
}
