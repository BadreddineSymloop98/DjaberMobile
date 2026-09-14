import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/agent.dart';
import '../../../data/models/agent_insight.dart';
import '../../../data/repositories/agent_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/agent_details_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_filter_chip.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/home_widgets.dart';
import '../../widgets/icon_square_button.dart';
import 'agent_widgets.dart';

/// The agent's details: KPIs, its insights, and its custom instructions —
/// the web's `/dashboard/agents/{id}`, opened from the edit icon on the card.
class AgentDetailsScreen extends StatefulWidget {
  const AgentDetailsScreen({super.key, required this.agentId});

  final String agentId;

  @override
  State<AgentDetailsScreen> createState() => _AgentDetailsScreenState();
}

class _AgentDetailsScreenState extends State<AgentDetailsScreen> {
  late final AgentDetailsViewModel _model = AgentDetailsViewModel(
    agents: context.read<AgentRepository>(),
    agentId: widget.agentId,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _model.load());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _back() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.agents);
    }
  }

  Future<void> _save({bool overwrite = false}) async {
    final outcome = await _model.saveInstructions(overwrite: overwrite);
    if (!mounted) return;
    final l10n = L10n.of(context);
    switch (outcome) {
      case InstructionsSaveOutcome.saved:
        AppToast.success(context, l10n.agentsDetailsSaved);
      case InstructionsSaveOutcome.savedWithWebChanges:
        AppToast.success(context, l10n.agentsDetailsSavedMerged);
      case InstructionsSaveOutcome.conflict:
        break; // The notice above the field asks the merchant to choose.
      case InstructionsSaveOutcome.failed:
        final error = _model.saveError;
        if (error != null) AppToast.info(context, apiErrorMessage(error, l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([_model, _model.insights]),
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  0.47.h,
                  AppSpacing.gutter,
                  AppSpacing.lg,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppBackButton(onBack: _back, semanticLabel: l10n.commonBack),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _model.load,
                  color: AppColors.textPrimary,
                  backgroundColor: AppColors.surface,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      0,
                      AppSpacing.gutter,
                      AppSpacing.xxl,
                    ),
                    children: _body(context, l10n),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context, L10n l10n) {
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

    final agent = _model.agent;
    if (agent == null) {
      final error = _model.error;
      return [
        if (error != null) ApiErrorLine(error: error) else Text(l10n.agentsNotFound, style: AppText.title),
        SizedBox(height: AppSpacing.md),
        OutlinedButton(onPressed: _model.load, child: Text(l10n.commonRetry)),
      ];
    }

    final tag = Localizations.localeOf(context).toLanguageTag();
    final metrics = _model.metrics;
    final last = metrics?.lastActiveDate;
    final insights = _model.insights;

    return [
      _Header(agent: agent),
      SizedBox(height: AppSpacing.xl),
      if (metrics != null) ...[
        Row(
          children: [
            Expanded(
              child: KpiTile(
                label: l10n.agentsDetailsConversations,
                value: '${metrics.conversationCount}',
                icon: AppIcons.chat,
                footnote: l10n.agentsDetailsConversationsFoot(
                  metrics.messagesFromCustomers,
                  metrics.messagesFromAgent,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: KpiTile(
                label: l10n.agentsDetailsMessages,
                value: '${metrics.totalMessages}',
                icon: AppIcons.message,
                footnote: last == null
                    ? l10n.agentsDetailsNoActivity
                    : l10n.agentsDetailsLastActive(DateFormat.yMMMd(tag).format(last.toLocal())),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: KpiTile(
                label: l10n.agentsDetailsOrders,
                value: '${metrics.ordersCreated}',
                icon: AppIcons.shoppingCart,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: KpiTile(
                label: l10n.agentsInsightsTitle,
                value: '${metrics.insightsPending}',
                icon: AppIcons.alert,
                footnote: l10n.agentsDetailsResolvedFoot(metrics.insightsResolved),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl),
      ],
      Text(l10n.agentsDetailsInsights, style: AppText.title),
      SizedBox(height: AppSpacing.sm),
      FilterChipRow(
        children: [
          for (final (status, label) in [
            (InsightStatus.pending, l10n.agentsInsightPending),
            (InsightStatus.resolved, l10n.agentsInsightResolved),
            (InsightStatus.dismissed, l10n.agentsInsightDismissed),
            (null, l10n.agentsDetailsAll),
          ])
            AppFilterChip(
              label: label,
              selected: insights.status == status,
              onTap: () => insights.setFilter(status),
            ),
        ],
      ),
      SizedBox(height: AppSpacing.md),
      InsightsList(
        model: insights,
        emptyText: insights.status == InsightStatus.pending
            ? l10n.agentsInsightsEmpty
            : l10n.agentsInsightsNone,
        onChanged: _model.refreshAfterInsight,
      ),
      SizedBox(height: AppSpacing.xl),
      Row(
        children: [
          Expanded(child: Text(l10n.agentsDetailsInstructions, style: AppText.title)),
          if (!_model.isEditing)
            TextButton(
              style: compactButton,
              onPressed: _model.startEditing,
              child: Text(l10n.agentsDetailsEdit),
            ),
        ],
      ),
      SizedBox(height: AppSpacing.sm),
      if (_model.isEditing) ...[
        if (_model.conflict case final latest?) ...[
          _ConflictNotice(
            latest: latest,
            busy: _model.isSaving,
            onUseLatest: _model.useLatest,
            onKeepMine: () => _save(overwrite: true),
          ),
          SizedBox(height: AppSpacing.sm),
        ],
        TextField(
          controller: _model.instructions,
          minLines: 4,
          maxLines: 12,
          style: AppText.bodyS.copyWith(color: AppColors.textPrimary, height: 1.4),
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            FilledButton(
              style: compactButton,
              onPressed: _model.isSaving ? null : _save,
              child: Text(l10n.agentsDetailsSave),
            ),
            SizedBox(width: AppSpacing.sm),
            TextButton(
              style: compactButton,
              onPressed: _model.isSaving ? null : _model.cancelEditing,
              child: Text(l10n.commonCancel),
            ),
          ],
        ),
      ] else
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Text(
            (agent.customInstructions ?? '').trim().isEmpty
                ? l10n.agentsDetailsNoInstructions
                : agent.customInstructions!.trim(),
            style: AppText.bodyS.copyWith(
              color: (agent.customInstructions ?? '').trim().isEmpty
                  ? AppColors.textMuted
                  : AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
    ];
  }
}

/// Shown when a save found the instructions rewritten elsewhere: the current
/// version, and the two ways forward. Taking it is the primary action — it is
/// the one that cannot lose anybody's work.
class _ConflictNotice extends StatelessWidget {
  const _ConflictNotice({
    required this.latest,
    required this.busy,
    required this.onUseLatest,
    required this.onKeepMine,
  });

  final String latest;
  final bool busy;
  final VoidCallback onUseLatest;
  final VoidCallback onKeepMine;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final text = latest.trim();
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.ruleStrong, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.agentsDetailsConflictTitle, style: AppText.title),
          SizedBox(height: AppSpacing.xs),
          Text(
            l10n.agentsDetailsConflictBody,
            style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
          ),
          SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.ink,
              border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: Text(
              text.isEmpty ? l10n.agentsDetailsNoInstructions : text,
              style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              FilledButton(
                style: compactButton,
                onPressed: busy ? null : onUseLatest,
                child: Text(l10n.agentsDetailsUseLatest),
              ),
              TextButton(
                style: compactButton,
                onPressed: busy ? null : onKeepMine,
                child: Text(l10n.agentsDetailsKeepMine),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.agent});

  final Agent agent;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final active = agent.isActive;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10.26.w,
          height: 10.26.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.ink,
            border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: AppIcon(
            AppIcons.bot,
            size: 5.13.w,
            color: active ? AppColors.live : AppColors.textMuted,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(agent.name, style: AppText.displayS, maxLines: 2, overflow: TextOverflow.ellipsis),
              SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AgentTag(label: agentPersonalityLabel(agent.personality, l10n)),
                  if (agent.aiModel != null)
                    Text(
                      agent.aiModel!,
                      style: AppText.labelMicro,
                      textDirection: TextDirection.ltr,
                    ),
                  Text(
                    (active ? l10n.agentsActive : l10n.agentsInactive).toUpperCase(),
                    style: AppText.labelMeta.copyWith(
                      color: active ? AppColors.live : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
