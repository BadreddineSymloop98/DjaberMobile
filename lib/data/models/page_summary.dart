import '../../core/utils/json.dart';
import 'agent.dart';

/// One page's dashboard card in a single round trip —
/// `GET /api/pages/{id}/summary`, what the web's `PageDashboardCard` reads.
///
/// Per the live docs: `unread` is the ACTIVE conversations whose last message
/// is the customer's (awaiting a reply), and `products` counts the merchant's
/// whole active catalogue, not this page's.
class PageSummary {
  const PageSummary({
    this.pictureUrl,
    this.conversations = 0,
    this.activeConversations = 0,
    this.unread = 0,
    this.messages7d = 0,
    this.incoming7d = 0,
    this.products = 0,
    this.agent = const PageAgentStatus(),
    this.lastActivity,
  });

  /// The stored avatar, or Facebook's public picture URL; null for an
  /// Instagram account without a stored avatar.
  final String? pictureUrl;
  final int conversations;
  final int activeConversations;
  final int unread;
  final int messages7d;
  final int incoming7d;
  final int products;
  final PageAgentStatus agent;

  /// The newest message on the page, either direction.
  final DateTime? lastActivity;

  factory PageSummary.fromJson(Map<String, dynamic> json) {
    final conversations = Json.map(json['conversations']);
    final messages = Json.map(json['messages']);
    return PageSummary(
      pictureUrl: Json.strOrNull(json['pictureUrl']),
      conversations: Json.intOf(conversations['total']),
      activeConversations: Json.intOf(conversations['active']),
      unread: Json.intOf(conversations['unread']),
      messages7d: Json.intOf(messages['last7d']),
      incoming7d: Json.intOf(messages['incoming7d']),
      products: Json.intOf(json['products']),
      agent: PageAgentStatus.fromJson(Json.map(json['agent'])),
      lastActivity: Json.dateOrNull(json['lastActivity']),
    );
  }
}

/// Who answers on a page: the linked Agent, or — with none linked — the
/// legacy per-page AI settings, which have no id or name.
class PageAgentStatus {
  const PageAgentStatus({
    this.id,
    this.name,
    this.enabled = false,
    this.personality,
    this.hasInstructions = false,
  });

  final String? id;
  final String? name;
  final bool enabled;
  final AgentPersonality? personality;
  final bool hasInstructions;

  /// The web's test for "Agent IA prêt".
  bool get isReady => enabled && hasInstructions;

  factory PageAgentStatus.fromJson(Map<String, dynamic> json) {
    final personality = Json.strOrNull(json['personality']);
    return PageAgentStatus(
      id: Json.strOrNull(json['id']),
      name: Json.strOrNull(json['name']),
      enabled: Json.boolOf(json['enabled']),
      personality: personality == null ? null : AgentPersonality.fromName(personality),
      hasInstructions: Json.boolOf(json['hasInstructions']),
    );
  }
}

/// An agent drafted from a page's inbox — `POST /api/pages/{id}/generate-agent`.
/// A preview only: nothing is saved until [applyBody] is posted to
/// `apply-agent`.
class GeneratedAgentDraft {
  const GeneratedAgentDraft({
    required this.personality,
    required this.responseTone,
    required this.responseLength,
    required this.customInstructions,
    required this.businessSummary,
    this.languages = const [],
    this.topQuestions = const [],
    this.sampledMessages = 0,
    this.sampledConversations = 0,
    this.warning,
  });

  /// `professional | friendly | casual | technical`.
  final String personality;

  /// `balanced | formal | casual | enthusiastic`.
  final String responseTone;

  /// `short | medium | detailed`.
  final String responseLength;
  final String customInstructions;
  final String businessSummary;
  final List<String> languages;
  final List<String> topQuestions;
  final int sampledMessages;
  final int sampledConversations;

  /// The backend always answers 200 with a usable draft; this says when it is
  /// only the default one (no key, too few messages, model failure). English.
  final String? warning;

  factory GeneratedAgentDraft.fromJson(Map<String, dynamic> json) {
    List<String> strings(Object? value) => [
          if (value is List)
            for (final item in value)
              if (item is String && item.trim().isNotEmpty) item,
        ];
    final warning = Json.strOrNull(json['warning']);
    return GeneratedAgentDraft(
      personality: Json.str(json['personality'], 'friendly'),
      responseTone: Json.str(json['responseTone'], 'balanced'),
      responseLength: Json.str(json['responseLength'], 'medium'),
      customInstructions: Json.str(json['customInstructions']),
      businessSummary: Json.str(json['businessSummary']),
      languages: strings(json['languages']),
      topQuestions: strings(json['topQuestions']),
      sampledMessages: Json.intOf(json['sampledMessages']),
      sampledConversations: Json.intOf(json['sampledConversations']),
      warning: warning == null || warning.trim().isEmpty ? null : warning,
    );
  }

  /// What the web's modal sends to `apply-agent`, with the merchant's edited
  /// [instructions].
  Map<String, Object> applyBody(String instructions) => {
        'personality': personality,
        'responseTone': responseTone,
        'responseLength': responseLength,
        'customInstructions': instructions,
        'businessSummary': businessSummary,
      };
}
