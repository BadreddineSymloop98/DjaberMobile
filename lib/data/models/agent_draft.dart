import '../../core/utils/json.dart';
import 'agent.dart';

/// Everything `POST /api/user-stock/agents` accepts, as the web's full agent
/// form sends it (`src/app/dashboard/agents/_components/AgentForm.tsx`) — and,
/// read back with [AgentDraft.fromJson], an existing agent as `15c — Modifier
/// l'agent` edits it.
///
/// The defaults are the web form's own starting values — `gpt-4o-mini`,
/// temperature 0.7, 1024 tokens, a 3-second delay, vision and voice off, the
/// whole catalogue — not the backend's, which differ (`gpt-4`, 1000 tokens):
/// a merchant creating the same agent on either client gets the same agent.
class AgentDraft {
  const AgentDraft({
    required this.name,
    this.description = '',
    this.personality = AgentPersonality.professional,
    this.customInstructions = '',
    this.closingInstructions = '',
    this.humanHandoffRules = '',
    this.productTemplate = '',
    this.aiModel = defaultModel,
    this.temperature = 0.7,
    this.maxTokens = 1024,
    this.imageRecognition = false,
    this.voiceTranscription = false,
    this.responseDelay = 3,
    this.sellAllProducts = true,
    this.isActive = true,
    this.pageIds = const [],
    this.productIds = const [],
  });

  static const defaultModel = 'gpt-4o-mini';

  /// The web's `max` bounds on the Max Tokens input.
  static const minTokens = 100;
  static const maxTokensLimit = 4096;

  /// The web's Response Delay slider runs 0–10 seconds.
  static const maxDelay = 10;

  final String name;
  final String description;
  final AgentPersonality personality;
  final String customInstructions;
  final String closingInstructions;
  final String humanHandoffRules;
  final String productTemplate;
  final String aiModel;
  final double temperature;
  final int maxTokens;
  final bool imageRecognition;
  final bool voiceTranscription;
  final int responseDelay;
  final bool sellAllProducts;

  /// Only the edit form shows it — the web's "Active" toggle. A new agent is
  /// always created active.
  final bool isActive;
  final List<String> pageIds;
  final List<String> productIds;

  /// The agent as `GET /agents/{id}` returns it. Blank text is `null` on the
  /// wire and `''` here; page and product links arrive as join rows carrying
  /// `pageId` / `productId` (live docs example).
  factory AgentDraft.fromJson(Map<String, dynamic> json) {
    List<String> linked(Object? rows, String key, String nested) => [
          if (rows is List)
            for (final row in rows)
              if (row is Map<String, dynamic>)
                ?(Json.strOrNull(row[key]) ?? Json.strOrNull(Json.mapOrNull(row[nested])?['id'])),
        ];

    return AgentDraft(
      name: Json.str(json['name']),
      description: Json.str(json['description']),
      personality: AgentPersonality.fromName(Json.strOrNull(json['personality'])),
      customInstructions: Json.str(json['customInstructions']),
      closingInstructions: Json.str(json['closingInstructions']),
      humanHandoffRules: Json.str(json['humanHandoffRules']),
      productTemplate: Json.str(json['productTemplate']),
      aiModel: Json.strOrNull(json['aiModel']) ?? defaultModel,
      temperature: Json.dbl(json['temperature'], 0.7),
      maxTokens: Json.intOf(json['maxTokens'], 1024),
      imageRecognition: Json.boolOf(json['imageRecognition']),
      voiceTranscription: Json.boolOf(json['voiceTranscription']),
      responseDelay: Json.intOf(json['responseDelay'], 3),
      sellAllProducts: Json.boolOf(json['sellAllProducts'], true),
      isActive: Json.boolOf(json['isActive'], true),
      pageIds: linked(json['pages'], 'pageId', 'page'),
      productIds: linked(json['products'], 'productId', 'product'),
    );
  }

  /// The request body. For a create, blank text fields are left out, as the
  /// web sends `undefined` for them. With [clearBlanks] they are sent as
  /// `null` instead — on an update that is what clears a field (live docs).
  /// `productIds` is empty while selling everything, since the backend ignores
  /// it then anyway.
  Map<String, Object?> toJson({bool clearBlanks = false}) {
    String? text(String value) => value.trim().isEmpty ? null : value.trim();
    final texts = <String, String?>{
      'description': text(description),
      'customInstructions': text(customInstructions),
      'productTemplate': text(productTemplate),
      'closingInstructions': text(closingInstructions),
      'humanHandoffRules': text(humanHandoffRules),
    };
    return {
      'name': name.trim(),
      for (final entry in texts.entries)
        if (clearBlanks || entry.value != null) entry.key: entry.value,
      'personality': personality.wireName,
      'imageRecognition': imageRecognition,
      'voiceTranscription': voiceTranscription,
      'responseDelay': responseDelay,
      'aiModel': aiModel,
      'temperature': temperature,
      'maxTokens': maxTokens.clamp(minTokens, maxTokensLimit),
      'sellAllProducts': sellAllProducts,
      'isActive': isActive,
      'pageIds': pageIds,
      'productIds': sellAllProducts ? const <String>[] : productIds,
    };
  }

  /// What a partial `PUT /agents/{id}` must carry to turn [before] into this
  /// draft — only the keys that differ, lists compared as sets.
  ///
  /// **Why only those.** The update leaves absent keys untouched (live docs),
  /// so a setting changed on the web while the phone's form was open survives
  /// the phone's save — unless the merchant changed that same setting too.
  Map<String, Object?> changesFrom(AgentDraft before) {
    final now = toJson(clearBlanks: true);
    final was = before.toJson(clearBlanks: true);
    bool same(Object? a, Object? b) {
      if (a is List && b is List) {
        final left = a.toSet();
        final right = b.toSet();
        return left.length == right.length && left.containsAll(right);
      }
      return a == b;
    }

    return {
      for (final entry in now.entries)
        if (!same(entry.value, was[entry.key])) entry.key: entry.value,
    };
  }

  /// This draft with other custom instructions — what the server holds after
  /// the web appended to them.
  AgentDraft withCustomInstructions(String value) => AgentDraft(
        name: name,
        description: description,
        personality: personality,
        customInstructions: value,
        closingInstructions: closingInstructions,
        humanHandoffRules: humanHandoffRules,
        productTemplate: productTemplate,
        aiModel: aiModel,
        temperature: temperature,
        maxTokens: maxTokens,
        imageRecognition: imageRecognition,
        voiceTranscription: voiceTranscription,
        responseDelay: responseDelay,
        sellAllProducts: sellAllProducts,
        isActive: isActive,
        pageIds: pageIds,
        productIds: productIds,
      );
}
