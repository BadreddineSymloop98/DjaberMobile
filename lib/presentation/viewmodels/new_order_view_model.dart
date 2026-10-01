import 'dart:async';
import 'dart:convert';

import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../core/utils/phone.dart';
import '../../core/utils/validators.dart';
import '../../data/models/client.dart';
import '../../data/models/order.dart';
import '../../data/models/product.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/delivery_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/product_repository.dart';
import 'form_draft_store.dart';
import 'form_field_model.dart';

/// One line on the form, before it becomes a [NewOrderLine] on the wire.
class OrderDraftLine {
  OrderDraftLine({
    required this.product,
    this.variant,
    this.quantity = 1,
    required this.unitPrice,
  });

  final Product product;
  final ProductVariant? variant;
  int quantity;
  double unitPrice;

  String get name =>
      variant == null ? product.name : '${product.name} — ${variant!.name}';

  /// What the merchant may sell without going short. The backend refuses the
  /// whole order if any line is over, naming the product.
  int get available => variant?.quantity ?? product.quantity;

  double get total => unitPrice * quantity;

  /// Two lines are the same line when they point at the same thing — picking a
  /// product twice bumps the quantity rather than repeating it, as the web
  /// does.
  bool matches(Product other, ProductVariant? otherVariant) =>
      other.id == product.id && otherVariant?.id == variant?.id;

  /// Enough to find the product again after the app was left. The product
  /// itself is **not** kept: it is refetched on the way back, so a price or a
  /// stock level that moved while the merchant was away is the one they see.
  Map<String, dynamic> toDraft() => {
        'productId': product.id,
        if (variant != null) 'variantId': variant!.id,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
}

/// What the form is refusing to send, if anything.
enum NewOrderProblem {
  noItems,
  noClientName,
  noPhone,
  noWilaya,
  noAddress,
}

/// `Nouvelle commande` — the web's `stock/orders/new`.
///
/// **Creating an order takes stock immediately**, whatever status it is given,
/// so this form is deliberately strict before it sends: a line over its
/// available quantity, or a missing phone, is caught here rather than coming
/// back as a 400 with the order half-made.
///
/// **It also survives being rebuilt.** Leaving the app used to replay the
/// splash as a route and rebuild this screen from scratch; the replay is an
/// overlay now (`SessionViewModel.replaySplash`) and leaves it alone, but
/// every typed field and every choice is still written to the
/// [FormDraftStore] on change and read back in the constructor; the product
/// lines are restored once the catalogue has reloaded.
class NewOrderViewModel extends FormViewModel {
  NewOrderViewModel({
    required OrderRepository orders,
    required ClientRepository clients,
    required ProductRepository products,
    required DeliveryRepository delivery,
    FormDraftStore? drafts,
  })  : _orders = orders,
        _clients = clients,
        _products = products,
        _delivery = delivery {
    attachFields();
    final saved = keepDraft(drafts, 'newOrder', {
      'name': name,
      'phone': phone,
      'address': address,
      'commune': commune,
      'notes': notes,
      'amountPaid': paid,
    });

    // The choices that are not text. The ids resolve again once [load] has
    // refilled the lists they came from.
    _clientId = _nonEmpty(saved['clientId']);
    _wilayaId = int.tryParse(saved['wilayaId'] ?? '');
    _isStopdesk = saved['isStopdesk'] == 'true';
    _status = OrderStatus.values
        .where((s) => s.wire == saved['status'])
        .firstOrNull ??
        OrderStatus.pending;
    _paymentMethod = PaymentMethod.values
        .where((m) => m.wire == saved['paymentMethod'])
        .firstOrNull ??
        PaymentMethod.cash;
    if (DateTime.tryParse(saved['orderDate'] ?? '') case final date?) {
      _orderDate = date;
    }
    _savedLines = saved['lines'];
  }

  final OrderRepository _orders;
  final ClientRepository _clients;
  final ProductRepository _products;
  final DeliveryRepository _delivery;

  // ---- Fields ----

  /// Optional because a chosen client supplies both; the form's own rule (see
  /// [problem]) is what insists on a name and a phone one way or the other.
  final name = FormFieldModel(validator: Validators.optional);
  final phone = FormFieldModel(validator: Validators.optional);
  final address = FormFieldModel(validator: Validators.optional);
  final commune = FormFieldModel(validator: Validators.optional);
  final notes = FormFieldModel(validator: Validators.optional);
  final paid = FormFieldModel(validator: Validators.optional);

  @override
  List<FormFieldModel> get fields => [name, phone, address, commune, notes, paid];

  @override
  Map<String, String> get draftExtras => {
        'clientId': _client?.id ?? _clientId ?? '',
        'wilayaId': _wilayaId?.toString() ?? '',
        'isStopdesk': '$_isStopdesk',
        'status': _status.wire,
        'paymentMethod': _paymentMethod.wire,
        'orderDate': _orderDate.toIso8601String(),
        'lines': jsonEncode([for (final line in _lines) line.toDraft()]),
      };

  // ---- What the pickers choose from ----

  List<Client> _clientList = const [];
  List<Client> get clients => _clientList;

  List<Product> _productList = const [];

  /// Only what can actually be sold: an active product with stock, or one with
  /// at least one active variant that has stock. A product nobody can order is
  /// noise in a search field.
  List<Product> get sellableProducts => [
        for (final product in _productList)
          if (_isSellable(product)) product,
      ];

  List<Wilaya> _wilayaList = const [];
  List<Wilaya> get wilayas => _wilayaList;

  static bool _isSellable(Product product) {
    if (!product.isActive) return false;
    if (!product.hasVariants) return product.quantity > 0;
    return product.variants.any((v) => v.isActive && v.quantity > 0);
  }

  // ---- The form's own state ----

  DateTime _orderDate = DateTime.now();
  DateTime get orderDate => _orderDate;

  Client? _client;
  Client? get client => _client;

  /// The client id read back from a draft, held until [load] can turn it into
  /// a real client again.
  String? _clientId;

  /// The lines read back from a draft, held for the same reason.
  String? _savedLines;

  /// Lines a draft could not restore because the product has since gone or
  /// sold out. Surfaced rather than swallowed: it changes the total.
  int _droppedLines = 0;
  int get droppedDraftLines => _droppedLines;

  /// The name and phone that will be sent: a chosen client's own, else what
  /// was typed. The web makes the same substitution.
  String get clientName => _client?.name ?? name.value;
  String get clientPhone => _client?.phone ?? phone.value;

  int? _wilayaId;
  int? get wilayaId => _wilayaId;

  bool _isStopdesk = false;
  bool get isStopdesk => _isStopdesk;

  final List<OrderDraftLine> _lines = [];
  List<OrderDraftLine> get lines => List.unmodifiable(_lines);

  double get amountPaid => double.tryParse(paid.value.trim()) ?? 0;

  OrderStatus _status = OrderStatus.pending;
  OrderStatus get status => _status;

  PaymentMethod _paymentMethod = PaymentMethod.cash;
  PaymentMethod get paymentMethod => _paymentMethod;

  double _deliveryFee = 0;
  double get deliveryFee => _deliveryFee;

  bool _quoting = false;

  /// True while the fee for a freshly chosen wilaya is being fetched — the
  /// summary shows `…` rather than a stale figure.
  bool get isQuotingFee => _quoting;

  // ---- The figures ----

  double get subtotal => _lines.fold(0, (sum, line) => sum + line.total);

  double get total => subtotal + _deliveryFee;

  double get remaining {
    final left = total - amountPaid;
    return left > 0 ? left : 0;
  }

  PaymentStatus get paymentStatus => remaining <= 0 && total > 0
      ? PaymentStatus.paid
      : amountPaid > 0
          ? PaymentStatus.partial
          : PaymentStatus.pending;

  // ---- Loading ----

  Future<void> load() async {
    await run(
      () async {
        final results = await Future.wait([
          _clients.list(),
          _products.list(limit: 200),
          _delivery.wilayas(),
        ]);
        for (final result in results) {
          if (result.errorOrNull case final error?) {
            return Result<void>.failure(error);
          }
        }
        _clientList = results[0].valueOrNull! as List<Client>;
        _productList = (results[1].valueOrNull! as ProductPage).products;
        _wilayaList = results[2].valueOrNull! as List<Wilaya>;
        return const Result<void>.success(null);
      },
      tag: 'newOrder',
    );
    _restoreDraft();
    safeNotify();
  }

  /// Turns the ids a draft kept back into the client and the lines they named.
  ///
  /// Only runs once, and only against a catalogue that actually loaded —
  /// otherwise a failed load would quietly throw the merchant's lines away.
  void _restoreDraft() {
    if (_productList.isEmpty && _clientList.isEmpty) return;

    if (_clientId case final id?) {
      _client = _clientList.where((c) => c.id == id).firstOrNull;
      _clientId = null;
    }

    final saved = _savedLines;
    _savedLines = null;
    if (saved == null || saved.isEmpty || _lines.isNotEmpty) return;

    try {
      final decoded = jsonDecode(saved);
      if (decoded is! List) return;
      for (final row in decoded.whereType<Map<String, dynamic>>()) {
        final product =
            _productList.where((p) => p.id == row['productId']).firstOrNull;
        if (product == null) {
          _droppedLines++;
          continue;
        }
        final variantId = row['variantId'];
        final variant = variantId == null
            ? null
            : product.variants.where((v) => v.id == variantId).firstOrNull;
        // A variant that has gone is a different line, not this one.
        if (variantId != null && variant == null) {
          _droppedLines++;
          continue;
        }
        _lines.add(OrderDraftLine(
          product: product,
          variant: variant,
          quantity: (row['quantity'] as num?)?.toInt() ?? 1,
          unitPrice: (row['unitPrice'] as num?)?.toDouble() ??
              variant?.sellingPrice ??
              product.sellingPrice,
        ));
      }
    } on FormatException {
      // A draft this old or this broken is not worth a crash.
    }
    if (_lines.isNotEmpty || _droppedLines > 0) unawaited(_quoteFee());
  }

  // ---- Editing ----

  void setOrderDate(DateTime value) {
    _orderDate = value;
    saveDraft();
    safeNotify();
  }

  void setClient(Client? value) {
    _client = value;
    // The web pre-fills the address from the client and leaves it editable; it
    // does not overwrite an address the merchant has already typed.
    if (value?.address case final known? when address.value.trim().isEmpty) {
      address.controller.text = known;
    }
    saveDraft();
    safeNotify();
  }

  Future<void> setWilaya(int? value) async {
    if (value == _wilayaId) return;
    _wilayaId = value;
    saveDraft();
    safeNotify();
    await _quoteFee();
  }

  Future<void> setStopdesk(bool value) async {
    if (value == _isStopdesk) return;
    _isStopdesk = value;
    saveDraft();
    safeNotify();
    await _quoteFee();
  }

  /// The fee follows the wilaya and the stopdesk tick, as the web's quote does.
  /// A failure leaves it at zero rather than blocking the form — the server
  /// recomputes it on create anyway.
  Future<void> _quoteFee() async {
    final wilaya = _wilayaId;
    if (wilaya == null) {
      _deliveryFee = 0;
      safeNotify();
      return;
    }
    _quoting = true;
    safeNotify();
    final result = await _delivery.quote(wilayaId: wilaya, isStopdesk: _isStopdesk);
    if (isDisposed) return;
    _deliveryFee = result.valueOrNull?.fee ?? 0;
    _quoting = false;
    safeNotify();
  }

  void addLine(Product product, [ProductVariant? variant]) {
    final existing = _lines.where((l) => l.matches(product, variant)).firstOrNull;
    if (existing != null) {
      existing.quantity += 1;
    } else {
      _lines.add(OrderDraftLine(
        product: product,
        variant: variant,
        unitPrice: variant?.sellingPrice ?? product.sellingPrice,
      ));
    }
    saveDraft();
    safeNotify();
  }

  void removeLine(int index) {
    if (index < 0 || index >= _lines.length) return;
    _lines.removeAt(index);
    saveDraft();
    safeNotify();
  }

  void setLineQuantity(int index, int quantity) {
    if (index < 0 || index >= _lines.length) return;
    _lines[index].quantity = quantity < 1 ? 1 : quantity;
    saveDraft();
    safeNotify();
  }

  void setLinePrice(int index, double price) {
    if (index < 0 || index >= _lines.length) return;
    _lines[index].unitPrice = price < 0 ? 0 : price;
    saveDraft();
    safeNotify();
  }

  void payInFull() {
    paid.controller.text = total.round().toString();
    safeNotify();
  }

  void setStatus(OrderStatus value) {
    _status = value;
    saveDraft();
    safeNotify();
  }

  void setPaymentMethod(PaymentMethod value) {
    _paymentMethod = value;
    saveDraft();
    safeNotify();
  }

  /// Clears the notice about lines a draft could not restore, once it has been
  /// read.
  void acknowledgeDroppedLines() {
    if (_droppedLines == 0) return;
    _droppedLines = 0;
    safeNotify();
  }

  // ---- Validation ----

  /// Lines asking for more than there is. Named, because the server's own 400
  /// names them one at a time and the merchant would fix them one at a time.
  List<OrderDraftLine> get overstockedLines =>
      [for (final line in _lines) if (line.quantity > line.available) line];

  /// What is missing, in the order the form reads — so the message points at
  /// the first field to fix rather than the last.
  NewOrderProblem? get problem {
    if (_lines.isEmpty) return NewOrderProblem.noItems;
    if (clientName.trim().isEmpty) return NewOrderProblem.noClientName;
    if (clientPhone.trim().isEmpty) return NewOrderProblem.noPhone;
    if (_wilayaId == null) return NewOrderProblem.noWilaya;
    // Stopdesk is a pickup at the courier's counter, so it needs no address —
    // the web's own exemption.
    if (!_isStopdesk && address.value.trim().isEmpty) {
      return NewOrderProblem.noAddress;
    }
    return null;
  }

  bool get canSubmit => problem == null && overstockedLines.isEmpty && !isBusy;

  AppException? _submitError;
  AppException? get submitError => _submitError;

  /// Creates the order. Returns it, or null when the server refused.
  ///
  /// Named for what it does rather than `submit`, which [FormViewModel]
  /// already owns for revealing field errors.
  Future<Order?> createOrder() async {
    if (!canSubmit) return null;
    _submitError = null;
    return run(
      () => _orders.create(
        clientId: _client?.id,
        clientName: clientName,
        // Digits only, never the spacing — see [Phone].
        clientPhone: Phone.digits(clientPhone),
        clientAddress: address.value,
        items: [
          for (final line in _lines)
            NewOrderLine(
              productId: line.product.id,
              variantId: line.variant?.id,
              quantity: line.quantity,
              unitPrice: line.unitPrice,
            ),
        ],
        amountPaid: amountPaid,
        paymentMethod: _paymentMethod,
        status: _status,
        notes: notes.value,
        wilayaId: _wilayaId,
        communeName: commune.value,
        isStopdesk: _isStopdesk,
        orderDate: _orderDate,
      ),
      onError: (error) => _submitError = error,
      tag: 'createOrder',
    );
  }

  static String? _nonEmpty(String? value) =>
      value == null || value.isEmpty ? null : value;
}
