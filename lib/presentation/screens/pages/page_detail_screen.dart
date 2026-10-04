import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/utils/money.dart';
import '../../../data/models/connected_page.dart';
import '../../../data/models/page_detail.dart';
import '../../../data/repositories/agent_repository.dart';
import '../../../data/repositories/inbox_repository.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/inbox_view_model.dart';
import '../../viewmodels/page_detail_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/date_picker_sheet.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../../widgets/list_widgets.dart';
import '../agents/agent_widgets.dart';
import '../inbox/inbox_widgets.dart';
import '../orders/order_status_pill.dart';
import '../sales/sale_widgets.dart';

/// `Page overview` (Figma `684:19313`) and its sibling sections — `Page
/// messages` (`685:19535`), `Page AI settings` (`685:19717`, `· aucun agent`
/// `685:19914`), `Page message history` (`687:19572`) — the web's
/// `/dashboard/page/[pageId]`, one screen with four tabs.
///
/// Opened from a page card's *Configurer*. Each section loads the first time
/// it is shown and again when the merchant comes back from a screen it opened
/// (a conversation, an agent, the analysis, the products).
class PageDetailScreen extends StatefulWidget {
  const PageDetailScreen({
    super.key,
    required this.pageId,
    this.initial,
    this.section = PageSection.overview,
  });

  final String pageId;

  /// The card's page, so the header draws at once.
  final ConnectedPage? initial;

  final PageSection section;

  @override
  State<PageDetailScreen> createState() => _PageDetailScreenState();
}

class _PageDetailScreenState extends State<PageDetailScreen> {
  late final _header = PageHeaderViewModel(
    pages: context.read<PageRepository>(),
    pageId: widget.pageId,
    initial: widget.initial,
  );
  late final _overview = PageOverviewViewModel(
    pages: context.read<PageRepository>(),
    pageId: widget.pageId,
  );
  late final _messages = PageMessagesViewModel(
    inbox: context.read<InboxRepository>(),
    pageId: widget.pageId,
  );
  late final _ai = PageAiViewModel(agents: context.read<AgentRepository>(), pageId: widget.pageId);
  late final _history = PageHistoryViewModel(
    pages: context.read<PageRepository>(),
    pageId: widget.pageId,
  );

  late PageSection _section = widget.section;
  final Set<PageSection> _opened = {};

  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _search.addListener(() => _messages.setQuery(_search.text));
    _scroll.addListener(() {
      if (_section == PageSection.history && _scroll.position.extentAfter < 600) {
        _history.loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _header.load();
      _open(_section);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    _scroll.dispose();
    for (final model in [_header, _overview, _messages, _ai, _history]) {
      model.dispose();
    }
    super.dispose();
  }

  void _open(PageSection section) {
    setState(() => _section = section);
    if (_opened.add(section)) unawaited(_reload(section));
  }

  Future<void> _reload(PageSection section) => switch (section) {
    PageSection.overview => _overview.load(),
    PageSection.messages => _messages.load(),
    PageSection.aiSettings => _ai.load(),
    PageSection.history => _history.load(),
  };

  /// Pushes [route] and reads the section again on the way back — whatever
  /// was done there shows here at once.
  Future<void> _push(String route, {Object? extra}) async {
    await GoRouter.of(context).push(route, extra: extra);
    if (!mounted) return;
    unawaited(_reload(_section));
    // The overview counts products; a new import or agent change moves it.
    if (_section != PageSection.overview && _opened.contains(PageSection.overview)) {
      unawaited(_overview.load());
    }
  }

  Future<void> _refresh() async {
    if (_section == PageSection.messages) {
      final l10n = L10n.of(context);
      final error = await _messages.sync();
      if (error != null && mounted) AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    await _reload(_section);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([_header, _overview, _messages, _ai, _history]),
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.textPrimary,
            backgroundColor: AppColors.surface,
            child: ListView(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 0.47.h, bottom: AppSpacing.xxl),
              children: _content(l10n),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(L10n l10n) {
    final page = _header.page;
    final back = Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.lg),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: AppBackButton(semanticLabel: l10n.commonBack),
      ),
    );
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight);

    if (page == null) {
      return [
        back,
        Padding(
          padding: gutter,
          child: _header.isLoading || !_header.isGone && _header.error == null
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
                  child: const SaleSpinner(),
                )
              : _header.isGone
              ? EmptyBox(icon: AppIcons.alert, title: l10n.pageGoneTitle, body: l10n.pageGoneBody)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ApiErrorLine(error: _header.error),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: OutlinedButton(onPressed: _header.load, child: Text(l10n.commonRetry)),
                    ),
                  ],
                ),
        ),
      ];
    }

    return [
      back,
      _PageHeader(page: page, onOpenStock: () => _push(Routes.products)),
      SizedBox(height: AppSpacing.xl),
      SizedBox(
        height: 9.5.w,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: gutter,
          children: [
            for (final (section, label) in [
              (PageSection.overview, l10n.pageTabOverview),
              (PageSection.messages, l10n.pageTabMessages),
              (PageSection.aiSettings, l10n.pageTabAi),
              (PageSection.history, l10n.pageTabHistory),
            ])
              Padding(
                padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
                child: AppFilterChip(
                  label: label,
                  selected: _section == section,
                  onTap: () => _open(section),
                ),
              ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.xl),
      Padding(
        padding: gutter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: switch (_section) {
            PageSection.overview => _overviewSection(l10n, page),
            PageSection.messages => _messagesSection(l10n),
            PageSection.aiSettings => _aiSection(l10n),
            PageSection.history => _historySection(l10n, page),
          },
        ),
      ),
    ];
  }

  // ---- Aperçu ----

  List<Widget> _overviewSection(L10n l10n, ConnectedPage page) {
    final tag = Localizations.localeOf(context).toLanguageTag();
    final model = _overview;
    final insights = model.insights;
    final updated = model.updatedAt;

    if (model.isFirstLoad) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
          child: const SaleSpinner(),
        ),
      ];
    }

    String figure(int? v) => v == null ? '—' : Money.grouped(v, tag);

    return [
      _SectionTitle(
        title: l10n.pageOverviewTitle,
        meta: updated == null ? null : l10n.pageUpdatedAt(saleTime(updated)),
        action: ToolChip(
          icon: AppIcons.refresh,
          label: l10n.pageRefresh,
          active: false,
          onTap: model.isLoading ? () {} : model.load,
        ),
      ),
      SizedBox(height: AppSpacing.lg),
      if (model.summary == null && model.error != null) ...[
        ApiErrorLine(error: model.error),
        SizedBox(height: AppSpacing.md),
      ],
      if (!model.insightsUnavailable && insights != null) ...[
        KpiPair(
          KpiTile(
            label: l10n.pageStatFollowers,
            value: figure(insights.followers),
            icon: AppIcons.users,
            iconColor: AppColors.accentMoney,
          ),
          KpiTile(
            label: l10n.pageStatImpressions,
            value: figure(insights.impressions),
            icon: AppIcons.chart,
            iconColor: AppColors.accentMoney,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        KpiPair(
          KpiTile(
            label: l10n.pageStatEngaged,
            value: figure(insights.engagedUsers),
            icon: AppIcons.bolt,
            iconColor: AppColors.accentMoney,
          ),
          KpiTile(
            label: l10n.pageStatPostEngagements,
            value: figure(insights.postEngagements),
            icon: AppIcons.chat,
            iconColor: AppColors.accentStarred,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
      ],
      SaleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _IconSquare(icon: AppIcons.search),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.pageAnalyzeCardTitle, style: AppText.title),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.pageAnalyzeCardBody,
                        style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => _push(Routes.pageAnalyzeOf(page.id), extra: page),
              child: Text(l10n.pageAnalyzeCardCta),
            ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.lg),
      SaleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _IconSquare(icon: AppIcons.box),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.pageStockTitle, style: AppText.title),
                      SizedBox(height: AppSpacing.xs),
                      Text(l10n.pageStockSubtitle.toUpperCase(), style: AppText.labelMicro),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            _LinkCard(
              title: l10n.pageStockMain,
              body: l10n.pageStockMainBody,
              trailing: model.summary == null
                  ? null
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Money.grouped(model.summary!.products, tag), style: AppText.numeralM),
                        SizedBox(width: AppSpacing.xs),
                        Text(l10n.pageStockProductsLabel.toUpperCase(), style: AppText.labelMicro),
                      ],
                    ),
              onTap: () => _push(Routes.products),
            ),
            SizedBox(height: AppSpacing.sm),
            _LinkCard(
              title: l10n.pageStockPage,
              body: l10n.pageStockPageBody,
              trailing: Text(l10n.pageStockPageCta, style: AppText.bodyS),
              onTap: () => _push(Routes.pageProductsOf(page.id), extra: page),
            ),
          ],
        ),
      ),
      if (model.insightsUnavailable) ...[
        SizedBox(height: AppSpacing.lg),
        _Notice(title: l10n.pageInsightsUnavailableTitle, body: l10n.pageInsightsUnavailableBody),
      ],
    ];
  }

  // ---- Messages ----

  List<Widget> _messagesSection(L10n l10n) {
    final tag = Localizations.localeOf(context).toLanguageTag();
    final model = _messages;
    final rows = model.visible;

    return [
      AppTextField(
        label: l10n.productsSearchLabel,
        controller: _search,
        focusNode: _searchFocus,
        placeholder: l10n.pageMessagesSearch,
        textInputAction: TextInputAction.search,
        inputFormatters: [LengthLimitingTextInputFormatter(100)],
        onSubmitted: (_) => _searchFocus.unfocus(),
      ),
      SizedBox(height: AppSpacing.md),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final filter in PageMessagesViewModel.filters)
            AppFilterChip(
              label: '${_filterLabel(filter, l10n)}  ${model.count(filter)}',
              selected: model.filter == filter,
              onTap: () => model.setFilter(filter),
            ),
        ],
      ),
      SizedBox(height: AppSpacing.lg),
      if (model.isFirstLoad || model.isSyncing && rows.isEmpty)
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
          child: const SaleSpinner(),
        )
      else if (rows.isEmpty && model.error != null) ...[
        ApiErrorLine(error: model.error),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(onPressed: model.load, child: Text(l10n.commonRetry)),
        ),
      ] else if (rows.isEmpty)
        EmptyBox(
          icon: AppIcons.chat,
          title: l10n.pageMessagesEmptyTitle,
          body: model.isNarrowed ? l10n.pageMessagesNoMatch : l10n.pageMessagesEmptyBody,
        )
      else
        _ListCard(
          children: [
            for (final c in rows)
              ConversationRow(
                conversation: c,
                time: inboxTime(c.lastActivity, l10n, tag),
                onTap: () => _push(Routes.conversationOf(c.id)),
              ),
          ],
        ),
    ];
  }

  String _filterLabel(InboxFilter filter, L10n l10n) => switch (filter) {
    InboxFilter.all => l10n.inboxTabAll,
    InboxFilter.active => l10n.inboxTabActive,
    InboxFilter.resolved => l10n.inboxTabResolved,
    InboxFilter.archived => l10n.inboxTabArchived,
    InboxFilter.needsHuman => l10n.homeQueue,
  };

  // ---- Paramètres IA ----

  List<Widget> _aiSection(L10n l10n) {
    final model = _ai;
    final agent = model.agent;
    final details = model.details;

    final title = _SectionTitle(title: l10n.pageTabAi, meta: l10n.pageAiSubtitle);

    if (model.isFirstLoad) {
      return [
        title,
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
          child: const SaleSpinner(),
        ),
      ];
    }

    if (agent == null && model.error != null) {
      return [
        title,
        SizedBox(height: AppSpacing.lg),
        ApiErrorLine(error: model.error),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(onPressed: model.load, child: Text(l10n.commonRetry)),
        ),
      ];
    }

    if (agent == null) {
      return [
        title,
        SizedBox(height: AppSpacing.lg),
        SaleCard(
          child: Column(
            children: [
              SizedBox(height: AppSpacing.md),
              const _IconSquare(icon: AppIcons.alert),
              SizedBox(height: AppSpacing.md),
              Text(l10n.pageAiNoAgentTitle, style: AppText.title, textAlign: TextAlign.center),
              SizedBox(height: AppSpacing.xs),
              Text(
                l10n.pageAiNoAgentBody,
                style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.4),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _push(Routes.agents),
                  child: Text(l10n.pageAiGoToAgents),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    final instructions = details?.customInstructions.trim() ?? '';
    final products = details == null
        ? '—'
        : details.sellAllProducts
        ? l10n.pageAiProductsAll
        : l10n.pageAiProductsSome(details.productIds.length);

    return [
      title,
      SizedBox(height: AppSpacing.lg),
      SaleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _IconSquare(icon: AppIcons.bot),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(agent.name, style: AppText.title),
                      SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: 1.54.w,
                        runSpacing: 1.54.w,
                        children: [
                          _Tag(label: agentPersonalityLabel(agent.personality, l10n)),
                          OrderStatusPill(
                            label: agent.isActive ? l10n.pageAgentActive : l10n.pageAgentInactive,
                            tone: agent.isActive ? PillTone.settled : PillTone.moving,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                ToolChip(
                  icon: AppIcons.edit,
                  label: l10n.saleEdit,
                  active: false,
                  onTap: () => _push(Routes.agentOf(agent.id)),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: l10n.pageAiModel,
                    value: details?.aiModel ?? agent.aiModel ?? '—',
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _InfoTile(
                    label: l10n.pageAiTemperature,
                    value: details == null ? '—' : details.temperature.toStringAsFixed(1),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: l10n.pageAiMaxTokens,
                    value: details == null ? '—' : '${details.maxTokens}',
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _InfoTile(label: l10n.pageAiProducts, value: products),
                ),
              ],
            ),
            if (instructions.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm),
              _InfoTile(label: l10n.pageAiInstructions, value: instructions, multiline: true),
            ],
            SizedBox(height: AppSpacing.md),
            const Divider(
              height: AppStroke.hairline,
              thickness: AppStroke.hairline,
              color: AppColors.rule,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              [
                l10n.pageAiLinkedPages(agent.connectedPageCount),
                if (model.conversations case final count?) l10n.pageAiConversations(count),
              ].join('  ·  ').toUpperCase(),
              style: AppText.labelMeta,
            ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.lg),
      _Notice(body: l10n.pageAiNote),
    ];
  }

  // ---- Historique ----

  List<Widget> _historySection(L10n l10n, ConnectedPage page) {
    final tag = Localizations.localeOf(context).toLanguageTag();
    final model = _history;
    final rows = model.messages;

    Future<void> pick({required bool from}) async {
      final picked = await showDatePickerSheet(
        context,
        title: from ? l10n.pageHistoryFrom : l10n.pageHistoryTo,
        initial: from ? model.from : model.to,
      );
      if (picked == null) return;
      from ? model.setFrom(picked) : model.setTo(picked);
    }

    return [
      _SectionTitle(
        title: l10n.pageHistoryTitle,
        meta: model.isFirstLoad
            ? l10n.pageHistoryLog
            : '${l10n.pageHistoryLog}  ·  ${l10n.pageHistoryMessages(model.total)}',
      ),
      SizedBox(height: AppSpacing.lg),
      SaleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pageHistoryDirection.toUpperCase(), style: AppText.labelMeta),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final (direction, label) in <(MessageDirection?, String)>[
                  (null, l10n.inboxTabAll),
                  (MessageDirection.incoming, l10n.pageHistoryIn),
                  (MessageDirection.outgoing, l10n.pageHistoryOut),
                ])
                  AppFilterChip(
                    label: label,
                    selected: model.direction == direction,
                    onTap: () => model.setDirection(direction),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ToolChip(
                  icon: AppIcons.calendar,
                  label: model.from == null
                      ? l10n.pageHistoryFrom
                      : formatPickedDay(model.from!, tag),
                  active: model.from != null,
                  onTap: () => pick(from: true),
                  onClear: model.from == null ? null : () => model.setFrom(null),
                  clearLabel: l10n.dateClear,
                ),
                ToolChip(
                  icon: AppIcons.calendar,
                  label: model.to == null ? l10n.pageHistoryTo : formatPickedDay(model.to!, tag),
                  active: model.to != null,
                  onTap: () => pick(from: false),
                  onClear: model.to == null ? null : () => model.setTo(null),
                  clearLabel: l10n.dateClear,
                ),
              ],
            ),
          ],
        ),
      ),
      SizedBox(height: AppSpacing.lg),
      if (model.isFirstLoad)
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
          child: const SaleSpinner(),
        )
      else if (rows.isEmpty && model.error != null) ...[
        ApiErrorLine(error: model.error),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(onPressed: model.load, child: Text(l10n.commonRetry)),
        ),
      ] else if (rows.isEmpty)
        EmptyBox(
          icon: AppIcons.history,
          title: l10n.pageHistoryEmptyTitle,
          body: model.isNarrowed ? l10n.pageHistoryNoMatch : l10n.pageHistoryEmptyBody,
        )
      else ...[
        _ListCard(
          children: [
            for (final m in rows) _HistoryRow(message: m, pageName: page.pageName, localeTag: tag),
          ],
        ),
        if (model.isLoadingMore)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: const SaleSpinner(),
          ),
      ],
    ];
  }
}

String pagePlatformName(PagePlatform platform) => switch (platform) {
  PagePlatform.facebook => 'Facebook',
  PagePlatform.instagram => 'Instagram',
};

/// Breadcrumb, name, platform and connection date, *Active* and *Ouvrir le
/// stock* — the frames' header, shared by every section.
class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.page, required this.onOpenStock});

  final ConnectedPage page;
  final VoidCallback onOpenStock;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final tag = Localizations.localeOf(context).toLanguageTag();
    final connected = page.createdAt;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.pageBreadcrumb(page.pageName.toUpperCase()), style: AppText.labelMeta),
          SizedBox(height: 1.54.w),
          Text(page.pageName, style: AppText.displayM),
          SizedBox(height: 1.54.w),
          Text(
            connected == null
                ? pagePlatformName(page.platform)
                : l10n.pageConnectedOn(
                    pagePlatformName(page.platform),
                    formatPickedDay(connected.toLocal(), tag),
                  ),
            style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OrderStatusPill(label: l10n.pageActive, tone: PillTone.settled),
              ToolChip(
                icon: AppIcons.box,
                label: l10n.pageOpenStock,
                active: false,
                onTap: onOpenStock,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.meta, this.action});

  final String title;
  final String? meta;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.title),
              if (meta case final meta?) ...[
                SizedBox(height: 0.77.w),
                Text(meta.toUpperCase(), style: AppText.labelMicro),
              ],
            ],
          ),
        ),
        if (action case final action?) ...[SizedBox(width: AppSpacing.sm), action],
      ],
    );
  }
}

class _IconSquare extends StatelessWidget {
  const _IconSquare({required this.icon});

  final List<String> icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.26.w,
      height: 10.26.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: AppIcon(icon, size: 4.62.w, color: AppColors.textSecondary),
    );
  }
}

/// A tappable inner card — the two stock choices.
class _LinkCard extends StatelessWidget {
  const _LinkCard({required this.title, required this.body, required this.onTap, this.trailing});

  final String title;
  final String body;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.ink,
            border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppIcon(AppIcons.box, size: 3.59.w, color: AppColors.textSecondary),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(title, style: AppText.bodyS.copyWith(color: AppColors.textPrimary)),
                  ),
                ],
              ),
              SizedBox(height: 0.77.w),
              Text(body, style: AppText.bodyS.copyWith(color: AppColors.textMuted)),
              if (trailing case final trailing?) ...[SizedBox(height: AppSpacing.sm), trailing],
            ],
          ),
        ),
      ),
    );
  }
}

/// The bordered note — insights unavailable, how to change the AI.
class _Notice extends StatelessWidget {
  const _Notice({this.title, required this.body});

  final String? title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            AppIcon(AppIcons.alert, size: AppSpacing.lg, color: AppColors.textMuted),
            SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title case final title?) ...[
                  Text(title, style: AppText.title),
                  SizedBox(height: AppSpacing.xs),
                ],
                Text(body, style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, this.multiline = false});

  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.ink,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppText.labelMicro),
          SizedBox(height: 0.77.w),
          Text(
            value,
            style: AppText.bodyS.copyWith(
              color: AppColors.textPrimary,
              height: multiline ? 1.4 : null,
            ),
            maxLines: multiline ? null : 1,
            overflow: multiline ? null : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.28.w, vertical: 0.51.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(1.03.w),
      ),
      child: Text(label.toUpperCase(), style: AppText.labelMicro),
    );
  }
}

/// A bordered list with hairlines between rows.
class _ListCard extends StatelessWidget {
  const _ListCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0)
              const Divider(
                height: AppStroke.hairline,
                thickness: AppStroke.hairline,
                color: AppColors.rule,
              ),
            child,
          ],
        ],
      ),
    );
  }
}

/// One line of the page's log: who, which way, what, when.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.message, required this.pageName, required this.localeTag});

  final PageHistoryMessage message;
  final String pageName;
  final String localeTag;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final m = message;
    // `senderName` is the conversation's customer; an outgoing message was
    // written by the page (or its AI).
    final who = m.isFromPage ? pageName : (m.senderName ?? '—');

    return Padding(
      padding: EdgeInsets.all(3.59.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  who,
                  style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              _Tag(label: m.isFromPage ? l10n.pageHistoryOutTag : l10n.pageHistoryInTag),
            ],
          ),
          SizedBox(height: 0.77.w),
          Text(
            m.text ?? l10n.pageHistoryNoText,
            style: AppText.bodyS.copyWith(
              color: m.text == null ? AppColors.textMuted : AppColors.textSecondary,
              fontStyle: m.text == null ? FontStyle.italic : null,
            ),
          ),
          SizedBox(height: 0.77.w),
          Text(
            '${formatPickedDay(m.timestamp.toLocal(), localeTag)}, ${saleTime(m.timestamp)}'
                .toUpperCase(),
            style: AppText.labelMicro,
          ),
        ],
      ),
    );
  }
}
