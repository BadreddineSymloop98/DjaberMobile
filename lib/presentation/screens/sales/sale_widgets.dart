import 'package:flutter/material.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/order.dart';
import '../../../data/models/sale.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../orders/order_status_pill.dart';

/// *Payée · En attente · Partielle* — feminine in French, as *une vente* is;
/// the order screens' labels agree with *une commande* elsewhere.
String saleStatusLabel(PaymentStatus status, L10n l10n) => switch (status) {
  PaymentStatus.paid => l10n.saleStatusPaid,
  PaymentStatus.pending => l10n.saleStatusPending,
  PaymentStatus.partial => l10n.saleStatusPartial,
};

/// The payment pill: filled once paid, hollow while money is still owed.
OrderStatusPill salePaymentPill(PaymentStatus status, L10n l10n) => OrderStatusPill(
  label: saleStatusLabel(status, l10n),
  tone: status == PaymentStatus.paid ? PillTone.settled : PillTone.moving,
);

/// The stored method, in the merchant's language — or as stored, for a value
/// no form of this app sends (the API keeps anything).
String saleMethodLabel(Sale sale, L10n l10n) => switch (sale.paymentMethod) {
  final method? => paymentMethodLabel(method, l10n),
  null => sale.paymentMethodWire,
};

String saleTime(DateTime value) {
  final local = value.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

/// A flat card — the surface the detail and edit blocks sit on.
class SaleCard extends StatelessWidget {
  const SaleCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: child,
    );
  }
}

/// A label / value line inside a [SaleCard].
class SaleFact extends StatelessWidget {
  const SaleFact({
    super.key,
    required this.label,
    required this.value,
    this.last = false,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool last;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 2.05.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.bodyS.copyWith(color: AppColors.textMuted)),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  value,
                  style: strong ? AppText.title : AppText.bodyS,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        if (!last)
          const Divider(
            height: AppStroke.hairline,
            thickness: AppStroke.hairline,
            color: AppColors.rule,
          ),
      ],
    );
  }
}

/// A row's small outlined button — smaller than the form buttons, so a list
/// of them does not read as a list of calls to action.
class SaleRowButton extends StatelessWidget {
  const SaleRowButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.56.w, vertical: 1.54.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.ruleStrong, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Text(label, style: AppText.bodyS),
        ),
      ),
    );
  }
}

/// The small spinner every busy spot on these screens uses.
class SaleSpinner extends StatelessWidget {
  const SaleSpinner({super.key, this.dimension = 20});

  final double dimension;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: dimension,
        child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
      ),
    );
  }
}
