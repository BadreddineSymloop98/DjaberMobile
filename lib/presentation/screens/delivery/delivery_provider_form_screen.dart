import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/phone.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/delivery.dart';
import '../../../data/repositories/delivery_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/delivery_provider_form_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_checkbox.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/back_scope.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import '../tutorial/tutorial_messages.dart';
import 'delivery_widgets.dart';

/// `Add / edit a delivery provider` (Figma `662:15717`, `· modifier` `662:15973`).
///
/// Full screen, as the frame draws it — the form is long. The courier's own
/// credential fields come from `GET /delivery/providers/available`, so a
/// courier the backend adds later needs no app release. See
/// [DeliveryProviderFormViewModel] for the API's rules the form follows.
class DeliveryProviderFormScreen extends StatefulWidget {
  const DeliveryProviderFormScreen({super.key, this.editing, this.editingId});

  /// The account to edit, handed over by the list. Null on *Ajouter*.
  final DeliveryProvider? editing;

  /// The id from the route when it was opened without [editing] — a splash
  /// replay or a deep link; the account is then read from the list.
  final String? editingId;

  @override
  State<DeliveryProviderFormScreen> createState() => _DeliveryProviderFormScreenState();
}

class _DeliveryProviderFormScreenState extends State<DeliveryProviderFormScreen> {
  DeliveryProviderFormViewModel? _model;
  bool _missing = false;

  final _focus = <String, FocusNode>{};
  FocusNode _node(String key) => _focus.putIfAbsent(key, FocusNode.new);

  @override
  void initState() {
    super.initState();
    _start();
  }

  /// There is no `GET /delivery/providers/{id}`: an edit opened without its
  /// row looks it up in the list.
  Future<void> _start() async {
    final delivery = context.read<DeliveryRepository>();
    var editing = widget.editing;
    if (editing == null && widget.editingId != null) {
      final list = await delivery.providers();
      editing = list.valueOrNull?.where((p) => p.id == widget.editingId).firstOrNull;
      if (!mounted) return;
      if (editing == null) {
        setState(() => _missing = true);
        return;
      }
    }
    final model = DeliveryProviderFormViewModel(delivery: delivery, editing: editing);
    setState(() => _model = model);
    await model.load();
  }

  @override
  void dispose() {
    for (final f in _focus.values) {
      f.dispose();
    }
    _model?.dispose();
    super.dispose();
  }

  void _close() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(true);
    } else {
      router.go(Routes.deliveryProviders);
    }
  }

  Future<void> _save() async {
    final model = _model!;
    final l10n = L10n.of(context);
    FocusScope.of(context).unfocus();
    final saved = await model.save();
    if (saved == null || !mounted) return;
    AppToast.success(
      context,
      model.isEdit ? l10n.deliveryProviderUpdated(saved.displayName) : l10n.deliveryProviderAdded(saved.displayName),
    );
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final model = _model;
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);
    final title = widget.editing != null || widget.editingId != null
        ? l10n.deliveryFormEditTitle
        : l10n.deliveryFormAddTitle;

    Widget frame(List<Widget> body, {bool guard = false}) => BackIntercept(
          active: guard && model != null && (model.hasChanges || model.isBusy),
          onBack: () => model != null && model.isBusy
              ? false
              : showLeaveSheet(context, body: l10n.productEditLeaveBody),
          child: Scaffold(
            backgroundColor: AppColors.ink,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: gutter.copyWith(top: 0.47.h, bottom: AppSpacing.lg),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AppBackButton(semanticLabel: l10n.commonBack),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: gutter.copyWith(bottom: AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(title, style: AppText.displayM),
                          SizedBox(height: AppSpacing.xl),
                          ...body,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    Widget spinner() => Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
          child: const Center(
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
            ),
          ),
        );

    if (_missing) {
      return frame([Text(l10n.deliveryProvidersEmptyTitle, style: AppText.bodyS.copyWith(color: AppColors.textMuted))]);
    }
    if (model == null) return frame([spinner()]);

    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        if (!model.isLoaded) return frame([spinner()]);

        if (model.allTaken) {
          return frame([
            Text(l10n.deliveryFormAllTaken, style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32)),
            SizedBox(height: AppSpacing.xl),
            OutlinedButton(onPressed: _close, child: Text(l10n.commonBack)),
          ]);
        }

        final courier = model.courier;
        final required = tutorialFieldMessage(FieldError.required, l10n);
        final busy = model.isBusy;

        return frame(guard: true, [
          if (model.isEdit)
            Text.rich(TextSpan(children: [
              TextSpan(text: '${l10n.deliveryCardProvider} ', style: AppText.bodyS.copyWith(color: AppColors.textMuted)),
              TextSpan(text: courier?.name ?? model.editing!.provider, style: AppText.title),
            ]))
          else
            AppSelectField<String>(
              label: l10n.deliveryFormCourier,
              placeholder: l10n.deliveryFormChooseCourier,
              sheetTitle: l10n.deliveryFormCourier,
              isRequired: true,
              options: [for (final c in model.selectableCouriers) SelectOption(value: c.id, label: c.name)],
              value: model.courierId,
              errorText: model.courierMissing ? required : null,
              enabled: !busy,
              onChanged: model.setCourier,
            ),
          SizedBox(height: AppSpacing.md),
          AppTextField(
            label: l10n.deliveryFormDisplayName,
            isRequired: true,
            controller: model.displayName,
            focusNode: _node('displayName'),
            errorText: model.displayNameMissing ? required : null,
            inputFormatters: [LengthLimitingTextInputFormatter(80)],
            textInputAction: TextInputAction.next,
            enabled: !busy,
          ),
          if (courier != null && courier.credentials.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xl),
            FlushSectionLabel(label: l10n.deliveryFormCredentials),
            for (final field in courier.credentials) ...[
              AppTextField(
                label: field.label.toUpperCase(),
                isRequired: !model.isEdit && field.isRequired,
                controller: model.credential(field.key),
                focusNode: _node('cred:${field.key}'),
                placeholder: model.isEdit ? l10n.deliveryFormUnchanged : null,
                obscureText: field.isSecret,
                errorText: model.credentialMissing(field) ? required : null,
                textInputAction: TextInputAction.next,
                enabled: !busy,
              ),
              SizedBox(height: AppSpacing.md),
            ],
            OutlinedButton(
              onPressed: model.canTest && !busy ? model.runTest : null,
              child: model.isTesting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
                    )
                  : Text(l10n.deliveryFormTest),
            ),
            if (model.test case final test?) ...[
              SizedBox(height: AppSpacing.sm),
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Text(
                  test.ok
                      ? l10n.deliveryFormTestOk(courier.name)
                      : l10n.deliveryFormTestFailed(courier.name, test.message),
                  style: AppText.bodyS.copyWith(color: test.ok ? AppColors.textSecondary : AppColors.accentAlert),
                ),
              ),
            ],
          ],
          SizedBox(height: AppSpacing.xl),
          FlushSectionLabel(label: l10n.deliveryFormSender),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: l10n.deliveryFormSenderName,
                  controller: model.senderName,
                  focusNode: _node('senderName'),
                  inputFormatters: [LengthLimitingTextInputFormatter(80)],
                  textInputAction: TextInputAction.next,
                  enabled: !busy,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppTextField(
                  label: l10n.deliveryFormSenderPhone,
                  controller: model.senderPhone,
                  focusNode: _node('senderPhone'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: const [AlgerianPhoneFormatter()],
                  textInputAction: TextInputAction.next,
                  enabled: !busy,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          AppTextField(
            label: l10n.deliveryFormSenderAddress,
            controller: model.senderAddress,
            focusNode: _node('senderAddress'),
            inputFormatters: [LengthLimitingTextInputFormatter(200)],
            textInputAction: TextInputAction.done,
            enabled: !busy,
          ),
          SizedBox(height: AppSpacing.md),
          AppSelectField<int>(
            label: l10n.deliveryFormSenderWilaya,
            placeholder: l10n.deliveryChooseWilaya,
            sheetTitle: l10n.deliveryFormSenderWilaya,
            options: [
              for (final w in model.wilayas)
                SelectOption(value: w.id, label: w.label(Localizations.localeOf(context).languageCode)),
            ],
            value: model.wilayaId,
            enabled: model.wilayas.isNotEmpty && !busy,
            onChanged: model.setWilaya,
          ),
          SizedBox(height: AppSpacing.lg),
          AppCheckbox(
            label: l10n.deliveryFormSetDefault,
            value: model.isDefault,
            onChanged: busy ? (_) {} : model.setDefault,
          ),
          if (model.saveError case final error?) ...[
            SizedBox(height: AppSpacing.lg),
            ApiErrorLine(error: error),
          ],
          SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: busy ? null : _save,
            child: busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                  )
                : Text(model.isEdit ? l10n.deliveryFormUpdate : l10n.deliveryFormAdd),
          ),
          SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            // Through the back intercept, so unsaved changes are asked about.
            onPressed: busy ? null : () => Navigator.of(context).maybePop(),
            child: Text(l10n.commonCancel),
          ),
        ]);
      },
    );
  }
}
