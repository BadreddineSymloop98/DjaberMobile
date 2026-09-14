import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/agent.dart';
import '../../../data/models/agent_insight.dart';
import '../../../data/repositories/agent_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/agent_insights_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';

/// The four personalities, in the merchant's language.
String agentPersonalityLabel(AgentPersonality value, L10n l10n) =>
    switch (value) {
      AgentPersonality.professional => l10n.agentToneProfessional,
      AgentPersonality.friendly => l10n.agentToneFriendly,
      AgentPersonality.casual => l10n.agentToneCasual,
      AgentPersonality.technical => l10n.agentToneTechnical,
    };

/// Buttons in a row size to their label: the theme sizes them for full-width
/// columns. Height stays the theme's control height — it also caps the height,
/// so a taller minimum would give the button impossible constraints.
final ButtonStyle compactButton = ButtonStyle(
  minimumSize: WidgetStateProperty.all(Size(0, AppSize.control)),
  maximumSize: WidgetStateProperty.all(Size(double.infinity, AppSize.control)),
  padding: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: 14),
  ),
);

/// An outlined mono tag.
class AgentTag extends StatelessWidget {
  const AgentTag({super.key, required this.label, this.color});

  final String label;
  final Color? color;

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
        label.toUpperCase(),
        style: AppText.labelMicro.copyWith(color: color ?? AppColors.textMuted),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Opens the pending-issues sheet for [agent].
Future<void> showAgentInsightsSheet(
  BuildContext context, {
  required Agent agent,
}) {
  final repository = context.read<AgentRepository>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.ink,
    barrierColor: AppColors.scrim,
    builder: (_) => _InsightsSheet(repository: repository, agent: agent),
  );
}

class _InsightsSheet extends StatefulWidget {
  const _InsightsSheet({required this.repository, required this.agent});

  final AgentRepository repository;
  final Agent agent;

  @override
  State<_InsightsSheet> createState() => _InsightsSheetState();
}

class _InsightsSheetState extends State<_InsightsSheet> {
  late final AgentInsightsViewModel _model = AgentInsightsViewModel(
    agents: widget.repository,
    agentId: widget.agent.id,
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

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Padding(
        // The instruction field must stay above the keyboard.
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ListenableBuilder(
          listenable: _model,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    AppIcon(AppIcons.alert, size: 4.1.w, color: AppColors.textSecondary),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${l10n.agentsInsightsTitle} (${_model.items.length})',
                        style: AppText.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.commonCancel,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: AppIcon(AppIcons.close, size: 5.13.w, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    0,
                    AppSpacing.gutter,
                    AppSpacing.xl,
                  ),
                  children: [
                    InsightsList(
                      model: _model,
                      emptyText: l10n.agentsInsightsEmpty,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The insights a [model] holds: loading, empty, or one card each.
class InsightsList extends StatelessWidget {
  const InsightsList({
    super.key,
    required this.model,
    required this.emptyText,
    this.onChanged,
  });

  final AgentInsightsViewModel model;
  final String emptyText;

  /// After an insight is resolved or dismissed.
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    if (model.isFirstLoad) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: const Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
          ),
        ),
      );
    }

    final error = model.error;
    if (error != null && model.items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ApiErrorLine(error: error),
          OutlinedButton(
            onPressed: model.isBusy ? null : model.load,
            child: Text(l10n.commonRetry),
          ),
        ],
      );
    }

    if (model.items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(
          emptyText,
          style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final insight in model.items) ...[
          InsightCard(insight: insight, model: model, onChanged: onChanged),
          SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

/// One flagged conversation: what the customer said, what the agent answered,
/// and — while pending — resolve (optionally teaching the agent) or dismiss.
class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.insight,
    required this.model,
    this.onChanged,
  });

  final AgentInsight insight;
  final AgentInsightsViewModel model;
  final VoidCallback? onChanged;

  Future<void> _run(BuildContext context, Future<bool> Function() action) async {
    final ok = await action();
    if (!context.mounted) return;
    if (ok) {
      onChanged?.call();
    } else if (model.actionError != null) {
      AppToast.info(context, L10n.of(context).agentsInsightFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final tag = Localizations.localeOf(context).toLanguageTag();
    final created = insight.createdAt;
    final saving = model.savingId == insight.id;
    final resolving = model.resolvingId == insight.id;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
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
              Flexible(child: AgentTag(label: _typeLabel(insight.type, l10n))),
              if (insight.platform != null) ...[
                SizedBox(width: AppSpacing.sm),
                AppIcon(
                  insight.platform == 'instagram' ? AppIcons.instagram : AppIcons.facebook,
                  size: 3.08.w,
                  color: AppColors.textMuted,
                  filled: true,
                ),
              ],
              const Spacer(),
              if (created != null)
                Text(
                  DateFormat.yMMMd(tag).format(created.toLocal()),
                  style: AppText.labelMicro,
                ),
            ],
          ),
          if ((insight.detail ?? '').isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            Text(
              insight.detail!,
              style: AppText.bodyS.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
          SizedBox(height: AppSpacing.sm),
          _Quote(label: l10n.agentsInsightCustomer, text: insight.customerMessage),
          SizedBox(height: AppSpacing.xs),
          _Quote(label: l10n.agentsInsightAgent, text: insight.aiResponse, outlined: true),
          SizedBox(height: AppSpacing.md),
          if (!insight.isPending)
            Row(
              children: [
                AgentTag(
                  label: insight.status == InsightStatus.resolved
                      ? l10n.agentsInsightResolved
                      : l10n.agentsInsightDismissed,
                  color: insight.status == InsightStatus.resolved
                      ? AppColors.textSecondary
                      : AppColors.textMuted,
                ),
                if (insight.resolvedAt != null) ...[
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    DateFormat.yMMMd(tag).format(insight.resolvedAt!.toLocal()),
                    style: AppText.labelMicro,
                  ),
                ],
              ],
            )
          else if (resolving) ...[
            TextField(
              controller: model.instructionController,
              minLines: 2,
              maxLines: 4,
              autofocus: true,
              style: AppText.bodyS.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(hintText: l10n.agentsInsightInstructionHint),
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: model.instructionController,
                  builder: (context, value, _) => FilledButton(
                    style: compactButton,
                    onPressed: saving ? null : () => _run(context, () => model.resolve(insight.id)),
                    child: Text(
                      value.text.trim().isEmpty
                          ? l10n.agentsInsightResolve
                          : l10n.agentsInsightAddAndResolve,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                TextButton(
                  style: compactButton,
                  onPressed: saving ? null : model.cancelResolving,
                  child: Text(l10n.commonCancel),
                ),
              ],
            ),
          ] else
            Row(
              children: [
                OutlinedButton(
                  style: compactButton,
                  onPressed: saving ? null : () => model.startResolving(insight.id),
                  child: Text(l10n.agentsInsightResolve),
                ),
                SizedBox(width: AppSpacing.sm),
                TextButton(
                  style: compactButton,
                  onPressed: saving ? null : () => _run(context, () => model.dismiss(insight.id)),
                  child: Text(l10n.agentsInsightDismiss),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static String _typeLabel(InsightType type, L10n l10n) => switch (type) {
        InsightType.unclear => l10n.agentsInsightUnclear,
        InsightType.unknownTopic => l10n.agentsInsightUnknown,
        InsightType.handoff => l10n.agentsInsightHandoff,
      };
}

class _Quote extends StatelessWidget {
  const _Quote({required this.label, required this.text, this.outlined = false});

  final String label;
  final String text;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: outlined ? null : AppColors.surfaceHigh,
        border: outlined ? Border.all(color: AppColors.rule, width: AppStroke.hairline) : null,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppText.labelMicro),
          SizedBox(height: AppSpacing.xxs),
          Text(
            text,
            style: AppText.bodyS.copyWith(
              color: outlined ? AppColors.textSecondary : AppColors.textPrimary,
              height: 1.32,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Asks before deleting — the agent stops replying on every page it had.
Future<bool?> showAgentDeleteSheet(
  BuildContext context, {
  required String agentName,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    barrierColor: AppColors.scrim,
    builder: (sheet) {
      final l10n = L10n.of(sheet);
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.xl,
            AppSpacing.gutter,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.agentsDeleteTitle, style: AppText.title),
              SizedBox(height: AppSpacing.xs),
              Text(
                l10n.agentsDeleteBody(agentName),
                style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
              ),
              SizedBox(height: AppSpacing.xl),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentAlert,
                  foregroundColor: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.of(sheet).pop(true),
                child: Text(l10n.agentsDeleteConfirm),
              ),
              SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => Navigator.of(sheet).pop(false),
                child: Text(l10n.commonCancel),
              ),
            ],
          ),
        ),
      );
    },
  );
}
