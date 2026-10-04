import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../models/order.dart';
import '../models/sale.dart';
import 'order_repository.dart';

/// Walk-in sales, against `/api/user-stock/sales` — the web's
/// `dashboard/stock/sales`.
///
/// A sale is recorded and paid for on the spot: **creating one takes the stock
/// at once** and, when money was received, posts an automatic caisse income.
/// After that only the payment and the notes can change.
class SaleRepository {
  SaleRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /api/user-stock/sales` → `{ sales, total }`, newest `saleDate` first.
  ///
  /// - [search] matches the sale number, the customer's name or phone, or the
  ///   notes.
  /// - [hasRemaining] forces "not fully paid" and **overrides**
  ///   [paymentStatus] server-side, so the two are never sent together.
  /// - [limit] and [offset] are `parseInt`ed: only integers are sent.
  Future<Result<SalePage>> list({
    String? search,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    bool hasRemaining = false,
    DateTime? startDate,
    DateTime? endDate,
    double? minTotal,
    double? maxTotal,
    int limit = 30,
    int offset = 0,
  }) {
    return _api.get<SalePage>(
      Api.sales,
      query: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (hasRemaining) 'hasRemaining': 'true',
        if (!hasRemaining && paymentStatus != null) 'paymentStatus': paymentStatus.wire,
        if (paymentMethod != null) 'paymentMethod': paymentMethod.wire,
        if (startDate != null) 'startDate': _startOfDay(startDate),
        // A bare day would mean midnight UTC and drop the day itself (docs).
        if (endDate != null) 'endDate': _endOfDay(endDate),
        if (minTotal != null && minTotal > 0) 'minTotal': minTotal,
        'maxTotal': ?maxTotal,
        'limit': limit,
        'offset': offset,
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final sales = Json.list(map['sales'], Sale.fromJson);
        return (sales: sales, total: Json.intOf(map['total'], sales.length));
      },
    );
  }

  /// `GET /api/user-stock/sales/{id}` → `{ sale }`, each line with its
  /// product's sku and image. Another merchant's sale is a 404.
  Future<Result<Sale>> get(String saleId) {
    return _api.get<Sale>(Api.sale(saleId), parse: _parse);
  }

  /// `GET /api/user-stock/sales/stats?period=` → `{ stats, topProducts }`.
  Future<Result<SaleStats>> stats(SalePeriod period) {
    return _api.get<SaleStats>(
      Api.salesStats,
      query: {'period': period.wire},
      parse: (json) => SaleStats.fromJson(json as Map<String, dynamic>),
    );
  }

  /// `POST /api/user-stock/sales` → **201** `{ sale }`, in one transaction.
  ///
  /// The stock is deducted with a conditional decrement, so a shortage that
  /// appeared since the form loaded rolls the whole sale back with a 400
  /// naming the product. [amountPaid] is the source of truth: the server
  /// clamps it to `[0, total]` and derives the status, so the legacy
  /// `paymentStatus` is never sent. [saleDate] may be in the past, and no more
  /// than 24 h ahead.
  ///
  /// [items] reuses the order line: the same four fields, and the same rule
  /// that a variant product needs its `variantId`.
  Future<Result<Sale>> create({
    String? customerName,
    String? customerPhone,
    required List<NewOrderLine> items,
    required double amountPaid,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    DateTime? saleDate,
    String? notes,
  }) {
    return _api.post<Sale>(
      Api.sales,
      body: {
        if (customerName != null && customerName.trim().isNotEmpty)
          'customerName': customerName.trim(),
        if (customerPhone != null && customerPhone.trim().isNotEmpty)
          'customerPhone': customerPhone.trim(),
        'items': [for (final line in items) line.toJson()],
        'amountPaid': amountPaid,
        'paymentMethod': paymentMethod.wire,
        if (saleDate != null) 'saleDate': saleDate.toUtc().toIso8601String(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
      parse: _parse,
    );
  }

  /// `PUT /api/user-stock/sales/{id}` → `{ sale }`. Only the payment and the
  /// notes; the lines and the totals are immutable.
  ///
  /// When [amountPaid] actually changes, every automatic caisse row of this
  /// sale is replaced by one income for the new amount (none when it is 0).
  /// [notes] is sent as typed — empty clears it.
  Future<Result<Sale>> update(
    String saleId, {
    double? amountPaid,
    PaymentMethod? paymentMethod,
    String? notes,
  }) {
    return _api.put<Sale>(
      Api.sale(saleId),
      body: {
        'amountPaid': ?amountPaid,
        if (paymentMethod != null) 'paymentMethod': paymentMethod.wire,
        if (notes != null) 'notes': notes.trim(),
      },
      parse: _parse,
    );
  }

  /// `DELETE /api/user-stock/sales/{id}`. Restocks every line and removes the
  /// automatic caisse rows. **Refused (400) once money is recorded** — see
  /// `Sale.canDelete`.
  Future<Result<void>> delete(String saleId) {
    return _api.delete<void>(Api.sale(saleId), parse: (_) {});
  }

  static String _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toUtc().toIso8601String();

  static String _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day).toUtc().toIso8601String();

  static Sale _parse(dynamic json) {
    final map = json as Map<String, dynamic>;
    final sale = map['sale'];
    return Sale.fromJson(sale is Map<String, dynamic> ? sale : map);
  }
}
