import 'stock_overview.dart';

/// What wrote a stock movement, read back from its `reason`.
///
/// The backend writes fixed English reasons (live docs): `Sale SL-…`,
/// `Deleted sale SL-…`, `Purchase PO-…`, `Purchase PO-… cancelled`,
/// `Order ORD-…`, `Cancelled order ORD-…`, `Returned order ORD-…`,
/// `Deleted order ORD-…`, `Initial stock`, `Initial variant stock`,
/// `Variant deleted`. The number is only in the reason — `reference` is the
/// record's id — so the row's text and its link both come from here. Anything
/// else (a merchant's own adjustment reason) is [OriginKind.other] and shown
/// as typed.
enum OriginKind {
  sale,
  saleDeleted,
  purchase,
  purchaseCancelled,
  order,
  orderCancelled,
  orderReturned,
  orderDeleted,
  initialStock,
  variantDeleted,
  other,
}

class MovementOrigin {
  const MovementOrigin(this.kind, {this.number, this.raw});

  final OriginKind kind;

  /// `SL-20261004-0001`, `PO-…`, `ORD-…` — null for the kinds without one.
  final String? number;

  /// The reason as stored, for [OriginKind.other].
  final String? raw;

  static final _sale = RegExp(r'^Sale (SL-\S+)$');
  static final _saleDeleted = RegExp(r'^Deleted sale (SL-\S+)$');
  static final _purchase = RegExp(r'^Purchase (PO-\S+)$');
  static final _purchaseCancelled = RegExp(r'^Purchase (PO-\S+) cancelled$');
  static final _order = RegExp(r'^Order (ORD-\S+)$');
  static final _orderCancelled = RegExp(r'^Cancelled order (ORD-\S+)$');
  static final _orderReturned = RegExp(r'^Returned order (ORD-\S+)$');
  static final _orderDeleted = RegExp(r'^Deleted order (ORD-\S+)$');

  factory MovementOrigin.of(StockMovement movement) {
    final reason = movement.reason?.trim() ?? '';
    for (final (pattern, kind) in [
      (_sale, OriginKind.sale),
      (_saleDeleted, OriginKind.saleDeleted),
      (_purchaseCancelled, OriginKind.purchaseCancelled),
      (_purchase, OriginKind.purchase),
      (_order, OriginKind.order),
      (_orderCancelled, OriginKind.orderCancelled),
      (_orderReturned, OriginKind.orderReturned),
      (_orderDeleted, OriginKind.orderDeleted),
    ]) {
      if (pattern.firstMatch(reason) case final match?) {
        return MovementOrigin(kind, number: match.group(1));
      }
    }
    if (reason == 'Initial stock' || reason == 'Initial variant stock') {
      return const MovementOrigin(OriginKind.initialStock);
    }
    if (reason == 'Variant deleted') return const MovementOrigin(OriginKind.variantDeleted);
    return MovementOrigin(OriginKind.other, raw: reason.isEmpty ? null : reason);
  }

  /// Where tapping the row leads, or null. A deleted record has nowhere to go.
  OriginLink? linkFor(StockMovement movement) {
    final id = movement.reference;
    if (id == null || id.isEmpty) return null;
    return switch (kind) {
      OriginKind.sale => OriginLink.sale(id),
      OriginKind.purchase || OriginKind.purchaseCancelled => OriginLink.purchase(id),
      OriginKind.order ||
      OriginKind.orderCancelled ||
      OriginKind.orderReturned => OriginLink.order(id),
      _ => null,
    };
  }
}

enum OriginTarget { sale, purchase, order }

class OriginLink {
  const OriginLink.sale(this.id) : target = OriginTarget.sale;
  const OriginLink.purchase(this.id) : target = OriginTarget.purchase;
  const OriginLink.order(this.id) : target = OriginTarget.order;

  final OriginTarget target;
  final String id;
}
