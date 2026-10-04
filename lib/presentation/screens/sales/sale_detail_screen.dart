import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/phone.dart';
import '../../../data/models/sale.dart';
import '../../../data/repositories/sale_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/sale_detail_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/date_picker_sheet.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/list_widgets.dart';
import 'sale_widgets.dart';

/// `Sale detail` (Figma `669:16411`, `· payée` `669:16555`) — the web's sale
/// modal, as a screen.
///
/// The customer and how they paid, every line, the total, the payment's state
/// and the notes. *Marquer comme payée* settles it in one tap while money is
/// owed; *Modifier* opens the payment and the notes for editing.
class SaleDetailScreen extends StatefulWidget {
  const SaleDetailScreen({super.key, required this.saleId, this.initial});

  final String saleId;

  /// The row the list handed over, so the screen draws at once.
  final Sale? initial;

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  late final SaleDetailViewModel _model = SaleDetailViewModel(
    sales: context.read<SaleRepository>(),
    saleId: widget.saleId,
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
    AppToast.success(context, l10n.saleMarkedPaidToast);
  }

  Future<void> _edit() async {
    final sale = _model.sale;
    if (sale == null) return;
    final saved = await GoRouter.of(context).push<Sale>(Routes.saleEditOf(sale.id), extra: sale);
    if (saved != null && mounted) _model.adopt(saved);
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
                      AppSpacing.xxl,
                    ),
                    children: _content(l10n),
                  ),
                ),
              ),
              _footer(l10n),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(L10n l10n) {
    final sale = _model.sale;
    if (sale == null) {
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
    final when = '${formatPickedDay(sale.saleDate.toLocal(), tag)} ${saleTime(sale.saleDate)}';
    final adjusted = sale.discount != 0 || sale.tax != 0;

    return [
      Text(l10n.saleEyebrow, style: AppText.labelMeta),
      SizedBox(height: 1.54.w),
      Text(sale.saleNumber, style: AppText.displayM),
      SizedBox(height: 1.54.w),
      Text(when, style: AppText.labelMeta),
      SizedBox(height: AppSpacing.xl),
      SaleCard(
        child: Column(
          children: [
            SaleFact(label: l10n.saleFieldCustomer, value: sale.customerName ?? l10n.saleWalkIn),
            SaleFact(
              label: l10n.saleFieldPhone,
              value: sale.customerPhone == null ? '—' : Phone.format(sale.customerPhone!),
            ),
            SaleFact(label: l10n.saleFieldDate, value: when),
            SaleFact(label: l10n.saleFieldMethod, value: saleMethodLabel(sale, l10n), last: true),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.xl),
      SectionLabel(nested: true, label: l10n.saleItemsSection, trailing: '${sale.itemCount}'),
      SaleCard(
        child: Column(
          children: [
            for (final (index, item) in sale.items.indexed) ...[
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
                          Text(item.productName, style: AppText.bodyS),
                          if (item.sku case final sku?) ...[
                            SizedBox(height: 0.77.w),
                            Text(sku.toUpperCase(), style: AppText.labelMeta),
                          ],
                          SizedBox(height: 0.77.w),
                          Text(
                            [
                              l10n.saleLineMeta(item.quantity, money(item.unitPrice)),
                              if (item.discount > 0) l10n.saleLineDiscount(money(item.discount)),
                            ].join('  ·  ').toUpperCase(),
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
            if (adjusted) ...[
              SaleFact(label: l10n.saleSubtotal, value: money(sale.subtotal)),
              if (sale.discount != 0)
                SaleFact(label: l10n.saleDiscount, value: '−${money(sale.discount)}'),
              if (sale.tax != 0) SaleFact(label: l10n.saleTax, value: money(sale.tax)),
            ],
            SaleFact(label: l10n.saleTotal, value: money(sale.total), strong: true, last: true),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.xl),
      SaleCard(
        child: Row(
          children: [
            Expanded(child: Text(l10n.salePaymentStatus, style: AppText.bodyS)),
            salePaymentPill(sale.paymentStatus, l10n),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.sm),
      KpiPair(
        KpiTile(
          label: l10n.orderPaidLabel,
          value: Money.exactFigure(sale.amountPaid, tag),
          unit: 'DA',
          icon: AppIcons.checkCircle,
          iconColor: AppColors.accentMoney,
        ),
        KpiTile(
          label: l10n.orderRemainingLabel,
          value: Money.exactFigure(sale.remaining, tag),
          unit: 'DA',
          icon: AppIcons.clock,
          iconColor: sale.remaining > 0 ? AppColors.accentAlert : AppColors.accentMoney,
        ),
      ),
      if (sale.notes case final notes?) ...[
        SizedBox(height: AppSpacing.xl),
        SectionLabel(nested: true, label: l10n.orderNotesSection),
        SaleCard(child: Text(notes, style: AppText.bodyS.copyWith(height: 1.4))),
      ],
    ];
  }

  Widget _footer(L10n l10n) {
    final sale = _model.sale;
    if (sale == null) return const SizedBox.shrink();
    final busy = _model.isMarkingPaid;

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
          if (!sale.isPaid) ...[
            FilledButton(
              onPressed: busy ? null : _markPaid,
              child: busy
                  ? SizedBox.square(
                      dimension: AppSpacing.gutterTight,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                    )
                  : Text(l10n.saleMarkPaid),
            ),
            SizedBox(height: AppSpacing.sm),
          ],
          OutlinedButton(onPressed: busy ? null : _edit, child: Text(l10n.saleEdit)),
        ],
      ),
    );
  }
}
