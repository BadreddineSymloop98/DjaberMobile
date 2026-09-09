import 'package:flutter/material.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// The chrome every tutorial **step** shares — `T2` through `T5`.
///
/// The step counter in mono top left, a four-segment progress bar under it,
/// the step's own content as the page, and the action pinned to the bottom.
///
/// This is deliberately *not* the shell the intro uses. `T1a`–`T1c` carry
/// three dots and one shared button and no counter; the steps carry a counter
/// and a segmented bar and no dots. Two different headers, two different
/// footers — see `tutorial_intro_screen.dart`.
///
/// **The footer is a slot, not a label.** `T2`–`T4` put a single primary
/// button there, but `T5 — Connecter la page` carries two (Facebook and
/// Instagram), so the shell cannot own the button.
///
/// The content scrolls and the footer does not, the way [AuthScaffold] is
/// arranged: `T3 — Produit` is six fields and will meet a keyboard on a short
/// handset, and a footer inside a scroll view gets pushed off screen.
///
/// > **There is no `Passer`, and that diverges from the frames.** Every step
/// > frame draws one top right. It was taken out on the decision that a
/// > merchant completes setup — mode, product, agent — before reaching the
/// > app for the first time. The intro keeps its `Passer`, because it only
/// > explains; these steps create.
/// >
/// > The single exception is `T5 — Connecter la page`, which offers
/// > *Connecter plus tard*. It is the only step that depends on something
/// > outside the product: Meta has to grant access, and the merchant has to
/// > have a Page at all. Without that door, a merchant who cannot connect one
/// > would have an app they can never open.
class TutorialStepScaffold extends StatelessWidget {
  const TutorialStepScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.footer,
    this.totalSteps = stepCount,
  });

  /// The four steps the tutorial performs: mode, product, agent, page.
  static const stepCount = 4;

  /// 1-based, as the counter reads it.
  final int step;

  final String title;
  final String subtitle;

  /// The step's own content, below the heading and subtitle.
  final Widget child;

  /// The action or actions at the bottom.
  final Widget footer;

  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);

    // Back does nothing on a step.
    //
    // Every step is reached with `context.go`, which *replaces* the route
    // rather than pushing, so the navigator has nothing to pop and the pop
    // reaches Android — which closes the app. On `T3` that means a merchant
    // who has just typed six fields loses all of them and relaunches into the
    // intro, which reads as a crash. Back is the most-pressed control on
    // Android and is routinely used to dismiss a keyboard, so this is not an
    // edge case on the hardware in brief §9.
    //
    // Swallowed rather than sent backwards: the tutorial is mandatory, so
    // there is nowhere to go, and returning from `T4` to `T3` would invite
    // creating a second product. `Connecter plus tard` on `T5` remains the
    // only way out.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: gutter.copyWith(
                  top: 0.47.h, // 4
                  bottom: AppSpacing.xl, // 20
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // No `Passer`. The frames put one here, and it was built —
                    // then removed on the decision that a first-run merchant
                    // completes setup before reaching the app. See the class
                    // doc; this is a deliberate divergence from the file.
                    Text(
                      l10n.tutorialStepCounter(step, totalSteps),
                      style: AppText.labelMeta,
                    ),
                    SizedBox(height: AppSpacing.md), // 12
                    _StepIndicator(step: step, total: totalSteps),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: gutter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(title, style: AppText.displayM),
                      SizedBox(height: AppSpacing.sm), // 8
                      Text(
                        subtitle,
                        style: AppText.bodyS.copyWith(height: 1.32),
                      ),
                      SizedBox(height: AppSpacing.xl), // 20
                      child,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: gutter.copyWith(
                  top: AppSpacing.md, // 12
                  bottom: 3.32.h, // 28
                ),
                child: footer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The four-segment progress bar: one segment per step, filled up to and
/// including the current one.
///
/// Segments rather than a continuous bar because the tutorial has a known,
/// small number of steps and "3 of 4" should be countable at a glance rather
/// than estimated from a fraction.
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0.77.w, // 3
      child: Row(
        // Load-bearing. A childless `DecoratedBox` inside an `Expanded` takes
        // the *smallest* height its constraints allow, and the Row's default
        // centre alignment passes a loose one — so every segment rendered at
        // zero height and the bar was invisible on the device while all its
        // colours were still present in the tree. `stretch` makes the height
        // constraint tight.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 1; i <= total; i++) ...[
            if (i > 1) SizedBox(width: AppSpacing.xs), // 4
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // Done and current are lit; the rest are muted at 40%, which
                  // is the frames' own value.
                  color: i <= step
                      ? AppColors.textPrimary
                      : AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(0.51.w), // 2
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
