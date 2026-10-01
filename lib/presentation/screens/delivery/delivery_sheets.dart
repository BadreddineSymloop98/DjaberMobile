import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/result.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/phone.dart';
import '../../../data/models/delivery.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/delivery_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/send_to_carrier_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_checkbox.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import 'delivery_widgets.dart';

// ---------------------------------------------------------------------------
// Send an order to a carrier (Figma `661:13915`, `· aucun transporteur` `661:14378`)
// ---------------------------------------------------------------------------

/// Sends [order] to a courier. Pops the updated order once the parcel exists,
/// nothing when dismissed. Used by *Livraison* and by Orders.
Future<Order?> showSendToCarrierSheet(BuildContext context, {required Order order}) {
  return showModalBottomSheet<Order>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _SendSheet(order: order),
  );
}

class _SendSheet extends StatefulWidget {
  const _SendSheet({required this.order});

  final Order order;

  @override
  State<_SendSheet> createState() => _SendSheetState();
}

class _SendSheetState extends State<_SendSheet> {
  late final SendToCarrierViewModel _model = SendToCarrierViewModel(
    delivery: context.read<DeliveryRepository>(),
    order: widget.order,
  );

  final _noteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _model.load();
  }

  @override
  void dispose() {
    _noteFocus.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = L10n.of(context);
    final provider = _model.provider;
    final sent = await _model.send();
    if (sent == null || !mounted) return;
    AppToast.success(context, l10n.deliverySentToast(sent.orderNumber, provider?.displayName ?? ''));
    Navigator.of(context).pop(sent);
  }

  /// No courier yet: the sheet closes and the form opens, as the frame's
  /// *Ajouter un transporteur* does. The merchant comes back to *Livraison*.
  void _addProvider() {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(Routes.deliveryProviderNew);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final tag = Localizations.localeOf(context).toLanguageTag();
    final lang = Localizations.localeOf(context).languageCode;
    final order = widget.order;

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        final summary = FactsBox(rows: [
          (l10n.deliveryClient, order.clientName),
          if (order.clientPhone case final phone?) (l10n.deliveryPhone, Phone.format(phone)),
          if (order.clientAddress case final address?) (l10n.deliveryAddress, address),
          (l10n.deliveryTotal, Money.exact(order.total, tag)),
        ]);

        if (!_model.isLoaded) {
          return DeliverySheetFrame(
            title: l10n.deliverySendTitle(order.orderNumber),
            children: [
              summary,
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: const Center(
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          );
        }

        if (_model.hasNoProvider && _model.sendError == null) {
          return DeliverySheetFrame(
            title: l10n.deliverySendTitle(order.orderNumber),
            children: [
              summary,
              SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.deliveryNoProviders,
                textAlign: TextAlign.center,
                style: AppText.bodyS.copyWith(color: AppColors.textMuted),
              ),
              SizedBox(height: AppSpacing.xxl),
              FilledButton(onPressed: _addProvider, child: Text(l10n.deliveryAddProvider)),
              SizedBox(height: AppSpacing.sm),
              OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
            ],
          );
        }

        final rates = _model.rates;
        String rate(double? v) => _model.ratesLoading ? '…' : (v == null ? '—' : Money.exact(v, tag));

        return DeliverySheetFrame(
          title: l10n.deliverySendTitle(order.orderNumber),
          children: [
            summary,
            SizedBox(height: AppSpacing.xl),
            AppSelectField<String>(
              label: l10n.deliveryProviderLabel,
              placeholder: l10n.deliveryFormChooseCourier,
              sheetTitle: l10n.deliveryProviderLabel,
              options: [
                for (final p in _model.providers)
                  SelectOption(
                    value: p.id,
                    label: p.isDefault ? l10n.deliveryProviderDefault(p.displayName) : p.displayName,
                  ),
              ],
              value: _model.providerId,
              enabled: _model.providers.length > 1 && !_model.isBusy,
              onChanged: _model.setProvider,
            ),
            SizedBox(height: AppSpacing.md),
            AppSelectField<int>(
              label: l10n.deliveryDestination,
              placeholder: l10n.deliveryChooseWilaya,
              sheetTitle: l10n.deliveryDestination,
              isRequired: true,
              options: [
                for (final w in _model.wilayas) SelectOption(value: w.id, label: w.label(lang)),
              ],
              value: _model.wilayaId,
              enabled: _model.wilayas.isNotEmpty && !_model.isBusy,
              onChanged: _model.setWilaya,
            ),
            SizedBox(height: AppSpacing.md),
            AppCheckbox(
              label: l10n.deliveryStopdesk,
              value: _model.isStopdesk,
              onChanged: _model.isBusy ? (_) {} : _model.setStopdesk,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.deliveryNote,
              controller: _model.note,
              focusNode: _noteFocus,
              placeholder: l10n.deliveryNotePlaceholder,
              inputFormatters: [LengthLimitingTextInputFormatter(255)],
              enabled: !_model.isBusy,
            ),
            SizedBox(height: AppSpacing.xl),
            FlushSectionLabel(label: l10n.deliveryRates),
            FactsBox(rows: [
              (l10n.deliveryRateHome, rate(rates?.home)),
              (l10n.deliveryRateStopdesk, rate(rates?.stopdesk)),
            ]),
            if (_model.sendError case final error?) ...[
              SizedBox(height: AppSpacing.lg),
              ApiErrorLine(error: error),
            ],
            SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _model.canSend ? _send : null,
              child: _model.isBusy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                    )
                  : Text(l10n.deliveryConfirmSend),
            ),
            SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: _model.isBusy ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Track a parcel (Figma `661:14805`, `· erreur` `661:15236`)
// ---------------------------------------------------------------------------

/// The courier's own view of the parcel, field names kept as it sent them —
/// each courier answers in its own shape, and the web shows it raw too.
Future<void> showTrackParcelSheet(
  BuildContext context, {
  required Order order,
  required String? courierName,
  required Future<Result<ParcelTracking>> Function() fetch,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _TrackSheet(order: order, courierName: courierName, fetch: fetch),
  );
}

class _TrackSheet extends StatefulWidget {
  const _TrackSheet({required this.order, required this.courierName, required this.fetch});

  final Order order;
  final String? courierName;
  final Future<Result<ParcelTracking>> Function() fetch;

  @override
  State<_TrackSheet> createState() => _TrackSheetState();
}

class _TrackSheetState extends State<_TrackSheet> {
  late final Future<Result<ParcelTracking>> _result = widget.fetch();

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return FutureBuilder<Result<ParcelTracking>>(
      future: _result,
      builder: (context, snapshot) {
        final result = snapshot.data;
        final children = <Widget>[];
        if (result == null) {
          children.add(Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: const Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
              ),
            ),
          ));
        } else {
          final error = result.errorOrNull;
          final tracking = result.valueOrNull;
          if (error != null) {
            children.add(_ErrorBox(message: apiErrorMessage(error, l10n)));
          } else if (tracking case ParcelError(:final message)) {
            children.add(_ErrorBox(message: message.isEmpty ? l10n.deliveryTrackEmpty : message));
          } else if (tracking case ParcelFound(:final fields)) {
            if (widget.courierName case final courier?) {
              children.add(FlushSectionLabel(label: l10n.deliveryCourierResponse(courier.toUpperCase())));
            }
            children.add(fields.isEmpty
                ? Text(l10n.deliveryTrackEmpty, style: AppText.bodyS.copyWith(color: AppColors.textMuted))
                : FactsBox(rows: [for (final f in fields) (f.key, f.value)], monoValues: true));
          }
        }
        return DeliverySheetFrame(
          title: l10n.deliveryTrackTitle(widget.order.orderNumber),
          children: [
            ...children,
            SizedBox(height: AppSpacing.xl),
            FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonDismiss)),
          ],
        );
      },
    );
  }
}

/// The courier's refusal, in the alert colour — the frame's error state.
class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ink,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Text(message, style: AppText.bodyS.copyWith(color: AppColors.accentAlert)),
    );
  }
}
