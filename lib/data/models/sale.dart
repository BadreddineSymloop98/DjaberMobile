import '../../core/utils/json.dart';
import 'order.dart';

/// The window `GET /sales/stats` counts over — the four chips above the
/// figures. Rolling, ending now (`week` is the last seven days, not the
/// calendar week).
enum SalePeriod {
  today('today'),
  week('week'),
  month('month'),
  year('year');

  const SalePeriod(this.wire);
  final String wire;
}

/// One line of a sale.
///
/// **There is no `variantId` on a sale line** (live docs): the variant sold is
/// only in [productName], which the server writes as `"<product> - <variant>"`.
/// It is a snapshot — the product may have been renamed since.
class SaleItem {
  const SaleItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.sku,
    this.quantity = 1,
    this.unitPrice = 0,
    this.discount = 0,
    this.total = 0,
  });

  final String id;
  final String productId;
  final String productName;

  /// From the embedded product, when the response carries one.
  final String? sku;

  final int quantity;
  final double unitPrice;
  final double discount;
  final double total;

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    final product = Json.mapOrNull(json['product']);
    return SaleItem(
      id: Json.str(json['id']),
      productId: Json.str(json['productId']),
      productName: Json.str(json['productName']),
      sku: product == null ? null : Json.strOrNull(product['sku']),
      quantity: Json.intOf(json['quantity'], 1),
      unitPrice: Json.dbl(json['unitPrice']),
      discount: Json.dbl(json['discount']),
      total: Json.dbl(json['total']),
    );
  }
}

/// A walk-in sale — `Sale` in the schema, the web's `stock/sales`.
///
/// Unlike an order there is no client record, no courier and no status
/// machine: the stock left when the sale was recorded, and the only thing that
/// can still move is the money. **Money arrives as Decimal strings**, which
/// `Json.dbl` parses.
class Sale {
  const Sale({
    required this.id,
    required this.saleNumber,
    this.customerName,
    this.customerPhone,
    this.subtotal = 0,
    this.discount = 0,
    this.tax = 0,
    this.total = 0,
    this.amountPaid = 0,
    this.paymentMethodWire = 'cash',
    this.paymentStatus = PaymentStatus.paid,
    this.notes,
    required this.saleDate,
    this.items = const [],
  });

  final String id;

  /// `SL-YYYYMMDD-NNNN`, one series per merchant per UTC day.
  final String saleNumber;

  /// Free text — a sale is not linked to a client record.
  final String? customerName;
  final String? customerPhone;

  final double subtotal;
  final double discount;
  final double tax;
  final double total;

  /// Cash actually received, clamped server-side to `[0, total]`;
  /// [paymentStatus] is derived from it.
  final double amountPaid;

  /// As stored. The API keeps whatever it was sent here, and its own schema
  /// lists `other`, which no form sends — so the raw value is kept and
  /// [paymentMethod] is null for anything the app does not know.
  final String paymentMethodWire;

  final PaymentStatus paymentStatus;
  final String? notes;
  final DateTime saleDate;
  final List<SaleItem> items;

  PaymentMethod? get paymentMethod =>
      PaymentMethod.values.where((m) => m.wire == paymentMethodWire).firstOrNull;

  /// What is still owed. Never negative.
  double get remaining {
    final left = total - amountPaid;
    return left > 0 ? left : 0;
  }

  /// Lines, not units — the frames' *3 articles* for a sale of 2 + 1 + 1.
  int get itemCount => items.length;

  /// The server refuses (400) any sale with money against it, and a zero-total
  /// sale is derived *paid* — so only a sale with nothing received may go.
  /// Decided 2026-10-01: the trash shows on exactly those, rather than on
  /// every unpaid one as the web does (where a partial sale then fails).
  bool get canDelete => paymentStatus != PaymentStatus.paid && amountPaid <= 0;

  bool get isPaid => paymentStatus == PaymentStatus.paid;

  /// This sale with [before]'s lines. `PUT` answers without each line's
  /// product (no sku), and the lines cannot have changed — so the ones
  /// already on screen are kept.
  Sale keepingLinesOf(Sale before) => Sale(
    id: id,
    saleNumber: saleNumber,
    customerName: customerName,
    customerPhone: customerPhone,
    subtotal: subtotal,
    discount: discount,
    tax: tax,
    total: total,
    amountPaid: amountPaid,
    paymentMethodWire: paymentMethodWire,
    paymentStatus: paymentStatus,
    notes: notes,
    saleDate: saleDate,
    items: before.items.isNotEmpty ? before.items : items,
  );

  factory Sale.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    return Sale(
      id: Json.str(json['id']),
      saleNumber: Json.str(json['saleNumber']),
      customerName: _blank(Json.strOrNull(json['customerName'])),
      customerPhone: _blank(Json.strOrNull(json['customerPhone'])),
      subtotal: Json.dbl(json['subtotal']),
      discount: Json.dbl(json['discount']),
      tax: Json.dbl(json['tax']),
      total: Json.dbl(json['total']),
      amountPaid: Json.dbl(json['amountPaid']),
      paymentMethodWire: _blank(Json.strOrNull(json['paymentMethod'])) ?? 'cash',
      paymentStatus: PaymentStatus.of(json['paymentStatus']),
      notes: _blank(Json.strOrNull(json['notes'])),
      saleDate: Json.date(json['saleDate']),
      items: items is List
          ? [for (final item in items.whereType<Map<String, dynamic>>()) SaleItem.fromJson(item)]
          : const [],
    );
  }

  static String? _blank(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();
}

/// `GET /sales/stats` — the four figures above the list.
///
/// **They count delivered orders too** (live docs): *Total ventes* is walk-in
/// sales plus delivered orders over the period, and the revenue likewise. They
/// do not follow the search or the filters, as on the web.
class SaleStats {
  const SaleStats({
    this.totalSales = 0,
    this.totalRevenue = 0,
    this.paidSales = 0,
    this.pendingSales = 0,
    this.averageOrderValue = 0,
  });

  final int totalSales;
  final double totalRevenue;
  final int paidSales;
  final int pendingSales;
  final double averageOrderValue;

  factory SaleStats.fromJson(Map<String, dynamic> json) {
    final stats = Json.mapOrNull(json['stats']) ?? json;
    return SaleStats(
      totalSales: Json.intOf(stats['totalSales']),
      totalRevenue: Json.dbl(stats['totalRevenue']),
      paidSales: Json.intOf(stats['paidSales']),
      pendingSales: Json.intOf(stats['pendingSales']),
      averageOrderValue: Json.dbl(stats['averageOrderValue']),
    );
  }
}

/// One page of the list, with the server's count for the whole query.
typedef SalePage = ({List<Sale> sales, int total});
