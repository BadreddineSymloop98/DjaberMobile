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
import '../../../data/models/sale.dart';
import '../../../data/repositories/sale_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/sales_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/date_picker_sheet.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import '../../widgets/list_widgets.dart';
import '../orders/order_status_pill.dart';
import 'sale_widgets.dart';

/// `Sales list` (Figma `667:15497`, `· aucune vente` `669:16196`) — the web's
/// `stock/sales`.
///
/// The period's four figures, a search, the three quick payment chips,
/// *Filtres* and two date chips, then one card per sale: its number and date,
/// the customer, the payment pill and method, the money line, *Voir*, and the
/// trash — only on a sale with nothing received, the one kind the API lets go.
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> with RouteAware {
  late final SalesViewModel _model = SalesViewModel(sales: context.read<SaleRepository>());

  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  final _scroll = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      _debounce?.cancel();
      // The web's own 300 ms: a request per keystroke is slow and costly on
      // the connections this market runs on.
      _debounce = Timer(const Duration(milliseconds: 300), () => _model.setSearch(_search.text));
    });
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 600) _model.loadMore();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.reload());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) appRouteObserver.subscribe(this, route);
  }

  /// Back from a new sale, a detail or an edit — any of them may have changed
  /// the list and the figures.
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

  void _openDetail(Sale sale) => GoRouter.of(context).push(Routes.saleOf(sale.id), extra: sale);

  void _openNew() => GoRouter.of(context).push(Routes.saleNew);

  Future<void> _openFilters() async {
    final applied = await showSaleFiltersSheet(context, current: _model.filters);
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

  /// `Delete a sale` (Figma `670:16505`).
  Future<void> _delete(Sale sale) async {
    if (_model.isDeleting(sale)) return;
    final l10n = L10n.of(context);
    final confirmed = await showDestructiveSheet(
      context,
      title: l10n.saleDeleteTitle,
      body: l10n.saleDeleteBody(sale.saleNumber),
      confirmLabel: l10n.commonDelete,
      // A partial sale's money leaves the caisse with it — said first.
      noticeBody: [
        if (sale.needsPaymentReset)
          l10n.saleDeleteMoney(
            Money.exact(sale.amountPaid, Localizations.localeOf(context).toLanguageTag()),
          ),
        l10n.saleDeleteNotice,
      ].join('\n\n'),
    );
    if (!confirmed || !mounted) return;
    final result = await _model.delete(sale);
    if (!mounted) return;
    switch (result.errorOrNull) {
      case null:
        AppToast.success(context, l10n.saleDeletedToast(sale.saleNumber));
      case NotFoundException():
        AppToast.info(context, l10n.saleAlreadyGone(sale.saleNumber));
      case final error:
        // A 400: it was fully paid since the list loaded.
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
                child: FilledButton(onPressed: _openNew, child: Text(l10n.salesNew)),
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
            Text(l10n.salesEyebrow, style: AppText.labelMeta),
            SizedBox(height: 1.54.w),
            Text(l10n.salesTitle, style: AppText.displayM),
            SizedBox(height: 1.54.w),
            Text(
              l10n.salesCount(_model.total),
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
                label: l10n.salesStatTotal,
                value: stats == null ? dash : Money.grouped(stats.totalSales, tag),
                icon: AppIcons.shoppingCart,
                iconColor: AppColors.accentOrders,
              ),
              KpiTile(
                label: l10n.salesStatRevenue,
                value: stats == null ? dash : Money.grouped(stats.totalRevenue.round(), tag),
                unit: 'DA',
                icon: AppIcons.dollar,
                iconColor: AppColors.accentMoney,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            KpiPair(
              KpiTile(
                label: l10n.salesStatAverage,
                value: stats == null ? dash : Money.grouped(stats.averageOrderValue.round(), tag),
                unit: 'DA',
                icon: AppIcons.chart,
                iconColor: AppColors.accentStarred,
              ),
              KpiTile(
                label: l10n.salesStatPending,
                value: stats == null ? dash : Money.grouped(stats.pendingSales, tag),
                icon: AppIcons.clock,
                iconColor: AppColors.accentAlert,
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
          placeholder: l10n.salesSearch,
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
              (SaleQuickFilter.all, l10n.salesQuickAll),
              (SaleQuickFilter.paid, l10n.salesQuickPaid),
              (SaleQuickFilter.remaining, l10n.salesQuickRemaining),
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
    final sales = _model.sales;

    if (_model.isFirstLoad) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
          child: const SaleSpinner(),
        ),
      ];
    }

    if (sales.isEmpty && _model.error != null) {
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

    if (sales.isEmpty) {
      return [
        Padding(
          padding: gutter,
          child: EmptyBox(
            icon: AppIcons.shoppingCart,
            title: l10n.salesEmptyTitle,
            body: _model.isNarrowed ? l10n.salesNoMatchBody : l10n.salesEmptyBody,
          ),
        ),
      ];
    }

    return [
      SectionLabel(label: l10n.salesSection, trailing: '${_model.total}'),
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
              for (final (index, sale) in sales.indexed) ...[
                if (index > 0)
                  const Divider(
                    height: AppStroke.hairline,
                    thickness: AppStroke.hairline,
                    color: AppColors.rule,
                  ),
                _SaleCard(
                  sale: sale,
                  localeTag: tag,
                  deleting: _model.isDeleting(sale),
                  onOpen: () => _openDetail(sale),
                  onDelete: () => _delete(sale),
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

/// One sale in the list.
class _SaleCard extends StatelessWidget {
  const _SaleCard({
    required this.sale,
    required this.localeTag,
    required this.deleting,
    required this.onOpen,
    required this.onDelete,
  });

  final Sale sale;
  final String localeTag;
  final bool deleting;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    String money(double v) => Money.exact(v, localeTag);

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
                      sale.saleNumber,
                      style: AppText.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    formatPickedDay(sale.saleDate.toLocal(), localeTag),
                    style: AppText.labelMeta,
                  ),
                ],
              ),
              SizedBox(height: 1.54.w),
              Text(
                sale.customerName ?? '—',
                style: AppText.bodyS.copyWith(
                  color: sale.customerName == null ? AppColors.textMuted : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.54.w),
              Row(
                children: [
                  salePaymentPill(sale.paymentStatus, l10n),
                  SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      saleMethodLabel(sale, l10n).toUpperCase(),
                      style: AppText.labelMeta,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.54.w),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      l10n.ordersRowMeta(
                        l10n.ordersRowItems(sale.itemCount).toUpperCase(),
                        money(sale.amountPaid),
                        money(sale.remaining),
                      ),
                      style: AppText.labelMeta,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(money(sale.total), style: AppText.numeralM),
                ],
              ),
              SizedBox(height: 1.54.w),
              Row(
                children: [
                  SaleRowButton(label: l10n.salesView, onTap: deleting ? null : onOpen),
                  const Spacer(),
                  if (deleting)
                    SizedBox.square(dimension: 9.23.w, child: const SaleSpinner(dimension: 18))
                  else if (sale.canDelete)
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

/// `Sales list · filtres` (Figma `669:15576`).
Future<SaleFilters?> showSaleFiltersSheet(BuildContext context, {required SaleFilters current}) {
  return showModalBottomSheet<SaleFilters>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _SaleFiltersSheet(current: current),
  );
}

class _SaleFiltersSheet extends StatefulWidget {
  const _SaleFiltersSheet({required this.current});

  final SaleFilters current;

  @override
  State<_SaleFiltersSheet> createState() => _SaleFiltersSheetState();
}

class _SaleFiltersSheetState extends State<_SaleFiltersSheet> {
  late PaymentStatus? _payment = widget.current.payment;
  late PaymentMethod? _method = widget.current.method;
  late bool _hasRemaining = widget.current.hasRemaining;
  late final _min = TextEditingController(text: widget.current.minTotal?.round().toString() ?? '');
  late final _max = TextEditingController(
    text: widget.current.maxTotal == null || widget.current.maxTotal! >= SaleFilters.maxCeiling
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

  SaleFilters get _draft => SaleFilters(
    payment: _payment,
    method: _method,
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
              Text(l10n.salePaymentStatus.toUpperCase(), style: AppText.labelMeta),
              SizedBox(height: AppSpacing.sm),
              // Greyed rather than hidden: the server ignores it while *Solde
              // restant* is on.
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
                        PaymentStatus.paid,
                        PaymentStatus.pending,
                        PaymentStatus.partial,
                      ])
                        AppFilterChip(
                          label: saleStatusLabel(status, l10n),
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
              Text(l10n.saleFieldMethod.toUpperCase(), style: AppText.labelMeta),
              SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 1.54.w,
                runSpacing: 1.54.w,
                children: [
                  AppFilterChip(
                    label: l10n.salesFilterMethodAny,
                    selected: _method == null,
                    onTap: () => setState(() => _method = null),
                  ),
                  for (final method in PaymentMethod.values)
                    AppFilterChip(
                      label: paymentMethodLabel(method, l10n),
                      selected: _method == method,
                      onTap: () => setState(() => _method = method),
                    ),
                ],
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
                      label: l10n.ordersFilterHasRemaining,
                    ),
                    SizedBox(width: 1.28.w),
                    Expanded(child: Text(l10n.ordersFilterHasRemaining, style: AppText.bodyS)),
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
                    : () => Navigator.of(context).pop(const SaleFilters()),
                child: Text(l10n.ordersFilterClear),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
