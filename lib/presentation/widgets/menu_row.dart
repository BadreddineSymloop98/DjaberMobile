import 'package:flutter/material.dart';

import '../../core/extensions/responsive_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

/// `Menu Row` (node `116:359`) — *"Tier-3 navigation row: icon + destination
/// + optional count + chevron. Sits inside a hairline box, like the home
/// digests."*
///
/// Fixed 48 high, which is what makes the drawer read as a list of equals
/// rather than as text of varying weight. The count is the same `Label/Meta`
/// the escalation card uses for its age, so a number in the drawer and a
/// number on home look like the same kind of fact.
class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.count,
    this.onTap,
    this.expanded,
  });

  final List<String> icon;
  final String label;

  /// Overrides the icon's `text/muted` default.
  ///
  /// *"Icon colour follows the module, not the screen"* (§21.3): the
  /// catalogue is amber, the AI is `signal/live`, alerts are red, tools are
  /// white — and Analyses and Rapports stay muted **on purpose**, because they
  /// live on the web only and grey is how this drawer says "not here".
  final Color? iconColor;

  /// A live number, rendered right of the label. Null hides it entirely
  /// rather than showing a zero.
  final String? count;

  final VoidCallback? onTap;

  /// Non-null turns the trailing chevron into a disclosure: down when open,
  /// right when closed. Null keeps the plain "goes somewhere" chevron.
  final bool? expanded;

  @override
  Widget build(BuildContext context) {
    final isGroup = expanded != null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 12.31.w, // 48
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md), // 12
          child: Row(
            children: [
              AppIcon(
                icon,
                size: 6.15.w, // 24
                color: iconColor ?? AppColors.textMuted,
              ),
              SizedBox(width: 2.56.w), // 10
              Expanded(
                child: Text(
                  label,
                  style: AppText.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count != null) ...[
                SizedBox(width: AppSpacing.sm), // 8
                Text(count!, style: AppText.labelMeta),
                SizedBox(width: AppSpacing.sm),
              ] else
                SizedBox(width: AppSpacing.sm),
              _MenuChevron(down: isGroup && expanded!),
            ],
          ),
        ),
      ),
    );
  }
}

/// `Menu Subrow` (node `141:937`) — *"A second-level nav item, indented under
/// its group — the web sidebar reveals these under Services, Analyses and
/// Rapports."*
///
/// 40 high against the row's 48, a 16 icon against 24, and `Body` in
/// `text/secondary` against `Title` in `text/primary`: three signals that it
/// is subordinate, so the indent is not carrying the hierarchy alone. It has
/// no chevron — the group above it owns the disclosure.
class MenuSubrow extends StatelessWidget {
  const MenuSubrow({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  final List<String> icon;
  final String label;
  final Color? iconColor;

  /// A `Label/Micro` note at the right edge — `BIENTÔT` on Commercial, which
  /// the web ships as `active: false` with no href.
  final String? trailing;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 10.26.w, // 40
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            // 34, the frame's own indent and the web sidebar's. Measured, not
            // derived: it puts the subrow's 16 icon under the tail of its
            // parent's 24 one (which ends at 36) and its label 14 further in
            // than the parent's. The labels deliberately do **not** line up —
            // the indent is the hierarchy, and it is meant to be visible.
            // `AppSpacing` already carries this number for the tutorial.
            start: AppSpacing.beforeAction,
            end: AppSpacing.md, // 12
          ),
          child: Row(
            children: [
              AppIcon(
                icon,
                size: AppSpacing.lg, // 16
                color: iconColor ?? AppColors.textMuted,
              ),
              SizedBox(width: 2.56.w), // 10
              Expanded(
                child: Text(
                  label,
                  style: AppText.body.copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null)
                Text(trailing!.toUpperCase(), style: AppText.labelMicro),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuChevron extends StatelessWidget {
  const _MenuChevron({required this.down});

  final bool down;

  @override
  Widget build(BuildContext context) {
    final icon = AppIcon(
      down ? AppIcons.chevronDown : AppIcons.chevronRight,
      size: AppSpacing.lg, // 16
    );

    // Only the "onwards" chevron mirrors. A disclosure chevron points at the
    // content it reveals, which is below it in Arabic exactly as it is in
    // French — the same distinction `home_widgets`' own `_Chevron` makes, and
    // the reason the flip lives at the call site rather than inside
    // [AppIcon].
    if (down) return icon;
    return Transform.flip(
      flipX: Directionality.of(context) == TextDirection.rtl,
      child: icon,
    );
  }
}
