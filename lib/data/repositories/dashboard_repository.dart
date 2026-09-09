import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../models/conversation.dart';
import '../models/dashboard_stats.dart';

/// The figures and the queue behind `09 — Accueil`.
class DashboardRepository {
  DashboardRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /api/user-stock/dashboard` → `{ stats, recentMovements }`.
  Future<Result<DashboardStats>> stats() => _api.get<DashboardStats>(
        Api.dashboard,
        parse: (json) => DashboardStats.fromJson(json as Map<String, dynamic>),
      );

  /// `GET /api/user-stock/sales/stats?period=month`.
  ///
  /// `month` is the endpoint's own name for "the last month", which is what
  /// the frame's `CHIFFRE D'AFFAIRES (30J)` tile means. The other accepted
  /// values are `today`, `week` and `year`.
  Future<Result<SalesStats>> salesStats() => _api.get<SalesStats>(
        Api.salesStats,
        query: const {'period': 'month'},
        parse: (json) => SalesStats.fromJson(json as Map<String, dynamic>),
      );

  /// `GET /api/pages/:pageId/conversations` for one Page.
  ///
  /// There is **no endpoint that lists conversations across Pages** — the
  /// route is nested under a page and checks ownership of it. So the queue is
  /// assembled client-side, one request per connected Page. That is cheap in
  /// practice: the plans cap Pages at 1, 3 and 10.
  Future<Result<List<Conversation>>> conversationsFor(String pageId) {
    return _api.get<List<Conversation>>(
      Api.pageConversations(pageId),
      parse: (json) {
        final map = json as Map<String, dynamic>;
        final rows = map['conversations'];
        if (rows is! List) return const <Conversation>[];
        return rows
            .whereType<Map<String, dynamic>>()
            .map((row) => Conversation.fromJson(row, pageId: pageId))
            .toList(growable: false);
      },
    );
  }
}
