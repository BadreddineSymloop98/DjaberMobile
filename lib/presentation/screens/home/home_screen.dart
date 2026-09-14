import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/session_view_model.dart';
import '../../widgets/app_icon.dart';

/// `09 — Accueil`, as a stub.
///
/// One line and a sign-out control, on purpose. The real frame carries the
/// escalation queue, a shortcut grid, stock KPIs, two digests and a custom nav
/// bar — none of which is built. This exists so signing in lands somewhere
/// that proves the session arrived, rather than on a placeholder that proves
/// only the route resolved.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final session = context.watch<SessionViewModel>();
    final user = session.user;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                // Falls back to the local part of the email — the backend
                // requires firstName, but a merchant created outside the
                // sign-up form might not have one, and "Bon retour, " reads
                // as a bug.
                l10n.homeWelcome(user?.greetingName ?? ''),
                style: AppText.displayM,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.huge),
              _SignOutButton(
                label: l10n.menuSignOut,
                onPressed: session.signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ends the session.
///
/// **Temporary placement.** Sign-out belongs in the tier-3 hamburger menu
/// (brief §16) alongside settings and language; it sits on the home stub only
/// because the behaviour needed somewhere to be reachable from. Moving it is
/// a matter of calling `session.signOut` from wherever it lands — the logic
/// lives in [SessionViewModel], not here.
///
/// No confirmation dialog: signing out costs nothing that cannot be undone by
/// signing back in, and a merchant who tapped it meant it.
///
/// Outlined rather than filled, because the design reserves the one white
/// button per screen for the primary action — and this is not one.
class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(
            AppIcons.logout,
            size: 4.1.w, // 16
            color: AppColors.textPrimary,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      ),
    );
  }
}
