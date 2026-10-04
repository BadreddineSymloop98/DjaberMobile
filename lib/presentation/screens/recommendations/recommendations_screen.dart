import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:provider/provider.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/recommendation.dart';
import '../../../data/repositories/recommendation_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/recommendations_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/list_widgets.dart';
import '../orders/order_status_pill.dart';
import '../sales/sale_widgets.dart';

/// `Recommendations list` (Figma `681:18697`; `· aucune recommandation`
/// `681:19061`, `· analyse en cours` `681:19270`, `Delete a recommendation`
/// `681:19472`) — the web's `stock/recommendations`.
///
/// Four figures over every recommendation, a search, the type and status
/// chips, then one card per pair: the product and what to offer with it,
/// the type and the confidence, why, how it performed, the *Active* tick and
/// delete — confirmed in the card itself, as the frame draws it.
class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  late final RecommendationsViewModel _model = RecommendationsViewModel(
    recommendations: context.read<RecommendationRepository>(),
  );

  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () => _model.setSearch(_search.text));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.reload());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _searchFocus.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final l10n = L10n.of(context);
    final result = await _model.generate();
    if (result == null || !mounted) return;
    if (result.errorOrNull case final error?) {
      AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    AppToast.success(context, l10n.recoGeneratedToast(result.valueOrNull ?? 0));
  }

  Future<void> _toggle(Recommendation r) async {
    final l10n = L10n.of(context);
    final error = await _model.toggleActive(r);
    if (error != null && mounted) AppToast.info(context, apiErrorMessage(error, l10n));
  }

  Future<void> _delete(Recommendation r) async {
    final l10n = L10n.of(context);
    final result = await _model.delete(r);
    if (!mounted) return;
    switch (result.errorOrNull) {
      case null:
        AppToast.success(context, l10n.recoDeletedToast);
      case NotFoundException():
        AppToast.info(context, l10n.recoAlreadyGone);
      case final error:
        AppToast.info(context, apiErrorMessage(error, l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _model.reload,
                  color: AppColors.textPrimary,
                  backgroundColor: AppColors.surface,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 0.47.h, bottom: AppSpacing.lg),
                    children: _content(l10n),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutterTight,
                  AppSpacing.md,
                  AppSpacing.gutterTight,
                  AppSpacing.md,
                ),
                child: FilledButton(
                  onPressed: _model.isGenerating || _model.isFirstLoad ? null : _generate,
                  child: Text(
                    _model.isGenerating
                        ? l10n.recoAnalyzing
                        // Nothing yet at all: the frame's *Générer maintenant*.
                        : (_model.recommendations.isEmpty && !_model.isNarrowed
                              ? l10n.recoGenerateNow
                              : l10n.recoGenerate),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(L10n l10n) {
    final tag = Localizations.localeOf(context).toLanguageTag();
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight);
    final stats = _model.stats;
    const dash = '—';

    return [
      Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.lg),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppBackButton(semanticLabel: l10n.commonBack),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.recoEyebrow, style: AppText.labelMeta),
            SizedBox(height: 1.54.w),
            Text(l10n.recoTitle, style: AppText.displayM),
            SizedBox(height: 1.54.w),
            Text(
              l10n.recoSubtitle,
              style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.32),
            ),
          ],
        ),
      ),
      SizedBox(height: 5.13.w),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          children: [
            KpiPair(
              KpiTile(
                label: l10n.recoStatRules,
                value: stats == null ? dash : Money.grouped(stats.total, tag),
                footnote: stats == null ? null : l10n.recoStatActive(stats.active).toUpperCase(),
                icon: AppIcons.bolt,
                iconColor: AppColors.accentStarred,
              ),
              KpiTile(
                label: l10n.recoStatImpressions,
                value: stats == null ? dash : Money.grouped(stats.totalImpressions, tag),
                footnote: l10n.recoStatImpressionsNote.toUpperCase(),
                icon: AppIcons.chart,
                iconColor: AppColors.accentMoney,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            KpiPair(
              KpiTile(
                label: l10n.recoStatConversions,
                value: stats == null ? dash : Money.grouped(stats.totalConversions, tag),
                footnote: stats == null
                    ? null
                    : l10n.recoStatRate(_rate(stats.conversionRate, tag)).toUpperCase(),
                icon: AppIcons.shoppingCart,
                iconColor: AppColors.accentMoney,
              ),
              KpiTile(
                label: l10n.recoStatRevenue,
                value: stats == null ? dash : Money.grouped(stats.totalRevenue.round(), tag),
                unit: 'DA',
                footnote: l10n.recoStatRevenueNote.toUpperCase(),
                icon: AppIcons.dollar,
                iconColor: AppColors.accentStarred,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 5.13.w),
      Padding(
        padding: gutter,
        child: AppTextField(
          label: l10n.productsSearchLabel,
          controller: _search,
          focusNode: _searchFocus,
          placeholder: l10n.recoSearch,
          textInputAction: TextInputAction.search,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
          onSubmitted: (_) => _searchFocus.unfocus(),
        ),
      ),
      SizedBox(height: AppSpacing.lg),
      Padding(
        padding: gutter,
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final (type, label) in <(RecommendationType?, String)>[
              (null, l10n.recoTypeAll),
              (RecommendationType.crossSell, l10n.recoFilterCross),
              (RecommendationType.upSell, l10n.recoFilterUp),
            ])
              AppFilterChip(
                label: label,
                selected: _model.type == type,
                onTap: () => _model.setType(type),
              ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.sm),
      Padding(
        padding: gutter,
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final (status, label) in [
              (RecommendationStatus.all, l10n.recoStatusAll),
              (RecommendationStatus.active, l10n.recoStatusActive),
              (RecommendationStatus.inactive, l10n.recoStatusInactive),
            ])
              AppFilterChip(
                label: label,
                selected: _model.status == status,
                onTap: () => _model.setStatus(status),
              ),
          ],
        ),
      ),
      SizedBox(height: 5.13.w),
      ..._list(l10n, tag),
    ];
  }

  List<Widget> _list(L10n l10n, String tag) {
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight);
    final rows = _model.recommendations;

    if (_model.isFirstLoad) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
          child: const SaleSpinner(),
        ),
      ];
    }

    if (rows.isEmpty && _model.error != null) {
      return [
        Padding(
          padding: gutter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ApiErrorLine(error: _model.error),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
              ),
            ],
          ),
        ),
      ];
    }

    return [
      SectionLabel(label: l10n.recoSection, trailing: '${rows.length}'),
      if (rows.isEmpty)
        Padding(
          padding: gutter,
          child: EmptyBox(
            icon: AppIcons.bolt,
            title: l10n.recoEmptyTitle,
            body: _model.isNarrowed ? l10n.recoNoMatchBody : l10n.recoEmptyBody,
          ),
        )
      else ...[
        Padding(
          padding: gutter,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (index, r) in rows.indexed) ...[
                  if (index > 0)
                    const Divider(
                      height: AppStroke.hairline,
                      thickness: AppStroke.hairline,
                      color: AppColors.rule,
                    ),
                  _RecommendationCard(
                    recommendation: r,
                    localeTag: tag,
                    confirming: _model.isConfirming(r),
                    deleting: _model.isDeleting(r),
                    onToggle: () => _toggle(r),
                    onAskDelete: () => _model.askDelete(r),
                    onConfirmDelete: () => _delete(r),
                    onCancelDelete: _model.cancelDelete,
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Text(l10n.recoShown(rows.length).toUpperCase(), style: AppText.labelMicro),
        ),
      ],
    ];
  }
}

/// `2,09 %` — the API's percentage, two decimals as the frame prints it.
String _rate(double percent, String tag) => '${NumberFormat('#,##0.00', tag).format(percent)} %';

/// `82 %` — a 0–100 whole figure.
String _whole(num percent, String tag) => '${NumberFormat('#,##0', tag).format(percent)} %';

/// The backend's reason in the merchant's language, or as stored.
String recommendationReasonText(String? reason, L10n l10n, String tag) {
  final parsed = RecommendationReason.parse(reason);
  final pct = parsed.percent == null ? '' : _whole(parsed.percent!, tag);
  return switch (parsed.kind) {
    ReasonKind.boughtTogether => l10n.recoReasonBought(parsed.count ?? 0, pct),
    ReasonKind.premiumAlternative => l10n.recoReasonPremium(pct),
    ReasonKind.similarDescription => l10n.recoReasonSimilar(pct),
    ReasonKind.related => l10n.recoReasonRelated(pct),
    ReasonKind.other => parsed.raw ?? '',
  };
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.recommendation,
    required this.localeTag,
    required this.confirming,
    required this.deleting,
    required this.onToggle,
    required this.onAskDelete,
    required this.onConfirmDelete,
    required this.onCancelDelete,
  });

  final Recommendation recommendation;
  final String localeTag;
  final bool confirming;
  final bool deleting;
  final VoidCallback onToggle;
  final VoidCallback onAskDelete;
  final VoidCallback onConfirmDelete;
  final VoidCallback onCancelDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final r = recommendation;
    final reason = recommendationReasonText(r.reason, l10n, localeTag);
    final rate = r.conversionRate;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    // An inactive pair is drawn faded, as the frame does — its controls stay
    // at full strength, since switching it back on is what one does next.
    final details = Opacity(
      opacity: r.isActive ? 1 : 0.45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ProductCell(product: r.product, localeTag: localeTag),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 0.77.w),
                child: Transform.flip(
                  // An arrow from the product to the one to offer, in reading
                  // order.
                  flipX: !rtl,
                  child: AppIcon(AppIcons.arrowLeft, size: 4.1.w, color: AppColors.textMuted),
                ),
              ),
              Expanded(
                child: _ProductCell(product: r.recommended, localeTag: localeTag),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _Tag(
                label: r.type == RecommendationType.crossSell ? l10n.recoTagCross : l10n.recoTagUp,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: _ScoreBar(value: r.score.clamp(0, 1).toDouble())),
              SizedBox(width: AppSpacing.sm),
              Text(_whole((r.score * 100).round(), localeTag), style: AppText.labelMeta),
            ],
          ),
          if (reason.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            Text(reason, style: AppText.bodyS.copyWith(color: AppColors.textSecondary)),
          ],
          SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  [
                    l10n.recoImpressions(r.impressions),
                    rate == null || r.conversions == 0
                        ? l10n.recoConversions(r.conversions)
                        : '${l10n.recoConversions(r.conversions)} (${_rate(rate, localeTag)})',
                  ].join('  ·  ').toUpperCase(),
                  style: AppText.labelMeta,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                r.revenue > 0 ? Money.exact(r.revenue, localeTag) : '—',
                style: AppText.numeralM,
              ),
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.all(3.59.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          details,
          SizedBox(height: AppSpacing.sm),
          if (deleting)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox.square(dimension: 9.23.w, child: const SaleSpinner(dimension: 18)),
            )
          else
            Row(
              children: [
                GestureDetector(
                  onTap: onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OrderTick(checked: r.isActive, onTap: onToggle, label: l10n.recoActive),
                      SizedBox(width: 1.28.w),
                      Text(l10n.recoActive, style: AppText.bodyS),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                if (confirming) ...[
                  Flexible(
                    child: Text(
                      l10n.recoDeleteAsk,
                      style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  _SmallButton(label: l10n.recoYes, onTap: onConfirmDelete, danger: true),
                  SizedBox(width: 1.54.w),
                  _SmallButton(label: l10n.recoNo, onTap: onCancelDelete),
                ] else
                  RowAction(icon: AppIcons.trash, label: l10n.commonDelete, onTap: onAskDelete),
              ],
            ),
          // The decided hint: a delete is not for good.
          if (confirming && !deleting) ...[
            SizedBox(height: AppSpacing.xs),
            Text(l10n.recoDeleteHint, style: AppText.labelMicro.copyWith(height: 1.4)),
          ],
        ],
      ),
    );
  }
}

class _ProductCell extends StatelessWidget {
  const _ProductCell({required this.product, required this.localeTag});

  final RecommendationProduct product;
  final String localeTag;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name.isEmpty ? '—' : product.name,
          style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 0.77.w),
        Text(Money.exact(product.sellingPrice, localeTag), style: AppText.labelMeta),
      ],
    );
  }
}

/// The confidence as a thin bar, the frame's.
class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.03.w,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(1.03.w),
      ),
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(1.03.w),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.28.w, vertical: 0.51.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(1.03.w),
      ),
      child: Text(label.toUpperCase(), style: AppText.labelMicro),
    );
  }
}

/// *Oui* / *Non* — small enough to sit in the card's control row.
class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.label, required this.onTap, this.danger = false});

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.56.w, vertical: 1.28.w),
          decoration: BoxDecoration(
            color: danger ? AppColors.accentAlert : null,
            border: Border.all(
              color: danger ? AppColors.accentAlert : AppColors.ruleStrong,
              width: AppStroke.hairline,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Text(
            label,
            style: AppText.bodyS.copyWith(color: danger ? AppColors.ink : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
