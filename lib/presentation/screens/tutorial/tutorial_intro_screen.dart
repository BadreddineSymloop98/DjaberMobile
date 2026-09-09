import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/checklist_row.dart';

/// `T1a — Bienvenue`, `T1b — Votre stock`, `T1c — Votre agent`.
///
/// The tutorial's intro: three swipeable pages that state the four steps the
/// merchant is about to do, before the steps themselves (`T2`–`T5`) create the
/// records. It runs once, immediately after account creation — see
/// [SessionViewModel.tutorialPending] for how that is decided.
///
/// **The structure follows the frames.** The `Passer` header and the
/// dots-plus-button footer sit *outside* the paged area and persist across the
/// three pages; only the checklist and the copy swipe. Each page dims the
/// steps it is not about to 28% rather than hiding them, so the whole
/// four-step shape stays visible while one part of it is emphasised:
///
/// | Page | Lit | Button |
/// |---|---|---|
/// | `T1a` | all four | Suivant |
/// | `T1b` | 1 and 2 | Suivant |
/// | `T1c` | 3 and 4 | Commencer |
///
/// > **The copy is invented and unapproved.** Nothing in the web app sources a
/// > tutorial, so none of it comes from `src/lib/i18n.ts`. The French is the
/// > design's own; the English and Arabic were written here, because the Figma
/// > file carries the tutorial in French only.
class TutorialIntroScreen extends StatefulWidget {
  const TutorialIntroScreen({super.key});

  @override
  State<TutorialIntroScreen> createState() => _TutorialIntroScreenState();
}

class _TutorialIntroScreenState extends State<TutorialIntroScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Skips the **introduction**, not the tutorial.
  ///
  /// These three pages only explain what is coming; nothing here creates
  /// anything, so a merchant who does not want the explanation can go straight
  /// to the first step. `T2`, `T3` and `T4` remain mandatory — they are what
  /// actually sets the shop up — and `tutorialPending` deliberately stays
  /// armed.
  void _skipIntro() => context.go(Routes.tutorialMode);

  void _next(int pageCount) {
    if (_page >= pageCount - 1) {
      // The last page hands over to the first real step. The flag stays
      // pending: the merchant has not finished the tutorial, only finished
      // being told what it is.
      context.go(Routes.tutorialMode);
      return;
    }
    _controller.nextPage(
      duration: AppDuration.slow,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    // The four steps, in the order the tutorial performs them. Mode precedes
    // the product deliberately: the merchant chooses how they manage stock
    // before being asked for an initial quantity.
    final steps = <String>[
      l10n.tutorialStepMode,
      l10n.tutorialStepProduct,
      l10n.tutorialStepAgent,
      l10n.tutorialStepPage,
    ];

    final pages = <_IntroPage>[
      _IntroPage(
        title: l10n.tutorialWelcomeTitle,
        body: l10n.tutorialWelcomeBody,
        // T1a lights all four: it is the overview.
        lit: const {0, 1, 2, 3},
      ),
      _IntroPage(
        title: l10n.tutorialStockTitle,
        body: l10n.tutorialStockBody,
        lit: const {0, 1},
      ),
      _IntroPage(
        title: l10n.tutorialAgentTitle,
        body: l10n.tutorialAgentBody,
        lit: const {2, 3},
      ),
    ];

    final isLast = _page == pages.length - 1;

    // Back walks the pages instead of closing the app.
    //
    // The intro is reached with `context.go`, which replaces rather than
    // pushes, so there is nothing to pop and the pop would reach Android and
    // close the app — see `tutorial_step_scaffold.dart` for the same problem
    // on the steps. Here it can do something useful: these pages already swipe
    // both ways, so back should agree with the gesture and step backwards
    // through them. On the first page it does nothing.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _page == 0) return;
        _controller.previousPage(
          duration: AppDuration.slow,
          curve: Curves.easeOutCubic,
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SkipBar(label: l10n.commonSkip, onSkip: _skipIntro),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (index) => setState(() => _page = index),
                  itemCount: pages.length,
                  itemBuilder: (context, index) =>
                      _IntroPageView(page: pages[index], steps: steps),
                ),
              ),
              _Footer(
                count: pages.length,
                index: _page,
                label: isLast ? l10n.commonStart : l10n.commonNext,
                onPressed: () => _next(pages.length),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroPage {
  const _IntroPage({
    required this.title,
    required this.body,
    required this.lit,
  });

  final String title;
  final String body;

  /// Indices of the steps this page is about. Everything else dims.
  final Set<int> lit;
}

/// One page: the checklist centred in the space above the copy, then the copy.
class _IntroPageView extends StatelessWidget {
  const _IntroPageView({required this.page, required this.steps});

  final _IntroPage page;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter), // 20
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Two equal spacers, as the frames are built: the checklist sits in
          // the middle of whatever room the copy leaves it.
          const Spacer(),
          ChecklistBox(
            rows: [
              for (var i = 0; i < steps.length; i++)
                ChecklistRow(
                  step: i + 1,
                  label: steps[i],
                  dimmed: !page.lit.contains(i),
                ),
            ],
          ),
          const Spacer(),
          Text(page.title, style: AppText.displayM),
          SizedBox(height: AppSpacing.md), // 12
          Text(page.body, style: tutorialBodyStyle),
        ],
      ),
    );
  }
}

/// The file's `Body` style — Geist Regular 13 / 1.32, `text/secondary`.
///
/// [AppText.bodyS] is the same face, size and colour but sits at 1.4, one of
/// the code-versus-file drifts recorded in brief §21.9. Pinned to the file's
/// value here rather than changing the shared token, which the four auth
/// screens are already built on.
@visibleForTesting
TextStyle get tutorialBodyStyle => AppText.bodyS.copyWith(height: 1.32);

/// `Passer`, top right, on every page — including the last, which is how the
/// frames have it.
///
/// **It skips the introduction, not the tutorial.** These pages explain; they
/// do not create. `T2`–`T4` stay mandatory, and only `T5` — which depends on
/// Meta — can be deferred.
///
/// Sentence case in Geist, not the uppercase mono the install onboarding's
/// skip uses: the frames set it in `Title` at `text/muted`.
class _SkipBar extends StatelessWidget {
  const _SkipBar({required this.label, required this.onSkip});

  final String label;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 3.32.h, // 28
        left: AppSpacing.gutter,
        right: AppSpacing.gutter,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: GestureDetector(
          onTap: onSkip,
          behavior: HitTestBehavior.opaque,
          // Slop that grows the target down and inwards only, so the label
          // still lands where the frame puts it.
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: Text(
              label,
              style: AppText.title.copyWith(color: AppColors.textMuted),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dots and the one primary action, persistent below the paged area.
class _Footer extends StatelessWidget {
  const _Footer({
    required this.count,
    required this.index,
    required this.label,
    required this.onPressed,
  });

  final int count;
  final int index;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: AppSpacing.xl), // 20 — the frames' `Gap · rail`
        _PageDots(count: count, index: index),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.xl, // 20
            AppSpacing.gutter,
            3.32.h, // 28
          ),
          child: FilledButton(onPressed: onPressed, child: Text(label)),
        ),
      ],
    );
  }
}

/// Progress as bars, the active one wider rather than a different colour —
/// which stays legible in daylight where filled-versus-hollow dots do not.
///
/// 18x3 active and 5x3 inactive with a 6 gap, from the frames. These are not
/// the onboarding screen's dots (24/8, `line/lit`); the tutorial draws its own,
/// narrower set.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: AppDuration.normal,
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: 0.77.w), // 3, for a 6 gap
          height: 0.77.w, // 3
          width: active ? 4.62.w : 1.28.w, // 18 / 5
          decoration: BoxDecoration(
            color: active ? AppColors.textPrimary : AppColors.textMuted,
            borderRadius: BorderRadius.circular(0.51.w), // 2
          ),
        );
      }),
    );
  }
}
