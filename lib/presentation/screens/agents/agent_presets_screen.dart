import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/agent_preset.dart';
import '../../../data/repositories/agent_repository.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/agent_create_view_model.dart';
import '../../widgets/api_error_message.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/icon_square_button.dart';

/// `15 — Agents · démarrer`: start with a ready-made agent, or from scratch.
///
/// The four cards are the web's templates (`/dashboard/agents`, no-agent
/// state). On the web a card opens the full create form pre-filled; on a phone
/// the configuration is already complete, so a tap creates the agent on every
/// connected page and returns to `14`. Everything stays editable afterwards
/// from the agent's details.
class AgentPresetsScreen extends StatefulWidget {
  const AgentPresetsScreen({super.key});

  @override
  State<AgentPresetsScreen> createState() => _AgentPresetsScreenState();
}

class _AgentPresetsScreenState extends State<AgentPresetsScreen> {
  late final AgentPresetsViewModel _model = AgentPresetsViewModel(
    agents: context.read<AgentRepository>(),
    pages: context.read<PageRepository>(),
  );

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

  /// Back to `14` once an agent exists. Popping, not `go`: `go` swaps the
  /// stack without completing the push that opened this screen, so the list
  /// under it never learns to reload and keeps showing its empty state.
  /// Opened without a list below it (a restored route), `go` builds a fresh
  /// one, which loads on its own.
  void _close(bool created) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(created);
    } else {
      router.go(Routes.agents);
    }
  }

  /// "Partir de zéro" answers `true` when it created the agent; this screen
  /// then steps back too, so the list is reached — and reloads — in one go.
  Future<void> _startFromScratch() async {
    final created = await GoRouter.of(context).push<bool>(Routes.agentNewScratch);
    if (created == true && mounted) _close(true);
  }

  Future<void> _use(AgentPreset preset) async {
    final outcome = await _model.createFrom(preset);
    if (!mounted) return;
    final l10n = L10n.of(context);
    switch (outcome) {
      case AgentCreateOutcome.created:
        AppToast.success(context, l10n.agentsCreatedToast);
        _close(true);
      // A plan limit included: the backend's sentence says which, and the
      // merchant stays here to read it.
      case AgentCreateOutcome.limitReached || AgentCreateOutcome.failed:
        final error = _model.createError;
        AppToast.info(context, error == null ? l10n.errorGeneric : apiErrorMessage(error, l10n));
    }
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
                padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0.47.h, AppSpacing.gutter, AppSpacing.lg),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppBackButton(onBack: _back, semanticLabel: l10n.commonBack),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xxl),
                  children: [
                    Text(l10n.agentsTitle, style: AppText.displayM),
                    SizedBox(height: AppSpacing.sm),
                    Text(l10n.agentsSubtitle, style: AppText.bodyS.copyWith(height: 1.32)),
                    SizedBox(height: AppSpacing.xl),
                    Text(l10n.agentsPresetsTitle, style: AppText.title),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.agentsPresetsBody,
                      style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    for (final preset in AgentPreset.all) ...[
                      _PresetCard(
                        preset: preset,
                        busy: _model.creatingKey == preset.key,
                        enabled: _model.creatingKey == null,
                        onUse: () => _use(preset),
                      ),
                      SizedBox(height: AppSpacing.md),
                    ],
                    SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.agentsPresetOwn,
                      style: AppText.bodyS.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: _model.creatingKey != null
                          ? null
                          : _startFromScratch,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(AppIcons.plus, size: 4.1.w, color: AppColors.textPrimary),
                          SizedBox(width: AppSpacing.sm),
                          Text(l10n.agentsPresetScratch),
                        ],
                      ),
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

/// One ready-made agent, as the `Preset Card` component draws it.
class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.busy,
    required this.enabled,
    required this.onUse,
  });

  final AgentPreset preset;
  final bool busy;
  final bool enabled;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final (tagline, highlights) = presetCopy(preset.key, l10n);
    final tag = preset.imageRecognition && preset.voiceTranscription
        ? l10n.agentsPresetVisionVoice
        : l10n.agentsPresetVoice;

    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: enabled ? onUse : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: AppIcon(AppIcons.bot, size: 5.13.w, color: AppColors.live),
                  ),
                  const Spacer(),
                  Text(tag, style: AppText.labelMicro),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              // Brand names, never translated — as in every row of the frame.
              Text(preset.name, style: AppText.title),
              SizedBox(height: AppSpacing.xxs),
              Text(tagline, style: AppText.bodyS.copyWith(color: AppColors.textMuted, height: 1.32)),
              SizedBox(height: AppSpacing.md),
              for (final line in highlights)
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 1.8.w),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(line, style: AppText.bodyS.copyWith(color: AppColors.textSecondary, height: 1.32)),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: AppSpacing.sm),
              busy
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
                    )
                  : Text(
                      l10n.agentsPresetUse,
                      style: AppText.actionS.copyWith(
                        color: enabled ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A preset's card copy in the merchant's language.
(String, List<String>) presetCopy(String key, L10n l10n) => switch (key) {
      'closer' => (
          l10n.agentsPresetCloserTagline,
          [l10n.agentsPresetCloser1, l10n.agentsPresetCloser2, l10n.agentsPresetCloser3],
        ),
      'support' => (
          l10n.agentsPresetSupportTagline,
          [l10n.agentsPresetSupport1, l10n.agentsPresetSupport2, l10n.agentsPresetSupport3],
        ),
      'advisor' => (
          l10n.agentsPresetAdvisorTagline,
          [l10n.agentsPresetAdvisor1, l10n.agentsPresetAdvisor2, l10n.agentsPresetAdvisor3],
        ),
      _ => (
          l10n.agentsPresetExpressTagline,
          [l10n.agentsPresetExpress1, l10n.agentsPresetExpress2, l10n.agentsPresetExpress3],
        ),
    };
