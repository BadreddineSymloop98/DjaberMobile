import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../models/supplier.dart';

/// Suppliers, against `/api/user-stock/suppliers` — the web's
/// `dashboard/stock/suppliers`.
class SupplierRepository {
  SupplierRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /api/user-stock/suppliers` → `{ suppliers }`, ordered by name.
  ///
  /// **Active and inactive together by default** — pass [isActive] to
  /// restrict. No pagination. From the live docs:
  ///
  /// - [search] matches name, e-mail or phone.
  /// - [startDate] / [endDate] bound `createdAt`, the end extended to the end of
  ///   that day. Sent as `yyyy-MM-dd`.
  /// - [minPurchases], [maxPurchases] and [minTotalSpent] apply only above 0.
  /// - [maxTotalSpent] applies **whenever it is a number, 0 included** — so it is
  ///   sent only when the merchant typed one.
  Future<Result<List<Supplier>>> list({
    String? search,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    int? minPurchases,
    int? maxPurchases,
    double? minTotalSpent,
    double? maxTotalSpent,
  }) {
    String day(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return _api.get<List<Supplier>>(
      Api.suppliers,
      query: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (isActive != null) 'isActive': '$isActive',
        if (startDate != null) 'startDate': day(startDate),
        if (endDate != null) 'endDate': day(endDate),
        if (minPurchases != null && minPurchases > 0) 'minPurchases': minPurchases,
        if (maxPurchases != null && maxPurchases > 0) 'maxPurchases': maxPurchases,
        if (minTotalSpent != null && minTotalSpent > 0) 'minTotalSpent': minTotalSpent,
        'maxTotalSpent': ?maxTotalSpent,
      },
      parse: (json) => Json.listAt(json as Map<String, dynamic>, 'suppliers', Supplier.fromJson),
    );
  }

  /// One supplier, **read from the list** — the backend has no
  /// `GET /suppliers/{id}`. Null in the result when no row has that id.
  Future<Result<Supplier?>> find(String supplierId) async {
    final result = await list();
    return switch (result) {
      Success(:final value) => Result.success(
          value.where((s) => s.id == supplierId).firstOrNull,
        ),
      Failure(:final error) => Result.failure(error),
    };
  }

  /// `POST /api/user-stock/suppliers` → **201** `{ supplier }`, active.
  ///
  /// Only `name` is required, and it must be unique for the merchant (400).
  /// Optional fields are omitted when empty; the server truncates long ones
  /// (e-mail 255, phone 50, address 1000, notes 5000), which the form caps at
  /// the keyboard so nothing is cut silently.
  Future<Result<Supplier>> create({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? notes,
  }) {
    return _api.post<Supplier>(
      Api.suppliers,
      body: {
        'name': name.trim(),
        ..._optional('email', email),
        ..._optional('phone', phone),
        ..._optional('address', address),
        ..._optional('notes', notes),
      },
      parse: _parse,
    );
  }

  /// `PUT /api/user-stock/suppliers/{id}` → `{ supplier }`.
  ///
  /// Every field is sent, empty ones as `""` — which is what clears them (the
  /// web sends `undefined`, which keeps the old value). [isActive] `true`
  /// restores a deleted supplier. A duplicate name is a **500** on this route,
  /// so the form checks names before sending. No length check runs here.
  Future<Result<Supplier>> update(
    String supplierId, {
    required String name,
    String? email,
    String? phone,
    String? address,
    String? notes,
    required bool isActive,
  }) {
    return _api.put<Supplier>(
      Api.supplier(supplierId),
      body: {
        'name': name.trim(),
        'email': email?.trim() ?? '',
        'phone': phone?.trim() ?? '',
        'address': address?.trim() ?? '',
        'notes': notes?.trim() ?? '',
        'isActive': isActive,
      },
      parse: _parse,
    );
  }

  /// `DELETE /api/user-stock/suppliers/{id}` — a **soft** delete.
  ///
  /// It sets `isActive = false`: the supplier stays in the list as inactive,
  /// its purchases are kept, and ticking *Actif* in the edit form restores it.
  Future<Result<void>> delete(String supplierId) {
    return _api.delete<void>(Api.supplier(supplierId), parse: (_) {});
  }

  static Map<String, String> _optional(String key, String? value) =>
      value == null || value.trim().isEmpty ? const {} : {key: value.trim()};

  static Supplier _parse(dynamic json) {
    final map = json as Map<String, dynamic>;
    final supplier = map['supplier'];
    return Supplier.fromJson(supplier is Map<String, dynamic> ? supplier : map);
  }
}
