import '../../core/error/app_exception.dart';
import '../../core/utils/validators.dart';
import '../../data/models/order.dart';
import '../../data/models/sale.dart';
import '../../data/repositories/sale_repository.dart';
import 'form_draft_store.dart';
import 'form_field_model.dart';

/// Why *Partielle* cannot be saved yet.
enum PartialProblem { missing, notBelowTotal }

/// `Modifier la vente` — the web's `stock/sales/[id]/edit`.
///
/// Only the payment and the notes can change; the lines and the prices are
/// fixed once the sale is recorded. The three status chips are the frame's,
/// but what is sent is always an **amount**: *Payée* is the total, *En
/// attente* is 0, and *Partielle* is what the merchant types — decided
/// 2026-10-01, because the API's legacy `partial` keeps the old amount and
/// would leave a pending sale pending.
class EditSaleViewModel extends FormViewModel {
  EditSaleViewModel({
    required SaleRepository sales,
    required this.saleId,
    Sale? initial,
    FormDraftStore? drafts,
  }) : _sales = sales {
    attachFields();
    _draft = keepDraft(drafts, 'editSale:$saleId', {'notes': notes, 'paid': paid});
    if (initial != null) _adopt(initial);
  }

  final SaleRepository _sales;
  final String saleId;

  final notes = FormFieldModel(validator: Validators.optional);

  /// The amount received, for *Partielle* only.
  final paid = FormFieldModel(validator: Validators.optional);

  @override
  List<FormFieldModel> get fields => [notes, paid];

  @override
  Map<String, String> get draftExtras => {
    if (_status case final status?) 'status': status.wire,
    if (_method case final method?) 'method': method.wire,
  };

  /// What a draft brought back, held until the sale is known.
  Map<String, String> _draft = const {};

  Sale? _sale;
  Sale? get sale => _sale;

  PaymentStatus? _status;
  PaymentStatus get status => _status ?? PaymentStatus.pending;

  PaymentMethod? _method;
  PaymentMethod? get method => _method;

  AppException? _saveError;
  AppException? get saveError => _saveError;

  Future<void> load() async {
    if (_sale != null) return;
    await run(() => _sales.get(saleId), onSuccess: _adopt, tag: 'editSale');
  }

  /// Fills the form from [sale] — or, after the app was left, from the draft
  /// that outlived the screen.
  void _adopt(Sale sale) {
    _sale = sale;
    final draft = _draft;
    _draft = const {};
    _status =
        PaymentStatus.values.where((s) => s.wire == draft['status']).firstOrNull ??
        sale.paymentStatus;
    // An unknown stored method (`other`) is left unset: the select shows
    // nothing chosen, and nothing is sent unless the merchant picks one.
    _method =
        PaymentMethod.values.where((m) => m.wire == draft['method']).firstOrNull ??
        sale.paymentMethod;
    if (!draft.containsKey('notes')) notes.controller.text = sale.notes ?? '';
    if (!draft.containsKey('paid') && sale.paymentStatus == PaymentStatus.partial) {
      paid.controller.text = _plain(sale.amountPaid);
    }
    safeNotify();
  }

  void setStatus(PaymentStatus value) {
    if (value == _status) return;
    _status = value;
    final sale = _sale;
    // Moving to *Partielle* starts from what was received, when there was
    // something; a blank field asks for the amount.
    if (value == PaymentStatus.partial &&
        paid.value.trim().isEmpty &&
        sale != null &&
        sale.amountPaid > 0 &&
        sale.amountPaid < sale.total) {
      paid.controller.text = _plain(sale.amountPaid);
    }
    saveDraft();
    safeNotify();
  }

  void setMethod(PaymentMethod? value) {
    _method = value;
    saveDraft();
    safeNotify();
  }

  double? get _typed => double.tryParse(paid.value.trim().replaceAll(',', '.'));

  /// The amount the chosen status means, or null while *Partielle* has no
  /// usable amount.
  double? get newAmountPaid {
    final sale = _sale;
    if (sale == null) return null;
    return switch (status) {
      PaymentStatus.paid => sale.total,
      PaymentStatus.pending => 0,
      PaymentStatus.partial => partialProblem == null ? _typed : null,
    };
  }

  /// *Partielle* means more than nothing and less than everything; either end
  /// is one of the other two chips.
  PartialProblem? get partialProblem {
    if (status != PaymentStatus.partial) return null;
    final value = _typed;
    final total = _sale?.total ?? 0;
    if (value == null || value <= 0) return PartialProblem.missing;
    if (value >= total) return PartialProblem.notBelowTotal;
    return null;
  }

  /// True when the cash received changes — the caisse is rewritten.
  bool get changesAmount {
    final next = newAmountPaid;
    final sale = _sale;
    return sale != null && next != null && (next - sale.amountPaid).abs() >= 0.005;
  }

  bool get isDirty {
    final sale = _sale;
    if (sale == null) return false;
    return changesAmount ||
        (_status != null && _status != sale.paymentStatus) ||
        _method != sale.paymentMethod ||
        notes.value.trim() != (sale.notes ?? '');
  }

  bool get canSave => _sale != null && !isBusy && partialProblem == null && isDirty;

  /// Saves, and returns the sale as it now stands (null when refused).
  Future<Sale?> save() async {
    final sale = _sale;
    if (sale == null || !canSave) return null;
    _saveError = null;
    final updated = await run(
      () => _sales.update(
        saleId,
        // Sent only when it moves, so the caisse is touched only then.
        amountPaid: changesAmount ? newAmountPaid : null,
        paymentMethod: _method != sale.paymentMethod ? _method : null,
        notes: notes.value.trim() != (sale.notes ?? '') ? notes.value : null,
      ),
      onError: (error) => _saveError = error,
      tag: 'saveSale',
    );
    return updated?.keepingLinesOf(sale);
  }

  static String _plain(double value) =>
      value == value.roundToDouble() ? value.round().toString() : value.toStringAsFixed(2);
}
