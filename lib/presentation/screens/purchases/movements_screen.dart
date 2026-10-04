import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/route_observer.dart';
import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/movement_origin.dart';
import '../../../data/models/product.dart';
import '../../../data/models/stock_overview.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/purchase_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/movements_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/date_picker_sheet.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/list_widgets.dart';
import '../orders/order_status_pill.dart';
import '../sales/sale_widgets.dart';

/// `Movements history` (Figma `677:17509`, `· aucun mouvement` `677:18099`) —
/// the web's `stock/movements`: every stock change, newest first.
///
/// Each row: the product and its sku, when, the type, what caused it, and the
/// signed quantity. A row written by a sale, a purchase or an order opens it
/// (decided 2026-10-04); the API's `reference` is that record's id, and the
/// readable number comes from the reason.
class MovementsScreen extends StatefulWidget {
  const MovementsScreen({super.key});

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> with RouteAware {
  late final MovementsViewModel _model = MovementsViewModel(
    movements: context.read<MovementRepository>(),
    products: context.read<ProductRepository>(),
  );

  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 600) _model.loadMore();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _model.load();
      _model.loadProducts();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) appRouteObserver.subscribe(this, route);
  }

  /// Back from a sale, a purchase or an order opened from a row — any of them
  /// may have moved stock since.
  @override
  void didPopNext() {
    if (mounted) unawaited(_model.load());
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _scroll.dispose();
    _model.dispose();
    super.dispose();
  }

  void _open(OriginLink link) {
    GoRouter.of(context).push(switch (link.target) {
      OriginTarget.sale => Routes.saleOf(link.id),
      OriginTarget.purchase => Routes.purchaseOf(link.id),
      OriginTarget.order => Routes.orderOf(link.id),
    });
  }

  Future<void> _openFilters() async {
    final applied = await showMovementFiltersSheet(
      context,
      current: _model.filters,
      products: _model.products,
    );
    if (applied != null) _model.applyFilters(applied);
  }

  Future<void> _pickDate({required bool start}) async {
    final l10n = L10n.of(context);
    final picked = await showDatePickerSheet(
      context,
      title: start ? l10n.dateFrom : l10n.dateTo,
      initial: start ? _model.startDate : _model.endDate,
    );
    if (picked == null) return;
    start ? _model.setStartDate(picked) : _model.setEndDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _model.load,
            color: AppColors.textPrimary,
            backgroundColor: AppColors.surface,
            child: ListView(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 0.47.h, bottom: AppSpacing.xxl),
              children: _content(l10n),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(L10n l10n) {
    final tag = Localizations.localeOf(context).toLanguageTag();
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight);
    final filters = _model.filters.activeCount;

    return [
      Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.lg),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppBackButton(semanticLabel: l10n.commonBack),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.movementsEyebrow, style: AppText.labelMeta),
            SizedBox(height: 1.54.w),
            Text(l10n.movementsTitle, style: AppText.displayM),
            SizedBox(height: 1.54.w),
            Text(
              l10n.movementsSubtitle,
              style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.32),
            ),
          ],
        ),
      ),
      SizedBox(height: 5.13.w),
      Padding(
        padding: gutter,
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ToolChip(
              icon: AppIcons.filter,
              label: filters > 0 ? l10n.ordersFiltersActive(filters) : l10n.ordersFilters,
              active: filters > 0,
              onTap: _openFilters,
            ),
            ToolChip(
              icon: AppIcons.calendar,
              label: _model.startDate == null
                  ? l10n.dateFrom
                  : formatPickedDay(_model.startDate!, tag),
              active: _model.startDate != null,
              onTap: () => _pickDate(start: true),
              onClear: _model.startDate == null ? null : () => _model.setStartDate(null),
              clearLabel: l10n.dateClear,
            ),
            ToolChip(
              icon: AppIcons.calendar,
              label: _model.endDate == null ? l10n.dateTo : formatPickedDay(_model.endDate!, tag),
              active: _model.endDate != null,
              onTap: () => _pickDate(start: false),
              onClear: _model.endDate == null ? null : () => _model.setEndDate(null),
              clearLabel: l10n.dateClear,
            ),
          ],
        ),
      ),
      SizedBox(height: 5.13.w),
      ..._list(l10n, tag),
    ];
  }

  List<Widget> _list(L10n l10n, String tag) {
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight);
    final rows = _model.movements;

    if (_model.isFirstLoad) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
          child: const SaleSpinner(),
        ),
      ];
    }

    if (rows.isEmpty && _model.error != null) {
      return [
        Padding(
          padding: gutter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ApiErrorLine(error: _model.error),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
              ),
            ],
          ),
        ),
      ];
    }

    if (rows.isEmpty) {
      return [
        Padding(
          padding: gutter,
          child: EmptyBox(
            icon: AppIcons.history,
            title: l10n.movementsEmptyTitle,
            body: _model.isNarrowed ? l10n.movementsNoMatchBody : l10n.movementsEmptyBody,
          ),
        ),
      ];
    }

    return [
      SectionLabel(label: l10n.movementsSection, trailing: '${_model.total}'),
      Padding(
        padding: gutter,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (index, movement) in rows.indexed) ...[
                if (index > 0)
                  const Divider(
                    height: AppStroke.hairline,
                    thickness: AppStroke.hairline,
                    color: AppColors.rule,
                  ),
                _MovementRow(movement: movement, localeTag: tag, onOpen: _open),
              ],
            ],
          ),
        ),
      ),
      if (_model.isLoadingMore)
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: const SaleSpinner(),
        ),
    ];
  }
}

String movementTypeLabel(StockMovementType type, L10n l10n) => switch (type) {
  StockMovementType.stockIn => l10n.stockMoveIn,
  StockMovementType.stockOut => l10n.stockMoveOut,
  StockMovementType.adjustment => l10n.stockMoveAdjustment,
  StockMovementType.returned => l10n.stockMoveReturn,
  StockMovementType.unknown => '—',
};

/// The reason in the merchant's language when the backend wrote it, as typed
/// when the merchant did.
String movementReasonText(MovementOrigin origin, L10n l10n) {
  final n = origin.number ?? '';
  return switch (origin.kind) {
    OriginKind.sale => l10n.movementReasonSale(n),
    OriginKind.saleDeleted => l10n.movementReasonSaleDeleted(n),
    OriginKind.purchase => l10n.movementReasonPurchase(n),
    OriginKind.purchaseCancelled => l10n.movementReasonPurchaseCancelled(n),
    OriginKind.order => l10n.movementReasonOrder(n),
    OriginKind.orderCancelled => l10n.movementReasonOrderCancelled(n),
    OriginKind.orderReturned => l10n.movementReasonOrderReturned(n),
    OriginKind.orderDeleted => l10n.movementReasonOrderDeleted(n),
    OriginKind.initialStock => l10n.movementReasonInitial,
    OriginKind.variantDeleted => l10n.movementReasonVariantDeleted,
    OriginKind.other => origin.raw ?? '—',
  };
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement, required this.localeTag, required this.onOpen});

  final StockMovement movement;
  final String localeTag;
  final ValueChanged<OriginLink> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final origin = MovementOrigin.of(movement);
    final link = origin.linkFor(movement);
    final signed = movement.signedQuantity;
    final date = movement.createdAt;
    final entering =
        movement.type == StockMovementType.stockIn || movement.type == StockMovementType.returned;

    final row = Padding(
      padding: EdgeInsets.all(3.59.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: movement.productName ?? '—', style: AppText.title),
                      if (movement.sku case final sku?)
                        TextSpan(text: '  ${sku.toUpperCase()}', style: AppText.labelMeta),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (date != null) ...[
                  SizedBox(height: 1.03.w),
                  Text(
                    '${formatPickedDay(date.toLocal(), localeTag)}  ·  ${saleTime(date)}',
                    style: AppText.labelMeta,
                  ),
                ],
                SizedBox(height: 1.54.w),
                OrderStatusPill(
                  label: movementTypeLabel(movement.type, l10n),
                  tone: entering ? PillTone.settled : PillTone.moving,
                ),
                SizedBox(height: 1.54.w),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        movementReasonText(origin, l10n),
                        style: AppText.bodyS.copyWith(
                          color: link == null ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (link != null) ...[
                      SizedBox(width: 1.03.w),
                      // Points forward in reading order.
                      Transform.flip(
                        flipX: Directionality.of(context) == TextDirection.rtl,
                        child: AppIcon(
                          AppIcons.chevronRight,
                          size: 3.59.w,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            signed > 0 ? '+$signed' : (signed < 0 ? '−${signed.abs()}' : '0'),
            style: AppText.numeralM.copyWith(
              color: signed < 0 ? AppColors.textMuted : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );

    if (link == null) return row;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: () => onOpen(link),
        behavior: HitTestBehavior.opaque,
        child: row,
      ),
    );
  }
}

/// `Movements history · filtres` (Figma `677:17803`).
Future<MovementFilters?> showMovementFiltersSheet(
  BuildContext context, {
  required MovementFilters current,
  required List<Product> products,
}) {
  return showModalBottomSheet<MovementFilters>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _MovementFiltersSheet(current: current, products: products),
  );
}

class _MovementFiltersSheet extends StatefulWidget {
  const _MovementFiltersSheet({required this.current, required this.products});

  final MovementFilters current;
  final List<Product> products;

  @override
  State<_MovementFiltersSheet> createState() => _MovementFiltersSheetState();
}

class _MovementFiltersSheetState extends State<_MovementFiltersSheet> {
  late StockMovementType? _type = widget.current.type;
  late String? _productId = widget.current.productId;

  MovementFilters get _draft => MovementFilters(type: _type, productId: _productId);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final draft = _draft;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutterTight,
          AppSpacing.sm,
          AppSpacing.gutterTight,
          3.32.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.ordersFilters, style: AppText.title),
            SizedBox(height: AppSpacing.xl),
            Text(l10n.movementsFilterType.toUpperCase(), style: AppText.labelMeta),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 1.54.w,
              runSpacing: 1.54.w,
              children: [
                AppFilterChip(
                  label: l10n.movementsFilterTypeAny,
                  selected: _type == null,
                  onTap: () => setState(() => _type = null),
                ),
                for (final type in [
                  StockMovementType.stockIn,
                  StockMovementType.stockOut,
                  StockMovementType.adjustment,
                  StockMovementType.returned,
                ])
                  AppFilterChip(
                    label: movementTypeLabel(type, l10n),
                    selected: _type == type,
                    onTap: () => setState(() => _type = type),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.xl),
            AppSelectField<String>(
              label: l10n.movementsFilterProduct,
              placeholder: l10n.movementsFilterProductAny,
              sheetTitle: l10n.movementsFilterProduct,
              options: [
                SelectOption(value: '', label: l10n.movementsFilterProductAny),
                for (final p in widget.products) SelectOption(value: p.id, label: p.name),
              ],
              value: _productId ?? '',
              enabled: widget.products.isNotEmpty,
              onChanged: (value) =>
                  setState(() => _productId = value == null || value.isEmpty ? null : value),
            ),
            SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: draft != widget.current ? () => Navigator.of(context).pop(draft) : null,
              child: Text(l10n.ordersFilterApply),
            ),
            SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: widget.current.isEmpty && draft.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(const MovementFilters()),
              child: Text(l10n.ordersFilterClear),
            ),
          ],
        ),
      ),
    );
  }
}
