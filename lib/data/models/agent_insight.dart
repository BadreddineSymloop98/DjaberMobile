import '../../core/utils/json.dart';

/// Where an insight stands, as `AgentInsight.status` says it.
enum InsightStatus {
  pending('pending'),
  resolved('resolved'),
  dismissed('dismissed');

  const InsightStatus(this.wireName);

  final String wireName;

  static InsightStatus fromName(String? value) => values.firstWhere(
        (s) => s.wireName == value,
        orElse: () => pending,
      );
}

/// Why the agent flagged its own reply — the status tag the messenger webhook
/// reads off it (`GET /agents/{id}/insights` in the live docs).
enum InsightType {
  unclear('unclear'),
  unknownTopic('unknown_topic'),
  handoff('handoff');

  const InsightType(this.wireName);

  final String wireName;

  static InsightType fromName(String? value) => values.firstWhere(
        (t) => t.wireName == value,
        orElse: () => unclear,
      );
}

/// A conversation the agent was not sure about, waiting for the merchant.
///
/// Resolving one can teach the agent: the instruction given with it is
/// appended to the agent's custom instructions server-side.
class AgentInsight {
  const AgentInsight({
    required this.id,
    required this.type,
    required this.customerMessage,
    required this.aiResponse,
    this.detail,
    this.status = InsightStatus.pending,
    this.platform,
    this.createdAt,
    this.resolvedAt,
  });

  final String id;
  final InsightType type;

  /// The customer's batched text, or `[image/attachment]`.
  final String customerMessage;

  /// The reply the agent actually sent.
  final String aiResponse;

  /// The reason or topic the agent gave, when it gave one.
  final String? detail;

  final InsightStatus status;

  /// `facebook` or `instagram`, from the embedded conversation.
  final String? platform;

  final DateTime? createdAt;
  final DateTime? resolvedAt;

  bool get isPending => status == InsightStatus.pending;

  factory AgentInsight.fromJson(Map<String, dynamic> json) {
    final conversation = json['conversation'];
    return AgentInsight(
      id: Json.str(json['id']),
      type: InsightType.fromName(Json.strOrNull(json['type'])),
      customerMessage: Json.str(json['customerMessage']),
      aiResponse: Json.str(json['aiResponse']),
      detail: Json.strOrNull(json['detail']),
      status: InsightStatus.fromName(Json.strOrNull(json['status'])),
      platform: conversation is Map<String, dynamic>
          ? Json.strOrNull(conversation['platform'])
          : null,
      createdAt: Json.dateOrNull(json['createdAt']),
      resolvedAt: Json.dateOrNull(json['resolvedAt']),
    );
  }
}

/// The agent's live KPIs — `GET /agents/{id}/metrics`.
class AgentMetrics {
  const AgentMetrics({
    this.conversationCount = 0,
    this.totalMessages = 0,
    this.messagesFromCustomers = 0,
    this.messagesFromAgent = 0,
    this.ordersCreated = 0,
    this.insightsPending = 0,
    this.insightsResolved = 0,
    this.lastActiveDate,
  });

  final int conversationCount;
  final int totalMessages;
  final int messagesFromCustomers;
  final int messagesFromAgent;

  /// Orders with `source = "ai"` for clients this agent talked to.
  final int ordersCreated;

  final int insightsPending;

  /// Resolved **or** dismissed.
  final int insightsResolved;

  /// The most recent message in its conversations; null before any.
  final DateTime? lastActiveDate;

  factory AgentMetrics.fromJson(Map<String, dynamic> json) => AgentMetrics(
        conversationCount: Json.intOf(json['conversationCount']),
        totalMessages: Json.intOf(json['totalMessages']),
        messagesFromCustomers: Json.intOf(json['messagesFromCustomers']),
        messagesFromAgent: Json.intOf(json['messagesFromAgent']),
        ordersCreated: Json.intOf(json['ordersCreated']),
        insightsPending: Json.intOf(json['insightsPending']),
        insightsResolved: Json.intOf(json['insightsResolved']),
        lastActiveDate: Json.dateOrNull(json['lastActiveDate']),
      );
}

/// One line of a test chat. The sandbox keeps no history, so the app sends
/// the whole conversation with every message.
class ChatTurn {
  const ChatTurn.user(this.content) : fromAgent = false;
  const ChatTurn.agent(this.content) : fromAgent = true;

  final String content;
  final bool fromAgent;

  Map<String, String> toJson() => {
        'role': fromAgent ? 'assistant' : 'user',
        'content': content,
      };
}
