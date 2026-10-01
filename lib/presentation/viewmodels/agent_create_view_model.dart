import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../core/utils/validators.dart';
import '../../data/models/agent.dart';
import '../../data/models/agent_draft.dart';
import '../../data/models/agent_preset.dart';
import '../../data/models/ai_provider.dart';
import '../../data/models/connected_page.dart';
import '../../data/models/product.dart';
import '../../data/repositories/agent_repository.dart';
import '../../data/repositories/page_repository.dart';
import '../../data/repositories/product_repository.dart';
import 'agent_details_view_model.dart';
import 'base_view_model.dart';
import 'form_draft_store.dart';
import 'form_field_model.dart';

/// What creating an agent came to.
enum AgentCreateOutcome { created, limitReached, failed }

/// What saving an edited agent came to.
enum AgentSaveOutcome {
  saved,

  /// Saved, with instructions the web appended while the form was open kept
  /// after the merchant's own.
  savedWithWebChanges,

  /// Nothing differed from the agent as loaded, so nothing was sent.
  unchanged,

  /// Not saved: the instructions were rewritten elsewhere and the merchant
  /// changed them too. [NewAgentViewModel.instructionsConflict] holds the
  /// newer text.
  conflict,
  failed,
}

/// The part every way of creating an agent shares.
///
/// **No up-front limit.** How many agents a merchant may hold is their plan's
/// call and the backend enforces it, so a refusal comes back as
/// [AgentCreateOutcome.limitReached] with the backend's own, translated
/// sentence in `error` — the screen shows that rather than guessing a cap.
///
/// **The pages still free.** A page answers through one agent only: a create
/// whose `pageIds` include a page another agent holds is refused whole
/// (`400 One or more pages are already assigned to another agent`). So the
/// new agent takes every connected page no agent has yet — all of them for a
/// first agent, what is left (possibly none) for the next.
Future<({AgentCreateOutcome outcome, Agent? agent, AppException? error})> createAgentOnFreePages({
  required AgentRepository agents,
  required PageRepository pages,
  required String name,
  required AgentPersonality personality,
  String? customInstructions,
  AgentPreset? preset,
}) async {
  // Without the current agents there is no knowing which pages are free, and
  // guessing wrong fails the whole create.
  final existing = await agents.list();
  final current = existing.valueOrNull;
  if (current == null) {
    return (outcome: AgentCreateOutcome.failed, agent: null, error: existing.errorOrNull);
  }
  final taken = {
    for (final agent in current) ...[...agent.pageIds, ...agent.pages.map((p) => p.id)],
  };
  final pageIds = (await pages.list()).valueOrNull?.map((p) => p.id).where((id) => !taken.contains(id)).toList() ??
      const <String>[];

  final result = await agents.create(
    name: name,
    personality: personality,
    customInstructions: customInstructions,
    pageIds: pageIds,
    preset: preset,
  );
  final agent = result.valueOrNull;
  if (agent != null) return (outcome: AgentCreateOutcome.created, agent: agent, error: null);
  final error = result.errorOrNull;
  final limit = error?.code == 'PLAN_LIMIT_REACHED' || error?.code == 'AGENT_LIMIT_REACHED';
  return (outcome: limit ? AgentCreateOutcome.limitReached : AgentCreateOutcome.failed, agent: null, error: error);
}

/// `15 — Agents · démarrer`: creating from a ready-made agent in one tap.
class AgentPresetsViewModel extends BaseViewModel {
  AgentPresetsViewModel({required AgentRepository agents, required PageRepository pages})
      : _agents = agents,
        _pages = pages;

  final AgentRepository _agents;
  final PageRepository _pages;

  String? _creatingKey;

  /// The preset being created, so only its card shows a spinner.
  String? get creatingKey => _creatingKey;

  AppException? _createError;
  AppException? get createError => _createError;

  Future<AgentCreateOutcome> createFrom(AgentPreset preset) async {
    if (_creatingKey != null) return AgentCreateOutcome.failed;
    _creatingKey = preset.key;
    _createError = null;
    safeNotify();

    final result = await createAgentOnFreePages(
      agents: _agents,
      pages: _pages,
      name: preset.name,
      personality: preset.personality,
      customInstructions: preset.customInstructions,
      preset: preset,
    );
    if (isDisposed) return result.outcome;

    _creatingKey = null;
    _createError = result.error;
    safeNotify();
    return result.outcome;
  }
}

/// The parts of the agent form that fold away — every section of the web
/// form past name, description, personality and instructions.
enum AgentFormSection { behavior, display, model, pages, products }

/// The web's full agent form (`AgentForm.tsx`), arranged for a phone — the
/// essentials open, the rest folded, each fold carrying its current value so
/// nothing is hidden by being closed.
///
/// Two modes, as on the web, where one component serves both pages:
/// - **Create** (`15b — Partir de zéro`, [agentId] null). Pages are chosen,
///   not assumed: the form starts with every page no other agent holds
///   ticked, and shows a held page as held, since a create naming it is
///   refused whole.
/// - **Edit** (`15c — Modifier l'agent`, [agentId] set). The form opens on the
///   agent as saved, adds the *Active* switch, and a save sends **only what
///   changed** — see [submitAndSave].
class NewAgentViewModel extends FormViewModel {
  NewAgentViewModel({
    required AgentRepository agents,
    required PageRepository pages,
    required ProductRepository products,
    this.agentId,
    FormDraftStore? drafts,
  })  : _agents = agents,
        _pages = pages,
        _products = products {
    attachFields();
    // Every field feeds a fold summary, the preview or the unsaved-changes
    // check, so the screen redraws as the merchant types.
    for (final field in fields) {
      field.controller.addListener(safeNotify);
    }
    productQuery.addListener(safeNotify);

    // Leaving the app replays the splash, which rebuilds this screen from
    // nothing: without a draft, everything typed or chosen was lost — and in
    // edit mode the form came back as the server's agent. Text is put back
    // now; the choices, and in edit mode the text again, once the agent and
    // the lists have loaded, since loading would overwrite them (see
    // [_restoreDraft]).
    _saved = keepDraft(drafts, agentId == null ? 'agentForm:new' : 'agentForm:edit:$agentId', {
      'name': name,
      'description': description,
      'instructions': instructions,
      'closing': closing,
      'handoff': handoff,
      'template': template,
      'maxTokens': maxTokens,
    });
    // Choices are not text, so no keystroke writes them: every change
    // notifies, and every notification writes the draft.
    addListener(saveDraft);
  }

  /// What the draft store held when the form was built — empty unless the
  /// splash took the screen.
  Map<String, String> _saved = const {};

  @override
  Map<String, String> get draftExtras => {
        'kept': '1',
        'changed': _changedKeys,
        'personality': _personality.wireName,
        'aiModel': _aiModel,
        'temperature': '$_temperature',
        'imageRecognition': '$_imageRecognition',
        'voiceTranscription': '$_voiceTranscription',
        'responseDelay': '$_responseDelay',
        'sellAll': '$_sellAll',
        'isActive': '$_isActive',
        'pageIds': _selectedPageIds.join(','),
        'productIds': _selectedProductIds.join(','),
      };

  /// Edit mode: the settings the merchant has changed from the agent as
  /// loaded, by their wire names. Empty when creating.
  String get _changedKeys {
    final original = _original;
    return original == null ? '' : draft.changesFrom(original).keys.join(',');
  }

  /// Puts the draft back over what loading filled in. Runs once.
  ///
  /// **Editing puts back only what the merchant changed.** The draft holds
  /// every setting, but the agent may have changed on the web while the app
  /// was left; restoring the untouched ones too would quietly revert those
  /// changes on screen, and the next save would send the old values back.
  void _restoreDraft() {
    final saved = _saved;
    _saved = const {};
    if (saved['kept'] != '1') return;

    final changed = (saved['changed'] ?? '').split(',').toSet();
    bool keep(String wireName) => agentId == null || changed.contains(wireName);

    for (final (key, field, wireName) in [
      ('name', name, 'name'),
      ('description', description, 'description'),
      ('instructions', instructions, 'customInstructions'),
      ('closing', closing, 'closingInstructions'),
      ('handoff', handoff, 'humanHandoffRules'),
      ('template', template, 'productTemplate'),
      ('maxTokens', maxTokens, 'maxTokens'),
    ]) {
      final value = saved[key];
      if (value != null && keep(wireName)) field.controller.text = value;
    }
    List<String> ids(String? value) => [
          for (final id in (value ?? '').split(','))
            if (id.isNotEmpty) id,
        ];
    if (keep('personality')) _personality = AgentPersonality.fromName(saved['personality']);
    if (keep('aiModel')) _aiModel = saved['aiModel'] ?? _aiModel;
    if (keep('temperature')) _temperature = double.tryParse(saved['temperature'] ?? '') ?? _temperature;
    if (keep('imageRecognition')) _imageRecognition = saved['imageRecognition'] == 'true';
    if (keep('voiceTranscription')) _voiceTranscription = saved['voiceTranscription'] == 'true';
    if (keep('responseDelay')) {
      _responseDelay =
          (int.tryParse(saved['responseDelay'] ?? '') ?? _responseDelay).clamp(minDelay, AgentDraft.maxDelay);
    }
    if (keep('sellAllProducts')) _sellAll = saved['sellAll'] != 'false';
    if (keep('isActive')) _isActive = saved['isActive'] != 'false';
    if (keep('pageIds')) {
      _selectedPageIds
        ..clear()
        // A page another agent took meanwhile is not put back.
        ..addAll(ids(saved['pageIds']).where((id) => !_takenBy.containsKey(id)));
    }
    if (keep('productIds')) {
      _selectedProductIds
        ..clear()
        ..addAll(ids(saved['productIds']));
    }
  }

  static const _defaults = AgentDraft(name: '');

  final AgentRepository _agents;
  final PageRepository _pages;
  final ProductRepository _products;

  /// The agent being edited; null when creating one.
  final String? agentId;

  bool get isEditing => agentId != null;

  final name = FormFieldModel(validator: Validators.name);
  final description = FormFieldModel(validator: Validators.optional);
  final instructions = FormFieldModel(validator: Validators.optional);
  final closing = FormFieldModel(validator: Validators.optional);
  final handoff = FormFieldModel(validator: Validators.optional);
  final template = FormFieldModel(validator: Validators.optional);
  final maxTokens = FormFieldModel(
    validator: Validators.optional,
    initialValue: '${_defaults.maxTokens}',
  );

  /// The product list's search box — a filter on what is loaded, as on web,
  /// not something the form sends.
  final productQuery = TextEditingController();
  final productQueryFocus = FocusNode();

  @override
  List<FormFieldModel> get fields => [name, description, instructions, closing, handoff, template, maxTokens];

  // ---- Choices ----

  AgentPersonality _personality = AgentPersonality.fallback;
  AgentPersonality get personality => _personality;

  void selectPersonality(AgentPersonality value) {
    if (_personality == value) return;
    _personality = value;
    safeNotify();
  }

  String _aiModel = _defaults.aiModel;
  String get aiModel => _aiModel;

  void selectModel(String model) {
    _aiModel = model;
    safeNotify();
  }

  double _temperature = _defaults.temperature;
  double get temperature => _temperature;

  /// The web's slider steps by 0.1.
  void setTemperature(double value) {
    _temperature = (value * 10).round() / 10;
    safeNotify();
  }

  /// What is sent: the typed number, or the default when the field is blank.
  /// The draft clamps it to 100–4096, as the web's input does.
  int get tokens => int.tryParse(maxTokens.value.trim()) ?? _defaults.maxTokens;

  bool _imageRecognition = _defaults.imageRecognition;
  bool get imageRecognition => _imageRecognition;

  void setImageRecognition(bool value) {
    _imageRecognition = value;
    safeNotify();
  }

  bool _voiceTranscription = _defaults.voiceTranscription;
  bool get voiceTranscription => _voiceTranscription;

  void setVoiceTranscription(bool value) {
    _voiceTranscription = value;
    safeNotify();
  }

  int _responseDelay = _defaults.responseDelay;
  int get responseDelay => _responseDelay;

  /// **Starts at 1, not the web's 0.** Per the live docs the backend reads a
  /// `0` delay as "unset" and stores 3, so a slider that offered *Instant*
  /// would save something else.
  static const minDelay = 1;

  void setResponseDelay(int seconds) {
    _responseDelay = seconds.clamp(minDelay, AgentDraft.maxDelay);
    safeNotify();
  }

  bool _isActive = _defaults.isActive;

  /// Edit only — the web's *Active* toggle.
  bool get isActive => _isActive;

  void setActive(bool value) {
    _isActive = value;
    safeNotify();
  }

  /// Inserts a template tag where the cursor is, replacing any selection —
  /// the web's tag chips. At the end when the field has never had focus.
  void insertTag(String tag) {
    final controller = template.controller;
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    controller.value = TextEditingValue(
      text: text.replaceRange(start, end, tag),
      selection: TextSelection.collapsed(offset: start + tag.length),
    );
  }

  // ---- Folds ----

  final _expanded = <AgentFormSection>{};

  bool isExpanded(AgentFormSection section) => _expanded.contains(section);

  void toggleSection(AgentFormSection section) {
    if (!_expanded.remove(section)) _expanded.add(section);
    safeNotify();
  }

  // ---- What the form chooses from ----

  Future<void>? _loading;
  bool _loaded = false;

  /// True once pages, agents, products and models — and, when editing, the
  /// agent itself — have answered. The lists may each have failed on their
  /// own, leaving them empty; the agent may not (see [loadError]).
  bool get isLoaded => _loaded;

  AppException? _loadError;

  /// Edit only: the agent could not be read, so there is no form to show.
  AppException? get loadError => _loadError;

  /// The agent as loaded, or as last saved — what [hasChanges] compares with.
  AgentDraft? _original;

  List<AiProvider> _providers = const [];
  List<AiProvider> get providers => _providers;

  List<ConnectedPage> _pageRows = const [];
  List<ConnectedPage> get pages => _pageRows;

  /// Page id → the name of the agent already answering on it. Never the agent
  /// being edited: its own pages are its to keep or drop.
  Map<String, String> _takenBy = const {};
  String? takenBy(String pageId) => _takenBy[pageId];

  final _selectedPageIds = <String>{};
  bool isPageSelected(String pageId) => _selectedPageIds.contains(pageId);
  int get selectedPageCount => _selectedPageIds.length;

  List<Product> _productRows = const [];

  bool _sellAll = _defaults.sellAllProducts;
  bool get sellAllProducts => _sellAll;

  final _selectedProductIds = <String>{};
  bool isProductSelected(String productId) => _selectedProductIds.contains(productId);
  int get selectedProductCount => _selectedProductIds.length;

  /// Safe to call more than once; later calls wait on the first.
  Future<void> load() => _loading ??= _load();

  /// After [loadError]: tries again from scratch.
  Future<void> retryLoad() {
    _loading = null;
    return load();
  }

  Future<void> _load() async {
    final editing = agentId;
    _loadError = null;
    _loaded = false;
    safeNotify();

    final (agentList, pageList, productPage, providerList, saved) = await (
      _agents.list(),
      _pages.list(),
      // The web loads the first 200 and filters them in the browser.
      _products.list(limit: 200),
      _agents.activeProviders(),
      editing == null ? Future<Result<AgentDraft>?>.value() : _agents.getDraft(editing),
    ).wait;
    if (isDisposed) return;

    final original = saved?.valueOrNull;
    if (editing != null && original == null) {
      _loadError = saved?.errorOrNull;
      _loading = null;
      safeNotify();
      return;
    }

    final current = agentList.valueOrNull;
    _takenBy = {
      for (final agent in current ?? const <Agent>[])
        if (agent.id != editing)
          for (final id in {...agent.pageIds, ...agent.pages.map((p) => p.id)}) id: agent.name,
    };
    _pageRows = pageList.valueOrNull ?? const [];
    _productRows = productPage.valueOrNull?.products ?? const [];
    _providers = providerList.valueOrNull ?? const [];

    if (original != null) {
      _apply(original);
    } else {
      // Without the current agents there is no knowing which pages are free,
      // and naming a held one fails the whole create — so nothing is pre-ticked.
      if (current != null) {
        _selectedPageIds.addAll([for (final page in _pageRows) if (!_takenBy.containsKey(page.id)) page.id]);
      }
      // Keep the model one the administrator actually offers. Not when
      // editing: that would change a saved agent without being asked.
      final offered = [for (final provider in _providers) ...provider.models];
      if (offered.isNotEmpty && !offered.contains(_aiModel)) _aiModel = offered.first;
    }

    // Create mode's "untouched" form: the defaults, the pre-ticked pages and
    // the coerced model, taken once every list has answered (they arrive
    // together above), so an untouched form never counts as changed. Before
    // the draft restore, so restored typing does count. Taken once only: a
    // reload inside submit must not reset it to the merchant's own edits.
    if (editing == null) _createBaseline ??= draft;

    // After loading, which filled the form from the server or the defaults.
    _restoreDraft();

    _loaded = true;
    safeNotify();
  }

  /// Fills the form with a saved agent.
  void _apply(AgentDraft saved) {
    name.controller.text = saved.name;
    description.controller.text = saved.description;
    instructions.controller.text = saved.customInstructions;
    closing.controller.text = saved.closingInstructions;
    handoff.controller.text = saved.humanHandoffRules;
    template.controller.text = saved.productTemplate;
    maxTokens.controller.text = '${saved.maxTokens}';
    _personality = saved.personality;
    _aiModel = saved.aiModel;
    _temperature = saved.temperature;
    _imageRecognition = saved.imageRecognition;
    _voiceTranscription = saved.voiceTranscription;
    _responseDelay = saved.responseDelay.clamp(minDelay, AgentDraft.maxDelay);
    _sellAll = saved.sellAllProducts;
    _isActive = saved.isActive;
    _selectedPageIds
      ..clear()
      ..addAll(saved.pageIds);
    _selectedProductIds
      ..clear()
      ..addAll(saved.productIds);
    // Compare with what the form now shows, so reading the agent in is not
    // itself a change (a 0 delay shows as 1, a stray id as unticked, …).
    _original = draft;
  }

  void togglePage(String pageId) {
    if (_takenBy.containsKey(pageId)) return;
    if (!_selectedPageIds.remove(pageId)) _selectedPageIds.add(pageId);
    safeNotify();
  }

  void selectAllPages() {
    _selectedPageIds.addAll([for (final page in _pageRows) if (!_takenBy.containsKey(page.id)) page.id]);
    safeNotify();
  }

  void clearPages() {
    _selectedPageIds.clear();
    safeNotify();
  }

  void setSellAll(bool value) {
    _sellAll = value;
    safeNotify();
  }

  List<Product> get visibleProducts {
    final query = productQuery.text.trim().toLowerCase();
    if (query.isEmpty) return _productRows;
    return [
      for (final product in _productRows)
        if (product.name.toLowerCase().contains(query) || product.sku.toLowerCase().contains(query)) product,
    ];
  }

  void toggleProduct(String productId) {
    if (!_selectedProductIds.remove(productId)) _selectedProductIds.add(productId);
    safeNotify();
  }

  void clearProducts() {
    _selectedProductIds.clear();
    safeNotify();
  }

  /// The product the preview fills its tags from — the web's rule: the first
  /// one the agent will sell.
  Product? get sampleProduct {
    for (final product in _productRows) {
      if (_sellAll || _selectedProductIds.contains(product.id)) return product;
    }
    return null;
  }

  // ---- Creating and saving ----

  bool _creating = false;

  /// A create or a save is on its way.
  bool get isCreating => _creating;

  AppException? _createError;
  AppException? get createError => _createError;

  AgentDraft get draft => AgentDraft(
        name: name.value,
        description: description.value,
        personality: _personality,
        customInstructions: instructions.value,
        closingInstructions: closing.value,
        humanHandoffRules: handoff.value,
        productTemplate: template.value,
        aiModel: _aiModel,
        temperature: _temperature,
        maxTokens: tokens,
        imageRecognition: _imageRecognition,
        voiceTranscription: _voiceTranscription,
        responseDelay: _responseDelay,
        sellAllProducts: _sellAll,
        isActive: _isActive,
        // Ids no longer listed (a page since disconnected) are kept, not
        // silently dropped — the backend decides what they still mean.
        pageIds: [
          for (final page in _pageRows) if (_selectedPageIds.contains(page.id)) page.id,
          for (final id in _selectedPageIds) if (!_pageRows.any((page) => page.id == id)) id,
        ],
        productIds: [
          for (final product in _productRows) if (_selectedProductIds.contains(product.id)) product.id,
          for (final id in _selectedProductIds) if (!_productRows.any((product) => product.id == id)) id,
        ],
      );

  /// Create mode's untouched form, taken in [_load]. Kept apart from
  /// [_original], which means "the saved agent" to the save path.
  AgentDraft? _createBaseline;

  /// The form differs from the agent as loaded or last saved (edit), or from
  /// the untouched form (create). False until the form has loaded.
  bool get hasChanges {
    final baseline = _original ?? _createBaseline;
    return baseline != null && draft.changesFrom(baseline).isNotEmpty;
  }

  /// Null when the form is not valid yet — its errors are now showing.
  Future<AgentCreateOutcome?> submitAndCreate() async {
    if (_creating || !submit()) return null;
    _creating = true;
    _createError = null;
    safeNotify();

    // Submitted before the lists answered: wait, so the pages go with it.
    await load();
    if (isDisposed) return null;

    final result = await _agents.createFromDraft(draft);
    if (isDisposed) return result.valueOrNull == null ? AgentCreateOutcome.failed : AgentCreateOutcome.created;

    _creating = false;
    final error = result.errorOrNull;
    _createError = error;
    safeNotify();
    if (result.valueOrNull != null) return AgentCreateOutcome.created;
    final limit = error?.code == 'PLAN_LIMIT_REACHED' || error?.code == 'AGENT_LIMIT_REACHED';
    return limit ? AgentCreateOutcome.limitReached : AgentCreateOutcome.failed;
  }

  String? _instructionsConflict;

  /// The server's newer instructions, when a save found them rewritten.
  String? get instructionsConflict => _instructionsConflict;

  /// Saves an edited agent without undoing what changed elsewhere meanwhile.
  ///
  /// **Only the changed settings are sent** (`PUT` is a partial update), so
  /// anything the web changed that the merchant did not touch stays as the
  /// web left it. The one field both can change is the instructions — the web
  /// appends to them when an insight is resolved (§24.17) — so when they are
  /// among the changes the agent is read again first: lines appended
  /// meanwhile are added after the merchant's text; a rewrite stops the save
  /// and [instructionsConflict] asks. [overwrite] skips that check.
  ///
  /// Null when the form is not valid yet, or not ready to save.
  Future<AgentSaveOutcome?> submitAndSave({bool overwrite = false}) async {
    final id = agentId;
    final original = _original;
    if (id == null || original == null || _creating || !submit()) return null;
    var changes = draft.changesFrom(original);
    if (changes.isEmpty) return AgentSaveOutcome.unchanged;

    _creating = true;
    _createError = null;
    _instructionsConflict = null;
    safeNotify();

    var merged = false;
    if (!overwrite && changes.containsKey('customInstructions')) {
      final latest = await _agents.getDraft(id);
      if (isDisposed) return AgentSaveOutcome.failed;
      final server = latest.valueOrNull;
      if (server == null) {
        _creating = false;
        _createError = latest.errorOrNull;
        safeNotify();
        return AgentSaveOutcome.failed;
      }
      if (server.customInstructions.trim() != original.customInstructions.trim()) {
        final added = AgentDetailsViewModel.appendedLines(
          base: original.customInstructions,
          server: server.customInstructions,
        );
        if (added == null) {
          _creating = false;
          _instructionsConflict = server.customInstructions;
          safeNotify();
          return AgentSaveOutcome.conflict;
        }
        final mine = instructions.value.trim();
        if (added.isNotEmpty && !mine.contains(added)) {
          final text = mine.isEmpty ? added : '$mine\n$added';
          instructions.controller.text = text;
          changes = {...changes, 'customInstructions': text};
          merged = true;
        }
      }
    }

    final result = await _agents.update(agentId: id, changes: changes);
    if (isDisposed) return result.valueOrNull == null ? AgentSaveOutcome.failed : AgentSaveOutcome.saved;

    _creating = false;
    if (result.valueOrNull == null) {
      _createError = result.errorOrNull;
      safeNotify();
      return AgentSaveOutcome.failed;
    }
    _original = draft;
    safeNotify();
    return merged ? AgentSaveOutcome.savedWithWebChanges : AgentSaveOutcome.saved;
  }

  /// Takes the newer instructions into the form instead of the merchant's,
  /// and bases the next save on them.
  void useLatestInstructions() {
    final server = _instructionsConflict;
    final original = _original;
    if (server == null || original == null) return;
    _original = original.withCustomInstructions(server);
    instructions.controller.text = server;
    _instructionsConflict = null;
    safeNotify();
  }

  @override
  void dispose() {
    productQuery.dispose();
    productQueryFocus.dispose();
    super.dispose();
  }
}
