import '../../core/utils/json.dart';

/// An LLM provider the administrator has switched on, with the model ids it
/// exposes — `GET /api/user-stock/ai-providers/active`, which the live docs
/// name as the source of the agent form's model picker.
class AiProvider {
  const AiProvider({
    required this.provider,
    required this.displayName,
    required this.models,
  });

  /// `openai`, `anthropic`, `google`, `groq`.
  final String provider;
  final String displayName;
  final List<String> models;

  factory AiProvider.fromJson(Map<String, dynamic> json) => AiProvider(
        provider: Json.str(json['provider']),
        displayName: Json.str(json['displayName']),
        models: [
          for (final model in (json['models'] as List? ?? const []))
            if (model is String) model,
        ],
      );
}

/// What a model is good at, in a word — the web's `modelLabels[id].desc`,
/// kept as a key so each language words it itself.
enum AiModelTrait {
  bestQuality,
  fastAffordable,
  longContext128k,
  legacyFast,
  bestBalanced,
  fastCheap,
  mostCapable,
  latestFast,
  longContext1m,
  bestOpenSource,
  ultraFast,
  mixtureOfExperts,
  reasoning,
}

/// The friendly names and cost estimates the web shows beside each model.
///
/// Labels and traits are `modelLabels` in the web's `AgentForm.tsx`; prices are
/// `MODEL_PRICING` in `src/lib/model-pricing.ts` (USD per 1M tokens, Jan 2026),
/// with its per-message baseline of 1060 input and 200 output tokens. An id
/// neither table knows is shown as-is, with no trait and no cost — as on web.
class AiModelInfo {
  const AiModelInfo._();

  static const _labels = <String, (String, AiModelTrait)>{
    'gpt-4o': ('GPT-4o', AiModelTrait.bestQuality),
    'gpt-4o-mini': ('GPT-4o Mini', AiModelTrait.fastAffordable),
    'gpt-4-turbo': ('GPT-4 Turbo', AiModelTrait.longContext128k),
    'gpt-3.5-turbo': ('GPT-3.5 Turbo', AiModelTrait.legacyFast),
    'claude-3-5-sonnet-20241022': ('Claude 3.5 Sonnet', AiModelTrait.bestBalanced),
    'claude-3-5-haiku-20241022': ('Claude 3.5 Haiku', AiModelTrait.fastCheap),
    'claude-3-opus-20240229': ('Claude 3 Opus', AiModelTrait.mostCapable),
    'gemini-2.0-flash': ('Gemini 2.0 Flash', AiModelTrait.latestFast),
    'gemini-1.5-pro': ('Gemini 1.5 Pro', AiModelTrait.longContext1m),
    'gemini-1.5-flash': ('Gemini 1.5 Flash', AiModelTrait.fastAffordable),
    'llama-3.3-70b-versatile': ('Llama 3.3 70B', AiModelTrait.bestOpenSource),
    'llama-3.1-8b-instant': ('Llama 3.1 8B', AiModelTrait.ultraFast),
    'mixtral-8x7b-32768': ('Mixtral 8x7B', AiModelTrait.mixtureOfExperts),
    'deepseek-r1-distill-llama-70b': ('DeepSeek R1 70B', AiModelTrait.reasoning),
  };

  static const _pricing = <String, (double, double)>{
    'gpt-4o': (2.5, 10),
    'gpt-4o-mini': (0.15, 0.6),
    'gpt-4-turbo': (10, 30),
    'gpt-3.5-turbo': (0.5, 1.5),
    'o1': (15, 60),
    'o1-mini': (3, 12),
    'claude-3-5-sonnet-20241022': (3, 15),
    'claude-3-5-haiku-20241022': (0.8, 4),
    'claude-3-opus-20240229': (15, 75),
    'gemini-2.0-flash': (0.1, 0.4),
    'gemini-1.5-pro': (1.25, 5),
    'gemini-1.5-flash': (0.075, 0.3),
    'llama-3.3-70b-versatile': (0.59, 0.79),
    'llama-3.1-8b-instant': (0.05, 0.08),
    'mixtral-8x7b-32768': (0.24, 0.24),
  };

  static String label(String model) => _labels[model]?.$1 ?? model;

  static AiModelTrait? trait(String model) => _labels[model]?.$2;

  /// The USD figure for 1000 answered messages, rounded the way the web's
  /// `costPer1000Label` rounds it — `0.28`, `4.7`, `63`. Null when unpriced.
  static String? costPer1000(String model) {
    final price = _pricing[model];
    if (price == null) return null;
    final usd = (1060 / 1e6 * price.$1 + 200 / 1e6 * price.$2) * 1000;
    if (usd < 1) return usd.toStringAsFixed(2);
    if (usd < 10) return usd.toStringAsFixed(1);
    return usd.round().toString();
  }
}
