import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/product_detail_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_scope.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import 'adjust_stock_sheet.dart';

/// A product's details — the web's *Product Details* modal on
/// `/dashboard/stock/products`, in its order: the images, name and SKU, the
/// description, cost / selling price / profit and margin / stock, the
/// category, unit, alert threshold and status, then **Variants (n)**.
///
/// **The variants table became rows.** Six columns do not fit 390dp: the name
/// is the title, the SKU and the two prices sit under it, and the quantity
/// with the status is on the end side. The web marks a quantity at or under the
/// variant's own threshold; here that quantity is set in the alert colour.
/// Like the web, the section shows only when the product has variants, and it
/// lists inactive ones too (the detail endpoint returns them all).
///
/// The web's *Close* button is not here — back closes, through the route's
/// `BackScope` in `router.dart`, whose parent is the product list. Its *Edit*
/// is: the boxed pencil beside the back arrow opens `Edit product`, and a save
/// reloads this screen. `17a` predates that screen and does not draw it.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductDetailViewModel _model = ProductDetailViewModel(
    products: context.read<ProductRepository>(),
    productId: widget.productId,
  );

  int _shownImage = 0;

  /// Opens the edit form and reloads when it reports a save, so the figures,
  /// the images and the variants below are the ones that were just written.
  Future<void> _openEdit() async {
    final saved = await GoRouter.of(context).push<bool>(
      Routes.productEditOf(widget.productId),
    );
    if (saved ?? false) {
      // The carousel index may point past the end now that an image could
      // have been removed.
      setState(() {
        _shownImage = 0;
        _edited = true;
      });
      await _model.load();
    }
  }

  /// True once an edit saved, so leaving this screen tells the product list to
  /// reload the row underneath — its name, price and stock all moved.
  bool _edited = false;

  /// `Adjust stock` — a sheet over this screen, as the frame draws it.
  ///
  /// Which form it shows is the backend's call, not a setting: a product with
  /// variants is refused by the product-level route, so the sheet gives it one
  /// card per variant.
  Future<void> _adjust(Product product) async {
    final applied = await showAdjustStockSheet(
      context,
      products: context.read<ProductRepository>(),
      product: product,
    );
    if (!applied || !mounted) return;
    setState(() => _edited = true);
    AppToast.success(context, L10n.of(context).stockAdjustDone);
    await _model.load();
  }

  /// Opens the expenses panel. Nothing is reloaded on the way back: an expense
  /// moves the true cost and the net margin, which live on that panel, and no
  /// figure on this screen.
  void _openExpenses() =>
      GoRouter.of(context).push(Routes.productExpensesOf(widget.productId));

  /// `Delete product` — the web's confirm, then a soft delete.
  ///
  /// On success this screen has nothing left to show, so it closes and the list
  /// behind it reloads without the row.
  Future<void> _delete(Product product) async {
    final l10n = L10n.of(context);
    final confirmed = await showDestructiveSheet(
      context,
      title: l10n.productDeleteTitle,
      body: l10n.productDeleteBody(product.name),
      confirmLabel: l10n.commonDelete,
    );
    if (!confirmed || !mounted) return;

    setState(() => _deleting = true);
    final result = await context.read<ProductRepository>().delete(product.id);
    if (!mounted) return;
    setState(() => _deleting = false);

    if (result.errorOrNull case final error?) {
      // A toast rather than a line: the sheet that asked is gone, and there is
      // no form on this screen to put a message under.
      AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    AppToast.success(context, l10n.productDeleteDone);
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(true);
    } else {
      router.go(Routes.products);
    }
  }

  /// Covers the screen while the delete is in flight, so nothing else on it can
  /// be tapped in the meantime.
  bool _deleting = false;

  /// Reports the edit on the way out, then lets the normal back path run.
  Future<bool> _onBack() async {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(true);
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: _model,
      // Inactive until an edit saves, so back is the route's own path in the
      // ordinary case.
      builder: (context, _) => BackIntercept(
        active: _edited,
        onBack: _onBack,
        // Nothing on the screen responds while a delete is in flight.
        child: IgnorePointer(
          ignoring: _deleting,
          child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0.47.h, AppSpacing.gutter, AppSpacing.lg),
                child: Row(
                  children: [
                    AppBackButton(semanticLabel: l10n.commonBack),
                    const Spacer(),
                    // The web's *Edit* button on this modal. `17a` was drawn
                    // before an edit screen existed and has neither Edit nor
                    // Close; back is still what closes, and this is the only
                    // way into the form — the product rows on `17` carry no
                    // actions (approved rule, brief §25.29: a row tap is the
                    // details, actions live on the details screen).
                    if (_model.product != null)
                      IconSquareButton(
                        icon: AppIcons.edit,
                        semanticLabel: l10n.productEditTitle,
                        onTap: _openEdit,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _model.load,
                  color: AppColors.textPrimary,
                  backgroundColor: AppColors.surface,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xxl),
                    children: _content(context, l10n),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, L10n l10n) {
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

    final product = _model.product;
    if (product == null) {
      return [
        ApiErrorLine(error: _model.error),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
        ),
      ];
    }

    final tag = Localizations.localeOf(context).toLanguageTag();
    final profit = product.sellingPrice - product.costPrice;
    final margin = product.sellingPrice > 0 ? (profit / product.sellingPrice * 100).toStringAsFixed(1) : '0';
    final description = product.description?.trim();
    final variants = product.variants;

    return [
      Text(l10n.productDetailEyebrow, style: AppText.labelMeta),
      SizedBox(height: AppSpacing.sm),
      _Images(
        urls: product.imageUrls,
        shown: _shownImage.clamp(0, product.imageUrls.isEmpty ? 0 : product.imageUrls.length - 1),
        onShow: (index) => setState(() => _shownImage = index),
      ),
      SizedBox(height: AppSpacing.xl),
      Text(product.name, style: AppText.displayM),
      SizedBox(height: AppSpacing.xs),
      Text(product.sku.toUpperCase(), style: AppText.labelMeta),
      if (description != null && description.isNotEmpty) ...[
        SizedBox(height: AppSpacing.sm),
        Text(description, style: AppText.bodyS.copyWith(height: 1.4)),
      ],
      SizedBox(height: AppSpacing.xl),
      _Pair(
        KpiTile(
          label: l10n.productDetailCost,
          value: Money.grouped(product.costPrice, tag),
          unit: 'DA',
          icon: AppIcons.dollar,
          iconColor: AppColors.accentMoney,
        ),
        KpiTile(
          label: l10n.productDetailSelling,
          value: Money.grouped(product.sellingPrice, tag),
          unit: 'DA',
          icon: AppIcons.dollar,
          iconColor: AppColors.accentMoney,
        ),
      ),
      SizedBox(height: AppSpacing.sm),
      _Pair(
        KpiTile(
          label: l10n.productDetailProfit,
          value: Money.grouped(profit, tag),
          unit: 'DA',
          footnote: '$margin %',
          icon: AppIcons.chart,
          iconColor: AppColors.accentMoney,
        ),
        KpiTile(
          label: l10n.productDetailInStock,
          value: Money.grouped(product.quantity, tag),
          unit: product.unitAbbreviation ?? product.unit,
          icon: AppIcons.box,
          iconColor: AppColors.accentStarred,
        ),
      ),
      SizedBox(height: AppSpacing.xl),
      ListBox(
        children: [
          _Fact(label: l10n.productCategory, value: product.categoryName ?? '–'),
          _Fact(label: l10n.productUnit, value: product.unitLabel),
          _Fact(label: l10n.productAlertThreshold, value: Money.grouped(product.minQuantity, tag)),
          _Fact(
            label: l10n.productDetailStatus,
            value: product.isActive ? l10n.productDetailActive : l10n.productDetailInactive,
            muted: !product.isActive,
          ),
        ],
      ),
      if (product.hasVariants && variants.isNotEmpty) ...[
        SizedBox(height: AppSpacing.xxl),
        Text(l10n.productDetailVariants(variants.length).toUpperCase(), style: AppText.labelSection),
        SizedBox(height: AppSpacing.md),
        ListBox(
          children: [
            for (final variant in variants) _VariantLine(variant: variant, tag: tag),
          ],
        ),
      ],
      // The web keeps these on the product's row in the table; `17`'s rows
      // carry no actions here (approved rule, brief §25.29), so the details
      // screen is where they live. Not in the `17a` frame, which predates all
      // three screens.
      SizedBox(height: AppSpacing.xxl),
      Text(l10n.productDetailActions.toUpperCase(), style: AppText.labelSection),
      SizedBox(height: AppSpacing.md),
      ListBox(
        children: [
          AppListRow(
            title: l10n.stockAdjustTitle,
            meta: l10n.productDetailAdjustMeta,
            onTap: () => _adjust(product),
          ),
          AppListRow(
            title: l10n.expensesTitle,
            meta: l10n.productDetailExpensesMeta,
            onTap: _openExpenses,
          ),
          AppListRow(
            title: l10n.productDeleteTitle,
            meta: l10n.productDetailDeleteMeta,
            titleColor: AppColors.accentAlert,
            onTap: () => _delete(product),
          ),
        ],
      ),
    ];
  }
}

/// The main image and, when there are several, the thumbnails under it — or
/// the web's "No images" box.
class _Images extends StatelessWidget {
  const _Images({required this.urls, required this.shown, required this.onShow});

  final List<String> urls;
  final int shown;
  final ValueChanged<int> onShow;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    if (urls.isEmpty) {
      return Container(
        height: 41.03.w, // 160
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(AppIcons.box, size: 7.18.w, color: AppColors.textMuted), // 28
            SizedBox(height: AppSpacing.sm),
            Text(l10n.productDetailNoImages.toUpperCase(), style: AppText.labelMeta),
          ],
        ),
      );
    }

    Widget image(String url, BoxFit fit) => CachedNetworkImage(
          imageUrl: url,
          fit: fit,
          placeholder: (_, _) => const ColoredBox(color: AppColors.surface),
          errorWidget: (_, _, _) => Center(
            child: AppIcon(AppIcons.box, size: 6.15.w, color: AppColors.textMuted),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(color: AppColors.ink, child: image(urls[shown], BoxFit.contain)),
          ),
        ),
        if (urls.length > 1) ...[
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 14.36.w, // 56
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: urls.length,
              separatorBuilder: (_, _) => SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => onShow(index),
                child: Container(
                  width: 14.36.w,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: index == shown ? AppColors.ruleStrong : AppColors.rule,
                      width: AppStroke.hairline,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: image(urls[index], BoxFit.cover),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// One of the web's label / value details.
class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, this.muted = false});

  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.bodyS.copyWith(color: AppColors.textMuted))),
          SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              style: AppText.title.copyWith(color: muted ? AppColors.textMuted : AppColors.textPrimary),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of the web's variants table: name, SKU, cost, price, quantity,
/// status.
class _VariantLine extends StatelessWidget {
  const _VariantLine({required this.variant, required this.tag});

  final ProductVariant variant;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final sku = variant.sku?.trim();

    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variant.name,
                  style: AppText.title.copyWith(
                    color: variant.isActive ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text((sku == null || sku.isEmpty ? '–' : sku).toUpperCase(), style: AppText.labelMeta),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  '${l10n.productVariantCost} ${Money.price(variant.costPrice, tag)}  ·  '
                  '${l10n.productVariantPrice} ${Money.price(variant.sellingPrice, tag)}',
                  style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.32),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Money.grouped(variant.quantity, tag),
                style: AppText.numeralS.copyWith(
                  // The web's at-threshold marker.
                  color: variant.isAtThreshold ? AppColors.accentAlert : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                (variant.isActive ? l10n.productDetailActive : l10n.productDetailInactive).toUpperCase(),
                style: AppText.labelMicro.copyWith(
                  color: variant.isActive ? AppColors.textSecondary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Two tiles side by side, kept level when a label wraps (as on `16`).
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
