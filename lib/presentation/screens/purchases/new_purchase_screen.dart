import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/phone.dart';
import '../../../data/models/order.dart';
import '../../../data/models/product.dart';
import '../../../data/models/supplier.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/purchase_repository.dart';
import '../../../data/repositories/supplier_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/form_draft_store.dart';
import '../../viewmodels/new_purchase_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_scope.dart';
import '../../widgets/date_picker_sheet.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import '../orders/order_form_widgets.dart';
import '../orders/order_status_pill.dart';
import '../sales/sale_widgets.dart';
import 'purchase_widgets.dart';

/// `New purchase` (Figma `673:16716`, `· choisir un fournisseur` `673:16857`)
/// — the web's `stock/purchases/new`.
///
/// The supplier and the date, the lines at cost, a note, then what is paid to
/// the supplier now. Nothing enters stock until the delivery is received, and
/// the footer says so.
class NewPurchaseScreen extends StatefulWidget {
  const NewPurchaseScreen({super.key});

  @override
  State<NewPurchaseScreen> createState() => _NewPurchaseScreenState();
}

class _NewPurchaseScreenState extends State<NewPurchaseScreen> {
  late final NewPurchaseViewModel _model = NewPurchaseViewModel(
    purchases: context.read<PurchaseRepository>(),
    suppliers: context.read<SupplierRepository>(),
    products: context.read<ProductRepository>(),
    drafts: context.read<FormDraftStore?>(),
  );

  // Queries, not values — not worth keeping across a restart.
  final _supplierSearch = TextEditingController();
  final _productSearch = TextEditingController();
  final _supplierFocus = FocusNode();
  final _productFocus = FocusNode();

  /// Which variant product has its list open in the picker.
  String? _expanded;

  @override
  void initState() {
    super.initState();
    _supplierSearch.addListener(() => setState(() {}));
    _productSearch.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
  }

  @override
  void dispose() {
    _supplierSearch.dispose();
    _productSearch.dispose();
    _supplierFocus.dispose();
    _productFocus.dispose();
    _model.dispose();
    super.dispose();
  }

  bool get _dirty =>
      _model.lines.isNotEmpty || _model.supplier != null || _model.notes.value.trim().isNotEmpty;

  Future<bool> _onBack() async {
    if (_model.isBusy) return false;
    if (!_dirty) return true;
    return showLeaveSheet(context, body: L10n.of(context).newPurchaseLeaveBody);
  }

  void _pickSupplier(Supplier supplier) {
    _model.setSupplier(supplier);
    _supplierSearch.clear();
    _supplierFocus.unfocus();
  }

  void _addLine(Product product, [ProductVariant? variant]) {
    _model.addLine(product, variant);
    _productSearch.clear();
    _productFocus.unfocus();
    setState(() => _expanded = null);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePickerSheet(
      context,
      title: L10n.of(context).newPurchaseDateTitle,
      initial: _model.purchaseDate,
      // The API refuses a purchase more than 24 h ahead.
      lastDay: DateTime.now(),
    );
    if (picked != null) _model.setPurchaseDate(picked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final l10n = L10n.of(context);
    final purchase = await _model.createPurchase();
    if (!mounted) return;
    if (purchase == null) {
      if (_model.submitError case final error?) {
        AppToast.info(context, apiErrorMessage(error, l10n));
      }
      return;
    }
    AppToast.success(context, l10n.newPurchaseCreatedToast(purchase.purchaseNumber));
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.purchases);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => BackIntercept(
        active: _dirty || _model.isBusy,
        onBack: _onBack,
        child: Scaffold(
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
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.gutterTight,
                      0,
                      AppSpacing.gutterTight,
                      AppSpacing.xl,
                    ),
                    children: _content(l10n),
                  ),
                ),
                _footer(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(L10n l10n) {
    final tag = Localizations.localeOf(context).toLanguageTag();

    if (!_model.isLoaded && _model.error != null) {
      return [
        Text(l10n.purchasesNew, style: AppText.displayM),
        SizedBox(height: AppSpacing.xl),
        ApiErrorLine(error: _model.error),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
        ),
      ];
    }

    return [
      Text(l10n.purchasesNew, style: AppText.displayM),
      SizedBox(height: AppSpacing.xl),
      ..._supplierBlock(l10n, tag),
      SizedBox(height: AppSpacing.xl),
      ..._productsBlock(l10n, tag),
      SizedBox(height: AppSpacing.xl),
      SectionLabel(nested: true, label: l10n.newOrderNotesSection),
      AppTextField(
        label: l10n.newOrderNotes,
        controller: _model.notes.controller,
        focusNode: _model.notes.focusNode,
        placeholder: l10n.newPurchaseNotesHint,
        minLines: 2,
        inputFormatters: [LengthLimitingTextInputFormatter(1000)],
      ),
      SizedBox(height: AppSpacing.xl),
      ..._summaryBlock(l10n, tag),
    ];
  }

  // ---- Supplier ----

  List<Widget> _supplierBlock(L10n l10n, String tag) {
    final query = _supplierSearch.text.trim().toLowerCase();
    final matches = query.isEmpty
        ? const <Supplier>[]
        : [
            for (final supplier in _model.suppliers)
              if (supplier.name.toLowerCase().contains(query) ||
                  (supplier.phone ?? '').toLowerCase().contains(query))
                supplier,
          ].take(6).toList();

    return [
      SectionLabel(
        nested: true,
        label: l10n.purchaseFieldSupplier,
        trailing: formatPickedDay(_model.purchaseDate, tag),
        onTrailingTap: _pickDate,
      ),
      if (_model.supplier case final chosen?)
        ChosenChip(label: chosen.name, onClear: () => _model.setSupplier(null))
      else ...[
        AppTextField(
          label: l10n.newPurchaseSearchSupplier,
          controller: _supplierSearch,
          focusNode: _supplierFocus,
          placeholder: l10n.newPurchaseSearchSupplierHint,
          inputFormatters: [LengthLimitingTextInputFormatter(80)],
        ),
        if (query.isNotEmpty) ...[
          SizedBox(height: AppSpacing.sm),
          PickerSuggestions(
            empty: l10n.newPurchaseNoSuppliers,
            children: [
              for (final supplier in matches)
                SuggestionRow(
                  title: supplier.name,
                  meta: supplier.phone == null ? null : Phone.format(supplier.phone!),
                  onTap: () => _pickSupplier(supplier),
                ),
            ],
          ),
        ],
      ],
    ];
  }

  // ---- Products ----

  List<Widget> _productsBlock(L10n l10n, String tag) {
    final query = _productSearch.text.trim().toLowerCase();
    final matches = query.isEmpty
        ? const <Product>[]
        : [
            for (final product in _model.products)
              if (product.name.toLowerCase().contains(query) ||
                  product.sku.toLowerCase().contains(query))
                product,
          ].take(6).toList();

    return [
      SectionLabel(nested: true, label: l10n.newOrderProductsSection),
      if (_model.droppedDraftLines > 0) ...[
        DashedBox(
          child: Text(
            l10n.newOrderDraftLinesDropped(_model.droppedDraftLines),
            style: AppText.bodyS.copyWith(color: AppColors.accentAlert, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
      ],
      AppTextField(
        label: l10n.newOrderAddProducts,
        controller: _productSearch,
        focusNode: _productFocus,
        placeholder: l10n.newOrderProductHint,
        inputFormatters: [LengthLimitingTextInputFormatter(80)],
      ),
      if (query.isNotEmpty) ...[
        SizedBox(height: AppSpacing.sm),
        PickerSuggestions(
          empty: l10n.newOrderNoProducts,
          children: [for (final product in matches) ..._productRows(l10n, tag, product)],
        ),
      ],
      SizedBox(height: AppSpacing.md),
      if (_model.lines.isEmpty)
        DashedBox(
          child: Text(
            l10n.newOrderNoLines,
            style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.4),
            textAlign: TextAlign.center,
          ),
        )
      else
        for (final (index, line) in _model.lines.indexed)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: DraftLineCard(
              key: ValueKey('${line.product.id}/${line.variant?.id}'),
              index: index,
              line: line,
              localeTag: tag,
              priceLabel: l10n.newPurchaseUnitCost,
              limitStock: false,
              onRemove: () => _model.removeLine(index),
              onQuantity: (value) => _model.setLineQuantity(index, value),
              onPrice: (value) => _model.setLineCost(index, value),
            ),
          ),
    ];
  }

  /// Every product is offered, stock or not, at its cost; the stock shown is
  /// what is on hand now — useful when deciding how much to order.
  List<Widget> _productRows(L10n l10n, String tag, Product product) {
    String stock(int q) =>
        (q > 0 ? l10n.newOrderInStock(q) : l10n.newOrderOutOfStock).toUpperCase();

    if (!product.hasVariants) {
      return [
        SuggestionRow(
          title: product.name,
          meta: product.sku.toUpperCase(),
          trailing: Money.exact(product.costPrice, tag),
          trailingMeta: stock(product.quantity),
          onTap: () => _addLine(product),
        ),
      ];
    }

    final variants = [
      for (final v in product.variants)
        if (v.isActive) v,
    ];
    final open = _expanded == product.id;

    return [
      SuggestionRow(
        title: product.name,
        meta: product.sku.toUpperCase(),
        trailingMeta: l10n.newOrderVariantCount(variants.length).toUpperCase(),
        onTap: () => setState(() => _expanded = open ? null : product.id),
      ),
      if (open)
        for (final variant in variants)
          SuggestionRow(
            indented: true,
            title: variant.name,
            trailing: Money.exact(variant.costPrice, tag),
            trailingMeta: stock(variant.quantity),
            onTap: () => _addLine(product, variant),
          ),
    ];
  }

  // ---- Payment to the supplier ----

  List<Widget> _summaryBlock(L10n l10n, String tag) {
    String money(double v) => Money.exact(v, tag);

    return [
      SectionLabel(nested: true, label: l10n.newPurchaseSummary),
      SaleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.newOrderTotal.toUpperCase(), style: AppText.labelMeta),
            SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: Text(money(_model.total), style: AppText.numeralL)),
                Text(
                  l10n.ordersRowItems(_model.lines.length).toUpperCase(),
                  style: AppText.labelMicro,
                ),
              ],
            ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.md),
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: GestureDetector(
          onTap: _model.payInFull,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xs),
            child: Text(l10n.newPurchasePayInFull, style: AppText.link),
          ),
        ),
      ),
      AppTextField(
        label: l10n.newPurchaseAmountPaid,
        controller: _model.paid.controller,
        focusNode: _model.paid.focusNode,
        placeholder: '0',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          LengthLimitingTextInputFormatter(12),
        ],
      ),
      if (_model.overpaid) ...[
        SizedBox(height: AppSpacing.sm),
        Text(l10n.newPurchaseOverpaid(money(_model.total)), style: AppText.labelMeta),
      ],
      SizedBox(height: AppSpacing.md),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          children: [
            Text(
              (_model.remaining > 0 ? l10n.purchaseFieldRemaining : l10n.newPurchaseFullyPaid)
                  .toUpperCase(),
              style: AppText.labelMeta,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(money(_model.remaining), style: AppText.numeralL),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.md),
      Row(
        children: [
          Text(l10n.newSaleStatus, style: AppText.bodyS),
          const Spacer(),
          if (_model.lines.isNotEmpty) purchasePayPill(_model.paymentStatus, l10n),
        ],
      ),
      SizedBox(height: AppSpacing.md),
      Text(l10n.newOrderPaymentMethod.toUpperCase(), style: AppText.labelMeta),
      SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: 1.54.w,
        runSpacing: 1.54.w,
        children: [
          for (final method in PaymentMethod.values)
            AppFilterChip(
              label: paymentMethodLabel(method, l10n),
              selected: _model.paymentMethod == method,
              onTap: () => _model.setPaymentMethod(method),
            ),
        ],
      ),
    ];
  }

  Widget _footer(L10n l10n) {
    final message = _model.hasNoItems ? l10n.newOrderErrNoItems : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutterTight,
        AppSpacing.md,
        AppSpacing.gutterTight,
        3.32.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message ?? l10n.newPurchaseStockNote,
            style: message == null
                ? AppText.labelMeta
                : AppText.bodyS.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: _model.canSubmit ? _submit : null,
            child: _model.isBusy && _model.isLoaded
                ? SizedBox.square(
                    dimension: AppSpacing.gutterTight,
                    child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                  )
                : Text(l10n.newPurchaseSubmit),
          ),
          SizedBox(height: AppSpacing.sm),
          OutlinedButton(onPressed: () => BackScope.back(context), child: Text(l10n.commonCancel)),
        ],
      ),
    );
  }
}
