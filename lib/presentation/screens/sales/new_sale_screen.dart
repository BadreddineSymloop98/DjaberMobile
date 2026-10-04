import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/phone.dart';
import '../../../data/models/client.dart';
import '../../../data/models/order.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/sale_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/form_draft_store.dart';
import '../../viewmodels/new_sale_view_model.dart';
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
import 'sale_widgets.dart';

/// `New sale` (Figma `670:15943`, `· paiement partiel` `670:16131`) — the
/// web's `stock/sales/new`.
///
/// The customer and the date, the product lines, a note, then the payment
/// summary: the total, what was received, what is left (or the change to
/// hand back), the status that follows, and the method.
class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  late final NewSaleViewModel _model = NewSaleViewModel(
    sales: context.read<SaleRepository>(),
    clients: context.read<ClientRepository>(),
    products: context.read<ProductRepository>(),
    drafts: context.read<FormDraftStore?>(),
  );

  // Queries, not values — not worth keeping across a restart.
  final _clientSearch = TextEditingController();
  final _productSearch = TextEditingController();
  final _clientFocus = FocusNode();
  final _productFocus = FocusNode();

  /// Which variant product has its list open in the picker.
  String? _expanded;

  @override
  void initState() {
    super.initState();
    _clientSearch.addListener(() => setState(() {}));
    _productSearch.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
  }

  @override
  void dispose() {
    _clientSearch.dispose();
    _productSearch.dispose();
    _clientFocus.dispose();
    _productFocus.dispose();
    _model.dispose();
    super.dispose();
  }

  bool get _dirty =>
      _model.lines.isNotEmpty ||
      _model.client != null ||
      _model.name.value.trim().isNotEmpty ||
      _model.phone.value.trim().isNotEmpty ||
      _model.notes.value.trim().isNotEmpty;

  Future<bool> _onBack() async {
    if (_model.isBusy) return false;
    if (!_dirty) return true;
    return showLeaveSheet(context, body: L10n.of(context).newSaleLeaveBody);
  }

  void _pickClient(Client client) {
    _model.setClient(client);
    _clientSearch.clear();
    _clientFocus.unfocus();
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
      title: L10n.of(context).newSaleDateTitle,
      initial: _model.saleDate,
      // The API refuses a sale more than 24 h ahead.
      lastDay: DateTime.now(),
    );
    if (picked != null) _model.setSaleDate(picked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final l10n = L10n.of(context);
    final sale = await _model.createSale();
    if (!mounted) return;
    if (sale == null) {
      if (_model.submitError case final error?) {
        AppToast.info(context, apiErrorMessage(error, l10n));
      }
      return;
    }
    AppToast.success(context, l10n.newSaleCreatedToast(sale.saleNumber));
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.sales);
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
        Text(l10n.salesNew, style: AppText.displayM),
        SizedBox(height: AppSpacing.xl),
        ApiErrorLine(error: _model.error),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
        ),
      ];
    }

    return [
      Text(l10n.salesNew, style: AppText.displayM),
      SizedBox(height: AppSpacing.xl),
      ..._clientBlock(l10n, tag),
      SizedBox(height: AppSpacing.xl),
      ..._productsBlock(l10n, tag),
      SizedBox(height: AppSpacing.xl),
      SectionLabel(nested: true, label: l10n.newOrderNotesSection),
      AppTextField(
        label: l10n.newOrderNotes,
        controller: _model.notes.controller,
        focusNode: _model.notes.focusNode,
        placeholder: l10n.newSaleNotesHint,
        minLines: 2,
        inputFormatters: [LengthLimitingTextInputFormatter(1000)],
      ),
      SizedBox(height: AppSpacing.xl),
      ..._summaryBlock(l10n, tag),
    ];
  }

  // ---- Customer ----

  List<Widget> _clientBlock(L10n l10n, String tag) {
    final query = _clientSearch.text.trim().toLowerCase();
    final matches = query.isEmpty
        ? const <Client>[]
        : [
            for (final client in _model.clients)
              if (client.name.toLowerCase().contains(query) ||
                  (client.phone ?? '').toLowerCase().contains(query))
                client,
          ].take(6).toList();

    return [
      SectionLabel(
        nested: true,
        label: l10n.newOrderClientSection,
        trailing: formatPickedDay(_model.saleDate, tag),
        onTrailingTap: _pickDate,
      ),
      if (_model.client case final chosen?)
        ChosenChip(label: chosen.name, onClear: () => _model.setClient(null))
      else ...[
        AppTextField(
          label: l10n.newOrderSearchClient,
          controller: _clientSearch,
          focusNode: _clientFocus,
          placeholder: l10n.newOrderSearchClientHint,
          inputFormatters: [LengthLimitingTextInputFormatter(80)],
        ),
        if (query.isNotEmpty) ...[
          SizedBox(height: AppSpacing.sm),
          PickerSuggestions(
            empty: l10n.newOrderNoClients,
            children: [
              for (final client in matches)
                SuggestionRow(
                  title: client.name,
                  meta: client.phone == null ? null : Phone.format(client.phone!),
                  onTap: () => _pickClient(client),
                ),
            ],
          ),
        ],
        SizedBox(height: AppSpacing.md),
        Text(l10n.newOrderOrType.toUpperCase(), style: AppText.labelMeta),
        SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: l10n.newOrderClientName,
                controller: _model.name.controller,
                focusNode: _model.name.focusNode,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [LengthLimitingTextInputFormatter(120)],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppTextField(
                label: l10n.newOrderClientPhone,
                controller: _model.phone.controller,
                focusNode: _model.phone.focusNode,
                errorText: _model.phoneIncomplete && !_model.phone.hasFocus
                    ? l10n.newSaleErrPhone
                    : null,
                keyboardType: TextInputType.phone,
                inputFormatters: const [AlgerianPhoneFormatter()],
              ),
            ),
          ],
        ),
      ],
    ];
  }

  // ---- Products ----

  List<Widget> _productsBlock(L10n l10n, String tag) {
    final query = _productSearch.text.trim().toLowerCase();
    final matches = query.isEmpty
        ? const <Product>[]
        : [
            for (final product in _model.sellableProducts)
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
              // Keyed by what the line is, so removing one line does not hand
              // its typed quantity to the next.
              key: ValueKey('${line.product.id}/${line.variant?.id}'),
              index: index,
              line: line,
              localeTag: tag,
              onRemove: () => _model.removeLine(index),
              onQuantity: (value) => _model.setLineQuantity(index, value),
              onPrice: (value) => _model.setLinePrice(index, value),
            ),
          ),
    ];
  }

  List<Widget> _productRows(L10n l10n, String tag, Product product) {
    if (!product.hasVariants) {
      return [
        SuggestionRow(
          title: product.name,
          meta: product.sku.toUpperCase(),
          trailing: Money.exact(product.sellingPrice, tag),
          trailingMeta: l10n.newOrderInStock(product.quantity).toUpperCase(),
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
            trailing: Money.exact(variant.sellingPrice, tag),
            trailingMeta: variant.quantity > 0
                ? l10n.newOrderInStock(variant.quantity).toUpperCase()
                : l10n.newOrderOutOfStock.toUpperCase(),
            disabled: variant.quantity <= 0,
            onTap: () => _addLine(product, variant),
          ),
    ];
  }

  // ---- Payment summary ----

  List<Widget> _summaryBlock(L10n l10n, String tag) {
    String money(double v) => Money.exact(v, tag);
    final overstocked = _model.overstockedLines;
    final change = _model.amountPaid - _model.total;
    final status = _model.paymentStatus;

    return [
      SectionLabel(nested: true, label: l10n.newSaleSummary),
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
            child: Text(l10n.newSalePayInFull, style: AppText.link),
          ),
        ),
      ),
      AppTextField(
        label: l10n.newOrderAmountPaid,
        controller: _model.paid.controller,
        focusNode: _model.paid.focusNode,
        placeholder: '0',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          LengthLimitingTextInputFormatter(12),
        ],
      ),
      // More handed over than owed: the server keeps the total, the merchant
      // hands back the difference.
      if (change > 0 && _model.total > 0) ...[
        SizedBox(height: AppSpacing.sm),
        Text(l10n.newSaleChangeDue(money(change)), style: AppText.labelMeta),
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
              (_model.remaining > 0 ? l10n.newOrderRemainingDebt : l10n.newSaleFullyPaid)
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
          // Nothing to pay yet reads as nothing, not as *Payée*.
          if (_model.lines.isNotEmpty) salePaymentPill(status, l10n),
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
      if (overstocked.isNotEmpty) ...[
        SizedBox(height: AppSpacing.md),
        for (final line in overstocked)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              l10n.newOrderErrStock(line.name, line.available),
              style: AppText.bodyS.copyWith(color: AppColors.accentAlert),
            ),
          ),
      ],
    ];
  }

  Widget _footer(L10n l10n) {
    final message = _model.hasNoItems
        ? l10n.newOrderErrNoItems
        : _model.phoneIncomplete
        ? l10n.newSaleErrPhone
        : null;

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
            message ?? l10n.newSaleStockNote,
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
                : Text(l10n.newSaleSubmit),
          ),
          SizedBox(height: AppSpacing.sm),
          OutlinedButton(onPressed: () => BackScope.back(context), child: Text(l10n.commonCancel)),
        ],
      ),
    );
  }
}
