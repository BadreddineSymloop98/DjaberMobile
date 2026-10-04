import '../../core/utils/json.dart';

/// `cross_sell` (bought with it) or `up_sell` (a pricier alternative).
enum RecommendationType {
  crossSell('cross_sell'),
  upSell('up_sell');

  const RecommendationType(this.wire);
  final String wire;

  static RecommendationType of(dynamic value) => values.firstWhere(
    (t) => t.wire == Json.strOrNull(value),
    orElse: () => RecommendationType.crossSell,
  );
}

/// The compact product a recommendation embeds.
class RecommendationProduct {
  const RecommendationProduct({
    required this.id,
    required this.name,
    this.sku,
    this.sellingPrice = 0,
  });

  final String id;
  final String name;
  final String? sku;
  final double sellingPrice;

  factory RecommendationProduct.fromJson(Map<String, dynamic>? json) => RecommendationProduct(
    id: Json.str(json?['id']),
    name: Json.str(json?['name']),
    sku: Json.strOrNull(json?['sku']),
    sellingPrice: Json.dbl(json?['sellingPrice']),
  );
}

/// Why the backend paired the two products, read back from its fixed English
/// `reason` so the card can say it in the merchant's language. Four shapes
/// (backend `recommendation.service.ts`); anything else is shown as stored.
enum ReasonKind { boughtTogether, premiumAlternative, similarDescription, related, other }

class RecommendationReason {
  const RecommendationReason(this.kind, {this.count, this.percent, this.raw});

  final ReasonKind kind;

  /// How many times the two were bought together.
  final int? count;

  /// The share of orders, the price step or the description match, 0–100.
  final int? percent;

  final String? raw;

  static final _bought = RegExp(r'^Bought together (\d+) time\(s\) \((\d+)% of orders\)$');
  static final _premium = RegExp(r'^Premium alternative in same category \(\+(\d+)% price\)$');
  static final _similar = RegExp(r'^Similar product description \((\d+)% match\)$');
  static final _related = RegExp(r'^Related products \((\d+)% description match\)$');

  factory RecommendationReason.parse(String? reason) {
    final text = reason?.trim() ?? '';
    if (_bought.firstMatch(text) case final m?) {
      return RecommendationReason(
        ReasonKind.boughtTogether,
        count: int.parse(m.group(1)!),
        percent: int.parse(m.group(2)!),
      );
    }
    if (_premium.firstMatch(text) case final m?) {
      return RecommendationReason(ReasonKind.premiumAlternative, percent: int.parse(m.group(1)!));
    }
    if (_similar.firstMatch(text) case final m?) {
      return RecommendationReason(ReasonKind.similarDescription, percent: int.parse(m.group(1)!));
    }
    if (_related.firstMatch(text) case final m?) {
      return RecommendationReason(ReasonKind.related, percent: int.parse(m.group(1)!));
    }
    return RecommendationReason(ReasonKind.other, raw: text.isEmpty ? null : text);
  }
}

/// One recommendation — `ProductRecommendation` with both products embedded.
///
/// Built by `POST /cross-sell/generate` (a local algorithm, no AI credits);
/// [impressions], [conversions] and [revenue] grow as the agent proposes the
/// pair in chat and customers buy it.
class Recommendation {
  const Recommendation({
    required this.id,
    required this.type,
    required this.product,
    required this.recommended,
    this.score = 0,
    this.reason,
    this.impressions = 0,
    this.conversions = 0,
    this.revenue = 0,
    this.isActive = true,
  });

  final String id;
  final RecommendationType type;
  final RecommendationProduct product;
  final RecommendationProduct recommended;

  /// Confidence, 0–1.
  final double score;
  final String? reason;
  final int impressions;
  final int conversions;
  final double revenue;

  /// Inactive rows are hidden from the agent — and, unlike a deleted one,
  /// survive the next generation.
  final bool isActive;

  /// Conversions per impression, in percent; null before any impression.
  double? get conversionRate => impressions == 0 ? null : conversions / impressions * 100;

  Recommendation copyWith({bool? isActive}) => Recommendation(
    id: id,
    type: type,
    product: product,
    recommended: recommended,
    score: score,
    reason: reason,
    impressions: impressions,
    conversions: conversions,
    revenue: revenue,
    isActive: isActive ?? this.isActive,
  );

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
    id: Json.str(json['id']),
    type: RecommendationType.of(json['type']),
    product: RecommendationProduct.fromJson(Json.mapOrNull(json['product'])),
    recommended: RecommendationProduct.fromJson(Json.mapOrNull(json['recommended'])),
    score: Json.dbl(json['score']),
    reason: Json.strOrNull(json['reason']),
    impressions: Json.intOf(json['impressions']),
    conversions: Json.intOf(json['conversions']),
    revenue: Json.dbl(json['revenue']),
    isActive: Json.boolOf(json['isActive'], true),
  );
}

/// `GET /cross-sell/stats` — over every recommendation, whatever the filters.
class RecommendationStats {
  const RecommendationStats({
    this.total = 0,
    this.active = 0,
    this.totalImpressions = 0,
    this.totalConversions = 0,
    this.conversionRate = 0,
    this.totalRevenue = 0,
  });

  final int total;
  final int active;
  final int totalImpressions;
  final int totalConversions;

  /// Already a percentage with two decimals.
  final double conversionRate;
  final double totalRevenue;

  factory RecommendationStats.fromJson(Map<String, dynamic> json) => RecommendationStats(
    total: Json.intOf(json['total']),
    active: Json.intOf(json['active']),
    totalImpressions: Json.intOf(json['totalImpressions']),
    totalConversions: Json.intOf(json['totalConversions']),
    conversionRate: Json.dbl(json['conversionRate']),
    totalRevenue: Json.dbl(json['totalRevenue']),
  );
}
