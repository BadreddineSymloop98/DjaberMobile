import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../data/models/agent.dart';
import '../../../data/repositories/agent_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/session_view_model.dart';
import '../../viewmodels/tutorial_agent_view_model.dart';
import '../../viewmodels/tutorial_view_model.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/leave_sheet.dart';
import '../../widgets/option_card.dart';
import 'tutorial_messages.dart';
import 'tutorial_step_scaffold.dart';

/// `T4 — Agent IA`. Step 3 of 4.
///
/// Three inputs, which is the frame's own promise — *"Trois champs suffisent
/// — tout s'ajuste plus tard"*. Everything else on the backend's `Agent` has a
/// server default and is left alone here.
///
/// The four personalities are the backend's own enum values
/// (`professional`, `friendly`, `casual`, `technical`), with Professionnel
/// preselected because that is the column default. They reuse [OptionCard]
/// **without an icon** — the frame draws them bare, which is why that
/// component's icon is optional.
class TutorialAgentScreen extends StatefulWidget {
  const TutorialAgentScreen({super.key});

  @override
  State<TutorialAgentScreen> createState() => _TutorialAgentScreenState();
}

class _TutorialAgentScreenState extends State<TutorialAgentScreen> {
  late final TutorialAgentViewModel _model = TutorialAgentViewModel(
    agents: context.read<AgentRepository>(),
  );

  /// Looked up once in [initState]: [dispose] runs too late to read the tree.
  late final TutorialViewModel _tutorial;

  @override
  void initState() {
    super.initState();
    // Leaving the app replays the splash, which replaces this screen — so put
    // back the name, instructions and personality from before it was torn
    // down.
    _tutorial = context.read<TutorialViewModel>();
    _model.restore(_tutorial.draftFor(Routes.tutorialAgent));
  }

  @override
  void dispose() {
    // A step that went through has spent its values; any other close keeps
    // them for when the step opens again.
    if (_model.created != null || _model.alreadyExists) {
      _tutorial.clearDraft(Routes.tutorialAgent);
    } else {
      _tutorial.saveDraft(Routes.tutorialAgent, _model.draft);
    }
    _model.dispose();
    super.dispose();
  }

  /// Set once the agent exists, and never cleared. Back is ignored from then
  /// on, so nothing can interrupt the move to `T5`.
  bool _advancing = false;

  /// The typed name or instructions: what leaving the app from this root
  /// would lose. The draft lives in memory only and dies with the process.
  bool get _hasTyped =>
      _model.name.value.trim().isNotEmpty ||
      _model.instructions.value.trim().isNotEmpty;

  /// `T4` is a root (the product below it is spent), so back leaves the app.
  /// With something typed, the leave sheet is the confirmation, replacing
  /// "tap again", and says what is lost. Busy or advancing is handled by the
  /// scaffold, which ignores the press.
  Future<bool> _onBack() => showLeaveSheet(
        context,
        body: L10n.of(context).tutorialAgentLeaveBody,
      );

  Future<void> _create() async {
    final agent = await _model.submitAndCreate();
    if ((agent != null || _model.alreadyExists) && mounted) {
      setState(() => _advancing = true);
    }
    // The wall this whole change exists to remove: one agent per user is
    // enforced, so a merchant who force-quit after this step came back to a
    // 403 they could never get past. `alreadyExists` treats that 403 as what
    // it actually means — the step is done.
    if ((agent == null && !_model.alreadyExists) || !mounted) return;
    // Recorded before navigating: step 4 needs the agent's id to attach the
    // page it connects.
    if (agent != null) {
      context.read<TutorialViewModel>().agentCreated(agent);
      AppToast.success(context, L10n.of(context).toastAgentCreated);
    } else {
      AppToast.info(context, L10n.of(context).tutorialStepAlreadyDone);
    }
    await context.read<SessionViewModel>()
        .rememberTutorialStep(Routes.tutorialConnect);
    if (!mounted) return;
    GoRouter.of(context).go(Routes.tutorialConnect);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    final personalities = <(AgentPersonality, String, String)>[
      (
        AgentPersonality.professional,
        l10n.agentToneProfessional,
        l10n.agentToneProfessionalDesc
      ),
      (
        AgentPersonality.friendly,
        l10n.agentToneFriendly,
        l10n.agentToneFriendlyDesc
      ),
      (AgentPersonality.casual, l10n.agentToneCasual, l10n.agentToneCasualDesc),
      (
        AgentPersonality.technical,
        l10n.agentToneTechnical,
        l10n.agentToneTechnicalDesc
      ),
    ];

    return ChangeNotifierProvider<TutorialAgentViewModel>.value(
      value: _model,
      child: Consumer<TutorialAgentViewModel>(
        builder: (context, model, _) {
          final nameError = model.visibleError(model.name);

          return TutorialStepScaffold(
            step: 3,
            busy: model.isBusy || _advancing,
            dirty: _hasTyped,
            onLeave: _onBack,
            title: l10n.tutorialAgentTitle,
            subtitle: l10n.tutorialAgentSubtitle,
            footer: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TutorialErrorLine(error: model.submitError),
                FilledButton(
                  onPressed: model.isBusy ? null : _create,
                  child: model.isBusy
                      ? SizedBox.square(
                          dimension: AppSpacing.gutterTight,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.ink,
                          ),
                        )
                      : Text(l10n.tutorialAgentSubmit),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: l10n.agentName,
                  isRequired: true,
                  controller: model.name.controller,
                  focusNode: model.name.focusNode,
                  errorText: nameError == null
                      ? null
                      : tutorialFieldMessage(nameError, l10n),
                  placeholder: l10n.agentNamePlaceholder,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  // Named explicitly. Here four Option Cards sit between the
                  // two inputs: traversal walked into them and the keyboard's
                  // **next** key moved focus to nothing at all, so the key
                  // advertised an action it did not perform.
                  //
                  // This used to record `T3` as the counter-example, where the
                  // fields are adjacent and the default `nextFocus()` was
                  // thought to land on the right one. It did in the widget
                  // test and did not on a handset, so `T3` names its hops too
                  // now — as do both auth screens and `18`. No form in the app
                  // leaves this to traversal any more.
                  onSubmitted: (_) => model.instructions.focusNode.requestFocus(),
                  inputFormatters: [LengthLimitingTextInputFormatter(255)],
                ),
                SizedBox(height: AppSpacing.xl), // 20
                Text(
                  // Uppercased at the call site, the way `AppTextField` does
                  // with its own label and the web's `.label` primitive does
                  // with `text-transform`. Without it this one heading sat in
                  // sentence case among a screen of uppercase mono labels —
                  // caught by running it, not by the tests.
                  l10n.agentPersonality.toUpperCase(),
                  style: AppText.labelMeta,
                ),
                SizedBox(height: AppSpacing.sm), // 8
                for (final (value, label, description) in personalities) ...[
                  OptionCard(
                    label: label,
                    description: description,
                    selected: model.personality == value,
                    selectedBadge: l10n.commonActive,
                    onTap: () => model.selectPersonality(value),
                  ),
                  if (value != personalities.last.$1)
                    SizedBox(height: AppSpacing.sm), // 8
                ],
                SizedBox(height: AppSpacing.xl), // 20
                AppTextField(
                  label: l10n.agentInstructions,
                  controller: model.instructions.controller,
                  focusNode: model.instructions.focusNode,
                  placeholder: l10n.agentInstructionsPlaceholder,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [LengthLimitingTextInputFormatter(5000)],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
