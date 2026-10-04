import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../models/order.dart';
import '../models/purchase.dart';
import '../models/sale.dart';
import '../models/stock_overview.dart';

/// One ordered line to send on `POST /purchases`.
class NewPurchaseLine {
  const NewPurchaseLine({
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.unitCost,
  });

  final String productId;

  /// Required by the backend when the product has variants (an active one).
  final String? variantId;
  final int quantity;
  final double unitCost;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'variantId': ?variantId,
    'quantity': quantity,
    'unitCost': unitCost,
  };
}

/// Purchase orders, against `/api/user-stock/purchases` — the web's
/// `dashboard/stock/purchases`.
///
/// **Creating one moves no stock**: goods enter only through [receive]. Paying
/// posts an automatic caisse expense; cancelling takes back what was received
/// and removes that expense.
class PurchaseRepository {
  PurchaseRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /api/user-stock/purchases` → `{ purchases, total }`, newest
  /// `purchaseDate` first.
  ///
  /// [hasRemaining] overrides [paymentStatus] server-side (and, without a
  /// [status], leaves cancelled purchases out), so the two are never sent
  /// together. [search] matches the number, the notes or the supplier's name.
  Future<Result<PurchasePage>> list({
    String? search,
    PurchaseStatus? status,
    PaymentStatus? paymentStatus,
    bool hasRemaining = false,
    String? supplierId,
    DateTime? startDate,
    DateTime? endDate,
    double? minTotal,
    double? maxTotal,
    int limit = 30,
    int offset = 0,
  }) {
    return _api.get<PurchasePage>(
      Api.purchases,
      query: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null) 'status': status.wire,
        if (hasRemaining) 'hasRemaining': 'true',
        if (!hasRemaining && paymentStatus != null) 'paymentStatus': paymentStatus.wire,
        'supplierId': ?supplierId,
        if (startDate != null) 'startDate': _startOfDay(startDate),
        if (endDate != null) 'endDate': _endOfDay(endDate),
        if (minTotal != null && minTotal > 0) 'minTotal': minTotal,
        'maxTotal': ?maxTotal,
        'limit': limit,
        'offset': offset,
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final purchases = Json.list(map['purchases'], Purchase.fromJson);
        return (purchases: purchases, total: Json.intOf(map['total'], purchases.length));
      },
    );
  }

  /// `GET /api/user-stock/purchases/{id}` → `{ purchase }`, with the full
  /// supplier and each line's product (sku, image).
  Future<Result<Purchase>> get(String purchaseId) {
    return _api.get<Purchase>(Api.purchase(purchaseId), parse: _parse);
  }

  /// `GET /api/user-stock/purchases/stats?period=` — cancelled purchases
  /// never count; `totalSpent` is cash actually paid out.
  Future<Result<PurchaseStats>> stats(SalePeriod period) {
    return _api.get<PurchaseStats>(
      Api.purchasesStats,
      query: {'period': period.wire},
      parse: (json) => PurchaseStats.fromJson(json as Map<String, dynamic>),
    );
  }

  /// `POST /api/user-stock/purchases` → **201** `{ purchase }`, status
  /// `pending`. [amountPaid] is clamped to `[0, total]` and drives the derived
  /// payment status; the legacy `paymentStatus` is never sent. [supplierId] is
  /// not checked server-side (an unknown id is a 500), so only one taken from
  /// the supplier list is ever sent.
  Future<Result<Purchase>> create({
    String? supplierId,
    required List<NewPurchaseLine> items,
    required double amountPaid,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    DateTime? purchaseDate,
    String? notes,
  }) {
    return _api.post<Purchase>(
      Api.purchases,
      body: {
        'supplierId': ?supplierId,
        'items': [for (final line in items) line.toJson()],
        'amountPaid': amountPaid,
        'paymentMethod': paymentMethod.wire,
        if (purchaseDate != null) 'purchaseDate': purchaseDate.toUtc().toIso8601String(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
      parse: _parse,
    );
  }

  /// `PUT /api/user-stock/purchases/{id}` → `{ purchase, note? }`.
  ///
  /// [status] `cancelled` runs the rollback in one transaction: the payment
  /// goes to 0, every received unit leaves stock again and the automatic
  /// caisse expense is removed. A supplier refund is not recorded — `note`
  /// says so when money had been paid. Payment changes are refused (400) on a
  /// cancelled purchase.
  Future<Result<PurchaseUpdate>> update(
    String purchaseId, {
    PurchaseStatus? status,
    double? amountPaid,
  }) {
    return _api.put<PurchaseUpdate>(
      Api.purchase(purchaseId),
      body: {if (status != null) 'status': status.wire, 'amountPaid': ?amountPaid},
      parse: (json) {
        final map = json as Map<String, dynamic>;
        return (purchase: _parse(map), note: Json.strOrNull(map['note']));
      },
    );
  }

  /// `POST /api/user-stock/purchases/{id}/receive` → `{ purchase }`.
  ///
  /// [quantities] maps a line id to what arrived **now** (a delta, not the
  /// running total); zero lines are left out. Over-receiving is a 400 (`only N
  /// remaining`), and a concurrent receive on the same line a 409. Stock goes
  /// up and an `in` movement is written per line; the status becomes
  /// `received` once every line is complete, `partial` before that.
  Future<Result<Purchase>> receive(String purchaseId, Map<String, int> quantities) {
    return _api.post<Purchase>(
      Api.purchaseReceive(purchaseId),
      body: {
        'items': [
          for (final entry in quantities.entries)
            if (entry.value > 0) {'itemId': entry.key, 'receivedQty': entry.value},
        ],
      },
      parse: _parse,
    );
  }

  /// `DELETE /api/user-stock/purchases/{id}`. Only a pending purchase with
  /// nothing paid and nothing received (`Purchase.canDelete`); 400 otherwise.
  Future<Result<void>> delete(String purchaseId) {
    return _api.delete<void>(Api.purchase(purchaseId), parse: (_) {});
  }

  static String _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toUtc().toIso8601String();

  static String _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day).toUtc().toIso8601String();

  static Purchase _parse(dynamic json) {
    final map = json as Map<String, dynamic>;
    final purchase = map['purchase'];
    return Purchase.fromJson(purchase is Map<String, dynamic> ? purchase : map);
  }
}

/// What `PUT` answers: the purchase, and the server's note after a cancel.
typedef PurchaseUpdate = ({Purchase purchase, String? note});

/// The stock ledger, `GET /api/user-stock/movements` → `{ movements, total }`,
/// newest first. [endDate] is **not** extended server-side, so the end of the
/// day is sent.
class MovementRepository {
  MovementRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<Result<MovementPage>> list({
    String? productId,
    StockMovementType? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 30,
    int offset = 0,
  }) {
    return _api.get<MovementPage>(
      Api.movements,
      query: {
        'productId': ?productId,
        'type': ?switch (type) {
          StockMovementType.stockIn => 'in',
          StockMovementType.stockOut => 'out',
          StockMovementType.adjustment => 'adjustment',
          StockMovementType.returned => 'return',
          StockMovementType.unknown || null => null,
        },
        if (startDate != null) 'startDate': PurchaseRepository._startOfDay(startDate),
        if (endDate != null) 'endDate': PurchaseRepository._endOfDay(endDate),
        'limit': limit,
        'offset': offset,
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final rows = Json.list(map['movements'], StockMovement.fromJson);
        return (movements: rows, total: Json.intOf(map['total'], rows.length));
      },
    );
  }
}

typedef MovementPage = ({List<StockMovement> movements, int total});
