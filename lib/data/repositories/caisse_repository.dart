import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../models/caisse.dart';
import '../models/sale.dart';

/// The cash register, against `/api/user-stock/caisse` — the web's
/// `dashboard/stock/caisse`.
///
/// Only **manual** rows can be created, edited or deleted here; the sale,
/// order and purchase endpoints post and remove their own.
class CaisseRepository {
  CaisseRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /caisse` → `{ transactions, total }`, newest `date` first. [search]
  /// matches the reference or the description.
  Future<Result<CaissePage>> list({
    String? search,
    CaisseType? type,
    CaisseCategory? category,
    DateTime? dateFrom,
    DateTime? dateTo,
    int limit = 30,
    int offset = 0,
  }) {
    return _api.get<CaissePage>(
      Api.caisse,
      query: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (type != null) 'type': type.wire,
        if (category != null) 'category': category.wire,
        if (dateFrom != null)
          'dateFrom': DateTime(
            dateFrom.year,
            dateFrom.month,
            dateFrom.day,
          ).toUtc().toIso8601String(),
        if (dateTo != null)
          'dateTo': DateTime(
            dateTo.year,
            dateTo.month,
            dateTo.day,
            23,
            59,
            59,
            999,
          ).toUtc().toIso8601String(),
        'limit': limit,
        'offset': offset,
      },
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final rows = Json.list(map['transactions'], CaisseTransaction.fromJson);
        return (transactions: rows, total: Json.intOf(map['total'], rows.length));
      },
    );
  }

  /// `GET /caisse/stats?period=` — income, expenses and their difference over
  /// the period, automatic rows included.
  Future<Result<CaisseStats>> stats(SalePeriod period) {
    return _api.get<CaisseStats>(
      Api.caisseStats,
      query: {'period': period.wire},
      parse: (json) => CaisseStats.fromJson(json as Map<String, dynamic>),
    );
  }

  /// `POST /caisse` → **201** `{ transaction }`, a manual row. [amount] must
  /// be above 0 (400 otherwise).
  Future<Result<CaisseTransaction>> create({
    required CaisseType type,
    required double amount,
    required CaisseCategory category,
    String? reference,
    String? description,
    DateTime? date,
  }) {
    return _api.post<CaisseTransaction>(
      Api.caisse,
      body: {
        'type': type.wire,
        'amount': amount,
        'category': category.wire,
        if (reference != null && reference.trim().isNotEmpty) 'reference': reference.trim(),
        if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
        if (date != null) 'date': date.toUtc().toIso8601String(),
      },
      parse: _parse,
    );
  }

  /// `PUT /caisse/{id}` → `{ transaction }`. Manual rows only (400 on an
  /// automatic one). The server does **not** check [amount] here, so the form
  /// does. [reference] / [description] are sent as typed: empty clears them.
  Future<Result<CaisseTransaction>> update(
    String id, {
    required CaisseType type,
    required double amount,
    required CaisseCategory category,
    required String reference,
    required String description,
    required DateTime date,
  }) {
    return _api.put<CaisseTransaction>(
      Api.caisseTransaction(id),
      body: {
        'type': type.wire,
        'amount': amount,
        'category': category.wire,
        'reference': reference.trim(),
        'description': description.trim(),
        'date': date.toUtc().toIso8601String(),
      },
      parse: _parse,
    );
  }

  /// `DELETE /caisse/{id}`. Manual rows only (400 on an automatic one).
  Future<Result<void>> delete(String id) {
    return _api.delete<void>(Api.caisseTransaction(id), parse: (_) {});
  }

  static CaisseTransaction _parse(dynamic json) {
    final map = json as Map<String, dynamic>;
    final row = map['transaction'];
    return CaisseTransaction.fromJson(row is Map<String, dynamic> ? row : map);
  }
}
