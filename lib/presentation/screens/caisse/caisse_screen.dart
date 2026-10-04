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
import '../../../data/models/caisse.dart';
import '../../../data/models/sale.dart';
import '../../../data/repositories/caisse_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/caisse_view_model.dart';
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
import '../sales/sale_widgets.dart';
import 'caisse_form_sheet.dart';

/// `Cash register` (Figma `680:17643`, `· aucune transaction` `680:18878`) —
/// the web's `stock/caisse`.
///
/// The period's four figures, a search, *Filtres* and two date chips, then
/// every ledger row: its type and category, the date, what it was, the signed
/// amount, the reference and whether it was posted automatically. A manual
/// row carries edit and delete; an automatic one opens the sale, order or
/// purchase that posted it — it cannot be changed here (the API refuses).
class CaisseScreen extends StatefulWidget {
  const CaisseScreen({super.key});

  @override
  State<CaisseScreen> createState() => _CaisseScreenState();
}

class _CaisseScreenState extends State<CaisseScreen> with RouteAware {
  late final CaisseViewModel _model = CaisseViewModel(caisse: context.read<CaisseRepository>());

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.reload());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) appRouteObserver.subscribe(this, route);
  }

  /// Back from a sale, an order or a purchase opened from an automatic row —
  /// a payment changed there rewrites its row here.
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

  Future<void> _openForm([CaisseTransaction? editing]) async {
    final l10n = L10n.of(context);
    final saved = await showCaisseFormSheet(
      context,
      caisse: context.read<CaisseRepository>(),
      editing: editing,
    );
    if (saved == null || !mounted) return;
    AppToast.success(context, editing == null ? l10n.caisseAddedToast : l10n.caisseUpdatedToast);
    await _model.saved();
  }

  void _openSource(CaisseTransaction row) {
    final id = row.sourceId;
    if (id == null) return;
    final route = switch (row.category) {
      CaisseCategory.sale => Routes.saleOf(id),
      CaisseCategory.order => Routes.orderOf(id),
      CaisseCategory.purchase => Routes.purchaseOf(id),
      _ => null,
    };
    if (route != null) GoRouter.of(context).push(route);
  }

  /// `Delete a transaction` (Figma `680:19900`).
  Future<void> _delete(CaisseTransaction row) async {
    if (_model.isDeleting(row)) return;
    final l10n = L10n.of(context);
    final confirmed = await showDestructiveSheet(
      context,
      title: l10n.caisseDeleteTitle,
      body: l10n.caisseDeleteBody,
      confirmLabel: l10n.commonDelete,
      noticeBody: l10n.purchaseDeleteNotice,
    );
    if (!confirmed || !mounted) return;
    final result = await _model.delete(row);
    if (!mounted) return;
    switch (result.errorOrNull) {
      case null:
        AppToast.success(context, l10n.caisseDeletedToast);
      case NotFoundException():
        AppToast.info(context, l10n.caisseAlreadyGone);
      case final error:
        AppToast.info(context, apiErrorMessage(error, l10n));
    }
  }

  Future<void> _openFilters() async {
    final applied = await showCaisseFiltersSheet(context, current: _model.filters);
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
                child: FilledButton(onPressed: _openForm, child: Text(l10n.caisseAddTitle)),
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
    String figure(double v) => Money.grouped(v.round(), tag);

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
            Text(l10n.caisseEyebrow, style: AppText.labelMeta),
            SizedBox(height: 1.54.w),
            Text(l10n.caisseTitle, style: AppText.displayM),
            SizedBox(height: 1.54.w),
            Text(
              l10n.caisseSubtitle,
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
              (SalePeriod.today, l10n.caissePeriodToday),
              (SalePeriod.week, l10n.caissePeriodWeek),
              (SalePeriod.month, l10n.caissePeriodMonth),
              (SalePeriod.year, l10n.caissePeriodYear),
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
                label: l10n.caisseStatBalance,
                // A negative period reads with its sign — money went out.
                value: stats == null
                    ? dash
                    : (stats.balance < 0 ? '−${figure(-stats.balance)}' : figure(stats.balance)),
                unit: 'DA',
                icon: AppIcons.dollar,
                iconColor: stats != null && stats.balance < 0
                    ? AppColors.accentAlert
                    : AppColors.accentMoney,
              ),
              KpiTile(
                label: l10n.caisseStatIncome,
                value: stats == null ? dash : figure(stats.totalIncome),
                unit: 'DA',
                icon: AppIcons.dollar,
                iconColor: AppColors.accentMoney,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            KpiPair(
              KpiTile(
                label: l10n.caisseStatExpense,
                value: stats == null ? dash : figure(stats.totalExpense),
                unit: 'DA',
                icon: AppIcons.dollar,
                iconColor: AppColors.accentAlert,
              ),
              KpiTile(
                label: l10n.caisseStatCount,
                value: stats == null ? dash : Money.grouped(stats.transactionCount, tag),
                icon: AppIcons.history,
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
          placeholder: l10n.caisseSearch,
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
    final rows = _model.transactions;

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
            icon: AppIcons.dollar,
            title: l10n.caisseEmptyTitle,
            body: _model.isNarrowed ? l10n.caisseNoMatchBody : l10n.caisseEmptyBody,
          ),
        ),
      ];
    }

    return [
      SectionLabel(label: l10n.caisseSection, trailing: '${_model.total}'),
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
              for (final (index, row) in rows.indexed) ...[
                if (index > 0)
                  const Divider(
                    height: AppStroke.hairline,
                    thickness: AppStroke.hairline,
                    color: AppColors.rule,
                  ),
                _CaisseRow(
                  row: row,
                  localeTag: tag,
                  deleting: _model.isDeleting(row),
                  onOpenSource: () => _openSource(row),
                  onEdit: () => _openForm(row),
                  onDelete: () => _delete(row),
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

/// What a row is called: an automatic row by its source and number, as the
/// backend's own description is English (`Sale SL-…`); a manual one by what
/// the merchant wrote, else its reference, else its category.
String caisseRowTitle(CaisseTransaction row, L10n l10n) {
  if (row.isAutomatic) {
    final number = row.reference ?? '';
    switch (row.category) {
      case CaisseCategory.sale:
        return l10n.caisseAutoSale(number);
      case CaisseCategory.order:
        return l10n.caisseAutoOrder(number);
      case CaisseCategory.purchase:
        return l10n.caisseAutoPurchase(number);
      default:
        break;
    }
  }
  return row.description ?? row.reference ?? caisseCategoryLabel(row.category, l10n);
}

class _CaisseRow extends StatelessWidget {
  const _CaisseRow({
    required this.row,
    required this.localeTag,
    required this.deleting,
    required this.onOpenSource,
    required this.onEdit,
    required this.onDelete,
  });

  final CaisseTransaction row;
  final String localeTag;
  final bool deleting;
  final VoidCallback onOpenSource;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final income = row.type == CaisseType.income;
    final amount = Money.exact(row.amount, localeTag);
    // Only an automatic row with a known source leads anywhere.
    final opens =
        row.isAutomatic &&
        row.sourceId != null &&
        (row.category == CaisseCategory.sale ||
            row.category == CaisseCategory.order ||
            row.category == CaisseCategory.purchase);

    final content = Opacity(
      opacity: deleting ? 0.5 : 1,
      child: Padding(
        padding: EdgeInsets.all(3.59.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 1.54.w,
              runSpacing: 1.54.w,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OrderStatusPill(
                  label: caisseTypeLabel(row.type, l10n),
                  tone: income ? PillTone.settled : PillTone.moving,
                ),
                _Tag(label: caisseCategoryLabel(row.category, l10n)),
                Text(formatPickedDay(row.date.toLocal(), localeTag), style: AppText.labelMeta),
              ],
            ),
            SizedBox(height: 1.54.w),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    caisseRowTitle(row, l10n),
                    style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  income ? '+$amount' : '−$amount',
                  style: AppText.numeralM.copyWith(
                    color: income ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.54.w),
            Row(
              children: [
                if (row.reference case final reference?) ...[
                  Flexible(
                    child: Text(
                      l10n.caisseRef(reference).toUpperCase(),
                      style: AppText.labelMeta,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                ],
                _Tag(label: row.isAutomatic ? l10n.caisseAuto : l10n.caisseManual),
                const Spacer(),
                if (deleting)
                  SizedBox.square(dimension: 9.23.w, child: const SaleSpinner(dimension: 18))
                else if (row.isEditable) ...[
                  RowAction(icon: AppIcons.edit, label: l10n.saleEdit, onTap: onEdit),
                  RowAction(icon: AppIcons.trash, label: l10n.commonDelete, onTap: onDelete),
                ] else if (opens)
                  Transform.flip(
                    flipX: Directionality.of(context) == TextDirection.rtl,
                    child: AppIcon(AppIcons.chevronRight, size: 4.1.w, color: AppColors.textMuted),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (!opens || deleting) return content;
    return Semantics(
      button: true,
      child: GestureDetector(onTap: onOpenSource, behavior: HitTestBehavior.opaque, child: content),
    );
  }
}

/// The small boxed word the frame uses for a category and for *AUTO* /
/// *MANUEL*.
class _Tag extends StatelessWidget {
  const _Tag({required this.label});

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

/// `Cash register · filtres` (Figma `680:18536`).
Future<CaisseFilters?> showCaisseFiltersSheet(
  BuildContext context, {
  required CaisseFilters current,
}) {
  return showModalBottomSheet<CaisseFilters>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _CaisseFiltersSheet(current: current),
  );
}

class _CaisseFiltersSheet extends StatefulWidget {
  const _CaisseFiltersSheet({required this.current});

  final CaisseFilters current;

  @override
  State<_CaisseFiltersSheet> createState() => _CaisseFiltersSheetState();
}

class _CaisseFiltersSheetState extends State<_CaisseFiltersSheet> {
  late CaisseType? _type = widget.current.type;
  late CaisseCategory? _category = widget.current.category;

  CaisseFilters get _draft => CaisseFilters(type: _type, category: _category);

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
            Text(l10n.caisseFilterType.toUpperCase(), style: AppText.labelMeta),
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
                for (final type in CaisseType.values)
                  AppFilterChip(
                    label: caisseTypeLabel(type, l10n),
                    selected: _type == type,
                    onTap: () => setState(() => _type = type),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.xl),
            Text(l10n.caisseFilterCategory.toUpperCase(), style: AppText.labelMeta),
            SizedBox(height: AppSpacing.sm),
            // All nine here: filtering is how a merchant finds the automatic
            // sale, order and purchase rows too.
            Wrap(
              spacing: 1.54.w,
              runSpacing: 1.54.w,
              children: [
                AppFilterChip(
                  label: l10n.caisseFilterCategoryAny,
                  selected: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
                for (final category in CaisseCategory.values)
                  AppFilterChip(
                    label: caisseCategoryLabel(category, l10n),
                    selected: _category == category,
                    onTap: () => setState(() => _category = category),
                  ),
              ],
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
                  : () => Navigator.of(context).pop(const CaisseFilters()),
              child: Text(l10n.ordersFilterClear),
            ),
          ],
        ),
      ),
    );
  }
}
