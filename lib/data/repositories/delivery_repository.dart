import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../models/delivery.dart';
import '../models/order.dart';

/// One of the 58 wilayas, as `GET /delivery/wilayas` returns it.
///
/// Carries all three names, so the picker can read in the merchant's own
/// language rather than always in French.
class Wilaya {
  const Wilaya({
    required this.id,
    required this.code,
    required this.nameAr,
    required this.nameFr,
    required this.nameEn,
  });

  final int id;
  final String code;
  final String nameAr;
  final String nameFr;
  final String nameEn;

  /// `16 — Alger`, the way the frame writes it.
  String label(String languageCode) => '$code — ${nameFor(languageCode)}';

  String nameFor(String languageCode) => switch (languageCode) {
        'ar' => nameAr.isEmpty ? nameFr : nameAr,
        'en' => nameEn.isEmpty ? nameFr : nameEn,
        _ => nameFr,
      };

  factory Wilaya.fromJson(Map<String, dynamic> json) => Wilaya(
        id: Json.intOf(json['id']),
        code: Json.str(json['code']),
        nameAr: Json.str(json['name']),
        nameFr: Json.str(json['nameFr']),
        nameEn: Json.str(json['nameEn']),
      );
}

/// What a delivery costs to one wilaya.
typedef DeliveryQuote = ({double fee, String source});

/// The delivery side of the stock API: wilayas and quotes (the order form),
/// and everything *Livraison* does — courier accounts, the fee table, sending
/// a parcel, tracking it, its label.
///
/// Courier calls (send, track, label, rates, test) can take seconds: the
/// backend talks to the courier's own API in the same request.
class DeliveryRepository {
  DeliveryRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /api/user-stock/delivery/wilayas` → `{ wilayas }`.
  ///
  /// The list never changes, so it is cached for the life of the app: the new
  /// order form reads it on every open, and 58 rows down a metered connection
  /// each time would be waste.
  List<Wilaya>? _cache;

  Future<Result<List<Wilaya>>> wilayas() async {
    if (_cache case final cached?) return Result.success(cached);
    final result = await _api.get<List<Wilaya>>(
      Api.deliveryWilayas,
      parse: (json) =>
          Json.listAt(json as Map<String, dynamic>, 'wilayas', Wilaya.fromJson),
    );
    if (result.valueOrNull case final value?) _cache = value;
    return result;
  }

  /// `GET /api/user-stock/delivery/fees/quote` → the fee for one wilaya.
  ///
  /// The server works down its own ladder — the courier's live rate, then the
  /// merchant's own rule, then a built-in table — and answers 0 when every one
  /// of them fails. It is never an error, so the form shows whatever comes
  /// back and lets the merchant see it before they commit.
  Future<Result<DeliveryQuote>> quote({
    required int wilayaId,
    bool isStopdesk = false,
  }) {
    return _api.get<DeliveryQuote>(
      Api.deliveryFeeQuote,
      query: {'wilayaId': wilayaId, 'isStopdesk': '$isStopdesk'},
      parse: (json) {
        final map = json as Map<String, dynamic>;
        return (fee: Json.dbl(map['fee']), source: Json.str(map['source']));
      },
    );
  }

  // ---- Sending and following a parcel ----

  /// `POST /delivery/send/{orderId}` → `{ order, shipment, tracking }`.
  ///
  /// Refused with a 400 when the order is cancelled, already sent, when no
  /// courier is configured, or when the courier rejects the parcel (its own
  /// message). **The order's own wilaya is ignored server-side** unless sent
  /// here — the sheet always sends it. [communeName] goes out as `toCommuneId`,
  /// which carries a commune *name* despite its suffix (live docs).
  Future<Result<Order>> send(
    String orderId, {
    String? providerId,
    required int toWilayaId,
    String? communeName,
    bool isStopdesk = false,
    String? note,
  }) {
    return _api.post<Order>(
      Api.deliverySend(orderId),
      body: {
        'providerId': ?providerId,
        'toWilayaId': toWilayaId,
        if (communeName != null && communeName.trim().isNotEmpty) 'toCommuneId': communeName.trim(),
        'isStopdesk': isStopdesk,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
      parse: (json) => Order.fromJson(Json.map((json as Map<String, dynamic>)['order'])),
    );
  }

  /// `GET /delivery/track/{orderId}` — the courier's own view of the parcel.
  /// Nothing is written back to the order.
  Future<Result<ParcelTracking>> track(String orderId) => _api.get<ParcelTracking>(
        Api.deliveryTrack(orderId),
        parse: (json) => ParcelTracking.fromJson(json as Map<String, dynamic>),
      );

  /// `GET /delivery/label/{orderId}` — a link (Yalidine) or a PDF (Maystro).
  Future<Result<ShippingLabel>> label(String orderId) => _api.get<ShippingLabel>(
        Api.deliveryLabel(orderId),
        parse: (json) => ShippingLabel.fromJson(json as Map<String, dynamic>),
      );

  /// `GET /delivery/rates?provider&toWilaya` — the courier's live tariff, for
  /// the *Tarifs estimés* box. [courier] is the courier name (`yalidine`), as
  /// the web sends it. Never an error worth showing: null rates mean "none".
  Future<Result<CourierRates>> rates({required String courier, required int toWilayaId}) =>
      _api.get<CourierRates>(
        Api.deliveryRates,
        query: {'provider': courier, 'toWilaya': toWilayaId},
        parse: (json) {
          final rates = Json.mapOrNull((json as Map<String, dynamic>)['rates']) ?? const {};
          double? positive(dynamic v) {
            final d = Json.dblOrNull(v);
            return d != null && d > 0 ? d : null;
          }

          return (home: positive(rates['home_delivery']), stopdesk: positive(rates['stopdesk']));
        },
      );

  // ---- The fee table ----

  /// `GET /delivery/fees` → `{ rules }` — always the 58 wilayas, defaults and
  /// the merchant's own prices merged.
  Future<Result<List<DeliveryFeeRow>>> fees() => _api.get<List<DeliveryFeeRow>>(
        Api.deliveryFees,
        parse: (json) => Json.listAt(json as Map<String, dynamic>, 'rules', DeliveryFeeRow.fromJson),
      );

  /// `POST /delivery/fees` — upsert one wilaya's prices.
  Future<Result<void>> saveFee({
    required int wilayaId,
    required double homePrice,
    required double stopdeskPrice,
    required double returnPrice,
  }) =>
      _api.post<void>(
        Api.deliveryFees,
        body: {
          'wilayaId': wilayaId,
          'homePrice': homePrice,
          'stopdeskPrice': stopdeskPrice,
          'returnPrice': returnPrice,
        },
      );

  /// `DELETE /delivery/fees/{wilayaId}` — back to the system default.
  Future<Result<void>> resetFee(int wilayaId) => _api.delete<void>(Api.deliveryFee(wilayaId));

  /// `POST /delivery/fees/seed` — *Compléter les manquants* (`overwrite:
  /// false`, only wilayas without a rule) or *Tout réinitialiser* (`true`,
  /// every custom price replaced by the defaults). Returns how many were written.
  Future<Result<int>> seedFees({required bool overwrite}) => _api.post<int>(
        Api.deliveryFeesSeed,
        body: {'overwrite': overwrite},
        parse: (json) => Json.intOf((json as Map<String, dynamic>)['seeded']),
      );

  // ---- Courier accounts ----

  /// `GET /delivery/providers` → `{ providers }`, newest first.
  Future<Result<List<DeliveryProvider>>> providers() => _api.get<List<DeliveryProvider>>(
        Api.deliveryProviders,
        parse: (json) => Json.listAt(json as Map<String, dynamic>, 'providers', DeliveryProvider.fromJson),
      );

  /// `GET /delivery/providers/available` — the couriers and their credential
  /// fields. Static server-side, so cached like the wilayas.
  List<CourierSchema>? _couriers;

  Future<Result<List<CourierSchema>>> couriers() async {
    if (_couriers case final cached?) return Result.success(cached);
    final result = await _api.get<List<CourierSchema>>(
      Api.deliveryProvidersAvailable,
      parse: (json) => Json.listAt(json as Map<String, dynamic>, 'providers', CourierSchema.fromJson),
    );
    if (result.valueOrNull case final value?) _couriers = value;
    return result;
  }

  /// `POST /delivery/providers/test` — always `200 { success, message }` once
  /// the request is well formed; nothing is stored.
  Future<Result<({bool ok, String message})>> testCredentials({
    required String courier,
    required Map<String, String> credentials,
  }) =>
      _api.post<({bool ok, String message})>(
        Api.deliveryProvidersTest,
        body: {'provider': courier, 'credentials': credentials},
        parse: (json) {
          final map = json as Map<String, dynamic>;
          return (ok: Json.boolOf(map['success']), message: Json.str(map['message']));
        },
      );

  /// `POST /delivery/providers` — one account per courier per merchant (a
  /// second one is a 409). `isDefault` clears the flag on the others.
  Future<Result<DeliveryProvider>> addProvider({
    required String courier,
    required String displayName,
    required Map<String, String> credentials,
    bool isDefault = false,
    String? senderName,
    String? senderPhone,
    String? senderAddress,
    int? senderWilayaId,
  }) =>
      _api.post<DeliveryProvider>(
        Api.deliveryProviders,
        body: {
          'provider': courier,
          'displayName': displayName,
          'credentials': credentials,
          'isDefault': isDefault,
          'senderName': senderName,
          'senderPhone': senderPhone,
          'senderAddress': senderAddress,
          'senderWilayaId': senderWilayaId,
        },
        parse: _parseProvider,
      );

  /// `PUT /delivery/providers/{id}` — partial. [credentials] null keeps the
  /// stored ones; sender fields sent as null are cleared.
  Future<Result<DeliveryProvider>> updateProvider(
    String id, {
    required String displayName,
    Map<String, String>? credentials,
    required bool isDefault,
    String? senderName,
    String? senderPhone,
    String? senderAddress,
    int? senderWilayaId,
  }) =>
      _api.put<DeliveryProvider>(
        Api.deliveryProvider(id),
        body: {
          'displayName': displayName,
          'credentials': ?credentials,
          'isDefault': isDefault,
          'senderName': senderName,
          'senderPhone': senderPhone,
          'senderAddress': senderAddress,
          'senderWilayaId': senderWilayaId,
        },
        parse: _parseProvider,
      );

  /// `DELETE /delivery/providers/{id}`. Orders already sent keep their tracking
  /// number, but tracking them and their label then answer 400.
  Future<Result<void>> deleteProvider(String id) => _api.delete<void>(Api.deliveryProvider(id));

  static DeliveryProvider _parseProvider(dynamic json) =>
      DeliveryProvider.fromJson(Json.map((json as Map<String, dynamic>)['provider']));
}
