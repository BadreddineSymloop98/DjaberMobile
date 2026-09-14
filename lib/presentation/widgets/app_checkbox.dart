import 'package:flutter/material.dart';

import '../../core/extensions/responsive_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The `Checkbox` component (node `37:16`), with its label.
///
/// Radius drops to 1px — at 16px a card radius reads as a rounded blob, which
/// is why the design specifies it.
///
/// Lifted out of `login_screen.dart` when `18 — Ajouter un produit` needed the
/// same control for *Ce produit a des variantes*. The whole row is the hit
/// target, box and label together: a 16px box is under the 48px minimum on its
/// own, and a merchant aims at the words.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// An optional second line under the label, for a rule the merchant needs
  /// before they tick it rather than after.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final note = hint;

    return Semantics(
      checked: value,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4.1.w, // 16
              height: 4.1.w,
              // Nudged down onto the label's cap height. Aligning the box's
              // top with the text's top sits it visibly high, because a line
              // box is taller than the glyphs in it.
              margin: EdgeInsets.only(top: 0.51.w), // 2
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: value ? AppColors.textPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
                border: Border.all(
                  color: AppColors.ruleStrong,
                  width: AppStroke.hairline,
                ),
              ),
              child: value
                  ? Text(
                      '✓',
                      style: AppText.labelMeta.copyWith(color: AppColors.ink),
                    )
                  : null,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppText.actionS.copyWith(fontSize: 12.sp),
                  ),
                  if (note != null) ...[
                    SizedBox(height: AppSpacing.xxs), // 2
                    Text(note.toUpperCase(), style: AppText.labelMicro),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
