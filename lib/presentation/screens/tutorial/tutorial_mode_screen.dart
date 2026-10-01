import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../data/models/stock_mode.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/session_view_model.dart';
import '../../viewmodels/stock_mode_view_model.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/option_card.dart';
import 'tutorial_step_scaffold.dart';

/// `T2 — Mode stock`. Step 1 of 4.
///
/// **This step precedes the product deliberately**: the merchant decides how
/// they manage stock before being asked for an initial quantity.
///
/// The choice is a **device preference, not an API call** — the web keeps it
/// in `localStorage` (`dashboard/layout.tsx:220`) and there is no column for
/// it in `schema.prisma` and no endpoint that sets it. So this screen really
/// does persist, through [PrefsStorage]; nothing here is waiting on a backend.
///
/// Copy: the two cards are the web's own strings, `page.dash.settings.simple`
/// / `.advanced` / `.simpleDesc` / `.advancedDesc`, in all three languages.
/// The heading and subtitle are the Figma frame's, since a tutorial has no web
/// equivalent to source them from.
///
/// > **Note the frame paraphrases the web on the card descriptions** — it says
/// > *"Produits, catégories et commandes — gérez votre stock et vos commandes
/// > sans la complexité."* where `i18n.ts` says *"Produits, Catégories &
/// > Commandes — gérez votre inventaire et commandes sans complexité."* The
/// > web wins, per §17. Flagged so it does not read as drift.
class TutorialModeScreen extends StatefulWidget {
  const TutorialModeScreen({super.key});

  @override
  State<TutorialModeScreen> createState() => _TutorialModeScreenState();
}

class _TutorialModeScreenState extends State<TutorialModeScreen> {
  /// The pending choice, **always starting on Simple** — the web's default and
  /// what the frame shows preselected.
  ///
  /// Not read from the app-wide model: the mode is a device preference that
  /// survives sign-out, so a phone where someone once chose Avancé would
  /// otherwise preselect it for the new account this tutorial is setting up.
  StockMode _mode = StockMode.simple;

  Future<void> _continue() async {
    final stockMode = context.read<StockModeViewModel>();
    final session = context.read<SessionViewModel>();
    final router = GoRouter.of(context);
    // Committed on Continuer rather than on tap, so backing out of the step
    // does not leave the app-wide mode changed behind them.
    await stockMode.setMode(_mode);
    // Recorded before navigating, so a process death between the two resumes
    // forward rather than back at the intro.
    await session.rememberTutorialStep(Routes.tutorialProduct);
    router.go(Routes.tutorialProduct);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final selected = _mode;

    return TutorialStepScaffold(
      step: 1,
      title: l10n.tutorialModeTitle,
      subtitle: l10n.tutorialModeSubtitle,
      footer: FilledButton(
        onPressed: _continue,
        child: Text(l10n.commonContinue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OptionCard(
            icon: AppIcons.box,
            label: l10n.stockModeSimple,
            description: l10n.stockModeSimpleDesc,
            selected: selected == StockMode.simple,
            selectedBadge: l10n.commonActive,
            onTap: () => setState(() => _mode = StockMode.simple),
          ),
          SizedBox(height: AppSpacing.sm), // 8
          OptionCard(
            icon: AppIcons.bolt,
            label: l10n.stockModeAdvanced,
            description: l10n.stockModeAdvancedDesc,
            selected: selected == StockMode.advanced,
            selectedBadge: l10n.commonActive,
            onTap: () => setState(() => _mode = StockMode.advanced),
          ),
        ],
      ),
    );
  }
}
