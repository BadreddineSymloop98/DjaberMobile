import 'package:flutter/material.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/order.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// The small dotted pill the order frames put under a row's client line, and
/// again beside the order number on the detail screen.
///
/// The dot is the whole signal: **filled** for a state that is settled — the
/// order is confirmed or delivered, the customer picked up — and **hollow**
/// for one still in motion. The web splits the same three ways (`good`,
/// `dead`, `progress`); here a dead state takes the alert colour rather than a
/// third shape, because at 6px a shape difference is not readable.
class OrderStatusPill extends StatelessWidget {
  const OrderStatusPill({
    super.key,
    required this.label,
    required this.tone,
  });

  /// The pill for an order's own status.
  factory OrderStatusPill.status(OrderStatus status, L10n l10n) => OrderStatusPill(
        label: orderStatusLabel(status, l10n),
        tone: switch (status) {
          OrderStatus.confirmed || OrderStatus.delivered => PillTone.settled,
          OrderStatus.cancelled || OrderStatus.returned => PillTone.dead,
          _ => PillTone.moving,
        },
      );

  /// The confirmation pill, which carries the attempt count once there is one:
  /// *SANS RÉPONSE (2)* says more than *SANS RÉPONSE* about whether it is
  /// worth calling again.
  factory OrderStatusPill.confirmation(Order order, L10n l10n) {
    final base = orderConfirmationLabel(order.confirmationStatus, l10n);
    return OrderStatusPill(
      label: order.callAttempts > 0
          ? l10n.orderConfirmWithCount(base, order.callAttempts)
          : base,
      tone: switch (order.confirmationStatus) {
        ConfirmationStatus.confirmed => PillTone.settled,
        ConfirmationStatus.rejected => PillTone.dead,
        _ => PillTone.moving,
      },
    );
  }

  final String label;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    final colour = switch (tone) {
      PillTone.settled => AppColors.accentMoney,
      PillTone.dead => AppColors.accentAlert,
      PillTone.moving => AppColors.textMuted,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.54.w, vertical: 0.77.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        // 6 in the frame — not a full pill, which at this height would read as a
        // lozenge rather than the tight chip the rows are built from.
        borderRadius: BorderRadius.circular(1.54.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 1.54.w,
            height: 1.54.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tone == PillTone.moving ? null : colour,
              border: tone == PillTone.moving
                  ? Border.all(color: colour, width: AppStroke.hairline)
                  : null,
            ),
          ),
          SizedBox(width: 1.28.w),
          Text(label.toUpperCase(), style: AppText.labelMicro),
        ],
      ),
    );
  }
}

enum PillTone { settled, moving, dead }

String orderStatusLabel(OrderStatus status, L10n l10n) => switch (status) {
      OrderStatus.pending => l10n.orderStatusPending,
      OrderStatus.confirmed => l10n.orderStatusConfirmed,
      OrderStatus.preparing => l10n.orderStatusPreparing,
      OrderStatus.shipped => l10n.orderStatusShipped,
      OrderStatus.delivered => l10n.orderStatusDelivered,
      OrderStatus.cancelled => l10n.orderStatusCancelled,
      OrderStatus.returned => l10n.orderStatusReturned,
    };

String orderConfirmationLabel(ConfirmationStatus status, L10n l10n) => switch (status) {
      ConfirmationStatus.notCalled => l10n.orderConfirmNotCalled,
      ConfirmationStatus.noAnswer => l10n.orderConfirmNoAnswer,
      ConfirmationStatus.confirmed => l10n.orderConfirmConfirmed,
      ConfirmationStatus.rejected => l10n.orderConfirmRejected,
    };

String paymentStatusLabel(PaymentStatus status, L10n l10n) => switch (status) {
      PaymentStatus.paid => l10n.paymentStatusPaid,
      PaymentStatus.pending => l10n.paymentStatusPending,
      PaymentStatus.partial => l10n.paymentStatusPartial,
    };

String paymentMethodLabel(PaymentMethod method, L10n l10n) => switch (method) {
      PaymentMethod.cash => l10n.paymentMethodCash,
      PaymentMethod.card => l10n.paymentMethodCard,
      PaymentMethod.transfer => l10n.paymentMethodTransfer,
      PaymentMethod.ccp => l10n.paymentMethodCcp,
    };

/// A 16px tick, the frame's `Checkbox` box. Square at radius 1 — a checkbox at
/// the card radius reads as a blob at this size (the component's own note).
class OrderTick extends StatelessWidget {
  const OrderTick({super.key, required this.checked, required this.onTap, required this.label});

  final bool checked;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xs),
          child: Container(
            width: AppSpacing.lg,
            height: AppSpacing.lg,
            decoration: BoxDecoration(
              color: checked ? AppColors.textPrimary : AppColors.surface,
              border: Border.all(
                color: checked ? AppColors.textPrimary : AppColors.rule,
                width: AppStroke.hairline,
              ),
              borderRadius: BorderRadius.circular(1),
            ),
            child: checked
                ? Icon(Icons.check, size: 3.1.w, color: AppColors.ink)
                : null,
          ),
        ),
      ),
    );
  }
}
