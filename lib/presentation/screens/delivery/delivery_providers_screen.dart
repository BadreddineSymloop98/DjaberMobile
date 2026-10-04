import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/route_observer.dart';
import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/phone.dart';
import '../../../data/models/delivery.dart';
import '../../../data/repositories/delivery_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/delivery_providers_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/leave_sheet.dart';
import '../../widgets/list_widgets.dart';
import 'delivery_widgets.dart';

/// `Delivery providers` (Figma `662:14400`, `· aucun transporteur` `662:14688`)
/// — the web's `stock/delivery/settings`.
///
/// One card per courier account: its name, *Par défaut*, an active dot (an
/// inactive account is drawn at 60 %, as on the web), the courier and the
/// sender details, *Modifier* and delete.
class DeliveryProvidersScreen extends StatefulWidget {
  const DeliveryProvidersScreen({super.key});

  @override
  State<DeliveryProvidersScreen> createState() => _DeliveryProvidersScreenState();
}

class _DeliveryProvidersScreenState extends State<DeliveryProvidersScreen> with RouteAware {
  late final DeliveryProvidersViewModel _model =
      DeliveryProvidersViewModel(delivery: context.read<DeliveryRepository>());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) appRouteObserver.subscribe(this, route);
  }

  /// Back from the form: an account was added or edited (or not — reading
  /// the list again is cheap, and the only way to see every exit).
  @override
  void didPopNext() {
    if (mounted) unawaited(_model.load());
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _model.dispose();
    super.dispose();
  }

  void _add() => GoRouter.of(context).push(Routes.deliveryProviderNew);

  void _edit(DeliveryProvider p) => GoRouter.of(context).push(Routes.deliveryProviderEditOf(p.id), extra: p);

  /// `Delete a provider` (Figma `662:16223`): the frame's question, plus a
  /// notice the frame lacks (decided 2026-10-01) — orders already sent with
  /// this courier keep their tracking number but can no longer be tracked or
  /// have their label printed (the API answers 400 once the account is gone),
  /// and, for the default courier, that a new default must be chosen (the
  /// backend does not pick one).
  Future<void> _delete(DeliveryProvider p) async {
    if (_model.isDeleting(p)) return;
    final l10n = L10n.of(context);
    final confirmed = await showDestructiveSheet(
      context,
      title: l10n.deliveryDeleteTitle,
      body: l10n.deliveryDeleteBody,
      confirmLabel: l10n.commonDelete,
      noticeTitle: l10n.deliveryDeleteNoticeTitle,
      noticeBody: [
        l10n.deliveryDeleteNoticeBody(p.displayName),
        if (p.isDefault) l10n.deliveryDeleteNoticeDefault,
      ].join('\n\n'),
    );
    if (!confirmed || !mounted) return;
    final outcome = await _model.delete(p);
    if (!mounted) return;
    switch (outcome.kind) {
      case DeleteKind.deleted:
        AppToast.success(context, l10n.deliveryProviderDeleted(p.displayName));
      case DeleteKind.alreadyGone:
        AppToast.info(context, l10n.deliveryProviderAlreadyGone(p.displayName));
      case DeleteKind.failed:
        AppToast.info(context, apiErrorMessage(outcome.error!, l10n));
      case DeleteKind.ignored:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _model.load,
                  color: AppColors.textPrimary,
                  backgroundColor: AppColors.surface,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 0.47.h, bottom: AppSpacing.lg),
                    children: [
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
                            Text(l10n.deliveryFeesEyebrow, style: AppText.labelMeta),
                            SizedBox(height: 1.54.w),
                            Text(l10n.deliveryProvidersTitle, style: AppText.displayM),
                            SizedBox(height: 1.54.w),
                            Text(
                              l10n.deliveryProvidersSubtitle,
                              style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.32),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      ..._list(l10n),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.md),
                child: FilledButton(onPressed: _add, child: Text(l10n.deliveryAddProvider)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _list(L10n l10n) {
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);
    final providers = _model.providers;

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

    if (providers.isEmpty && _model.error != null) {
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

    if (providers.isEmpty) {
      return [
        Padding(
          padding: gutter,
          child: EmptyBox(
            icon: AppIcons.settings,
            title: l10n.deliveryProvidersEmptyTitle,
            body: l10n.deliveryProvidersEmptyBody,
          ),
        ),
      ];
    }

    final lang = Localizations.localeOf(context).languageCode;
    return [
      SectionLabel(label: l10n.deliveryProvidersSection, trailing: '${providers.length}'),
      for (final p in providers)
        Padding(
          padding: gutter.copyWith(bottom: AppSpacing.sm),
          child: _ProviderCard(
            provider: p,
            deleting: _model.isDeleting(p),
            courierName: _model.courierName(p.provider),
            wilayaName: _model.wilaya(p.senderWilayaId)?.nameFor(lang),
            onEdit: () => _edit(p),
            onDelete: () => _delete(p),
          ),
        ),
    ];
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.provider,
    required this.deleting,
    required this.courierName,
    required this.wilayaName,
    required this.onEdit,
    required this.onDelete,
  });

  final DeliveryProvider provider;

  /// The delete is on its way: the card stops answering taps.
  final bool deleting;
  final String courierName;
  final String? wilayaName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final p = provider;

    Widget fact(String label, String? value) => value == null
        ? const SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.only(top: 1.03.w),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: '$label ', style: AppText.bodyS.copyWith(color: AppColors.textMuted)),
                TextSpan(text: value, style: AppText.bodyS),
              ]),
            ),
          );

    return Opacity(
      opacity: p.isActive ? 1 : 0.6,
      child: Container(
        padding: EdgeInsets.all(3.59.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Flexible(child: Text(p.displayName, style: AppText.title, overflow: TextOverflow.ellipsis)),
                if (p.isDefault) ...[
                  SizedBox(width: AppSpacing.sm),
                  DefaultBadge(label: l10n.deliveryDefaultBadge),
                ],
                SizedBox(width: AppSpacing.sm),
                // Filled when the account can send, hollow when it is off.
                Container(
                  width: 2.56.w,
                  height: 2.56.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.isActive ? AppColors.textPrimary : null,
                    border: p.isActive ? null : Border.all(color: AppColors.textMuted, width: AppStroke.hairline),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            fact(l10n.deliveryCardProvider, courierName),
            fact(l10n.deliveryCardSender, p.senderName),
            fact(l10n.deliveryCardPhone, p.senderPhone == null ? null : Phone.format(p.senderPhone!)),
            fact(l10n.deliveryCardWilaya, wilayaName),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: CardButton(
                    icon: AppIcons.edit,
                    label: l10n.deliveryEdit,
                    onTap: deleting ? null : onEdit,
                    expand: true,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                if (deleting)
                  SizedBox(
                    width: 9.23.w,
                    height: 9.23.w,
                    child: const Center(
                      child: SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
                      ),
                    ),
                  )
                else
                  RowAction(icon: AppIcons.trash, label: l10n.commonDelete, onTap: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
