import '../../core/utils/json.dart';
import 'dashboard_stats.dart';

/// `StockMovement.type` — `in`, `out`, `adjustment`, `return` on the wire.
enum StockMovementType { stockIn, stockOut, adjustment, returned, unknown }

/// One row of the dashboard's `recentMovements`.
///
/// The backend stores `quantity` positive for an entry and negative for an
/// exit (live docs, `StockMovement`), but the web prints its own sign in front
/// of it — so [signedQuantity] takes the sign from [type] and the size from
/// the number, and a row never reads `--2`.
class StockMovement {
  const StockMovement({
    required this.id,
    required this.type,
    required this.quantity,
    this.productName,
    this.reason,
    this.createdAt,
  });

  final String id;
  final StockMovementType type;
  final int quantity;

  /// The reduced `product` the endpoint embeds. Null if it was not.
  final String? productName;

  /// Free text — "Réception fournisseur", "Vente", an adjustment's reason.
  final String? reason;

  final DateTime? createdAt;

  /// Positive in, negative out. An adjustment keeps the sign it was stored with.
  int get signedQuantity => switch (type) {
        StockMovementType.stockIn || StockMovementType.returned => quantity.abs(),
        StockMovementType.stockOut => -quantity.abs(),
        _ => quantity,
      };

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    return StockMovement(
      id: Json.strOrNull(json['id']) ?? '',
      type: switch (json['type']) {
        'in' => StockMovementType.stockIn,
        'out' => StockMovementType.stockOut,
        'adjustment' => StockMovementType.adjustment,
        'return' => StockMovementType.returned,
        _ => StockMovementType.unknown,
      },
      quantity: Json.intOf(json['quantity']),
      productName: product is Map<String, dynamic> ? Json.strOrNull(product['name']) : null,
      reason: Json.strOrNull(json['reason']),
      createdAt: Json.dateOrNull(json['createdAt']),
    );
  }
}

/// Everything `GET /api/user-stock/dashboard` returns: the seven figures and
/// the 10 latest movements, newest first.
class StockOverview {
  const StockOverview({this.stats = const DashboardStats(), this.movements = const []});

  final DashboardStats stats;
  final List<StockMovement> movements;

  factory StockOverview.fromJson(Map<String, dynamic> json) {
    final rows = json['recentMovements'];
    return StockOverview(
      stats: DashboardStats.fromJson(json),
      movements: rows is List
          ? rows.whereType<Map<String, dynamic>>().map(StockMovement.fromJson).toList(growable: false)
          : const [],
    );
  }
}

/// `GET /api/user-stock/purchases/stats?period=month` — the Advanced block.
///
/// Cancelled purchases never count. [totalSpent] is cash actually paid out
/// (`amountPaid`), which is the figure the web prints.
class PurchaseStats {
  const PurchaseStats({
    this.totalPurchases = 0,
    this.totalSpent = 0,
    this.pendingPurchases = 0,
    this.receivedPurchases = 0,
  });

  final int totalPurchases;
  final double totalSpent;
  final int pendingPurchases;
  final int receivedPurchases;

  factory PurchaseStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'];
    final map = stats is Map<String, dynamic> ? stats : json;
    return PurchaseStats(
      totalPurchases: Json.intOf(map['totalPurchases']),
      totalSpent: Json.dbl(map['totalSpent']),
      pendingPurchases: Json.intOf(map['pendingPurchases']),
      receivedPurchases: Json.intOf(map['receivedPurchases']),
    );
  }
}
