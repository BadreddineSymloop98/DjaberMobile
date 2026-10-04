import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/connected_page.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/page_analysis_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_scope.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import '../../widgets/list_widgets.dart';
import '../orders/order_status_pill.dart';
import '../sales/sale_widgets.dart';
import 'page_detail_screen.dart';

/// `Page analysis` (Figma `688:19729`; `· reconnexion` `688:19821`, `· analyse
/// en cours` `688:19918`, `· vérification` `688:20004`, `· terminé`
/// `688:20229`) — the web's `page/[pageId]/analyze`.
///
/// Start → the scan (minutes, a spinner that says so) → the candidates to
/// check and edit → import into the main stock → what was created. Leaving
/// the review with candidates on screen asks first: a scan is not free to
/// repeat.
class PageAnalysisScreen extends StatefulWidget {
  const PageAnalysisScreen({super.key, required this.pageId, this.page});

  final String pageId;
  final ConnectedPage? page;

  @override
  State<PageAnalysisScreen> createState() => _PageAnalysisScreenState();
}

class _PageAnalysisScreenState extends State<PageAnalysisScreen> {
  late final PageAnalysisViewModel _model = PageAnalysisViewModel(
    pages: context.read<PageRepository>(),
    pageId: widget.pageId,
  );

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool get _holding =>
      _model.step == AnalysisStep.scanning ||
      _model.step == AnalysisStep.importing ||
      _model.step == AnalysisStep.review;

  Future<bool> _onBack() async {
    if (_model.step == AnalysisStep.scanning || _model.step == AnalysisStep.importing) return false;
    if (_model.step != AnalysisStep.review) return true;
    return showLeaveSheet(context, body: L10n.of(context).pageAnalysisLeave);
  }

  Future<void> _import() async {
    FocusScope.of(context).unfocus();
    final l10n = L10n.of(context);
    final error = await _model.importSelected();
    if (error != null && mounted) AppToast.info(context, apiErrorMessage(error, l10n));
  }

  void _backToPage() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.pageOf(widget.pageId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => BackIntercept(
        active: _holding,
        onBack: _onBack,
        child: Scaffold(
          backgroundColor: AppColors.ink,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.gutterTight,
                      0.47.h,
                      AppSpacing.gutterTight,
                      AppSpacing.xl,
                    ),
                    children: _content(l10n),
                  ),
                ),
                if (_model.step == AnalysisStep.review || _model.step == AnalysisStep.importing)
                  _footer(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(L10n l10n) {
    return [
      Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.lg),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppBackButton(semanticLabel: l10n.pageAnalysisBack),
        ),
      ),
      Text(l10n.pageAnalysisBack.toUpperCase(), style: AppText.labelMeta),
      SizedBox(height: 1.54.w),
      Text(l10n.pageAnalysisTitle, style: AppText.displayM),
      SizedBox(height: 1.54.w),
      Text(
        l10n.pageAnalysisSubtitle,
        style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.32),
      ),
      SizedBox(height: AppSpacing.xl),
      ...switch (_model.step) {
        AnalysisStep.start => _start(l10n),
        AnalysisStep.scanning => [_scanning(l10n)],
        AnalysisStep.review || AnalysisStep.importing => _review(l10n),
        AnalysisStep.done => [_done(l10n)],
      },
    ];
  }

  List<Widget> _start(L10n l10n) {
    final platform = widget.page == null ? 'Facebook' : pagePlatformName(widget.page!.platform);
    final rescanning = _model.foundNothing || _model.warning != null || _model.failure != null;

    return [
      SaleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSpacing.md),
            const Center(child: _Square(icon: AppIcons.search)),
            SizedBox(height: AppSpacing.md),
            Text(l10n.pageAnalysisCardTitle, style: AppText.title, textAlign: TextAlign.center),
            SizedBox(height: AppSpacing.xs),
            Text(
              l10n.pageAnalysisCardBody,
              style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.4),
              textAlign: TextAlign.center,
            ),
            // The scan ran: what came back, said before the button again.
            if (_model.foundNothing) ...[
              SizedBox(height: AppSpacing.md),
              Text(l10n.pageAnalysisNothing, style: AppText.bodyS, textAlign: TextAlign.center),
            ],
            if (_model.warning case final warning?) ...[
              SizedBox(height: AppSpacing.md),
              Text(
                warning,
                style: AppText.bodyS.copyWith(color: AppColors.accentAlert),
                textAlign: TextAlign.center,
              ),
            ],
            if (_model.failure case final failure?) ...[
              SizedBox(height: AppSpacing.md),
              ApiErrorLine(error: failure),
            ],
            if (_model.needsReconnect) ...[
              SizedBox(height: AppSpacing.lg),
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.pageAnalysisReconnectTitle(platform), style: AppText.title),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.pageAnalysisReconnectBody,
                      style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.4),
                    ),
                    SizedBox(height: AppSpacing.md),
                    // Reconnecting is *Connecter* again on the pages list: the
                    // backend reactivates the same row with the new permission.
                    OutlinedButton(
                      onPressed: () => GoRouter.of(context).go(Routes.pages),
                      child: Text(l10n.pageAnalysisReconnectCta),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _model.analyze,
              child: Text(rescanning ? l10n.pageAnalysisRescan : l10n.pageAnalysisStart),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _scanning(L10n l10n) {
    return SaleCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.21.w),
        child: Column(
          children: [
            const SaleSpinner(dimension: 24),
            SizedBox(height: AppSpacing.lg),
            Text(
              l10n.pageAnalysisScanning,
              style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _review(L10n l10n) {
    final candidates = _model.candidates;
    final allSelected = candidates.every((c) => c.selected);
    final busy = _model.step == AnalysisStep.importing;
    final incomplete = _model.incompleteSelected;

    return [
      SaleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [
                if (widget.page != null) widget.page!.pageName,
                l10n.pageAnalysisScanned(_model.scanned),
                l10n.pageAnalysisFound(candidates.length),
              ].join('  ·  '),
              style: AppText.bodyS,
            ),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                ToolChip(
                  icon: AppIcons.check,
                  label: allSelected ? l10n.pageProductsDeselectAll : l10n.pageProductsSelectAll,
                  active: false,
                  onTap: busy ? () {} : () => _model.selectAll(!allSelected),
                ),
              ],
            ),
          ],
        ),
      ),
      // One fixed slot that only hides its content. It used to be inserted and
      // removed as the fields filled in — the first digit that completed a
      // card removed it, every card below moved up two places, and the field
      // being typed in was rebuilt, losing its focus and the keyboard.
      KeyedSubtree(
        key: const ValueKey('incomplete-notice'),
        child: incomplete == 0
            ? const SizedBox.shrink()
            : Padding(
                padding: EdgeInsets.only(top: AppSpacing.md),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.accentAlert, width: AppStroke.hairline),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppIcon(AppIcons.alert, size: AppSpacing.lg, color: AppColors.accentAlert),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.pageAnalysisIncomplete(incomplete),
                          style: AppText.bodyS.copyWith(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      SizedBox(height: AppSpacing.md),
      // Keyed by candidate, spacing included in the keyed child: whatever
      // changes above, each card — and the field in it — keeps its state.
      for (final c in candidates)
        Padding(
          key: ObjectKey(c),
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: _CandidateCard(draft: c, enabled: !busy, onToggle: () => _model.toggle(c)),
        ),
    ];
  }

  Widget _footer(L10n l10n) {
    final busy = _model.step == AnalysisStep.importing;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutterTight,
        AppSpacing.md,
        AppSpacing.gutterTight,
        3.32.h,
      ),
      child: FilledButton(
        onPressed: _model.canImport ? _import : null,
        child: busy
            ? Text(l10n.pageAnalysisImporting)
            : Text(l10n.pageAnalysisImport(_model.selected.length)),
      ),
    );
  }

  Widget _done(L10n l10n) {
    final result = _model.result;
    final created = result?.created ?? 0;
    final skipped = result?.skipped ?? 0;

    return SaleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSpacing.md),
          const Center(child: _Square(icon: AppIcons.checkCircle)),
          SizedBox(height: AppSpacing.md),
          Text(
            l10n.pageAnalysisDoneTitle(created),
            style: AppText.title,
            textAlign: TextAlign.center,
          ),
          if (skipped > 0) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              l10n.pageAnalysisSkipped(skipped).toUpperCase(),
              style: AppText.labelMeta,
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: AppSpacing.lg),
          if (created > 0) ...[
            FilledButton(
              onPressed: () => GoRouter.of(context).push(Routes.products),
              child: Text(l10n.pageOpenStock),
            ),
            SizedBox(height: AppSpacing.sm),
          ],
          OutlinedButton(onPressed: _backToPage, child: Text(l10n.pageAnalysisBack)),
        ],
      ),
    );
  }
}

class _Square extends StatelessWidget {
  const _Square({required this.icon});

  final List<String> icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12.31.w,
      height: 12.31.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: AppIcon(icon, size: 5.64.w, color: AppColors.textSecondary),
    );
  }
}

/// One candidate: its picture, the tick, then the fields to check. An
/// unticked one is drawn faded and its fields are left alone.
class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.draft, required this.enabled, required this.onToggle});

  final CandidateDraft draft;
  final bool enabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final d = draft;
    final image = d.source.imageUrl;
    final active = d.selected && enabled;

    String? missing(bool flag, String text) => d.selected && flag ? text : null;

    return Opacity(
      opacity: d.selected ? 1 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: enabled ? onToggle : null,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: image == null
                        ? Container(
                            color: AppColors.ink,
                            alignment: Alignment.center,
                            child: AppIcon(AppIcons.box, size: 6.15.w, color: AppColors.textMuted),
                          )
                        : Image.network(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.ink,
                              alignment: Alignment.center,
                              child: AppIcon(
                                AppIcons.box,
                                size: 6.15.w,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                  ),
                  PositionedDirectional(
                    top: AppSpacing.sm,
                    start: AppSpacing.sm,
                    child: OrderTick(
                      checked: d.selected,
                      onTap: enabled ? onToggle : () {},
                      label: d.name.text,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: IgnorePointer(
                ignoring: !active,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: l10n.pageAnalysisName,
                      isRequired: true,
                      controller: d.name,
                      focusNode: d.nameFocus,
                      errorText: missing(d.nameMissing, l10n.pageAnalysisFillName),
                      inputFormatters: [LengthLimitingTextInputFormatter(120)],
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: l10n.caisseFieldDescription,
                      controller: d.description,
                      focusNode: d.descriptionFocus,
                      placeholder: l10n.pageAnalysisDescriptionHint,
                      minLines: 2,
                      inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                    ),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: l10n.pageAnalysisPrice,
                            isRequired: true,
                            controller: d.price,
                            focusNode: d.priceFocus,
                            placeholder: '0',
                            errorText: missing(d.priceMissing, l10n.pageAnalysisFillPrice),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                              LengthLimitingTextInputFormatter(12),
                            ],
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppTextField(
                            label: l10n.pageAnalysisStock,
                            isRequired: true,
                            controller: d.stock,
                            focusNode: d.stockFocus,
                            placeholder: '0',
                            errorText: missing(d.stockMissing, l10n.pageAnalysisFillStock),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (d.source.category case final category?) ...[
                      SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: OrderStatusPill(
                          label: _categoryLabel(category, l10n),
                          tone: PillTone.moving,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The model's category guess, in the merchant's language when known.
  static String _categoryLabel(String category, L10n l10n) => switch (category) {
    'clothing' => l10n.pageCategoryClothing,
    'beauty' => l10n.pageCategoryBeauty,
    'electronics' => l10n.pageCategoryElectronics,
    'food' => l10n.pageCategoryFood,
    'accessories' => l10n.pageCategoryAccessories,
    'home' => l10n.pageCategoryHome,
    'kids' => l10n.pageCategoryKids,
    'other' => l10n.pageCategoryOther,
    _ => category,
  };
}
