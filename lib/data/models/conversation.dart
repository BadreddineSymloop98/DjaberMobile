import '../../core/utils/json.dart';
import 'connected_page.dart';

/// A customer thread on a connected Page.
///
/// From `GET /api/pages/:pageId/conversations`, which returns a flattened
/// shape rather than the raw model: `senderName`, `status`, `aiPaused`,
/// `platform`, and the single most recent message
/// (`page-config.controller.ts:116`).
///
/// **`aiPaused` is the escalation.** The schema comments it as *"true = human
/// takeover, AI must not auto-reply (set by HANDOFF/UNCLEAR/UNKNOWN)"* — so it
/// is exactly the trigger §13.2 F1 describes, already computed by the backend.
/// The `À traiter` queue on `09 — Accueil` is the set of conversations where
/// it is true.
class Conversation {
  const Conversation({
    required this.id,
    required this.pageId,
    this.senderName,
    this.senderId = '',
    this.status = 'active',
    this.aiPaused = false,
    this.platform = PagePlatform.facebook,
    this.lastMessage,
    this.lastMessageAt,
    this.updatedAt,
  });

  final String id;

  /// Our page row id. Not in the response — filled in by the repository from
  /// the page it was fetched for, so the queue can say which Page a thread is
  /// on without a second lookup.
  final String pageId;

  final String? senderName;
  final String senderId;

  /// `active`, `resolved` or `archived`.
  final String status;

  /// The AI has stopped and is waiting for the merchant. See the class note.
  final bool aiPaused;

  final PagePlatform platform;

  /// The most recent message's text, whoever sent it.
  final String? lastMessage;

  final DateTime? lastMessageAt;
  final DateTime? updatedAt;

  /// What to show as the customer's name when the platform gave us none.
  String get displayName {
    final name = senderName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return senderId.isNotEmpty ? senderId : '—';
  }

  /// Newest activity, for ordering the queue. Falls back to `updatedAt`, which
  /// the backend already sorts by.
  DateTime? get lastActivity => lastMessageAt ?? updatedAt;

  factory Conversation.fromJson(Map<String, dynamic> json, {String pageId = ''}) {
    final last = json['lastMessage'];
    final lastMap = last is Map<String, dynamic> ? last : null;

    return Conversation(
      id: Json.str(json['id']),
      pageId: pageId,
      senderName: Json.strOrNull(json['senderName']),
      senderId: Json.str(json['senderId']),
      status: Json.str(json['status'], 'active'),
      aiPaused: Json.boolOf(json['aiPaused']),
      platform: PagePlatform.fromName(Json.strOrNull(json['platform'])),
      lastMessage: Json.strOrNull(lastMap?['text']),
      lastMessageAt: Json.dateOrNull(lastMap?['timestamp']),
      updatedAt: Json.dateOrNull(json['updatedAt']),
    );
  }
}
