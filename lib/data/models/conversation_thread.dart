import '../../core/utils/json.dart';
import 'conversation.dart';

/// One message in a thread, from
/// `GET /api/pages/conversations/{id}/messages`.
class ConversationMessage {
  const ConversationMessage({
    required this.id,
    this.text,
    this.timestamp,
    this.isFromPage = false,
    this.attachmentType,
    this.attachmentUrl,
  });

  final String id;

  /// Null for an attachment sent without text.
  final String? text;

  final DateTime? timestamp;

  /// True for the page — the AI or the merchant; the API does not say which.
  final bool isFromPage;

  /// `image`, `video`, `audio`, `file`, `location`, `fallback` or null.
  final String? attachmentType;

  /// A Meta CDN URL. **It expires**, so an old photo is expected to fail to
  /// load and must fall back quietly.
  final String? attachmentUrl;

  static final _imageUrl = RegExp(r'\.(jpg|jpeg|png|gif|webp)', caseSensitive: false);

  /// The web's rule: an `image` attachment, or a URL that looks like one.
  bool get hasImage {
    final url = attachmentUrl;
    return url != null && (attachmentType == 'image' || _imageUrl.hasMatch(url));
  }

  /// Any other attachment — shown by its type, as the web does.
  bool get hasFile => attachmentUrl != null && attachmentType != null && !hasImage;

  bool get hasText => (text ?? '').trim().isNotEmpty;

  ConversationMessage withId(String newId) => ConversationMessage(
        id: newId,
        text: text,
        timestamp: timestamp,
        isFromPage: isFromPage,
        attachmentType: attachmentType,
        attachmentUrl: attachmentUrl,
      );

  factory ConversationMessage.fromJson(Map<String, dynamic> json) => ConversationMessage(
        id: Json.str(json['id']),
        text: Json.strOrNull(json['text']),
        timestamp: Json.dateOrNull(json['timestamp']),
        isFromPage: Json.boolOf(json['isFromPage']),
        attachmentType: Json.strOrNull(json['attachmentType']),
        attachmentUrl: Json.strOrNull(json['attachmentUrl']),
      );
}

/// The chat-screen payload: a compact header and the messages, oldest first.
///
/// Per the live docs the route returns **at most 200 messages and no
/// pagination** — the 200 oldest. A very long thread is cut off at the recent
/// end; that is a backend limit, not something the screen can fix.
class ConversationThread {
  const ConversationThread({required this.conversation, this.messages = const []});

  final Conversation conversation;
  final List<ConversationMessage> messages;

  factory ConversationThread.fromJson(Map<String, dynamic> json) {
    final header = json['conversation'];
    final rows = json['messages'];
    return ConversationThread(
      conversation: Conversation.fromJson(header is Map<String, dynamic> ? header : const {}),
      messages: rows is List
          ? rows.whereType<Map<String, dynamic>>().map(ConversationMessage.fromJson).toList(growable: false)
          : const [],
    );
  }
}

/// `POST /api/pages/{pageId}/sync` — how many rows the pull from Meta stored.
class InboxSyncResult {
  const InboxSyncResult({this.newConversations = 0, this.newMessages = 0});

  final int newConversations;
  final int newMessages;

  bool get foundAnything => newConversations + newMessages > 0;

  factory InboxSyncResult.fromJson(Map<String, dynamic> json) => InboxSyncResult(
        newConversations: Json.intOf(json['newConversations']),
        newMessages: Json.intOf(json['newMessages']),
      );
}
