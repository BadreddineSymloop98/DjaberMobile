import 'agent.dart';

/// Everything `POST /api/user-stock/agents` accepts, as the web's full agent
/// form sends it (`src/app/dashboard/agents/_components/AgentForm.tsx`).
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
  final List<String> pageIds;
  final List<String> productIds;

  /// The request body. Blank text fields are left out, as the web sends
  /// `undefined` for them; `productIds` is empty while selling everything,
  /// since the backend ignores it then anyway.
  Map<String, Object> toJson() {
    String? text(String value) => value.trim().isEmpty ? null : value.trim();
    return {
      'name': name.trim(),
      'description': ?text(description),
      'personality': personality.wireName,
      'customInstructions': ?text(customInstructions),
      'productTemplate': ?text(productTemplate),
      'closingInstructions': ?text(closingInstructions),
      'humanHandoffRules': ?text(humanHandoffRules),
      'imageRecognition': imageRecognition,
      'voiceTranscription': voiceTranscription,
      'responseDelay': responseDelay,
      'aiModel': aiModel,
      'temperature': temperature,
      'maxTokens': maxTokens.clamp(minTokens, maxTokensLimit),
      'sellAllProducts': sellAllProducts,
      'isActive': true,
      'pageIds': pageIds,
      'productIds': sellAllProducts ? const <String>[] : productIds,
    };
  }
}
