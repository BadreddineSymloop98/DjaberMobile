import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/catalogue_repository.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/products_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';

/// `17 — Produits` — the catalogue.
///
/// **The table on the web became rows here.** The desktop page is a nine-column
/// grid with cost, margin and profit in it; brief §14.3 keeps margin work on
/// the web, and nine columns do not survive 390dp. Each product is one `List
/// Row` instead: name, then SKU and price on the meta line, then the stock on
/// hand on the right.
///
/// **The category `select` became chips.** The web's toolbar has a dropdown of
/// every category plus a separate low-stock toggle; both are folded into one
/// scrolling chip row, because a dropdown for a filter is a modal for a
/// one-tap decision. The chips are `Tous`, `Stock faible`, then one per
/// category the merchant has actually created — so they are as long as their
/// catalogue and the row scrolls.
///
/// > The frames drew a third fixed chip, `Sans catégorie`. It is **not** here:
/// > the endpoint has no filter for "category is null" — `categoryId` matches
/// > one id and `categoryIds` a list — so the chip could only have been
/// > satisfied by filtering the fetched page, which is wrong the moment a
/// > merchant has more products than one page holds. The Figma frames were
/// > corrected to match.
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final ProductsViewModel _model = ProductsViewModel(
    products: context.read<ProductRepository>(),
    catalogue: context.read<CatalogueRepository>(),
    dashboard: context.read<DashboardRepository>(),
  );

  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearchChanged);
    // After the first frame, so a failure has a tree to show its message in.
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

  /// 300ms, the web's own debounce on the same field.
  ///
  /// Every keystroke is a request otherwise, and on the metered connections
  /// this market runs on that is both slow and expensive — the results for
  /// "rob" would also arrive after the ones for "robe" as often as not.
  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _model.setSearch(_search.text),
    );
  }

  /// Back, which cannot simply pop.
  ///
  /// This screen is reached with `go` from the drawer and from home's action
  /// card, so the navigator is usually empty and `pop()` would reach Android
  /// and close the app. Home is the honest fallback: it is where both entry
  /// points live.
  void _back() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.home);
    }
  }

  Future<void> _add() async {
    // `push`, not `go`: the merchant comes back to the list they were reading,
    // with the filter and the search they had set still on it.
    final created = await GoRouter.of(context).push<bool>(Routes.productNew);
    if (created != true || !mounted) return;
    // The rows and the two figures in the subtitle are both stale now.
    await _model.reloadAfterCreate();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ChangeNotifierProvider<ProductsViewModel>.value(
      value: _model,
      child: Consumer<ProductsViewModel>(
        builder: (context, model, _) {
          return Scaffold(
            backgroundColor: AppColors.ink,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      0.47.h, // 4
                      AppSpacing.gutter,
                      AppSpacing.lg, // 16
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AppBackButton(
                        onBack: _back,
                        semanticLabel: l10n.commonBack,
                      ),
                    ),
                  ),
                  Expanded(child: _Body(model: model, controller: _search,
                      focusNode: _searchFocus)),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      AppSpacing.md, // 12
                      AppSpacing.gutter,
                      3.32.h, // 28
                    ),
                    child: FilledButton(
                      onPressed: _add,
                      child: Text(l10n.productsAdd),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.model,
    required this.controller,
    required this.focusNode,
  });

  final ProductsViewModel model;
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final tag = Localizations.localeOf(context).toLanguageTag();
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);

    return ListView(
      // The chip row is full-bleed, so the padding is per-section rather than
      // on the scroll view.
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      children: [
        Padding(
          padding: gutter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.productsEyebrow, style: AppText.labelMeta),
              SizedBox(height: AppSpacing.sm), // 8
              Text(l10n.productsTitle, style: AppText.displayM),
              SizedBox(height: AppSpacing.sm),
              Text(
                l10n.productsSummary(
                  model.stats.totalProducts,
                  Money.shortLabel(model.stats.totalStockValue, tag),
                ),
                style: AppText.bodyS.copyWith(height: 1.32),
              ),
              SizedBox(height: AppSpacing.xl), // 20
              AppTextField(
                label: l10n.productsSearchLabel,
                controller: controller,
                focusNode: focusNode,
                placeholder: l10n.productsSearchPlaceholder,
                // Search, not done: the list updates as they type, and the
                // keyboard's action should say so rather than promise a
                // submit that does not exist.
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => focusNode.unfocus(),
              ),
              SizedBox(height: AppSpacing.lg), // 16
            ],
          ),
        ),
        _Chips(model: model),
        SizedBox(height: AppSpacing.lg),
        SectionLabel(
          label: model.filter is LowStockOnly
              ? l10n.productsSectionLowStock
              : switch (model.filter) {
                  InCategory(:final category) => category.name,
                  _ => l10n.productsSectionAll,
                },
          trailing: Money.grouped(model.total, tag),
        ),
        Padding(padding: gutter, child: _Rows(model: model)),
      ],
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.model});

  final ProductsViewModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return FilterChipRow(
      children: [
        AppFilterChip(
          label: l10n.productsFilterAll,
          selected: model.filter is AllProducts,
          onTap: () => model.selectFilter(ProductFilter.all),
        ),
        AppFilterChip(
          label: l10n.productsFilterLowStock,
          selected: model.filter is LowStockOnly,
          onTap: () => model.selectFilter(ProductFilter.lowStock),
        ),
        for (final category in model.categories)
          AppFilterChip(
            label: category.name,
            selected: model.filter == InCategory(category),
            onTap: () => model.selectFilter(InCategory(category)),
          ),
      ],
    );
  }
}

class _Rows extends StatelessWidget {
  const _Rows({required this.model});

  final ProductsViewModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    if (model.isFirstLoad) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
        child: const Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    final error = model.error;
    if (error != null && model.rows.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: ApiErrorLine(error: error),
      );
    }

    if (model.rows.isEmpty) {
      // Two different nothings. An empty catalogue is an invitation; an empty
      // filter is a dead end the merchant can back out of, and telling them
      // to "add your first product" when they have eighty would be wrong.
      return _EmptyState(
        title: model.isCatalogueEmpty
            ? l10n.productsEmptyTitle
            : l10n.productsNoMatchTitle,
        body: model.isCatalogueEmpty
            ? l10n.productsEmptyBody
            : l10n.productsNoMatchBody,
      );
    }

    final tag = Localizations.localeOf(context).toLanguageTag();

    return ListBox(
      children: [
        for (final product in model.rows)
          AppListRow(
            title: product.name,
            meta: _meta(product, l10n, tag),
            value: Money.grouped(product.quantity, tag),
            unit: _stockLabel(product, l10n),
            unitColor: product.isOutOfStock ? AppColors.accentAlert : null,
            onTap: () => GoRouter.of(context).go(Routes.productOf(product.id)),
          ),
      ],
    );
  }

  /// `PRD-001 · 2 400 DA`, plus the threshold when one is set.
  ///
  /// The frames put the stock state here as a third segment. It moved to the
  /// label under the count instead, where it reads as what it is — the state
  /// of *that* number — rather than sitting next to the price as though it
  /// were another attribute of the product.
  static String _meta(Product product, L10n l10n, String tag) {
    final parts = <String>[
      product.sku,
      Money.price(product.sellingPrice, tag),
      if (product.minQuantity > 0) l10n.productsThreshold(product.minQuantity),
    ];
    return parts.join(' · ');
  }

  static String _stockLabel(Product product, L10n l10n) =>
      product.isOutOfStock ? l10n.productsOutOfStock : l10n.productsInStock;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.title),
          SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: AppText.bodyS.copyWith(
              height: 1.32,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
