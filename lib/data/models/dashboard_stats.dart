import '../../core/utils/json.dart';

/// The stock figures behind `09 — Accueil`'s Aperçu tiles.
///
/// From `GET /api/user-stock/dashboard` → `{ stats, recentMovements }`
/// (`user-stock.controller.ts:1010`). Every number is computed server-side,
/// including two raw SQL sums that add variant-level value to parent-level
/// value — so nothing here is derived on the phone.
class DashboardStats {
  const DashboardStats({
    this.totalProducts = 0,
    this.lowStockProducts = 0,
    this.totalCategories = 0,
    this.totalSuppliers = 0,
    this.totalStockValue = 0,
    this.totalRetailValue = 0,
    this.totalItems = 0,
  });

  final int totalProducts;

  /// Products at or below their own `minQuantity`. The tile's second line.
  final int lowStockProducts;

  final int totalCategories;
  final int totalSuppliers;

  /// Cost value of everything on hand, in DA.
  final double totalStockValue;

  /// What it would sell for.
  final double totalRetailValue;

  /// Units on hand across every product.
  final int totalItems;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'];
    final map = stats is Map<String, dynamic> ? stats : json;
    return DashboardStats(
      totalProducts: Json.intOf(map['totalProducts']),
      lowStockProducts: Json.intOf(map['lowStockProducts']),
      totalCategories: Json.intOf(map['totalCategories']),
      totalSuppliers: Json.intOf(map['totalSuppliers']),
      totalStockValue: Json.dbl(map['totalStockValue']),
      totalRetailValue: Json.dbl(map['totalRetailValue']),
      totalItems: Json.intOf(map['totalItems']),
    );
  }
}

/// Revenue over a period, for the `Chiffre d'affaires (30j)` tile.
///
/// From `GET /api/user-stock/sales/stats?period=month`
/// (`user-sales.controller.ts:616`). **It counts more than walk-in sales**:
/// the controller merges `sale` rows with **delivered** `order` rows, so a
/// merchant whose income arrives as AI-created orders still sees it here.
/// Orders that are not delivered are excluded, because they can still be
/// cancelled and counting them would inflate the figure.
class SalesStats {
  const SalesStats({this.totalSales = 0, this.totalRevenue = 0});

  /// Sales plus delivered orders — the tile's "N vente" line.
  final int totalSales;

  /// Their combined total, in DA.
  final double totalRevenue;

  factory SalesStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'];
    final map = stats is Map<String, dynamic> ? stats : json;
    return SalesStats(
      totalSales: Json.intOf(map['totalSales']),
      totalRevenue: Json.dbl(map['totalRevenue']),
    );
  }
}
