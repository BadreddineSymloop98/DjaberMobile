import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/route_observer.dart';
import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/phone.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/orders_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/date_picker_sheet.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/leave_sheet.dart';
import '../../widgets/list_widgets.dart';
import 'order_status_pill.dart';

/// `Orders list` (Figma `649:11305`) — the web's `stock/orders`, and the CMD
/// tab of the bottom nav.
///
/// Four server figures, the eight status tabs, a search, *Filtres* and two
/// date chips, then one card per order: its number and source, the client,
/// two pills, the money line, and the **one action that status deserves** —
/// *Appeler et confirmer* on a new order, *Préparer* on a confirmed one, and
/// so on down to *Ouvrir* once there is nothing left to do.
///
/// **Selection is the second way to work.** Ticking rows swaps the New-order
/// button for a bulk bar offering only the moves every selected order can
/// legally make — the intersection, so a bar that appears always works.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final OrdersViewModel _model =
      OrdersViewModel(orders: context.read<OrderRepository>());

  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      _debounce?.cancel();
      // 300ms, the web's own debounce: a request per keystroke is slow and
      // expensive on the connections this market runs on.
      _debounce = Timer(const Duration(milliseconds: 300), () => _model.setSearch(_search.text));
    });
    // Refreshes when a screen pushed from here closes — a new order, or one
    // confirmed on the detail screen. Through the shell, not [appRouteObserver]
    // directly: this list is a **tab**, and a tab never hears a pop on the root
    // navigator (see [shellReturns]). Subscribing to the observer from here
    // silently did nothing, which is why a new order did not appear until the
    // list was pulled down.
    shellReturns.addListener(_onReturn);
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.reload());
  }

  void _onReturn() {
    if (mounted) unawaited(_model.reload());
  }

  @override
  void dispose() {
    shellReturns.removeListener(_onReturn);
    _debounce?.cancel();
    _search.dispose();
    _searchFocus.dispose();
    _model.dispose();
    super.dispose();
  }

  void _openDetail(Order order) {
    GoRouter.of(context).push(Routes.orderOf(order.id), extra: order);
  }

  void _openNew() => GoRouter.of(context).push(Routes.orderNew);

  Future<void> _openFilters() async {
    final applied = await showOrderFiltersSheet(context, current: _model.filters);
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

  /// The row's one button. Everything it can do is a status move except the
  /// two ends: a new order has to be called first, and a finished one only
  /// opens.
  Future<void> _primaryAction(Order order) async {
    switch (order.status) {
      case OrderStatus.pending:
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
      case OrderStatus.returned:
        _openDetail(order);
      case OrderStatus.confirmed:
        await _move(order, OrderStatus.preparing);
      case OrderStatus.preparing:
        await _move(order, OrderStatus.shipped);
      case OrderStatus.shipped:
        await _move(order, OrderStatus.delivered);
    }
  }

  Future<void> _move(Order order, OrderStatus status) async {
    final l10n = L10n.of(context);
    final result = await _model.setStatus(order, status);
    if (!mounted) return;
    if (result.errorOrNull case final error?) {
      AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    AppToast.success(context, l10n.orderStatusChangedToast);
  }

  Future<void> _markReturned(Order order) async {
    final l10n = L10n.of(context);
    final confirmed = await showDestructiveSheet(
      context,
      title: l10n.orderReturnTitle,
      body: l10n.orderReturnBody(order.orderNumber),
      confirmLabel: l10n.orderReturnTitle,
      // The backend zeroes the payment and deletes the caisse rows, but it
      // does not move any money. Saying so here is the difference between a
      // merchant who refunds the customer and one who thinks it was handled.
      noticeTitle: l10n.orderReturnNoticeTitle,
      noticeBody: l10n.orderReturnNoticeBody,
    );
    if (!confirmed || !mounted) return;
    final result = await _model.setStatus(order, OrderStatus.returned);
    if (!mounted) return;
    if (result.errorOrNull case final error?) {
      AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    AppToast.success(context, l10n.orderReturnedToast);
  }

  Future<void> _delete(Order order) async {
    final l10n = L10n.of(context);
    final confirmed = await showDestructiveSheet(
      context,
      title: l10n.orderDeleteTitle,
      body: l10n.orderDeleteBody(order.orderNumber),
      confirmLabel: l10n.commonDelete,
      noticeBody: l10n.orderDeleteNoticeBody,
    );
    if (!confirmed || !mounted) return;
    final result = await _model.delete(order);
    if (!mounted) return;
    if (result.errorOrNull case final error?) {
      AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    AppToast.success(context, l10n.orderDeletedToast);
  }

  Future<void> _bulk(OrderStatus status) async {
    final l10n = L10n.of(context);
    final count = _model.selectedCount;
    final failed = await _model.applyBulk(status);
    if (!mounted) return;
    if (failed > 0) {
      AppToast.info(context, l10n.ordersBulkFailed(failed, count));
      return;
    }
    AppToast.success(context, l10n.orderStatusChangedToast);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.ink,
        resizeToAvoidBottomInset: true,
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
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 0.47.h, bottom: AppSpacing.lg),
                    children: _content(l10n),
                  ),
                ),
              ),
              _footer(l10n),
            ],
          ),
        ),
      ),
    );
  }

  /// The New-order button, or the bulk bar while rows are ticked. The frame
  /// puts the bar here, above the nav, rather than sticky at the top as the
  /// web has it: on a handset the thumb is at the bottom.
  Widget _footer(L10n l10n) {
    final padding = EdgeInsets.fromLTRB(
      AppSpacing.gutterTight,
      AppSpacing.md,
      AppSpacing.gutterTight,
      AppSpacing.md,
    );

    if (_model.selectedCount == 0) {
      return Padding(
        padding: padding,
        child: FilledButton(onPressed: _openNew, child: Text(l10n.ordersNew)),
      );
    }

    final allowed = _model.bulkAllowed;
    final labels = <OrderStatus, String>{
      OrderStatus.confirmed: l10n.ordersBulkConfirm,
      OrderStatus.preparing: l10n.ordersBulkPrepare,
      OrderStatus.shipped: l10n.ordersBulkShip,
      OrderStatus.delivered: l10n.ordersBulkDeliver,
      OrderStatus.returned: l10n.ordersBulkReturn,
      OrderStatus.cancelled: l10n.ordersBulkCancel,
    };
    // Cancelling and returning are the destructive pair, so they stay
    // outlined however few buttons there are — the loud one is never a move
    // that restocks the order.
    bool subtle(OrderStatus s) =>
        s == OrderStatus.cancelled || s == OrderStatus.returned;
    final primary = allowed.where((s) => !subtle(s)).firstOrNull;

    return Container(
      padding: padding,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.rule, width: AppStroke.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.ordersSelectedCount(_model.selectedCount), style: AppText.title),
              ),
              GestureDetector(
                onTap: _model.clearSelection,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  child: Text(
                    l10n.ordersClearSelection,
                    style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (allowed.isEmpty)
            Text(
              l10n.ordersBulkNone,
              style: AppText.bodyS.copyWith(color: AppColors.textMuted),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final status in allowed)
                  if (status == primary)
                    FilledButton(
                      onPressed: () => _bulk(status),
                      child: Text(labels[status]!),
                    )
                  else
                    OutlinedButton(
                      onPressed: () => _bulk(status),
                      child: Text(labels[status]!),
                    ),
              ],
            ),
        ],
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
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ordersEyebrow, style: AppText.labelMeta),
            SizedBox(height: 1.54.w),
            Text(l10n.ordersTitle, style: AppText.displayM),
            SizedBox(height: 1.54.w),
            Text(
              l10n.ordersCount(_model.total),
              style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      SizedBox(height: 5.13.w),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          children: [
            KpiPair(
              KpiTile(
                label: l10n.ordersStatTotal,
                value: stats == null ? dash : Money.grouped(stats.totalOrders, tag),
                icon: AppIcons.clipboard,
                iconColor: AppColors.accentOrders,
              ),
              KpiTile(
                label: l10n.ordersStatPending,
                value: stats == null ? dash : Money.grouped(stats.pending, tag),
                icon: AppIcons.clock,
                iconColor: AppColors.accentMoney,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            KpiPair(
              KpiTile(
                label: l10n.ordersStatDelivered,
                value: stats == null ? dash : Money.grouped(stats.delivered, tag),
                icon: AppIcons.checkCircle,
                iconColor: AppColors.accentMoney,
              ),
              KpiTile(
                label: l10n.ordersStatValue,
                value: stats == null ? dash : Money.grouped(stats.totalRevenue.round(), tag),
                unit: 'DA',
                icon: AppIcons.dollar,
                iconColor: AppColors.accentStarred,
              ),
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
            for (final (status, label) in <(OrderStatus?, String)>[
              (null, l10n.orderStatusAll),
              for (final s in OrderStatus.values) (s, orderStatusLabel(s, l10n)),
            ])
              Padding(
                padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
                child: AppFilterChip(
                  label: _tabLabel(label, status, l10n),
                  selected: _model.tab == status,
                  onTap: () => _model.setTab(status),
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
          placeholder: l10n.ordersSearch,
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
            ToolChip(
              icon: AppIcons.filter,
              label: filters > 0 ? l10n.ordersFiltersActive(filters) : l10n.ordersFilters,
              active: filters > 0,
              onTap: _openFilters,
            ),
            ToolChip(
              icon: AppIcons.calendar,
              label: _model.startDate == null ? l10n.dateFrom : formatPickedDay(_model.startDate!, tag),
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

  /// The active tab carries its own count, which is the server's figure for
  /// that status rather than the page's length.
  String _tabLabel(String label, OrderStatus? status, L10n l10n) {
    if (_model.tab != status) return label;
    final count = _model.stats?.countFor(status) ?? _model.total;
    return l10n.orderConfirmWithCount(label, count);
  }

  List<Widget> _list(L10n l10n, String tag) {
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight);
    final orders = _model.orders;

    if (_model.isFirstLoad) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
          child: const Center(
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
            ),
          ),
        ),
      ];
    }

    if (orders.isEmpty && _model.error != null) {
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

    if (orders.isEmpty) {
      return [
        Padding(
          padding: gutter,
          child: EmptyBox(
            icon: AppIcons.clipboard,
            title: l10n.ordersEmptyTitle,
            body: _model.isNarrowed ? l10n.ordersNoMatchBody : l10n.ordersEmptyBody,
          ),
        ),
      ];
    }

    return [
      SectionLabel(label: l10n.ordersSection, trailing: '${orders.length}'),
      Padding(
        padding: EdgeInsets.only(bottom: 2.56.w),
        child: Row(
          children: [
            SizedBox(width: AppSpacing.md),
            OrderTick(
              checked: _model.allSelected,
              onTap: _model.toggleAll,
              label: l10n.ordersSelectAll,
            ),
            SizedBox(width: 1.28.w),
            Text(
              l10n.ordersSelectAll,
              style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
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
              for (final (index, order) in orders.indexed) ...[
                if (index > 0)
                  const Divider(
                    height: AppStroke.hairline,
                    thickness: AppStroke.hairline,
                    color: AppColors.rule,
                  ),
                _OrderCard(
                  order: order,
                  selected: _model.isSelected(order.id),
                  localeTag: tag,
                  onToggle: () => _model.toggle(order.id),
                  onOpen: () => _openDetail(order),
                  onPrimary: () => _primaryAction(order),
                  onMarkReturned: () => _markReturned(order),
                  onDelete: () => _delete(order),
                ),
              ],
            ],
          ),
        ),
      ),
    ];
  }
}

/// One order in the list.
class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.selected,
    required this.localeTag,
    required this.onToggle,
    required this.onOpen,
    required this.onPrimary,
    required this.onMarkReturned,
    required this.onDelete,
  });

  final Order order;
  final bool selected;
  final String localeTag;
  final VoidCallback onToggle;
  final VoidCallback onOpen;
  final VoidCallback onPrimary;
  final VoidCallback onMarkReturned;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    String money(double v) => Money.exact(v, localeTag);
    final items = l10n.ordersRowItems(order.itemCount).toUpperCase();

    return Padding(
      padding: EdgeInsets.all(3.59.w), // 14
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderTick(
            checked: selected,
            onTap: onToggle,
            label: order.orderNumber,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: GestureDetector(
              onTap: onOpen,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(order.orderNumber, style: AppText.title),
                      if (order.source == OrderSource.ai) ...[
                        SizedBox(width: 1.54.w),
                        _SourceTag(label: l10n.orderSourceAi),
                      ],
                      const Spacer(),
                      Text(formatPickedDay(order.orderDate, localeTag), style: AppText.labelMeta),
                    ],
                  ),
                  SizedBox(height: 1.54.w),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          order.clientName,
                          style: AppText.bodyS,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (order.clientPhone case final phone?) ...[
                        SizedBox(width: AppSpacing.sm),
                        Text(Phone.format(phone), style: AppText.labelMeta),
                      ],
                    ],
                  ),
                  SizedBox(height: 1.54.w),
                  Wrap(
                    spacing: 1.54.w,
                    runSpacing: 1.54.w,
                    children: [
                      OrderStatusPill.status(order.status, l10n),
                      OrderStatusPill.confirmation(order, l10n),
                    ],
                  ),
                  SizedBox(height: 1.54.w),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.ordersRowMeta(
                            items,
                            money(order.amountPaid),
                            order.remaining > 0 ? money(order.remaining) : l10n.ordersRowNoRemaining,
                          ),
                          style: AppText.labelMeta,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(money(order.total), style: AppText.numeralM),
                    ],
                  ),
                  SizedBox(height: 1.54.w),
                  Row(
                    children: [
                      _RowButton(label: _primaryLabel(l10n), onTap: onPrimary),
                      if (order.canMarkReturned) ...[
                        SizedBox(width: 1.54.w),
                        _RowButton(
                          label: l10n.orderActionMarkReturned,
                          onTap: onMarkReturned,
                          quiet: true,
                        ),
                      ],
                      const Spacer(),
                      if (order.canDelete)
                        RowAction(
                          icon: AppIcons.trash,
                          label: l10n.orderActionDelete,
                          onTap: onDelete,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The web's per-status label, and the reason a row needs only one button:
  /// at any moment there is exactly one thing the merchant would do next.
  String _primaryLabel(L10n l10n) => switch (order.status) {
        OrderStatus.pending => order.confirmationStatus == ConfirmationStatus.notCalled
            ? l10n.orderActionCallConfirm
            : l10n.orderActionRetry,
        OrderStatus.confirmed => l10n.orderActionPrepare,
        OrderStatus.preparing => l10n.orderActionMarkShipped,
        OrderStatus.shipped => l10n.orderActionMarkDelivered,
        _ => l10n.orderActionOpen,
      };
}

class _SourceTag extends StatelessWidget {
  const _SourceTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.28.w, vertical: 0.51.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(1.03.w),
      ),
      child: Text(label.toUpperCase(), style: AppText.labelMicro),
    );
  }
}

/// A row's small outlined button. Smaller than the form buttons on purpose —
/// five of them stacked in a list must not read as five calls to action.
class _RowButton extends StatelessWidget {
  const _RowButton({required this.label, required this.onTap, this.quiet = false});

  final String label;
  final VoidCallback onTap;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.56.w, vertical: 1.54.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: quiet ? AppColors.rule : AppColors.ruleStrong,
              width: AppStroke.hairline,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Text(
            label,
            style: AppText.bodyS.copyWith(
              color: quiet ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// `Orders list · filtres` (Figma `649:12698`).
Future<OrderFilters?> showOrderFiltersSheet(
  BuildContext context, {
  required OrderFilters current,
}) {
  return showModalBottomSheet<OrderFilters>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _OrderFiltersSheet(current: current),
  );
}

class _OrderFiltersSheet extends StatefulWidget {
  const _OrderFiltersSheet({required this.current});

  final OrderFilters current;

  @override
  State<_OrderFiltersSheet> createState() => _OrderFiltersSheetState();
}

class _OrderFiltersSheetState extends State<_OrderFiltersSheet> {
  late ConfirmationStatus? _confirmation = widget.current.confirmation;
  late PaymentStatus? _payment = widget.current.payment;
  late bool _hasRemaining = widget.current.hasRemaining;
  late final _min = TextEditingController(text: widget.current.minTotal?.round().toString() ?? '');
  late final _max = TextEditingController(
    text: widget.current.maxTotal == null || widget.current.maxTotal! >= OrderFilters.maxCeiling
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

  static double? _amount(TextEditingController c) {
    final value = int.tryParse(c.text.trim());
    return value?.toDouble();
  }

  OrderFilters get _draft => OrderFilters(
        confirmation: _confirmation,
        payment: _payment,
        hasRemaining: _hasRemaining,
        minTotal: _amount(_min),
        maxTotal: _amount(_max),
      );

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
              Text(l10n.ordersFilterConfirmation.toUpperCase(), style: AppText.labelMeta),
              SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 1.54.w,
                runSpacing: 1.54.w,
                children: [
                  AppFilterChip(
                    label: l10n.ordersFilterAny,
                    selected: _confirmation == null,
                    onTap: () => setState(() => _confirmation = null),
                  ),
                  for (final status in ConfirmationStatus.values)
                    AppFilterChip(
                      label: orderConfirmationLabel(status, l10n),
                      selected: _confirmation == status,
                      onTap: () => setState(() => _confirmation = status),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.xl),
              Text(l10n.ordersFilterPayment.toUpperCase(), style: AppText.labelMeta),
              SizedBox(height: AppSpacing.sm),
              // Greyed rather than hidden: the server ignores this filter while
              // *Solde restant* is on, and a control that silently stops
              // applying is worse than one that says it is off.
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
                      for (final status in PaymentStatus.values)
                        AppFilterChip(
                          label: paymentStatusLabel(status, l10n),
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
              GestureDetector(
                onTap: () => setState(() => _hasRemaining = !_hasRemaining),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    OrderTick(
                      checked: _hasRemaining,
                      onTap: () => setState(() => _hasRemaining = !_hasRemaining),
                      label: l10n.ordersFilterHasRemaining,
                    ),
                    SizedBox(width: 1.28.w),
                    Text(l10n.ordersFilterHasRemaining, style: AppText.bodyS),
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
                    : () => Navigator.of(context).pop(const OrderFilters()),
                child: Text(l10n.ordersFilterClear),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
