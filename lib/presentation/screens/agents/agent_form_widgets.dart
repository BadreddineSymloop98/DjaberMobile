import 'package:flutter/material.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_icon.dart';

/// The pieces of `15b — Partir de zéro`. The web form is two desktop columns of
/// cards; on a phone it is one column, its long tail folded into [FoldGroup].
///
/// Everything stays inside the frozen style: `ink/surface`, hairlines, radius
/// 8, emphasis by weight and opacity. The two controls the file had no
/// component for — a switch and a slider — are drawn from the same tokens:
/// white means on, `line/lit` means the track.

/// A form section's heading — `Display/S`, the way `14c` heads its sections.
class FormSectionTitle extends StatelessWidget {
  const FormSectionTitle(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final note = subtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppText.displayS),
        if (note != null) ...[
          SizedBox(height: AppSpacing.xs),
          Text(note, style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32)),
        ],
      ],
    );
  }
}

/// A hairline box of rows — the folds on `ink/surface`, the page and product
/// pickers unfilled inside them.
class FoldGroup extends StatelessWidget {
  const FoldGroup({super.key, required this.children, this.filled = true});

  final List<Widget> children;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: filled ? AppColors.surface : Colors.transparent,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

/// One folding section: module icon, title, its current value in mono, and a
/// chevron that turns when open. The value is why a fold can stay closed —
/// the merchant sees what will be sent without opening it.
class FoldSection extends StatelessWidget {
  const FoldSection({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.summary,
    required this.expanded,
    required this.onToggle,
    required this.child,
    this.first = false,
  });

  final List<String> icon;
  final Color iconColor;
  final String title;
  final String summary;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  /// The first row draws no divider above itself.
  final bool first;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: first ? null : const Border(top: BorderSide(color: AppColors.rule, width: AppStroke.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: expanded,
            child: GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 3.59.w), // 16 · 14
                child: Row(
                  children: [
                    AppIcon(icon, size: 5.13.w, color: iconColor), // 20
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(title, style: AppText.title),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            summary.toUpperCase(),
                            style: AppText.labelMeta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: AppIcon(AppIcons.chevronDown, size: 4.10.w, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xxs, AppSpacing.lg, AppSpacing.lg),
              child: child,
            ),
        ],
      ),
    );
  }
}

/// A single-choice card — the personality grid and the model list. Selection
/// is the border (`line/lit`) plus a tick, like the web's `border-white/40`
/// and `CheckCircleIcon`.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.description,
    this.note,
    this.filled = true,
  });

  final String title;
  final String? description;

  /// A mono figure on the description line — the model's cost.
  final String? note;
  final bool selected;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final detail = description;
    final figure = note;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: filled ? AppColors.surface : Colors.transparent,
            border: Border.all(color: selected ? AppColors.ruleStrong : AppColors.rule, width: AppStroke.hairline),
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
                      title,
                      style: AppText.title.copyWith(color: selected ? AppColors.textPrimary : AppColors.textSecondary),
                    ),
                  ),
                  if (selected) AppIcon(AppIcons.check, size: 3.59.w, color: AppColors.textPrimary),
                ],
              ),
              if (detail != null || figure != null) ...[
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        detail ?? '',
                        style: AppText.bodyS.copyWith(
                          color: selected ? AppColors.textSecondary : AppColors.textMuted,
                          height: 1.32,
                        ),
                      ),
                    ),
                    if (figure != null) ...[
                      SizedBox(width: AppSpacing.sm),
                      Text(figure, style: AppText.labelMicro),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// On: a white track with an ink knob at the end. Off: `line/lit` with a
/// white knob at the start. Mirrors with the layout, as the frames do.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 10.26.w, // 40
      height: 6.15.w, // 24
      padding: EdgeInsets.all(0.77.w), // 3
      decoration: BoxDecoration(
        color: value ? AppColors.textPrimary : AppColors.ruleStrong,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 160),
        alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        child: Container(
          width: 4.62.w, // 18
          height: 4.62.w,
          decoration: BoxDecoration(color: value ? AppColors.ink : AppColors.textPrimary, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

/// A whole-row toggle with its explanation — the web's Image Recognition,
/// Voice Notes and Sell All Products rows. The row is the hit target.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: AppText.title),
                    SizedBox(height: AppSpacing.xs),
                    Text(description, style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32)),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              AppSwitch(value: value),
            ],
          ),
        ),
      ),
    );
  }
}

/// A labelled slider with its value in `Numeral/M` and the two ends named —
/// the web's Temperature and Response Delay.
class LabeledSlider extends StatelessWidget {
  const LabeledSlider({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.startLabel,
    required this.endLabel,
    this.hint,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final String startLabel;
  final String endLabel;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final note = hint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: Text(label.toUpperCase(), style: AppText.labelMeta)),
            Text(valueLabel, style: AppText.numeralM),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: AppColors.textPrimary,
            inactiveTrackColor: AppColors.ruleStrong,
            thumbColor: AppColors.textPrimary,
            overlayColor: AppColors.rule,
            activeTickMarkColor: Colors.transparent,
            inactiveTickMarkColor: Colors.transparent,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            semanticFormatterCallback: (_) => valueLabel,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(startLabel, style: AppText.labelMeta),
            Text(endLabel, style: AppText.labelMeta),
          ],
        ),
        if (note != null) ...[
          SizedBox(height: AppSpacing.sm),
          Text(note, style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32)),
        ],
      ],
    );
  }
}

/// The multi-select tick. Radius 2, as the `Checkbox` component keeps it small.
class CheckSquare extends StatelessWidget {
  const CheckSquare({super.key, required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 4.62.w, // 18
      height: 4.62.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value ? AppColors.textPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: value ? AppColors.textPrimary : AppColors.ruleStrong, width: AppStroke.hairline),
      ),
      child: value ? AppIcon(AppIcons.check, size: 3.08.w, color: AppColors.ink, strokeWidth: 3) : null,
    );
  }
}

/// A square hairline tile for a page mark or a product photo.
class ThumbBox extends StatelessWidget {
  const ThumbBox({super.key, required this.size, required this.child, this.imageUrl});

  final double size;
  final Widget child;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: url == null
          ? child
          : Image.network(url, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, _, _) => child),
    );
  }
}

/// A picker row: thumb, name, mono meta, and a tick. With no [onTap] it is
/// shown but cannot be chosen — a page another agent already holds.
class SelectRow extends StatelessWidget {
  const SelectRow({
    super.key,
    required this.leading,
    required this.title,
    required this.meta,
    required this.selected,
    required this.onTap,
    this.first = false,
  });

  final Widget leading;
  final String title;
  final String meta;
  final bool selected;
  final VoidCallback? onTap;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Semantics(
        selected: selected,
        enabled: enabled,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: first ? null : const Border(top: BorderSide(color: AppColors.rule, width: AppStroke.hairline)),
            ),
            child: Row(
              children: [
                leading,
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppText.title.copyWith(
                          color: !enabled
                              ? AppColors.textMuted
                              : selected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(meta.toUpperCase(), style: AppText.labelMeta, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (enabled) ...[
                  SizedBox(width: AppSpacing.sm),
                  CheckSquare(value: selected),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A tag the merchant taps to insert into the product template.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.56.w, vertical: 1.54.w), // 10 · 6
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Text(label, style: AppText.bodyS.copyWith(color: AppColors.textSecondary)),
        ),
      ),
    );
  }
}

/// The web's live preview: a customer asks, the agent answers with the
/// template filled from a real product, product cards drawn where the tag is.
///
/// **Both tag spellings split the reply.** The web's chip inserts
/// `[PRODUCT_CARD]` but its preview only splits on `[PRODUCT_CARD:…]`, so a
/// merchant's own template previews the tag as literal text there.
class TemplatePreview extends StatelessWidget {
  const TemplatePreview({
    super.key,
    required this.template,
    required this.fallback,
    required this.customerMessage,
    required this.liveLabel,
    required this.productName,
    required this.productPrice,
    required this.productPriceLabel,
    required this.productDescription,
    required this.productStock,
    this.imageUrl,
  });

  final String template;

  /// Shown when [template] is blank — the agent's default style.
  final String fallback;
  final String customerMessage;
  final String liveLabel;
  final String productName;

  /// The bare figure `{price}` becomes, since templates write the currency.
  final String productPrice;

  /// The figure with its currency, for the card.
  final String productPriceLabel;
  final String productDescription;
  final String productStock;
  final String? imageUrl;

  static final _card = RegExp(r'\[PRODUCT_CARD(?::[^\]]*)?\]');

  @override
  Widget build(BuildContext context) {
    final source = template.trim().isEmpty ? fallback : template.trim();
    final text = source
        .replaceAll('{name}', productName)
        .replaceAll('{price}', productPrice)
        .replaceAll('{description}', productDescription)
        .replaceAll('{stock}', productStock);
    final parts = text.split(_card);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ink,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 6.15.w,
                height: 6.15.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                ),
                child: Text('C', style: AppText.labelMeta.copyWith(color: AppColors.textSecondary)),
              ),
              SizedBox(width: AppSpacing.sm),
              Flexible(child: _Bubble(customerMessage)),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < parts.length; i++) ...[
                if (parts[i].trim().isNotEmpty)
                  Padding(padding: EdgeInsets.only(bottom: AppSpacing.sm), child: _Bubble(parts[i].trim())),
                if (i < parts.length - 1)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _ProductCard(name: productName, price: productPriceLabel, imageUrl: imageUrl),
                  ),
              ],
            ],
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.56.w, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Text(liveLabel.toUpperCase(), style: AppText.labelMicro),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 62.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.56.w, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Text(text, style: AppText.bodyS.copyWith(color: AppColors.textPrimary, height: 1.32)),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.name, required this.price, this.imageUrl});

  final String name;
  final String price;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final placeholder = AppIcon(AppIcons.box, size: 6.15.w, color: AppColors.textMuted);
    return Container(
      width: 46.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 18.46.w, // 72
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.rule, width: AppStroke.hairline)),
            ),
            child: url == null
                ? placeholder
                : Image.network(url, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, _, _) => placeholder),
          ),
          Padding(
            padding: EdgeInsets.all(2.56.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: AppText.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: AppSpacing.xxs),
                Text(price, style: AppText.labelMeta.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
