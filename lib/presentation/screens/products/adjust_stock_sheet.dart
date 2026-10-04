import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/adjust_stock_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_text_field.dart';

/// `Adjust stock` (Figma `614:6794`) — a sheet over `17a — Détail du produit`.
///
/// The frame draws the **variant** form, which is the harder of the two: one
/// card per variant, each with its own type chips, quantity and reason. A
/// product without variants gets the same card once, for the product itself —
/// the web's `showAdjust.hasVariants ? … : …`, and the only shape the backend
/// accepts in each case.
///
/// **Only the lines with a quantity are sent**, which is what makes a
/// five-variant sheet usable: the merchant fills in the one size they counted.
/// *Fixer* to `0` counts as filled — unlike the web, which ignored it — so
/// "this size is sold out" can be said directly. See `AdjustRow.isFilled`.
///
/// Returns `true` when something was applied, so the screen underneath reloads.
Future<bool> showAdjustStockSheet(
  BuildContext context, {
  required ProductRepository products,
  required Product product,
}) async {
  final applied = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    // The variant form can be taller than half the screen, and the keyboard
    // takes the rest.
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
    ),
    builder: (sheet) => _AdjustStockSheet(products: products, product: product),
  );
  return applied ?? false;
}

class _AdjustStockSheet extends StatefulWidget {
  const _AdjustStockSheet({required this.products, required this.product});

  final ProductRepository products;
  final Product product;

  @override
  State<_AdjustStockSheet> createState() => _AdjustStockSheetState();
}

class _AdjustStockSheetState extends State<_AdjustStockSheet> {
  late final AdjustStockViewModel _model = AdjustStockViewModel(
    products: widget.products,
    product: widget.product,
  );

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final ok = await _model.apply();
    if (!ok || !mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final product = widget.product;
    final unit = product.unitAbbreviation?.trim();

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => SafeArea(
        child: Padding(
          // Lifts the whole sheet clear of the keyboard.
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: ConstrainedBox(
            // Never taller than most of the screen; the cards scroll inside.
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.86),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // No grab handle drawn here: the app theme's bottom sheet
                // (`showDragHandle: true`) already draws the frame's handle.
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.gutterTight,
                    AppSpacing.xl,
                    AppSpacing.gutterTight,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.stockAdjustTitle, style: AppText.title),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        // `Robe satin — Noir · Stock actuel : 15 pcs`
                        l10n.stockAdjustSubtitle(
                          product.name,
                          '${product.quantity}${unit == null || unit.isEmpty ? '' : ' $unit'}',
                        ),
                        style: AppText.bodyS.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.gutterTight,
                      AppSpacing.md,
                      AppSpacing.gutterTight,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < _model.rows.length; i++) ...[
                          if (i > 0) SizedBox(height: AppSpacing.sm),
                          _AdjustCard(
                            model: _model,
                            row: _model.rows[i],
                            // The single-product card has the name in the
                            // subtitle already; its header would repeat it.
                            showLabel: _model.isVariantForm,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.gutterTight,
                    AppSpacing.md,
                    AppSpacing.gutterTight,
                    3.32.h, // 28
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ApiErrorLine(error: _model.submitError),
                      if (_model.showNothingToApply)
                        Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Text(
                            l10n.stockAdjustNothing,
                            textAlign: TextAlign.center,
                            style: AppText.actionS.copyWith(color: AppColors.accentAlert),
                          ),
                        ),
                      FilledButton(
                        // Disabled only while sending: each line is its own
                        // request, and a second tap mid-flight would replay the
                        // ones already applied.
                        onPressed: _model.isBusy ? null : _apply,
                        child: _model.isBusy
                            ? SizedBox.square(
                                dimension: AppSpacing.gutterTight,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.ink,
                                ),
                              )
                            : Text(l10n.stockAdjustSubmit),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      OutlinedButton(
                        onPressed: _model.isBusy
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Text(l10n.commonCancel),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One adjustable line: the header with the stock it holds, the three type
/// chips, then the quantity and the reason side by side.
class _AdjustCard extends StatelessWidget {
  const _AdjustCard({
    required this.model,
    required this.row,
    required this.showLabel,
  });

  final AdjustStockViewModel model;
  final AdjustRow row;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final exceeds = model.showsExceeds(row);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        // ink/3 — a card inside a surface, one step lighter so it separates
        // from the sheet it sits on.
        color: const Color(0xFF141414),
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showLabel) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    row.label,
                    style: AppText.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.stockAdjustCurrent(row.currentQuantity),
                  style: AppText.labelMeta,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
          ],
          // The three types as the file's `Tab`: filled white when active,
          // hairline outline when not. Wrapped rather than a Row so the three
          // labels still fit when a translation runs long.
          Wrap(
            spacing: 1.54.w, // 6
            runSpacing: 1.54.w,
            children: [
              for (final (type, label) in [
                (StockAdjustType.stockIn, l10n.stockAdjustIn),
                (StockAdjustType.stockOut, l10n.stockAdjustOut),
                (StockAdjustType.set, l10n.stockAdjustSet),
              ])
                _TypeChip(
                  label: label,
                  selected: row.type == type,
                  onTap: model.isBusy ? null : () => model.setType(row, type),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: l10n.productVariantQuantity,
                  controller: row.quantity,
                  focusNode: row.quantityFocus,
                  placeholder: l10n.productVariantQuantity,
                  errorText: exceeds
                      ? l10n.stockAdjustInsufficient(row.currentQuantity)
                      : null,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  // Digits only: a decimal reaches an Int column and comes
                  // back as a 500 rather than a 400.
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  label: l10n.stockAdjustReason,
                  controller: row.reason,
                  focusNode: row.reasonFocus,
                  placeholder: l10n.stockAdjustReason,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [LengthLimitingTextInputFormatter(255)],
                ),
              ),
            ],
          ),
          if (row.isFilled && !exceeds) ...[
            SizedBox(height: AppSpacing.sm),
            Text(
              l10n.stockAdjustResult(row.resultingQuantity),
              style: AppText.labelMicro,
            ),
          ],
        ],
      ),
    );
  }
}

/// The file's `Tab` component: a filled white chip when active, a hairline
/// outline when not.
class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md, // 12
            vertical: AppSpacing.sm, // 8
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.textPrimary : Colors.transparent,
            border: Border.all(
              color: selected ? AppColors.textPrimary : AppColors.rule,
              width: AppStroke.hairline,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Text(
            label,
            style: AppText.bodyS.copyWith(
              color: selected ? AppColors.ink : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
