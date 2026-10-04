import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/route_observer.dart';
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
import '../../viewmodels/delivery_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/list_widgets.dart';
import 'delivery_sheets.dart';
import 'delivery_widgets.dart';

/// `Delivery overview` (Figma `660:13827`) — the web's `stock/delivery`.
///
/// *Tarifs*, *Transporteurs* and *Actualiser*; the four delivery counts; a
/// search; one tab per delivery status; then one card per order with the one
/// thing to do next — *Envoyer* while it waits, *Suivre* and *Étiquette* once
/// a courier has it. Cancelled and returned orders are never offered *Envoyer*
/// (the API refuses cancelled ones; the web hides both).
class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> with RouteAware {
  late final DeliveryViewModel _model = DeliveryViewModel(
    orders: context.read<OrderRepository>(),
    delivery: context.read<DeliveryRepository>(),
  );

  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  /// Orders whose label is being fetched — the courier can take seconds.
  final Set<String> _labelling = {};

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      _debounce?.cancel();
      // 300ms, the web's own debounce on the same field.
      _debounce = Timer(const Duration(milliseconds: 300), () => _model.setSearch(_search.text));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) appRouteObserver.subscribe(this, route);
  }

  /// Back from *Tarifs*, *Transporteurs* or a provider form: a new courier
  /// changes the names on the cards, so read everything again.
  @override
  void didPopNext() {
    if (mounted) unawaited(_model.load());
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _debounce?.cancel();
    _search.dispose();
    _searchFocus.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _send(Order order) async {
    final sent = await showSendToCarrierSheet(context, order: order);
    if (sent != null && mounted) _model.replace(sent);
  }

  Future<void> _track(Order order) => showTrackParcelSheet(
        context,
        order: order,
        courierName: _model.providerName(order) ?? _model.courierOf(order),
        fetch: () => _model.track(order),
      );

  Future<void> _label(Order order) async {
    if (_labelling.contains(order.id)) return;
    setState(() => _labelling.add(order.id));
    await openShippingLabel(context, order: order, fetch: () => _model.label(order));
    if (mounted) setState(() => _labelling.remove(order.id));
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
          child: RefreshIndicator(
            onRefresh: _model.load,
            color: AppColors.textPrimary,
            backgroundColor: AppColors.surface,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 0.47.h, bottom: AppSpacing.xl),
              children: _content(l10n),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(L10n l10n) {
    final tag = Localizations.localeOf(context).toLanguageTag();
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);
    final stats = _model.stats;
    const dash = '—';
    String count(int? v) => v == null ? dash : Money.grouped(v, tag);

    return [
      Padding(
        padding: gutter.copyWith(bottom: AppSpacing.lg),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppBackButton(semanticLabel: l10n.commonBack),
        ),
      ),
      Padding(
        padding: gutter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deliveryEyebrow, style: AppText.labelMeta),
            SizedBox(height: 1.54.w),
            Text(l10n.deliveryTitle, style: AppText.displayM),
            SizedBox(height: 1.54.w),
            Text(l10n.deliverySubtitle, style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.32)),
            SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ToolChip(
                  icon: AppIcons.dollar,
                  label: l10n.deliveryFeesAction,
                  active: false,
                  onTap: () => GoRouter.of(context).push(Routes.deliveryFees),
                ),
                ToolChip(
                  icon: AppIcons.settings,
                  label: l10n.deliveryProvidersAction,
                  active: false,
                  onTap: () => GoRouter.of(context).push(Routes.deliveryProviders),
                ),
                ToolChip(
                  icon: AppIcons.refresh,
                  label: l10n.deliveryRefresh,
                  active: false,
                  onTap: _model.load,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xl),
            KpiPair(
              KpiTile(
                label: l10n.deliveryStatReady,
                value: count(stats?.notSent),
                icon: AppIcons.box,
                iconColor: AppColors.accentMoney,
              ),
              KpiTile(
                label: l10n.deliveryStatShipped,
                value: count(stats?.sent),
                icon: AppIcons.truck,
                iconColor: AppColors.accentMoney,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            KpiPair(
              KpiTile(
                label: l10n.deliveryStatInTransit,
                value: count(stats?.inTransit),
                icon: AppIcons.truck,
                iconColor: AppColors.accentMoney,
              ),
              KpiTile(
                label: l10n.deliveryStatDelivered,
                value: count(stats?.deliveredDelivery),
                icon: AppIcons.checkCircle,
                iconColor: AppColors.accentStarred,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: l10n.deliverySearchLabel,
              controller: _search,
              focusNode: _searchFocus,
              placeholder: l10n.deliverySearchPlaceholder,
              textInputAction: TextInputAction.search,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              onSubmitted: (_) => _searchFocus.unfocus(),
            ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.lg),
      SizedBox(
        height: 9.5.w,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          children: [
            for (final (tab, label) in [
              (DeliveryTab.all, l10n.deliveryTabAll),
              (DeliveryTab.ready, l10n.deliveryTabReady),
              (DeliveryTab.sent, l10n.deliveryTabSent),
              (DeliveryTab.inTransit, l10n.deliveryTabInTransit),
              (DeliveryTab.delivered, l10n.deliveryTabDelivered),
            ])
              Padding(
                padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
                child: AppFilterChip(
                  label: label,
                  selected: _model.tab == tab,
                  onTap: () => _model.setTab(tab),
                ),
              ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.lg),
      ..._list(l10n, tag),
    ];
  }

  List<Widget> _list(L10n l10n, String tag) {
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);
    final orders = _model.orders;

    if (_model.isFirstLoad) {
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

    if (orders.isEmpty && _model.error != null) {
      return [
        Padding(
          padding: gutter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ApiErrorLine(error: _model.error),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
              ),
            ],
          ),
        ),
      ];
    }

    if (orders.isEmpty) {
      return [
        Padding(
          padding: gutter,
          child: EmptyBox(
            icon: AppIcons.truck,
            title: _model.isNarrowed ? l10n.deliveryNoMatchTitle : l10n.deliveryEmptyTitle,
            body: _model.isNarrowed ? l10n.deliveryNoMatchBody : l10n.deliveryEmptyBody,
          ),
        ),
      ];
    }

    return [
      SectionLabel(label: l10n.deliveryOrdersSection, trailing: Money.grouped(orders.length, tag)),
      Padding(
        padding: gutter,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (index, order) in orders.indexed) ...[
                if (index > 0)
                  const Divider(height: AppStroke.hairline, thickness: AppStroke.hairline, color: AppColors.rule),
                _DeliveryCard(
                  order: order,
                  providerName: _model.providerName(order),
                  localeTag: tag,
                  labelBusy: _labelling.contains(order.id),
                  onOpen: () => GoRouter.of(context).push(Routes.orderOf(order.id), extra: order),
                  onSend: () => _send(order),
                  onTrack: () => _track(order),
                  onLabel: () => _label(order),
                ),
              ],
            ],
          ),
        ),
      ),
    ];
  }
}

/// One order on its way to the customer.
class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    required this.order,
    required this.providerName,
    required this.localeTag,
    required this.labelBusy,
    required this.onOpen,
    required this.onSend,
    required this.onTrack,
    required this.onLabel,
  });

  final Order order;
  final String? providerName;
  final String localeTag;
  final bool labelBusy;
  final VoidCallback onOpen;
  final VoidCallback onSend;
  final VoidCallback onTrack;
  final VoidCallback onLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    const dash = '—';

    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(3.59.w), // 14
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(order.orderNumber, style: AppText.title, overflow: TextOverflow.ellipsis)),
                SizedBox(width: AppSpacing.sm),
                deliveryStatusPill(order.deliveryStatus, l10n),
              ],
            ),
            SizedBox(height: 1.54.w),
            Row(
              children: [
                Flexible(
                  child: Text(order.clientName, style: AppText.bodyS, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (order.clientPhone case final phone?) ...[
                  SizedBox(width: AppSpacing.sm),
                  Text(Phone.format(phone), style: AppText.labelMeta),
                ],
              ],
            ),
            if (order.clientAddress case final address?) ...[
              SizedBox(height: 1.03.w),
              Text(
                address,
                style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 1.54.w),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    l10n.deliveryMetaLine(providerName ?? dash, order.trackingNumber ?? dash),
                    style: AppText.labelMeta,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(Money.exact(order.total, localeTag), style: AppText.numeralM),
              ],
            ),
            if (order.canSendToDelivery || order.canTrack) ...[
              SizedBox(height: 2.05.w),
              Wrap(
                spacing: 1.54.w,
                runSpacing: 1.54.w,
                children: [
                  if (order.canSendToDelivery)
                    CardButton(icon: AppIcons.truck, label: l10n.deliverySend, onTap: onSend),
                  if (order.canTrack) ...[
                    CardButton(icon: AppIcons.search, label: l10n.deliveryTrack, onTap: onTrack),
                    CardButton(icon: AppIcons.fileText, label: l10n.deliveryLabel, onTap: onLabel, busy: labelBusy),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
