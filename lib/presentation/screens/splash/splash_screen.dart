import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/session_view_model.dart';
import '../../widgets/djaber_logo.dart';
import '../../widgets/rise_fade.dart';

/// The launch screen.
///
/// It is not decoration: it covers [SessionViewModel.restore], which reads the
/// stored token and asks the backend whether it is still good. The router holds
/// every navigation here until that finishes, so the merchant never sees a
/// login screen flash before being sent to home.
///
/// A wordmark and nothing else, per the design. Still open on this flow: no
/// loading state, no version, and no offline case — a restore that fails on a
/// dead network keeps the session and moves on, but says nothing about it.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// The splash stays up at least this long.
  ///
  /// Without a floor, a restore that resolves in 150ms cuts the logo animation
  /// mid-rise and the app looks broken rather than fast. Long enough for the
  /// reveal to land, short enough not to tax a merchant opening the app because
  /// a customer is waiting.
  static const minimumDisplay = Duration(milliseconds: 1150);

  static const _riseDuration = Duration(milliseconds: 620);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // After the first frame, so the animation starts on a painted screen
    // rather than competing with the engine's own startup work.
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final session = context.read<SessionViewModel>();
    await Future.wait([
      session.restore(),
      Future<void>.delayed(SplashScreen.minimumDisplay),
    ]);
    if (!mounted) return;
    // Flips the gate the router's redirect is waiting on.
    session.markBootComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: RiseFade(
          duration: SplashScreen._riseDuration,
          offset: 3.32.h, // 28 on the 844-tall frame
          child: const _SplashLogo(),
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    // ~56px on the 390-wide design frame, which is what the splash frame uses.
    // `.r` rather than `.w` so the mark stays square and proportionate rather
    // than stretching.
    //
    // The tagline is on here and off in headers, matching the frame. It reads
    // from `appTagline`, which is the web's own `dash.tagline`.
    // Scaled down rather than allowed to overflow.
    //
    // The lockup's Row is `mainAxisSize.min` with no bound on the text
    // column, so its width is whatever the wordmark and tagline need — and
    // **the Arabic tagline is wider than the wordmark**. It overflowed at
    // every width tested: 24px at 320, 27 at 360, 29 even at the frames' own
    // 390, while French and English fit with room to spare. Nothing caught it
    // because nothing had ever rendered this screen in Arabic.
    //
    // The same fix home's header and the drawer already use for the same
    // widget (brief §23.9, §24.6): the lockup shrinks proportionally instead
    // of clipping the wordmark. The gutter keeps it off the edges on a 320
    // handset, which is this market's floor.
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: _SplashLockup(),
      ),
    );
  }
}

/// The lockup itself, at the splash frame's size.
class _SplashLockup extends StatelessWidget {
  const _SplashLockup();

  @override
  Widget build(BuildContext context) {
    // ~56px on the 390-wide design frame. `.r` rather than `.w` so the mark
    // stays square and proportionate rather than stretching.
    return DjaberLogo(size: 14.4.r, showTagline: true);
  }
}
