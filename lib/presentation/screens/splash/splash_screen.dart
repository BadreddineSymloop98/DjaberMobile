import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../theme/app_colors.dart';
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
    return const Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: RiseFade(
          duration: SplashScreen._riseDuration,
          offset: 28,
          child: _SplashLogo(),
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    // 18% of the shorter edge — about 72px on a 400dp phone. `.r` rather than
    // `.w` so the mark stays square and proportionate rather than stretching.
    return DjaberLogo(size: 18.r);
  }
}
