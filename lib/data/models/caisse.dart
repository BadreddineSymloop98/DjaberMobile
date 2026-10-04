import '../../core/utils/json.dart';

/// Money in or money out.
enum CaisseType {
  income('income'),
  expense('expense');

  const CaisseType(this.wire);
  final String wire;

  static CaisseType of(dynamic value) =>
      values.firstWhere((t) => t.wire == Json.strOrNull(value), orElse: () => CaisseType.expense);
}

/// The API's nine categories. The first three are written only by the sale,
/// order and purchase endpoints; a merchant's own row takes one of [manual].
enum CaisseCategory {
  sale('sale'),
  order('order'),
  purchase('purchase'),
  rent('rent'),
  salary('salary'),
  utilities('utilities'),
  marketing('marketing'),
  shipping('shipping'),
  other('other');

  const CaisseCategory(this.wire);
  final String wire;

  static CaisseCategory of(dynamic value) =>
      values.firstWhere((c) => c.wire == Json.strOrNull(value), orElse: () => CaisseCategory.other);

  /// What the form offers — the web's `MANUAL_CATEGORIES`. Sale, order and
  /// purchase money is posted by those features, and entering it here as well
  /// would count it twice.
  static const manual = [rent, salary, utilities, marketing, shipping, other];
}

/// One ledger row — `CaisseTransaction` in the schema.
///
/// **Automatic rows** ([isAutomatic]) were posted by a sale, an order or a
/// purchase: [sourceId] is that record's id and [reference] its number. The
/// API refuses to edit or delete them (400) — they change with their source.
class CaisseTransaction {
  const CaisseTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.reference,
    this.description,
    required this.date,
    this.isAutomatic = false,
    this.sourceId,
  });

  final String id;
  final CaisseType type;

  /// Always positive; [type] carries the direction.
  final double amount;
  final CaisseCategory category;
  final String? reference;
  final String? description;
  final DateTime date;
  final bool isAutomatic;
  final String? sourceId;

  /// `+7 300` or `−35 000` — the sign the row shows.
  double get signed => type == CaisseType.income ? amount : -amount;

  bool get isEditable => !isAutomatic;

  factory CaisseTransaction.fromJson(Map<String, dynamic> json) => CaisseTransaction(
    id: Json.str(json['id']),
    type: CaisseType.of(json['type']),
    amount: Json.dbl(json['amount']).abs(),
    category: CaisseCategory.of(json['category']),
    reference: _blank(Json.strOrNull(json['reference'])),
    description: _blank(Json.strOrNull(json['description'])),
    date: Json.date(json['date']),
    isAutomatic: Json.boolOf(json['isAutomatic']),
    sourceId: _blank(Json.strOrNull(json['sourceId'])),
  );

  static String? _blank(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();
}

/// `GET /caisse/stats` — every row of the period, manual and automatic.
///
/// [balance] is the period's income minus its expenses, **not** an all-time
/// cash-on-hand figure.
class CaisseStats {
  const CaisseStats({
    this.balance = 0,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.transactionCount = 0,
  });

  final double balance;
  final double totalIncome;
  final double totalExpense;
  final int transactionCount;

  factory CaisseStats.fromJson(Map<String, dynamic> json) {
    final stats = Json.mapOrNull(json['stats']) ?? json;
    return CaisseStats(
      balance: Json.dbl(stats['balance']),
      totalIncome: Json.dbl(stats['totalIncome']),
      totalExpense: Json.dbl(stats['totalExpense']),
      transactionCount: Json.intOf(stats['transactionCount']),
    );
  }
}

typedef CaissePage = ({List<CaisseTransaction> transactions, int total});
