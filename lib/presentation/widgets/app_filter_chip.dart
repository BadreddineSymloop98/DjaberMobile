import 'package:flutter/material.dart';

import '../../core/extensions/responsive_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// One filter chip. Selected inverts to a white fill with ink text; the rest
/// are outlined in `line/hairline`.
///
/// Inversion rather than a tint, because the palette's accents all *mean*
/// something (brief §21.3) and a selected filter means nothing about the
/// module it belongs to.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 8.21.w, // 32
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md), // 12
          decoration: BoxDecoration(
            color: selected ? AppColors.textPrimary : Colors.transparent,
            border: Border.all(
              color: selected ? AppColors.textPrimary : AppColors.rule,
              width: AppStroke.hairline,
            ),
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Text(
            label,
            style: AppText.bodyS.copyWith(
              color: selected ? AppColors.ink : AppColors.textSecondary,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

/// A scrolling row of chips, bled to the screen edges.
///
/// **Horizontally scrollable, and it has to be.** The frames draw three chips
/// that fit; the real row is `Tous` + `Stock faible` + one chip per category a
/// merchant has created, in words they chose, in three languages. That cannot
/// be made to fit and must not wrap — a filter bar that grows to two lines
/// pushes the list it filters off the screen.
///
/// The padding is inside the scroll view rather than around it so the first
/// chip starts on the gutter and the last one can still scroll clear of it,
/// instead of being clipped by a parent's padding.
class FilterChipRow extends StatelessWidget {
  const FilterChipRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: AppSpacing.sm), // 8
            children[i],
          ],
        ],
      ),
    );
  }
}
