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

  Agent? _created;
  Agent? get created => _created;

  AppException? _submitError;
  AppException? get submitError => _submitError;

  /// Validates, then creates. Returns the agent on success, null otherwise.
  ///
  /// The failure worth knowing about: a merchant who already has an agent gets
  /// `400 Agent limit reached`, because the backend allows exactly one. That
  /// surfaces as the server's own message rather than a generic error.
  Future<Agent?> submitAndCreate() async {
    _submitError = null;
    if (!submit()) return null;

    final agent = await run(
      () => _agents.create(
        name: name.value,
        personality: _personality,
        customInstructions: instructions.value,
      ),
      onError: (error) => _submitError = error,
      tag: 'createAgent',
    );

    if (agent != null) _created = agent;
    return agent;
  }
}
