import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/route_observer.dart';
import '../../../app/routes.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/order.dart';
import '../../../data/models/purchase.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/supplier.dart';
import '../../../data/repositories/purchase_repository.dart';
import '../../../data/repositories/supplier_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/purchases_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/date_picker_sheet.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import '../../widgets/list_widgets.dart';
import '../orders/order_status_pill.dart';
import '../sales/sale_widgets.dart';
import 'purchase_widgets.dart';

/// `Purchases list` (Figma `672:16477`, `· aucun achat` `672:18532`) — the
/// web's `stock/purchases`.
///
/// The period's four figures, a search, the three quick payment chips,
/// *Filtres* and two date chips, then one card per purchase: number and date,
/// the supplier, the goods and the money as two pills, the money line, *Voir*,
/// *Réceptionner* while goods are still to come, and the trash only on a
/// purchase the API lets go (pending, nothing paid, nothing received).
class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> with RouteAware {
  late final PurchasesViewModel _model = PurchasesViewModel(
    purchases: context.read<PurchaseRepository>(),
    suppliers: context.read<SupplierRepository>(),
  );

  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  final _scroll = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () => _model.setSearch(_search.text));
    });
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 600) _model.loadMore();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _model.reload();
      _model.loadSuppliers();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) appRouteObserver.subscribe(this, route);
  }

  /// Back from a new purchase or a detail — either may have changed the list
  /// and the figures.
  @override
  void didPopNext() {
    if (mounted) unawaited(_model.reload());
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _debounce?.cancel();
    _search.dispose();
    _searchFocus.dispose();
    _scroll.dispose();
    _model.dispose();
    super.dispose();
  }

  void _openDetail(Purchase purchase) =>
      GoRouter.of(context).push(Routes.purchaseOf(purchase.id), extra: purchase);

  void _openNew() => GoRouter.of(context).push(Routes.purchaseNew);

  Future<void> _openFilters() async {
    final applied = await showPurchaseFiltersSheet(
      context,
      current: _model.filters,
      suppliers: _model.suppliers,
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

  /// `Receive items` straight from the row; the row updates in place.
  Future<void> _receive(Purchase purchase) async {
    final updated = await showReceiveSheet(context, purchase: purchase);
    if (updated != null && mounted) _model.replace(updated);
  }

  /// `Delete a purchase` (Figma `673:17419`).
  Future<void> _delete(Purchase purchase) async {
    if (_model.isDeleting(purchase)) return;
    final l10n = L10n.of(context);
    final confirmed = await showDestructiveSheet(
      context,
      title: l10n.purchaseDeleteTitle,
      body: l10n.purchaseDeleteBody(purchase.purchaseNumber),
      confirmLabel: l10n.commonDelete,
      noticeBody: l10n.purchaseDeleteNotice,
    );
    if (!confirmed || !mounted) return;
    final result = await _model.delete(purchase);
    if (!mounted) return;
    switch (result.errorOrNull) {
      case null:
        AppToast.success(context, l10n.purchaseDeletedToast(purchase.purchaseNumber));
      case NotFoundException():
        AppToast.info(context, l10n.purchaseAlreadyGone(purchase.purchaseNumber));
      case final error:
        // A 400: it was paid or received since the list loaded.
        AppToast.info(context, apiErrorMessage(error, l10n));
        unawaited(_model.load());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _model.reload,
                  color: AppColors.textPrimary,
                  backgroundColor: AppColors.surface,
                  child: ListView(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 0.47.h, bottom: AppSpacing.lg),
                    children: _content(l10n),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutterTight,
                  AppSpacing.md,
                  AppSpacing.gutterTight,
                  AppSpacing.md,
                ),
                child: FilledButton(onPressed: _openNew, child: Text(l10n.purchasesNew)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(L10n l10n) {
    final tag = Localizations.localeOf(context).toLanguageTag();
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight);
    final stats = _model.stats;
    final filters = _model.filters.activeCount;
    const dash = '—';

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
            Text(l10n.purchasesEyebrow, style: AppText.labelMeta),
            SizedBox(height: 1.54.w),
            Text(l10n.purchasesTitle, style: AppText.displayM),
            SizedBox(height: 1.54.w),
            Text(
              l10n.purchasesCount(_model.total),
              style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      SizedBox(height: 5.13.w),
      SizedBox(
        height: 9.5.w,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
          children: [
            for (final (period, label) in [
              (SalePeriod.today, l10n.salesPeriodToday),
              (SalePeriod.week, l10n.salesPeriodWeek),
              (SalePeriod.month, l10n.salesPeriodMonth),
              (SalePeriod.year, l10n.salesPeriodYear),
            ])
              Padding(
                padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
                child: AppFilterChip(
                  label: label,
                  selected: _model.period == period,
                  onTap: () => _model.setPeriod(period),
                ),
              ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.md),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          children: [
            KpiPair(
              KpiTile(
                label: l10n.purchasesStatTotal,
                value: stats == null ? dash : Money.grouped(stats.totalPurchases, tag),
                icon: AppIcons.truck,
                iconColor: AppColors.accentOrders,
              ),
              KpiTile(
                label: l10n.purchasesStatSpent,
                value: stats == null ? dash : Money.grouped(stats.totalSpent.round(), tag),
                unit: 'DA',
                icon: AppIcons.dollar,
                iconColor: AppColors.accentMoney,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            KpiPair(
              KpiTile(
                label: l10n.purchasesStatToReceive,
                value: stats == null ? dash : Money.grouped(stats.pendingPurchases, tag),
                icon: AppIcons.alert,
                iconColor: AppColors.accentMoney,
              ),
              KpiTile(
                label: l10n.purchasesStatReceived,
                value: stats == null ? dash : Money.grouped(stats.receivedPurchases, tag),
                icon: AppIcons.box,
                iconColor: AppColors.accentStarred,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 5.13.w),
      Padding(
        padding: gutter,
        child: AppTextField(
          label: l10n.productsSearchLabel,
          controller: _search,
          focusNode: _searchFocus,
          placeholder: l10n.purchasesSearch,
          textInputAction: TextInputAction.search,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
          onSubmitted: (_) => _searchFocus.unfocus(),
        ),
      ),
      SizedBox(height: AppSpacing.lg),
      Padding(
        padding: gutter,
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final (quick, label) in [
              (PurchaseQuickFilter.all, l10n.purchasesQuickAll),
              (PurchaseQuickFilter.paid, l10n.purchasesQuickPaid),
              (PurchaseQuickFilter.toPay, l10n.purchasesQuickToPay),
            ])
              AppFilterChip(
                label: label,
                selected: _model.isQuickSelected(quick),
                onTap: () => _model.setQuick(quick),
              ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.md),
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
    final purchases = _model.purchases;

    if (_model.isFirstLoad) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
          child: const SaleSpinner(),
        ),
      ];
    }

    if (purchases.isEmpty && _model.error != null) {
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

    if (purchases.isEmpty) {
      return [
        Padding(
          padding: gutter,
          child: EmptyBox(
            icon: AppIcons.truck,
            title: l10n.purchasesEmptyTitle,
            body: _model.isNarrowed ? l10n.purchasesNoMatchBody : l10n.purchasesEmptyBody,
          ),
        ),
      ];
    }

    return [
      SectionLabel(label: l10n.purchasesSection, trailing: '${_model.total}'),
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
              for (final (index, purchase) in purchases.indexed) ...[
                if (index > 0)
                  const Divider(
                    height: AppStroke.hairline,
                    thickness: AppStroke.hairline,
                    color: AppColors.rule,
                  ),
                _PurchaseCard(
                  purchase: purchase,
                  localeTag: tag,
                  deleting: _model.isDeleting(purchase),
                  onOpen: () => _openDetail(purchase),
                  onReceive: () => _receive(purchase),
                  onDelete: () => _delete(purchase),
                ),
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

/// One purchase in the list.
class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({
    required this.purchase,
    required this.localeTag,
    required this.deleting,
    required this.onOpen,
    required this.onReceive,
    required this.onDelete,
  });

  final Purchase purchase;
  final String localeTag;
  final bool deleting;
  final VoidCallback onOpen;
  final VoidCallback onReceive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    String money(double v) => Money.exact(v, localeTag);
    final p = purchase;

    return GestureDetector(
      onTap: deleting ? null : onOpen,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: deleting ? 0.5 : 1,
        child: Padding(
          padding: EdgeInsets.all(3.59.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      p.purchaseNumber,
                      style: AppText.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    formatPickedDay(p.purchaseDate.toLocal(), localeTag),
                    style: AppText.labelMeta,
                  ),
                ],
              ),
              SizedBox(height: 1.54.w),
              Text(
                p.supplierName ?? '—',
                style: AppText.bodyS.copyWith(
                  color: p.supplierName == null ? AppColors.textMuted : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.54.w),
              Wrap(
                spacing: 1.54.w,
                runSpacing: 1.54.w,
                children: [
                  purchaseStatusPill(p.status, l10n),
                  purchasePayPill(p.paymentStatus, l10n),
                ],
              ),
              SizedBox(height: 1.54.w),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      l10n.purchasesRowMeta(
                        l10n.ordersRowItems(p.itemCount).toUpperCase(),
                        money(p.amountPaid),
                        money(p.remaining),
                      ),
                      style: AppText.labelMeta,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    money(p.total),
                    style: AppText.numeralM.copyWith(
                      // A cancelled purchase owes nothing; its figure is a record.
                      color: p.status == PurchaseStatus.cancelled ? AppColors.textMuted : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.54.w),
              Row(
                children: [
                  SaleRowButton(label: l10n.salesView, onTap: deleting ? null : onOpen),
                  if (p.canReceive) ...[
                    SizedBox(width: 1.54.w),
                    SaleRowButton(label: l10n.purchasesReceive, onTap: deleting ? null : onReceive),
                  ],
                  const Spacer(),
                  if (deleting)
                    SizedBox.square(dimension: 9.23.w, child: const SaleSpinner(dimension: 18))
                  else if (p.canDelete)
                    RowAction(icon: AppIcons.trash, label: l10n.commonDelete, onTap: onDelete),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `Purchases list · filtres` (Figma `672:18146`).
Future<PurchaseFilters?> showPurchaseFiltersSheet(
  BuildContext context, {
  required PurchaseFilters current,
  required List<Supplier> suppliers,
}) {
  return showModalBottomSheet<PurchaseFilters>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _PurchaseFiltersSheet(current: current, suppliers: suppliers),
  );
}

class _PurchaseFiltersSheet extends StatefulWidget {
  const _PurchaseFiltersSheet({required this.current, required this.suppliers});

  final PurchaseFilters current;
  final List<Supplier> suppliers;

  @override
  State<_PurchaseFiltersSheet> createState() => _PurchaseFiltersSheetState();
}

class _PurchaseFiltersSheetState extends State<_PurchaseFiltersSheet> {
  late PurchaseStatus? _status = widget.current.status;
  late PaymentStatus? _payment = widget.current.payment;
  late String? _supplierId = widget.current.supplierId;
  late bool _hasRemaining = widget.current.hasRemaining;
  late final _min = TextEditingController(text: widget.current.minTotal?.round().toString() ?? '');
  late final _max = TextEditingController(
    text: widget.current.maxTotal == null || widget.current.maxTotal! >= PurchaseFilters.maxCeiling
        ? ''
        : widget.current.maxTotal!.round().toString(),
  );
  final _minFocus = FocusNode();
  final _maxFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    for (final c in [_min, _max]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    _minFocus.dispose();
    _maxFocus.dispose();
    super.dispose();
  }

  static double? _amount(TextEditingController c) => int.tryParse(c.text.trim())?.toDouble();

  PurchaseFilters get _draft => PurchaseFilters(
    status: _status,
    payment: _payment,
    supplierId: _supplierId,
    hasRemaining: _hasRemaining,
    minTotal: _amount(_min),
    maxTotal: _amount(_max),
  );

  void _toggleRemaining() => setState(() => _hasRemaining = !_hasRemaining);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final draft = _draft;
    final min = _amount(_min);
    final max = _amount(_max);
    final rangeBad = min != null && max != null && min > max;
    final digits = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)];
    // A supplier filtered on but since archived still shows as chosen.
    final suppliers = [
      for (final s in widget.suppliers)
        if (s.isActive || s.id == _supplierId) s,
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
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
              Text(l10n.purchasesFilterStatus.toUpperCase(), style: AppText.labelMeta),
              SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 1.54.w,
                runSpacing: 1.54.w,
                children: [
                  AppFilterChip(
                    label: l10n.ordersFilterAny,
                    selected: _status == null,
                    onTap: () => setState(() => _status = null),
                  ),
                  for (final status in PurchaseStatus.values)
                    AppFilterChip(
                      label: purchaseStatusLabel(status, l10n),
                      selected: _status == status,
                      onTap: () => setState(() => _status = status),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.xl),
              Text(l10n.salePaymentStatus.toUpperCase(), style: AppText.labelMeta),
              SizedBox(height: AppSpacing.sm),
              // Greyed rather than hidden: the server ignores it while *Reste
              // à payer* is on.
              Opacity(
                opacity: _hasRemaining ? 0.4 : 1,
                child: IgnorePointer(
                  ignoring: _hasRemaining,
                  child: Wrap(
                    spacing: 1.54.w,
                    runSpacing: 1.54.w,
                    children: [
                      AppFilterChip(
                        label: l10n.ordersFilterAny,
                        selected: _payment == null,
                        onTap: () => setState(() => _payment = null),
                      ),
                      for (final status in [
                        PaymentStatus.pending,
                        PaymentStatus.partial,
                        PaymentStatus.paid,
                      ])
                        AppFilterChip(
                          label: purchasePayLabel(status, l10n),
                          selected: _payment == status,
                          onTap: () => setState(() => _payment = status),
                        ),
                    ],
                  ),
                ),
              ),
              if (_hasRemaining) ...[
                SizedBox(height: AppSpacing.xs),
                Text(l10n.ordersFilterPaymentDisabled, style: AppText.labelMicro),
              ],
              SizedBox(height: AppSpacing.xl),
              AppSelectField<String>(
                label: l10n.purchaseFieldSupplier,
                placeholder: l10n.purchasesFilterSupplierAny,
                sheetTitle: l10n.purchaseFieldSupplier,
                options: [
                  SelectOption(value: '', label: l10n.purchasesFilterSupplierAny),
                  for (final s in suppliers) SelectOption(value: s.id, label: s.name),
                ],
                value: _supplierId ?? '',
                enabled: suppliers.isNotEmpty,
                onChanged: (value) =>
                    setState(() => _supplierId = value == null || value.isEmpty ? null : value),
              ),
              SizedBox(height: AppSpacing.xl),
              GestureDetector(
                onTap: _toggleRemaining,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    OrderTick(
                      checked: _hasRemaining,
                      onTap: _toggleRemaining,
                      label: l10n.purchasesFilterHasRemaining,
                    ),
                    SizedBox(width: 1.28.w),
                    Expanded(child: Text(l10n.purchasesFilterHasRemaining, style: AppText.bodyS)),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: l10n.ordersFilterTotalMin,
                      controller: _min,
                      focusNode: _minFocus,
                      placeholder: '0',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: digits,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextField(
                      label: l10n.ordersFilterTotalMax,
                      controller: _max,
                      focusNode: _maxFocus,
                      placeholder: '1000000',
                      errorText: rangeBad ? l10n.categoriesFilterRangeInvalid : null,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: digits,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xxl),
              FilledButton(
                onPressed: draft != widget.current && !rangeBad
                    ? () => Navigator.of(context).pop(draft)
                    : null,
                child: Text(l10n.ordersFilterApply),
              ),
              SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: widget.current.isEmpty && draft.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(const PurchaseFilters()),
                child: Text(l10n.ordersFilterClear),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
