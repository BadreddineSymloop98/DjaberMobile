import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../models/recommendation.dart';

/// Cross-sell / up-sell recommendations, against `/api/user-stock/cross-sell`
/// — the web's `dashboard/stock/recommendations`.
///
/// The list is a **bare array** with no pagination, sorted by score.
class RecommendationRepository {
  RecommendationRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /cross-sell`. [search] matches either product's name or sku.
  Future<Result<List<Recommendation>>> list({
    String? search,
    RecommendationType? type,
    bool? isActive,
  }) {
    return _api.get<List<Recommendation>>(
      Api.crossSell,
      query: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (type != null) 'type': type.wire,
        if (isActive != null) 'isActive': '$isActive',
      },
      parse: (json) => json is List
          ? [for (final row in json.whereType<Map<String, dynamic>>()) Recommendation.fromJson(row)]
          : Json.list(Json.map(json)['recommendations'], Recommendation.fromJson),
    );
  }

  /// `GET /cross-sell/stats` — totals over every recommendation.
  Future<Result<RecommendationStats>> stats() {
    return _api.get<RecommendationStats>(
      Api.crossSellStats,
      parse: (json) => RecommendationStats.fromJson(Json.map(json)),
    );
  }

  /// `PUT /cross-sell/{id}` — the only editable field is `isActive`. The
  /// answer carries no product embeds, so only the flag is taken from it.
  Future<Result<bool>> setActive(String id, {required bool isActive}) {
    return _api.put<bool>(
      Api.crossSellItem(id),
      body: {'isActive': isActive},
      parse: (json) => Json.boolOf(Json.map(json)['isActive'], isActive),
    );
  }

  /// `DELETE /cross-sell/{id}`. The next [generate] recreates it if the pair
  /// still qualifies — deactivating is the durable way to hide one.
  Future<Result<void>> delete(String id) {
    return _api.delete<void>(Api.crossSellItem(id), parse: (_) {});
  }

  /// `POST /cross-sell/generate` → `{ success, count, message }`. Synchronous;
  /// `count` is the number of rows created or refreshed. Existing rows keep
  /// their figures and their active flag.
  Future<Result<int>> generate() {
    return _api.post<int>(
      Api.crossSellGenerate,
      parse: (json) => Json.intOf(Json.map(json)['count']),
    );
  }
}
