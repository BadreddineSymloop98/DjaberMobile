import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../data/models/purchase.dart';
import '../../data/repositories/purchase_repository.dart';
import 'base_view_model.dart';

/// `Détail de l'achat` — the web's purchase modal, as a screen.
class PurchaseDetailViewModel extends BaseViewModel {
  PurchaseDetailViewModel({
    required PurchaseRepository purchases,
    required this.purchaseId,
    Purchase? initial,
  }) : _purchases = purchases,
       _purchase = initial;

  final PurchaseRepository _purchases;
  final String purchaseId;

  Purchase? _purchase;
  Purchase? get purchase => _purchase;

  /// Which action is on its way, so only its button spins and the others wait.
  PurchaseAction? _busy;
  PurchaseAction? get busyAction => _busy;

  /// Whether anything changed here, for the list below to refresh.
  bool _changed = false;
  bool get changed => _changed;

  Future<void> load() async {
    await run(
      () => _purchases.get(purchaseId),
      onSuccess: (value) => _purchase = value,
      silent: _purchase != null,
      tag: 'purchaseDetail',
    );
    safeNotify();
  }

  /// The purchase as the receive sheet returned it.
  void adopt(Purchase updated) {
    final before = _purchase;
    _purchase = before == null ? updated : updated.keepingLabelsOf(before);
    _changed = true;
    safeNotify();
  }

  /// *Marquer comme payé*: the full total, sent as an amount. The server posts
  /// the caisse expense.
  Future<Result<PurchaseUpdate>?> markPaid() {
    final purchase = _purchase;
    if (purchase == null) return Future.value();
    return _update(
      PurchaseAction.markPaid,
      () => _purchases.update(purchase.id, amountPaid: purchase.total),
    );
  }

  /// *Annuler l'achat*: received units leave stock, the payment goes to 0 and
  /// the caisse expense is removed — all server-side, in one transaction.
  Future<Result<PurchaseUpdate>?> cancel() {
    final purchase = _purchase;
    if (purchase == null) return Future.value();
    return _update(
      PurchaseAction.cancel,
      () => _purchases.update(purchase.id, status: PurchaseStatus.cancelled),
    );
  }

  Future<Result<PurchaseUpdate>?> _update(
    PurchaseAction action,
    Future<Result<PurchaseUpdate>> Function() call,
  ) async {
    final before = _purchase;
    if (before == null || _busy != null) return null;
    _busy = action;
    safeNotify();
    final result = await call();
    if (isDisposed) return result;
    _busy = null;
    if (result.valueOrNull case final value?) {
      _purchase = value.purchase.keepingLabelsOf(before);
      _changed = true;
    } else if (result.errorOrNull is NotFoundException) {
      _changed = true;
    }
    safeNotify();
    return result;
  }
}

enum PurchaseAction { markPaid, cancel }

/// `Receive items` — the sheet over the list or the detail.
///
/// Each open line starts at what is still to come — the usual delivery is the
/// whole of it — and the merchant lowers what did not arrive. The quantities
/// are deltas (what came **now**), as the API takes them.
class ReceivePurchaseViewModel extends BaseViewModel {
  ReceivePurchaseViewModel({required PurchaseRepository purchases, required this.purchase})
    : _purchases = purchases {
    for (final item in purchase.items) {
      _quantities[item.id] = item.toReceive;
    }
  }

  final PurchaseRepository _purchases;
  final Purchase purchase;

  final Map<String, int> _quantities = {};

  int quantityOf(PurchaseItem item) => _quantities[item.id] ?? 0;

  void setQuantity(PurchaseItem item, int value) {
    _quantities[item.id] = value < 0 ? 0 : value;
    safeNotify();
  }

  /// Lines asking for more than is still to come — the server's `only N
  /// remaining`, caught before sending.
  bool isOver(PurchaseItem item) => quantityOf(item) > item.toReceive;

  int get totalNow => _quantities.values.fold(0, (sum, q) => sum + q);

  bool get canSubmit => !isBusy && totalNow > 0 && !purchase.items.any(isOver);

  AppException? _submitError;
  AppException? get submitError => _submitError;

  Future<Purchase?> submit() async {
    if (!canSubmit) return null;
    _submitError = null;
    final updated = await run(
      () => _purchases.receive(purchase.id, {
        for (final item in purchase.items)
          if (quantityOf(item) > 0) item.id: quantityOf(item),
      }),
      onError: (error) => _submitError = error,
      tag: 'receivePurchase',
    );
    return updated?.keepingLabelsOf(purchase);
  }
}
