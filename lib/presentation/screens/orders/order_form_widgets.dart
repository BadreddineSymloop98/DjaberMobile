import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/new_order_view_model.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/list_widgets.dart';

// The pieces *Nouvelle commande* and *Nouvelle vente* share: the chosen
// client, the search dropdowns, the dashed placeholder and the line card.

/// The chosen client, with the × the frame draws beside the name.
class ChosenChip extends StatelessWidget {
  const ChosenChip({super.key, required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.bodyS)),
          RowAction(icon: AppIcons.close, label: label, onTap: onClear),
        ],
      ),
    );
  }
}

/// The dropdown under a search field.
class PickerSuggestions extends StatelessWidget {
  const PickerSuggestions({super.key, required this.children, required this.empty});

  final List<Widget> children;
  final String empty;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: children.isEmpty
          ? Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(empty, style: AppText.bodyS.copyWith(color: AppColors.textMuted)),
            )
          : Column(children: children),
    );
  }
}

class SuggestionRow extends StatelessWidget {
  const SuggestionRow({
    super.key,
    required this.title,
    this.meta,
    this.trailing,
    this.trailingMeta,
    required this.onTap,
    this.indented = false,
    this.disabled = false,
  });

  final String title;
  final String? meta;
  final String? trailing;
  final String? trailingMeta;
  final VoidCallback onTap;
  final bool indented;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: Semantics(
        button: true,
        enabled: !disabled,
        child: GestureDetector(
          onTap: disabled ? null : onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              indented ? AppSpacing.xxl : AppSpacing.md,
              2.56.w,
              AppSpacing.md,
              2.56.w,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppText.bodyS, maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (meta case final meta?) ...[
                        SizedBox(height: 0.77.w),
                        Text(meta, style: AppText.labelMeta),
                      ],
                    ],
                  ),
                ),
                if (trailing != null || trailingMeta != null) ...[
                  SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (trailing case final trailing?) Text(trailing, style: AppText.bodyS),
                      if (trailingMeta case final trailingMeta?) ...[
                        SizedBox(height: 0.77.w),
                        Text(trailingMeta, style: AppText.labelMicro),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The dashed "nothing here yet" box the frame draws where the lines go.
class DashedBox extends StatelessWidget {
  const DashedBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 6.15.w, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: child,
    );
  }
}

/// One product line: quantity and unit price are editable, the line total is
/// not — it is the product of the two.
class DraftLineCard extends StatefulWidget {
  const DraftLineCard({
    super.key,
    required this.index,
    required this.line,
    required this.localeTag,
    required this.onRemove,
    required this.onQuantity,
    required this.onPrice,
    this.priceLabel,
    this.limitStock = true,
  });

  final int index;
  final OrderDraftLine line;
  final String localeTag;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantity;
  final ValueChanged<double> onPrice;

  /// The price field's label — a purchase line is a unit **cost**.
  final String? priceLabel;

  /// False on a purchase: buying more than is in stock is the point.
  final bool limitStock;

  @override
  State<DraftLineCard> createState() => _DraftLineCardState();
}

class _DraftLineCardState extends State<DraftLineCard> {
  late final _qty = TextEditingController(text: '${widget.line.quantity}');
  late final _price = TextEditingController(text: widget.line.unitPrice.round().toString());
  final _qtyFocus = FocusNode();
  final _priceFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _qty.addListener(() => widget.onQuantity(int.tryParse(_qty.text.trim()) ?? 1));
    _price.addListener(() => widget.onPrice(double.tryParse(_price.text.trim()) ?? 0));
  }

  @override
  void dispose() {
    _qty.dispose();
    _price.dispose();
    _qtyFocus.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final over = widget.limitStock && widget.line.quantity > widget.line.available;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: over ? AppColors.accentAlert : AppColors.rule,
          width: AppStroke.hairline,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${widget.index + 1}', style: AppText.labelMeta),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.line.name,
                  style: AppText.bodyS,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              RowAction(
                icon: AppIcons.trash,
                label: widget.line.name,
                onTap: widget.onRemove,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 20.5.w,
                child: AppTextField(
                  label: l10n.newOrderQty,
                  controller: _qty,
                  focusNode: _qtyFocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  label: widget.priceLabel ?? l10n.newOrderUnitPrice,
                  controller: _price,
                  focusNode: _priceFocus,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    LengthLimitingTextInputFormatter(12),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.newOrderLineTotal.toUpperCase(), style: AppText.labelMicro),
                  SizedBox(height: 0.77.w),
                  Text(
                    Money.exact(widget.line.total, widget.localeTag),
                    style: AppText.numeralM,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
