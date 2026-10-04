import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/caisse.dart';
import '../../../data/repositories/caisse_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/caisse_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/date_picker_sheet.dart';
import '../../widgets/list_widgets.dart';

/// `Add / edit a transaction` (Figma `680:19098`, `· modifier` `680:19510`).
///
/// Resolves to the saved row, or null when dismissed. Manual rows only — an
/// automatic one never reaches this sheet.
Future<CaisseTransaction?> showCaisseFormSheet(
  BuildContext context, {
  required CaisseRepository caisse,
  CaisseTransaction? editing,
}) {
  return showModalBottomSheet<CaisseTransaction>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _CaisseFormSheet(caisse: caisse, editing: editing),
  );
}

class _CaisseFormSheet extends StatefulWidget {
  const _CaisseFormSheet({required this.caisse, required this.editing});

  final CaisseRepository caisse;
  final CaisseTransaction? editing;

  @override
  State<_CaisseFormSheet> createState() => _CaisseFormSheetState();
}

class _CaisseFormSheetState extends State<_CaisseFormSheet> {
  late final CaisseFormViewModel _model = CaisseFormViewModel(
    caisse: widget.caisse,
    editing: widget.editing,
  );

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePickerSheet(
      context,
      title: L10n.of(context).caisseFieldDate,
      initial: _model.date,
    );
    if (picked != null) _model.setDate(picked);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    // An edit that changed nothing just closes — no request, no toast.
    if (_model.isEditing && !_model.isDirty && _model.problem == null) {
      Navigator.of(context).pop();
      return;
    }
    final saved = await _model.save();
    if (saved == null || !mounted) return;
    Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final tag = Localizations.localeOf(context).toLanguageTag();
    final gap = SizedBox(height: AppSpacing.xl);

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
                Text(
                  _model.isEditing ? l10n.caisseEditTitle : l10n.caisseAddTitle,
                  style: AppText.title,
                ),
                gap,
                Text(l10n.caisseFilterType.toUpperCase(), style: AppText.labelMeta),
                SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 1.54.w,
                  runSpacing: 1.54.w,
                  children: [
                    for (final type in CaisseType.values)
                      AppFilterChip(
                        label: caisseTypeLabel(type, l10n),
                        selected: _model.type == type,
                        onTap: () => _model.setType(type),
                      ),
                  ],
                ),
                gap,
                AppTextField(
                  label: l10n.caisseFieldAmount,
                  isRequired: true,
                  controller: _model.amount.controller,
                  focusNode: _model.amount.focusNode,
                  placeholder: '0.00',
                  errorText: switch (_model.visibleProblem) {
                    CaisseFormProblem.noAmount => l10n.caisseErrAmount,
                    CaisseFormProblem.amountNotPositive => l10n.caisseErrAmountPositive,
                    null => null,
                  },
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    LengthLimitingTextInputFormatter(12),
                  ],
                ),
                gap,
                AppSelectField<CaisseCategory>(
                  label: l10n.caisseFilterCategory,
                  placeholder: l10n.caisseCatOther,
                  sheetTitle: l10n.caisseFilterCategory,
                  options: [
                    for (final c in _model.categories)
                      SelectOption(value: c, label: caisseCategoryLabel(c, l10n)),
                  ],
                  value: _model.category,
                  onChanged: _model.setCategory,
                ),
                gap,
                AppTextField(
                  label: l10n.caisseFieldReference,
                  controller: _model.reference.controller,
                  focusNode: _model.reference.focusNode,
                  placeholder: l10n.caisseReferenceHint,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(120)],
                  onSubmitted: (_) => _model.description.focusNode.requestFocus(),
                ),
                gap,
                AppTextField(
                  label: l10n.caisseFieldDescription,
                  controller: _model.description.controller,
                  focusNode: _model.description.focusNode,
                  placeholder: l10n.caisseDescriptionHint,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
                ),
                gap,
                Text(l10n.caisseFieldDate.toUpperCase(), style: AppText.labelMeta),
                SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ToolChip(
                    icon: AppIcons.calendar,
                    label: formatPickedDay(_model.date, tag),
                    active: true,
                    onTap: _pickDate,
                  ),
                ),
                SizedBox(height: AppSpacing.xxl),
                ApiErrorLine(error: _model.saveError),
                FilledButton(
                  onPressed: _model.isBusy ? null : _save,
                  child: _model.isBusy
                      ? SizedBox.square(
                          dimension: AppSpacing.gutterTight,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.ink,
                          ),
                        )
                      : Text(_model.isEditing ? l10n.caisseUpdate : l10n.caisseAdd),
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
}

String caisseTypeLabel(CaisseType type, L10n l10n) => switch (type) {
  CaisseType.income => l10n.caisseTypeIncome,
  CaisseType.expense => l10n.caisseTypeExpense,
};

String caisseCategoryLabel(CaisseCategory category, L10n l10n) => switch (category) {
  CaisseCategory.sale => l10n.caisseCatSale,
  CaisseCategory.order => l10n.caisseCatOrder,
  CaisseCategory.purchase => l10n.caisseCatPurchase,
  CaisseCategory.rent => l10n.caisseCatRent,
  CaisseCategory.salary => l10n.caisseCatSalary,
  CaisseCategory.utilities => l10n.caisseCatUtilities,
  CaisseCategory.marketing => l10n.caisseCatMarketing,
  CaisseCategory.shipping => l10n.caisseCatShipping,
  CaisseCategory.other => l10n.caisseCatOther,
};
