import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';

/// Notifications. The first thing on mobile to call this API at all.
///
/// The endpoints have existed since before the app did — `api_endpoints.dart`
/// has carried them with the note *"the API exists, mobile has never used
/// it"* (brief Q7). Only the unread count is wired so far, because that is
/// what the drawer's badge needs; the list, `read` and `read-all` are still
/// unused and stay in `Api` rather than here until a screen wants them.
class NotificationRepository {
  NotificationRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /api/user-stock/notifications/unread-count` → `{ "count": 0 }`.
  ///
  /// Verified against the live backend on 2026-09-10, and read from
  /// `user-notifications.controller.ts:36` rather than inferred: it is a
  /// `prisma.notification.count` over `isRead: false`, returned under a bare
  /// `count` key with no envelope.
  Future<Result<int>> unreadCount() => _api.get<int>(
        Api.notificationsUnreadCount,
        // Through `Json.map` and a tolerant cast for the same reason every
        // other model is: Prisma sends an `Int` as a number but the shape of
        // an envelope has changed before, so a missing or string `count`
        // degrades to 0 rather than throwing a parse failure that the UI
        // would have to render as an error.
        parse: (json) {
          final value = Json.map(json)['count'];
          if (value is int) return value;
          if (value is num) return value.toInt();
          if (value is String) return int.tryParse(value) ?? 0;
          return 0;
        },
      );
}
