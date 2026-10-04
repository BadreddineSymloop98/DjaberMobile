import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/phone.dart';
import '../../../data/models/supplier.dart';
import '../../../data/repositories/supplier_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/supplier_form_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_checkbox.dart';
import '../../widgets/app_text_field.dart';

/// `Add / edit a supplier` (Figma `644:10851` / `644:11230`) — *Nom \**,
/// *E-mail*, *Téléphone*, *Adresse*, *Notes*, and **Actif** when editing (the
/// web shows its switch only then; the frame draws it with the file's
/// Checkbox).
///
/// Returns the saved supplier, or null when dismissed.
Future<Supplier?> showSupplierFormSheet(
  BuildContext context, {
  required SupplierRepository suppliers,
  required Set<String> knownNames,
  Supplier? editing,
}) {
  return showModalBottomSheet<Supplier>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _SupplierFormSheet(suppliers: suppliers, knownNames: knownNames, editing: editing),
  );
}

class _SupplierFormSheet extends StatefulWidget {
  const _SupplierFormSheet({required this.suppliers, required this.knownNames, required this.editing});

  final SupplierRepository suppliers;
  final Set<String> knownNames;
  final Supplier? editing;

  @override
  State<_SupplierFormSheet> createState() => _SupplierFormSheetState();
}

class _SupplierFormSheetState extends State<_SupplierFormSheet> {
  late final SupplierFormViewModel _model = SupplierFormViewModel(
    suppliers: widget.suppliers,
    knownNames: widget.knownNames,
    editing: widget.editing,
  );

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await _model.save();
    if (saved == null || !mounted) return;
    Navigator.of(context).pop(saved);
  }

  String? _message(SupplierFieldError? error, L10n l10n) => switch (error) {
        null => null,
        SupplierFieldError.required => l10n.productErrRequired,
        SupplierFieldError.noLetters => l10n.clientErrNoLetters,
        SupplierFieldError.nameTaken => l10n.supplierErrNameTaken,
        SupplierFieldError.invalidEmail => l10n.authErrInvalidEmail,
        SupplierFieldError.invalidPhone => l10n.clientErrPhone,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final gap = SizedBox(height: AppSpacing.xl);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(AppSpacing.gutterTight, AppSpacing.sm, AppSpacing.gutterTight, 3.32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_model.isEditing ? l10n.supplierEditTitle : l10n.supplierAddTitle, style: AppText.title),
                gap,
                AppTextField(
                  label: l10n.categoryName,
                  isRequired: true,
                  controller: _model.name.controller,
                  focusNode: _model.name.focusNode,
                  placeholder: l10n.supplierNamePlaceholder,
                  errorText: _message(_model.visible(_model.name, _model.nameError), l10n),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  // The server's own ceilings, so nothing is truncated silently.
                  inputFormatters: [LengthLimitingTextInputFormatter(255)],
                  onSubmitted: (_) => _model.email.focusNode.requestFocus(),
                ),
                gap,
                AppTextField(
                  label: l10n.authEmail,
                  controller: _model.email.controller,
                  focusNode: _model.email.focusNode,
                  placeholder: 'email@example.com',
                  errorText: _message(_model.visible(_model.email, _model.emailError), l10n),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(255)],
                  onSubmitted: (_) => _model.phone.focusNode.requestFocus(),
                ),
                gap,
                AppTextField(
                  label: l10n.clientPhone,
                  controller: _model.phone.controller,
                  focusNode: _model.phone.focusNode,
                  placeholder: '0555 12 34 56',
                  errorText: _message(_model.visible(_model.phone, _model.phoneError), l10n),
                  keyboardType: TextInputType.phone,
                  // The formatter owns both jobs now: it admits digits only
                  // and caps at the length the shape allows.
                  inputFormatters: const [AlgerianPhoneFormatter()],
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _model.address.focusNode.requestFocus(),
                ),
                gap,
                AppTextField(
                  label: l10n.clientAddress,
                  controller: _model.address.controller,
                  focusNode: _model.address.focusNode,
                  placeholder: l10n.supplierAddressPlaceholder,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                  onSubmitted: (_) => _model.notes.focusNode.requestFocus(),
                ),
                gap,
                AppTextField(
                  label: l10n.clientNotes,
                  controller: _model.notes.controller,
                  focusNode: _model.notes.focusNode,
                  placeholder: l10n.clientNotesPlaceholder,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [LengthLimitingTextInputFormatter(5000)],
                  onSubmitted: (_) => _model.notes.focusNode.unfocus(),
                ),
                if (_model.isEditing) ...[
                  SizedBox(height: AppSpacing.xl),
                  AppCheckbox(
                    label: l10n.supplierActive,
                    value: _model.isActive,
                    onChanged: _model.setActive,
                  ),
                ],
                SizedBox(height: AppSpacing.xxl),
                ApiErrorLine(error: _model.submitError),
                FilledButton(
                  onPressed: _model.isBusy ? null : _save,
                  child: _model.isBusy
                      ? SizedBox.square(
                          dimension: AppSpacing.gutterTight,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                        )
                      : Text(_model.isEditing ? l10n.supplierUpdate : l10n.supplierCreate),
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
