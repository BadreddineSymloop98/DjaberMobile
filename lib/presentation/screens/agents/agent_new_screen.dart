import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/agent.dart';
import '../../../data/models/agent_draft.dart';
import '../../../data/models/ai_provider.dart';
import '../../../data/models/connected_page.dart';
import '../../../data/repositories/agent_repository.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/agent_create_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/icon_square_button.dart';
import '../tutorial/tutorial_messages.dart';
import 'agent_form_widgets.dart';
import 'agent_widgets.dart' show compactButton;

/// `15b — Partir de zéro` (Figma `463:3761`, open states `15b.1`–`15b.5`).
class AgentNewScreen extends StatelessWidget {
  const AgentNewScreen({super.key});

  @override
  Widget build(BuildContext context) => const AgentFormScreen();
}

/// `15c — Modifier l'agent` (Figma `481:4433`; `15c.1` pages, `15c.2` leave
/// without saving, `15c.3` loading). Opened from the details page.
class AgentEditScreen extends StatelessWidget {
  const AgentEditScreen({super.key, required this.agentId});

  final String agentId;

  @override
  Widget build(BuildContext context) => AgentFormScreen(agentId: agentId);
}

/// The web's full agent form — `src/app/dashboard/agents/_components/
/// AgentForm.tsx`, every field it sends — laid out for a phone. Name,
/// description, personality and instructions stay open; behaviour, product
/// display, AI model, pages and products fold, each showing its current value.
///
/// One screen for both of the web's uses of that form: with no [agentId] it
/// creates an agent; with one it edits it — filled from the agent, with the
/// *Active* switch, a skeleton while it loads, and a sheet before leaving
/// with unsaved changes.
class AgentFormScreen extends StatefulWidget {
  const AgentFormScreen({super.key, this.agentId});

  final String? agentId;

  @override
  State<AgentFormScreen> createState() => _AgentFormScreenState();
}

class _AgentFormScreenState extends State<AgentFormScreen> {
  late final NewAgentViewModel _model;

  bool get _editing => widget.agentId != null;

  @override
  void initState() {
    super.initState();
    _model = NewAgentViewModel(
      agents: context.read<AgentRepository>(),
      pages: context.read<PageRepository>(),
      products: context.read<ProductRepository>(),
      agentId: widget.agentId,
    )..load();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _back() async {
    if (_model.hasChanges && !await _confirmLeave()) return;
    if (!mounted) return;
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(_editing ? Routes.agentOf(widget.agentId!) : Routes.agentNew);
    }
  }

  /// `15c.2`: leaving an edit with unsaved changes asks first. The web has no
  /// such guard; on a phone a Back gesture is easy to fire and the form is long.
  Future<bool> _confirmLeave() async {
    final l10n = L10n.of(context);
    final name = _model.name.value.trim();
    final leave = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      barrierColor: AppColors.scrim,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.xl, AppSpacing.gutter, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.agentFormLeaveTitle, style: AppText.title),
              SizedBox(height: AppSpacing.xs),
              Text(
                l10n.agentFormLeaveBody(name.isEmpty ? l10n.agentsTitle : name),
                style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
              ),
              SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => Navigator.of(sheet).pop(false),
                child: Text(l10n.agentFormKeepEditing),
              ),
              SizedBox(height: AppSpacing.sm),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.accentAlert),
                onPressed: () => Navigator.of(sheet).pop(true),
                child: Text(l10n.agentFormLeave),
              ),
            ],
          ),
        ),
      ),
    );
    return leave ?? false;
  }

  /// Back to where the form was opened from, telling it something changed.
  /// Popping, not `go`: `go` swaps the stack without completing the push that
  /// opened this screen, so the screen under it never learns to reload.
  /// Opened without a screen below it (a restored route), `go` builds one,
  /// which loads on its own.
  void _close() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(true);
    } else {
      router.go(_editing ? Routes.agentOf(widget.agentId!) : Routes.agents);
    }
  }

  Future<void> _submit() => _editing ? _save() : _create();

  Future<void> _create() async {
    final outcome = await _model.submitAndCreate();
    if (outcome == null || !mounted) return;
    final l10n = L10n.of(context);
    switch (outcome) {
      case AgentCreateOutcome.created:
        AppToast.success(context, l10n.agentsCreatedToast);
        _close();
      case AgentCreateOutcome.limitReached || AgentCreateOutcome.failed:
        break; // The error line above the button — a plan limit in the backend's words.
    }
  }

  Future<void> _save({bool overwrite = false}) async {
    final outcome = await _model.submitAndSave(overwrite: overwrite);
    if (outcome == null || !mounted) return;
    final l10n = L10n.of(context);
    switch (outcome) {
      case AgentSaveOutcome.saved:
        AppToast.success(context, l10n.agentFormSavedToast);
        _close();
      case AgentSaveOutcome.savedWithWebChanges:
        AppToast.success(context, l10n.agentFormSavedMergedToast);
        _close();
      case AgentSaveOutcome.unchanged:
        _close();
      case AgentSaveOutcome.conflict || AgentSaveOutcome.failed:
        break; // The notice or the error line above the button.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final localeTag = Localizations.localeOf(context).toLanguageTag();

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        final m = _model;
        final ready = !_editing || m.isLoaded;

        return PopScope(
          canPop: !m.hasChanges,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _back();
          },
          child: Scaffold(
            backgroundColor: AppColors.ink,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0.47.h, AppSpacing.gutter, AppSpacing.lg),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AppBackButton(onBack: _back, semanticLabel: l10n.commonBack),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xl),
                      children: [
                        Text(_editing ? l10n.agentFormEditTitle : l10n.agentsNewTitle, style: AppText.displayM),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          _editing ? l10n.agentFormEditSubtitle : l10n.agentFormSubtitle,
                          style: AppText.bodyS.copyWith(height: 1.32),
                        ),
                        SizedBox(height: 7.18.w), // 28
                        if (_editing && m.loadError != null) ...[
                          ApiErrorLine(error: m.loadError),
                          SizedBox(height: AppSpacing.md),
                          OutlinedButton(onPressed: m.retryLoad, child: Text(l10n.commonRetry)),
                        ] else if (!ready)
                          const _FormSkeleton()
                        else
                          ..._form(l10n, localeTag),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, 3.32.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (m.instructionsConflict case final latest?) ...[
                          _InstructionsConflict(
                            latest: latest,
                            busy: m.isCreating,
                            onUseLatest: m.useLatestInstructions,
                            onKeepMine: () => _save(overwrite: true),
                          ),
                          SizedBox(height: AppSpacing.sm),
                        ],
                        ApiErrorLine(error: m.createError),
                        FilledButton(
                          onPressed: m.isCreating || !ready ? null : _submit,
                          child: m.isCreating
                              ? SizedBox.square(
                                  dimension: AppSpacing.gutterTight,
                                  child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                                )
                              : Text(_editing ? l10n.agentFormSave : l10n.tutorialAgentSubmit),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _form(L10n l10n, String localeTag) {
    final m = _model;
    final nameError = m.visibleError(m.name);
    final sectionGap = 7.18.w; // 28
    final titleGap = 3.59.w; // 14

    return [
      // ---- Informations ----
      FormSectionTitle(l10n.agentFormBasics),
      SizedBox(height: titleGap),
      AppTextField(
        label: l10n.agentName,
        isRequired: true,
        controller: m.name.controller,
        focusNode: m.name.focusNode,
        errorText: nameError == null ? null : tutorialFieldMessage(nameError, l10n),
        placeholder: l10n.agentNamePlaceholder,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => m.description.focusNode.requestFocus(),
        inputFormatters: [LengthLimitingTextInputFormatter(255)],
      ),
      SizedBox(height: AppSpacing.lg),
      AppTextField(
        label: l10n.agentFormDescription,
        controller: m.description.controller,
        focusNode: m.description.focusNode,
        placeholder: l10n.agentFormDescriptionPlaceholder,
        textCapitalization: TextCapitalization.sentences,
        minLines: 2,
        inputFormatters: [LengthLimitingTextInputFormatter(1000)],
      ),
      if (_editing) ...[
        SizedBox(height: AppSpacing.lg),
        // The web's edit-only "Active" toggle. Off pauses the agent: the
        // webhook stops replying on its pages (live docs).
        SwitchRow(
          title: l10n.agentFormActive,
          description: l10n.agentFormActiveHint,
          value: m.isActive,
          onChanged: m.setActive,
        ),
      ],
      SizedBox(height: sectionGap),

      // ---- Personnalité ----
      FormSectionTitle(l10n.agentPersonality),
      SizedBox(height: titleGap),
      _ToneGrid(model: m),
      SizedBox(height: AppSpacing.lg),
      AppTextField(
        label: l10n.agentFormInstructions,
        controller: m.instructions.controller,
        focusNode: m.instructions.focusNode,
        placeholder: l10n.agentFormInstructionsPlaceholder,
        hint: l10n.agentFormInstructionsHint,
        sentenceHint: true,
        textCapitalization: TextCapitalization.sentences,
        minLines: 4,
        inputFormatters: [LengthLimitingTextInputFormatter(5000)],
      ),
      SizedBox(height: sectionGap),

      // ---- Réglages avancés ----
      FormSectionTitle(
        l10n.agentFormAdvanced,
        subtitle: _editing ? l10n.agentFormEditAdvancedHint : l10n.agentFormAdvancedHint,
      ),
      SizedBox(height: titleGap),
      FoldGroup(
        children: [
          _fold(
            AgentFormSection.behavior,
            first: true,
            icon: AppIcons.message,
            color: AppColors.textPrimary,
            title: l10n.agentFormBehavior,
            summary: l10n.agentFormBehaviorSummary,
            content: () => _behavior(l10n),
          ),
          _fold(
            AgentFormSection.display,
            icon: AppIcons.tag,
            color: AppColors.textPrimary,
            title: l10n.agentFormDisplay,
            summary: m.template.value.trim().isEmpty ? l10n.agentFormDisplayDefault : l10n.agentFormDisplayCustom,
            content: () => _display(l10n, localeTag),
          ),
          _fold(
            AgentFormSection.model,
            // The AI is `signal/live`, as in the drawer.
            icon: AppIcons.sparkles,
            color: AppColors.live,
            title: l10n.agentFormModel,
            summary: l10n.agentFormModelSummary(
              AiModelInfo.label(m.aiModel),
              m.temperature.toStringAsFixed(1),
              m.tokens,
            ),
            content: () => _aiModel(l10n),
          ),
          _fold(
            AgentFormSection.pages,
            // Violet is people; a Page is where the customers are.
            icon: AppIcons.globe,
            color: AppColors.accentClients,
            title: l10n.agentFormPages,
            summary: m.isLoaded && m.pages.isEmpty
                ? l10n.agentFormPagesNone
                : l10n.agentFormPagesSummary(m.selectedPageCount, m.pages.length),
            content: () => _pages(l10n),
          ),
          _fold(
            AgentFormSection.products,
            icon: AppIcons.box,
            color: AppColors.accentStarred,
            title: l10n.agentFormProducts,
            summary: m.sellAllProducts
                ? l10n.agentFormProductsAll
                : l10n.agentFormProductsChosen(m.selectedProductCount),
            content: () => _products(l10n, localeTag),
          ),
        ],
      ),
    ];
  }

  Widget _fold(
    AgentFormSection section, {
    bool first = false,
    required List<String> icon,
    required Color color,
    required String title,
    required String summary,
    required Widget Function() content,
  }) {
    final expanded = _model.isExpanded(section);
    return FoldSection(
      first: first,
      icon: icon,
      iconColor: color,
      title: title,
      summary: summary,
      expanded: expanded,
      onToggle: () => _model.toggleSection(section),
      child: expanded ? content() : const SizedBox.shrink(),
    );
  }

  Widget _muted(String text) =>
      Text(text, style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32));

  Widget _behavior(L10n l10n) {
    final m = _model;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l10n.agentFormClosing,
          controller: m.closing.controller,
          focusNode: m.closing.focusNode,
          placeholder: l10n.agentFormClosingPlaceholder,
          hint: l10n.agentFormClosingHint,
          sentenceHint: true,
          textCapitalization: TextCapitalization.sentences,
          minLines: 5,
        ),
        SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: l10n.agentFormHandoff,
          controller: m.handoff.controller,
          focusNode: m.handoff.focusNode,
          placeholder: l10n.agentFormHandoffPlaceholder,
          hint: l10n.agentFormHandoffHint,
          sentenceHint: true,
          textCapitalization: TextCapitalization.sentences,
          minLines: 4,
        ),
      ],
    );
  }

  Widget _display(L10n l10n, String localeTag) {
    final m = _model;
    final tags = <(String, String)>[
      ('[PRODUCT_CARD]', l10n.agentFormTagCard),
      ('{name}', l10n.agentFormTagName),
      ('{price}', l10n.agentFormTagPrice),
      ('{description}', l10n.agentFormTagDescription),
      ('{stock}', l10n.agentFormTagStock),
      ('\n', l10n.agentFormTagNewLine),
    ];
    final sample = m.sampleProduct;
    final price = sample?.sellingPrice ?? 1500; // the web's sample price
    final description = sample?.description?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _muted(l10n.agentFormDisplayHint),
        SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final (tag, label) in tags)
              TagChip(
                label: label,
                onTap: () {
                  m.insertTag(tag);
                  m.template.focusNode.requestFocus();
                },
              ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: l10n.agentFormTemplate,
          controller: m.template.controller,
          focusNode: m.template.focusNode,
          placeholder: l10n.agentFormTemplatePlaceholder,
          minLines: 4,
        ),
        SizedBox(height: AppSpacing.lg),
        Text(l10n.agentFormPreview.toUpperCase(), style: AppText.labelMeta),
        SizedBox(height: 1.54.w),
        TemplatePreview(
          template: m.template.value,
          fallback: l10n.agentFormPreviewDefault,
          customerMessage: l10n.agentFormPreviewCustomer,
          liveLabel: l10n.agentFormPreviewLive,
          productName: sample?.name ?? l10n.agentFormPreviewSampleName,
          productPrice: Money.grouped(price, localeTag),
          productPriceLabel: Money.price(price, localeTag),
          productDescription: description.isEmpty ? l10n.agentFormPreviewSampleDescription : description,
          productStock: '${sample?.quantity ?? 12}',
          imageUrl: sample?.imageUrl,
        ),
      ],
    );
  }

  String? _trait(L10n l10n, AiModelTrait? trait) => switch (trait) {
        null => null,
        AiModelTrait.bestQuality => l10n.agentFormTraitBestQuality,
        AiModelTrait.fastAffordable => l10n.agentFormTraitFastAffordable,
        AiModelTrait.longContext128k => l10n.agentFormTraitLongContext128k,
        AiModelTrait.legacyFast => l10n.agentFormTraitLegacyFast,
        AiModelTrait.bestBalanced => l10n.agentFormTraitBestBalanced,
        AiModelTrait.fastCheap => l10n.agentFormTraitFastCheap,
        AiModelTrait.mostCapable => l10n.agentFormTraitMostCapable,
        AiModelTrait.latestFast => l10n.agentFormTraitLatestFast,
        AiModelTrait.longContext1m => l10n.agentFormTraitLongContext1m,
        AiModelTrait.bestOpenSource => l10n.agentFormTraitBestOpenSource,
        AiModelTrait.ultraFast => l10n.agentFormTraitUltraFast,
        AiModelTrait.mixtureOfExperts => l10n.agentFormTraitMixtureOfExperts,
        AiModelTrait.reasoning => l10n.agentFormTraitReasoning,
      };

  Widget _aiModel(L10n l10n) {
    final m = _model;
    final offered = {for (final provider in m.providers) ...provider.models};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.agentFormModelPicker.toUpperCase(), style: AppText.labelMeta),
        SizedBox(height: AppSpacing.sm),
        if (!m.isLoaded)
          _muted(l10n.agentFormModelsLoading)
        else if (m.providers.isEmpty)
          _muted(l10n.agentFormModelsUnavailable)
        else ...[
          // An edited agent may run on a model the admin has since switched
          // off: show it, ticked, rather than pretend another is chosen.
          if (!offered.contains(m.aiModel))
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: _modelCard(l10n, m.aiModel),
            ),
          for (final provider in m.providers) ...[
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.xs, bottom: 1.54.w),
              child: Text(provider.displayName.toUpperCase(), style: AppText.labelMicro),
            ),
            for (final model in provider.models)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: _modelCard(l10n, model),
              ),
          ],
        ],
        SizedBox(height: AppSpacing.md),
        LabeledSlider(
          label: l10n.agentFormTemperature,
          valueLabel: m.temperature.toStringAsFixed(1),
          value: m.temperature,
          min: 0,
          max: 1,
          divisions: 10,
          onChanged: m.setTemperature,
          startLabel: l10n.agentFormPrecise,
          endLabel: l10n.agentFormCreative,
        ),
        SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: l10n.agentFormMaxTokens,
          controller: m.maxTokens.controller,
          focusNode: m.maxTokens.focusNode,
          hint: l10n.agentFormMaxTokensHint,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
        ),
        SizedBox(height: AppSpacing.lg),
        SwitchRow(
          title: l10n.agentFormImages,
          description: l10n.agentFormImagesHint,
          value: m.imageRecognition,
          onChanged: m.setImageRecognition,
        ),
        SizedBox(height: AppSpacing.sm),
        SwitchRow(
          title: l10n.agentFormVoice,
          description: l10n.agentFormVoiceHint,
          value: m.voiceTranscription,
          onChanged: m.setVoiceTranscription,
        ),
        SizedBox(height: AppSpacing.lg),
        LabeledSlider(
          label: l10n.agentFormDelay,
          valueLabel: l10n.agentFormDelayValue(m.responseDelay),
          value: m.responseDelay.toDouble(),
          min: NewAgentViewModel.minDelay.toDouble(),
          max: AgentDraft.maxDelay.toDouble(),
          divisions: AgentDraft.maxDelay - NewAgentViewModel.minDelay,
          onChanged: (value) => m.setResponseDelay(value.round()),
          startLabel: l10n.agentFormDelayValue(NewAgentViewModel.minDelay),
          endLabel: l10n.agentFormDelayMax,
          hint: l10n.agentFormDelayHint,
        ),
      ],
    );
  }

  Widget _modelCard(L10n l10n, String model) => ChoiceCard(
        filled: false,
        title: AiModelInfo.label(model),
        description: _trait(l10n, AiModelInfo.trait(model)),
        note: switch (AiModelInfo.costPer1000(model)) {
          null => null,
          final usd => l10n.agentFormModelCost('\$$usd').toUpperCase(),
        },
        selected: _model.aiModel == model,
        onTap: () => _model.selectModel(model),
      );

  Widget _loading() => Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: SizedBox.square(
            dimension: AppSpacing.lg,
            child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
          ),
        ),
      );

  Widget _link(String label, VoidCallback onTap, {bool strong = false}) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Text(
            label,
            style: AppText.bodyS.copyWith(color: strong ? AppColors.textPrimary : AppColors.textSecondary),
          ),
        ),
      );

  Widget _pages(L10n l10n) {
    final m = _model;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _muted(l10n.agentFormPagesHint),
        SizedBox(height: AppSpacing.md),
        if (!m.isLoaded)
          _loading()
        else if (m.pages.isEmpty)
          Text(l10n.agentFormPagesEmpty, style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.32))
        else ...[
          Row(
            children: [
              _link(l10n.agentFormSelectAll, m.selectAllPages, strong: true),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text('·', style: AppText.bodyS.copyWith(color: AppColors.textMuted)),
              ),
              _link(l10n.agentFormClear, m.clearPages),
              const Spacer(),
              Text(
                l10n.agentFormPagesCount(m.selectedPageCount, m.pages.length).toUpperCase(),
                style: AppText.labelMeta,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          FoldGroup(
            filled: false,
            children: [
              for (final (index, page) in m.pages.indexed) _pageRow(l10n, page, first: index == 0),
            ],
          ),
        ],
      ],
    );
  }

  Widget _pageRow(L10n l10n, ConnectedPage page, {required bool first}) {
    final m = _model;
    final holder = m.takenBy(page.id);
    final instagram = page.platform == PagePlatform.instagram;
    final status = page.isActive ? l10n.agentFormPageActive : l10n.agentFormPageInactive;
    return SelectRow(
      first: first,
      leading: ThumbBox(
        size: 9.23.w, // 36
        child: AppIcon(
          instagram ? AppIcons.instagram : AppIcons.facebook,
          size: 4.62.w,
          color: AppColors.textSecondary,
          filled: true,
        ),
      ),
      title: page.pageName,
      meta: holder != null ? l10n.agentFormPageTaken(holder) : '${instagram ? 'Instagram' : 'Facebook'} · $status',
      selected: m.isPageSelected(page.id),
      onTap: holder != null ? null : () => m.togglePage(page.id),
    );
  }

  Widget _products(L10n l10n, String localeTag) {
    final m = _model;
    final rows = m.visibleProducts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchRow(
          title: l10n.agentFormSellAll,
          description: l10n.agentFormSellAllHint,
          value: m.sellAllProducts,
          onChanged: m.setSellAll,
        ),
        if (!m.sellAllProducts) ...[
          SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: l10n.agentFormProductSearch,
            controller: m.productQuery,
            focusNode: m.productQueryFocus,
            placeholder: l10n.agentFormProductSearchPlaceholder,
            textInputAction: TextInputAction.search,
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.agentFormProductsChosen(m.selectedProductCount).toUpperCase(),
                  style: AppText.labelMeta,
                ),
              ),
              if (m.selectedProductCount > 0) _link(l10n.agentFormClear, m.clearProducts),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          if (!m.isLoaded)
            _loading()
          else if (rows.isEmpty)
            _muted(m.productQuery.text.trim().isEmpty ? l10n.agentFormProductsNone : l10n.agentFormProductsNoMatch)
          else
            FoldGroup(
              filled: false,
              children: [
                for (final (index, product) in rows.indexed)
                  SelectRow(
                    first: index == 0,
                    leading: ThumbBox(
                      size: 8.21.w, // 32
                      imageUrl: product.imageUrl,
                      child: AppIcon(AppIcons.box, size: 4.10.w, color: AppColors.textMuted),
                    ),
                    title: product.name,
                    meta: '${product.sku} · ${Money.price(product.sellingPrice, localeTag)}',
                    selected: m.isProductSelected(product.id),
                    onTap: () => m.toggleProduct(product.id),
                  ),
              ],
            ),
        ],
      ],
    );
  }
}

/// The web's two-by-two personality grid; the two cards of a row share the
/// taller one's height so the grid stays square when a description wraps.
class _ToneGrid extends StatelessWidget {
  const _ToneGrid({required this.model});

  final NewAgentViewModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final tones = <(AgentPersonality, String, String)>[
      (AgentPersonality.professional, l10n.agentToneProfessional, l10n.agentToneProfessionalDesc),
      (AgentPersonality.friendly, l10n.agentToneFriendly, l10n.agentToneFriendlyDesc),
      (AgentPersonality.casual, l10n.agentToneCasual, l10n.agentToneCasualDesc),
      (AgentPersonality.technical, l10n.agentToneTechnical, l10n.agentToneTechnicalDesc),
    ];
    return Column(
      children: [
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) SizedBox(height: AppSpacing.sm),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var col = 0; col < 2; col++) ...[
                  if (col > 0) SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ChoiceCard(
                      title: tones[row * 2 + col].$2,
                      description: tones[row * 2 + col].$3,
                      selected: model.personality == tones[row * 2 + col].$1,
                      onTap: () => model.selectPersonality(tones[row * 2 + col].$1),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// `15c.3`: the form's shape in hairline blocks while the agent loads — the
/// web shows a skeleton too.
class _FormSkeleton extends StatelessWidget {
  const _FormSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget block(double height) => Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
        );
    Widget label(double width) => Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            width: width,
            height: AppSpacing.sm,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(2)),
          ),
        );
    Widget pair() => Row(
          children: [
            Expanded(child: block(17.95.w)), // 70
            SizedBox(width: AppSpacing.sm),
            Expanded(child: block(17.95.w)),
          ],
        );

    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          label(28.w),
          SizedBox(height: AppSpacing.sm),
          block(AppSize.control),
          SizedBox(height: AppSpacing.lg),
          block(16.41.w), // 64
          SizedBox(height: 7.18.w),
          label(23.w),
          SizedBox(height: AppSpacing.sm),
          pair(),
          SizedBox(height: AppSpacing.sm),
          pair(),
          SizedBox(height: AppSpacing.lg),
          block(24.62.w), // 96
          SizedBox(height: 7.18.w),
          label(33.w),
          SizedBox(height: AppSpacing.sm),
          block(64.w), // 250
        ],
      ),
    );
  }
}

/// A save found the instructions rewritten elsewhere while the merchant
/// changed them too: the current version, and the two ways forward. Taking it
/// is the primary action — the one that cannot lose anybody's work.
class _InstructionsConflict extends StatelessWidget {
  const _InstructionsConflict({
    required this.latest,
    required this.busy,
    required this.onUseLatest,
    required this.onKeepMine,
  });

  final String latest;
  final bool busy;
  final VoidCallback onUseLatest;
  final VoidCallback onKeepMine;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final text = latest.trim();
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.ruleStrong, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.agentsDetailsConflictTitle, style: AppText.title),
          SizedBox(height: AppSpacing.xs),
          Text(
            l10n.agentsDetailsConflictBody,
            style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            text.isEmpty ? l10n.agentsDetailsNoInstructions : text,
            style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.4),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              FilledButton(
                style: compactButton,
                onPressed: busy ? null : onUseLatest,
                child: Text(l10n.agentsDetailsUseLatest),
              ),
              TextButton(
                style: compactButton,
                onPressed: busy ? null : onKeepMine,
                child: Text(l10n.agentsDetailsKeepMine),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
