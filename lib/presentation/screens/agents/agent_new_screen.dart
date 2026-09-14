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

/// `15b — Partir de zéro` (Figma `463:3761`, open states `15b.1`–`15b.5`).
///
/// The web's full agent form — `src/app/dashboard/agents/_components/
/// AgentForm.tsx`, every field it sends — laid out for a phone. Name,
/// description, personality and instructions stay open; behaviour, product
/// display, AI model, pages and products fold, each showing its current value.
/// Only the name is required; everything else starts at the web's defaults.
class AgentNewScreen extends StatefulWidget {
  const AgentNewScreen({super.key});

  @override
  State<AgentNewScreen> createState() => _AgentNewScreenState();
}

class _AgentNewScreenState extends State<AgentNewScreen> {
  late final NewAgentViewModel _model;

  @override
  void initState() {
    super.initState();
    _model = NewAgentViewModel(
      agents: context.read<AgentRepository>(),
      pages: context.read<PageRepository>(),
      products: context.read<ProductRepository>(),
    )..load();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _back() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.agentNew);
    }
  }

  /// Back to `14` once an agent exists. Popping, not `go`: `go` swaps the
  /// stack without completing the push that opened this screen, so the list
  /// under it never learns to reload and keeps showing its empty state.
  /// Opened without a list below it (a restored route), `go` builds a fresh
  /// one, which loads on its own.
  void _close() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(true);
    } else {
      router.go(Routes.agents);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final localeTag = Localizations.localeOf(context).toLanguageTag();

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        final m = _model;
        final nameError = m.visibleError(m.name);
        final sectionGap = 7.18.w; // 28
        final titleGap = 3.59.w; // 14

        return Scaffold(
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
                      Text(l10n.agentsNewTitle, style: AppText.displayM),
                      SizedBox(height: AppSpacing.sm),
                      Text(l10n.agentFormSubtitle, style: AppText.bodyS.copyWith(height: 1.32)),
                      SizedBox(height: sectionGap),

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
                      FormSectionTitle(l10n.agentFormAdvanced, subtitle: l10n.agentFormAdvancedHint),
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
                            summary: m.template.value.trim().isEmpty
                                ? l10n.agentFormDisplayDefault
                                : l10n.agentFormDisplayCustom,
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
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, 3.32.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ApiErrorLine(error: m.createError),
                      FilledButton(
                        onPressed: m.isCreating ? null : _create,
                        child: m.isCreating
                            ? SizedBox.square(
                                dimension: AppSpacing.gutterTight,
                                child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                              )
                            : Text(l10n.tutorialAgentSubmit),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.agentFormModelPicker.toUpperCase(), style: AppText.labelMeta),
        SizedBox(height: AppSpacing.sm),
        if (!m.isLoaded)
          _muted(l10n.agentFormModelsLoading)
        else if (m.providers.isEmpty)
          _muted(l10n.agentFormModelsUnavailable)
        else
          for (final provider in m.providers) ...[
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.xs, bottom: 1.54.w),
              child: Text(provider.displayName.toUpperCase(), style: AppText.labelMicro),
            ),
            for (final model in provider.models)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: ChoiceCard(
                  filled: false,
                  title: AiModelInfo.label(model),
                  description: _trait(l10n, AiModelInfo.trait(model)),
                  note: switch (AiModelInfo.costPer1000(model)) {
                    null => null,
                    final usd => l10n.agentFormModelCost('\$$usd').toUpperCase(),
                  },
                  selected: m.aiModel == model,
                  onTap: () => m.selectModel(model),
                ),
              ),
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
              for (final (index, page) in m.pages.indexed)
                _pageRow(l10n, page, first: index == 0),
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
      meta: holder != null
          ? l10n.agentFormPageTaken(holder)
          : '${instagram ? 'Instagram' : 'Facebook'} · $status',
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
