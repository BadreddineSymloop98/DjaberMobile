import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/supplier.dart';
import '../../../data/repositories/supplier_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/suppliers_view_model.dart';
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
import 'supplier_form_sheet.dart';

/// `Suppliers list` (Figma `644:10517`) — the web's `stock/suppliers` page.
///
/// Count, three figures (total, active, with purchases), one search, *Filtres*
/// and the two date chips, then one row per supplier: initials, name and
/// status, phone · e-mail, address, purchases and total spent, and edit +
/// delete. A row tap opens the details.
///
/// **Deleting keeps the row.** The backend's delete is soft and the list
/// returns inactive suppliers too, so a deleted supplier stays, marked
/// *INACTIF* — as on the web.
class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  late final SuppliersViewModel _model = SuppliersViewModel(suppliers: context.read<SupplierRepository>());

  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () => _model.setSearch(_search.text));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _searchFocus.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _openForm([Supplier? editing]) async {
    final l10n = L10n.of(context);
    final saved = await showSupplierFormSheet(
      context,
      suppliers: context.read<SupplierRepository>(),
      knownNames: _model.knownNames,
      editing: editing,
    );
    if (saved == null || !mounted) return;
    AppToast.success(context, editing == null ? l10n.supplierAdded : l10n.supplierUpdated);
    await _model.load();
  }

  Future<void> _openDetails(Supplier supplier) async {
    final changed = await GoRouter.of(context).push<bool>(
      Routes.supplierOf(supplier.id),
      // The backend has no read-one route: hand the row over so the details
      // show at once. The details screen re-reads the list when it has none.
      extra: supplier,
    );
    if (changed == true && mounted) await _model.load();
  }

  Future<void> _delete(Supplier supplier) async {
    final l10n = L10n.of(context);
    final confirmed = await confirmSupplierDelete(context, supplier);
    if (!confirmed || !mounted) return;
    final result = await _model.delete(supplier);
    if (!mounted) return;
    if (result.errorOrNull case final error?) {
      AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    AppToast.success(context, l10n.supplierDeleted);
  }

  Future<void> _openFilters() async {
    final applied = await showSupplierFiltersSheet(context, current: _model.filters);
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
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.gutterTight, 0.47.h, AppSpacing.gutter, AppSpacing.lg),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppBackButton(semanticLabel: l10n.commonBack),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _model.load,
                  color: AppColors.textPrimary,
                  backgroundColor: AppColors.surface,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: AppSpacing.lg),
                    children: _content(l10n),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.gutterTight, AppSpacing.md, AppSpacing.gutterTight, 3.32.h),
                child: FilledButton(onPressed: _openForm, child: Text(l10n.supplierAddTitle)),
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
    final filters = _model.filters.activeCount;

    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.suppliersEyebrow, style: AppText.labelMeta),
            SizedBox(height: 1.54.w),
            Text(l10n.suppliersTitle, style: AppText.displayM),
            SizedBox(height: 1.54.w),
            Text(
              l10n.suppliersCount(_model.totalCount),
              style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      SizedBox(height: 10.26.w),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          children: [
            KpiPair(
              KpiTile(
                label: l10n.suppliersStatTotal,
                value: Money.grouped(_model.totalCount, tag),
                icon: AppIcons.users,
                iconColor: AppColors.accentMoney,
              ),
              KpiTile(
                label: l10n.clientsStatActive,
                value: Money.grouped(_model.activeCount, tag),
                icon: AppIcons.checkCircle,
                iconColor: AppColors.accentMoney,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            KpiTile(
              label: l10n.suppliersStatWithPurchases,
              value: Money.grouped(_model.withPurchasesCount, tag),
              icon: AppIcons.truck,
              iconColor: AppColors.accentMoney,
            ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.xl),
      Padding(
        padding: gutter,
        child: AppTextField(
          label: l10n.productsSearchLabel,
          controller: _search,
          focusNode: _searchFocus,
          placeholder: l10n.suppliersSearch,
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
              label: filters > 0 ? l10n.categoriesFiltersActive(filters) : l10n.categoriesFilters,
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
      SizedBox(height: AppSpacing.xl),
      ..._list(l10n, tag),
    ];
  }

  List<Widget> _list(L10n l10n, String tag) {
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight);
    final count = _model.suppliers.length;

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
    if (count == 0 && _model.error != null) {
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
    if (count == 0) {
      return [
        Padding(
          padding: gutter,
          child: EmptyBox(
            icon: AppIcons.truck,
            title: _model.isNarrowed ? l10n.productsNoMatchTitle : l10n.suppliersEmptyTitle,
            body: _model.isNarrowed ? l10n.suppliersNoMatchBody : l10n.suppliersEmptyBody,
          ),
        ),
      ];
    }

    return [
      if (_model.error != null) Padding(padding: gutter, child: ApiErrorLine(error: _model.error)),
      SectionLabel(label: l10n.suppliersSection, trailing: '$count'),
      Padding(
        padding: gutter,
        child: ListBox(
          children: [
            for (final supplier in _model.suppliers)
              _SupplierRow(
                supplier: supplier,
                tag: tag,
                onTap: () => _openDetails(supplier),
                onEdit: () => _openForm(supplier),
                onDelete: () => _delete(supplier),
              ),
          ],
        ),
      ),
    ];
  }
}

/// The web's delete confirm, with its notice when purchases are linked.
Future<bool> confirmSupplierDelete(BuildContext context, Supplier supplier) {
  final l10n = L10n.of(context);
  return showDestructiveSheet(
    context,
    title: l10n.supplierDeleteTitle,
    body: l10n.supplierDeleteBody(supplier.name),
    noticeTitle: supplier.purchaseCount > 0 ? l10n.supplierDeleteNotice(supplier.purchaseCount) : null,
    confirmLabel: l10n.commonDelete,
  );
}

/// *● ACTIF* / *INACTIF* — the web's status pill; inactive is dimmed and has no
/// dot.
class SupplierStatusBadge extends StatelessWidget {
  const SupplierStatusBadge({super.key, required this.active, this.boxed = true});

  final bool active;

  /// False for the bare label under the name on the details screen.
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final color = active ? AppColors.textSecondary : AppColors.textMuted;
    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (active) ...[
          Container(
            width: 1.54.w,
            height: 1.54.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 1.03.w),
        ],
        Text(
          (active ? l10n.supplierActive : l10n.supplierInactive).toUpperCase(),
          style: AppText.labelMicro.copyWith(color: color),
        ),
      ],
    );
    if (!boxed) return label;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.54.w, vertical: 0.77.w),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: label,
    );
  }
}

class _SupplierRow extends StatelessWidget {
  const _SupplierRow({
    required this.supplier,
    required this.tag,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Supplier supplier;
  final String tag;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final contact = [?supplier.phone, ?supplier.email].join('  ·  ');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(AppSpacing.lg, 3.59.w, AppSpacing.sm, 3.59.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InitialsAvatar(initials: supplier.initials),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(supplier.name, style: AppText.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      SupplierStatusBadge(active: supplier.isActive),
                    ],
                  ),
                  if (contact.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.xs),
                    Text(contact, style: AppText.bodyS.copyWith(color: AppColors.textSecondary)),
                  ],
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    supplier.address ?? '—',
                    style: AppText.bodyS.copyWith(color: AppColors.textMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.suppliersPurchaseCount(supplier.purchaseCount).toUpperCase(),
                          style: AppText.labelMeta,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(Money.price(supplier.totalSpent, tag), style: AppText.numeralM),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            RowAction(icon: AppIcons.edit, label: l10n.supplierEditTitle, onTap: onEdit),
            SizedBox(width: AppSpacing.xs),
            RowAction(icon: AppIcons.trash, label: l10n.supplierDeleteTitle, onTap: onDelete),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filters sheet (Figma `644:12163`)
// ---------------------------------------------------------------------------

Future<SupplierFilters?> showSupplierFiltersSheet(BuildContext context, {required SupplierFilters current}) {
  return showModalBottomSheet<SupplierFilters>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _FiltersSheet(current: current),
  );
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.current});

  final SupplierFilters current;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late SupplierStatusFilter _status = widget.current.status;
  late final _minPurchases = TextEditingController(text: widget.current.minPurchases?.toString() ?? '');
  late final _maxPurchases = TextEditingController(text: widget.current.maxPurchases?.toString() ?? '');
  late final _minSpent = TextEditingController(text: widget.current.minSpent?.round().toString() ?? '');
  late final _maxSpent = TextEditingController(text: widget.current.maxSpent?.round().toString() ?? '');
  final _focus = List.generate(4, (_) => FocusNode());

  List<TextEditingController> get _controllers => [_minPurchases, _maxPurchases, _minSpent, _maxSpent];

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

  static int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  SupplierFilters get _draft => SupplierFilters(
        status: _status,
        minPurchases: _int(_minPurchases),
        maxPurchases: _int(_maxPurchases),
        minSpent: _int(_minSpent)?.toDouble(),
        maxSpent: _int(_maxSpent)?.toDouble(),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final draft = _draft;
    bool bad(int? min, int? max) => min != null && max != null && min > max;
    final purchasesBad = bad(_int(_minPurchases), _int(_maxPurchases));
    final spentBad = bad(_int(_minSpent), _int(_maxSpent));
    final digits = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)];

    Widget range(String minLabel, String maxLabel, int index, String maxHint, bool isBad) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: minLabel,
                controller: _controllers[index],
                focusNode: _focus[index],
                placeholder: '0',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: digits,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppTextField(
                label: maxLabel,
                controller: _controllers[index + 1],
                focusNode: _focus[index + 1],
                placeholder: maxHint,
                errorText: isBad ? l10n.categoriesFilterRangeInvalid : null,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: digits,
              ),
            ),
          ],
        );

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
                    (SupplierStatusFilter.all, l10n.productsFilterAll),
                    (SupplierStatusFilter.active, l10n.clientsFilterActive),
                    (SupplierStatusFilter.inactive, l10n.clientsFilterInactive),
                  ])
                    AppFilterChip(
                      label: label,
                      selected: _status == value,
                      onTap: () => setState(() => _status = value),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.xl),
              range(l10n.suppliersFilterPurchasesMin, l10n.suppliersFilterPurchasesMax, 0, '1000', purchasesBad),
              SizedBox(height: AppSpacing.xl),
              range(l10n.clientsFilterSpentMin, l10n.clientsFilterSpentMax, 2, '10000000', spentBad),
              SizedBox(height: AppSpacing.xxl),
              FilledButton(
                onPressed: draft != widget.current && !purchasesBad && !spentBad
                    ? () => Navigator.of(context).pop(draft)
                    : null,
                child: Text(l10n.categoriesFilterApply),
              ),
              SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: widget.current.isEmpty && draft.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(const SupplierFilters()),
                child: Text(l10n.categoriesFilterClear),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
