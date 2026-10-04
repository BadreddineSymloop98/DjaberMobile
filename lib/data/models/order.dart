import '../../core/utils/json.dart';

/// Where an order is in its life. The backend's `status` column.
///
/// The seven the live docs enumerate. `dispatched` appears in the **web's**
/// TypeScript union as a legacy alias of `shipped`; the API does not list it
/// and no screen offers it, so it is not here — an unknown wire value parses to
/// [pending] rather than crashing a list.
enum OrderStatus {
  pending('pending'),
  confirmed('confirmed'),
  preparing('preparing'),
  shipped('shipped'),
  delivered('delivered'),
  cancelled('cancelled'),
  returned('returned');

  const OrderStatus(this.wire);
  final String wire;

  static OrderStatus of(dynamic value) => values.firstWhere(
        (s) => s.wire == Json.strOrNull(value),
        orElse: () => OrderStatus.pending,
      );

  /// Nothing may change on these but the notes and the contact — the backend
  /// answers 400 to anything else (live docs).
  bool get isTerminal => this == cancelled || this == returned;
}

/// How far the confirmation call has got. Driven **only** by logging calls:
/// there is no endpoint that sets it directly.
enum ConfirmationStatus {
  notCalled('not_called'),
  noAnswer('no_answer'),
  confirmed('confirmed'),
  rejected('rejected');

  const ConfirmationStatus(this.wire);
  final String wire;

  static ConfirmationStatus of(dynamic value) => values.firstWhere(
        (s) => s.wire == Json.strOrNull(value),
        orElse: () => ConfirmationStatus.notCalled,
      );
}

/// Derived server-side from `amountPaid` against `total`. Sent directly only by
/// the legacy path, which the app never takes.
enum PaymentStatus {
  pending('pending'),
  partial('partial'),
  paid('paid');

  const PaymentStatus(this.wire);
  final String wire;

  static PaymentStatus of(dynamic value) => values.firstWhere(
        (s) => s.wire == Json.strOrNull(value),
        orElse: () => PaymentStatus.pending,
      );
}

enum PaymentMethod {
  cash('cash'),
  card('card'),
  transfer('transfer'),
  ccp('ccp');

  const PaymentMethod(this.wire);
  final String wire;

  static PaymentMethod of(dynamic value) => values.firstWhere(
        (m) => m.wire == Json.strOrNull(value),
        orElse: () => PaymentMethod.cash,
      );
}

/// Where the parcel is with the courier. Separate from [OrderStatus], and not
/// synced from live tracking by the backend.
enum DeliveryStatus {
  notSent('not_sent'),
  sent('sent'),
  inTransit('in_transit'),
  delivered('delivered');

  const DeliveryStatus(this.wire);
  final String wire;

  static DeliveryStatus of(dynamic value) => values.firstWhere(
        (s) => s.wire == Json.strOrNull(value),
        orElse: () => DeliveryStatus.notSent,
      );
}

/// Who raised the order — the merchant, or the AI agent from a conversation.
enum OrderSource {
  manual('manual'),
  ai('ai');

  const OrderSource(this.wire);
  final String wire;

  static OrderSource of(dynamic value) => values.firstWhere(
        (s) => s.wire == Json.strOrNull(value),
        orElse: () => OrderSource.manual,
      );
}

/// How a confirmation call went — `POST …/orders/{id}/calls`.
///
/// **`pickedUp` is the wire's `picked_up`, and the screens call it
/// *Confirmée*.** The web makes the same mapping; keeping the backend's word
/// here and the merchant's word in the copy is deliberate, because the two
/// really are different things: the customer picked up the phone *and* wanted
/// the order.
enum CallResult {
  pickedUp('picked_up'),
  noAnswer('no_answer'),
  busy('busy'),
  voicemail('voicemail'),
  rejected('rejected');

  const CallResult(this.wire);
  final String wire;

  static CallResult of(dynamic value) => values.firstWhere(
        (r) => r.wire == Json.strOrNull(value),
        orElse: () => CallResult.noAnswer,
      );

  /// What the order becomes when this result is logged, or null when the order
  /// keeps the status it had. The backend applies this itself — the app only
  /// needs it to say, before sending, what is about to happen.
  OrderStatus? get impliedStatus => switch (this) {
        CallResult.pickedUp => OrderStatus.confirmed,
        CallResult.rejected => OrderStatus.cancelled,
        _ => null,
      };
}

/// The transitions `PUT /orders/{id}` allows, exactly as the live docs list
/// them. `cancelled` and `returned` are terminal; a delivered order can only be
/// returned.
///
/// The app checks this before offering an action **and** before sending, so a
/// bulk action over a mixed selection cannot fire a request the server will
/// refuse with a 400.
const orderTransitions = <OrderStatus, List<OrderStatus>>{
  OrderStatus.pending: [
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.shipped,
    OrderStatus.delivered,
    OrderStatus.cancelled,
  ],
  OrderStatus.confirmed: [
    OrderStatus.preparing,
    OrderStatus.shipped,
    OrderStatus.delivered,
    OrderStatus.cancelled,
  ],
  OrderStatus.preparing: [
    OrderStatus.shipped,
    OrderStatus.delivered,
    OrderStatus.cancelled,
  ],
  OrderStatus.shipped: [OrderStatus.delivered, OrderStatus.returned],
  OrderStatus.delivered: [OrderStatus.returned],
  OrderStatus.cancelled: [],
  OrderStatus.returned: [],
};

/// One line of an order.
///
/// `productName` and `variantName` are **snapshots taken when the order was
/// raised** — the live product may have been renamed since, and the order must
/// still read the way it was sold.
class OrderItem {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.variantId,
    this.variantName,
    this.sku,
    this.quantity = 1,
    this.unitPrice = 0,
    this.discount = 0,
    this.total = 0,
  });

  final String id;
  final String productId;
  final String productName;
  final String? variantId;
  final String? variantName;

  /// From the embedded product, when the response carries one.
  final String? sku;

  final int quantity;
  final double unitPrice;
  final double discount;
  final double total;

  /// `Robe satin — Noir (L)`, the way both the detail frame and the web write
  /// a line's name.
  String get label =>
      variantName == null || variantName!.isEmpty ? productName : '$productName ($variantName)';

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = Json.mapOrNull(json['product']);
    return OrderItem(
      id: Json.str(json['id']),
      productId: Json.str(json['productId']),
      productName: Json.str(json['productName']),
      variantId: Json.strOrNull(json['variantId']),
      variantName: Json.strOrNull(json['variantName']),
      sku: product == null ? null : Json.strOrNull(product['sku']),
      quantity: Json.intOf(json['quantity'], 1),
      unitPrice: Json.dbl(json['unitPrice']),
      discount: Json.dbl(json['discount']),
      total: Json.dbl(json['total']),
    );
  }
}

/// One logged confirmation call.
class OrderCall {
  const OrderCall({
    required this.id,
    required this.result,
    this.notes,
    required this.calledAt,
  });

  final String id;
  final CallResult result;
  final String? notes;
  final DateTime calledAt;

  factory OrderCall.fromJson(Map<String, dynamic> json) => OrderCall(
        id: Json.str(json['id']),
        result: CallResult.of(json['result']),
        notes: Json.strOrNull(json['notes']),
        calledAt: Json.date(json['calledAt']),
      );
}

/// An order — `Order` in the schema.
///
/// **Money arrives as Decimal strings** (`"1500.00"`), which `Json.dbl` parses.
/// The list embeds the items, the client's name and phone, and the five most
/// recent calls; `GET /orders/{id}` carries the full client and every call.
class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    this.clientId,
    required this.clientName,
    this.clientPhone,
    this.clientAddress,
    this.subtotal = 0,
    this.discount = 0,
    this.tax = 0,
    this.total = 0,
    this.amountPaid = 0,
    this.deliveryFee = 0,
    this.paymentMethod = PaymentMethod.cash,
    this.paymentStatus = PaymentStatus.pending,
    this.status = OrderStatus.pending,
    this.deliveryStatus = DeliveryStatus.notSent,
    this.confirmationStatus = ConfirmationStatus.notCalled,
    this.callAttempts = 0,
    this.source = OrderSource.manual,
    this.notes,
    required this.orderDate,
    this.wilayaId,
    this.communeName,
    this.isStopdesk = false,
    this.trackingNumber,
    this.deliveryProvider,
    this.items = const [],
    this.calls = const [],
  });

  final String id;

  /// `ORD-YYYYMMDD-NNNN`, one series per merchant per day.
  final String orderNumber;

  final String? clientId;
  final String clientName;
  final String? clientPhone;
  final String? clientAddress;

  final double subtotal;
  final double discount;
  final double tax;
  final double total;

  /// Cash actually received. The backend clamps it to `[0, total]` and derives
  /// [paymentStatus] from it, so the app sends this and never the status.
  final double amountPaid;

  final double deliveryFee;

  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final OrderStatus status;
  final DeliveryStatus deliveryStatus;
  final ConfirmationStatus confirmationStatus;

  /// How many calls have been logged. The confirmation pill shows it.
  final int callAttempts;

  final OrderSource source;
  final String? notes;
  final DateTime orderDate;

  final int? wilayaId;
  final String? communeName;
  final bool isStopdesk;

  /// The courier's tracking number, set when the order was sent — may stay
  /// null when the courier answered without one.
  final String? trackingNumber;

  /// The **id** of the merchant's courier account the parcel went to (a
  /// `DeliveryProvider` row), not the courier's name.
  final String? deliveryProvider;

  final List<OrderItem> items;

  /// Newest first. Five at most on a list row; all of them on the detail.
  final List<OrderCall> calls;

  /// What is still owed. Never negative — the same `max(0, …)` the web and the
  /// frames use.
  double get remaining {
    final left = total - amountPaid;
    return left > 0 ? left : 0;
  }

  int get itemCount => items.length;

  /// True while the merchant may still log a call against this order. Shipped
  /// and everything after it is a read-only record (the web's `canLogCall`).
  bool get canLogCall =>
      status == OrderStatus.pending ||
      status == OrderStatus.confirmed ||
      status == OrderStatus.preparing;

  /// True when confirming would leave the courier without somewhere to go. The
  /// call sheet refuses to send *Confirmée* in that state, as the web does.
  bool get hasDeliveryAddress =>
      isStopdesk || (clientAddress != null && clientAddress!.trim().isNotEmpty);

  List<OrderStatus> get allowedNext => orderTransitions[status] ?? const [];

  /// `POST /delivery/send/{id}` accepts it: never sent, not cancelled (live
  /// docs) — and, as the web's *Envoyer* button, not returned either.
  bool get canSendToDelivery =>
      deliveryStatus == DeliveryStatus.notSent && !status.isTerminal;

  /// Sent, with something to look up at the courier: *Suivre* and *Étiquette*.
  bool get canTrack =>
      deliveryStatus != DeliveryStatus.notSent && (trackingNumber ?? '').isNotEmpty;

  /// The web's rule, kept: a delivered order is the only one that can be
  /// returned, and only a non-delivered, non-cancelled one can be deleted.
  bool get canMarkReturned => status == OrderStatus.delivered;
  bool get canDelete =>
      status != OrderStatus.delivered && status != OrderStatus.cancelled;

  factory Order.fromJson(Map<String, dynamic> json) {
    final client = Json.mapOrNull(json['client']);
    final items = json['items'];
    final calls = json['calls'];
    return Order(
      id: Json.str(json['id']),
      orderNumber: Json.str(json['orderNumber']),
      clientId: Json.strOrNull(json['clientId']),
      // The column is the snapshot; the relation is the live client. The
      // column wins, because it is what was agreed when the order was placed.
      clientName: Json.strOrNull(json['clientName']) ??
          (client == null ? '' : Json.str(client['name'])),
      clientPhone: _blank(Json.strOrNull(json['clientPhone'])) ??
          (client == null ? null : _blank(Json.strOrNull(client['phone']))),
      clientAddress: _blank(Json.strOrNull(json['clientAddress'])),
      subtotal: Json.dbl(json['subtotal']),
      discount: Json.dbl(json['discount']),
      tax: Json.dbl(json['tax']),
      total: Json.dbl(json['total']),
      amountPaid: Json.dbl(json['amountPaid']),
      deliveryFee: Json.dbl(json['deliveryFee']),
      paymentMethod: PaymentMethod.of(json['paymentMethod']),
      paymentStatus: PaymentStatus.of(json['paymentStatus']),
      status: OrderStatus.of(json['status']),
      deliveryStatus: DeliveryStatus.of(json['deliveryStatus']),
      confirmationStatus: ConfirmationStatus.of(json['confirmationStatus']),
      callAttempts: Json.intOf(json['callAttempts']),
      source: OrderSource.of(json['source']),
      notes: _blank(Json.strOrNull(json['notes'])),
      orderDate: Json.date(json['orderDate']),
      wilayaId: Json.intOrNull(json['wilayaId']),
      communeName: _blank(Json.strOrNull(json['communeName'])),
      isStopdesk: Json.boolOf(json['isStopdesk']),
      trackingNumber: _blank(Json.strOrNull(json['trackingNumber'])),
      deliveryProvider: _blank(Json.strOrNull(json['deliveryProvider'])),
      items: items is List
          ? [
              for (final item in items.whereType<Map<String, dynamic>>())
                OrderItem.fromJson(item),
            ]
          : const [],
      calls: calls is List
          ? [
              for (final call in calls.whereType<Map<String, dynamic>>())
                OrderCall.fromJson(call),
            ]
          : const [],
    );
  }

  static String? _blank(String? value) =>
      value == null || value.trim().isEmpty ? null : value;
}

/// `GET /orders/stats` — the four figures the frame puts above the list.
///
/// **`totalOrders` and `totalRevenue` leave out cancelled and returned orders**
/// (their stock and their caisse rows were rolled back), while the per-status
/// counts below count everything. Server-computed, so they do not follow the
/// search or the filters — unlike the list screens built before this one,
/// which derive their figures from the loaded rows.
class OrderStats {
  const OrderStats({
    this.totalOrders = 0,
    this.totalRevenue = 0,
    this.pending = 0,
    this.confirmed = 0,
    this.preparing = 0,
    this.shipped = 0,
    this.delivered = 0,
    this.cancelled = 0,
    this.returned = 0,
    this.notSent = 0,
    this.sent = 0,
    this.inTransit = 0,
    this.deliveredDelivery = 0,
  });

  final int totalOrders;
  final double totalRevenue;
  final int pending;
  final int confirmed;
  final int preparing;
  final int shipped;
  final int delivered;
  final int cancelled;
  final int returned;

  /// Counts per **delivery** status — the four figures on *Livraison*.
  /// `deliveredDelivery` is the courier's "delivered", distinct from the
  /// order status of the same name.
  final int notSent;
  final int sent;
  final int inTransit;
  final int deliveredDelivery;

  /// The count for one tab, so the active tab can show its own figure.
  int? countFor(OrderStatus? status) => switch (status) {
        null => totalOrders,
        OrderStatus.pending => pending,
        OrderStatus.confirmed => confirmed,
        OrderStatus.preparing => preparing,
        OrderStatus.shipped => shipped,
        OrderStatus.delivered => delivered,
        OrderStatus.cancelled => cancelled,
        OrderStatus.returned => returned,
      };

  factory OrderStats.fromJson(Map<String, dynamic> json) {
    final stats = Json.mapOrNull(json['stats']) ?? json;
    return OrderStats(
      totalOrders: Json.intOf(stats['totalOrders']),
      totalRevenue: Json.dbl(stats['totalRevenue']),
      pending: Json.intOf(stats['pending']),
      confirmed: Json.intOf(stats['confirmed']),
      preparing: Json.intOf(stats['preparing']),
      shipped: Json.intOf(stats['shipped']),
      delivered: Json.intOf(stats['delivered']),
      cancelled: Json.intOf(stats['cancelled']),
      returned: Json.intOf(stats['returned']),
      notSent: Json.intOf(stats['notSent']),
      sent: Json.intOf(stats['sent']),
      inTransit: Json.intOf(stats['inTransit']),
      deliveredDelivery: Json.intOf(stats['deliveredDelivery']),
    );
  }
}

/// One page of the list, with the server's unfiltered total for the subtitle.
typedef OrderPage = ({List<Order> orders, int total});
