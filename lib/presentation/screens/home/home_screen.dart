import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/session_view_model.dart';

/// `09 — Accueil`, as a stub.
///
/// One line, on purpose. The real frame carries the escalation queue, a
/// shortcut grid, stock KPIs, two digests and a custom nav bar — none of which
/// is built. This exists so signing in lands somewhere that proves the session
/// arrived, rather than on a placeholder that proves only the route resolved.
///
/// The greeting name comes from [User.greetingName], which falls back to the
/// part of the email before the `@` — the backend guarantees `firstName` is
/// non-empty, but a merchant created outside the sign-up form might not have
/// one, and "Welcome back, " reads as a bug.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final user = context.watch<SessionViewModel>().user;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Center(
            child: Text(
              l10n.homeWelcome(user?.greetingName ?? ''),
              style: AppText.displayM,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
