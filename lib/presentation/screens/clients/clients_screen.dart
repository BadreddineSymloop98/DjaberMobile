import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/client.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/clients_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/date_picker_sheet.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import 'client_form_sheet.dart';

/// `Clients list` (Figma `639:8359`) — the web's `stock/clients` page.
///
/// The four figures, the two searches (name or e-mail; phone), *Filtres* and
/// the two date chips, then one row per client: initials, name and source,
/// phone · e-mail, address, orders · conversations and total spent, and edit +
/// delete. **A row tap opens the details** — the web's per-row *View* — and
/// *View Orders* lives there only (approved rule, brief §25.29).
class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  late final ClientsViewModel _model = ClientsViewModel(clients: context.read<ClientRepository>());

  final _search = TextEditingController();
  final _phone = TextEditingController();
  final _searchFocus = FocusNode();
  final _phoneFocus = FocusNode();
  Timer? _searchDebounce;
  Timer? _phoneDebounce;

  @override
  void initState() {
    super.initState();
    // 300 ms on each field, the web's own debounce.
    _search.addListener(() {
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 300), () => _model.setSearch(_search.text));
    });
    _phone.addListener(() {
      _phoneDebounce?.cancel();
      _phoneDebounce = Timer(const Duration(milliseconds: 300), () => _model.setPhone(_phone.text));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _phoneDebounce?.cancel();
    _search.dispose();
    _phone.dispose();
    _searchFocus.dispose();
    _phoneFocus.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _openForm([Client? editing]) async {
    final l10n = L10n.of(context);
    final saved = await showClientFormSheet(
      context,
      clients: context.read<ClientRepository>(),
      knownPhones: _model.knownPhones,
      editing: editing,
    );
    if (saved == null || !mounted) return;
    AppToast.success(context, editing == null ? l10n.clientAdded : l10n.clientUpdated);
    await _model.load();
  }

  Future<void> _openDetails(Client client) async {
    final changed = await GoRouter.of(context).push<bool>(Routes.clientOf(client.id));
    if (changed == true && mounted) await _model.load();
  }

  /// The web's confirm, with its notice when orders are linked. The backend
  /// deletes regardless: the orders stay and lose their client.
  Future<void> _delete(Client client) async {
    final l10n = L10n.of(context);
    final confirmed = await confirmClientDelete(context, client);
    if (!confirmed || !mounted) return;
    final result = await _model.delete(client);
    if (!mounted) return;
    if (result.errorOrNull case final error?) {
      AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    AppToast.success(context, l10n.clientDeleted);
  }

  Future<void> _openFilters() async {
    final applied = await showClientFiltersSheet(context, current: _model.filters);
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
                child: FilledButton(onPressed: _openForm, child: Text(l10n.clientAddTitle)),
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
            Text(l10n.clientsEyebrow, style: AppText.labelMeta),
            SizedBox(height: 1.54.w),
            Text(l10n.clientsTitle, style: AppText.displayM),
            SizedBox(height: 1.54.w),
            Text(
              l10n.clientsSubtitle,
              style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.32),
            ),
          ],
        ),
      ),
      SizedBox(height: 10.26.w), // 20 + 20

      // ---- The four figures ----
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          children: [
            _Pair(
              KpiTile(
                label: l10n.clientsStatTotal,
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
            _Pair(
              KpiTile(
                label: l10n.clientsStatWithOrders,
                value: Money.grouped(_model.withOrdersCount, tag),
                icon: AppIcons.clipboard,
                iconColor: AppColors.accentMoney,
              ),
              KpiTile(
                label: l10n.clientsStatTotalSpent,
                value: Money.grouped(_model.totalSpent.round(), tag),
                unit: 'DA',
                icon: AppIcons.dollar,
                iconColor: AppColors.accentStarred,
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.xl),

      // ---- Searches ----
      Padding(
        padding: gutter,
        child: Column(
          children: [
            AppTextField(
              label: l10n.productsSearchLabel,
              controller: _search,
              focusNode: _searchFocus,
              placeholder: l10n.clientsSearchName,
              textInputAction: TextInputAction.search,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              onSubmitted: (_) => _searchFocus.unfocus(),
            ),
            SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: l10n.clientPhone,
              controller: _phone,
              focusNode: _phoneFocus,
              placeholder: l10n.clientsSearchPhone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.search,
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
              onSubmitted: (_) => _phoneFocus.unfocus(),
            ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.lg),

      // ---- Filters and dates ----
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
    final count = _model.clients.length;

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
            icon: AppIcons.users,
            title: _model.isNarrowed ? l10n.productsNoMatchTitle : l10n.clientsEmptyTitle,
            body: _model.isNarrowed ? l10n.clientsNoMatchBody : l10n.clientsEmptyBody,
          ),
        ),
      ];
    }

    return [
      if (_model.error != null) Padding(padding: gutter, child: ApiErrorLine(error: _model.error)),
      SectionLabel(label: l10n.clientsSection, trailing: '$count'),
      Padding(
        padding: gutter,
        child: ListBox(
          children: [
            for (final client in _model.clients)
              _ClientRow(
                client: client,
                tag: tag,
                onTap: () => _openDetails(client),
                onEdit: () => _openForm(client),
                onDelete: () => _delete(client),
              ),
          ],
        ),
      ),
    ];
  }
}

/// The web's delete confirm, shared by the list and the details screen.
Future<bool> confirmClientDelete(BuildContext context, Client client) {
  final l10n = L10n.of(context);
  return showDestructiveSheet(
    context,
    title: l10n.clientDeleteTitle,
    body: l10n.clientDeleteBody(client.name),
    noticeTitle: client.totalOrders > 0 ? l10n.clientDeleteNotice(client.totalOrders) : null,
    confirmLabel: l10n.commonDelete,
  );
}

class _Pair extends StatelessWidget {
  const _Pair(this.first, this.second);

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: first),
          SizedBox(width: AppSpacing.sm),
          Expanded(child: second),
        ],
      ),
    );
  }
}

/// One client row, as the frame draws it.
class _ClientRow extends StatelessWidget {
  const _ClientRow({
    required this.client,
    required this.tag,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Client client;
  final String tag;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final contact = [?client.phone, ?client.email].join('  ·  ');
    final conversations = client.conversationCount ?? 0;
    final figures = [
      l10n.clientsOrderCount(client.totalOrders),
      if (conversations > 0) l10n.clientsConversationCount(conversations),
    ].join('  ·  ');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(AppSpacing.lg, 3.59.w, AppSpacing.sm, 3.59.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InitialsAvatar(initials: client.initials),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(client.name, style: AppText.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      SourceBadge(source: client.source),
                    ],
                  ),
                  if (contact.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.xs),
                    Text(contact, style: AppText.bodyS.copyWith(color: AppColors.textSecondary)),
                  ],
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    client.address ?? '—',
                    style: AppText.bodyS.copyWith(color: AppColors.textMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: Text(figures.toUpperCase(), style: AppText.labelMeta)),
                      SizedBox(width: AppSpacing.sm),
                      Text(Money.price(client.totalSpent, tag), style: AppText.numeralM),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            RowAction(icon: AppIcons.edit, label: l10n.clientEditTitle, onTap: onEdit),
            SizedBox(width: AppSpacing.xs),
            RowAction(icon: AppIcons.trash, label: l10n.clientDeleteTitle, onTap: onDelete),
          ],
        ),
      ),
    );
  }
}

/// The 36px initials square — `ink/3` with a hairline, square as the file's
/// frozen style has it (the web's are round).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9.23.w, // 36
      height: 9.23.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Text(initials, style: AppText.title.copyWith(color: AppColors.textSecondary)),
    );
  }
}

/// *CHAT IA* / *MANUEL* — the web's source badge.
class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.source});

  final ClientSource source;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.54.w, vertical: 0.77.w), // 6 / 3
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Text(
        (source == ClientSource.ai ? l10n.clientsSourceAi : l10n.clientsSourceManual).toUpperCase(),
        style: AppText.labelMicro.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

/// A 16px glyph with a comfortable hit target.
class RowAction extends StatelessWidget {
  const RowAction({super.key, required this.icon, required this.label, required this.onTap});

  final List<String> icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.all(1.54.w),
          child: AppIcon(icon, size: 4.1.w, color: AppColors.textMuted),
        ),
      ),
    );
  }
}

/// The file's `Tab` with a leading icon — *Filtres* and the date chips. Filled
/// white once it holds a value; a date chip then carries a × that clears it,
/// as the web's DatePicker does.
class ToolChip extends StatelessWidget {
  const ToolChip({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.onClear,
    this.clearLabel,
  });

  final List<String> icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final String? clearLabel;

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.ink : AppColors.textSecondary;
    return Container(
      decoration: BoxDecoration(
        color: active ? AppColors.textPrimary : Colors.transparent,
        border: Border.all(color: active ? AppColors.textPrimary : AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  onClear == null ? AppSpacing.md : AppSpacing.xs,
                  AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(icon, size: 3.59.w, color: fg),
                    SizedBox(width: 1.54.w),
                    Text(label, style: AppText.bodyS.copyWith(color: fg)),
                  ],
                ),
              ),
            ),
          ),
          if (onClear != null)
            Semantics(
              button: true,
              label: clearLabel,
              child: GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(AppSpacing.xs, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
                  child: AppIcon(AppIcons.close, size: 3.08.w, color: fg),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The empty box — an icon, a title, a sentence.
class EmptyBox extends StatelessWidget {
  const EmptyBox({super.key, required this.icon, required this.title, required this.body});

  final List<String> icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 12.31.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          AppIcon(icon, size: 8.21.w, color: AppColors.textMuted),
          SizedBox(height: AppSpacing.md),
          Text(title, style: AppText.title, textAlign: TextAlign.center),
          SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filters sheet (Figma `639:10584`)
// ---------------------------------------------------------------------------

/// The web's filter panel as a sheet: *Statut*, *Source*, orders min/max and
/// spent min/max. The web's two range sliders became number fields, as the
/// frame draws them.
Future<ClientFilters?> showClientFiltersSheet(BuildContext context, {required ClientFilters current}) {
  return showModalBottomSheet<ClientFilters>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _FiltersSheet(current: current),
  );
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.current});

  final ClientFilters current;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late ClientStatusFilter _status = widget.current.status;
  late ClientSource? _source = widget.current.source;
  late final _minOrders = TextEditingController(text: widget.current.minOrders?.toString() ?? '');
  late final _maxOrders = TextEditingController(text: widget.current.maxOrders?.toString() ?? '');
  late final _minSpent = TextEditingController(text: widget.current.minSpent?.round().toString() ?? '');
  late final _maxSpent = TextEditingController(text: widget.current.maxSpent?.round().toString() ?? '');
  final _focus = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (final c in [_minOrders, _maxOrders, _minSpent, _maxSpent]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_minOrders, _maxOrders, _minSpent, _maxSpent]) {
      c.dispose();
    }
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  static int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  ClientFilters get _draft => ClientFilters(
        status: _status,
        source: _source,
        minOrders: _int(_minOrders),
        maxOrders: _int(_maxOrders),
        minSpent: _int(_minSpent)?.toDouble(),
        maxSpent: _int(_maxSpent)?.toDouble(),
      );

  bool _bad(int? min, int? max) => min != null && max != null && max > 0 && min > max;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final draft = _draft;
    final ordersBad = _bad(draft.minOrders, draft.maxOrders);
    final spentBad = _bad(_int(_minSpent), _int(_maxSpent));
    final digits = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)];

    Widget chips<T>(List<(T, String)> options, T selected, ValueChanged<T> onTap) => Wrap(
          spacing: 1.54.w,
          runSpacing: 1.54.w,
          children: [
            for (final (value, label) in options)
              AppFilterChip(label: label, selected: selected == value, onTap: () => setState(() => onTap(value))),
          ],
        );

    Widget range(String minLabel, String maxLabel, TextEditingController min, TextEditingController max,
            int focusIndex, String maxHint, bool bad) =>
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: minLabel,
                controller: min,
                focusNode: _focus[focusIndex],
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
                controller: max,
                focusNode: _focus[focusIndex + 1],
                placeholder: maxHint,
                errorText: bad ? l10n.categoriesFilterRangeInvalid : null,
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
              chips<ClientStatusFilter>(
                [
                  (ClientStatusFilter.all, l10n.productsFilterAll),
                  (ClientStatusFilter.active, l10n.clientsFilterActive),
                  (ClientStatusFilter.inactive, l10n.clientsFilterInactive),
                ],
                _status,
                (v) => _status = v,
              ),
              SizedBox(height: AppSpacing.xl),
              Text(l10n.clientsFilterSource.toUpperCase(), style: AppText.labelMeta),
              SizedBox(height: AppSpacing.sm),
              chips<ClientSource?>(
                [
                  (null, l10n.productsFilterAll),
                  (ClientSource.ai, l10n.clientsSourceAi),
                  (ClientSource.manual, l10n.clientsSourceManual),
                ],
                _source,
                (v) => _source = v,
              ),
              SizedBox(height: AppSpacing.xl),
              range(l10n.clientsFilterOrdersMin, l10n.clientsFilterOrdersMax, _minOrders, _maxOrders, 0, '1000', ordersBad),
              SizedBox(height: AppSpacing.xl),
              range(l10n.clientsFilterSpentMin, l10n.clientsFilterSpentMax, _minSpent, _maxSpent, 2, '1000000', spentBad),
              SizedBox(height: AppSpacing.xxl),
              FilledButton(
                onPressed: draft != widget.current && !ordersBad && !spentBad
                    ? () => Navigator.of(context).pop(draft)
                    : null,
                child: Text(l10n.categoriesFilterApply),
              ),
              SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: widget.current.isEmpty && draft.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(const ClientFilters()),
                child: Text(l10n.categoriesFilterClear),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
