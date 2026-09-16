import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/agent.dart';
import '../../../data/models/connected_page.dart';
import '../../../data/models/page_summary.dart';
import '../../../data/repositories/agent_repository.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/pages_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/connect_platform_button.dart';
import '../../widgets/icon_square_button.dart';
import '../agents/agent_widgets.dart' show agentPersonalityLabel, compactButton;
import '../tutorial/oauth_web_view_screen.dart';
import 'generate_agent_sheet.dart';

/// `12 — Pages connectées` (Figma `155:820`), and `13 — Connecter une page`
/// (`156:958`) — the same screen with no page yet.
///
/// The web's pages section (`src/app/dashboard/page.tsx`, `section=pages`) and
/// its `PageDashboardCard`: eyebrow, title, the connect pair, the channel strip,
/// platform tabs, then one card per page — identity, AI status, four counters,
/// the agent strip with Générer / Régénérer, and Boîte · Stock · Configurer ·
/// disconnect.
///
/// Connecting reuses `T5`'s web view — Meta's dialog, then the backend's
/// callback — without the tutorial around it.
class PagesScreen extends StatefulWidget {
  const PagesScreen({super.key});

  @override
  State<PagesScreen> createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen> {
  late final PagesViewModel _model = PagesViewModel(
    pages: context.read<PageRepository>(),
    agents: context.read<AgentRepository>(),
  );

  @override
  void initState() {
    super.initState();
    // After the first frame, so a failure has a tree to show its message in.
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _connect(PagePlatform platform) async {
    final url = await _model.startConnect(platform);
    if (!mounted) return;
    final l10n = L10n.of(context);
    if (url == null) {
      final error = _model.connectError;
      if (error != null) AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }

    final result = await Navigator.of(context).push<OAuthResult>(
      MaterialPageRoute(
        builder: (_) => OAuthWebViewScreen(authUrl: url, platform: platform),
        fullscreenDialog: true,
      ),
    );
    if (!mounted) return;

    switch (result?.outcome ?? OAuthOutcome.dismissed) {
      // Backing out is not a failure — nothing is said.
      case OAuthOutcome.dismissed:
        _model.connectEnded();
        return;
      case OAuthOutcome.denied:
        _model.connectEnded();
        AppToast.info(context, l10n.oauthDenied);
        return;
      // Meta granted; the backend's callback page then reported an error.
      case OAuthOutcome.failed:
        _model.connectEnded(failure: result?.report?.reason ?? 'no reason given');
        AppToast.info(context, l10n.connectFailed);
        return;
      case OAuthOutcome.granted:
        break;
    }

    final outcome = await _model.afterGrant(platform, report: result?.report);
    if (!mounted) return;
    switch (outcome) {
      case PageConnectOutcome.connected:
        AppToast.success(context, l10n.toastPageConnected);
      case PageConnectOutcome.nothingNew:
        AppToast.info(context, l10n.connectNothingNew);
    }
  }

  Future<void> _disconnect(ConnectedPage page) async {
    final l10n = L10n.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      barrierColor: AppColors.scrim,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.xl, AppSpacing.gutter, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.pagesDisconnectTitle, style: AppText.title),
              SizedBox(height: AppSpacing.xs),
              Text(
                l10n.pagesDisconnectBody(page.pageName),
                style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
              ),
              SizedBox(height: AppSpacing.xl),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentAlert,
                  foregroundColor: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.of(sheet).pop(true),
                child: Text(l10n.pagesDisconnectConfirm),
              ),
              SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => Navigator.of(sheet).pop(false),
                child: Text(l10n.commonCancel),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    final done = await _model.disconnect(page);
    if (!mounted) return;
    final error = _model.disconnectError;
    if (done) {
      AppToast.success(context, l10n.pagesDisconnectedToast);
    } else if (error != null) {
      AppToast.info(context, apiErrorMessage(error, l10n));
    }
  }

  Future<void> _generate(ConnectedPage page) async {
    final created = await showGenerateAgentSheet(context, page: page);
    if (created == null || !mounted) return;
    final l10n = L10n.of(context);
    AppToast.success(
      context,
      created ? l10n.agentGenCreated(page.pageName) : l10n.agentGenUpdated(page.pageName),
    );
    await _model.refreshSummaries();
  }

  Future<void> _editAgent(String agentId) async {
    await GoRouter.of(context).push(Routes.agentEditOf(agentId));
    if (mounted) await _model.refreshSummaries();
  }

  void _notBuilt(String what) {
    AppToast.info(context, '$what — ${L10n.of(context).commonNotBuilt}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ChangeNotifierProvider<PagesViewModel>.value(
      value: _model,
      child: Consumer<PagesViewModel>(
        builder: (context, model, _) {
          return Scaffold(
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
                      onRefresh: model.load,
                      color: AppColors.textPrimary,
                      backgroundColor: AppColors.surface,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xxl),
                        children: [
                          Text(l10n.pagesEyebrow.toUpperCase(), style: AppText.labelMeta),
                          SizedBox(height: AppSpacing.xs),
                          Text(l10n.pagesTitle, style: AppText.displayM),
                          SizedBox(height: AppSpacing.sm),
                          Text(l10n.pagesSubtitle, style: AppText.bodyS.copyWith(height: 1.32)),
                          SizedBox(height: AppSpacing.xl),
                          ..._content(model, l10n),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _content(PagesViewModel model, L10n l10n) {
    if (model.isFirstLoad) {
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

    final error = model.error;
    // A failed load with nothing to show. With cards on screen a failed
    // refresh keeps them — stale beats blank.
    if (model.pages.isEmpty && error != null) {
      return [
        ApiErrorLine(error: error),
        OutlinedButton(onPressed: model.isBusy ? null : model.load, child: Text(l10n.commonRetry)),
      ];
    }

    final connecting = model.connectingPlatform;
    Widget connect(PagePlatform platform) => ConnectPlatformButton(
          platform: platform,
          label: platform == PagePlatform.instagram ? l10n.connectInstagram : l10n.connectFacebook,
          busy: connecting == platform,
          onTap: connecting == null ? () => _connect(platform) : null,
        );

    final visible = model.visiblePages;
    // The connect buttons follow the chip: Facebook on the Facebook tab,
    // Instagram on the Instagram tab, both on Toutes les plateformes.
    final showFacebook = model.filter != PagesFilter.instagram;
    final showInstagram = model.filter != PagesFilter.facebook;
    return [
      if (model.pages.isNotEmpty) ...[
        _ChannelStrip(model: model),
        SizedBox(height: AppSpacing.lg),
      ],
      _PlatformTabs(model: model),
      SizedBox(height: AppSpacing.lg),
      if (model.pages.isNotEmpty) ...[
        // Under the chips, so the button(s) shown are visibly the ones the
        // chip chose. Stacked: side by side they do not fit the Instagram
        // label at 320dp. With no page, the empty panel below carries them.
        if (showFacebook) connect(PagePlatform.facebook),
        if (showFacebook && showInstagram) SizedBox(height: AppSpacing.sm),
        if (showInstagram) connect(PagePlatform.instagram),
        SizedBox(height: AppSpacing.lg),
      ],
      if (visible.isEmpty)
        _EmptyPanel(
          filter: model.filter,
          // With pages connected the pair is already at the top; an empty
          // platform tab would otherwise show it twice.
          facebook: model.pages.isEmpty && showFacebook ? connect(PagePlatform.facebook) : null,
          instagram: model.pages.isEmpty && showInstagram ? connect(PagePlatform.instagram) : null,
        )
      else
        for (final page in visible) ...[
          _PageCard(
            page: page,
            summary: model.summaryFor(page.id),
            linkedAgent: model.agentFor(page.id),
            agentsKnown: model.agentsKnown,
            busy: model.busyPageId == page.id,
            enabled: model.busyPageId == null,
            // The inbox tab; a page-filtered inbox is not built yet.
            onInbox: () => GoRouter.of(context).go(Routes.inbox),
            onStock: () => GoRouter.of(context).push(Routes.products),
            // The web's page configuration (`/dashboard/page/{id}`) is not
            // built on mobile.
            onConfigure: () => _notBuilt(l10n.pageCardActionConfigure),
            onDisconnect: () => _disconnect(page),
            onGenerate: () => _generate(page),
            onEditAgent: _editAgent,
          ),
          SizedBox(height: AppSpacing.md),
        ],
    ];
  }
}

/// Total · Facebook · Instagram · plan limit — the web's `ChannelStat` band.
class _ChannelStrip extends StatelessWidget {
  const _ChannelStrip({required this.model});

  final PagesViewModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final total = model.pages.length;
    final stats = <(String, String)>[
      (l10n.pagesStatTotal, '$total'),
      (l10n.platformFacebook, '${model.countOn(PagePlatform.facebook)}'),
      (l10n.platformInstagram, '${model.countOn(PagePlatform.instagram)}'),
      // The web's literal: no plan's page cap is read here (§24.6).
      (l10n.pagesStatPlanLimit, '$total/∞'),
    ];

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (index, stat) in stats.indexed) ...[
              if (index > 0) Container(width: AppStroke.hairline, color: AppColors.rule),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stat.$2, style: AppText.numeralM, textDirection: TextDirection.ltr),
                      SizedBox(height: AppSpacing.xxs),
                      Text(stat.$1.toUpperCase(), style: AppText.labelMicro, maxLines: 2),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Toutes les plateformes · Facebook · Instagram — the Figma `Tab`: white when
/// chosen, outlined otherwise, brand mark on the two platforms.
class _PlatformTabs extends StatelessWidget {
  const _PlatformTabs({required this.model});

  final PagesViewModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final tabs = <(PagesFilter, String, List<String>?)>[
      (PagesFilter.all, l10n.pagesFilterAll, null),
      (PagesFilter.facebook, l10n.platformFacebook, AppIcons.facebook),
      (PagesFilter.instagram, l10n.platformInstagram, AppIcons.instagram),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (index, tab) in tabs.indexed) ...[
            if (index > 0) SizedBox(width: AppSpacing.sm),
            _PlatformTab(
              label: tab.$2,
              icon: tab.$3,
              selected: model.filter == tab.$1,
              onTap: () => model.setFilter(tab.$1),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlatformTab extends StatelessWidget {
  const _PlatformTab({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final List<String>? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : AppColors.textSecondary;
    final glyph = icon;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 9.23.w, // 36
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.textPrimary : Colors.transparent,
            border: Border.all(color: selected ? AppColors.textPrimary : AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (glyph != null) ...[
                AppIcon(glyph, size: 4.1.w, color: color, filled: true),
                SizedBox(width: 1.54.w), // 6
              ],
              Text(label, style: AppText.bodyS.copyWith(color: color), maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}

/// `13 — Connecter une page`: no page (or none on the chosen platform) and the
/// two ways to connect one.
class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.filter, this.facebook, this.instagram});

  final PagesFilter filter;

  /// The connect pair, when the screen does not already show it above.
  final Widget? facebook;
  final Widget? instagram;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final (title, body) = switch (filter) {
      PagesFilter.all => (l10n.pagesEmptyTitle, l10n.pagesEmptyBody),
      PagesFilter.facebook => (
          l10n.pagesEmptyPlatformTitle(l10n.platformFacebook),
          l10n.pagesEmptyPlatformBody(l10n.platformFacebook),
        ),
      PagesFilter.instagram => (
          l10n.pagesEmptyPlatformTitle(l10n.platformInstagram),
          l10n.pagesEmptyPlatformBody(l10n.platformInstagram),
        ),
    };

    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxxl, AppSpacing.xl, AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: AppIcon(AppIcons.chat, size: 10.26.w, color: AppColors.textMuted)), // 40
          SizedBox(height: AppSpacing.lg),
          Text(title, style: AppText.title, textAlign: TextAlign.center),
          SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
            textAlign: TextAlign.center,
          ),
          for (final (index, button) in [?facebook, ?instagram].indexed) ...[
            SizedBox(height: index == 0 ? AppSpacing.xl : AppSpacing.sm),
            button,
          ],
        ],
      ),
    );
  }
}

/// One connected page — the web's `PageDashboardCard`, as Figma `Page Card`
/// draws it.
class _PageCard extends StatelessWidget {
  const _PageCard({
    required this.page,
    required this.summary,
    required this.linkedAgent,
    required this.agentsKnown,
    required this.busy,
    required this.enabled,
    required this.onInbox,
    required this.onStock,
    required this.onConfigure,
    required this.onDisconnect,
    required this.onGenerate,
    required this.onEditAgent,
  });

  final ConnectedPage page;
  final PageSummary? summary;

  /// The agent answering on this page, per the agents list; null when none.
  final Agent? linkedAgent;

  /// False when the agents list could not be had — the summary decides then.
  final bool agentsKnown;
  final bool busy;
  final bool enabled;
  final VoidCallback onInbox;
  final VoidCallback onStock;
  final VoidCallback onConfigure;
  final VoidCallback onDisconnect;
  final VoidCallback onGenerate;
  final ValueChanged<String> onEditAgent;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final tag = Localizations.localeOf(context).toLanguageTag();
    final s = summary;
    final network = (page.isInstagram ? l10n.platformInstagram : l10n.platformFacebook).toUpperCase();
    final meta = s == null ? network : '$network  ·  ${_ago(s.lastActivity, l10n, tag).toUpperCase()}';
    String count(int? value) => value == null ? '–' : '$value';

    // The agent as Agents IA sees it; the summary's own reading only when the
    // agents list could not be had. Null status: nothing known yet.
    final linked = linkedAgent;
    final bool? aiOn = agentsKnown ? (linked?.isActive ?? false) : s?.agent.enabled;
    final ready = agentsKnown
        ? linked != null && linked.isActive && (linked.customInstructions?.trim().isNotEmpty ?? false)
        : (s?.agent.isReady ?? false);
    final personality = agentsKnown ? linked?.personality : s?.agent.personality;
    final agentId = agentsKnown ? linked?.id : s?.agent.id;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
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
              _Avatar(url: s?.pictureUrl, instagram: page.isInstagram),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(page.pageName, style: AppText.displayS, maxLines: 1, overflow: TextOverflow.ellipsis),
                    SizedBox(height: AppSpacing.xxs),
                    Text(meta, style: AppText.labelMeta, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (aiOn != null) ...[
                SizedBox(width: AppSpacing.sm),
                _AiStatus(on: aiOn),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          const _Rule(),
          SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Stat(
                  value: count(s?.conversations),
                  label: l10n.pageCardStatConvos,
                  subtle: l10n.pageCardStatActive(s?.activeConversations ?? 0),
                ),
              ),
              Expanded(
                child: _Stat(
                  value: count(s?.messages7d),
                  label: l10n.pageCardStatMsgs7d,
                  subtle: l10n.pageCardStatIn(s?.incoming7d ?? 0),
                ),
              ),
              Expanded(
                child: _Stat(
                  value: count(s?.unread),
                  label: l10n.pageCardStatUnread,
                  subtle: (s?.unread ?? 0) > 0 ? l10n.pageCardStatNeedsReply : null,
                ),
              ),
              Expanded(
                child: _Stat(
                  value: count(s?.products),
                  label: l10n.pageCardStatStock,
                  subtle: l10n.pageCardStatProducts,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          const _Rule(),
          SizedBox(height: AppSpacing.md),
          _AgentStrip(
            ready: ready,
            personality: personality,
            onGenerate: enabled ? onGenerate : null,
            onEdit: agentId == null ? null : () => onEditAgent(agentId),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _CardAction(icon: AppIcons.chat, label: l10n.pageCardActionInbox, onTap: onInbox)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: _CardAction(icon: AppIcons.box, label: l10n.pageCardActionStock, onTap: onStock)),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _CardAction(icon: AppIcons.settings, label: l10n.pageCardActionConfigure, onTap: onConfigure),
              ),
              SizedBox(width: AppSpacing.sm),
              _DisconnectButton(
                label: l10n.pageCardActionDisconnect,
                busy: busy,
                onTap: enabled ? onDisconnect : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Il y a 2 h" — the web's `formatRelative`, in words.
String _ago(DateTime? at, L10n l10n, String localeTag) {
  if (at == null) return l10n.pageCardNoActivity;
  final elapsed = DateTime.now().difference(at.toLocal());
  if (elapsed.inMinutes < 1) return l10n.pageCardNow;
  if (elapsed.inMinutes < 60) return l10n.pageCardMinutesAgo(elapsed.inMinutes);
  if (elapsed.inHours < 24) return l10n.pageCardHoursAgo(elapsed.inHours);
  if (elapsed.inDays < 30) return l10n.pageCardDaysAgo(elapsed.inDays);
  return DateFormat.yMMMd(localeTag).format(at.toLocal());
}

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) => Container(height: AppStroke.hairline, color: AppColors.rule);
}

/// The page's picture, grey like the web's, or its network's mark.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.instagram});

  final String? url;
  final bool instagram;

  static const _greyscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final size = 10.26.w; // 40
    final mark = AppIcon(
      instagram ? AppIcons.instagram : AppIcons.facebook,
      size: 5.13.w,
      color: AppColors.textMuted,
      filled: true,
    );
    final picture = url;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.ink,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: picture == null
          ? mark
          : ColorFiltered(
              colorFilter: _greyscale,
              child: Image.network(
                picture,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => mark,
              ),
            ),
    );
  }
}

/// `● IA ACTIVE` in `signal/live`, or a hollow dot and `IA DÉSACTIVÉE`.
class _AiStatus extends StatelessWidget {
  const _AiStatus({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? AppColors.live : null,
            border: on ? null : Border.all(color: AppColors.textMuted, width: AppStroke.hairline),
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          (on ? l10n.pageCardAiOn : l10n.pageCardAiOff).toUpperCase(),
          style: AppText.labelMeta.copyWith(color: on ? AppColors.live : AppColors.textMuted),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.subtle});

  final String value;
  final String label;
  final String? subtle;

  @override
  Widget build(BuildContext context) {
    final note = subtle;
    return Padding(
      padding: EdgeInsetsDirectional.only(end: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppText.numeralM, maxLines: 1),
          SizedBox(height: AppSpacing.xxs),
          Text(label.toUpperCase(), style: AppText.labelMicro, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (note != null)
            Text(note.toUpperCase(), style: AppText.labelMicro, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// "Agent IA prêt" with Régénérer, or "Pas encore d'agent personnalisé" with
/// Générer — and, when an agent is linked, the way into its settings.
class _AgentStrip extends StatelessWidget {
  const _AgentStrip({
    required this.ready,
    required this.personality,
    required this.onGenerate,
    required this.onEdit,
  });

  /// An active agent with instructions answers on the page — the web's
  /// "Agent IA prêt".
  final bool ready;
  final AgentPersonality? personality;
  final VoidCallback? onGenerate;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final personality = this.personality;
    final heading = ready && personality != null
        ? '${l10n.pageCardAgentReady} · ${agentPersonalityLabel(personality, l10n)}'
        : ready
            ? l10n.pageCardAgentReady
            : l10n.pageCardAgentNotReady;
    final edit = onEdit;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppIcon(AppIcons.sparkles, size: 5.13.w, color: ready ? AppColors.live : AppColors.textSecondary),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(heading, style: AppText.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      (ready ? l10n.pageCardAgentTailored : l10n.pageCardAgentNotReadyHint).toUpperCase(),
                      style: AppText.labelMicro,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              FilledButton(
                style: compactButton,
                onPressed: onGenerate,
                child: Text(ready ? l10n.pageCardAgentRegenerate : l10n.pageCardAgentGenerate),
              ),
            ],
          ),
          if (edit != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                style: compactButton,
                onPressed: edit,
                child: Text(l10n.agentsDetailsEditAgent),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({required this.icon, required this.label, required this.onTap});

  final List<String> icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 8.72.w, // 34
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(icon, size: 3.59.w, color: AppColors.textSecondary), // 14
              SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The web's `×` at the end of the action row.
class _DisconnectButton extends StatelessWidget {
  const _DisconnectButton({required this.label, required this.busy, required this.onTap});

  final String label;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 8.72.w,
          height: 8.72.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: busy
              ? SizedBox.square(
                  dimension: 3.59.w,
                  child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
                )
              : AppIcon(AppIcons.close, size: 3.59.w, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
