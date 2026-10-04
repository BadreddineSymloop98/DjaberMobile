import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/order.dart';
import '../../../data/models/purchase.dart';
import '../../../data/repositories/purchase_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/purchase_detail_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../orders/order_status_pill.dart';

/// *À recevoir · Reçu en partie · Reçu · Annulé* — where the goods are.
String purchaseStatusLabel(PurchaseStatus status, L10n l10n) => switch (status) {
  PurchaseStatus.pending => l10n.purchaseStatusPending,
  PurchaseStatus.partial => l10n.purchaseStatusPartial,
  PurchaseStatus.received => l10n.purchaseStatusReceived,
  PurchaseStatus.cancelled => l10n.purchaseStatusCancelled,
};

/// *Non payé · Payé en partie · Payé* — where the money is (masculine, as
/// *un achat* is).
String purchasePayLabel(PaymentStatus status, L10n l10n) => switch (status) {
  PaymentStatus.pending => l10n.purchasePayPending,
  PaymentStatus.partial => l10n.purchasePayPartial,
  PaymentStatus.paid => l10n.purchasePayPaid,
};

OrderStatusPill purchaseStatusPill(PurchaseStatus status, L10n l10n) => OrderStatusPill(
  label: purchaseStatusLabel(status, l10n),
  tone: switch (status) {
    PurchaseStatus.received => PillTone.settled,
    PurchaseStatus.cancelled => PillTone.dead,
    _ => PillTone.moving,
  },
);

OrderStatusPill purchasePayPill(PaymentStatus status, L10n l10n) => OrderStatusPill(
  label: purchasePayLabel(status, l10n),
  tone: status == PaymentStatus.paid ? PillTone.settled : PillTone.moving,
);

/// `Receive items` (Figma `673:17012`): the quantity that arrived now, per
/// line. Opened from the list's *Réceptionner* and the detail's *Réceptionner
/// la livraison*; resolves to the purchase as it now stands, or null.
Future<Purchase?> showReceiveSheet(BuildContext context, {required Purchase purchase}) {
  final repository = context.read<PurchaseRepository>();
  return showModalBottomSheet<Purchase>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _ReceiveSheet(repository: repository, purchase: purchase),
  );
}

class _ReceiveSheet extends StatefulWidget {
  const _ReceiveSheet({required this.repository, required this.purchase});

  final PurchaseRepository repository;
  final Purchase purchase;

  @override
  State<_ReceiveSheet> createState() => _ReceiveSheetState();
}

class _ReceiveSheetState extends State<_ReceiveSheet> {
  // Built once, here: the sheet's builder may run again, and a model made
  // there would drop what was typed.
  late final _model = ReceivePurchaseViewModel(
    purchases: widget.repository,
    purchase: widget.purchase,
  );

  late final Map<String, TextEditingController> _fields = {
    for (final item in _model.purchase.items)
      item.id: TextEditingController(text: '${_model.quantityOf(item)}'),
  };
  late final Map<String, FocusNode> _focus = {
    for (final item in _model.purchase.items) item.id: FocusNode(),
  };

  @override
  void initState() {
    super.initState();
    for (final item in _model.purchase.items) {
      _fields[item.id]!.addListener(
        () => _model.setQuantity(item, int.tryParse(_fields[item.id]!.text.trim()) ?? 0),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    for (final f in _focus.values) {
      f.dispose();
    }
    _model.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final l10n = L10n.of(context);
    final updated = await _model.submit();
    if (!mounted) return;
    if (updated == null) {
      if (_model.submitError case final error?) {
        AppToast.info(context, apiErrorMessage(error, l10n));
      }
      return;
    }
    AppToast.success(context, l10n.receivedToast);
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => SafeArea(
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
                Text(l10n.purchaseReceiveDelivery, style: AppText.title),
                SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.receiveBody,
                  style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.4),
                ),
                SizedBox(height: AppSpacing.lg),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (final (index, item) in _model.purchase.items.indexed) ...[
                        if (index > 0)
                          const Divider(
                            height: AppStroke.hairline,
                            thickness: AppStroke.hairline,
                            color: AppColors.rule,
                          ),
                        _line(l10n, item),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                if (_model.totalNow == 0) ...[
                  Text(
                    l10n.receiveNothing,
                    style: AppText.bodyS.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.sm),
                ],
                FilledButton(
                  onPressed: _model.canSubmit ? _submit : null,
                  child: _model.isBusy
                      ? SizedBox.square(
                          dimension: AppSpacing.gutterTight,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.ink,
                          ),
                        )
                      : Text(l10n.receiveSubmit),
                ),
                SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: _model.isBusy ? null : () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// One line: what it is and where it stands, then the field. A line that is
  /// already complete is shown dimmed and closed, as the frame draws it.
  Widget _line(L10n l10n, PurchaseItem item) {
    final done = item.toReceive == 0;
    final over = _model.isOver(item);

    return Opacity(
      opacity: done ? 0.4 : 1,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: AppText.bodyS),
                  SizedBox(height: 0.77.w),
                  Text(
                    l10n.receiveLineMeta(item.quantity, item.receivedQty).toUpperCase(),
                    style: AppText.labelMeta,
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 25.6.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppTextField(
                    label: l10n.receiveNowLabel,
                    controller: _fields[item.id]!,
                    focusNode: _focus[item.id]!,
                    enabled: !done && !_model.isBusy,
                    errorText: over ? l10n.receiveOver(item.toReceive) : null,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                  ),
                  if (!over) ...[
                    SizedBox(height: 0.77.w),
                    Text(
                      (done ? l10n.receiveComplete : l10n.receiveToCome(item.toReceive))
                          .toUpperCase(),
                      style: AppText.labelMicro,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
