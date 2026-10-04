import 'dart:convert';

import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../core/utils/validators.dart';
import '../../data/models/order.dart';
import '../../data/models/product.dart';
import '../../data/models/purchase.dart';
import '../../data/models/supplier.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/purchase_repository.dart';
import '../../data/repositories/supplier_repository.dart';
import 'form_draft_store.dart';
import 'form_field_model.dart';
import 'new_order_view_model.dart';

/// `Nouvel achat` — the web's `stock/purchases/new`.
///
/// Built like *Nouvelle vente*, turned around: a supplier instead of a
/// customer, each line at its **cost** price, and no stock ceiling — buying
/// what has run out is the point. **Nothing enters stock here**; that happens
/// when the delivery is received.
///
/// The amount paid follows the total until the merchant types one, as on the
/// web and in the frame (62 000 for 62 000).
class NewPurchaseViewModel extends FormViewModel {
  NewPurchaseViewModel({
    required PurchaseRepository purchases,
    required SupplierRepository suppliers,
    required ProductRepository products,
    FormDraftStore? drafts,
  }) : _purchases = purchases,
       _suppliers = suppliers,
       _products = products {
    attachFields();
    final saved = keepDraft(drafts, 'newPurchase', {'notes': notes, 'amountPaid': paid});
    _supplierId = saved['supplierId'];
    _paidEdited = saved['paidEdited'] == 'true';
    _method =
        PaymentMethod.values.where((m) => m.wire == saved['paymentMethod']).firstOrNull ??
        PaymentMethod.cash;
    if (DateTime.tryParse(saved['purchaseDate'] ?? '') case final date?) _date = date;
    _savedLines = saved['lines'];
    paid.controller.addListener(() {
      if (!_syncingPaid) _paidEdited = true;
    });
  }

  final PurchaseRepository _purchases;
  final SupplierRepository _suppliers;
  final ProductRepository _products;

  final notes = FormFieldModel(validator: Validators.optional);
  final paid = FormFieldModel(validator: Validators.optional);

  @override
  List<FormFieldModel> get fields => [notes, paid];

  @override
  Map<String, String> get draftExtras => {
    'supplierId': _supplier?.id ?? _supplierId ?? '',
    'paidEdited': '$_paidEdited',
    'paymentMethod': _method.wire,
    'purchaseDate': _date.toIso8601String(),
    'lines': jsonEncode([for (final line in _lines) line.toDraft()]),
  };

  // ---- What the pickers choose from ----

  List<Supplier> _supplierList = const [];

  /// Active suppliers only — an archived one is not someone to order from.
  List<Supplier> get suppliers => [
    for (final s in _supplierList)
      if (s.isActive) s,
  ];

  List<Product> _productList = const [];

  /// Every product, in stock or not: restocking what ran out is why one buys.
  /// A variant product needs at least one active variant (the API's rule).
  List<Product> get products => [
    for (final p in _productList)
      if (!p.hasVariants || p.variants.any((v) => v.isActive)) p,
  ];

  bool _loaded = false;
  bool get isLoaded => _loaded;

  // ---- The form's own state ----

  DateTime _date = DateTime.now();
  DateTime get purchaseDate => _date;

  Supplier? _supplier;
  Supplier? get supplier => _supplier;
  String? _supplierId;
  String? _savedLines;

  int _droppedLines = 0;
  int get droppedDraftLines => _droppedLines;

  /// The order line, reused: its `unitPrice` is the unit cost here.
  final List<OrderDraftLine> _lines = [];
  List<OrderDraftLine> get lines => List.unmodifiable(_lines);

  PaymentMethod _method = PaymentMethod.cash;
  PaymentMethod get paymentMethod => _method;

  bool _paidEdited = false;
  bool _syncingPaid = false;

  // ---- The figures ----

  double get total => _lines.fold(0, (sum, line) => sum + line.total);

  double get amountPaid => double.tryParse(paid.value.trim().replaceAll(',', '.')) ?? 0;

  double get remaining => total - amountPaid > 0 ? total - amountPaid : 0;

  /// More typed than owed: the server keeps the total.
  bool get overpaid => _lines.isNotEmpty && amountPaid > total;

  PaymentStatus get paymentStatus => remaining <= 0
      ? PaymentStatus.paid
      : amountPaid > 0
      ? PaymentStatus.partial
      : PaymentStatus.pending;

  // ---- Loading ----

  Future<void> load() async {
    await run(() async {
      final results = await Future.wait([_suppliers.list(), _products.list(limit: 200)]);
      for (final result in results) {
        if (result.errorOrNull case final error?) return Result<void>.failure(error);
      }
      _supplierList = results[0].valueOrNull! as List<Supplier>;
      _productList = (results[1].valueOrNull! as ProductPage).products;
      _loaded = true;
      return const Result<void>.success(null);
    }, tag: 'newPurchase');
    _restoreDraft();
    safeNotify();
  }

  void _restoreDraft() {
    if (!_loaded) return;
    if (_supplierId case final id? when id.isNotEmpty) {
      _supplier = _supplierList.where((s) => s.id == id).firstOrNull;
    }
    _supplierId = null;

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
            : product.variants.where((v) => v.id == variantId && v.isActive).firstOrNull;
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
                (row['unitPrice'] as num?)?.toDouble() ?? variant?.costPrice ?? product.costPrice,
          ),
        );
      }
    } on FormatException {
      // Not worth a crash.
    }
    _syncPaid();
  }

  // ---- Editing ----

  /// The picked day at the current time of day; the picker offers none after
  /// today (the API refuses more than 24 h ahead).
  void setPurchaseDate(DateTime day) {
    final now = DateTime.now();
    _date = DateTime(day.year, day.month, day.day, now.hour, now.minute, now.second);
    saveDraft();
    safeNotify();
  }

  void setSupplier(Supplier? value) {
    _supplier = value;
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
          unitPrice: variant?.costPrice ?? product.costPrice,
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

  void setLineCost(int index, double cost) {
    if (index < 0 || index >= _lines.length) return;
    _lines[index].unitPrice = cost < 0 ? 0 : cost;
    _changed();
  }

  void setPaymentMethod(PaymentMethod value) {
    _method = value;
    saveDraft();
    safeNotify();
  }

  /// *Entièrement payé*: back to following the total.
  void payInFull() {
    _paidEdited = false;
    _syncPaid();
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

  // ---- Submitting ----

  bool get hasNoItems => _lines.isEmpty;

  bool get canSubmit => _lines.isNotEmpty && !isBusy;

  AppException? _submitError;
  AppException? get submitError => _submitError;

  Future<Purchase?> createPurchase() async {
    if (!canSubmit) return null;
    _submitError = null;
    return run(
      () => _purchases.create(
        supplierId: _supplier?.id,
        items: [
          for (final line in _lines)
            NewPurchaseLine(
              productId: line.product.id,
              variantId: line.variant?.id,
              quantity: line.quantity,
              unitCost: line.unitPrice,
            ),
        ],
        // The server clamps it anyway; sent clamped so the caisse reads true.
        amountPaid: amountPaid > total ? total : amountPaid,
        paymentMethod: _method,
        purchaseDate: _date,
        notes: notes.value,
      ),
      onError: (error) => _submitError = error,
      tag: 'createPurchase',
    );
  }

  static String _plain(double value) =>
      value == value.roundToDouble() ? value.round().toString() : value.toStringAsFixed(2);
}
