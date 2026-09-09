import '../../core/utils/json.dart';

/// How the agent talks to customers.
///
/// The four the backend accepts, from `Agent.personality` in
/// `schema.prisma` — its default is `professional`, which is what the frame
/// shows preselected.
enum AgentPersonality {
  professional('professional'),
  friendly('friendly'),
  casual('casual'),
  technical('technical');

  const AgentPersonality(this.wireName);

  final String wireName;

  static const fallback = AgentPersonality.professional;

  static AgentPersonality fromName(String? value) => values.firstWhere(
        (p) => p.wireName == value,
        orElse: () => fallback,
      );
}

/// The merchant's AI agent.
///
/// **One per user, enforced server-side.** `user-agents.controller.ts:104`
/// counts existing agents and answers `400 { error: 'Agent limit reached' }`
/// on the second. That is why `14 — Agents IA` — which draws two cards and a
/// "Nouvel agent" button — is wrong, and why the tutorial creates exactly one.
///
/// Only the fields the app sets or shows are modelled. The backend carries a
/// dozen more (`aiModel`, `temperature`, `maxTokens`, `productTemplate`,
/// `closingInstructions`, `humanHandoffRules`, `imageRecognition`,
/// `voiceTranscription`, `responseDelay`) which all have server defaults — the
/// tutorial deliberately sets none of them, per the frame's "trois champs
/// suffisent — tout s'ajuste plus tard".
class Agent {
  const Agent({
    required this.id,
    required this.name,
    this.description,
    this.personality = AgentPersonality.professional,
    this.customInstructions,
    this.sellAllProducts = true,
    this.isActive = true,
    this.pageIds = const [],
    this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final AgentPersonality personality;

  /// The merchant's own words on how it should behave — `Instructions` on the
  /// frame, `customInstructions` on the wire.
  final String? customInstructions;

  /// True means the agent knows the whole catalogue rather than a chosen
  /// subset. Server default, and what the tutorial wants.
  final bool sellAllProducts;

  final bool isActive;

  /// The connected Pages this agent answers on, through the `AgentPage` join.
  final List<String> pageIds;

  final DateTime? createdAt;

  factory Agent.fromJson(Map<String, dynamic> json) {
    // `pages` comes back as the join rows, each carrying a `pageId` and often
    // the nested page itself.
    final pages = json['pages'];
    final ids = <String>[];
    if (pages is List) {
      for (final row in pages) {
        if (row is Map<String, dynamic>) {
          final id = Json.strOrNull(row['pageId']) ??
              Json.strOrNull((row['page'] as Map<String, dynamic>?)?['id']);
          if (id != null) ids.add(id);
        }
      }
    }

    return Agent(
      id: Json.str(json['id']),
      name: Json.str(json['name']),
      description: Json.strOrNull(json['description']),
      personality: AgentPersonality.fromName(Json.strOrNull(json['personality'])),
      customInstructions: Json.strOrNull(json['customInstructions']),
      sellAllProducts: Json.boolOf(json['sellAllProducts'], true),
      isActive: Json.boolOf(json['isActive'], true),
      pageIds: ids,
      createdAt: Json.dateOrNull(json['createdAt']),
    );
  }
}
