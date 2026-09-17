import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/agent.dart';
import '../../../data/repositories/agent_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/agents_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/icon_square_button.dart';
import 'agent_widgets.dart';

/// `14 — Agents IA`.
///
/// **Every agent, then `Nouvel agent`** — as the frame draws it. Each card
/// carries what the web's does — status, personality, description, Pages /
/// Produits / Modèle and the pages it answers on — plus its four actions and
/// the one control a phone needs most: pause or resume.
///
/// How many agents a merchant may have is their plan's call, not this
/// screen's: the button is always offered, and `15` relays a refusal in the
/// backend's own words.
///
/// **No agent** is its own state, with a way to create one.
class AgentsScreen extends StatefulWidget {
  const AgentsScreen({super.key});

  @override
  State<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends State<AgentsScreen> {
  late final AgentsViewModel _model = AgentsViewModel(
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

  /// `15 — Agents · démarrer`, from the empty state's button and from
  /// `Nouvel agent` under the cards. Reloads on return, so a new agent is on
  /// the list the moment the merchant is back.
  Future<void> _create() async {
    await GoRouter.of(context).push(Routes.agentNew);
    if (mounted) await _model.load();
  }

  Future<void> _toggle(Agent agent) async {
    final updated = await _model.toggleActive(agent);
    if (!mounted) return;

    final l10n = L10n.of(context);
    final error = _model.toggleError;
    if (error != null) {
      AppToast.info(context, apiErrorMessage(error, l10n));
    } else if (updated != null) {
      AppToast.success(
        context,
        updated.isActive ? l10n.agentsResumedToast : l10n.agentsPausedToast,
      );
    }
  }

  /// The alert icon: the agent's pending issues, in a sheet.
  Future<void> _openInsights(Agent agent) async {
    await showAgentInsightsSheet(context, agent: agent);
    if (mounted) await _model.refreshMetrics();
  }

  /// The message icon: a sandbox chat with the agent.
  Future<void> _openTest(Agent agent) async {
    await GoRouter.of(context).push(Routes.agentTestOf(agent.id), extra: agent);
  }

  /// The edit icon: details, KPIs and instructions. Reloads on return, since
  /// the instructions or the pending count may have changed there.
  Future<void> _openDetails(Agent agent) async {
    await GoRouter.of(context).push(Routes.agentOf(agent.id));
    if (mounted) await _model.load();
  }

  /// The trash icon: asks, then deletes.
  Future<void> _confirmDelete(Agent agent) async {
    final l10n = L10n.of(context);
    final confirmed = await showAgentDeleteSheet(context, agentName: agent.name);
    if (confirmed != true || !mounted) return;
    final deleted = await _model.deleteAgent(agent);
    if (!mounted) return;
    final error = _model.deleteError;
    if (deleted) {
      AppToast.success(context, l10n.agentsDeletedToast);
    } else if (error != null) {
      AppToast.info(context, apiErrorMessage(error, l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ChangeNotifierProvider<AgentsViewModel>.value(
      value: _model,
      child: Consumer<AgentsViewModel>(
        builder: (context, model, _) {
          return Scaffold(
            backgroundColor: AppColors.ink,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      0.47.h, // 4
                      AppSpacing.gutter,
                      AppSpacing.lg, // 16
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AppBackButton(
                                                semanticLabel: l10n.commonBack,
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: model.load,
                      color: AppColors.textPrimary,
                      backgroundColor: AppColors.surface,
                      child: ListView(
                        // Scrollable even when short, so pull-to-refresh
                        // works on a single card or the empty state.
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.gutter,
                          0,
                          AppSpacing.gutter,
                          AppSpacing.xxl,
                        ),
                        children: [
                          Text(l10n.agentsTitle, style: AppText.displayM),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.agentsSubtitle,
                            style: AppText.bodyS.copyWith(height: 1.32),
                          ),
                          SizedBox(height: AppSpacing.xl),
                          _Content(
                            model: model,
                            onCreate: _create,
                            onToggle: _toggle,
                            actions: _CardActions(
                              onInsights: _openInsights,
                              onTest: _openTest,
                              onDetails: _openDetails,
                              onDelete: _confirmDelete,
                            ),
                          ),
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
}

class _Content extends StatelessWidget {
  const _Content({
    required this.model,
    required this.onCreate,
    required this.onToggle,
    required this.actions,
  });

  final AgentsViewModel model;
  final VoidCallback onCreate;
  final ValueChanged<Agent> onToggle;
  final _CardActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    if (model.isFirstLoad) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.huge),
        child: const Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    final agents = model.agents;
    final error = model.error;

    // A failed load with nothing to show. With cards already on screen a
    // failed refresh keeps them — stale beats blank.
    if (agents.isEmpty && error != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ApiErrorLine(error: error),
            OutlinedButton(
              onPressed: model.isBusy ? null : model.load,
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      );
    }

    if (agents.isEmpty) return _EmptyState(onCreate: onCreate);

    final busyId = model.busyAgentId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final agent in agents) ...[
          _AgentCard(
            agent: agent,
            busy: busyId == agent.id,
            // One change at a time: the other cards wait rather than
            // silently ignoring a tap.
            enabled: busyId == null,
            onToggle: onToggle,
            actions: actions,
            pendingInsights: model.pendingFor(agent.id),
          ),
          SizedBox(height: AppSpacing.md), // 12
        ],
        _NewAgentButton(onPressed: onCreate),
      ],
    );
  }
}

/// No agent: what one does, and the way to create it.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BotTile(active: false),
          SizedBox(height: AppSpacing.md), // 12
          Text(l10n.agentsEmptyTitle, style: AppText.title),
          SizedBox(height: AppSpacing.xs),
          Text(
            l10n.agentsEmptyBody,
            style: AppText.bodyS.copyWith(
              height: 1.32,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: AppSpacing.lg), // 16
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCreate,
              child: Text(l10n.agentsEmptyCta),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  const _AgentCard({
    required this.agent,
    required this.busy,
    required this.enabled,
    required this.onToggle,
    required this.actions,
    required this.pendingInsights,
  });

  final Agent agent;
  final bool busy;
  final bool enabled;
  final ValueChanged<Agent> onToggle;
  final _CardActions actions;
  final int pendingInsights;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final active = agent.isActive;
    final description = agent.description?.trim() ?? '';
    // Connected pages only: a disconnected page stays linked to its agent on
    // the backend, and counting it said the agent answered where it cannot.
    final pageCount = agent.connectedPageCount;
    final pages = agent.connectedPages;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _BotTile(active: active),
              SizedBox(width: AppSpacing.md), // 12
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent.name,
                      style: AppText.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        Flexible(
                          child: _Pill(
                            label: _personality(agent.personality, l10n)
                                .toUpperCase(),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        _StatusDot(active: active),
                        SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            (active ? l10n.agentsActive : l10n.agentsInactive)
                                .toUpperCase(),
                            style: AppText.labelMeta.copyWith(
                              color: active
                                  ? AppColors.live
                                  : AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              _ActionRow(
                agent: agent,
                actions: actions,
                pending: pendingInsights,
                enabled: enabled,
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            SizedBox(height: AppSpacing.md),
            Text(
              description,
              style: AppText.bodyS.copyWith(
                height: 1.32,
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: l10n.agentsStatPages,
                  value: '$pageCount',
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Stat(
                  label: l10n.agentsStatProducts,
                  value: agent.sellAllProducts
                      ? l10n.agentsAllProducts
                      : '${agent.productCount}',
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Stat(
                  label: l10n.agentsStatModel,
                  value: agent.aiModel ?? '—',
                  compact: true,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (pages.isEmpty)
            Text(
              l10n.agentsNoPages,
              style: AppText.bodyS.copyWith(color: AppColors.textMuted),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final page in pages) _PageChip(page: page),
              ],
            ),
          SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: enabled ? () => onToggle(agent) : null,
            child: busy
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textMuted,
                    ),
                  )
                : Text(active ? l10n.agentsPause : l10n.agentsResume),
          ),
        ],
      ),
    );
  }

  static String _personality(AgentPersonality value, L10n l10n) =>
      switch (value) {
        AgentPersonality.professional => l10n.agentToneProfessional,
        AgentPersonality.friendly => l10n.agentToneFriendly,
        AgentPersonality.casual => l10n.agentToneCasual,
        AgentPersonality.technical => l10n.agentToneTechnical,
      };
}

/// `Nouvel agent`, under the cards: the frame's outlined button, plus mark
/// and muted label.
class _NewAgentButton extends StatelessWidget {
  const _NewAgentButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(AppIcons.plus, size: 4.1.w, color: AppColors.textPrimary), // 16
          SizedBox(width: AppSpacing.sm), // 8
          Flexible(
            child: Text(
              l10n.agentsNewTitle,
              style: const TextStyle(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// The flat card surface every block on this screen sits on.
class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg), // 16
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: child,
    );
  }
}

/// The bot mark in its square — `signal/live` while the agent is answering.
class _BotTile extends StatelessWidget {
  const _BotTile({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.26.w, // 40
      height: 10.26.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.ink,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: AppIcon(
        AppIcons.bot,
        size: 5.13.w, // 20
        color: active ? AppColors.live : AppColors.textMuted,
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.live : null,
        border: active
            ? null
            : Border.all(color: AppColors.textMuted, width: AppStroke.hairline),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.compact = false});

  final String label;
  final String value;

  /// For a value that is a word, not a count — the model name.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md), // 12
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The value leads and the label sits under it, as the Agent Card
          // draws it.
          Text(
            value,
            style: AppText.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // A model name like `gpt-4o-mini` is never mirrored.
            textDirection: compact ? TextDirection.ltr : null,
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            label.toUpperCase(),
            style: AppText.labelMicro,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// An outlined mono tag — the personality, a page name.
class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Text(
        label,
        style: AppText.labelMicro.copyWith(color: AppColors.textMuted),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _PageChip extends StatelessWidget {
  const _PageChip({required this.page});

  final AgentPageLink page;

  @override
  Widget build(BuildContext context) => _Pill(label: page.name);
}

/// What the card's four icons do.
class _CardActions {
  const _CardActions({
    required this.onInsights,
    required this.onTest,
    required this.onDetails,
    required this.onDelete,
  });

  final ValueChanged<Agent> onInsights;
  final ValueChanged<Agent> onTest;
  final ValueChanged<Agent> onDetails;
  final ValueChanged<Agent> onDelete;
}

/// Pending issues · test chat · details · delete — the web card's icons, in
/// its order.
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.agent,
    required this.actions,
    required this.pending,
    required this.enabled,
  });

  final Agent agent;
  final _CardActions actions;
  final int pending;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionIcon(
          icon: AppIcons.alert,
          label: l10n.agentsActionInsights,
          onTap: enabled ? () => actions.onInsights(agent) : null,
          badge: pending,
          // Brighter when something is waiting.
          color: pending > 0 ? AppColors.textPrimary : AppColors.textSecondary,
        ),
        _ActionIcon(
          icon: AppIcons.message,
          label: l10n.agentsActionTest,
          onTap: enabled ? () => actions.onTest(agent) : null,
        ),
        _ActionIcon(
          icon: AppIcons.edit,
          label: l10n.agentsActionDetails,
          onTap: enabled ? () => actions.onDetails(agent) : null,
        ),
        _ActionIcon(
          icon: AppIcons.trash,
          label: l10n.agentsActionDelete,
          onTap: enabled ? () => actions.onDelete(agent) : null,
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
    this.color = AppColors.textSecondary,
  });

  final List<String> icon;
  final String label;
  final VoidCallback? onTap;
  final int badge;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.square(
          dimension: 7.18.w, // 28
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AppIcon(
                icon,
                size: 4.1.w, // 16
                color: onTap == null ? AppColors.textMuted : color,
              ),
              if (badge > 0)
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
                      style: AppText.labelMicro.copyWith(color: AppColors.ink),
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
