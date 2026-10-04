import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/catalogue.dart';
import '../../../data/repositories/catalogue_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/categories_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import 'category_form_sheet.dart';

/// `Categories list` (Figma `629:6798`) — the web's `stock/categories` page.
///
/// Title and count, a search, the *Filtres* chip, then one row per category:
/// the colour square, the name, the description when there is one, the
/// product count, and edit + delete. The web shows those two on hover; here
/// they are always visible, as the frame draws them. *Ajouter une catégorie*
/// is pinned under the list.
///
/// The count is `_count.products` from the server, which **includes inactive
/// products** — a deleted product still counts until it is restored or its
/// category changes. It is shown as the server gives it.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final CategoriesViewModel _model = CategoriesViewModel(
    catalogue: context.read<CatalogueRepository>(),
  );

  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearchChanged);
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

  /// 300 ms, the web's own debounce on the same field.
  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _model.setSearch(_search.text),
    );
  }

  Future<void> _openForm([ProductCategory? editing]) async {
    final l10n = L10n.of(context);
    final saved = await showCategoryFormSheet(
      context,
      catalogue: context.read<CatalogueRepository>(),
      knownNames: _model.knownNames,
      editing: editing,
    );
    if (saved == null || !mounted) return;
    AppToast.success(context, editing == null ? l10n.categoryAdded : l10n.categoryUpdated);
    await _model.load();
  }

  /// The web's confirm, with its notice when the category still holds
  /// products — which the backend does not guard against: they simply lose
  /// their category.
  Future<void> _delete(ProductCategory category) async {
    final l10n = L10n.of(context);
    final count = category.productCount ?? 0;
    final confirmed = await showDestructiveSheet(
      context,
      title: l10n.categoryDeleteTitle,
      body: l10n.categoryDeleteBody(category.name),
      noticeTitle: count > 0 ? l10n.categoryDeleteNotice(count) : null,
      noticeBody: count > 0 ? l10n.categoryDeleteNoticeBody : null,
      confirmLabel: l10n.commonDelete,
    );
    if (!confirmed || !mounted) return;

    final result = await _model.delete(category);
    if (!mounted) return;
    if (result.errorOrNull case final error?) {
      AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    AppToast.success(context, l10n.categoryDeleted);
  }

  Future<void> _openFilters() async {
    final applied = await showCategoryFiltersSheet(context, current: _model.filters);
    if (applied != null) _model.applyFilters(applied);
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
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutterTight,
                  0.47.h,
                  AppSpacing.gutter,
                  AppSpacing.lg,
                ),
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
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutterTight,
                  AppSpacing.md,
                  AppSpacing.gutterTight,
                  3.32.h,
                ),
                child: FilledButton(
                  onPressed: _openForm,
                  child: Text(l10n.categoryAddTitle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(L10n l10n) {
    final count = _model.categories.length;
    final activeFilters = _model.filters.activeCount;

    return [
      // ---- Title ----
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.productsEyebrow, style: AppText.labelMeta),
            SizedBox(height: 1.54.w), // 6
            Text(l10n.categoriesTitle, style: AppText.displayM),
            SizedBox(height: 1.54.w),
            Text(
              l10n.categoriesCount(count),
              style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      SizedBox(height: 10.26.w), // 20 + 20

      // ---- Search ----
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
        child: AppTextField(
          label: l10n.productsSearchLabel,
          controller: _search,
          focusNode: _searchFocus,
          placeholder: l10n.categoriesSearchPlaceholder,
          textInputAction: TextInputAction.search,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
          onSubmitted: (_) => _searchFocus.unfocus(),
        ),
      ),
      SizedBox(height: AppSpacing.lg),

      // ---- Filters chip ----
      Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: _FiltersChip(
            label: activeFilters > 0
                ? l10n.categoriesFiltersActive(activeFilters)
                : l10n.categoriesFilters,
            active: activeFilters > 0,
            onTap: _openFilters,
          ),
        ),
      ),
      SizedBox(height: AppSpacing.xl),

      ..._list(l10n, count),
    ];
  }

  List<Widget> _list(L10n l10n, int count) {
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight);

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
          child: _EmptyBox(
            title: _model.isNarrowed ? l10n.productsNoMatchTitle : l10n.categoriesEmptyTitle,
            body: _model.isNarrowed ? l10n.categoriesNoMatchBody : l10n.categoriesEmptyBody,
          ),
        ),
      ];
    }

    return [
      // A failed silent refresh keeps the rows, and says so.
      if (_model.error != null)
        Padding(padding: gutter, child: ApiErrorLine(error: _model.error)),
      SectionLabel(label: l10n.categoriesSection, trailing: '$count'),
      Padding(
        padding: gutter,
        child: ListBox(
          children: [
            for (final category in _model.categories)
              _CategoryRow(
                category: category,
                onEdit: () => _openForm(category),
                onDelete: () => _delete(category),
              ),
          ],
        ),
      ),
    ];
  }
}

/// The *Filtres* chip: the file's `Tab` with the filter icon. It fills white
/// once a filter is on, and says how many.
class _FiltersChip extends StatelessWidget {
  const _FiltersChip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.ink : AppColors.textSecondary;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: active ? AppColors.textPrimary : Colors.transparent,
            border: Border.all(
              color: active ? AppColors.textPrimary : AppColors.rule,
              width: AppStroke.hairline,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(AppIcons.filter, size: 3.59.w, color: fg), // 14
              SizedBox(width: 1.54.w), // 6
              Text(label, style: AppText.bodyS.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

/// One category: colour square and name, description when set, product count,
/// then edit and delete.
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.onEdit, required this.onDelete});

  final ProductCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final description = category.description?.trim();

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg, // 16
        3.59.w, // 14
        AppSpacing.sm, // 8
        3.59.w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: AppSpacing.sm, // 8
                      height: AppSpacing.sm,
                      decoration: BoxDecoration(
                        color: categoryColor(category.color),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 2.56.w), // 10
                    Flexible(
                      child: Text(
                        category.name,
                        style: AppText.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (description != null && description.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.categoriesProductCount(category.productCount ?? 0),
                  style: AppText.labelMeta,
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          _RowAction(icon: AppIcons.edit, label: l10n.categoryEditTitle, onTap: onEdit),
          SizedBox(width: AppSpacing.xs),
          _RowAction(icon: AppIcons.trash, label: l10n.categoryDeleteTitle, onTap: onDelete),
        ],
      ),
    );
  }
}

/// A 16px glyph with a comfortable hit target around it.
class _RowAction extends StatelessWidget {
  const _RowAction({required this.icon, required this.label, required this.onTap});

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
          padding: EdgeInsets.all(1.54.w), // 6
          child: AppIcon(icon, size: 4.1.w, color: AppColors.textMuted), // 16
        ),
      ),
    );
  }
}

/// The empty box (Figma `629:8252`): the tag icon, the title and the hint.
class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.title, required this.body});

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
          AppIcon(AppIcons.tag, size: 8.21.w, color: AppColors.textMuted), // 32
          SizedBox(height: AppSpacing.md),
          Text(title, style: AppText.title, textAlign: TextAlign.center),
          SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: AppText.bodyS.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filters sheet (Figma `629:8397`)
// ---------------------------------------------------------------------------

/// The web's filter panel as a sheet. Edits a draft; returns the filters to
/// apply, or null when dismissed.
///
/// The web's 0–1000 range slider became two number fields — the file has no
/// slider component, and a merchant filtering by product count types a number.
Future<CategoryFilters?> showCategoryFiltersSheet(
  BuildContext context, {
  required CategoryFilters current,
}) {
  return showModalBottomSheet<CategoryFilters>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _FiltersSheet(current: current),
  );
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.current});

  final CategoryFilters current;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late CategoryFilters _draft = widget.current;
  late final _min = TextEditingController(text: widget.current.minProducts?.toString() ?? '');
  late final _max = TextEditingController(text: widget.current.maxProducts?.toString() ?? '');
  final _minFocus = FocusNode();
  final _maxFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _min.addListener(() => setState(() {
          _draft = _draft.copyWith(minProducts: () => int.tryParse(_min.text.trim()));
        }));
    _max.addListener(() => setState(() {
          _draft = _draft.copyWith(maxProducts: () => int.tryParse(_max.text.trim()));
        }));
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    _minFocus.dispose();
    _maxFocus.dispose();
    super.dispose();
  }

  bool get _rangeInvalid {
    final min = _draft.minProducts;
    final max = _draft.maxProducts;
    return min != null && max != null && min > max;
  }

  void _toggleColor(String hex) {
    final colors = {..._draft.colors};
    if (!colors.remove(hex)) colors.add(hex);
    setState(() => _draft = _draft.copyWith(colors: colors));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final dirty = _draft != widget.current;
    final digits = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)];

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
              Text(l10n.categoriesFilters, style: AppText.title),
              SizedBox(height: AppSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: l10n.categoriesFilterMin,
                      controller: _min,
                      focusNode: _minFocus,
                      placeholder: '0',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: digits,
                      onSubmitted: (_) => _maxFocus.requestFocus(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextField(
                      label: l10n.categoriesFilterMax,
                      controller: _max,
                      focusNode: _maxFocus,
                      placeholder: '1000',
                      errorText: _rangeInvalid ? l10n.categoriesFilterRangeInvalid : null,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: digits,
                      onSubmitted: (_) => _maxFocus.unfocus(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xxl),
              Text(l10n.categoriesFilterHasDescription.toUpperCase(), style: AppText.labelMeta),
              SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 1.54.w,
                runSpacing: 1.54.w,
                children: [
                  for (final (value, label) in [
                    (DescriptionFilter.all, l10n.productsFilterAll),
                    (DescriptionFilter.yes, l10n.commonYes),
                    (DescriptionFilter.no, l10n.commonNo),
                  ])
                    AppFilterChip(
                      label: label,
                      selected: _draft.description == value,
                      onTap: () => setState(() => _draft = _draft.copyWith(description: value)),
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.xxl),
              Text(l10n.categoryColor.toUpperCase(), style: AppText.labelMeta),
              SizedBox(height: AppSpacing.sm),
              ColorSwatchRow(selected: _draft.colors, onTap: _toggleColor),
              if (_draft.colors.isNotEmpty) ...[
                SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.categoriesFilterColorsSelected(_draft.colors.length),
                  style: AppText.labelMicro,
                ),
              ],
              SizedBox(height: AppSpacing.xxl),
              FilledButton(
                // Disabled until something changed, as on the web.
                onPressed: dirty && !_rangeInvalid ? () => Navigator.of(context).pop(_draft) : null,
                child: Text(l10n.categoriesFilterApply),
              ),
              SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                // The web's Clear All applies at once.
                onPressed: widget.current.isEmpty && _draft.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(const CategoryFilters()),
                child: Text(l10n.categoriesFilterClear),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
