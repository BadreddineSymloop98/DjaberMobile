import 'dart:convert';

import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../core/utils/phone.dart';
import '../../core/utils/validators.dart';
import '../../data/models/client.dart';
import '../../data/models/order.dart';
import '../../data/models/product.dart';
import '../../data/models/sale.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/sale_repository.dart';
import 'form_draft_store.dart';
import 'form_field_model.dart';
import 'new_order_view_model.dart';

/// `Nouvelle vente` — the web's `stock/sales/new`: a walk-in sale, paid (or
/// not) at the counter.
///
/// Built like *Nouvelle commande*, without the courier: the same product
/// picker and lines, the same refusal to send a line over its stock — the
/// server would roll the whole sale back — and the same draft that survives
/// the app being left.
///
/// **The amount paid follows the total** until the merchant types one, as the
/// web's does (an empty field there means paid in full): most counter sales
/// are paid on the spot, and the frame shows the total already in the field.
class NewSaleViewModel extends FormViewModel {
  NewSaleViewModel({
    required SaleRepository sales,
    required ClientRepository clients,
    required ProductRepository products,
    FormDraftStore? drafts,
  }) : _sales = sales,
       _clients = clients,
       _products = products {
    attachFields();
    final saved = keepDraft(drafts, 'newSale', {
      'name': name,
      'phone': phone,
      'notes': notes,
      'amountPaid': paid,
    });
    _clientId = saved['clientId'];
    _paidEdited = saved['paidEdited'] == 'true';
    _method =
        PaymentMethod.values.where((m) => m.wire == saved['paymentMethod']).firstOrNull ??
        PaymentMethod.cash;
    if (DateTime.tryParse(saved['saleDate'] ?? '') case final date?) _saleDate = date;
    _savedLines = saved['lines'];
    paid.controller.addListener(() {
      if (!_syncingPaid) _paidEdited = true;
    });
  }

  final SaleRepository _sales;
  final ClientRepository _clients;
  final ProductRepository _products;

  // ---- Fields ----

  /// Both optional: a walk-in customer often stays anonymous, and the API
  /// stores whatever is typed — there is no client record behind a sale.
  final name = FormFieldModel(validator: Validators.optional);
  final phone = FormFieldModel(validator: Validators.optional);
  final notes = FormFieldModel(validator: Validators.optional);
  final paid = FormFieldModel(validator: Validators.optional);

  @override
  List<FormFieldModel> get fields => [name, phone, notes, paid];

  @override
  Map<String, String> get draftExtras => {
    'clientId': _client?.id ?? _clientId ?? '',
    'paidEdited': '$_paidEdited',
    'paymentMethod': _method.wire,
    'saleDate': _saleDate.toIso8601String(),
    'lines': jsonEncode([for (final line in _lines) line.toDraft()]),
  };

  // ---- What the pickers choose from ----

  List<Client> _clientList = const [];
  List<Client> get clients => _clientList;

  List<Product> _productList = const [];

  /// An active product with stock, or with an active variant that has some.
  List<Product> get sellableProducts => [
    for (final product in _productList)
      if (product.isActive &&
          (product.hasVariants
              ? product.variants.any((v) => v.isActive && v.quantity > 0)
              : product.quantity > 0))
        product,
  ];

  bool _loaded = false;
  bool get isLoaded => _loaded;

  // ---- The form's own state ----

  DateTime _saleDate = DateTime.now();
  DateTime get saleDate => _saleDate;

  Client? _client;
  Client? get client => _client;
  String? _clientId;
  String? _savedLines;

  int _droppedLines = 0;
  int get droppedDraftLines => _droppedLines;

  final List<OrderDraftLine> _lines = [];
  List<OrderDraftLine> get lines => List.unmodifiable(_lines);

  PaymentMethod _method = PaymentMethod.cash;
  PaymentMethod get paymentMethod => _method;

  /// False while the amount paid is still the one this form wrote.
  bool _paidEdited = false;
  bool _syncingPaid = false;

  /// What is sent as the customer: a chosen client's own, else what was typed.
  String get customerName => _client?.name ?? name.value;
  String get customerPhone => _client?.phone ?? phone.value;

  // ---- The figures ----

  double get total => _lines.fold(0, (sum, line) => sum + line.total);

  double get amountPaid => double.tryParse(paid.value.trim().replaceAll(',', '.')) ?? 0;

  double get remaining {
    final left = total - amountPaid;
    return left > 0 ? left : 0;
  }

  /// What the server will derive from the amount, shown before it is sent.
  PaymentStatus get paymentStatus => remaining <= 0
      ? PaymentStatus.paid
      : amountPaid > 0
      ? PaymentStatus.partial
      : PaymentStatus.pending;

  // ---- Loading ----

  Future<void> load() async {
    await run(() async {
      final results = await Future.wait([_clients.list(), _products.list(limit: 200)]);
      for (final result in results) {
        if (result.errorOrNull case final error?) return Result<void>.failure(error);
      }
      _clientList = results[0].valueOrNull! as List<Client>;
      _productList = (results[1].valueOrNull! as ProductPage).products;
      _loaded = true;
      return const Result<void>.success(null);
    }, tag: 'newSale');
    _restoreDraft();
    safeNotify();
  }

  void _restoreDraft() {
    if (!_loaded) return;
    if (_clientId case final id? when id.isNotEmpty) {
      _client = _clientList.where((c) => c.id == id).firstOrNull;
    }
    _clientId = null;

    final saved = _savedLines;
    _savedLines = null;
    if (saved == null || saved.isEmpty || _lines.isNotEmpty) return;
    try {
      final decoded = jsonDecode(saved);
      if (decoded is! List) return;
      for (final row in decoded.whereType<Map<String, dynamic>>()) {
        final product = _productList.where((p) => p.id == row['productId']).firstOrNull;
        final variantId = row['variantId'];
        final variant = variantId == null || product == null
            ? null
            : product.variants.where((v) => v.id == variantId).firstOrNull;
        if (product == null || (variantId != null && variant == null)) {
          _droppedLines++;
          continue;
        }
        _lines.add(
          OrderDraftLine(
            product: product,
            variant: variant,
            quantity: (row['quantity'] as num?)?.toInt() ?? 1,
            unitPrice:
                (row['unitPrice'] as num?)?.toDouble() ??
                variant?.sellingPrice ??
                product.sellingPrice,
          ),
        );
      }
    } on FormatException {
      // Not worth a crash.
    }
    _syncPaid();
  }

  // ---- Editing ----

  /// The day picked, at the current time of day: a sale backdated to a past
  /// day keeps a plausible hour, and today's is simply now. The API refuses a
  /// date more than 24 h ahead, and the picker offers none after today.
  void setSaleDate(DateTime day) {
    final now = DateTime.now();
    _saleDate = DateTime(day.year, day.month, day.day, now.hour, now.minute, now.second);
    saveDraft();
    safeNotify();
  }

  void setClient(Client? value) {
    _client = value;
    saveDraft();
    safeNotify();
  }

  void addLine(Product product, [ProductVariant? variant]) {
    final existing = _lines.where((l) => l.matches(product, variant)).firstOrNull;
    if (existing != null) {
      existing.quantity += 1;
    } else {
      _lines.add(
        OrderDraftLine(
          product: product,
          variant: variant,
          unitPrice: variant?.sellingPrice ?? product.sellingPrice,
        ),
      );
    }
    _changed();
  }

  void removeLine(int index) {
    if (index < 0 || index >= _lines.length) return;
    _lines.removeAt(index);
    _changed();
  }

  void setLineQuantity(int index, int quantity) {
    if (index < 0 || index >= _lines.length) return;
    _lines[index].quantity = quantity < 1 ? 1 : quantity;
    _changed();
  }

  void setLinePrice(int index, double price) {
    if (index < 0 || index >= _lines.length) return;
    _lines[index].unitPrice = price < 0 ? 0 : price;
    _changed();
  }

  void setPaymentMethod(PaymentMethod value) {
    _method = value;
    saveDraft();
    safeNotify();
  }

  /// *Payée en totalité*: the amount goes back to following the total.
  void payInFull() {
    _paidEdited = false;
    _syncPaid();
    safeNotify();
  }

  void acknowledgeDroppedLines() {
    if (_droppedLines == 0) return;
    _droppedLines = 0;
    safeNotify();
  }

  void _changed() {
    _syncPaid();
    saveDraft();
    safeNotify();
  }

  void _syncPaid() {
    if (_paidEdited) return;
    _syncingPaid = true;
    paid.controller.text = _plain(total);
    _syncingPaid = false;
  }

  // ---- Validation ----

  List<OrderDraftLine> get overstockedLines => [
    for (final line in _lines)
      if (line.quantity > line.available) line,
  ];

  bool get hasNoItems => _lines.isEmpty;

  /// A typed number that is not a whole one yet. Optional, but a half number
  /// on the receipt is worse than none.
  bool get phoneIncomplete {
    final typed = customerPhone.trim();
    return typed.isNotEmpty && !Phone.isComplete(typed);
  }

  bool get canSubmit =>
      _lines.isNotEmpty && overstockedLines.isEmpty && !phoneIncomplete && !isBusy;

  AppException? _submitError;
  AppException? get submitError => _submitError;

  Future<Sale?> createSale() async {
    if (!canSubmit) return null;
    _submitError = null;
    return run(
      () => _sales.create(
        customerName: customerName,
        // Digits only, never the spacing — see [Phone].
        customerPhone: Phone.digitsOrNull(customerPhone),
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
        paymentMethod: _method,
        saleDate: _saleDate,
        notes: notes.value,
      ),
      onError: (error) => _submitError = error,
      tag: 'createSale',
    );
  }

  static String _plain(double value) =>
      value == value.roundToDouble() ? value.round().toString() : value.toStringAsFixed(2);
}
