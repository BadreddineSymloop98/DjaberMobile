import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/plan.dart';
import '../../../data/models/stock_mode.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/billing_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/locale_view_model.dart';
import '../../viewmodels/session_view_model.dart';
import '../../viewmodels/settings_view_model.dart';
import '../../viewmodels/stock_mode_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/option_card.dart';
import 'checkout_web_view_screen.dart';
import 'plan_copy.dart';

/// `11 — Paramètres` — the web's `/dashboard?section=settings`.
///
/// Five sections, in the web's order and the frame's:
///
/// | Section | Behaviour | Source |
/// |---|---|---|
/// | Gestion du stock | Applies on tap, like the web | [StockModeViewModel] (device) |
/// | Informations du compte | Read-only — the web disables them, no update endpoint | session user |
/// | Plan & facturation | Monthly / yearly, current plan, a card per plan, checkout | `GET /api/plans`, `POST /api/payments/checkout` |
/// | Permissions API Facebook | The web's own fixed list | — |
/// | Zone de danger | The web's button has no handler and there is no endpoint: says so | — |
///
/// Copy is the web's (`page.dash.settings.*`, `settings.fb.*`,
/// `settings.danger.*`) where it exists; the frame's wording for what the web
/// hardcodes in English (the plan card labels).
///
/// The frame badges both stock modes `ACTIF` — a known Figma slip (brief).
/// Only the chosen one is badged here.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsViewModel _model = SettingsViewModel(billing: context.read<BillingRepository>());

  /// A payment's webhook can land after the checkout's outcome was shown —
  /// or while the merchant was in their bank's app. Coming back reads the
  /// plan again, so *Plan actuel* is not left on the old one.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () {
      if (mounted) context.read<SessionViewModel>().refreshProfile();
    },
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _model.load();
      // The plan may have changed on the web, or by a payment's webhook.
      context.read<SessionViewModel>().refreshProfile();
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([_model.load(), context.read<SessionViewModel>().refreshProfile()]);
  }

  /// Checkout → Chargily's page → one verify → the plan read again → the
  /// outcome. The plan buttons stay locked until all of it is done.
  Future<void> _subscribe(Plan plan) async {
    final l10n = L10n.of(context);
    final session = context.read<SessionViewModel>();
    final navigator = Navigator.of(context);

    final checkout = await _model.startCheckout(plan);
    if (!mounted) return;
    if (checkout == null) {
      final error = _model.checkoutError;
      if (error != null) AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }

    try {
      final back = await navigator.push<CheckoutReturn>(
        MaterialPageRoute(builder: (_) => CheckoutWebViewScreen(checkoutUrl: checkout.checkoutUrl)),
      );
      if (!mounted) return;

      final status = await _model.verify(checkout.checkoutId);
      // Whatever verify answered: the webhook may already have activated the
      // plan — after the page was closed, or while verify reported pending.
      await session.refreshProfile();
      if (!mounted) return;
      switch (status) {
        case CheckoutStatus.paid:
          AppToast.success(context, l10n.settingsCheckoutPaid(PlanCopy.of(context).name(plan)));
        case CheckoutStatus.failed || CheckoutStatus.canceled || CheckoutStatus.expired:
          AppToast.info(context, l10n.settingsCheckoutFailed);
        case CheckoutStatus.pending || CheckoutStatus.unknown:
          // Closing the page without paying is not worth a message; coming back
          // from Chargily's success page without a confirmation is.
          if (back == CheckoutReturn.failed) {
            AppToast.info(context, l10n.settingsCheckoutFailed);
          } else if (back == CheckoutReturn.success) {
            AppToast.info(context, l10n.settingsCheckoutPending);
          }
      }
    } finally {
      _model.endCheckout();
    }
  }

  void _deleteAccount() {
    final l10n = L10n.of(context);
    AppToast.info(context, '${l10n.settingsDeleteAccount} — ${l10n.commonNotBuilt}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final user = context.watch<SessionViewModel>().user;
    final modes = context.watch<StockModeViewModel>();
    final section = EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0.47.h, AppSpacing.gutter, AppSpacing.lg),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppBackButton(semanticLabel: l10n.commonBack),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  color: AppColors.textPrimary,
                  backgroundColor: AppColors.surface,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 3.79.h), // 32
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.settingsTitle, style: AppText.displayM),
                            SizedBox(height: AppSpacing.sm),
                            Text(l10n.settingsSubtitle, style: AppText.bodyS.copyWith(height: 1.32)),
                          ],
                        ),
                      ),

                      // ---- Langue ----
                      SectionLabel(label: l10n.settingsLanguage),
                      Padding(padding: section, child: const _Languages()),
                      SizedBox(height: AppSpacing.xxl),

                      // ---- Gestion du stock ----
                      SectionLabel(label: l10n.settingsStockMode),
                      Padding(
                        padding: section,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OptionCard(
                              icon: AppIcons.box,
                              label: l10n.stockModeSimple,
                              description: l10n.stockModeSimpleDesc,
                              selected: modes.isSimple,
                              selectedBadge: l10n.commonActive,
                              onTap: () => modes.setMode(StockMode.simple),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            OptionCard(
                              icon: AppIcons.bolt,
                              label: l10n.stockModeAdvanced,
                              description: l10n.stockModeAdvancedDesc,
                              selected: modes.isAdvanced,
                              selectedBadge: l10n.commonActive,
                              onTap: () => modes.setMode(StockMode.advanced),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxl),

                      // ---- Informations du compte ----
                      SectionLabel(label: l10n.settingsAccount),
                      Padding(
                        padding: section,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ReadOnlyField(label: l10n.authFirstName, value: user?.firstName ?? ''),
                            SizedBox(height: AppSpacing.md),
                            _ReadOnlyField(label: l10n.authLastName, value: user?.lastName ?? ''),
                            SizedBox(height: AppSpacing.md),
                            _ReadOnlyField(label: l10n.authEmail, value: user?.email ?? '', ltr: true),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxl),

                      // ---- Plan & facturation ----
                      SectionLabel(label: l10n.settingsBilling),
                      Padding(
                        padding: section,
                        child: _Billing(model: _model, user: user, onSubscribe: _subscribe),
                      ),
                      SizedBox(height: AppSpacing.xxl),

                      // ---- Permissions API Facebook ----
                      SectionLabel(label: l10n.settingsFbTitle),
                      Padding(padding: section, child: const _Permissions()),
                      SizedBox(height: AppSpacing.xxl),

                      // ---- Zone de danger ----
                      SectionLabel(label: l10n.settingsDangerTitle),
                      Padding(
                        padding: section,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Semantics(
                              button: true,
                              child: GestureDetector(
                                onTap: _deleteAccount,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  height: 12.31.w, // 48
                                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                                    borderRadius: BorderRadius.circular(AppRadius.card),
                                  ),
                                  child: Row(
                                    children: [
                                      AppIcon(AppIcons.alert, size: 5.13.w, color: AppColors.accentAlert),
                                      SizedBox(width: 2.56.w), // 10
                                      Expanded(
                                        child: Text(
                                          l10n.settingsDeleteAccount,
                                          style: AppText.title.copyWith(color: AppColors.accentAlert),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.settingsDeleteHelp,
                              style: AppText.bodyS.copyWith(height: 1.32, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The interface language: French, English, Arabic.
///
/// Each card carries the language's own name (as the web's `LanguageSwitcher`
/// shows `nativeLabel`) and, under it, its name in the current language.
///
/// A tap goes through [LocaleViewModel.setLanguage], which persists the choice
/// and from then on ignores the phone's system language — including a tap on
/// the language already shown, which pins what was until then only inherited
/// from the handset. `MaterialApp` rebuilds with the new locale (RTL for
/// Arabic); the router is created once outside it, so the merchant stays here.
class _Languages extends StatelessWidget {
  const _Languages();

  static const _order = [AppLanguage.french, AppLanguage.english, AppLanguage.arabic];

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final locale = context.watch<LocaleViewModel>();

    String translated(AppLanguage language) => switch (language) {
          AppLanguage.french => l10n.settingsLanguageFrench,
          AppLanguage.english => l10n.settingsLanguageEnglish,
          AppLanguage.arabic => l10n.settingsLanguageArabic,
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, language) in _order.indexed) ...[
          if (index > 0) SizedBox(height: AppSpacing.sm),
          OptionCard(
            label: language.nativeLabel,
            description: translated(language),
            selected: locale.language == language,
            selectedBadge: l10n.commonActive,
            onTap: () => locale.setLanguage(language),
          ),
        ],
        SizedBox(height: AppSpacing.sm),
        Text(
          l10n.settingsLanguageHelp,
          style: AppText.bodyS.copyWith(height: 1.32, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

/// A field that only shows a value — the frame's `Text Field` with the web's
/// `disabled`.
class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value, this.ltr = false});

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      value: value,
      readOnly: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppText.labelMeta),
          SizedBox(height: 1.54.w), // 6
          Container(
            height: AppSize.control,
            width: double.infinity,
            alignment: AlignmentDirectional.centerStart,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            ),
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppText.bodyS.copyWith(color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: ltr ? TextDirection.ltr : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// The cycle switch, the current plan, then one card per plan.
class _Billing extends StatelessWidget {
  const _Billing({required this.model, required this.user, required this.onSubscribe});

  final SettingsViewModel model;
  final User? user;
  final ValueChanged<Plan> onSubscribe;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final tag = Localizations.localeOf(context).toLanguageTag();
    final slug = user?.plan;
    final copy = PlanCopy(l10n, tag);
    final currentName = model.plans.where((plan) => plan.slug == slug).map(copy.name).firstOrNull ??
        (slug == null || slug.isEmpty ? l10n.settingsFree : copy.nameForSlug(slug));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AppFilterChip(
              label: l10n.settingsMonthly,
              selected: model.cycle == BillingCycle.monthly,
              onTap: () => model.setCycle(BillingCycle.monthly),
            ),
            SizedBox(width: AppSpacing.sm),
            AppFilterChip(
              label: l10n.settingsYearly,
              selected: model.cycle == BillingCycle.yearly,
              onTap: () => model.setCycle(BillingCycle.yearly),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settingsCurrentPlan.toUpperCase(), style: AppText.labelMicro),
                    SizedBox(height: AppSpacing.xxs),
                    Text(currentName, style: AppText.title),
                  ],
                ),
              ),
              _Badge(label: currentName),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        if (model.isFirstLoad)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: const Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
              ),
            ),
          )
        else if (model.plans.isEmpty && model.error != null) ...[
          ApiErrorLine(error: model.error),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton(onPressed: model.load, child: Text(l10n.commonRetry)),
          ),
        ] else if (model.plans.isEmpty)
          Container(
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Text(
              l10n.settingsNoPlans,
              textAlign: TextAlign.center,
              style: AppText.bodyS.copyWith(color: AppColors.textMuted),
            ),
          )
        else
          for (final (index, plan) in model.plans.indexed) ...[
            if (index > 0) SizedBox(height: AppSpacing.md),
            _PlanCard(
              plan: plan,
              cycle: model.cycle,
              current: plan.slug == slug,
              busyLabel: model.subscribingSlug != plan.slug
                  ? null
                  : model.checkoutPhase == CheckoutPhase.verifying
                      ? l10n.settingsVerifying
                      : l10n.settingsRedirecting,
              locked: model.isSubscribing,
              tag: tag,
              onSubscribe: () => onSubscribe(plan),
            ),
          ],
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.cycle,
    required this.current,
    this.busyLabel,
    this.locked = false,
    required this.tag,
    required this.onSubscribe,
  });

  final Plan plan;
  final BillingCycle cycle;
  final bool current;

  /// What the button says while this plan's checkout runs — null otherwise.
  final String? busyLabel;

  /// A checkout is running, this plan's or another's: the button is disabled.
  final bool locked;
  final String tag;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final price = plan.priceFor(cycle);
    final free = price <= 0;
    final amount = Money.grouped(price.round(), tag);
    final unit = cycle == BillingCycle.yearly
        ? l10n.settingsPerYear(plan.currency)
        : l10n.settingsPerMonth(plan.currency);
    // The server's French, translated where it is recognised (see [PlanCopy]).
    final copy = PlanCopy(l10n, tag);
    final description = copy.description(plan)?.trim();
    final features = copy.features(plan);

    return Container(
      padding: EdgeInsets.all(AppSpacing.gutterTight), // 16
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          // The web lights the featured plan's border and rings the current one.
          color: current || plan.isFeatured ? AppColors.ruleStrong : AppColors.rule,
          width: AppStroke.hairline,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(copy.name(plan), style: AppText.title)),
              if (current)
                _Badge(label: l10n.settingsBadgeCurrent, lit: true)
              else if (plan.isFeatured)
                _Badge(label: l10n.settingsBadgePopular),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(child: Text(free ? l10n.settingsFree : amount, style: AppText.displayM)),
              if (!free) ...[
                SizedBox(width: 1.54.w), // 6
                Text(unit.toUpperCase(), style: AppText.labelMicro),
              ],
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            SizedBox(height: AppSpacing.md),
            Text(description, style: AppText.bodyS.copyWith(height: 1.32, color: AppColors.textMuted)),
          ],
          if (features.isNotEmpty) ...[
            SizedBox(height: AppSpacing.md),
            // Six at most, as the web slices them.
            for (final feature in features.take(6))
              Padding(
                padding: EdgeInsets.only(bottom: 1.54.w), // 6
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 0.51.w), // 2
                      child: AppIcon(AppIcons.check, size: 3.59.w, color: AppColors.textMuted), // 14
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(feature, style: AppText.bodyS.copyWith(height: 1.32, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
          ],
          SizedBox(height: AppSpacing.sm),
          if (current)
            _StaticAction(label: l10n.settingsYourPlan)
          else if (free)
            _StaticAction(label: l10n.settingsFreeNoPayment)
          else
            FilledButton(
              onPressed: locked ? null : onSubscribe,
              child: Text(busyLabel ?? l10n.settingsSubscribe('$amount ${plan.currency}')),
            ),
        ],
      ),
    );
  }
}

/// The frame's outlined, inert button — "Votre plan actuel".
class _StaticAction extends StatelessWidget {
  const _StaticAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.control,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Text(label, style: AppText.bodyS.copyWith(color: AppColors.textMuted), maxLines: 1),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.lit = false});

  final String label;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        border: Border.all(color: lit ? AppColors.ruleStrong : AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppText.labelMicro.copyWith(color: lit ? AppColors.textPrimary : AppColors.textSecondary),
      ),
    );
  }
}

/// The web's fixed list — the permissions the app holds, and the ones that
/// would need Facebook's App Review.
class _Permissions extends StatelessWidget {
  const _Permissions();

  static const _active = ['pages_show_list', 'pages_manage_metadata', 'pages_messaging'];
  static const _available = [
    'pages_read_engagement',
    'pages_read_user_content',
    'pages_manage_posts',
    'pages_manage_engagement',
    'read_insights',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    Widget chips(List<String> names) => Wrap(
          spacing: 1.54.w, // 6
          runSpacing: 1.54.w,
          children: [
            for (final name in names)
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Text(
                  name,
                  style: AppText.labelMeta.copyWith(color: AppColors.textSecondary),
                  textDirection: TextDirection.ltr,
                ),
              ),
          ],
        );

    return Container(
      padding: EdgeInsets.all(3.59.w), // 14
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.settingsFbActive, style: AppText.title),
          SizedBox(height: AppSpacing.sm),
          chips(_active),
          SizedBox(height: AppSpacing.md),
          Container(height: AppStroke.hairline, color: AppColors.rule),
          SizedBox(height: AppSpacing.md),
          Text(l10n.settingsFbAvailable, style: AppText.title),
          SizedBox(height: AppSpacing.sm),
          chips(_available),
          SizedBox(height: AppSpacing.sm),
          Text(l10n.settingsFbReviewHint, style: AppText.bodyS.copyWith(height: 1.32, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
