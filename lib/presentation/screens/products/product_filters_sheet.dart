import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/product_filters.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_text_field.dart';

/// The web's products filter panel as a sheet: *Statut*, then selling price,
/// cost price, quantity, net profit and margin, each as a min and a max.
///
/// No Figma frame draws it; it is the clients sheet (`639:10584`) with the
/// web's fields. The web's range sliders became number fields, as they did
/// there. Its category list and *Stock faible uniquement* are not repeated:
/// the chip row on `17` already filters by one category and by low stock.
///
/// Pops the new [ProductFilters], or nothing when dismissed.
Future<ProductFilters?> showProductFiltersSheet(BuildContext context, {required ProductFilters current}) {
  return showModalBottomSheet<ProductFilters>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _ProductFiltersSheet(current: current),
  );
}

class _ProductFiltersSheet extends StatefulWidget {
  const _ProductFiltersSheet({required this.current});

  final ProductFilters current;

  @override
  State<_ProductFiltersSheet> createState() => _ProductFiltersSheetState();
}

class _ProductFiltersSheetState extends State<_ProductFiltersSheet> {
  late ProductStatusFilter _status = widget.current.status;

  late final _minPrice = _field(widget.current.minPrice);
  late final _maxPrice = _field(widget.current.maxPrice);
  late final _minCost = _field(widget.current.minCost);
  late final _maxCost = _field(widget.current.maxCost);
  late final _minQty = _field(widget.current.minQty);
  late final _maxQty = _field(widget.current.maxQty);
  late final _minProfit = _field(widget.current.minProfit);
  late final _maxProfit = _field(widget.current.maxProfit);
  late final _minMargin = _field(widget.current.minMargin);
  late final _maxMargin = _field(widget.current.maxMargin);

  late final List<TextEditingController> _controllers = [
    _minPrice, _maxPrice, _minCost, _maxCost, _minQty, _maxQty, //
    _minProfit, _maxProfit, _minMargin, _maxMargin,
  ];
  late final List<FocusNode> _focus = List.generate(_controllers.length, (_) => FocusNode());

  static TextEditingController _field(num? value) =>
      TextEditingController(text: value == null ? '' : value.round().toString());

  @override
  void initState() {
    super.initState();
    for (final c in _controllers) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  /// A whole number, or null for an empty field — and for a lone `-`, which a
  /// merchant typing a negative bound passes through on the way.
  static int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  ProductFilters get _draft => ProductFilters(
        status: _status,
        minPrice: _int(_minPrice)?.toDouble(),
        maxPrice: _int(_maxPrice)?.toDouble(),
        minCost: _int(_minCost)?.toDouble(),
        maxCost: _int(_maxCost)?.toDouble(),
        minQty: _int(_minQty),
        maxQty: _int(_maxQty),
        minProfit: _int(_minProfit)?.toDouble(),
        maxProfit: _int(_maxProfit)?.toDouble(),
        minMargin: _int(_minMargin)?.toDouble(),
        maxMargin: _int(_maxMargin)?.toDouble(),
      );

  /// A price, cost or quantity maximum of 0 means "no maximum" to the server,
  /// so it cannot be below the minimum. A profit or margin bound is real at
  /// any value.
  static bool _inverted(int? min, int? max, {required bool zeroIsNone}) =>
      min != null && max != null && (!zeroIsNone || max > 0) && min > max;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final draft = _draft;

    final priceBad = _inverted(_int(_minPrice), _int(_maxPrice), zeroIsNone: true);
    final costBad = _inverted(_int(_minCost), _int(_maxCost), zeroIsNone: true);
    final qtyBad = _inverted(_int(_minQty), _int(_maxQty), zeroIsNone: true);
    final profitBad = _inverted(_int(_minProfit), _int(_maxProfit), zeroIsNone: false);
    final marginBad = _inverted(_int(_minMargin), _int(_maxMargin), zeroIsNone: false);
    final anyBad = priceBad || costBad || qtyBad || profitBad || marginBad;

    final digits = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)];
    // Profit and margin run negative — a product sold under its true cost.
    final signed = [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')), LengthLimitingTextInputFormatter(9)];

    Widget range({
      required String minLabel,
      required String maxLabel,
      required TextEditingController min,
      required TextEditingController max,
      required int focusIndex,
      required String minHint,
      required String maxHint,
      required bool bad,
      bool allowNegative = false,
    }) {
      final keyboard = allowNegative
          ? const TextInputType.numberWithOptions(signed: true)
          : TextInputType.number;
      final formatters = allowNegative ? signed : digits;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppTextField(
              label: minLabel,
              controller: min,
              focusNode: _focus[focusIndex],
              placeholder: minHint,
              keyboardType: keyboard,
              textInputAction: TextInputAction.next,
              inputFormatters: formatters,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppTextField(
              label: maxLabel,
              controller: max,
              focusNode: _focus[focusIndex + 1],
              placeholder: maxHint,
              errorText: bad ? l10n.categoriesFilterRangeInvalid : null,
              keyboardType: keyboard,
              textInputAction: focusIndex + 1 == _focus.length - 1 ? TextInputAction.done : TextInputAction.next,
              inputFormatters: formatters,
            ),
          ),
        ],
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(AppSpacing.gutterTight, AppSpacing.sm, AppSpacing.gutterTight, 3.32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.categoriesFilters, style: AppText.title),
              SizedBox(height: AppSpacing.xl),
              Text(l10n.clientsFilterStatus.toUpperCase(), style: AppText.labelMeta),
              SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 1.54.w,
                runSpacing: 1.54.w,
                children: [
                  for (final (value, label) in [
                    (ProductStatusFilter.active, l10n.clientsFilterActive),
                    (ProductStatusFilter.inactive, l10n.clientsFilterInactive),
                  ])
                    AppFilterChip(
                      label: label,
                      selected: _status == value,
                      onTap: () => setState(() => _status = value),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.xl),
              range(
                minLabel: l10n.productsFilterPriceMin,
                maxLabel: l10n.productsFilterPriceMax,
                min: _minPrice,
                max: _maxPrice,
                focusIndex: 0,
                minHint: '0',
                maxHint: '100000',
                bad: priceBad,
              ),
              SizedBox(height: AppSpacing.xl),
              range(
                minLabel: l10n.productsFilterCostMin,
                maxLabel: l10n.productsFilterCostMax,
                min: _minCost,
                max: _maxCost,
                focusIndex: 2,
                minHint: '0',
                maxHint: '100000',
                bad: costBad,
              ),
              SizedBox(height: AppSpacing.xl),
              range(
                minLabel: l10n.productsFilterQtyMin,
                maxLabel: l10n.productsFilterQtyMax,
                min: _minQty,
                max: _maxQty,
                focusIndex: 4,
                minHint: '0',
                maxHint: '10000',
                bad: qtyBad,
              ),
              SizedBox(height: AppSpacing.xl),
              range(
                minLabel: l10n.productsFilterProfitMin,
                maxLabel: l10n.productsFilterProfitMax,
                min: _minProfit,
                max: _maxProfit,
                focusIndex: 6,
                minHint: '-50000',
                maxHint: '50000',
                bad: profitBad,
                allowNegative: true,
              ),
              SizedBox(height: AppSpacing.xl),
              range(
                minLabel: l10n.productsFilterMarginMin,
                maxLabel: l10n.productsFilterMarginMax,
                min: _minMargin,
                max: _maxMargin,
                focusIndex: 8,
                minHint: '-100',
                maxHint: '100',
                bad: marginBad,
                allowNegative: true,
              ),
              SizedBox(height: AppSpacing.xxl),
              FilledButton(
                onPressed: draft != widget.current && !anyBad ? () => Navigator.of(context).pop(draft) : null,
                child: Text(l10n.categoriesFilterApply),
              ),
              SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: widget.current.isEmpty && draft.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(const ProductFilters()),
                child: Text(l10n.categoriesFilterClear),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
