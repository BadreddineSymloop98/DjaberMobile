import 'package:flutter/material.dart';

import '../../core/extensions/responsive_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';
import 'icon_square_button.dart';

/// The pieces `09 — Accueil` is assembled from, each one a component in the
/// Figma file rather than a shape invented here.
///
/// They live together because they are only used by home and by the screens
/// that will share its sections (`12 — Pages connectées`, `16 — Aperçu du
/// stock`). Split them out when a second screen actually needs one.

/// `Section Label` (node `31:3`) — *"Always uppercase, on gutter/label so it
/// reads as an annotation on the content below."*
///
/// The optional trailing slot carries a count on `À traiter` and an action on
/// `Vos pages`; the frame sets both in `Label/Section` at `text/primary`.
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label, this.trailing, this.onTrailingTap});

  final String label;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final trailingText = trailing;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter, // 20 — the label gutter, wider than the content's 16
        AppSpacing.xxs, // 2
        AppSpacing.gutter,
        AppSpacing.md, // 12
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label.toUpperCase(), style: AppText.labelSection),
          ),
          if (trailingText != null)
            GestureDetector(
              onTap: onTrailingTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                trailingText,
                style: AppText.labelSection
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
        ],
      ),
    );
  }
}

/// `KPI Tile` (node `32:8`) — *"A single figure, not a report."*
///
/// The unit sits on the value's baseline, and the optional footnote is the
/// tile's second fact ("3 STOCK FAIBLE", "0 VENTE").
class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.unit,
    this.footnote,
    this.iconColor,
  });

  final String label;
  final String value;
  final List<String> icon;
  final String? unit;
  final String? footnote;

  /// Colour marks the module, never decorates (brief §21.3).
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      // A *minimum*, not a fixed height. The frame's tile is 88 and every one
      // of its labels fits on a line there — but "CHIFFRE D'AFFAIRES (30J)"
      // wraps on a 320dp handset, and a label that wraps must push the tile
      // down rather than be clipped. Its row stretches, so the pair stays
      // level (see `_Kpis`).
      constraints: BoxConstraints(minHeight: 22.56.w), // 88
      padding: EdgeInsets.all(AppSpacing.md), // 12
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: AppText.labelMicro,
                  maxLines: 2,
                ),
              ),
              AppIcon(
                icon,
                size: 4.1.w, // 16
                color: iconColor ?? AppColors.textMuted,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs), // 4
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppText.numeralKpi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                SizedBox(width: AppSpacing.xs), // 4
                Text(unit!, style: AppText.labelMicro),
              ],
            ],
          ),
          if (footnote != null) ...[
            SizedBox(height: AppSpacing.xs),
            Text(footnote!.toUpperCase(), style: AppText.labelMicro),
          ],
        ],
      ),
    );
  }
}

/// `Escalation Card` (node `35:15`) — *"The queue item — the reason the app
/// exists."*
///
/// Both states share `ink/surface`; only the border and the kind's colour
/// differ. Waiting takes `line/lit` with the kind in `text/primary`; handled
/// drops to the hairline and `text/muted`. Emphasis by weight and opacity,
/// never by a new colour.
class EscalationCard extends StatelessWidget {
  const EscalationCard({
    super.key,
    required this.kind,
    required this.time,
    required this.who,
    required this.message,
    this.waiting = true,
    this.onTap,
  });

  final String kind;
  final String time;
  final String who;
  final String message;
  final bool waiting;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md), // 12
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: waiting ? AppColors.ruleStrong : AppColors.rule,
            width: AppStroke.hairline,
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    kind.toUpperCase(),
                    style: AppText.labelMeta.copyWith(
                      color: waiting
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
                Text(time.toUpperCase(), style: AppText.labelMeta),
              ],
            ),
            SizedBox(height: AppSpacing.xs), // 4
            Text(who, style: AppText.title, maxLines: 1,
                overflow: TextOverflow.ellipsis),
            SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppText.bodyS.copyWith(height: 1.32),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// `Action Card` (node `133:737`) — *"A quick action from the web dashboard:
/// what to do next, with where it goes."*
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final List<String> icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.gutterTight), // 16
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppIcon(
                  icon,
                  size: 6.15.w, // 24
                  color: iconColor ?? AppColors.textMuted,
                ),
                _Chevron(size: 4.1.w), // 16
              ],
            ),
            SizedBox(height: 2.56.w), // 10
            Text(title, style: AppText.title),
            SizedBox(height: AppSpacing.xxs), // 2
            Text(
              subtitle,
              style: AppText.bodyS
                  .copyWith(height: 1.32, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// `List Row` (node `34:3`) — *"One line in a digest… No fill of its own: it
/// sits inside a flat, hairline-bordered list container."*
class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.title,
    required this.meta,
    this.value,
    this.unit,
    this.unitColor,
    this.onTap,
  });

  final String title;
  final String meta;
  final String? value;
  final String? unit;

  /// Tints the label under the value. Used by `17 — Produits` to put
  /// `accent/alert` on `RUPTURE`: a product with no stock cannot be sold, and
  /// that is a state worth colour rather than decoration (brief §21.3).
  final Color? unitColor;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md), // 12
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppText.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: AppSpacing.xxs), // 2
                  Text(meta.toUpperCase(), style: AppText.labelMeta,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (value != null || unit != null) ...[
              SizedBox(width: AppSpacing.sm), // 8
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (value != null)
                    Text(value!, style: AppText.numeralS),
                  if (unit != null) ...[
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      unit!.toUpperCase(),
                      style: unitColor == null
                          ? AppText.labelMicro
                          : AppText.labelMicro.copyWith(color: unitColor),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// `Credits Pill` (node `148:640`) — the web header's credits chip.
///
/// *"Exhausted turns accent/alert — when credits run out the AI stops
/// replying, which is the one header state worth shouting about."* That is the
/// interrupt-shaped signal §"Home rebuilt from components" flags as missing
/// from the design, and it is why the pill is here rather than a static label.
class CreditsPill extends StatelessWidget {
  const CreditsPill({super.key, required this.label, this.exhausted = false});

  final String label;
  final bool exhausted;

  @override
  Widget build(BuildContext context) {
    final tint = exhausted ? AppColors.accentAlert : null;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm, // 8
        vertical: AppSpacing.xs, // 4
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: tint ?? AppColors.rule,
          width: AppStroke.hairline,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(
            AppIcons.bolt,
            size: 3.08.w, // 12
            // Amber, the palette's `text-amber-400`. The one icon in the
            // header that carries colour, because the bolt *is* the credit
            // meter — and it still gives way to `accent/alert` when the
            // allowance is spent, which outranks it.
            color: tint ?? AppColors.accentStarred,
          ),
          SizedBox(width: 1.28.w), // 5
          Text(
            label,
            style: AppText.labelMeta
                .copyWith(color: tint ?? AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// `Menu Button` (node `31:11`) — *"Opens tier-3 navigation (brief §16)."*
///
/// The box itself is [IconSquareButton], which the back button on the product
/// screens shares. Not flipped for Arabic: a hamburger has no direction.
class MenuButton extends StatelessWidget {
  const MenuButton({super.key, required this.onTap, this.semanticLabel});

  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => IconSquareButton(
        icon: AppIcons.menu,
        onTap: onTap,
        semanticLabel: semanticLabel,
      );
}

/// A hairline between rows inside a boxed list.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(height: AppStroke.hairline, color: AppColors.rule);
}

/// The flat, hairline-bordered container a digest sits in.
class ListBox extends StatelessWidget {
  const ListBox({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(const RowDivider());
      rows.add(children[i]);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: rows,
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    // Flipped for Arabic: a chevron meaning "onwards" points wherever onwards
    // is, unlike the entrance animation whose direction is physical.
    return Transform.flip(
      flipX: Directionality.of(context) == TextDirection.rtl,
      child: AppIcon(AppIcons.chevronRight, size: size),
    );
  }
}
