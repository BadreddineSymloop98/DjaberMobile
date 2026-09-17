import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/product_expense.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/product_expenses_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';

/// `Product expenses panel` (Figma `614:7141`) — the web's side panel, a full
/// screen here.
///
/// In the frame's order: the eyebrow and the product's name, **Résumé de la
/// marge** as a rows box, **Dépenses (n)** with a delete on each row, then the
/// add form — category, amount with the fixed/per-unit toggle, description.
///
/// **The margin figures are the server's.** `GET …/margins` computes them from
/// the product's prices and every expense, flooring the quantity at 1; nothing
/// is recomputed here. A negative net margin is a real answer — the frame's own
/// sample is `−333,33 DA (−13,9 %)` — and it is shown muted rather than red,
/// as §25.22 settled: it is a figure to read, not an alarm.
class ProductExpensesScreen extends StatefulWidget {
  const ProductExpensesScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductExpensesScreen> createState() => _ProductExpensesScreenState();
}

class _ProductExpensesScreenState extends State<ProductExpensesScreen> {
  late final ProductExpensesViewModel _model = ProductExpensesViewModel(
    products: context.read<ProductRepository>(),
    productId: widget.productId,
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

  Future<void> _add() async {
    final ok = await _model.addExpense();
    if (!ok || !mounted) return;
    AppToast.success(context, L10n.of(context).expenseAdded);
  }

  /// Asks first: the backend's expense delete is hard, and the figures above
  /// move with it.
  Future<void> _delete(ProductExpense expense) async {
    final l10n = L10n.of(context);
    final tag = Localizations.localeOf(context).toLanguageTag();
    final confirmed = await showDestructiveSheet(
      context,
      title: l10n.expenseDeleteTitle,
      body: l10n.expenseDeleteBody(
        _categoryLabel(expense.category, l10n),
        Money.exact(expense.amount, tag),
      ),
      confirmLabel: l10n.commonDelete,
    );
    if (!confirmed || !mounted) return;

    final ok = await _model.deleteExpense(expense);
    if (!ok || !mounted) return;
    AppToast.success(context, L10n.of(context).expenseDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.ink,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
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
                    padding: EdgeInsets.only(bottom: AppSpacing.xxl),
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
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);

    if (!_model.isLoaded) {
      if (_model.error != null) {
        return [
          Padding(
            padding: gutter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ApiErrorLine(error: _model.error),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton(
                    onPressed: _model.load,
                    child: Text(l10n.commonRetry),
                  ),
                ),
              ],
            ),
          ),
        ];
      }
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
          child: const Center(
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
            ),
          ),
        ),
      ];
    }

    final tag = Localizations.localeOf(context).toLanguageTag();
    final product = _model.product;
    final margins = _model.margins;
    final expenses = _model.expenses;

    return [
      Padding(
        padding: gutter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.expensesEyebrow, style: AppText.labelMeta),
            SizedBox(height: AppSpacing.xl),
            Text(product?.name ?? '', style: AppText.displayM),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.xl),

      // ---- Margin summary ----
      if (margins != null) ...[
        SectionLabel(label: l10n.expensesMarginSummary),
        Padding(
          padding: gutter,
          child: ListBox(
            children: [
              _SummaryRow(label: l10n.productDetailCost, value: Money.exact(margins.costPrice, tag)),
              _SummaryRow(label: l10n.productDetailSelling, value: Money.exact(margins.sellingPrice, tag)),
              _SummaryRow(label: l10n.expensesTotal, value: Money.exact(margins.totalExpenses, tag)),
              _SummaryRow(label: l10n.expensesPerUnit, value: Money.exact(margins.expensePerUnit, tag)),
              _SummaryRow(label: l10n.expensesTrueCost, value: Money.exact(margins.trueCost, tag)),
              _SummaryRow(
                label: l10n.expensesNetMargin,
                // `−333,33 DA (−13,9 %)`. Muted, not red — a figure to read.
                value: '${Money.exact(margins.netMargin, tag)}'
                    ' (${Money.percent(margins.marginPercent, tag)})',
                muted: true,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.xl),
      ],

      // ---- The expenses ----
      SectionLabel(label: l10n.expensesSection(expenses.length)),
      Padding(
        padding: gutter,
        child: expenses.isEmpty
            ? Text(
                l10n.expensesEmpty,
                style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
              )
            : ListBox(
                children: [
                  for (final expense in expenses)
                    _ExpenseRow(
                      expense: expense,
                      label: _categoryLabel(expense.category, l10n),
                      amount: Money.exact(expense.amount, tag),
                      busy: _model.deletingId == expense.id,
                      onDelete: _model.deletingId == null ? () => _delete(expense) : null,
                    ),
                ],
              ),
      ),
      SizedBox(height: AppSpacing.xl),

      // ---- Add an expense ----
      SectionLabel(label: l10n.expensesAddSection),
      Padding(
        padding: gutter,
        child: _AddForm(model: _model, onSubmit: _add),
      ),
    ];
  }

  /// The six categories the backend names, in French/English/Arabic. A value
  /// the app does not know falls back to *Autre* in the model, so this is
  /// total.
  static String _categoryLabel(ExpenseCategory category, L10n l10n) =>
      switch (category) {
        ExpenseCategory.marketing => l10n.expenseCategoryMarketing,
        ExpenseCategory.shipping => l10n.expenseCategoryShipping,
        ExpenseCategory.packaging => l10n.expenseCategoryPackaging,
        ExpenseCategory.customs => l10n.expenseCategoryCustoms,
        ExpenseCategory.storage => l10n.expenseCategoryStorage,
        ExpenseCategory.other => l10n.expenseCategoryOther,
      };
}

/// One line of the margin box: label on the start side, figure on the end.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.muted = false});

  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppText.bodyS.copyWith(color: AppColors.textMuted),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            value,
            textAlign: TextAlign.end,
            style: AppText.title.copyWith(
              color: muted ? AppColors.textMuted : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// One expense: the category, the `/ UNITÉ` tag when it is per unit, the
/// description, then the amount with the delete control under it — the frame's
/// own arrangement.
class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.expense,
    required this.label,
    required this.amount,
    required this.busy,
    required this.onDelete,
  });

  final ProductExpense expense;
  final String label;
  final String amount;
  final bool busy;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final description = expense.description?.trim();

    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppText.title),
                if (expense.isPerUnit) ...[
                  SizedBox(height: AppSpacing.xxs),
                  Text(l10n.expensePerUnitTag, style: AppText.labelMeta),
                ],
                if (description != null && description.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    description,
                    style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amount,
                textAlign: TextAlign.end,
                style: AppText.numeralM,
              ),
              SizedBox(height: AppSpacing.xxs),
              if (busy)
                SizedBox.square(
                  dimension: 4.1.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textMuted,
                  ),
                )
              else
                Semantics(
                  button: true,
                  label: l10n.expenseDeleteTitle,
                  child: GestureDetector(
                    onTap: onDelete,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      // Pads a 16px glyph out to a real hit target without
                      // moving it off the frame's alignment.
                      padding: EdgeInsets.all(AppSpacing.xs),
                      child: AppIcon(
                        AppIcons.trash,
                        size: 4.1.w, // 16
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The add form: category picker, amount with the fixed/per-unit toggle beside
/// it, description, then the button.
class _AddForm extends StatelessWidget {
  const _AddForm({required this.model, required this.onSubmit});

  final ProductExpensesViewModel model;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSelectField<ExpenseCategory>(
          label: l10n.expenseCategory,
          placeholder: l10n.expenseCategoryMarketing,
          value: model.category,
          onChanged: (value) => model.setCategory(value ?? ExpenseCategory.marketing),
          options: [
            // The backend's enum, in the web select's order.
            SelectOption(value: ExpenseCategory.marketing, label: l10n.expenseCategoryMarketing),
            SelectOption(value: ExpenseCategory.shipping, label: l10n.expenseCategoryShipping),
            SelectOption(value: ExpenseCategory.packaging, label: l10n.expenseCategoryPackaging),
            SelectOption(value: ExpenseCategory.customs, label: l10n.expenseCategoryCustoms),
            SelectOption(value: ExpenseCategory.storage, label: l10n.expenseCategoryStorage),
            SelectOption(value: ExpenseCategory.other, label: l10n.expenseCategoryOther),
          ],
        ),
        SizedBox(height: 3.59.w), // 14
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: AppTextField(
                label: l10n.expenseAmount,
                isRequired: true,
                controller: model.amount,
                focusNode: model.amountFocus,
                placeholder: l10n.expenseAmountPlaceholder,
                errorText: model.showAmountError ? l10n.productErrMustBePositive : null,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                onSubmitted: (_) => model.descriptionFocus.requestFocus(),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            // The web's toggle: `fixed` / `/unit`. A chip rather than a
            // checkbox, as the frame draws it.
            Padding(
              // Level with the input, under the label — and with the error
              // line's height when one is showing, so it does not jump.
              padding: EdgeInsets.only(bottom: model.showAmountError ? 5.13.w : 0),
              child: _ToggleChip(
                label: model.isPerUnit ? l10n.expensePerUnit : l10n.expenseFixed,
                selected: model.isPerUnit,
                onTap: model.isAdding ? null : model.togglePerUnit,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.59.w),
        AppTextField(
          label: l10n.productDescription,
          controller: model.description,
          focusNode: model.descriptionFocus,
          placeholder: l10n.expenseDescriptionPlaceholder,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          inputFormatters: [LengthLimitingTextInputFormatter(255)],
          onSubmitted: (_) => model.descriptionFocus.unfocus(),
        ),
        SizedBox(height: AppSpacing.lg),
        ApiErrorLine(error: model.submitError),
        FilledButton(
          onPressed: model.isAdding ? null : onSubmit,
          child: model.isAdding
              ? SizedBox.square(
                  dimension: AppSpacing.gutterTight,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.ink,
                  ),
                )
              : Text(l10n.expenseAdd),
        ),
      ],
    );
  }
}

/// The fixed / per-unit toggle — the file's `Tab` shape.
class _ToggleChip extends StatelessWidget {
  const _ToggleChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: AppSize.control,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AppColors.textPrimary : Colors.transparent,
            border: Border.all(
              color: selected ? AppColors.textPrimary : AppColors.rule,
              width: AppStroke.hairline,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Text(
            label,
            style: AppText.bodyS.copyWith(
              color: selected ? AppColors.ink : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
