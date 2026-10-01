import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';

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

/// The delivery side of the stock API — only the two routes the order form
/// needs. Sending a parcel to a courier is not built yet (the frames say
/// *Yalidine / ZR — bientôt*).
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
}
