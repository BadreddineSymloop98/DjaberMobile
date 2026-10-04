import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/session_view_model.dart';
import '../../widgets/app_icon.dart';
import '../orders/order_status_pill.dart';
import 'home_screen.dart';
import 'menu_drawer.dart';

/// `16s — Services` (Figma `729:23743`) — the web's `/dashboard/services`.
///
/// Opened from the drawer's *Services* label (its chevron still shows the
/// group). Figma gives it home's header — menu, wordmark, credits — since it
/// is a top-level section, not a step down from somewhere.
///
/// Four cards, in the web's order. The web ships only *Produits* as active;
/// here *Ventes* and *Bot* open what the app now has — Sales and the AI agents
/// — and only *Commercial* is still *Bientôt*, as in the drawer (decided
/// 2026-10-04).
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final user = context.watch<SessionViewModel>().user;
    final router = GoRouter.of(context);

    final services = <_Service>[
      _Service(
        icon: AppIcons.box,
        title: l10n.servicesProducts,
        body: l10n.servicesProductsBody,
        // Pushed, not the tab: back from the overview returns here. Switching
        // to the Stock tab replaced the stack and sent back to home.
        onOpen: () => router.push(Routes.stockOverview),
      ),
      _Service(
        icon: AppIcons.shoppingCart,
        title: l10n.servicesSales,
        body: l10n.servicesSalesBody,
        onOpen: () => router.push(Routes.sales),
      ),
      _Service(
        icon: AppIcons.bot,
        title: l10n.servicesBot,
        body: l10n.servicesBotBody,
        onOpen: () => router.push(Routes.agents),
      ),
      _Service(
        icon: AppIcons.megaphone,
        title: l10n.servicesCommercial,
        body: l10n.servicesCommercialBody,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(top: 0.47.h, bottom: AppSpacing.xxl),
          children: [
            HomeHeader(user: user, onMenu: () => openMenuDrawer(context)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.servicesTitle, style: AppText.displayS),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.servicesSubtitle,
                    style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  for (final service in services) ...[
                    _ServiceCard(service: service),
                    SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Service {
  const _Service({required this.icon, required this.title, required this.body, this.onOpen});

  final List<String> icon;
  final String title;
  final String body;

  /// Null while the service is not available yet.
  final VoidCallback? onOpen;

  bool get isActive => onOpen != null;
}

/// One service — an active one bright, bordered and tappable as a whole; a
/// coming one at 60 %, inert, with *Bientôt* where *Actif* would be.
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final _Service service;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final s = service;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    final card = Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: s.isActive ? AppColors.ruleStrong : AppColors.rule,
          width: AppStroke.hairline,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10.26.w,
                height: 10.26.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: AppIcon(s.icon, size: 5.13.w, color: AppColors.textSecondary),
              ),
              const Spacer(),
              if (s.isActive)
                OrderStatusPill(label: l10n.servicesActive, tone: PillTone.settled)
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 1.54.w, vertical: 0.77.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                    borderRadius: BorderRadius.circular(1.54.w),
                  ),
                  child: Text(l10n.servicesSoon.toUpperCase(), style: AppText.labelMicro),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Text(s.title, style: AppText.title),
          SizedBox(height: AppSpacing.xs),
          Text(s.body, style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.4)),
          if (s.isActive) ...[
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.servicesOpen,
                  style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(width: AppSpacing.xs),
                Transform.flip(
                  flipX: rtl,
                  child: AppIcon(AppIcons.chevronRight, size: 3.59.w, color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (!s.isActive) {
      return Semantics(enabled: false, child: Opacity(opacity: 0.6, child: card));
    }
    return Semantics(
      button: true,
      label: s.title,
      child: GestureDetector(onTap: s.onOpen, behavior: HitTestBehavior.opaque, child: card),
    );
  }
}
