import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../models/conversation.dart';
import '../models/conversation_thread.dart';

/// `10 — Boîte de réception` and `10b — Conversation`, against the page
/// conversation routes. Every behaviour noted here is from the live docs.
class InboxRepository {
  InboxRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// How many conversations one page's inbox loads — the web's own `limit`.
  static const pageSize = 100;

  /// `GET /api/pages/{pageId}/conversations?status=all&limit=100`, newest first.
  ///
  /// **`status=all` is required.** The route defaults to `active`, and a
  /// conversation the AI handed over is `resolved` — without it the inbox
  /// would hide exactly the conversations waiting for the merchant.
  Future<Result<List<Conversation>>> conversations(String pageId) {
    return _api.get<List<Conversation>>(
      Api.pageConversations(pageId),
      query: const {'status': 'all', 'limit': pageSize},
      parse: (json) {
        final rows = (json as Map<String, dynamic>)['conversations'];
        if (rows is! List) return const <Conversation>[];
        return rows
            .whereType<Map<String, dynamic>>()
            .map((row) => Conversation.fromJson(row, pageId: pageId))
            .toList(growable: false);
      },
    );
  }

  /// `GET /api/pages/conversations/{id}/messages` — header and messages.
  /// Read-only.
  Future<Result<ConversationThread>> thread(String conversationId) {
    return _api.get<ConversationThread>(
      Api.conversationMessages(conversationId),
      parse: (json) => ConversationThread.fromJson(json as Map<String, dynamic>),
    );
  }

  /// `POST /api/pages/conversations/{id}/reply` → the stored message's id.
  ///
  /// Sent through Meta. **409** when a Facebook customer has not written in 24
  /// hours; **503** for any Instagram error. Replying does not change `status`
  /// or `aiPaused`.
  Future<Result<String?>> reply(String conversationId, String message) {
    return _api.post<String?>(
      Api.conversationReply(conversationId),
      body: {'message': message},
      parse: (json) => json is Map<String, dynamic> ? Json.strOrNull(json['messageId']) : null,
    );
  }

  /// `PATCH /api/pages/conversations/{id}` — `active` also clears `aiPaused`.
  Future<Result<Conversation>> setStatus(String conversationId, ConversationStatus status) {
    return _api.patch<Conversation>(
      Api.conversation(conversationId),
      body: {'status': status.wire},
      parse: (json) {
        final row = (json as Map<String, dynamic>)['conversation'];
        return Conversation.fromJson(row is Map<String, dynamic> ? row : const {});
      },
    );
  }

  /// `POST /api/pages/{pageId}/sync` — the web's Sync button. Pulls up to 25
  /// threads from Meta; no AI, no notifications, no credits.
  Future<Result<InboxSyncResult>> sync(String pageId) {
    return _api.post<InboxSyncResult>(
      Api.pageSync(pageId),
      body: const <String, dynamic>{},
      parse: (json) => InboxSyncResult.fromJson(json as Map<String, dynamic>),
    );
  }
}
