import '../../core/utils/json.dart';
import 'order.dart';

/// Where the goods are — the purchase's own `status`, separate from the money.
///
/// Only `POST /purchases/{id}/receive` moves it forward for real (stock in);
/// `cancelled` is set through `PUT` and rolls the stock and the caisse back.
enum PurchaseStatus {
  pending('pending'),
  partial('partial'),
  received('received'),
  cancelled('cancelled');

  const PurchaseStatus(this.wire);
  final String wire;

  static PurchaseStatus of(dynamic value) => values.firstWhere(
    (s) => s.wire == Json.strOrNull(value),
    orElse: () => PurchaseStatus.pending,
  );
}

/// One ordered line. `productName` / `variantName` are snapshots.
class PurchaseItem {
  const PurchaseItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.variantId,
    this.variantName,
    this.sku,
    this.quantity = 0,
    this.receivedQty = 0,
    this.unitCost = 0,
    this.total = 0,
  });

  final String id;
  final String productId;
  final String productName;
  final String? variantId;
  final String? variantName;
  final String? sku;

  /// Ordered.
  final int quantity;

  /// Delivered so far, cumulative.
  final int receivedQty;

  final double unitCost;
  final double total;

  /// What the supplier still owes on this line. Never negative.
  int get toReceive => quantity - receivedQty > 0 ? quantity - receivedQty : 0;

  /// `Robe satin — Noir`, the frames' way of naming a variant line.
  String get label =>
      variantName == null || variantName!.isEmpty ? productName : '$productName — $variantName';

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    final product = Json.mapOrNull(json['product']);
    return PurchaseItem(
      id: Json.str(json['id']),
      productId: Json.str(json['productId']),
      productName: Json.str(json['productName']),
      variantId: Json.strOrNull(json['variantId']),
      variantName: Json.strOrNull(json['variantName']),
      sku: product == null ? null : Json.strOrNull(product['sku']),
      quantity: Json.intOf(json['quantity']),
      receivedQty: Json.intOf(json['receivedQty']),
      unitCost: Json.dbl(json['unitCost']),
      total: Json.dbl(json['total']),
    );
  }
}

/// A purchase order to a supplier — `Purchase` in the schema, the web's
/// `stock/purchases`.
///
/// Two separate tracks: the goods ([status], moved by receiving) and the money
/// ([paymentStatus], derived server-side from [amountPaid]). Money arrives as
/// Decimal strings.
class Purchase {
  const Purchase({
    required this.id,
    required this.purchaseNumber,
    this.supplierId,
    this.supplierName,
    this.subtotal = 0,
    this.tax = 0,
    this.shippingCost = 0,
    this.total = 0,
    this.amountPaid = 0,
    this.paymentMethodWire = 'cash',
    this.paymentStatus = PaymentStatus.pending,
    this.status = PurchaseStatus.pending,
    this.notes,
    required this.purchaseDate,
    this.expectedDate,
    this.receivedDate,
    this.items = const [],
  });

  final String id;

  /// `PO-YYYYMMDD-NNNN`.
  final String purchaseNumber;

  final String? supplierId;

  /// From the embedded supplier; null when there is none or it was deleted.
  final String? supplierName;

  final double subtotal;
  final double tax;
  final double shippingCost;
  final double total;
  final double amountPaid;

  /// As stored — the API keeps whatever it is sent (see `Sale`).
  final String paymentMethodWire;

  final PaymentStatus paymentStatus;
  final PurchaseStatus status;
  final String? notes;
  final DateTime purchaseDate;
  final DateTime? expectedDate;
  final DateTime? receivedDate;
  final List<PurchaseItem> items;

  PaymentMethod? get paymentMethod =>
      PaymentMethod.values.where((m) => m.wire == paymentMethodWire).firstOrNull;

  /// Still owed to the supplier. Never negative.
  double get remaining => total - amountPaid > 0 ? total - amountPaid : 0;

  int get itemCount => items.length;

  /// Units already in stock from this purchase — what a cancel takes back.
  int get unitsReceived => items.fold(0, (sum, i) => sum + i.receivedQty);

  bool get isClosed => status == PurchaseStatus.received || status == PurchaseStatus.cancelled;

  /// `/receive` refuses a received or cancelled purchase.
  bool get canReceive => !isClosed && items.any((i) => i.toReceive > 0);

  /// The API's own rule: still pending, nothing paid, nothing received.
  /// Anything else has to be cancelled instead.
  bool get canDelete =>
      status == PurchaseStatus.pending &&
      paymentStatus != PaymentStatus.paid &&
      amountPaid <= 0 &&
      unitsReceived == 0;

  /// Offered where delete is not (decided 2026-10-04): an open purchase with
  /// money paid or goods received. A cancelled one is terminal, and so is a
  /// received one.
  bool get canCancel => !isClosed && !canDelete;

  /// The payment is refused (400) on a cancelled purchase.
  bool get canMarkPaid => paymentStatus != PaymentStatus.paid && status != PurchaseStatus.cancelled;

  /// This purchase with [before]'s lines and supplier name: `PUT` and
  /// `/receive` answer without each line's product (no sku). The received
  /// quantities are taken from the answer, since they may have moved.
  Purchase keepingLabelsOf(Purchase before) {
    final skus = {for (final i in before.items) i.id: i.sku};
    return Purchase(
      id: id,
      purchaseNumber: purchaseNumber,
      supplierId: supplierId,
      supplierName: supplierName ?? before.supplierName,
      subtotal: subtotal,
      tax: tax,
      shippingCost: shippingCost,
      total: total,
      amountPaid: amountPaid,
      paymentMethodWire: paymentMethodWire,
      paymentStatus: paymentStatus,
      status: status,
      notes: notes,
      purchaseDate: purchaseDate,
      expectedDate: expectedDate,
      receivedDate: receivedDate,
      items: [
        for (final i in items)
          PurchaseItem(
            id: i.id,
            productId: i.productId,
            productName: i.productName,
            variantId: i.variantId,
            variantName: i.variantName,
            sku: i.sku ?? skus[i.id],
            quantity: i.quantity,
            receivedQty: i.receivedQty,
            unitCost: i.unitCost,
            total: i.total,
          ),
      ],
    );
  }

  factory Purchase.fromJson(Map<String, dynamic> json) {
    final supplier = Json.mapOrNull(json['supplier']);
    final items = json['items'];
    return Purchase(
      id: Json.str(json['id']),
      purchaseNumber: Json.str(json['purchaseNumber']),
      supplierId: Json.strOrNull(json['supplierId']),
      supplierName: supplier == null ? null : _blank(Json.strOrNull(supplier['name'])),
      subtotal: Json.dbl(json['subtotal']),
      tax: Json.dbl(json['tax']),
      shippingCost: Json.dbl(json['shippingCost']),
      total: Json.dbl(json['total']),
      amountPaid: Json.dbl(json['amountPaid']),
      paymentMethodWire: _blank(Json.strOrNull(json['paymentMethod'])) ?? 'cash',
      paymentStatus: PaymentStatus.of(json['paymentStatus']),
      status: PurchaseStatus.of(json['status']),
      notes: _blank(Json.strOrNull(json['notes'])),
      purchaseDate: Json.date(json['purchaseDate']),
      expectedDate: Json.dateOrNull(json['expectedDate']),
      receivedDate: Json.dateOrNull(json['receivedDate']),
      items: items is List
          ? [
              for (final item in items.whereType<Map<String, dynamic>>())
                PurchaseItem.fromJson(item),
            ]
          : const [],
    );
  }

  static String? _blank(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();
}

/// One page of the list, with the server's count for the whole query.
typedef PurchasePage = ({List<Purchase> purchases, int total});
