import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/order.dart';
import '../../../data/models/sale.dart';
import '../../../data/repositories/sale_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/edit_sale_view_model.dart';
import '../../viewmodels/form_draft_store.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_scope.dart';
import '../../widgets/date_picker_sheet.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import '../orders/order_status_pill.dart';
import 'sale_widgets.dart';

/// `Edit a sale` (Figma `670:16272`) — the web's `stock/sales/[id]/edit`.
///
/// The sale read-only on top, then the payment status, the method and the
/// notes. Pops with the saved sale, so the detail below shows it at once.
class EditSaleScreen extends StatefulWidget {
  const EditSaleScreen({super.key, required this.saleId, this.initial});

  final String saleId;
  final Sale? initial;

  @override
  State<EditSaleScreen> createState() => _EditSaleScreenState();
}

class _EditSaleScreenState extends State<EditSaleScreen> {
  late final EditSaleViewModel _model = EditSaleViewModel(
    sales: context.read<SaleRepository>(),
    saleId: widget.saleId,
    initial: widget.initial,
    drafts: context.read<FormDraftStore?>(),
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

  Future<bool> _onBack() async {
    if (_model.isBusy) return false;
    if (!_model.isDirty) return true;
    return showLeaveSheet(context, body: L10n.of(context).saleEditLeaveBody);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final l10n = L10n.of(context);
    final saved = await _model.save();
    if (!mounted) return;
    if (saved == null) {
      if (_model.saveError case final error?) AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    AppToast.success(context, l10n.saleUpdatedToast);
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(saved);
    } else {
      router.go(Routes.saleOf(saved.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => BackIntercept(
        active: _model.isDirty || _model.isBusy,
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
                if (_model.sale != null) _footer(l10n),
              ],
            ),
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
    final problem = _model.partialProblem;
    final next = _model.newAmountPaid;

    return [
      Text(l10n.saleEditTitle(sale.saleNumber), style: AppText.displayM),
      SizedBox(height: AppSpacing.sm),
      Text(
        l10n.saleEditSubtitle,
        style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.4),
      ),
      SizedBox(height: AppSpacing.xl),
      SaleCard(
        child: Column(
          children: [
            SaleFact(label: l10n.saleFieldCustomer, value: sale.customerName ?? l10n.saleWalkIn),
            SaleFact(label: l10n.saleFieldItems, value: '${sale.itemCount}'),
            SaleFact(label: l10n.saleTotal, value: money(sale.total), strong: true),
            SaleFact(
              label: l10n.saleFieldDate,
              value: '${formatPickedDay(sale.saleDate.toLocal(), tag)} ${saleTime(sale.saleDate)}',
              last: true,
            ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.xl),
      Text(l10n.salePaymentStatus.toUpperCase(), style: AppText.labelMeta),
      SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: 1.54.w,
        runSpacing: 1.54.w,
        children: [
          for (final status in [PaymentStatus.paid, PaymentStatus.pending, PaymentStatus.partial])
            AppFilterChip(
              label: saleStatusLabel(status, l10n),
              selected: _model.status == status,
              onTap: () => _model.setStatus(status),
            ),
        ],
      ),
      if (_model.status == PaymentStatus.partial) ...[
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: l10n.newOrderAmountPaid,
          controller: _model.paid.controller,
          focusNode: _model.paid.focusNode,
          placeholder: '0',
          isRequired: true,
          errorText: switch (problem) {
            // Shown once typed into, or as soon as the field is in use.
            PartialProblem.missing when _model.paid.hasFocus || _model.paid.value.isNotEmpty =>
              l10n.saleEditPartialMissing,
            PartialProblem.notBelowTotal => l10n.saleEditPartialTooHigh(money(sale.total)),
            _ => null,
          },
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            LengthLimitingTextInputFormatter(12),
          ],
        ),
      ],
      // What the change does to the money, before it is made — moving a paid
      // sale back to pending takes its income out of the caisse.
      if (_model.changesAmount && next != null) ...[
        SizedBox(height: AppSpacing.sm),
        Text(l10n.saleEditCaisse(money(sale.amountPaid), money(next)), style: AppText.labelMeta),
      ],
      SizedBox(height: AppSpacing.xl),
      AppSelectField<PaymentMethod>(
        label: l10n.saleFieldMethod,
        placeholder: l10n.saleMethodHint,
        sheetTitle: l10n.saleFieldMethod,
        options: [
          for (final method in PaymentMethod.values)
            SelectOption(value: method, label: paymentMethodLabel(method, l10n)),
        ],
        value: _model.method,
        onChanged: _model.setMethod,
      ),
      SizedBox(height: AppSpacing.xl),
      AppTextField(
        label: l10n.newOrderNotes,
        controller: _model.notes.controller,
        focusNode: _model.notes.focusNode,
        placeholder: l10n.newSaleNotesHint,
        minLines: 2,
        inputFormatters: [LengthLimitingTextInputFormatter(1000)],
      ),
    ];
  }

  Widget _footer(L10n l10n) {
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
          FilledButton(
            onPressed: _model.canSave ? _save : null,
            child: _model.isBusy
                ? SizedBox.square(
                    dimension: AppSpacing.gutterTight,
                    child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                  )
                : Text(l10n.saleEditSave),
          ),
          SizedBox(height: AppSpacing.sm),
          OutlinedButton(onPressed: () => BackScope.back(context), child: Text(l10n.commonCancel)),
        ],
      ),
    );
  }
}
