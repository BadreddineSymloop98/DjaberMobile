import 'package:flutter/material.dart';

import '../../core/extensions/responsive_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

/// The Figma `Option Card` component (node `124:641`).
///
/// Its own description: *"A settings choice, stacked full width. Selection is
/// carried by the border — line/lit when chosen, hairline when not — the same
/// mechanism the escalation card uses."*
///
/// So selection is a **border change plus a badge**, never a tick or a radio
/// dot. That is the web's own mechanism (`--rule` versus `--rule-strong`) and
/// the reason the design needs no accent colour to show state.
///
/// Used by `T2 — Mode stock` and by the stock-mode section of
/// `11 — Paramètres`, which is why it lives in `widgets/` rather than beside
/// either screen.
class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.label,
    this.icon,
    required this.description,
    required this.selected,
    required this.onTap,
    required this.selectedBadge,
  });

  /// A glyph from [AppIcons], or null. `T4 — Agent IA` uses the card without
  /// one: its four personality choices carry no icon in the frame.
  final List<String>? icon;

  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  /// The word shown on the chosen card — `ACTIF`. Passed in rather than read
  /// from `L10n` here so the component stays free of localisation lookups.
  final String selectedBadge;

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
          border: Border.all(
            // The whole selection mechanism, in one line.
            color: selected ? AppColors.ruleStrong : AppColors.rule,
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
                if (icon != null) ...[
                  AppIcon(icon!, size: 6.15.w), // 24
                  SizedBox(width: 2.56.w), // 10
                ],
                Expanded(child: Text(label, style: AppText.title)),
                if (selected)
                  Text(
                    selectedBadge,
                    // Label/Micro in `text/primary`, not the muted default:
                    // it is the one lit thing on the card.
                    style: AppText.labelMicro
                        .copyWith(color: AppColors.textPrimary),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.sm), // 8
            Text(
              description,
              style: AppText.bodyS.copyWith(height: 1.32),
            ),
          ],
        ),
      ),
    );
  }
}
