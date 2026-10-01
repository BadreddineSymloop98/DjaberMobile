import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/error/result.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/delivery.dart';
import '../../../data/models/order.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import '../orders/order_status_pill.dart';

/// The delivery status as the overview's pill — *Livrée* settled, the rest
/// still moving.
OrderStatusPill deliveryStatusPill(DeliveryStatus status, L10n l10n) => OrderStatusPill(
      label: switch (status) {
        DeliveryStatus.notSent => l10n.deliveryPillNotSent,
        DeliveryStatus.sent => l10n.deliveryPillSent,
        DeliveryStatus.inTransit => l10n.deliveryPillInTransit,
        DeliveryStatus.delivered => l10n.deliveryPillDelivered,
      },
      tone: status == DeliveryStatus.delivered ? PillTone.settled : PillTone.moving,
    );

/// A card's small outlined button with its icon — *Envoyer*, *Suivre*,
/// *Étiquette*, *Modifier*. Small on purpose: several stacked in a list must
/// not read as several calls to action.
class CardButton extends StatelessWidget {
  const CardButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.busy = false,
    this.expand = false,
  });

  final List<String> icon;
  final String label;
  final VoidCallback? onTap;

  /// A courier call is running for this button: a spinner replaces the icon.
  final bool busy;

  /// Full width — the providers card's *Modifier*.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !busy;
    final fg = enabled ? AppColors.textPrimary : AppColors.textMuted;
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (busy)
          SizedBox.square(
            dimension: 3.59.w,
            child: const CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.textMuted),
          )
        else
          AppIcon(icon, size: 3.59.w, color: fg),
        SizedBox(width: 1.54.w),
        Flexible(
          child: Text(label, style: AppText.bodyS.copyWith(color: fg), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: BoxConstraints(minHeight: 9.23.w), // 36 — a finger, not a cursor
          padding: EdgeInsets.symmetric(horizontal: 3.08.w, vertical: 1.54.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.ruleStrong, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// A boxed table of label / value rows — the Send sheet's order summary, the
/// tracking sheet's courier fields, *Tarifs estimés*.
class FactsBox extends StatelessWidget {
  const FactsBox({super.key, required this.rows, this.monoValues = false});

  final List<(String, String)> rows;

  /// The courier's raw values (tracking numbers, dates) read better in mono.
  final bool monoValues;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.ink,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1.03.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.bodyS.copyWith(color: AppColors.textMuted)),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: monoValues ? AppText.labelMeta.copyWith(color: AppColors.textPrimary) : AppText.bodyS,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// *PAR DÉFAUT* beside a courier's name.
class DefaultBadge extends StatelessWidget {
  const DefaultBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.54.w, vertical: 0.51.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(1.03.w),
      ),
      child: Text(label.toUpperCase(), style: AppText.labelMicro),
    );
  }
}

/// A sheet's title, top padding and drag-handle spacing, shared by Send and
/// Track so the two read as one family.
class DeliverySheetFrame extends StatelessWidget {
  const DeliverySheetFrame({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AppText.title),
              SizedBox(height: AppSpacing.lg),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the courier's label: a link in the browser (Yalidine), a PDF in the
/// phone's viewer (Maystro). Anything else — ZR Express has none, the courier
/// has not made it yet, the call failed — is said in a toast.
Future<void> openShippingLabel(
  BuildContext context, {
  required Order order,
  required Future<Result<ShippingLabel>> Function() fetch,
}) async {
  final l10n = L10n.of(context);
  final result = await fetch();
  if (!context.mounted) return;
  final error = result.errorOrNull;
  if (error != null) {
    AppToast.info(context, apiErrorMessage(error, l10n));
    return;
  }
  final label = result.valueOrNull!;
  switch (label) {
    case LabelUrl(:final url):
      final uri = Uri.tryParse(url);
      final opened = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) AppToast.info(context, l10n.deliveryLabelOpenFailed);
    case LabelPdf(:final bytes):
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/label-${order.orderNumber.replaceAll(RegExp(r'[^A-Za-z0-9-]'), '')}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      final opened = await OpenFilex.open(file.path, type: 'application/pdf');
      if (opened.type != ResultType.done && context.mounted) {
        AppToast.info(context, l10n.deliveryLabelOpenFailed);
      }
    case LabelUnavailable(:final message):
      AppToast.info(context, message.isEmpty ? l10n.deliveryLabelNotReady : message);
  }
}

/// A section heading inside a padded sheet or form — [SectionLabel]'s style
/// without its own side gutter, which would indent it a second time there.
class FlushSectionLabel extends StatelessWidget {
  const FlushSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: AppSpacing.xxs, bottom: AppSpacing.md),
        child: Text(label.toUpperCase(), style: AppText.labelSection),
      );
}
