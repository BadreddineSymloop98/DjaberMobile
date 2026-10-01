import '../../core/error/result.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import 'base_view_model.dart';

/// Which of the three panels the order screen is showing.
///
/// The web calls them Review · Call outcome · Result, and the frames
/// *Vérification · Appel · Résultat*.
enum OrderStep { review, call, result }

/// `Détail de la commande` and the confirm wizard behind it — the web's
/// `ConfirmOrderModal`, which is one screen here rather than a modal.
///
/// The three steps are one view model because they are one transaction from
/// the merchant's side: the contact they corrected in step 1 is sent **with**
/// the call outcome in step 2, in the same breath, and step 3 only reports
/// what the server did.
class OrderDetailViewModel extends BaseViewModel {
  OrderDetailViewModel({
    required OrderRepository orders,
    required this.orderId,
    Order? initial,
  })  : _orders = orders,
        _order = initial;

  final OrderRepository _orders;
  final String orderId;

  Order? _order;
  Order? get order => _order;

  bool _notFound = false;
  bool get notFound => _notFound;

  OrderStep _step = OrderStep.review;
  OrderStep get step => _step;

  /// The outcome chosen in step 2, and what step 3 then reports on.
  CallResult? _outcome;
  CallResult? get outcome => _outcome;

  String _callNotes = '';
  String get callNotes => _callNotes;

  /// The server's word when a call changed nothing — a *Confirmée* logged
  /// against an order that had already been cancelled. Shown, not swallowed.
  String? _warning;
  String? get warning => _warning;

  bool _saving = false;
  bool get isSaving => _saving;

  // ---- The contact card's inline edit ----

  bool _editingContact = false;
  bool get isEditingContact => _editingContact;

  String? _draftPhone;
  String? _draftAddress;

  /// What the contact fields should show: the edit in progress if there is
  /// one, else what the order carries.
  String get contactPhone => _draftPhone ?? _order?.clientPhone ?? '';
  String get contactAddress => _draftAddress ?? _order?.clientAddress ?? '';

  /// True once the merchant has changed either field. They are **not** sent on
  /// their own — they ride along with the call outcome, which is what the
  /// frame's caption promises: *les modifications sont enregistrées avec le
  /// résultat de l'appel*.
  bool get hasContactEdits =>
      (_draftPhone != null && _draftPhone!.trim() != (_order?.clientPhone ?? '').trim()) ||
      (_draftAddress != null && _draftAddress!.trim() != (_order?.clientAddress ?? '').trim());

  void startEditingContact() {
    _editingContact = true;
    _draftPhone ??= _order?.clientPhone ?? '';
    _draftAddress ??= _order?.clientAddress ?? '';
    safeNotify();
  }

  void stopEditingContact() {
    _editingContact = false;
    safeNotify();
  }

  void setDraftPhone(String value) {
    _draftPhone = value;
    safeNotify();
  }

  void setDraftAddress(String value) {
    _draftAddress = value;
    safeNotify();
  }

  /// Whether confirming is possible right now.
  ///
  /// The backend does not refuse a confirmation without an address — it would
  /// happily confirm an order no courier can deliver. The web guards it and so
  /// does this: *Confirmée* stays unsendable until there is an address, or the
  /// order is a stopdesk pickup.
  bool get confirmNeedsAddress =>
      _outcome == CallResult.pickedUp &&
      !(_order?.isStopdesk ?? false) &&
      contactAddress.trim().isEmpty;

  bool get canSaveOutcome => _outcome != null && !_saving && !confirmNeedsAddress;

  void setOutcome(CallResult? value) {
    _outcome = value;
    safeNotify();
  }

  void setCallNotes(String value) {
    _callNotes = value;
  }

  void goTo(OrderStep value) {
    _step = value;
    safeNotify();
  }

  Future<void> load() async {
    final silent = _order != null;
    await run(
      () => _orders.get(orderId),
      onSuccess: (value) => _order = value,
      onError: (error) => _notFound = error.statusCode == 404,
      silent: silent,
      tag: 'orderDetail',
    );
    safeNotify();
  }

  /// Sends the call, and the contact corrections with it.
  ///
  /// Order matters: the call goes first because it is what the merchant just
  /// did, and it is also what may change the order's status (a *Confirmée*
  /// confirms it; a *Rejetée* **cancels** it outright, restocking every line).
  /// The contact update follows, and only when something actually changed —
  /// the fields are legal to send on a terminal order, which is what makes it
  /// safe even after a rejection cancelled it.
  Future<bool> saveOutcome() async {
    final order = _order;
    final outcome = _outcome;
    if (order == null || outcome == null || _saving) return false;

    _saving = true;
    _warning = null;
    clearError();
    safeNotify();

    final call = await _orders.addCall(order.id, result: outcome, notes: _callNotes);
    if (isDisposed) return false;

    if (call.errorOrNull case final error?) {
      _saving = false;
      setError(error);
      return false;
    }

    _order = call.valueOrNull!.order;
    _warning = call.valueOrNull!.warning;

    if (hasContactEdits) {
      final contact = await _orders.update(
        order.id,
        clientPhone: _draftPhone ?? order.clientPhone ?? '',
        clientAddress: _draftAddress ?? order.clientAddress ?? '',
      );
      if (isDisposed) return false;
      if (contact.valueOrNull case final updated?) {
        // The update response carries no client relation, but every column
        // this screen reads is on it.
        _order = updated;
      }
      // A contact write that failed does not undo the call: the attempt really
      // was made, and losing it would be worse than losing the correction.
      _draftPhone = null;
      _draftAddress = null;
    }

    _saving = false;
    _editingContact = false;
    _step = OrderStep.result;
    safeNotify();
    return true;
  }

  /// The order as the Send sheet returned it — sent, with its tracking.
  void adopt(Order updated) {
    _order = updated;
    safeNotify();
  }

  /// Step 3's *Marquer en préparation*.
  Future<Result<Order>> advanceTo(OrderStatus status) async {
    final result = await _orders.update(orderId, status: status);
    if (isDisposed) return result;
    if (result.valueOrNull case final updated?) {
      _order = updated;
      safeNotify();
    }
    return result;
  }
}
