import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/agent.dart';
import '../../../data/models/connected_page.dart';
import '../../../data/models/page_summary.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/pages_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../agents/agent_widgets.dart' show agentPersonalityLabel;

/// The web's `GenerateAgentModal`, as a sheet: what it does → reading,
/// analysing, drafting → a preview to edit → apply.
///
/// Pops with true when an agent was created, false when one was updated, null
/// when closed without applying.
Future<bool?> showGenerateAgentSheet(BuildContext context, {required ConnectedPage page}) {
  final repository = context.read<PageRepository>();
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    // No swipe to close: a drag pops the sheet without asking, and doing it
    // while Appliquer is saving threw the result away — the agent saved, but
    // no toast and a stale card. The × and the scrim still close it, and both
    // respect the sheet's PopScope.
    enableDrag: false,
    backgroundColor: AppColors.ink,
    barrierColor: AppColors.scrim,
    builder: (_) => _GenerateAgentSheet(repository: repository, page: page),
  );
}

class _GenerateAgentSheet extends StatefulWidget {
  const _GenerateAgentSheet({required this.repository, required this.page});

  final PageRepository repository;
  final ConnectedPage page;

  @override
  State<_GenerateAgentSheet> createState() => _GenerateAgentSheetState();
}

class _GenerateAgentSheetState extends State<_GenerateAgentSheet> {
  late final GenerateAgentViewModel _model = GenerateAgentViewModel(
    pages: widget.repository,
    pageId: widget.page.id,
  );

  late final FocusNode _instructionsFocus = FocusNode();

  @override
  void dispose() {
    _instructionsFocus.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final created = await _model.apply();
    if (!mounted) return;
    if (created != null) {
      Navigator.of(context).pop(created);
      return;
    }
    final l10n = L10n.of(context);
    final error = _model.applyError;
    AppToast.info(context, error == null ? l10n.agentGenApplyFail : apiErrorMessage(error, l10n));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Padding(
        // The instructions field must stay above the keyboard.
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ListenableBuilder(
          // The instructions too, so the character count follows the typing.
          listenable: Listenable.merge([_model, _model.instructions]),
          builder: (context, _) => PopScope(
            // Not while applying: closing then would lose the result.
            canPop: _model.phase != AgentGenPhase.applying,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.lg, AppSpacing.sm, AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 7.18.w, // 28
                      height: 7.18.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                      ),
                      child: AppIcon(AppIcons.sparkles, size: 3.59.w, color: AppColors.textSecondary),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.agentGenTitle, style: AppText.displayS),
                          SizedBox(height: AppSpacing.xxs),
                          Text(
                            l10n.agentGenSubtitle(widget.page.pageName),
                            style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _model.phase == AgentGenPhase.applying ? null : () => Navigator.of(context).pop(),
                      tooltip: l10n.commonCancel,
                      icon: AppIcon(AppIcons.close, size: 5.13.w, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(height: AppStroke.hairline, color: AppColors.rule),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, AppSpacing.xl),
                  children: switch (_model.phase) {
                    AgentGenPhase.idle => _idle(l10n),
                    AgentGenPhase.reading || AgentGenPhase.analyzing || AgentGenPhase.drafting => _working(l10n),
                    AgentGenPhase.preview => _preview(l10n),
                    AgentGenPhase.applying => _applying(l10n),
                  },
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _box({required Widget child}) => Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: child,
      );

  List<Widget> _idle(L10n l10n) => [
        _box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.agentGenWhatTitle, style: AppText.title),
              for (final line in [l10n.agentGenWhat1, l10n.agentGenWhat2, l10n.agentGenWhat3, l10n.agentGenWhat4]) ...[
                SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•', style: AppText.bodyS.copyWith(color: AppColors.textMuted)),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(line, style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.32)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        if (_model.generateError case final error?)
          ApiErrorLine(error: error),
        FilledButton(onPressed: _model.generate, child: Text(l10n.agentGenStart)),
        SizedBox(height: AppSpacing.sm),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
      ];

  List<Widget> _working(L10n l10n) {
    final phase = _model.phase;
    final label = switch (phase) {
      AgentGenPhase.analyzing => l10n.agentGenPhaseAnalyzing,
      AgentGenPhase.drafting => l10n.agentGenPhaseDrafting,
      _ => l10n.agentGenPhaseReading,
    };
    return [
      SizedBox(height: AppSpacing.huge),
      Center(
        child: SizedBox.square(
          dimension: 6.15.w,
          child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
        ),
      ),
      SizedBox(height: AppSpacing.lg),
      Text(label, style: AppText.title, textAlign: TextAlign.center),
      SizedBox(height: AppSpacing.xs),
      Text(
        l10n.agentGenPhaseSubhint,
        style: AppText.bodyS.copyWith(color: AppColors.textMuted),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: AppSpacing.xl),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          _Step(label: l10n.agentGenStepRead, active: phase == AgentGenPhase.reading, done: phase != AgentGenPhase.reading),
          _Step(
            label: l10n.agentGenStepAnalyze,
            active: phase == AgentGenPhase.analyzing,
            done: phase == AgentGenPhase.drafting,
          ),
          _Step(label: l10n.agentGenStepDraft, active: phase == AgentGenPhase.drafting, done: false),
        ],
      ),
    ];
  }

  List<Widget> _preview(L10n l10n) {
    final draft = _model.draft!;
    final warning = draft.warning;
    return [
      if (warning != null) ...[
        _box(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIcon(AppIcons.alert, size: 3.59.w, color: AppColors.textMuted),
              SizedBox(width: AppSpacing.sm),
              // The backend's own sentence — English — as the web shows it.
              Expanded(child: Text(warning, style: AppText.bodyS.copyWith(color: AppColors.textPrimary, height: 1.32))),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
      ],
      _box(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(l10n.agentGenSummary.toUpperCase(), style: AppText.labelMeta),
                Text(
                  l10n.agentGenSampled(draft.sampledConversations, draft.sampledMessages).toUpperCase(),
                  style: AppText.labelMicro,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(draft.businessSummary, style: AppText.bodyS.copyWith(color: AppColors.textPrimary, height: 1.4)),
            if (draft.languages.isNotEmpty) ...[
              SizedBox(height: AppSpacing.md),
              _Chips(label: l10n.agentGenLanguages, values: draft.languages),
            ],
            if (draft.topQuestions.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm),
              _Chips(label: l10n.agentGenTopQuestions, values: draft.topQuestions),
            ],
          ],
        ),
      ),
      SizedBox(height: AppSpacing.md),
      Row(
        children: [
          Expanded(
            child: _Pill(
              label: l10n.agentGenPersonality,
              value: agentPersonalityLabel(AgentPersonality.fromName(draft.personality), l10n),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(child: _Pill(label: l10n.agentGenTone, value: _tone(draft, l10n))),
          SizedBox(width: AppSpacing.sm),
          Expanded(child: _Pill(label: l10n.agentGenLength, value: _length(draft, l10n))),
        ],
      ),
      SizedBox(height: AppSpacing.lg),
      AppTextField(
        label: l10n.agentGenInstructions,
        controller: _model.instructions,
        focusNode: _instructionsFocus,
        minLines: 8,
        hint: l10n.agentGenEditHint,
        sentenceHint: true,
        textCapitalization: TextCapitalization.sentences,
      ),
      SizedBox(height: AppSpacing.xs),
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Text(l10n.agentGenChars(_model.instructions.text.length), style: AppText.labelMicro),
      ),
      SizedBox(height: AppSpacing.lg),
      FilledButton(onPressed: _apply, child: Text(l10n.agentGenApply(widget.page.pageName))),
      SizedBox(height: AppSpacing.sm),
      TextButton(onPressed: _model.discard, child: Text(l10n.agentGenDiscard)),
    ];
  }

  List<Widget> _applying(L10n l10n) => [
        SizedBox(height: AppSpacing.huge),
        Center(
          child: SizedBox.square(
            dimension: 5.13.w,
            child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.textSecondary),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          l10n.agentGenApplying,
          style: AppText.bodyS.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ];

  static String _tone(GeneratedAgentDraft draft, L10n l10n) => switch (draft.responseTone) {
        'formal' => l10n.agentGenToneFormal,
        'casual' => l10n.agentGenToneCasual,
        'enthusiastic' => l10n.agentGenToneEnthusiastic,
        _ => l10n.agentGenToneBalanced,
      };

  static String _length(GeneratedAgentDraft draft, L10n l10n) => switch (draft.responseLength) {
        'short' => l10n.agentGenLengthShort,
        'detailed' => l10n.agentGenLengthDetailed,
        _ => l10n.agentGenLengthMedium,
      };
}

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.active, required this.done});

  final String label;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5.13.w, // 20
          height: 5.13.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.textPrimary : AppColors.surface,
            border: Border.all(color: active ? AppColors.ruleStrong : AppColors.rule, width: AppStroke.hairline),
          ),
          child: done ? AppIcon(AppIcons.check, size: 3.08.w, color: AppColors.ink, strokeWidth: 3) : null,
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppText.labelMeta.copyWith(
            color: active
                ? AppColors.textPrimary
                : done
                    ? AppColors.textSecondary
                    : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.label, required this.values});

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(end: AppSpacing.xs),
          child: Text(label.toUpperCase(), style: AppText.labelMicro),
        ),
        for (final value in values)
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: Text(value, style: AppText.bodyS.copyWith(color: AppColors.textSecondary)),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppText.labelMicro, maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: AppSpacing.xxs),
          Text(value, style: AppText.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
