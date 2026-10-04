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
import '../../../data/repositories/delivery_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/form_draft_store.dart';
import '../../viewmodels/new_order_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_scope.dart';
import '../../widgets/date_picker_sheet.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import 'order_form_widgets.dart';
import 'order_status_pill.dart';

/// `New order` (Figma `652:12048`) — the web's `stock/orders/new`.
///
/// Four blocks down the screen: the client and where it goes, the product
/// lines, a note, then the summary that adds it all up and asks how much was
/// paid.
///
/// **Creating an order takes the stock immediately**, whatever status it is
/// given — so the form says so above the button, and it refuses to send a line
/// that is over what is on hand rather than letting the server roll the whole
/// order back.
class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  late final NewOrderViewModel _model = NewOrderViewModel(
    orders: context.read<OrderRepository>(),
    clients: context.read<ClientRepository>(),
    products: context.read<ProductRepository>(),
    delivery: context.read<DeliveryRepository>(),
    // What keeps the form alive across the splash that plays when the app is
    // left and reopened.
    drafts: context.read<FormDraftStore?>(),
  );

  // The two search boxes are the screen's own: they hold a query, not a value,
  // and a query is not worth keeping across a restart.
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
      _model.address.value.trim().isNotEmpty;

  Future<bool> _onBack() async {
    if (_model.isBusy) return false;
    if (!_dirty) return true;
    return showLeaveSheet(context, body: L10n.of(context).productFormLeaveBody);
  }

  void _pickClient(Client client) {
    // The model fills the address from the client when there is none typed.
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
    final l10n = L10n.of(context);
    final picked = await showDatePickerSheet(
      context,
      title: l10n.dateFrom,
      initial: _model.orderDate,
    );
    if (picked != null) _model.setOrderDate(picked);
  }

  Future<void> _submit() async {
    final l10n = L10n.of(context);
    final order = await _model.createOrder();
    if (order == null || !mounted) {
      if (_model.submitError case final error?) {
        if (mounted) AppToast.info(context, apiErrorMessage(error, l10n));
      }
      return;
    }
    AppToast.success(context, l10n.orderCreatedToast);
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.orders);
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

    if (_model.wilayas.isEmpty && _model.error != null) {
      return [
        ApiErrorLine(error: _model.error),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
        ),
      ];
    }

    return [
      Text(l10n.newOrderTitle, style: AppText.displayM),
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
        placeholder: l10n.newOrderNotesHint,
        minLines: 2,
        inputFormatters: [LengthLimitingTextInputFormatter(1000)],
      ),
      SizedBox(height: AppSpacing.xl),
      ..._summaryBlock(l10n, tag),
    ];
  }

  // ---- Client ----

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
        trailing: formatPickedDay(_model.orderDate, tag),
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
                  meta: client.phone,
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
                isRequired: true,
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
                isRequired: true,
                keyboardType: TextInputType.phone,
                inputFormatters: const [AlgerianPhoneFormatter()],
              ),
            ),
          ],
        ),
      ],
      SizedBox(height: AppSpacing.md),
      AppTextField(
        label: l10n.newOrderDeliveryAddress,
        controller: _model.address.controller,
        focusNode: _model.address.focusNode,
        placeholder: l10n.orderAddressHint,
        minLines: 2,
        inputFormatters: [LengthLimitingTextInputFormatter(1000)],
      ),
      SizedBox(height: AppSpacing.md),
      // A select, not chips. 58 wilayas in a horizontal strip means scrolling
      // sideways past dozens of them to find one, with no sense of how far in
      // it is — and the app already has the answer the brief's own adaptation
      // rules name for a web `<select>`: a field that opens a sheet. The
      // sheet also keeps the merchant's place in a long form, which a strip
      // that grows the layout does not.
      AppSelectField<int>(
        label: l10n.newOrderWilaya,
        placeholder: l10n.newOrderWilayaHint,
        isRequired: true,
        sheetTitle: l10n.newOrderWilaya,
        options: [
          for (final wilaya in _model.wilayas)
            SelectOption(
              value: wilaya.id,
              label: wilaya.label(Localizations.localeOf(context).languageCode),
            ),
        ],
        value: _model.wilayaId,
        // Still loading, or the list failed: the field stays readable and
        // simply does not open an empty sheet.
        enabled: _model.wilayas.isNotEmpty,
        onChanged: _model.setWilaya,
      ),
      SizedBox(height: AppSpacing.md),
      AppTextField(
        label: l10n.newOrderCommune,
        controller: _model.commune.controller,
        focusNode: _model.commune.focusNode,
        placeholder: l10n.newOrderCommuneHint,
        inputFormatters: [LengthLimitingTextInputFormatter(80)],
      ),
      SizedBox(height: AppSpacing.md),
      GestureDetector(
        onTap: () => _model.setStopdesk(!_model.isStopdesk),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            OrderTick(
              checked: _model.isStopdesk,
              onTap: () => _model.setStopdesk(!_model.isStopdesk),
              label: l10n.newOrderStopdesk,
            ),
            SizedBox(width: 1.28.w),
            Expanded(
              child: Text(
                l10n.newOrderStopdesk,
                style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
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
      // A draft came back with lines whose product has since been deleted or
      // sold out. Said plainly, because it changes the total the merchant is
      // about to commit to.
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
          children: [
            for (final product in matches) ..._productRows(l10n, tag, product),
          ],
        ),
      ],
      SizedBox(height: AppSpacing.md),
      if (_model.lines.isEmpty)
        DashedBox(child: Text(
          l10n.newOrderNoLines,
          style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.4),
          textAlign: TextAlign.center,
        ))
      else
        for (final (index, line) in _model.lines.indexed)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: DraftLineCard(
              // Keyed by what the line is: unkeyed, removing a line handed its
              // fields (and their listeners) to the line below it.
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

  /// A plain product is one row; a variant product is a row that opens into
  /// its variants. Out-of-stock variants are **shown and dimmed** rather than
  /// hidden, so the merchant can see the size exists and is simply gone.
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

    final variants = [for (final v in product.variants) if (v.isActive) v];
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

  // ---- Summary ----

  List<Widget> _summaryBlock(L10n l10n, String tag) {
    String money(double v) => Money.exact(v, tag);
    final overstocked = _model.overstockedLines;

    return [
      SectionLabel(nested: true, label: l10n.newOrderSummary),
      Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          children: [
            _SummaryRow(label: l10n.newOrderSubtotal, value: money(_model.subtotal)),
            SizedBox(height: AppSpacing.xs),
            _SummaryRow(
              label: l10n.newOrderDelivery,
              value: _model.isQuotingFee ? '…' : money(_model.deliveryFee),
            ),
            SizedBox(height: AppSpacing.md),
            const Divider(
              height: AppStroke.hairline,
              thickness: AppStroke.hairline,
              color: AppColors.rule,
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l10n.newOrderTotal.toUpperCase(), style: AppText.labelMeta),
                const Spacer(),
                Text(money(_model.total), style: AppText.numeralL),
              ],
            ),
            SizedBox(height: 0.77.w),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                l10n.ordersRowItems(_model.lines.length).toUpperCase(),
                style: AppText.labelMicro,
              ),
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
            child: Text(l10n.newOrderPayInFull, style: AppText.link),
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
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          LengthLimitingTextInputFormatter(12),
        ],
      ),
      SizedBox(height: AppSpacing.sm),
      Text(l10n.newOrderCodHint, style: AppText.labelMeta),
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
              (_model.remaining > 0 ? l10n.newOrderRemainingDebt : l10n.newOrderFullyPaid)
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
          Text(l10n.newOrderPayment, style: AppText.bodyS),
          const Spacer(),
          OrderStatusPill(
            label: paymentStatusLabel(_model.paymentStatus, l10n),
            tone: _model.paymentStatus == PaymentStatus.paid ? PillTone.settled : PillTone.moving,
          ),
        ],
      ),
      SizedBox(height: AppSpacing.md),
      Text(l10n.newOrderStatus.toUpperCase(), style: AppText.labelMeta),
      SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: 1.54.w,
        runSpacing: 1.54.w,
        children: [
          // Only the two the backend takes safely: it stores whatever it is
          // sent here **without validating it**, so the form never offers a
          // status that would persist as nonsense.
          for (final status in [OrderStatus.pending, OrderStatus.confirmed])
            AppFilterChip(
              label: orderStatusLabel(status, l10n),
              selected: _model.status == status,
              onTap: () => _model.setStatus(status),
            ),
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
    final problem = _model.problem;
    final message = switch (problem) {
      NewOrderProblem.noItems => l10n.newOrderErrNoItems,
      NewOrderProblem.noClientName => l10n.newOrderErrName,
      NewOrderProblem.noPhone => l10n.newOrderErrPhone,
      NewOrderProblem.noWilaya => l10n.newOrderErrWilaya,
      NewOrderProblem.noAddress => l10n.newOrderErrAddress,
      null => null,
    };

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
          if (message != null) ...[
            Text(
              message,
              style: AppText.bodyS.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
          ] else ...[
            Text(l10n.newOrderStockReserved, style: AppText.labelMeta, textAlign: TextAlign.center),
            SizedBox(height: AppSpacing.sm),
          ],
          FilledButton(
            onPressed: _model.canSubmit ? _submit : null,
            child: _model.isBusy
                ? SizedBox.square(
                    dimension: AppSpacing.gutterTight,
                    child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                  )
                : Text(l10n.newOrderSubmit),
          ),
          SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => BackScope.back(context),
            child: Text(l10n.commonCancel),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppText.bodyS.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: AppText.bodyS),
      ],
    );
  }
}
