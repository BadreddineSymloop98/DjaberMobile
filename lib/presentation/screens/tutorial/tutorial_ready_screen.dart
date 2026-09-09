import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../data/models/agent.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/session_view_model.dart';
import '../../viewmodels/stock_mode_view_model.dart';
import '../../viewmodels/tutorial_view_model.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/checklist_row.dart';

/// `T6 — Prêt`. The tutorial's closing screen.
///
/// **It carries no wizard chrome** — no step counter, no progress bar, no
/// `Passer`. The steps are done; there is nothing left to skip. That is why it
/// does not use [TutorialStepScaffold].
///
/// The same four steps the intro listed, now ticked and each carrying **what
/// was actually created** rather than a generic confirmation: the mode chosen,
/// the product's name, the agent and its tone, the page. Those come from
/// [TutorialViewModel], which the three creating steps wrote into.
///
/// A step whose record is missing — the merchant reached the end without
/// completing it, or a link failed — still shows, unticked and without a
/// subtitle, rather than being hidden. A checklist that silently drops a line
/// is worse than one that admits a gap.
class TutorialReadyScreen extends StatelessWidget {
  const TutorialReadyScreen({super.key});

  /// Ends the tutorial for good and hands the merchant the app.
  Future<void> _finish(BuildContext context) async {
    final session = context.read<SessionViewModel>();
    final tutorial = context.read<TutorialViewModel>();
    final router = GoRouter.of(context);

    await session.completeTutorial();
    // So a second run in the same session does not inherit these records.
    tutorial.reset();
    router.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final tutorial = context.watch<TutorialViewModel>();
    final mode = context.watch<StockModeViewModel>();

    final agent = tutorial.agent;

    // The tutorial ends here however it was walked, including when the
    // merchant chose *Connecter plus tard* on `T5`. Without a Page the agent
    // is **not** answering anyone, so the screen says so: a different heading,
    // a neutral mark instead of the live ring, and the fourth step left
    // unticked below. Congratulating a merchant for a connection that did not
    // happen would be the one lie the whole screen exists to avoid.
    final isLive = tutorial.page != null;

    final steps = <({String label, String? subtitle})>[
      (
        label: l10n.tutorialStepMode,
        subtitle: mode.isAdvanced
            ? l10n.tutorialReadyModeAdvanced
            : l10n.tutorialReadyModeSimple,
      ),
      (
        label: l10n.tutorialStepProduct,
        subtitle: tutorial.product?.name,
      ),
      (
        label: l10n.tutorialStepAgent,
        subtitle: agent == null
            ? null
            : '${agent.name} · ${_toneLabel(agent.personality, l10n)}',
      ),
      (
        label: l10n.tutorialStepPage,
        subtitle: tutorial.page?.pageName,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 10.9.h), // 92
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _LiveMark(live: isLive),
                    ),
                    SizedBox(height: AppSpacing.xxl), // 24
                    Text(
                      isLive
                          ? l10n.tutorialReadyTitle
                          : l10n.tutorialReadyTitlePending,
                      style: AppText.displayM,
                    ),
                    SizedBox(height: 2.56.w), // 10
                    Text(
                      isLive
                          ? l10n.tutorialReadySubtitle
                          : l10n.tutorialReadySubtitlePending,
                      style: AppText.bodyS.copyWith(height: 1.32),
                    ),
                    SizedBox(height: 3.32.h), // 28
                    ChecklistBox(
                      rows: [
                        for (final (index, step) in steps.indexed)
                          ChecklistRow(
                            step: index + 1,
                            label: step.label,
                            subtitle: step.subtitle,
                            // Ticked only where there is a record to show for
                            // it. The mode always has one — it has a default.
                            done: index == 0 || step.subtitle != null,
                          ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.md, // 12
                AppSpacing.gutter,
                3.32.h, // 28
              ),
              child: FilledButton(
                onPressed: () => _finish(context),
                child: Text(l10n.tutorialReadySubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _toneLabel(AgentPersonality personality, L10n l10n) =>
      switch (personality) {
        AgentPersonality.professional => l10n.agentToneProfessional,
        AgentPersonality.friendly => l10n.agentToneFriendly,
        AgentPersonality.casual => l10n.agentToneCasual,
        AgentPersonality.technical => l10n.agentToneTechnical,
      };
}

/// The 64px ring with a tick — the one place `signal/live` appears in the
/// tutorial, and it means exactly what the token means: the agent is live.
///
/// With no Page connected it is not, so the ring drops to `text/muted`. The
/// token is never spent on "nearly": brief §21.3 — `live` means live.
class _LiveMark extends StatelessWidget {
  const _LiveMark({required this.live});

  final bool live;

  @override
  Widget build(BuildContext context) {
    final tint = live ? AppColors.live : AppColors.textMuted;
    return Container(
      width: 16.41.w, // 64
      height: 16.41.w, // 64
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: tint, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: AppIcon(
        AppIcons.check,
        size: 7.18.w, // 28
        color: tint,
      ),
    );
  }
}
