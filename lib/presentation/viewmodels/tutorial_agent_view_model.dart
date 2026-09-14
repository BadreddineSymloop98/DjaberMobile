import '../../core/error/app_exception.dart';
import '../../core/utils/validators.dart';
import '../../data/models/agent.dart';
import '../../data/repositories/agent_repository.dart';
import 'form_field_model.dart';

/// The form on `T4 — Agent IA`, and the call that creates the agent.
///
/// Three inputs, as the frame promises — *"Trois champs suffisent — tout
/// s'ajuste plus tard"*: a name, one of four personalities, and free-text
/// instructions. Everything else the `Agent` model carries has a server
/// default and is deliberately left alone.
class TutorialAgentViewModel extends FormViewModel {
  TutorialAgentViewModel({required AgentRepository agents}) : _agents = agents {
    attachFields();
  }

  final AgentRepository _agents;

  final name = FormFieldModel(validator: Validators.name);

  /// Optional on the server, and optional here — an agent with no extra
  /// instructions still works.
  final instructions = FormFieldModel(validator: Validators.optional);

  @override
  List<FormFieldModel> get fields => [name, instructions];

  /// Professional is the backend's own default and what the frame preselects.
  AgentPersonality _personality = AgentPersonality.fallback;
  AgentPersonality get personality => _personality;

  void selectPersonality(AgentPersonality value) {
    if (_personality == value) return;
    _personality = value;
    safeNotify();
  }

  /// What has been chosen and typed but not sent, for
  /// `TutorialViewModel.saveDraft` to hold while this step's screen is gone.
  Map<String, String> get draft => {
        'name': name.value,
        'instructions': instructions.value,
        'personality': _personality.wireName,
      };

  /// Puts back a [draft]. Anything it does not carry is left as it is.
  void restore(Map<String, String> draft) {
    final savedName = draft['name'];
    if (savedName != null) name.controller.text = savedName;
    final savedInstructions = draft['instructions'];
    if (savedInstructions != null) {
      instructions.controller.text = savedInstructions;
    }
    final savedPersonality = draft['personality'];
    if (savedPersonality != null) {
      _personality = AgentPersonality.fromName(savedPersonality);
    }
  }

  Agent? _created;
  Agent? get created => _created;

  AppException? _submitError;
  AppException? get submitError => _submitError;

  /// True when the server refused because the account already has an agent.
  ///
  /// **This is the wall.** One agent per user is enforced, and `T4` only
  /// advanced on a successful create — so a merchant who force-quit after this
  /// step came back to a 403 they could never pass, with no `Passer` on the
  /// steps, no sign-out inside the tutorial, and `T5`'s *Connecter plus tard*
  /// unreachable behind it. Clearing app data or signing up again were the
  /// only exits.
  ///
  /// `PLAN_LIMIT_REACHED` does not mean "you failed", it means "you already
  /// have one" — which is the step's goal. So it advances.
  bool _alreadyExists = false;
  bool get alreadyExists => _alreadyExists;

  /// Validates, then creates. Returns the agent on success, null otherwise.
  ///
  /// The failure worth knowing about: a merchant who already has an agent gets
  /// `400 Agent limit reached`, because the backend allows exactly one. That
  /// surfaces as the server's own message rather than a generic error.
  Future<Agent?> submitAndCreate() async {
    _submitError = null;
    _alreadyExists = false;
    if (!submit()) return null;

    final agent = await run(
      () => _agents.create(
        name: name.value,
        personality: _personality,
        customInstructions: instructions.value,
      ),
      onError: (error) {
        if (error.code == 'PLAN_LIMIT_REACHED' ||
            error.code == 'AGENT_LIMIT_REACHED') {
          _alreadyExists = true;
          return;
        }
        _submitError = error;
      },
      tag: 'createAgent',
    );

    if (agent != null) _created = agent;
    return agent;
  }
}
