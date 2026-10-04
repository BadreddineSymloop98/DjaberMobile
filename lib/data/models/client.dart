import '../../core/utils/json.dart';

/// Where a client record came from — the backend's `source`.
///
/// `ai` when the agent created it from a conversation, `manual` when the
/// merchant typed it. Stored as sent and not validated server-side, so any
/// other value reads as [manual] rather than failing.
enum ClientSource {
  ai,
  manual;

  static ClientSource parse(String? value) => value == 'ai' ? ai : manual;
}

/// A customer — `Client` in the schema.
///
/// `GET /api/user-stock/clients` → `{ clients }`, `GET …/clients/{id}` →
/// `{ client }`. The order figures (`totalOrders`, `totalSpent`,
/// `lastOrderDate`) are **maintained by the orders endpoints**, not by this
/// record's own routes: the form cannot set them. `totalSpent` is a Decimal and
/// arrives as a string.
class Client {
  const Client({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.source = ClientSource.manual,
    this.isActive = true,
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.lastOrderDate,
    this.conversationCount,
    this.createdAt,
  });

  final String id;
  final String name;

  /// Unique per merchant — a duplicate is a 400 on create and on update.
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final ClientSource source;
  final bool isActive;
  final int totalOrders;
  final double totalSpent;
  final DateTime? lastOrderDate;

  /// `_count.conversations`, when the response embeds it. The update response
  /// does not.
  final int? conversationCount;

  final DateTime? createdAt;

  /// Up to two initials for the avatar square — "Amina Belkacem" → `AB`.
  String get initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    final first = String.fromCharCode(words.first.runes.first);
    if (words.length == 1) return first.toUpperCase();
    return (first + String.fromCharCode(words.last.runes.first)).toUpperCase();
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    final count = Json.mapOrNull(json['_count']);
    return Client(
      id: Json.str(json['id']),
      name: Json.str(json['name']),
      phone: _blankToNull(Json.strOrNull(json['phone'])),
      email: _blankToNull(Json.strOrNull(json['email'])),
      address: _blankToNull(Json.strOrNull(json['address'])),
      notes: _blankToNull(Json.strOrNull(json['notes'])),
      source: ClientSource.parse(Json.strOrNull(json['source'])),
      isActive: Json.boolOf(json['isActive'], true),
      totalOrders: Json.intOf(json['totalOrders']),
      totalSpent: Json.dbl(json['totalSpent']),
      lastOrderDate: Json.dateOrNull(json['lastOrderDate']),
      conversationCount: count == null ? null : Json.intOrNull(count['conversations']),
      createdAt: Json.dateOrNull(json['createdAt']),
    );
  }

  static String? _blankToNull(String? value) =>
      value == null || value.trim().isEmpty ? null : value;
}

/// The AI-conversation figures for one client — `GET …/clients/{id}/metrics`.
///
/// Computed over every conversation linked to the client. No order figures
/// here: those are on [Client].
class ClientMetrics {
  const ClientMetrics({
    this.conversationCount = 0,
    this.totalMessages = 0,
    this.aiResponseCount = 0,
    this.messagesReceived = 0,
    this.lastMessageDate,
    this.conversations = const [],
  });

  final int conversationCount;
  final int totalMessages;

  /// Messages sent by the page or the AI. The backend's `messagesSent` is the
  /// same number; the web labels it *AI Responses*.
  final int aiResponseCount;

  /// Messages written by the customer.
  final int messagesReceived;
  final DateTime? lastMessageDate;

  /// Newest first.
  final List<ClientConversation> conversations;

  factory ClientMetrics.fromJson(Map<String, dynamic> json) {
    final metrics = Json.mapOrNull(json['metrics']) ?? const <String, dynamic>{};
    return ClientMetrics(
      conversationCount: Json.intOf(metrics['conversationCount']),
      totalMessages: Json.intOf(metrics['totalMessages']),
      aiResponseCount: Json.intOf(metrics['aiResponseCount']),
      messagesReceived: Json.intOf(metrics['messagesReceived']),
      lastMessageDate: Json.dateOrNull(metrics['lastMessageDate']),
      conversations: Json.list(json['conversations'], ClientConversation.fromJson),
    );
  }
}

/// One conversation in a client's history.
class ClientConversation {
  const ClientConversation({
    required this.id,
    required this.platform,
    this.pageName,
    required this.status,
    this.messageCount = 0,
    this.lastMessage,
    this.lastMessageIsFromPage = false,
  });

  final String id;

  /// `facebook` or `instagram`, as the server sends it.
  final String platform;
  final String? pageName;

  /// `active`, `resolved` or `archived` — shown raw, as the web does.
  final String status;
  final int messageCount;

  /// Truncated to 100 characters by the server.
  final String? lastMessage;
  final bool lastMessageIsFromPage;

  factory ClientConversation.fromJson(Map<String, dynamic> json) => ClientConversation(
        id: Json.str(json['id']),
        platform: Json.str(json['platform']),
        pageName: Json.strOrNull(json['pageName']),
        status: Json.str(json['status']),
        messageCount: Json.intOf(json['messageCount']),
        lastMessage: Json.strOrNull(json['lastMessage']),
        lastMessageIsFromPage: Json.boolOf(json['lastMessageIsFromPage']),
      );
}
