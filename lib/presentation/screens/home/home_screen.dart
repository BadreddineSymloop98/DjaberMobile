import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/connected_page.dart';
import '../../../data/models/conversation.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/agent_repository.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/home_view_model.dart';
import '../../viewmodels/session_view_model.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/checklist_row.dart';
import '../../widgets/djaber_logo.dart';
import '../../widgets/home_widgets.dart';
import 'menu_drawer.dart';

/// `09 — Accueil`.
///
/// The web dashboard rearranged for a phone: greeting, the escalation queue,
/// four figures, three quick actions, the connected Pages, and the `Démarrer`
/// checklist. **`À traiter` is mobile-only by design** (brief §2) — the web
/// has no equivalent and needs none.
///
/// Every number is live. Nothing on this screen is sample data; see
/// [HomeViewModel] for the table of sources.
///
/// Two gutters, as the frame has them: section labels sit on **20** so they
/// read as annotations, and the content they head sits on **16**.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _model = HomeViewModel(
    dashboard: context.read<DashboardRepository>(),
    pages: context.read<PageRepository>(),
    agents: context.read<AgentRepository>(),
  );

  @override
  void initState() {
    super.initState();
    _model.load();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final locale = Localizations.localeOf(context);
    final user = context.watch<SessionViewModel>().user;

    return ChangeNotifierProvider<HomeViewModel>.value(
      value: _model,
      child: Consumer<HomeViewModel>(
        builder: (context, model, _) {
          return Scaffold(
            backgroundColor: AppColors.ink,
            body: SafeArea(
              bottom: false,
              child: RefreshIndicator(
                // The merchant's own way to ask "is there anything new?" until
                // push is wired (brief Q5). Silent, so the queue they are
                // reading does not blank out under them.
                onRefresh: () => model.load(silent: true),
                backgroundColor: AppColors.surface,
                color: AppColors.textPrimary,
                child: ListView(
                  // Always scrollable, so pull-to-refresh works even when the
                  // content is short — which it is for a new merchant.
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: AppSpacing.xxxl),
                  children: [
                    _Header(user: user, onMenu: () => openMenuDrawer(context, connectedPages: model.pages.length)),
                    _Greeting(
                      name: user?.greetingName ?? '',
                      locale: locale,
                      l10n: l10n,
                    ),

                    // Asked for: a merchant with no Page has nothing that can
                    // reach the queue, so say so above it rather than showing
                    // an empty section they cannot fill from here.
                    if (!model.isFirstLoad && !model.hasPages)
                      _NoPageBanner(
                        // Not `T5`: see `_QuickActions`. The step it names is
                        // outstanding, but the place to do it is the
                        // standalone connect screen, not the wizard.
                        onConnect: () =>
                            _notBuilt(context, l10n.homeNoPageTitle),
                      ),

                    SectionLabel(
                      label: l10n.homeQueue,
                      trailing: model.queue.isEmpty
                          ? null
                          : '${model.queue.length}',
                    ),
                    _Queue(model: model, l10n: l10n),

                    _gap,
                    SectionLabel(label: l10n.homeOverview),
                    _Kpis(model: model, locale: locale, l10n: l10n),

                    _gap,
                    SectionLabel(label: l10n.homeQuickActions),
                    _QuickActions(
                      l10n: l10n,
                      onUnbuilt: (what) => _notBuilt(context, what),
                    ),

                    _gap,
                    SectionLabel(
                      label: l10n.homeYourPages,
                      trailing: model.hasPages ? l10n.homeManageAll : null,
                      onTrailingTap: () => _notBuilt(context, 'Pages'),
                    ),
                    _Pages(model: model, l10n: l10n),

                    _gap,
                    SectionLabel(label: l10n.homeGetStarted),
                    _Checklist(model: model, l10n: l10n),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget get _gap => SizedBox(height: AppSpacing.xxl); // 24


  /// Destinations that do not exist yet. Says so rather than doing nothing,
  /// which reads as a broken tap.
  void _notBuilt(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$what — ${L10n.of(context).commonNotBuilt}'),
        backgroundColor: AppColors.surfaceHigh,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Menu button, wordmark, credits pill.
class _Header extends StatelessWidget {
  const _Header({required this.user, required this.onMenu});

  final User? user;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    // Null until `/auth/profile` answers — signing in does not return credits
    // (see [User]). The pill stays off rather than showing "0 / 0", which
    // would read as an exhausted allowance.
    final remaining = user?.creditsRemaining;
    final limit = user?.creditsLimit;
    final exhausted = user?.isAgentPaused ?? false;

    return Padding(
      // Symmetric side inset. The frame gives the header 16 left and 20 right
      // — the label gutter — but the two things it insets are a square button
      // and a pill, which read as a matched pair. Unequal edges made the pill
      // look nudged inwards, so both sides take the content gutter.
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutterTight, // 16
        AppSpacing.xs, // 4
        AppSpacing.gutterTight, // 16
        AppSpacing.gutterTight, // 16
      ),
      child: Row(
        children: [
          MenuButton(onTap: onMenu),
          SizedBox(width: AppSpacing.md), // 12
          // 34 tall with an 8 gap, tagline off — the frame's header lockup.
          //
          // `Expanded` so the lockup's box takes every pixel between the menu
          // button and the pill, and `centerStart` so the lockup itself stays
          // left inside it. That is what holds the pill against the right
          // edge instead of letting it drift in beside the wordmark.
          //
          // `scaleDown` is the guard: the pill's width is the merchant's own
          // credit figures, so a large allowance on a narrow handset squeezes
          // this box, and the lockup shrinks proportionally rather than
          // overflowing. At 390 it never fires — there is 36dp of slack.
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: DjaberLogo(size: 8.72.w, gap: AppSpacing.sm),
            ),
          ),
          SizedBox(width: AppSpacing.sm), // 8
          if (remaining != null && limit != null)
            // Forced LTR: `3 760 / 5 000` is a pair of numerals, and the
            // frames keep numerals in reading order under RTL rather than
            // mirroring them (brief §21.8).
            Directionality(
              textDirection: TextDirection.ltr,
              child: CreditsPill(
                label: '${_grouped(context, remaining)} / '
                    '${_grouped(context, limit)}',
                exhausted: exhausted,
              ),
            ),
        ],
      ),
    );
  }

  static String _grouped(BuildContext context, int value) =>
      intl.NumberFormat.decimalPattern(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(value);
}

/// Date eyebrow, greeting, "voici un aperçu".
class _Greeting extends StatelessWidget {
  const _Greeting({
    required this.name,
    required this.locale,
    required this.l10n,
  });

  final String name;
  final Locale locale;
  final L10n l10n;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = intl.DateFormat.MMMMEEEEd(locale.toLanguageTag()).format(now);

    // The web's own three-way split — morning / afternoon / evening.
    final hour = now.hour;
    final greeting = hour < 12
        ? l10n.homeGreetingMorning
        : hour < 18
            ? l10n.homeGreetingAfternoon
            : l10n.homeGreetingEvening;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        AppSpacing.xxl, // 24
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date.toUpperCase(), style: AppText.labelMeta),
          SizedBox(height: AppSpacing.xs), // 4
          Text(
            name.isEmpty ? greeting : '$greeting, $name',
            style: AppText.displayM,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(l10n.homeSnapshot, style: AppText.bodyS.copyWith(height: 1.32)),
        ],
      ),
    );
  }
}

/// Shown above `À traiter` when no Page is connected.
///
/// The queue can only ever be empty in that state — escalations arrive on a
/// Page's inbox — so an empty queue would be silence where an explanation
/// belongs. This is also where a merchant who chose *Connecter plus tard* on
/// `T5` picks the step back up.
class _NoPageBanner extends StatelessWidget {
  const _NoPageBanner({required this.onConnect});

  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutterTight, // 16
        0,
        AppSpacing.gutterTight,
        AppSpacing.xxl, // 24
      ),
      child: GestureDetector(
        onTap: onConnect,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.gutterTight),
          decoration: BoxDecoration(
            color: AppColors.surface,
            // `line/lit`, the same border the waiting escalation card takes:
            // this is the one thing on the screen asking to be acted on.
            border: Border.all(
              color: AppColors.ruleStrong,
              width: AppStroke.hairline,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppIcon(
                    AppIcons.chat,
                    size: 6.15.w, // 24
                    color: AppColors.textPrimary,
                  ),
                  Transform.flip(
                    flipX: Directionality.of(context) == TextDirection.rtl,
                    child: AppIcon(AppIcons.chevronRight, size: 4.1.w),
                  ),
                ],
              ),
              SizedBox(height: 2.56.w), // 10
              Text(l10n.homeNoPageTitle, style: AppText.title),
              SizedBox(height: AppSpacing.xxs),
              Text(
                l10n.homeNoPageBody,
                style: AppText.bodyS.copyWith(height: 1.32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `À traiter` — the queue, or why it is empty.
class _Queue extends StatelessWidget {
  const _Queue({required this.model, required this.l10n});

  final HomeViewModel model;
  final L10n l10n;

  /// The frame shows two cards and rolls the rest into one row.
  static const _visible = 2;

  @override
  Widget build(BuildContext context) {
    if (model.isFirstLoad) return const _SectionLoading();

    if (model.queue.isEmpty) {
      return _EmptySection(
        // Two different silences, and they mean different things.
        message: model.hasPages ? l10n.homeQueueEmpty : l10n.homeQueueNoPage,
      );
    }

    final shown = model.queue.take(_visible).toList();
    final rest = model.queue.length - shown.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight), // 16
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final conversation in shown) ...[
            EscalationCard(
              kind: l10n.homeQueueStuck,
              time: _age(conversation, l10n),
              who: conversation.displayName,
              message: conversation.lastMessage ?? '',
              onTap: () => context.go(Routes.conversationOf(conversation.id)),
            ),
            SizedBox(height: AppSpacing.sm), // 8
          ],
          if (rest > 0)
            GestureDetector(
              onTap: () => context.go(Routes.queue),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md), // 12
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.rule,
                    width: AppStroke.hairline,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.homeQueueMore(rest),
                        style: AppText.bodyS.copyWith(
                          height: 1.32,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    Transform.flip(
                      flipX: Directionality.of(context) == TextDirection.rtl,
                      child: AppIcon(AppIcons.chevronRight, size: 4.1.w),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// How long it has been waiting, in the frame's compact form.
  String _age(Conversation conversation, L10n l10n) {
    final at = conversation.lastActivity;
    if (at == null) return '';
    final elapsed = DateTime.now().difference(at);
    if (elapsed.inMinutes < 60) return l10n.homeAgeMinutes(elapsed.inMinutes);
    if (elapsed.inHours < 24) return l10n.homeAgeHours(elapsed.inHours);
    return l10n.homeAgeDays(elapsed.inDays);
  }
}

/// `Aperçu` — four figures, two per row.
class _Kpis extends StatelessWidget {
  const _Kpis({required this.model, required this.locale, required this.l10n});

  final HomeViewModel model;
  final Locale locale;
  final L10n l10n;

  @override
  Widget build(BuildContext context) {
    final stats = model.stats;
    final sales = model.sales;
    final revenue = _short(sales.totalRevenue);
    final stockValue = _short(stats.totalStockValue);

    // The tile icons keep their bound stroke — `text/muted`. The component's
    // own note: override with an accent only where the web app itself uses
    // colour, and the dashboard does not colour these four.
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
      child: Column(
        children: [
          // `IntrinsicHeight` + `stretch` is what keeps a pair of tiles level
          // when one of their labels wraps and the other's does not. Without
          // it the taller tile's neighbour sits short, and the row of four
          // stops reading as a grid. Two children, so the extra layout pass
          // costs nothing worth counting.
          _TileRow(
            children: [
              Expanded(
                child: KpiTile(
                  label: l10n.homeKpiPages,
                  value: '${model.pages.length}',
                  icon: AppIcons.chat,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: KpiTile(
                  label: l10n.homeKpiProducts,
                  value: '${stats.totalProducts}',
                  icon: AppIcons.box,
                  // Only when there is something to warn about — an empty
                  // second line on a tile reads as a missing figure.
                  footnote: stats.lowStockProducts > 0
                      ? l10n.homeKpiLowStock(stats.lowStockProducts)
                      : null,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          _TileRow(
            children: [
              Expanded(
                child: KpiTile(
                  label: l10n.homeKpiRevenue,
                  value: revenue.value,
                  unit: revenue.unit,
                  icon: AppIcons.dollar,
                  footnote: l10n.homeKpiSales(sales.totalSales),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: KpiTile(
                  label: l10n.homeKpiStockValue,
                  value: stockValue.value,
                  unit: stockValue.unit,
                  icon: AppIcons.box,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// `1 240 000` → `1,24` + `M DA`, the way the frame writes money.
  ///
  /// A tile is 175 wide at the design frame; an ungrouped dinar figure runs
  /// off it long before a merchant's stock is worth much. The thresholds are
  /// the frame's own two examples — `1,24 M DA` and a bare `0 DA`.
  ({String value, String unit}) _short(double amount) {
    final tag = locale.toLanguageTag();
    if (amount >= 1000000) {
      final millions = amount / 1000000;
      return (
        value: intl.NumberFormat('#,##0.00', tag).format(millions),
        unit: 'M DA',
      );
    }
    if (amount >= 10000) {
      final thousands = amount / 1000;
      return (
        value: intl.NumberFormat('#,##0.0', tag).format(thousands),
        unit: 'K DA',
      );
    }
    return (
      value: intl.NumberFormat.decimalPattern(tag).format(amount.round()),
      unit: 'DA',
    );
  }
}

/// A row of tiles that stay the same height as each other.
class _TileRow extends StatelessWidget {
  const _TileRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
}

/// `Actions rapides` — three cards from the web dashboard.
///
/// **None of these route into the tutorial.** Its steps are a first-run
/// walkthrough: wizard chrome, a step counter, a footer that advances to the
/// next step. Sending a merchant there from home would drop them back into a
/// flow they have already finished, four steps from where they meant to go.
/// The standalone creation screens are not built yet, so each card says so
/// until it has a real destination.
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.l10n, required this.onUnbuilt});

  final L10n l10n;

  /// Called with the destination's name until that screen exists.
  final void Function(String what) onUnbuilt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ActionCard(
            icon: AppIcons.chat,
            iconColor: AppColors.live,
            title: l10n.homeActionConnectTitle,
            subtitle: l10n.homeActionConnectBody,
            // TODO(pages): `13 — Connecter une page`, the standalone twin of
            // `T5`. Same two brand buttons, no wizard around them.
            onTap: () => onUnbuilt(l10n.homeActionConnectTitle),
          ),
          SizedBox(height: AppSpacing.sm),
          ActionCard(
            icon: AppIcons.box,
            iconColor: AppColors.accentStarred,
            title: l10n.homeActionProductsTitle,
            subtitle: l10n.homeActionProductsBody,
            // TODO(stock): the product form outside the tutorial. Not the
            // Stock tab either — that is a list, and this card is a create.
            onTap: () => context.go(Routes.products),
          ),
          SizedBox(height: AppSpacing.sm),
          ActionCard(
            icon: AppIcons.sparkles,
            iconColor: AppColors.live,
            title: l10n.homeActionAgentsTitle,
            subtitle: l10n.homeActionAgentsBody,
            // TODO(agents): the agents list, which is where a second agent is
            // created — not `T4`, which creates the first one.
            onTap: () => onUnbuilt(l10n.homeActionAgentsTitle),
          ),
        ],
      ),
    );
  }
}

/// `Vos pages`.
class _Pages extends StatelessWidget {
  const _Pages({required this.model, required this.l10n});

  final HomeViewModel model;
  final L10n l10n;

  @override
  Widget build(BuildContext context) {
    if (model.isFirstLoad) return const _SectionLoading();
    if (!model.hasPages) {
      return _EmptySection(message: l10n.homePagesEmpty);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
      child: ListBox(
        children: [
          for (final page in model.pages)
            AppListRow(
              title: page.pageName,
              meta: _meta(page, l10n),
              unit: page.isActive ? l10n.homePageActive : l10n.homePageInactive,
            ),
        ],
      ),
    );
  }

  String _meta(ConnectedPage page, L10n l10n) {
    final network =
        page.isInstagram ? l10n.platformInstagram : l10n.platformFacebook;
    final since = page.createdAt;
    if (since == null) return network;
    return '$network  ·  ${l10n.homePageConnectedOn(since)}';
  }
}

/// `Démarrer` — the four setup steps, ticked from real state.
class _Checklist extends StatelessWidget {
  const _Checklist({required this.model, required this.l10n});

  final HomeViewModel model;
  final L10n l10n;

  @override
  Widget build(BuildContext context) {
    final steps = <(SetupStep, String, String)>[
      (
        SetupStep.connectPage,
        l10n.homeStepConnectTitle,
        l10n.homeStepConnectBody
      ),
      (
        SetupStep.addProducts,
        l10n.homeStepProductsTitle,
        l10n.homeStepProductsBody
      ),
      (SetupStep.configureAgent, l10n.homeStepAgentTitle, l10n.homeStepAgentBody),
      (SetupStep.firstSale, l10n.homeStepSaleTitle, l10n.homeStepSaleBody),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
      child: ListBox(
        children: [
          for (final (index, step) in steps.indexed)
            ChecklistRow(
              step: index + 1,
              label: step.$2,
              subtitle: step.$3,
              done: model.isStepDone(step.$1),
            ),
        ],
      ),
    );
  }
}

/// A section still loading, at the height its content will take.
class _SectionLoading extends StatelessWidget {
  const _SectionLoading();

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
        child: Container(
          height: 22.56.w, // 88 — one KPI row
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border:
                Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: SizedBox.square(
            dimension: AppSpacing.gutterTight,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
}

/// A section with nothing in it, saying so rather than collapsing.
class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.gutterTight),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border:
                Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Text(
            message,
            style: AppText.bodyS
                .copyWith(height: 1.32, color: AppColors.textMuted),
          ),
        ),
      );
}
