import 'package:flutter/material.dart';

import '../../core/extensions/responsive_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

/// One option in an [AppSelectField]'s picker.
class SelectOption<T> {
  const SelectOption({required this.value, required this.label, this.meta});

  /// The value handed back on selection. Null is legitimate and means "none" —
  /// an optional field's way of being cleared again.
  final T? value;

  final String label;

  /// An optional second line, uppercase mono — a product count, a symbol.
  final String? meta;
}

/// **A select, which the design system does not have.**
///
/// The Figma file has a `Text Field` and nothing else that takes a value, so
/// `18 — Ajouter un produit` draws Category and Unit as text fields with
/// placeholder copy in them. On the web both are `<select>` elements. This is
/// the mobile answer to that gap, and the choice made here is a **bottom
/// sheet**, for three reasons:
///
/// - it is the platform's own pattern for choosing one of a list, so it needs
///   no explaining;
/// - the list is unbounded — a merchant's categories are their own words, and
///   the seeded unit list is long — and a sheet scrolls where an inline
///   expansion would push the rest of a nine-field form around;
/// - it mirrors without special-casing: a sheet is a full-width surface, so
///   Arabic gets the same layout with the tick on the other side.
///
/// Visually it *is* the `Text Field`: same label row, same `ink/surface` box
/// at the one control height, same hairline and radius. Only two things
/// differ, and both say "this is a choice, not typing" — a chevron on the
/// trailing edge, and a placeholder that stays `text/muted` until something is
/// chosen.
class AppSelectField<T> extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.options,
    required this.value,
    required this.onChanged,
    this.sheetTitle,
    this.isRequired = false,
    this.errorText,
    this.enabled = true,
  });

  final String label;

  /// Shown, muted, while nothing is selected. `Sans catégorie`.
  final String placeholder;

  final List<SelectOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;

  /// The sheet's heading. Falls back to [label].
  final String? sheetTitle;

  final bool isRequired;
  final String? errorText;

  /// False while the options are still loading, or when there are none to
  /// choose from. The field stays visible and legible — it just does not open
  /// an empty sheet.
  final bool enabled;

  String? get _selectedLabel {
    for (final option in options) {
      if (option.value == value) return option.label;
    }
    return null;
  }

  Future<void> _open(BuildContext context) async {
    if (!enabled || options.isEmpty) return;
    // Unfocus first: a keyboard left up behind the sheet resizes the form
    // underneath it, and the sheet lands on a screen that is still moving.
    FocusManager.instance.primaryFocus?.unfocus();

    final picked = await showModalBottomSheet<SelectOption<T>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PickerSheet<T>(
        title: sheetTitle ?? label,
        options: options,
        selected: value,
      ),
    );
    if (picked != null) onChanged(picked.value);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedLabel;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: label.toUpperCase(),
            children: isRequired
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.accentAlert),
                    ),
                  ]
                : null,
          ),
          style: AppText.labelMeta,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 1.54.w), // 6
        GestureDetector(
          onTap: () => _open(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: AppSize.control,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(
                color: hasError ? AppColors.accentAlert : AppColors.rule,
                width: AppStroke.hairline,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected ?? placeholder,
                    style: AppText.bodyS.copyWith(
                      // Same ramp as the text field: muted while empty, full
                      // white once it holds a value, so "not chosen" and
                      // "chosen" are a whole step apart rather than one shade.
                      color: selected == null
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                AppIcon(
                  AppIcons.chevronDown,
                  size: 4.1.w, // 16
                  // Never flipped. A chevron pointing down means "opens
                  // downwards", which is physical, not linguistic — unlike the
                  // one on a list row, which means "onwards".
                  color: enabled ? AppColors.textMuted : AppColors.rule,
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 1.54.w), // 6
          Text(
            errorText!,
            style: AppText.actionS.copyWith(color: AppColors.accentAlert),
          ),
        ],
      ],
    );
  }
}

/// The sheet itself: a heading, then the options, the chosen one ticked.
class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<SelectOption<T>> options;
  final T? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        // Capped so the sheet never covers the whole screen: the field it
        // belongs to should stay visible above it, which is what makes it
        // obvious what is being chosen.
        constraints: BoxConstraints(maxHeight: 70.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.xs,
                AppSpacing.gutter,
                AppSpacing.md,
              ),
              child: Text(title.toUpperCase(), style: AppText.labelSection),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                itemCount: options.length,
                separatorBuilder: (_, _) => Container(
                  height: AppStroke.hairline,
                  color: AppColors.rule,
                  margin: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                ),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return _OptionRow<T>(
                    option: option,
                    isSelected: option.value == selected,
                    onTap: () => Navigator.of(context).pop(option),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow<T> extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final SelectOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meta = option.meta;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.gutter,
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
                    option.label,
                    style: AppText.bodyS.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (meta != null) ...[
                    SizedBox(height: AppSpacing.xxs),
                    Text(meta.toUpperCase(), style: AppText.labelMicro),
                  ],
                ],
              ),
            ),
            if (isSelected)
              AppIcon(
                AppIcons.check,
                size: 4.1.w, // 16
                color: AppColors.textPrimary,
              ),
          ],
        ),
      ),
    );
  }
}
