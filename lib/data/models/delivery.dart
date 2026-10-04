import 'dart:convert';
import 'dart:typed_data';

import '../../core/utils/json.dart';

/// A courier account the merchant configured — `Ops_DeliveryProviderPublic`.
///
/// The credentials never come back from the API (they are encrypted at rest),
/// so the model has none: an edit form shows them as "unchanged".
class DeliveryProvider {
  const DeliveryProvider({
    required this.id,
    required this.provider,
    required this.displayName,
    this.isActive = true,
    this.isDefault = false,
    this.senderName,
    this.senderPhone,
    this.senderAddress,
    this.senderWilayaId,
  });

  /// The account row's id — what `providerId`, `PUT` and `DELETE` take.
  final String id;

  /// The courier: `yalidine`, `zrexpress` or `maystro`. Immutable after create.
  final String provider;
  final String displayName;
  final bool isActive;

  /// Used by *Envoyer* when no courier is picked, and by the fee quote.
  final bool isDefault;
  final String? senderName;
  final String? senderPhone;
  final String? senderAddress;

  /// Origin wilaya for quotes and parcels. Null means 16 (Alger) server-side.
  final int? senderWilayaId;

  factory DeliveryProvider.fromJson(Map<String, dynamic> json) => DeliveryProvider(
        id: Json.str(json['id']),
        provider: Json.str(json['provider']),
        displayName: Json.str(json['displayName'], Json.str(json['provider'])),
        isActive: Json.boolOf(json['isActive'], true),
        isDefault: Json.boolOf(json['isDefault']),
        senderName: _blank(json['senderName']),
        senderPhone: _blank(json['senderPhone']),
        senderAddress: _blank(json['senderAddress']),
        senderWilayaId: Json.intOrNull(json['senderWilayaId']),
      );
}

/// One credential field a courier needs — from `GET /delivery/providers/available`.
class CourierCredentialField {
  const CourierCredentialField({
    required this.key,
    required this.label,
    this.isSecret = false,
    this.isRequired = true,
  });

  /// The key inside the `credentials` object (`id`, `token`, `key`).
  final String key;

  /// The courier's own name for it (`API ID`, `API Token`) — kept as is.
  final String label;

  /// `type: password` — obscured in the form.
  final bool isSecret;
  final bool isRequired;

  factory CourierCredentialField.fromJson(Map<String, dynamic> json) => CourierCredentialField(
        key: Json.str(json['key']),
        label: Json.str(json['label'], Json.str(json['key'])),
        isSecret: Json.str(json['type']) == 'password',
        isRequired: Json.boolOf(json['required'], true),
      );
}

/// A courier the backend can talk to, and what it needs to connect.
class CourierSchema {
  const CourierSchema({required this.id, required this.name, this.credentials = const []});

  /// `yalidine`, `zrexpress`, `maystro`.
  final String id;

  /// `Yalidine`, `ZR Express`, `Maystro Delivery`.
  final String name;
  final List<CourierCredentialField> credentials;

  factory CourierSchema.fromJson(Map<String, dynamic> json) => CourierSchema(
        id: Json.str(json['id']),
        name: Json.str(json['name'], Json.str(json['id'])),
        credentials: Json.list(json['credentials'], CourierCredentialField.fromJson),
      );
}

/// One row of the 58-wilaya fee table — `Ops_DeliveryFeeTableRow`.
///
/// Prices are JSON numbers here (the upsert answers strings — not read).
class DeliveryFeeRow {
  const DeliveryFeeRow({
    required this.wilayaId,
    required this.code,
    required this.name,
    required this.nameAr,
    required this.homePrice,
    required this.stopdeskPrice,
    required this.returnPrice,
    this.isCustom = false,
    this.isActive = true,
  });

  final int wilayaId;
  final String code;

  /// French name. Note the inversion against `GET /delivery/wilayas`, where
  /// `name` is the Arabic one.
  final String name;
  final String nameAr;
  final double homePrice;
  final double stopdeskPrice;
  final double returnPrice;

  /// The merchant saved a rule for this wilaya; false = the system default.
  final bool isCustom;
  final bool isActive;

  factory DeliveryFeeRow.fromJson(Map<String, dynamic> json) => DeliveryFeeRow(
        wilayaId: Json.intOf(json['wilayaId']),
        code: Json.str(json['code']),
        name: Json.str(json['name']),
        nameAr: Json.str(json['nameAr']),
        homePrice: Json.dbl(json['homePrice']),
        stopdeskPrice: Json.dbl(json['stopdeskPrice']),
        returnPrice: Json.dbl(json['returnPrice']),
        isCustom: Json.boolOf(json['isCustom']),
        isActive: Json.boolOf(json['isActive'], true),
      );
}

/// What the courier says about a parcel.
///
/// The API answers `200 { success, data }` either way: on success `data` is the
/// courier's **raw, provider-specific** object — shown as the frame draws it,
/// field names kept — and on failure `{ error }`.
sealed class ParcelTracking {
  const ParcelTracking();

  factory ParcelTracking.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final error = data is Map ? Json.strOrNull(data['error']) : null;
    if (Json.boolOf(json['success']) && data is Map && error == null) {
      return ParcelFound(_flatten(Map<String, dynamic>.from(data)));
    }
    return ParcelError(error ?? Json.str(json['error']));
  }

  /// One level of nesting folded into `parent.child` keys, lists joined —
  /// enough to read every courier's payload as rows without a JSON viewer.
  static List<MapEntry<String, String>> _flatten(Map<String, dynamic> map, [String prefix = '']) {
    final rows = <MapEntry<String, String>>[];
    for (final entry in map.entries) {
      final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      final value = entry.value;
      if (value == null || (value is String && value.trim().isEmpty)) continue;
      if (value is Map && prefix.isEmpty) {
        rows.addAll(_flatten(Map<String, dynamic>.from(value), key));
      } else if (value is List) {
        if (value.isEmpty) continue;
        rows.add(MapEntry(key, value.map((v) => v is Map ? jsonEncode(v) : '$v').join(', ')));
      } else {
        rows.add(MapEntry(key, value is Map ? jsonEncode(value) : '$value'));
      }
    }
    return rows;
  }
}

class ParcelFound extends ParcelTracking {
  const ParcelFound(this.fields);

  /// The courier's fields, in the order it sent them.
  final List<MapEntry<String, String>> fields;
}

class ParcelError extends ParcelTracking {
  const ParcelError(this.message);

  /// The courier's message — `Tracking ID not found: …` — shown as is.
  final String message;
}

/// The courier's shipping label for a sent order.
sealed class ShippingLabel {
  const ShippingLabel();

  /// `{ success, data: { type: url|pdf, data } }` — Yalidine a link, Maystro a
  /// base64 PDF; `{ success: false, data: { error } }` otherwise (ZR Express
  /// has none).
  factory ShippingLabel.fromJson(Map<String, dynamic> json) {
    final data = Json.mapOrNull(json['data']) ?? const {};
    if (!Json.boolOf(json['success'])) {
      return LabelUnavailable(Json.strOrNull(data['error']) ?? Json.str(json['error']));
    }
    final payload = Json.strOrNull(data['data']);
    if (payload == null || payload.isEmpty) return const LabelUnavailable('');
    return switch (Json.str(data['type'])) {
      'pdf' => LabelPdf(base64Decode(payload)),
      _ => LabelUrl(payload),
    };
  }
}

class LabelUrl extends ShippingLabel {
  const LabelUrl(this.url);
  final String url;
}

class LabelPdf extends ShippingLabel {
  const LabelPdf(this.bytes);
  final Uint8List bytes;
}

class LabelUnavailable extends ShippingLabel {
  const LabelUnavailable(this.message);

  /// The courier's reason, or empty when it simply has not produced one yet.
  final String message;
}

/// A courier's live tariff to one wilaya — `GET /delivery/rates`. Both null
/// when the courier has no rate API (Maystro) or the call failed.
typedef CourierRates = ({double? home, double? stopdesk});

String? _blank(dynamic value) {
  final s = Json.strOrNull(value);
  return s == null || s.trim().isEmpty ? null : s;
}
