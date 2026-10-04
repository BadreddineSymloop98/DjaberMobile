import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/connected_page.dart';
import '../../../data/models/conversation.dart';
import '../../../data/repositories/inbox_repository.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/inbox_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import '../agents/agent_widgets.dart' show compactButton;
import 'inbox_widgets.dart';

/// `10 — Boîte de réception` — the Boîte tab, the web's `/dashboard/inbox`.
///
/// **The two-column messenger became two screens.** This one is the web's
/// left column — its page switcher as the title, the Sync button, the search,
/// the four tabs with their counts, the list — and a conversation opens
/// `10b` on top of it.
///
/// | Web | Here |
/// |---|---|
/// | Page dropdown | The page name is the title; ⌄ opens `10a`, a sheet |
/// | Sync button | A refresh square in the header, plus pull to refresh |
/// | "No pages connected" card | `10 · aucune page`, the same copy |
///
/// `IA EN PAUSE` on a row is not on the web: see [ConversationRow].
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key, this.initialPageId});

  /// `/inbox?pageId=` — the page card's *Boîte* opens its own page.
  final String? initialPageId;

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late final InboxViewModel _model = InboxViewModel(
    pages: context.read<PageRepository>(),
    inbox: context.read<InboxRepository>(),
    initialPageId: widget.initialPageId,
  );

  final _search = TextEditingController();

  /// New messages arrive while the app is away — push is not wired (brief §7)
  /// — so coming back reads the list again.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () {
      if (!_model.isFirstLoad) _model.refreshConversations();
    },
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
  }

  @override
  void didUpdateWidget(InboxScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final requested = widget.initialPageId;
    if (requested != null && requested != oldWidget.initialPageId) _model.selectPage(requested);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _search.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _sync() async {
    final l10n = L10n.of(context);
    final result = await _model.sync();
    if (!mounted || result == null) return;
    final error = result.errorOrNull;
    if (error != null) {
      AppToast.info(context, apiErrorMessage(error, l10n));
      return;
    }
    final synced = result.valueOrNull!;
    AppToast.success(
      context,
      synced.foundAnything ? l10n.inboxSyncedCount(synced.newMessages) : l10n.inboxUpToDate,
    );
  }

  /// Pushed, so back returns here; the list is re-read on the way back, since
  /// a reply or a status change moved the conversation.
  Future<void> _open(Conversation conversation) async {
    await GoRouter.of(context).push(Routes.conversationOf(conversation.id));
    if (mounted) await _model.refreshConversations();
  }

  Future<void> _switchPage() async {
    final router = GoRouter.of(context);
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      barrierColor: AppColors.scrim,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      builder: (_) => _PageSwitcherSheet(
        pages: _model.pages,
        selectedId: _model.selectedPage?.id,
        onConnectAnother: () {
          Navigator.of(context).pop();
          router.push(Routes.pages);
        },
      ),
    );
    if (!mounted || chosen == null) return;
    _search.clear();
    _model.setQuery('');
    await _model.selectPage(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.gutterTight, 0.47.h, AppSpacing.gutterTight, AppSpacing.lg),
                child: Row(
                  children: [
                    AppBackButton(semanticLabel: l10n.commonBack),
                    const Spacer(),
                    if (_model.hasPages)
                      _SyncButton(syncing: _model.isSyncing, onTap: _sync, label: l10n.inboxSync),
                  ],
                ),
              ),
              Expanded(child: _body(context, l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, L10n l10n) {
    if (_model.isFirstLoad) return const _Spinner();

    if (!_model.hasPages) {
      return RefreshIndicator(
        onRefresh: _model.load,
        color: AppColors.textPrimary,
        backgroundColor: AppColors.surface,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            if (_model.error != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ApiErrorLine(error: _model.error),
                    OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
                  ],
                ),
              )
            else
              _NoPages(onConnect: () => GoRouter.of(context).push(Routes.pages)),
          ],
        ),
      );
    }

    final page = _model.selectedPage!;
    final tag = Localizations.localeOf(context).toLanguageTag();

    return RefreshIndicator(
      onRefresh: _model.load,
      color: AppColors.textPrimary,
      backgroundColor: AppColors.surface,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          _Title(
            page: page,
            canSwitch: _model.pages.length > 1,
            lastSyncedAt: _model.lastSyncedAt,
            onSwitch: _switchPage,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
            child: TextField(
              controller: _search,
              onChanged: _model.setQuery,
              textInputAction: TextInputAction.search,
              style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.inboxSearchHint,
                prefixIcon: Padding(
                  padding: EdgeInsetsDirectional.only(start: AppSpacing.md, end: AppSpacing.sm),
                  child: AppIcon(AppIcons.search, size: 4.1.w, color: AppColors.textMuted),
                ),
                prefixIconConstraints: const BoxConstraints(),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          FilterChipRow(
            children: [
              for (final filter in InboxFilter.values)
                AppFilterChip(
                  label: _chipLabel(filter, l10n),
                  selected: _model.filter == filter,
                  onTap: () => _model.setFilter(filter),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          ..._list(l10n, tag),
        ],
      ),
    );
  }

  String _chipLabel(InboxFilter filter, L10n l10n) {
    final label = switch (filter) {
      InboxFilter.all => l10n.inboxTabAll,
      // Home's section name, so the queue reads the same in both places.
      InboxFilter.needsHuman => l10n.homeQueue,
      InboxFilter.active => l10n.inboxTabActive,
      InboxFilter.resolved => l10n.inboxTabResolved,
      InboxFilter.archived => l10n.inboxTabArchived,
    };
    final count = _model.count(filter);
    return count > 0 ? '$label  $count' : label;
  }

  List<Widget> _list(L10n l10n, String tag) {
    if (_model.isSwitching) return const [_Spinner(padded: true)];

    final error = _model.error;
    final rows = _model.visible;
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight);

    return [
      // A failed refresh keeps the list — and says it may be out of date.
      if (error != null)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Column(
            children: [
              ApiErrorLine(error: error),
              if (!_model.hasConversations)
                OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
              SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      if (!_model.hasConversations && error == null)
        Padding(
          padding: gutter,
          child: _EmptyBox(
            message: _model.query.isNotEmpty ? l10n.inboxNoMatches : l10n.inboxNoConversations,
            action: _model.query.isNotEmpty
                ? null
                : FilledButton(
                    style: compactButton,
                    onPressed: _model.isSyncing ? null : _sync,
                    child: Text(_model.isSyncing ? l10n.inboxSyncing : l10n.inboxPullFromFacebook),
                  ),
          ),
        )
      else if (_model.hasConversations && rows.isEmpty)
        Padding(
          padding: gutter,
          child: _EmptyBox(message: _model.query.isNotEmpty ? l10n.inboxNoMatches : l10n.inboxNothingHere),
        )
      else if (rows.isNotEmpty)
        Padding(
          padding: gutter,
          child: ListBox(
            children: [
              for (final conversation in rows)
                ConversationRow(
                  conversation: conversation,
                  time: inboxTime(conversation.lastActivity, l10n, tag),
                  onTap: () => _open(conversation),
                ),
            ],
          ),
        ),
    ];
  }
}

/// The eyebrow, the page name as the title (the web's switcher), and
/// "Messenger · synchronisé il y a 2 min".
class _Title extends StatelessWidget {
  const _Title({required this.page, required this.canSwitch, required this.lastSyncedAt, required this.onSwitch});

  final ConnectedPage page;
  final bool canSwitch;
  final DateTime? lastSyncedAt;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final synced = lastSyncedAt;
    final subtitle = [
      inboxPlatformLabel(page.platform, l10n),
      if (synced != null) l10n.inboxSynced(inboxAgo(synced, l10n)),
    ].join(' · ');

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.inboxTitle.toUpperCase(), style: AppText.labelMeta),
          SizedBox(height: AppSpacing.sm),
          Semantics(
            button: canSwitch,
            label: canSwitch ? l10n.inboxSwitchPage : null,
            child: GestureDetector(
              onTap: canSwitch ? onSwitch : null,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      page.pageName,
                      style: AppText.displayM,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (canSwitch) ...[
                    SizedBox(width: AppSpacing.sm),
                    AppIcon(AppIcons.chevronDown, size: 5.13.w, color: AppColors.textSecondary),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(subtitle, style: AppText.bodyS.copyWith(height: 1.32)),
        ],
      ),
    );
  }
}

/// The Sync button — the header's refresh square, a spinner while it runs.
class _SyncButton extends StatelessWidget {
  const _SyncButton({required this.syncing, required this.onTap, required this.label});

  final bool syncing;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (!syncing) {
      return IconSquareButton(icon: AppIcons.refresh, onTap: onTap, semanticLabel: label);
    }
    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: const Color(0x1FFFFFFF), width: AppStroke.hairline), // line/edge
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: SizedBox.square(
          dimension: 6.15.w, // 24
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xs),
            child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// `10 · aucune page` — the web's empty inbox, word for word.
class _NoPages extends StatelessWidget {
  const _NoPages({required this.onConnect});

  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.inboxTitle, style: AppText.displayM),
              SizedBox(height: AppSpacing.sm),
              Text(l10n.inboxSubtitle, style: AppText.bodyS.copyWith(height: 1.32)),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutterTight),
          child: _EmptyBox(
            icon: true,
            title: l10n.inboxNoPagesTitle,
            message: l10n.inboxNoPagesBody,
            action: FilledButton(style: compactButton, onPressed: onConnect, child: Text(l10n.inboxConnectPage)),
          ),
        ),
      ],
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.message, this.title, this.action, this.icon = false});

  final String message;
  final String? title;
  final Widget? action;
  final bool icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 7.18.w), // 28
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          if (icon) ...[
            Container(
              width: 12.31.w, // 48
              height: 12.31.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: AppIcon(AppIcons.chat, size: 6.15.w, color: AppColors.textMuted),
            ),
            SizedBox(height: AppSpacing.lg),
          ],
          if (title != null) ...[
            Text(title!, style: AppText.title, textAlign: TextAlign.center),
            SizedBox(height: AppSpacing.xs),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.bodyS.copyWith(height: 1.4, color: AppColors.textMuted),
          ),
          if (action != null) ...[
            SizedBox(height: AppSpacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner({this.padded = false});

  final bool padded;

  @override
  Widget build(BuildContext context) {
    const spinner = SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
    );
    return padded
        ? Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.huge), child: const Center(child: spinner))
        : const Center(child: spinner);
  }
}

/// `10a — Changer de page` — the web's page dropdown as a bottom sheet. Pops
/// with the chosen page's id.
class _PageSwitcherSheet extends StatelessWidget {
  const _PageSwitcherSheet({required this.pages, required this.selectedId, required this.onConnectAnother});

  final List<ConnectedPage> pages;
  final String? selectedId;
  final VoidCallback onConnectAnother;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.gutterTight, AppSpacing.sm, AppSpacing.gutterTight, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 9.23.w, // 36
                height: 1.03.w, // 4
                decoration: BoxDecoration(
                  color: AppColors.ruleStrong,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(AppSpacing.xs, AppSpacing.lg, 0, AppSpacing.sm),
              child: Text(l10n.inboxSwitchPage.toUpperCase(), style: AppText.labelSection),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final page in pages)
                      _PageOption(
                        page: page,
                        selected: page.id == selectedId,
                        onTap: () => Navigator.of(context).pop(page.id),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: const RowDivider(),
            ),
            Semantics(
              button: true,
              child: GestureDetector(
                onTap: onConnectAnother,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      AppIcon(AppIcons.plus, size: 4.1.w, color: AppColors.textSecondary),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.inboxConnectAnother,
                          style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageOption extends StatelessWidget {
  const _PageOption({required this.page, required this.selected, required this.onTap});

  final ConnectedPage page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2.56.w), // 12 · 10
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceHigh : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              Container(
                width: 10.26.w, // 40
                height: 10.26.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: AppIcon(
                  page.isInstagram ? AppIcons.instagram : AppIcons.facebook,
                  size: 5.13.w,
                  color: AppColors.textSecondary,
                  filled: true,
                ),
              ),
              SizedBox(width: 2.56.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page.pageName,
                      style: AppText.title.copyWith(
                        color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      (page.isInstagram ? l10n.platformInstagram : l10n.platformFacebook).toUpperCase(),
                      style: AppText.labelMeta,
                    ),
                  ],
                ),
              ),
              if (selected) ...[
                SizedBox(width: AppSpacing.sm),
                Container(
                  width: 1.54.w, // 6
                  height: 1.54.w,
                  decoration: const BoxDecoration(color: AppColors.textPrimary, shape: BoxShape.circle),
                ),
                SizedBox(width: 1.54.w),
                Text(l10n.commonActive.toUpperCase(), style: AppText.labelMeta.copyWith(color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
