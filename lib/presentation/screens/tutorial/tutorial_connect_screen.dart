import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/extensions/responsive_extension.dart';
import '../../../core/storage/prefs_storage.dart';
import '../../../data/models/connected_page.dart';
import '../../../data/repositories/agent_repository.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../viewmodels/session_view_model.dart';
import '../../viewmodels/tutorial_connect_view_model.dart';
import '../../viewmodels/tutorial_view_model.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_toast.dart';
import 'oauth_web_view_screen.dart';
import 'tutorial_messages.dart';
import 'tutorial_step_scaffold.dart';

/// `T5 — Connecter la page`. Step 4 of 4.
///
/// Says what Meta will ask for, then hands off to Meta's own dialog in a web
/// view. The three permission lines are the human reading of the scopes the
/// backend actually requests in `connectFacebookPage`:
/// `pages_show_list`, `pages_messaging`, `pages_read_engagement`
/// (plus `pages_manage_metadata`, which is the subscription plumbing and not
/// worth a line of its own).
///
/// **The two buttons are not the standard Primary Button.** The frame draws
/// them at Geist Regular 13 with a 16px brand mark and an 8 gap — white for
/// Facebook, hairline-outlined for Instagram. Same pair as `13 — Connecter une
/// page`, and the one screen in the app with two loud controls, because there
/// are genuinely two destinations rather than a primary and a secondary.
class TutorialConnectScreen extends StatefulWidget {
  const TutorialConnectScreen({super.key});

  @override
  State<TutorialConnectScreen> createState() => _TutorialConnectScreenState();
}

class _TutorialConnectScreenState extends State<TutorialConnectScreen> {
  late final TutorialConnectViewModel _model = TutorialConnectViewModel(
    pages: context.read<PageRepository>(),
    agents: context.read<AgentRepository>(),
  );

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _connect(PagePlatform platform) async {
    final authUrl = await _model.startConnect(platform);
    if (authUrl == null || !mounted) return;

    final result = await Navigator.of(context).push<OAuthResult>(
      MaterialPageRoute(
        builder: (_) => OAuthWebViewScreen(
          authUrl: authUrl,
          platform: platform,
        ),
        fullscreenDialog: true,
      ),
    );
    if (!mounted) return;

    switch (result?.outcome ?? OAuthOutcome.dismissed) {
      // Backing out is not a failure — the merchant changed their mind, and
      // the screen says nothing rather than accusing them of an error.
      case OAuthOutcome.dismissed:
        _model.connectAbandoned(denied: false);
        return;
      case OAuthOutcome.denied:
        _model.connectAbandoned(denied: true);
        return;
      // Meta granted, and our backend then said it could not save the page.
      case OAuthOutcome.failed:
        _model.connectFailed(result?.report?.reason);
        return;
      case OAuthOutcome.granted:
        break;
    }

    final agentId = context.read<TutorialViewModel>().agent?.id;
    final page = await _model.finishConnect(
      platform: platform,
      report: result?.report,
      agentId: agentId,
    );
    if (page == null || !mounted) return;

    context.read<TutorialViewModel>().pageConnected(page);
    final l10n = L10n.of(context);
    // The page is connected either way, so the step moves on — but a page the
    // agent is not linked to is one it does not answer on, so say so.
    if (_model.linkFailed) {
      AppToast.info(context, l10n.connectLinkFailed);
    } else {
      AppToast.success(context, l10n.toastPageConnected);
    }
    await context.read<SessionViewModel>()
        .rememberTutorialStep(Routes.tutorialReady);
    if (!mounted) return;
    GoRouter.of(context).go(Routes.tutorialReady);
  }

  /// Leaves the page connection for later and opens the app.
  ///
  /// **The only way out of the tutorial before the end**, and it exists on
  /// this step alone. `T2` writes a device preference and cannot fail; `T3`
  /// and `T4` call our own backend, so a failure there is transient. `T5`
  /// depends on Meta — the merchant may have no Page yet, or it may belong to
  /// someone else, or Meta may simply not grant it (the app is still in
  /// development mode). Without this, that merchant has an app they can never
  /// open.
  ///
  /// It still goes **through `T6`**, which is where the tutorial ends however
  /// it was walked. That screen reads its own state: with no Page it drops the
  /// "Votre agent est en ligne" heading and leaves the fourth step unticked,
  /// so the merchant is told plainly what is still outstanding rather than
  /// being congratulated for something that did not happen.
  Future<void> _later() async {
    final prefs = context.read<PrefsStorage>();
    final session = context.read<SessionViewModel>();
    final router = GoRouter.of(context);

    // Recorded so home's Démarrer checklist can show the step as still
    // outstanding rather than the tutorial simply vanishing (brief §21.10).
    // The tutorial itself is closed by `T6`, not here.
    await prefs.setPageConnectionDeferred(true);
    await session.rememberTutorialStep(Routes.tutorialReady);
    router.go(Routes.tutorialReady);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ChangeNotifierProvider<TutorialConnectViewModel>.value(
      value: _model,
      child: Consumer<TutorialConnectViewModel>(
        builder: (context, model, _) {
          return TutorialStepScaffold(
            step: 4,
            title: l10n.tutorialConnectTitle,
            subtitle: l10n.tutorialConnectSubtitle,
            footer: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TutorialErrorLine(error: model.submitError),
                if (model.failed)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      l10n.connectFailed,
                      style: AppText.actionS
                          .copyWith(color: AppColors.accentAlert),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (model.nothingNew)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      l10n.connectNothingNew,
                      style: AppText.actionS
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (model.wasDenied)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      l10n.oauthDenied,
                      style: AppText.actionS
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _ConnectButton(
                  icon: AppIcons.facebook,
                  label: l10n.connectFacebook,
                  filled: true,
                  busy: model.busyPlatform == PagePlatform.facebook,
                  onTap: model.isBusy
                      ? null
                      : () => _connect(PagePlatform.facebook),
                ),
                SizedBox(height: AppSpacing.sm), // 8
                _ConnectButton(
                  icon: AppIcons.instagram,
                  label: l10n.connectInstagram,
                  filled: false,
                  busy: model.busyPlatform == PagePlatform.instagram,
                  onTap: model.isBusy
                      ? null
                      : () => _connect(PagePlatform.instagram),
                ),
                SizedBox(height: AppSpacing.md), // 12
                _LaterLink(
                  label: l10n.connectLater,
                  onTap: model.isBusy ? null : _later,
                ),
              ],
            ),
            child: _Permissions(
              heading: l10n.connectPermissionsHeading,
              lines: [
                l10n.connectPermissionPages,
                l10n.connectPermissionMessages,
                l10n.connectPermissionInfo,
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The one way out of the tutorial, and it lives on this step alone.
///
/// **Deliberately quiet.** Set like the auth screens' footer link rather than
/// as a third button: it is an escape hatch, not an alternative action, and it
/// must not compete with the two controls that do what the step is for. It is
/// also the only control on the screen that is not a Meta connection, so
/// giving it a button's weight would read as a third platform.
class _LaterLink extends StatelessWidget {
  const _LaterLink({required this.label, required this.onTap});

  final String label;

  /// Null while a connection is in flight, matching the two buttons above.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Padding(
          // Vertical slop for a comfortable target without moving the label.
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            label,
            style: AppText.link.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// The `Autorisations` card: a mono heading and three ticked lines.
class _Permissions extends StatelessWidget {
  const _Permissions({required this.heading, required this.lines});

  final String heading;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.59.w), // 14
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.rule, width: AppStroke.hairline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Uppercased here for the same reason `AppTextField` uppercases its
          // label: the mono style's tracking is designed for caps, and the
          // frame sets this heading in them.
          Text(heading.toUpperCase(), style: AppText.labelMeta),
          for (final line in lines) ...[
            SizedBox(height: 2.56.w), // 10
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  // Nudged onto the first line's baseline rather than its box.
                  padding: EdgeInsets.only(top: 0.51.w),
                  child: AppIcon(AppIcons.check, size: 3.59.w), // 14
                ),
                SizedBox(width: 2.56.w), // 10
                Expanded(
                  child: Text(
                    line,
                    style: AppText.bodyS.copyWith(height: 1.32),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// One of the two connect controls.
class _ConnectButton extends StatelessWidget {
  const _ConnectButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.busy,
    required this.onTap,
  });

  final List<String> icon;
  final String label;

  /// Facebook is the white one; Instagram is outlined.
  final bool filled;

  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? AppColors.ink : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: onTap == null && !busy ? 0.5 : 1,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md), // 12
          decoration: BoxDecoration(
            color: filled ? AppColors.textPrimary : null,
            border: filled
                ? null
                : Border.all(color: AppColors.rule, width: AppStroke.hairline),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: busy
                ? [
                    SizedBox.square(
                      dimension: 4.1.w, // 16
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foreground,
                      ),
                    ),
                  ]
                : [
                    AppIcon(
                      icon,
                      size: 4.1.w, // 16
                      color: foreground,
                      filled: true,
                    ),
                    SizedBox(width: AppSpacing.sm), // 8
                    Text(
                      label,
                      // Geist Regular 13 here, not the button's Medium 14.
                      style: AppText.bodyS
                          .copyWith(height: 1.32, color: foreground),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
