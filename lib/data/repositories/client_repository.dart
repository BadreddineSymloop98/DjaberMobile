import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../models/client.dart';

/// Clients, against `/api/user-stock/clients` — the web's
/// `dashboard/stock/clients`.
class ClientRepository {
  ClientRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /api/user-stock/clients` → `{ clients }`, newest first.
  ///
  /// **The whole list, always** — the endpoint has no pagination and no total.
  /// Every filter is applied by the server (live docs):
  ///
  /// - [search] matches name, phone or e-mail; [phone] matches the phone only.
  /// - [isActive] and [source] are exact.
  /// - The order and spend bounds are applied only when **greater than 0**, so
  ///   a 0 is never sent.
  /// - [startDate] / [endDate] bound `createdAt`; the end date is extended to
  ///   the end of that day, server time. Sent as `yyyy-MM-dd`.
  Future<Result<List<Client>>> list({
    String? search,
    String? phone,
    bool? isActive,
    ClientSource? source,
    int? minOrders,
    int? maxOrders,
    double? minSpent,
    double? maxSpent,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    String day(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return _api.get<List<Client>>(
      Api.clients,
      query: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (isActive != null) 'isActive': '$isActive',
        if (source != null) 'source': source.name,
        if (minOrders != null && minOrders > 0) 'minOrders': minOrders,
        if (maxOrders != null && maxOrders > 0) 'maxOrders': maxOrders,
        if (minSpent != null && minSpent > 0) 'minSpent': minSpent,
        if (maxSpent != null && maxSpent > 0) 'maxSpent': maxSpent,
        if (startDate != null) 'startDate': day(startDate),
        if (endDate != null) 'endDate': day(endDate),
      },
      parse: (json) => Json.listAt(json as Map<String, dynamic>, 'clients', Client.fromJson),
    );
  }

  /// `GET /api/user-stock/clients/{id}` → `{ client }` with the conversation
  /// count. Orders are not embedded.
  Future<Result<Client>> get(String clientId) {
    return _api.get<Client>(Api.client(clientId), parse: _parseClient);
  }

  /// `GET /api/user-stock/clients/{id}/metrics` — AI-conversation figures and
  /// the conversation history.
  Future<Result<ClientMetrics>> metrics(String clientId) {
    return _api.get<ClientMetrics>(
      Api.clientMetrics(clientId),
      parse: (json) => ClientMetrics.fromJson(json as Map<String, dynamic>),
    );
  }

  /// `POST /api/user-stock/clients` → **201** `{ client }`.
  ///
  /// Only `name` is required by the server; the phone is required by the form,
  /// as on the web ("they need to receive their order"). Empty optional fields
  /// are omitted — the server would store them as null anyway. `source` is left
  /// to its `manual` default. A phone another client of this merchant already
  /// has is a **400**.
  Future<Result<Client>> create({
    required String name,
    required String phone,
    String? email,
    String? address,
    String? notes,
  }) {
    return _api.post<Client>(
      Api.clients,
      body: {
        'name': name.trim(),
        'phone': phone.trim(),
        ..._optional('email', email),
        ..._optional('address', address),
        ..._optional('notes', notes),
      },
      parse: _parseClient,
    );
  }

  /// `PUT /api/user-stock/clients/{id}` → `{ client }`.
  ///
  /// Partial: only the keys present are written, and an **empty string clears**
  /// a field. So every field is sent, empty ones as `""` — the only way to take
  /// an e-mail or an address off a client. (The web sends `undefined` for an
  /// empty one, which leaves the old value in place.) The server does **not**
  /// check the name is non-empty on update; the form does. Duplicate phone:
  /// 400. `source` and the order figures cannot be edited.
  Future<Result<Client>> update(
    String clientId, {
    required String name,
    required String phone,
    String? email,
    String? address,
    String? notes,
  }) {
    return _api.put<Client>(
      Api.client(clientId),
      body: {
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email?.trim() ?? '',
        'address': address?.trim() ?? '',
        'notes': notes?.trim() ?? '',
      },
      parse: _parseClient,
    );
  }

  /// `DELETE /api/user-stock/clients/{id}` — a **hard** delete with no guard.
  ///
  /// The client's orders and conversations are kept and lose their link
  /// (`onDelete: SetNull`); stock movements and caisse rows are untouched.
  Future<Result<void>> delete(String clientId) {
    return _api.delete<void>(Api.client(clientId), parse: (_) {});
  }

  static Map<String, String> _optional(String key, String? value) =>
      value == null || value.trim().isEmpty ? const {} : {key: value.trim()};

  static Client _parseClient(dynamic json) {
    final map = json as Map<String, dynamic>;
    final client = map['client'];
    return Client.fromJson(client is Map<String, dynamic> ? client : map);
  }
}
