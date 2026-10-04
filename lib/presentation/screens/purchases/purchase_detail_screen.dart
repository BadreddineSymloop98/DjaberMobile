import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/purchase.dart';
import '../../../data/repositories/purchase_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/purchase_detail_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/date_picker_sheet.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import '../orders/order_status_pill.dart';
import '../sales/sale_widgets.dart';
import 'purchase_widgets.dart';

/// `Purchase detail` (Figma `672:18732`, `· reçu` `672:18812`) — the web's
/// purchase modal, as a screen.
///
/// The supplier and where the goods and the money stand, every line with what
/// was ordered and what arrived, the total, then the two things left to do —
/// *Marquer comme payé* and *Réceptionner la livraison* — inside the payment
/// card, as the frame draws them. *Annuler l'achat* (decided 2026-10-04) sits
/// last, for an open purchase that can no longer simply be deleted.
class PurchaseDetailScreen extends StatefulWidget {
  const PurchaseDetailScreen({super.key, required this.purchaseId, this.initial});

  final String purchaseId;

  /// The row the list handed over, so the screen draws at once.
  final Purchase? initial;

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  late final PurchaseDetailViewModel _model = PurchaseDetailViewModel(
    purchases: context.read<PurchaseRepository>(),
    purchaseId: widget.purchaseId,
    initial: widget.initial,
  );

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

  Future<void> _markPaid() async {
    final l10n = L10n.of(context);
    final result = await _model.markPaid();
    if (result == null || !mounted) return;
    if (result.errorOrNull case final error?) {
      AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    AppToast.success(context, l10n.purchaseMarkedPaidToast);
  }

  Future<void> _receive() async {
    final purchase = _model.purchase;
    if (purchase == null) return;
    final updated = await showReceiveSheet(context, purchase: purchase);
    if (updated != null && mounted) _model.adopt(updated);
  }

  /// Says exactly what the rollback will do to this purchase — the units that
  /// leave stock, the payment that leaves the caisse — before doing it.
  Future<void> _cancel() async {
    final purchase = _model.purchase;
    if (purchase == null) return;
    final l10n = L10n.of(context);
    final tag = Localizations.localeOf(context).toLanguageTag();
    final confirmed = await showDestructiveSheet(
      context,
      title: l10n.purchaseCancel,
      body: l10n.purchaseCancelBody(purchase.purchaseNumber),
      confirmLabel: l10n.purchaseCancel,
      cancelLabel: l10n.purchaseCancelKeep,
      noticeTitle: l10n.purchaseCancelNoticeTitle,
      noticeBody: [
        if (purchase.unitsReceived > 0) l10n.purchaseCancelStock(purchase.unitsReceived),
        if (purchase.amountPaid > 0)
          l10n.purchaseCancelMoney(Money.exact(purchase.amountPaid, tag)),
        l10n.purchaseCancelFinal,
      ].join('\n\n'),
    );
    if (!confirmed || !mounted) return;
    final result = await _model.cancel();
    if (result == null || !mounted) return;
    if (result.errorOrNull case final error?) {
      AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    AppToast.success(context, l10n.purchaseCancelledToast(purchase.purchaseNumber));
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
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.gutterTight,
                      0,
                      AppSpacing.gutterTight,
                      3.32.h,
                    ),
                    children: _content(l10n),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(L10n l10n) {
    final purchase = _model.purchase;
    if (purchase == null) {
      return [
        if (_model.isLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
            child: const SaleSpinner(),
          )
        else ...[
          ApiErrorLine(error: _model.error),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
          ),
        ],
      ];
    }

    final tag = Localizations.localeOf(context).toLanguageTag();
    String money(double v) => Money.exact(v, tag);
    String when(DateTime d) => '${formatPickedDay(d.toLocal(), tag)} ${saleTime(d)}';
    final p = purchase;
    final cancelled = p.status == PurchaseStatus.cancelled;
    final busy = _model.busyAction;

    return [
      Text(l10n.purchaseEyebrow, style: AppText.labelMeta),
      SizedBox(height: 1.54.w),
      Text(p.purchaseNumber, style: AppText.displayM),
      SizedBox(height: 1.54.w),
      Text(when(p.purchaseDate), style: AppText.labelMeta),
      SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: 1.54.w,
        runSpacing: 1.54.w,
        children: [purchaseStatusPill(p.status, l10n), purchasePayPill(p.paymentStatus, l10n)],
      ),
      SizedBox(height: AppSpacing.xl),
      SaleCard(
        child: Column(
          children: [
            SaleFact(
              label: l10n.purchaseFieldSupplier,
              value: p.supplierName ?? l10n.purchaseNoSupplier,
            ),
            SaleFact(label: l10n.saleFieldDate, value: when(p.purchaseDate)),
            SaleFact(
              label: l10n.purchaseFieldReceiving,
              value: purchaseStatusLabel(p.status, l10n),
            ),
            if (p.receivedDate case final received?)
              SaleFact(label: l10n.purchaseFieldReceivedOn, value: when(received)),
            SaleFact(
              label: l10n.purchaseFieldPayment,
              value: purchasePayLabel(p.paymentStatus, l10n),
            ),
            SaleFact(label: l10n.saleFieldMethod, value: _method(p, l10n)),
            if (!cancelled) ...[
              SaleFact(label: l10n.purchaseFieldPaid, value: money(p.amountPaid)),
              SaleFact(label: l10n.purchaseFieldRemaining, value: money(p.remaining), last: true),
            ] else
              SaleFact(label: l10n.purchaseFieldPaid, value: money(p.amountPaid), last: true),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.xl),
      SectionLabel(nested: true, label: l10n.saleItemsSection, trailing: '${p.itemCount}'),
      SaleCard(
        child: Column(
          children: [
            for (final (index, item) in p.items.indexed) ...[
              if (index > 0)
                const Divider(
                  height: AppStroke.hairline,
                  thickness: AppStroke.hairline,
                  color: AppColors.rule,
                ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.56.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.label, style: AppText.bodyS),
                          if (item.sku case final sku?) ...[
                            SizedBox(height: 0.77.w),
                            Text(sku.toUpperCase(), style: AppText.labelMeta),
                          ],
                          SizedBox(height: 0.77.w),
                          Text(
                            l10n
                                .purchaseLineMeta(
                                  item.quantity,
                                  item.receivedQty,
                                  money(item.unitCost),
                                )
                                .toUpperCase(),
                            style: AppText.labelMeta,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(money(item.total), style: AppText.numeralM),
                  ],
                ),
              ),
            ],
            const Divider(
              height: AppStroke.hairline,
              thickness: AppStroke.hairline,
              color: AppColors.rule,
            ),
            if (p.tax != 0 || p.shippingCost != 0) ...[
              SaleFact(label: l10n.saleSubtotal, value: money(p.subtotal)),
              if (p.tax != 0) SaleFact(label: l10n.saleTax, value: money(p.tax)),
              if (p.shippingCost != 0)
                SaleFact(label: l10n.newOrderDelivery, value: money(p.shippingCost)),
            ],
            SaleFact(label: l10n.saleTotal, value: money(p.total), strong: true, last: true),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.xl),
      SaleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.salePaymentStatus, style: AppText.bodyS)),
                purchasePayPill(p.paymentStatus, l10n),
              ],
            ),
            if (p.canMarkPaid) ...[
              SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: busy == null ? _markPaid : null,
                child: busy == PurchaseAction.markPaid
                    ? SizedBox.square(
                        dimension: AppSpacing.gutterTight,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.ink,
                        ),
                      )
                    : Text(l10n.purchaseMarkPaid),
              ),
            ],
            if (p.canReceive) ...[
              SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: busy == null ? _receive : null,
                child: Text(l10n.purchaseReceiveDelivery),
              ),
            ],
          ],
        ),
      ),
      if (p.notes case final notes?) ...[
        SizedBox(height: AppSpacing.xl),
        SectionLabel(nested: true, label: l10n.orderNotesSection),
        SaleCard(child: Text(notes, style: AppText.bodyS.copyWith(height: 1.4))),
      ],
      if (p.canCancel) ...[
        SizedBox(height: AppSpacing.xxl),
        OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.accentAlert),
          onPressed: busy == null ? _cancel : null,
          child: busy == PurchaseAction.cancel
              ? SizedBox.square(
                  dimension: AppSpacing.gutterTight,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accentAlert,
                  ),
                )
              : Text(l10n.purchaseCancel),
        ),
      ],
    ];
  }

  String _method(Purchase p, L10n l10n) => switch (p.paymentMethod) {
    final method? => paymentMethodLabel(method, l10n),
    null => p.paymentMethodWire,
  };
}
