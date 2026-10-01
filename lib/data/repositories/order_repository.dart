import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../models/order.dart';

/// One line to send on `POST /orders`.
///
/// `variantId` is **required by the backend when the product has variants** —
/// omitting it is a 400 naming the product. The form only ever builds a line
/// from a chosen variant or from a plain product, so the rule holds by
/// construction.
class NewOrderLine {
  const NewOrderLine({
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String? variantId;
  final int quantity;
  final double unitPrice;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        if (variantId != null) 'variantId': variantId,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
}

/// Orders, against `/api/user-stock/orders` — the web's
/// `dashboard/stock/orders`.
///
/// **Two things here are unlike every other repository in this app.** Money
/// comes back as Decimal strings and is parsed, not cast; and confirming an
/// order is not its own route — it is a side effect of logging a call, which
/// is why [addCall] returns the whole order back.
class OrderRepository {
  OrderRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /api/user-stock/orders` → `{ orders, total }`, newest first.
  ///
  /// Each row embeds its items, a compact client (`id`, `name`, `phone`) and
  /// the **five most recent** calls. From the live docs:
  ///
  /// - [search] matches the order number, the client's name, phone or address,
  ///   the notes, or any line's product name.
  /// - [hasRemaining] forces "not fully paid" and **overrides** [paymentStatus]
  ///   server-side, so the two are never sent together.
  /// - [minTotal] / [maxTotal] bound `total`.
  /// - [limit] and [offset] are parsed with `parseInt`: a non-numeric value
  ///   silently becomes 500 rather than erroring, so only integers are sent.
  Future<Result<OrderPage>> list({
    String? search,
    OrderStatus? status,
    ConfirmationStatus? confirmationStatus,
    PaymentStatus? paymentStatus,
    bool hasRemaining = false,
    DateTime? startDate,
    DateTime? endDate,
    double? minTotal,
    double? maxTotal,
    String? clientId,
    int limit = 50,
    int offset = 0,
  }) {
    return _api.get<OrderPage>(
      Api.orders,
      query: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null) 'status': status.wire,
        if (confirmationStatus != null) 'confirmationStatus': confirmationStatus.wire,
        // Never both: the server ignores `paymentStatus` when `hasRemaining`
        // is set, and sending a filter that is silently dropped would make the
        // sheet lie about what is applied.
        if (hasRemaining) 'hasRemaining': 'true',
        if (!hasRemaining && paymentStatus != null) 'paymentStatus': paymentStatus.wire,
        if (startDate != null) 'startDate': _startOfDay(startDate),
        if (endDate != null) 'endDate': _endOfDay(endDate),
        if (minTotal != null && minTotal > 0) 'minTotal': minTotal,
        'maxTotal': ?maxTotal,
        'clientId': ?clientId,
        'limit': limit,
        'offset': offset,
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final orders = Json.list(map['orders'], Order.fromJson);
        return (orders: orders, total: Json.intOf(map['total'], orders.length));
      },
    );
  }

  /// `GET /api/user-stock/orders/{id}` → `{ order }` — the full client record
  /// and **every** call, which the list's five do not give.
  Future<Result<Order>> get(String orderId) {
    return _api.get<Order>(Api.order(orderId), parse: _parse);
  }

  /// `GET /api/user-stock/orders/stats` → `{ stats, topProducts }`.
  ///
  /// Declared before `/orders/{id}` server-side, so `stats` is never read as an
  /// id. The default period is a month; the frame's figures are the whole
  /// picture, so the app asks for a year.
  Future<Result<OrderStats>> stats({String period = 'year'}) {
    return _api.get<OrderStats>(
      Api.orderStats,
      query: {'period': period},
      parse: (json) => OrderStats.fromJson(json as Map<String, dynamic>),
    );
  }

  /// `POST /api/user-stock/orders` → **201** `{ order }`.
  ///
  /// **Stock is reserved the moment this succeeds**, whatever [status] says —
  /// a pending order already holds its units, and a concurrent shortage rolls
  /// the whole thing back with a 400 naming the product.
  ///
  /// [status] is restricted to pending or confirmed on purpose: the backend
  /// stores whatever it is sent here **without validating it**, so a wrong
  /// value would persist and only the transition matrix on update would ever
  /// object. [paymentStatus] cannot be set at all — it is derived from
  /// [amountPaid], which the server clamps to `[0, total]`.
  ///
  /// [clientId] is **not checked server-side**: an id that does not exist
  /// fails the transaction with a 500 rather than a 400, so the form only ever
  /// sends one it took from the client list.
  Future<Result<Order>> create({
    String? clientId,
    required String clientName,
    String? clientPhone,
    String? clientAddress,
    required List<NewOrderLine> items,
    double amountPaid = 0,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    OrderStatus status = OrderStatus.pending,
    String? notes,
    int? wilayaId,
    String? communeName,
    bool isStopdesk = false,
    DateTime? orderDate,
  }) {
    assert(
      status == OrderStatus.pending || status == OrderStatus.confirmed,
      'the create route stores status unvalidated — only the two the form offers',
    );
    return _api.post<Order>(
      Api.orders,
      body: {
        'clientId': ?clientId,
        'clientName': clientName.trim(),
        if (clientPhone != null && clientPhone.trim().isNotEmpty)
          'clientPhone': clientPhone.trim(),
        if (clientAddress != null && clientAddress.trim().isNotEmpty)
          'clientAddress': clientAddress.trim(),
        'items': [for (final line in items) line.toJson()],
        'amountPaid': amountPaid,
        'paymentMethod': paymentMethod.wire,
        'status': status.wire,
        'source': OrderSource.manual.wire,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        'wilayaId': ?wilayaId,
        if (communeName != null && communeName.trim().isNotEmpty)
          'communeName': communeName.trim(),
        'isStopdesk': isStopdesk,
        if (orderDate != null) 'orderDate': orderDate.toUtc().toIso8601String(),
      },
      parse: _parse,
    );
  }

  /// `PUT /api/user-stock/orders/{id}` → `{ order }`. A partial update: the
  /// lines and the totals cannot be changed here at all.
  ///
  /// [status] must be a legal transition (see `orderTransitions`) or the server
  /// answers 400 naming both ends. On a **terminal** order only [notes],
  /// [clientPhone] and [clientAddress] may be sent; anything else is a 400.
  ///
  /// Two side effects worth knowing at the call site:
  ///
  /// - Moving to `delivered` **forces** `amountPaid = total` when the order was
  ///   not already paid — cash on delivery, and it overrides an [amountPaid]
  ///   sent in the same request.
  /// - Moving to `cancelled` or `returned` restocks every line, deletes the
  ///   automatic caisse rows and zeroes `amountPaid`. **It does not refund
  ///   anything** — money already taken has to be given back by hand, which is
  ///   why the sheets that lead here say so.
  Future<Result<Order>> update(
    String orderId, {
    OrderStatus? status,
    double? amountPaid,
    PaymentMethod? paymentMethod,
    String? clientPhone,
    String? clientAddress,
    String? notes,
  }) {
    return _api.put<Order>(
      Api.order(orderId),
      body: {
        if (status != null) 'status': status.wire,
        'amountPaid': ?amountPaid,
        if (paymentMethod != null) 'paymentMethod': paymentMethod.wire,
        // Sent as typed, empty as "" — which is what clears the column. The
        // web sends `undefined` and so keeps the old value; this app clears,
        // as it does everywhere else.
        if (clientPhone != null) 'clientPhone': clientPhone.trim(),
        if (clientAddress != null) 'clientAddress': clientAddress.trim(),
        if (notes != null) 'notes': notes.trim(),
      },
      parse: _parse,
    );
  }

  /// `POST /api/user-stock/orders/{id}/calls` → `{ call, order, warning? }`.
  ///
  /// **This is how an order gets confirmed** — there is no `/confirm` route.
  /// The result drives the rest: `picked_up` confirms a pending order,
  /// `rejected` **cancels** it outright (restocking it) as long as it has not
  /// shipped, and the other three only add an attempt.
  ///
  /// `warning` comes back when `picked_up` is logged against an order that is
  /// already cancelled or returned: the call is kept but the order is not
  /// re-confirmed. It is surfaced, not swallowed.
  Future<Result<OrderCallOutcome>> addCall(
    String orderId, {
    required CallResult result,
    String? notes,
  }) {
    return _api.post<OrderCallOutcome>(
      Api.orderCalls(orderId),
      body: {
        'result': result.wire,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        return (
          order: Order.fromJson(Json.map(map['order'])),
          warning: Json.strOrNull(map['warning']),
        );
      },
    );
  }

  /// `DELETE /api/user-stock/orders/{id}` → `{ success: true }`.
  ///
  /// **A hard delete**, and it cascades the lines and the calls. A still-live
  /// order is restocked on the way out and its caisse rows are removed. Only a
  /// *delivered* order is refused (400) — a shipped one with money against it
  /// will go, quietly.
  Future<Result<void>> delete(String orderId) {
    return _api.delete<void>(Api.order(orderId), parse: (_) {});
  }

  /// The end of [date] in the merchant's own day, which is what the filter
  /// chip means by "up to and including this date".
  static String _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toUtc().toIso8601String();

  static String _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day).toUtc().toIso8601String();

  static Order _parse(dynamic json) {
    final map = json as Map<String, dynamic>;
    final order = map['order'];
    return Order.fromJson(order is Map<String, dynamic> ? order : map);
  }
}

/// What logging a call answers with: the order as it now stands, and the
/// server's warning when the call changed nothing.
typedef OrderCallOutcome = ({Order order, String? warning});
