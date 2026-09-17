import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/client.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/client_form_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_text_field.dart';

/// `Add / edit a client` (Figma `639:9557` / `639:9940`) — the web's modal as a
/// sheet: *Nom \**, *E-mail*, *Téléphone \**, *Adresse*, *Notes*, in the web's
/// order and with its placeholders.
///
/// Returns the saved client, or null when dismissed.
Future<Client?> showClientFormSheet(
  BuildContext context, {
  required ClientRepository clients,
  required Map<String, Client> knownPhones,
  Client? editing,
}) {
  return showModalBottomSheet<Client>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _ClientFormSheet(clients: clients, knownPhones: knownPhones, editing: editing),
  );
}

class _ClientFormSheet extends StatefulWidget {
  const _ClientFormSheet({required this.clients, required this.knownPhones, required this.editing});

  final ClientRepository clients;
  final Map<String, Client> knownPhones;
  final Client? editing;

  @override
  State<_ClientFormSheet> createState() => _ClientFormSheetState();
}

class _ClientFormSheetState extends State<_ClientFormSheet> {
  late final ClientFormViewModel _model = ClientFormViewModel(
    clients: widget.clients,
    knownPhones: widget.knownPhones,
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

  String? _message(ClientFieldError? error, L10n l10n) => switch (error) {
        null => null,
        ClientFieldError.required => l10n.productErrRequired,
        ClientFieldError.noLetters => l10n.clientErrNoLetters,
        ClientFieldError.invalidPhone => l10n.clientErrPhone,
        ClientFieldError.invalidEmail => l10n.authErrInvalidEmail,
        ClientFieldError.phoneTaken => l10n.clientErrPhoneTaken(_model.duplicateOwner?.name ?? ''),
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
                Text(_model.isEditing ? l10n.clientEditTitle : l10n.clientAddTitle, style: AppText.title),
                gap,
                AppTextField(
                  label: l10n.categoryName,
                  isRequired: true,
                  controller: _model.name.controller,
                  focusNode: _model.name.focusNode,
                  placeholder: l10n.clientNamePlaceholder,
                  errorText: _message(_model.visible(_model.name, _model.nameError), l10n),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
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
                  autofillHints: const [AutofillHints.email],
                  inputFormatters: [LengthLimitingTextInputFormatter(254)],
                  onSubmitted: (_) => _model.phone.focusNode.requestFocus(),
                ),
                gap,
                AppTextField(
                  label: l10n.clientPhone,
                  isRequired: true,
                  controller: _model.phone.controller,
                  focusNode: _model.phone.focusNode,
                  placeholder: '0555 12 34 56',
                  errorText: _message(_model.visible(_model.phone, _model.phoneError), l10n),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-().]')),
                    LengthLimitingTextInputFormatter(20),
                  ],
                  onSubmitted: (_) => _model.address.focusNode.requestFocus(),
                ),
                gap,
                AppTextField(
                  label: l10n.clientAddress,
                  controller: _model.address.controller,
                  focusNode: _model.address.focusNode,
                  placeholder: l10n.clientAddressPlaceholder,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
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
                  inputFormatters: [LengthLimitingTextInputFormatter(2000)],
                  onSubmitted: (_) => _model.notes.focusNode.unfocus(),
                ),
                SizedBox(height: AppSpacing.xxl),
                ApiErrorLine(error: _model.submitError),
                FilledButton(
                  onPressed: _model.isBusy ? null : _save,
                  child: _model.isBusy
                      ? SizedBox.square(
                          dimension: AppSpacing.gutterTight,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                        )
                      : Text(_model.isEditing ? l10n.clientUpdate : l10n.clientCreate),
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
