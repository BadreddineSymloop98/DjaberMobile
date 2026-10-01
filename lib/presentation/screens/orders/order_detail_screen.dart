import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/phone.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/delivery_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/order_detail_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/date_picker_sheet.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/list_widgets.dart';
import '../delivery/delivery_sheets.dart';
import 'order_status_pill.dart';

/// `Order detail` (Figma `651:11839`) and the confirm wizard on top of it
/// (`651:12830`, `651:13012`) — the web's `ConfirmOrderModal` as a screen.
///
/// Three steps, one screen: **Vérification** is the order as it stands,
/// **Appel** asks how the call went, **Résultat** reports what the backend did
/// with that answer. A shipped, delivered, cancelled or returned order has no
/// steps at all — it opens straight into a read-only record with the full call
/// history (`651:12120`).
///
/// The contact card can be corrected in place, and those corrections are sent
/// **with the call outcome** rather than on their own: a phone number fixed
/// during the call belongs to the same moment as the call.
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId, this.initial});

  final String orderId;

  /// The row the list handed over, so the screen draws immediately while the
  /// full record — every call, the whole client — is fetched behind it.
  final Order? initial;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late final OrderDetailViewModel _model = OrderDetailViewModel(
    orders: context.read<OrderRepository>(),
    orderId: widget.orderId,
    initial: widget.initial,
  );

  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _notesFocus = FocusNode();

  List<Wilaya> _wilayas = const [];

  @override
  void initState() {
    super.initState();
    _notes.addListener(() => _model.setCallNotes(_notes.text));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _model.load();
      if (!mounted) return;
      // Only to read the region line back — the order stores a wilaya id, and
      // a bare number would tell the merchant nothing.
      final result = await context.read<DeliveryRepository>().wilayas();
      if (!mounted) return;
      if (result.valueOrNull case final value?) setState(() => _wilayas = value);
    });
  }

  @override
  void dispose() {
    _phone.dispose();
    _address.dispose();
    _notes.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _notesFocus.dispose();
    _model.dispose();
    super.dispose();
  }

  void _startEditing() {
    _phone.text = Phone.format(_model.contactPhone);
    _address.text = _model.contactAddress;
    _model.startEditingContact();
  }

  void _stopEditing() {
    _model.setDraftPhone(_phone.text);
    _model.setDraftAddress(_address.text);
    _model.stopEditingContact();
  }

  Future<void> _saveOutcome() async {
    // Whatever is in the fields right now, whether or not *Terminé* was
    // tapped: a merchant who typed an address and went straight to the call
    // step meant to keep it.
    if (_model.isEditingContact) _stopEditing();
    final l10n = L10n.of(context);
    final ok = await _model.saveOutcome();
    if (!mounted) return;
    if (!ok) {
      if (_model.error case final error?) {
        AppToast.info(context, apiErrorMessage(error, l10n));
      }
      return;
    }
    if (_model.warning case final warning?) {
      // The server kept the call but did not re-confirm the order. Saying so
      // is the only way the merchant learns the order is still cancelled.
      AppToast.info(context, warning);
      return;
    }
    AppToast.success(context, l10n.orderCallLoggedToast);
  }

  Future<void> _markPreparing() async {
    final l10n = L10n.of(context);
    final result = await _model.advanceTo(OrderStatus.preparing);
    if (!mounted) return;
    if (result.errorOrNull case final error?) {
      AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    AppToast.success(context, l10n.orderStatusChangedToast);
    _close();
  }

  /// *Envoyer en livraison* — the Send sheet from *Livraison*, for this order.
  /// From step 3 the work is then done and the screen closes, as *Marquer en
  /// préparation* does; from the review it stays, now showing the order sent.
  Future<void> _sendToDelivery({bool closeAfter = false}) async {
    final order = _model.order;
    if (order == null) return;
    final sent = await showSendToCarrierSheet(context, order: order);
    if (sent == null || !mounted) return;
    _model.adopt(sent);
    if (closeAfter) _close();
  }

  void _close() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.orders);
    }
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
                    AppSpacing.xxl,
                  ),
                  children: _content(l10n),
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
    final order = _model.order;

    if (order == null) {
      return [
        if (_model.isLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
            child: const Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
              ),
            ),
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

    return switch (_model.step) {
      OrderStep.review => _review(l10n, order),
      OrderStep.call => _call(l10n, order),
      OrderStep.result => _result(l10n, order),
    };
  }

  // ---- Step 1 ----

  List<Widget> _review(L10n l10n, Order order) {
    final tag = Localizations.localeOf(context).toLanguageTag();
    final editing = _model.isEditingContact;

    return [
      _header(l10n, order, tag),
      SizedBox(height: AppSpacing.xl),
      if (!order.canLogCall) ...[
        _Notice(
          icon: AppIcons.alert,
          title: l10n.orderReadOnlyNotice(orderStatusLabel(order.status, l10n).toLowerCase()),
          body: order.status.isTerminal ? l10n.orderReadOnlyResell : null,
        ),
        SizedBox(height: AppSpacing.xl),
      ] else ...[
        _Steps(step: _model.step),
        SizedBox(height: AppSpacing.xl),
      ],
      SectionLabel(
        label: l10n.orderClientSection,
        trailing: order.canLogCall ? (editing ? l10n.orderEditContactDone : l10n.orderEditContact) : null,
        onTrailingTap: order.canLogCall ? (editing ? _stopEditing : _startEditing) : null,
      ),
      _Card(
        child: editing ? _contactForm(l10n) : _contactFacts(l10n, order),
      ),
      SizedBox(height: AppSpacing.xl),
      SectionLabel(label: l10n.orderItemsSection, trailing: '${order.itemCount}'),
      _Card(
        child: Column(
          children: [
            for (final (index, item) in order.items.indexed) ...[
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
                          Text(item.label, style: AppText.bodyS),
                          if (item.sku case final sku?) ...[
                            SizedBox(height: 0.77.w),
                            Text(sku.toUpperCase(), style: AppText.labelMeta),
                          ],
                          SizedBox(height: 0.77.w),
                          Text(
                            l10n.orderUnitLine(item.quantity, Money.exact(item.unitPrice, tag)),
                            style: AppText.labelMeta,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(Money.exact(item.total, tag), style: AppText.numeralM),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      SizedBox(height: AppSpacing.xl),
      KpiPair(
        KpiTile(
          label: l10n.orderTotalLabel,
          value: Money.exactFigure(order.total, tag),
          unit: 'DA',
          icon: AppIcons.dollar,
          iconColor: AppColors.accentStarred,
        ),
        KpiTile(
          label: l10n.orderPaidLabel,
          value: Money.exactFigure(order.amountPaid, tag),
          unit: 'DA',
          icon: AppIcons.checkCircle,
          iconColor: AppColors.accentMoney,
        ),
      ),
      SizedBox(height: AppSpacing.sm),
      KpiTile(
        label: l10n.orderRemainingLabel,
        value: Money.exactFigure(order.remaining, tag),
        unit: 'DA',
        icon: AppIcons.clock,
        iconColor: order.remaining > 0 ? AppColors.accentAlert : AppColors.accentMoney,
      ),
      if (order.notes case final notes?) ...[
        SizedBox(height: AppSpacing.xl),
        SectionLabel(label: l10n.orderNotesSection),
        _Card(child: Text(notes, style: AppText.bodyS.copyWith(height: 1.4))),
      ],
      if (order.calls.isNotEmpty) ...[
        SizedBox(height: AppSpacing.xl),
        SectionLabel(
          label: order.canLogCall ? l10n.orderAttemptsSection : l10n.orderCallHistorySection,
        ),
        _Card(
          child: Column(
            children: [
              // Three at most while there is still calling to do — the point is
              // "have I tried recently", not the whole record. A finished order
              // shows everything, because then the record is the point.
              for (final (index, call)
                  in (order.canLogCall ? order.calls.take(3) : order.calls).indexed) ...[
                if (index > 0)
                  const Divider(
                    height: AppStroke.hairline,
                    thickness: AppStroke.hairline,
                    color: AppColors.rule,
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.05.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${formatPickedDay(call.calledAt, tag)} ${_time(call.calledAt)}',
                          style: AppText.labelMeta,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          call.notes?.trim().isNotEmpty ?? false
                              ? '${_outcomeLabel(call.result, l10n)} — ${call.notes}'
                              : _outcomeLabel(call.result, l10n),
                          style: AppText.bodyS,
                          textAlign: TextAlign.end,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ];
  }

  Widget _contactFacts(L10n l10n, Order order) {
    final region = _regionLine(order);
    // **The correction in hand, not the order's stored value.** These edits
    // are only written when the call outcome is saved, so between *Terminé*
    // and that save the order still holds the old number — and showing it
    // there made a correction the merchant had just typed look discarded.
    final phone = _model.contactPhone.trim();
    final address = _model.contactAddress.trim();
    final pending = _model.hasContactEdits;

    return Column(
      children: [
        _Fact(label: l10n.orderFieldName, value: order.clientName),
        _Fact(
          label: l10n.orderFieldPhone,
          value: phone.isEmpty ? l10n.orderNoPhone : Phone.format(phone),
        ),
        _Fact(
          label: l10n.orderFieldAddress,
          value: address.isEmpty
              ? (order.isStopdesk ? l10n.orderStopdeskChip : l10n.orderNoAddress)
              : address,
        ),
        if (region != null) _Fact(label: l10n.orderFieldRegion, value: region, last: true),
        // Why the card shows something the order does not yet carry.
        if (pending) ...[
          SizedBox(height: AppSpacing.sm),
          Text(l10n.orderContactSavedWithCall, style: AppText.labelMeta),
        ],
      ],
    );
  }

  Widget _contactForm(L10n l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l10n.orderFieldPhone,
          controller: _phone,
          focusNode: _phoneFocus,
          placeholder: l10n.orderPhoneHint,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: const [AlgerianPhoneFormatter()],
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: l10n.orderFieldAddress,
          controller: _address,
          focusNode: _addressFocus,
          placeholder: l10n.orderAddressHint,
          minLines: 2,
          inputFormatters: [LengthLimitingTextInputFormatter(1000)],
        ),
        SizedBox(height: AppSpacing.sm),
        Text(l10n.orderContactSavedWithCall, style: AppText.labelMeta),
      ],
    );
  }

  /// `Oran, 31 — Oran`: the commune the order carries, then the wilaya read
  /// back from its id. Null when the order has neither.
  String? _regionLine(Order order) {
    final tag = Localizations.localeOf(context).languageCode;
    final parts = <String>[
      ?order.communeName,
      if (order.wilayaId case final id?)
        if (_wilayas.where((w) => w.id == id).firstOrNull case final wilaya?) wilaya.label(tag),
    ];
    return parts.isEmpty ? null : parts.join(', ');
  }

  // ---- Step 2 ----

  List<Widget> _call(L10n l10n, Order order) {
    final tag = Localizations.localeOf(context).toLanguageTag();
    final outcomes = <(CallResult, String, String)>[
      (CallResult.pickedUp, l10n.orderOutcomeConfirmed, l10n.orderOutcomeConfirmedHint),
      (CallResult.noAnswer, l10n.orderOutcomeNoAnswer, l10n.orderOutcomeNoAnswerHint),
      (CallResult.busy, l10n.orderOutcomeBusy, l10n.orderOutcomeBusyHint),
      (CallResult.voicemail, l10n.orderOutcomeVoicemail, l10n.orderOutcomeVoicemailHint),
      (CallResult.rejected, l10n.orderOutcomeRejected, l10n.orderOutcomeRejectedHint),
    ];

    return [
      _header(l10n, order, tag),
      SizedBox(height: AppSpacing.xl),
      _Steps(step: _model.step),
      SizedBox(height: AppSpacing.xl),
      Text(l10n.orderCallQuestion, style: AppText.displayS),
      SizedBox(height: AppSpacing.xs),
      Text(
        l10n.orderCallSubtitle,
        style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.4),
      ),
      SizedBox(height: AppSpacing.lg),
      for (final (result, label, hint) in outcomes) ...[
        _OutcomeCard(
          label: label,
          hint: hint,
          icon: switch (result) {
            CallResult.pickedUp => AppIcons.checkCircle,
            CallResult.noAnswer => AppIcons.message,
            CallResult.busy => AppIcons.clock,
            CallResult.voicemail => AppIcons.chat,
            CallResult.rejected => AppIcons.close,
          },
          selected: _model.outcome == result,
          onTap: () => _model.setOutcome(result),
        ),
        SizedBox(height: AppSpacing.sm),
      ],
      SizedBox(height: AppSpacing.md),
      AppTextField(
        label: l10n.orderCallNotesLabel,
        controller: _notes,
        focusNode: _notesFocus,
        placeholder: switch (_model.outcome) {
          CallResult.pickedUp => l10n.orderCallNotesHintConfirmed,
          CallResult.rejected => l10n.orderCallNotesHintRejected,
          _ => l10n.orderCallNotesHintOther,
        },
        minLines: 2,
        inputFormatters: [LengthLimitingTextInputFormatter(1000)],
      ),
      if (_model.confirmNeedsAddress) ...[
        SizedBox(height: AppSpacing.md),
        _Notice(
          icon: AppIcons.alert,
          title: l10n.orderNoAddressWarning,
          body: l10n.orderNoAddressBody,
        ),
      ],
    ];
  }

  // ---- Step 3 ----

  List<Widget> _result(L10n l10n, Order order) {
    final tag = Localizations.localeOf(context).toLanguageTag();
    final outcome = _model.outcome;
    final confirmed = outcome == CallResult.pickedUp && order.status == OrderStatus.confirmed;

    final (title, body) = switch (outcome) {
      CallResult.pickedUp => (l10n.orderResultConfirmedTitle, l10n.orderResultConfirmedBody),
      CallResult.rejected => (l10n.orderResultCancelledTitle, l10n.orderResultCancelledBody),
      _ => (
          l10n.orderResultAttemptTitle,
          l10n.orderResultAttemptBody(order.callAttempts),
        ),
    };

    return [
      _header(l10n, order, tag),
      SizedBox(height: AppSpacing.xl),
      _Steps(step: _model.step),
      SizedBox(height: AppSpacing.xl),
      Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8.21.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          children: [
            AppIcon(
              outcome == CallResult.rejected ? AppIcons.close : AppIcons.checkCircle,
              size: 8.21.w,
              color: outcome == CallResult.rejected ? AppColors.accentAlert : AppColors.accentMoney,
            ),
            SizedBox(height: AppSpacing.md),
            Text(title, style: AppText.displayS, textAlign: TextAlign.center),
            SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      if (confirmed) ...[
        SizedBox(height: AppSpacing.xl),
        SectionLabel(label: l10n.orderNextSection),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.orderNextBody,
                style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.4),
              ),
              SizedBox(height: AppSpacing.md),
              // Was drawn disabled (*bientôt*) until Livraison existed; it now
              // opens the Send sheet (wired 2026-10-01).
              if (order.canSendToDelivery)
                OutlinedButton(
                  onPressed: () => _sendToDelivery(closeAfter: true),
                  child: Text(l10n.orderSendToDelivery),
                ),
              SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: _markPreparing,
                child: Text(l10n.orderMarkPreparing),
              ),
            ],
          ),
        ),
      ],
    ];
  }

  // ---- Shared ----

  Widget _header(L10n l10n, Order order, String tag) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.orderEyebrow.toUpperCase(), style: AppText.labelMeta),
        SizedBox(height: 1.54.w),
        Text(order.orderNumber, style: AppText.displayM),
        SizedBox(height: 1.54.w),
        Text(
          '${formatPickedDay(order.orderDate, tag)} ${_time(order.orderDate)}  ·  '
          '${order.source == OrderSource.ai ? l10n.orderSourceAiLong : l10n.orderSourceManual}'
              .toUpperCase(),
          style: AppText.labelMeta,
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            OrderStatusPill.status(order.status, l10n),
            SizedBox(width: AppSpacing.sm),
            Text(l10n.orderCallsCount(order.callAttempts).toUpperCase(), style: AppText.labelMeta),
          ],
        ),
      ],
    );
  }

  Widget _footer(L10n l10n) {
    final order = _model.order;
    if (order == null) return const SizedBox.shrink();

    final padding = EdgeInsets.fromLTRB(
      AppSpacing.gutterTight,
      AppSpacing.md,
      AppSpacing.gutterTight,
      3.32.h,
    );

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: switch (_model.step) {
          OrderStep.review => [
              if (order.canLogCall)
                FilledButton(
                  onPressed: order.confirmationStatus == ConfirmationStatus.confirmed
                      ? null
                      : () => _model.goTo(OrderStep.call),
                  child: Text(
                    order.confirmationStatus == ConfirmationStatus.confirmed
                        ? l10n.orderAlreadyConfirmed
                        : l10n.orderLogCall,
                  ),
                ),
              if (order.canLogCall) SizedBox(height: AppSpacing.sm),
              // A confirmed order waiting for its courier. Not offered before
              // confirmation: a cash-on-delivery order is confirmed by phone
              // first. *Livraison* still lists every unsent order.
              if (order.canSendToDelivery &&
                  (order.status == OrderStatus.confirmed || order.status == OrderStatus.preparing)) ...[
                FilledButton(onPressed: _sendToDelivery, child: Text(l10n.orderSendToDelivery)),
                SizedBox(height: AppSpacing.sm),
              ],
              OutlinedButton(onPressed: _close, child: Text(l10n.orderClose)),
            ],
          OrderStep.call => [
              FilledButton(
                onPressed: _model.canSaveOutcome ? _saveOutcome : null,
                child: _model.isSaving
                    ? SizedBox.square(
                        dimension: AppSpacing.gutterTight,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                      )
                    : Text(l10n.orderSaveOutcome),
              ),
              SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => _model.goTo(OrderStep.review),
                child: Text(l10n.orderBackToReview),
              ),
            ],
          OrderStep.result => [
              FilledButton(onPressed: _close, child: Text(l10n.orderDone)),
            ],
        },
      ),
    );
  }

  String _time(DateTime value) {
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String _outcomeLabel(CallResult result, L10n l10n) => switch (result) {
        CallResult.pickedUp => l10n.orderOutcomeConfirmed,
        CallResult.noAnswer => l10n.orderOutcomeNoAnswer,
        CallResult.busy => l10n.orderOutcomeBusy,
        CallResult.voicemail => l10n.orderOutcomeVoicemail,
        CallResult.rejected => l10n.orderOutcomeRejected,
      };
}

/// The 1-2-3 rail the frames draw under the header.
class _Steps extends StatelessWidget {
  const _Steps({required this.step});

  final OrderStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final labels = [l10n.orderStepReview, l10n.orderStepCall, l10n.orderStepResult];
    final current = step.index;

    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: AppStroke.hairline,
                margin: EdgeInsets.symmetric(horizontal: 1.54.w),
                color: AppColors.rule,
              ),
            ),
          Container(
            width: 5.13.w,
            height: 5.13.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= current ? AppColors.textPrimary : AppColors.surfaceRaised,
              border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            ),
            child: i < current
                ? Icon(Icons.check, size: 3.1.w, color: AppColors.ink)
                : Text(
                    '${i + 1}',
                    style: AppText.labelMicro.copyWith(
                      color: i == current ? AppColors.ink : AppColors.textMuted,
                    ),
                  ),
          ),
          SizedBox(width: 1.54.w),
          Text(
            labels[i],
            style: AppText.bodyS.copyWith(
              color: i == current ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

/// A flat card — the surface every block on this screen sits on.
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: child,
    );
  }
}

/// A label / value line inside the contact card.
class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 2.05.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.bodyS.copyWith(color: AppColors.textMuted)),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(value, style: AppText.bodyS, textAlign: TextAlign.end),
              ),
            ],
          ),
        ),
        if (!last)
          const Divider(
            height: AppStroke.hairline,
            thickness: AppStroke.hairline,
            color: AppColors.rule,
          ),
      ],
    );
  }
}

/// The bordered warning box — the read-only banner and the missing-address
/// guard both use it.
class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.title, this.body});

  final List<String> icon;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(icon, size: AppSpacing.lg, color: AppColors.textMuted),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.bodyS.copyWith(height: 1.4)),
                if (body case final body?) ...[
                  SizedBox(height: 0.77.w),
                  Text(
                    body,
                    style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One of the five call outcomes — the frame's Option Card.
class _OutcomeCard extends StatelessWidget {
  const _OutcomeCard({
    required this.label,
    required this.hint,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String hint;
  final List<String> icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: selected ? AppColors.textPrimary : AppColors.rule,
              width: AppStroke.hairline,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppIcon(icon, size: AppSpacing.lg, color: AppColors.textSecondary),
                  SizedBox(width: AppSpacing.sm),
                  Text(label, style: AppText.title),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                hint,
                style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
