import 'package:flutter/material.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/djaber_logo.dart';

/// The artwork for the three onboarding slides, transcribed from Figma frames
/// `02 — Onboarding 1 · Stock`, `03 — Onboarding 2 · IA` and
/// `04 — Onboarding 3 · Escalade`.
///
/// Real UI rather than illustration: the promise on screen is the product on
/// screen. These are still **stand-ins** — the Escalation Card, List Row and
/// KPI Tile do not exist as shared components yet — so when they land, replace
/// the bodies here with instances and delete the private widgets below.
///
/// Every string comes from the `ob*` keys, which are illustrative sample data,
/// not live values. They are translated all the same: an Arabic first run
/// showing French product names reads as broken.
///
/// The lower items in each stack fade out. That is done with per-item opacity
/// rather than a gradient `ShaderMask` — four cheap layers instead of one
/// full-height `saveLayer`, which matters on the hardware in brief §9.

/// The design frame is 390 wide with 20 gutters, so the artwork is 350 across
/// — 89.74% of the screen width. Slides scale it down on a narrower handset
/// rather than reflowing.
double get _artworkWidth => 89.74.w;

/// Slide 1 — the stock summary: value, four counters, and the product list.
class StockArtwork extends StatelessWidget {
  const StockArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return SizedBox(
      width: _artworkWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(l10n.obStockValue, style: AppText.numeralL),
                    SizedBox(width: AppSpacing.sm),
                    Text(l10n.obStockValueUnit, style: AppText.labelS),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Text(l10n.obStockValueLabel.toUpperCase(), style: AppText.label),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (final (index, kpi) in _kpis(l10n).indexed) ...[
                Expanded(child: _KpiTile(kpi: kpi)),
                if (index < 3) SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.md),
          // The list runs off the bottom of the frame rather than ending, so
          // it reads as a real screen the merchant is looking into.
          for (final (index, row) in _rows(l10n).indexed) ...[
            Opacity(
              opacity: _fade(index),
              child: _StockRow(row: row, inStockLabel: l10n.obInStock),
            ),
            if (index < 2) SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }

  static List<_Kpi> _kpis(L10n l10n) => [
        _Kpi(l10n.obKpiProducts, l10n.obKpiProductsValue, AppIcons.box,
            AppColors.textMuted),
        _Kpi(l10n.obKpiPurchases, l10n.obKpiPurchasesValue, AppIcons.truck,
            AppColors.textMuted),
        _Kpi(l10n.obKpiSales, l10n.obKpiSalesValue, AppIcons.dollar,
            AppColors.accentMoney),
        _Kpi(l10n.obKpiOrders, l10n.obKpiOrdersValue, AppIcons.clipboard,
            AppColors.accentOrders),
      ];

  static List<_StockRowData> _rows(L10n l10n) => [
        _StockRowData(
            l10n.obStockRow1Name, l10n.obStockRow1Meta, l10n.obStockRow1Qty),
        _StockRowData(
            l10n.obStockRow2Name, l10n.obStockRow2Meta, l10n.obStockRow2Qty),
        _StockRowData(
            l10n.obStockRow3Name, l10n.obStockRow3Meta, l10n.obStockRow3Qty),
      ];
}

/// Slide 2 — the agent answering a customer. Unchanged.
class ConversationArtwork extends StatelessWidget {
  const ConversationArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return _Surface(
      width: _artworkWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ThreadHeader(name: l10n.onboardingSampleCustomer),
          SizedBox(height: AppSpacing.lg),
          _Bubble(text: l10n.onboardingSampleMessage, fromCustomer: true),
          SizedBox(height: AppSpacing.sm),
          _Bubble(text: l10n.onboardingSampleReply, fromCustomer: false),
          SizedBox(height: AppSpacing.md),
          _LiveChip(label: l10n.onboardingSampleHandling),
        ],
      ),
    );
  }
}

/// Slide 3 — the queue.
///
/// Four cards, and the order is the argument: conversational, consequential,
/// operational — the three kinds the model in brief §3 predicts — then a
/// negotiation, which is the case the AI understands perfectly well and should
/// hand over anyway (G2). Treated separately these are three features; stacked
/// like this they are one queue.
class EscalationArtwork extends StatelessWidget {
  const EscalationArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final cards = [
      _EscalationData(
          l10n.obEsc1Kind, l10n.obEsc1Time, l10n.obEsc1Name, l10n.obEsc1Body),
      _EscalationData(
          l10n.obEsc2Kind, l10n.obEsc2Time, l10n.obEsc2Name, l10n.obEsc2Body),
      _EscalationData(
          l10n.obEsc3Kind, l10n.obEsc3Time, l10n.obEsc3Name, l10n.obEsc3Body),
      _EscalationData(
          l10n.obEsc4Kind, l10n.obEsc4Time, l10n.obEsc4Name, l10n.obEsc4Body),
    ];

    return SizedBox(
      width: _artworkWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, card) in cards.indexed) ...[
            Opacity(
              opacity: _fade(index),
              // Only the top card is waiting on the merchant, so only it takes
              // the strong rule and the primary-weight kind label. That is the
              // web's own `--rule` versus `--rule-strong` mechanism carrying
              // urgency, which is what depth used to do before the flat
              // decision in brief §15.
              child: _EscalationCard(data: card, waiting: index == 0),
            ),
            if (index < cards.length - 1)
              SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// How far down the stack an item sits, as an opacity.
double _fade(int index) => switch (index) {
      0 => 1,
      1 => 0.55,
      2 => 0.28,
      _ => 0.12,
    };

// ---------------------------------------------------------------------------
// Stand-ins. Delete once the real components land.
// ---------------------------------------------------------------------------

class _Kpi {
  const _Kpi(this.label, this.value, this.icon, this.accent);
  final String label;
  final String value;
  final List<String> icon;
  final Color accent;
}

class _StockRowData {
  const _StockRowData(this.name, this.meta, this.qty);
  final String name;
  final String meta;
  final String qty;
}

class _EscalationData {
  const _EscalationData(this.kind, this.time, this.name, this.body);
  final String kind;
  final String time;
  final String name;
  final String body;
}

/// A surface with a hairline — the shape every card in the app takes.
class _Surface extends StatelessWidget {
  const _Surface({
    required this.child,
    this.border = AppColors.rule,
    this.width,
    this.padding,
  });

  final Widget child;
  final Color border;
  final double? width;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding ?? EdgeInsets.all(AppSpacing.gutterTight),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.kpi});

  final _Kpi kpi;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(kpi.icon, size: 5.13.w, color: kpi.accent), // 20
          SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(kpi.label.toUpperCase(), style: AppText.labelS),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(kpi.value, style: AppText.numeralM),
        ],
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  const _StockRow({required this.row, required this.inStockLabel});

  final _StockRowData row;
  final String inStockLabel;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.gutterTight,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  row.name,
                  style: AppText.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xxs),
                // The rupture row stays muted rather than red, matching the
                // frame. Depth of the stack, not colour, is what separates
                // these rows — and `accent/alert` is held back for a real
                // alert surface rather than spent on sample artwork.
                Text(
                  row.meta.toUpperCase(),
                  style: AppText.labelMeta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(row.qty, style: AppText.numeralS),
              SizedBox(height: AppSpacing.xxs),
              Text(inStockLabel.toUpperCase(), style: AppText.labelS),
            ],
          ),
        ],
      ),
    );
  }
}

class _EscalationCard extends StatelessWidget {
  const _EscalationCard({required this.data, required this.waiting});

  final _EscalationData data;
  final bool waiting;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      border: waiting ? AppColors.ruleStrong : AppColors.rule,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.kind.toUpperCase(),
                  style: waiting
                      ? AppText.label.copyWith(color: AppColors.textPrimary)
                      : AppText.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(data.time.toUpperCase(), style: AppText.labelS),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            data.name,
            style: AppText.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            data.body,
            style: AppText.bodyS,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ThreadHeader extends StatelessWidget {
  const _ThreadHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DjaberMark(size: 5.64.w), // 22
        SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(name, style: AppText.title)),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.fromCustomer});

  final String text;
  final bool fromCustomer;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromCustomer
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: Container(
        constraints: BoxConstraints(maxWidth: 61.54.w), // 240
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: fromCustomer ? AppColors.surfaceHigh : AppColors.textPrimary,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Text(
          text,
          style: AppText.bodyS.copyWith(
            color: fromCustomer ? AppColors.textPrimary : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

/// The web's `.status-live` pill, minus the pulse.
class _LiveChip extends StatelessWidget {
  const _LiveChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.rule),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 1.79.w, // 7
            height: 1.79.w,
            decoration: const BoxDecoration(
              color: AppColors.live,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            label.toUpperCase(),
            style: AppText.labelS.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
