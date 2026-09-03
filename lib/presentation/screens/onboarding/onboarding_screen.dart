import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/session_view_model.dart';
import '../../widgets/rise_fade.dart';
import 'onboarding_artwork.dart';

/// Three slides: stock, then the agent answering, then the escalation.
///
/// Stock leads by request (2026-09-03). Note that this inverts the ordering the
/// brief's §3 model implies — the escalation is the reason the app exists and
/// stock is support for it — so the last slide, not the first, now carries the
/// product's actual promise. Worth revisiting alongside the copy, which is
/// itself still unapproved.
///
/// The artwork is **real UI, not illustration** — a message thread, an
/// escalation card, a row of shortcut tiles. The promise on screen is the
/// product on screen. When the real components exist, these swap for instances
/// of them; see `onboarding_artwork.dart`.
///
/// Copy is invented and not yet approved — there is no onboarding on the web,
/// so none of it comes from `src/lib/i18n.ts`.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  /// Which slides have been revealed. A slide animates in the first time the
  /// merchant lands on it and stays revealed after that, so swiping back does
  /// not replay the entrance — the reveal is a first impression, not a toll on
  /// every swipe.
  final _revealed = <int>{0};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _page = index;
      _revealed.add(index);
    });
  }

  void _next(int slideCount) {
    if (_page >= slideCount - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: AppDuration.slow,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    final session = context.read<SessionViewModel>();
    final router = GoRouter.of(context);
    await session.completeOnboarding();
    router.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final slides = <_Slide>[
      _Slide(
        title: l10n.onboardingStockTitle,
        body: l10n.onboardingStockBody,
        artwork: const ShortcutsArtwork(),
      ),
      _Slide(
        title: l10n.onboardingAnswersTitle,
        body: l10n.onboardingAnswersBody,
        artwork: const ConversationArtwork(),
      ),
      _Slide(
        title: l10n.onboardingEscalationTitle,
        body: l10n.onboardingEscalationBody,
        artwork: const EscalationArtwork(),
      ),
    ];
    final isLast = _page == slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            _SkipBar(onSkip: _finish, visible: !isLast),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: _onPageChanged,
                itemCount: slides.length,
                itemBuilder: (context, index) => _SlideView(
                  slide: slides[index],
                  // The whole slide rises in together — same gesture as the
                  // splash logo, staggered so the artwork leads and the words
                  // follow it.
                  reveal: _revealed.contains(index),
                ),
              ),
            ),
            _Footer(
              count: slides.length,
              index: _page,
              label: isLast ? l10n.commonStart : l10n.commonNext,
              onPressed: () => _next(slides.length),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.title,
    required this.body,
    required this.artwork,
  });

  final String title;
  final String body;
  final Widget artwork;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.reveal});

  final _Slide slide;
  final bool reveal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The artwork sits in the middle of the screen and takes whatever
          // room is left, so the copy below it never gets pushed off a short
          // handset.
          Expanded(
            child: Center(
              child: RiseFade(
                animate: reveal,
                offset: 28,
                duration: const Duration(milliseconds: 560),
                child: slide.artwork,
              ),
            ),
          ),
          RiseFade(
            animate: reveal,
            delay: const Duration(milliseconds: 90),
            child: Text(slide.title, style: AppText.displayM),
          ),
          const SizedBox(height: AppSpacing.md),
          RiseFade(
            animate: reveal,
            delay: const Duration(milliseconds: 160),
            child: Text(
              slide.body,
              style: AppText.bodyS.copyWith(height: 1.55),
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

class _SkipBar extends StatelessWidget {
  const _SkipBar({required this.onSkip, required this.visible});

  final VoidCallback onSkip;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: AppDuration.normal,
          child: IgnorePointer(
            ignoring: !visible,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: TextButton(
                onPressed: onSkip,
                child: Text(
                  // Uppercased at the call site, the way the web's `.label`
                  // primitive does with `text-transform`. The 0.16em tracking
                  // in the style is designed for caps.
                  L10n.of(context).commonSkip.toUpperCase(),
                  style: AppText.label.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.lg,
        AppSpacing.gutter,
        AppSpacing.xxl,
      ),
      child: Column(
        children: [
          _PageDots(count: count, index: index),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: onPressed, child: Text(label)),
        ],
      ),
    );
  }
}

/// Progress, as a row of bars rather than dots — the active one widens instead
/// of changing colour, which stays legible in daylight where a filled-versus-
/// hollow dot does not.
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
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          height: 3,
          width: active ? 24 : 8,
          decoration: BoxDecoration(
            color: active ? AppColors.textPrimary : AppColors.ruleStrong,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        );
      }),
    );
  }
}
