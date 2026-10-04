import '../../core/utils/json.dart';
import 'connected_page.dart';

/// A conversation's `status`, as `PATCH /api/pages/conversations/{id}` takes it.
///
/// **`resolved` is also what a handoff looks like.** Per the live docs, the
/// webhook sets `status = resolved` *and* `aiPaused = true` when the agent
/// hands a customer over — so a paused conversation is usually not `active`.
/// Setting `active` clears `aiPaused` too: reopening resumes the AI.
enum ConversationStatus {
  active('active'),
  resolved('resolved'),
  archived('archived');

  const ConversationStatus(this.wire);

  final String wire;
}

/// A customer thread on a connected Page.
///
/// From `GET /api/pages/:pageId/conversations`, which returns a flattened
/// shape rather than the raw model: `senderName`, `status`, `aiPaused`,
/// `platform`, and the single most recent message.
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
    this.lastMessageFromPage,
    this.updatedAt,
  });

  final String id;

  /// Our page row id. Not in the response — filled in by the repository from
  /// the page it was fetched for, so the queue can say which Page a thread is
  /// on without a second lookup.
  final String pageId;

  final String? senderName;
  final String senderId;

  /// `active`, `resolved` or `archived` — see [ConversationStatus].
  final String status;

  /// The AI has stopped and is waiting for the merchant. See the class note.
  final bool aiPaused;

  final PagePlatform platform;

  /// The most recent message's text, whoever sent it. Null for an attachment
  /// with no text, and for a conversation with no message at all.
  final String? lastMessage;

  final DateTime? lastMessageAt;

  /// Who wrote the most recent message: true for the page (the AI or the
  /// merchant), false for the customer. Null when there is no message yet.
  final bool? lastMessageFromPage;

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

  bool get hasLastMessage => lastMessageFromPage != null;

  bool get isActive => status == ConversationStatus.active.wire;
  bool get isArchived => status == ConversationStatus.archived.wire;

  /// The web's `isUnread`: the customer wrote last and the conversation is
  /// still active. There is no read receipt in the API — this is the whole
  /// signal.
  bool get isUnread => isActive && lastMessageFromPage == false;

  Conversation copyWith({String? status, bool? aiPaused}) => Conversation(
        id: id,
        pageId: pageId,
        senderName: senderName,
        senderId: senderId,
        status: status ?? this.status,
        aiPaused: aiPaused ?? this.aiPaused,
        platform: platform,
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt,
        lastMessageFromPage: lastMessageFromPage,
        updatedAt: updatedAt,
      );

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
      lastMessageFromPage: lastMap == null ? null : Json.boolOf(lastMap['isFromPage']),
      updatedAt: Json.dateOrNull(json['updatedAt']),
    );
  }
}
