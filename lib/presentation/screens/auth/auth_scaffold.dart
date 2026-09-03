import 'package:flutter/material.dart';

import '../../../core/extensions/responsive_extension.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/djaber_logo.dart';

/// The shared shape of every auth screen, from Figma frames `05`–`08`.
///
/// All four are the same column: logo, a gap, a Syne heading, a subtitle, then
/// the form, with a footer pinned to the bottom. Building it once keeps the
/// four from drifting apart — which is exactly what happened on the web, where
/// the logo exists in five pasted copies.
///
/// **The footer sits outside the scroll view, not inside it.** The first
/// attempt put the whole column in a `SingleChildScrollView` with a `Spacer`
/// pushing the footer down; a scroll view gives its child unbounded height, a
/// `Spacer` needs a bounded one, and the screen rendered completely black. The
/// arrangement below also behaves better: the form scrolls under a footer that
/// stays put, and the keyboard shortens the scrolling area rather than pushing
/// the footer off screen.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.footer,
  });

  final String title;
  final String subtitle;

  /// The form: fields, button, and anything under them.
  final List<Widget> children;

  /// The line pinned to the bottom of the screen.
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final gutter = EdgeInsets.symmetric(horizontal: AppSpacing.gutter);

    return Scaffold(
      backgroundColor: AppColors.ink,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: gutter.copyWith(top: 3.32.h, bottom: 3.32.h), // 28
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: DjaberLogo(size: 8.72.w), // 34
                    ),
                    SizedBox(height: 6.64.h), // 56
                    Text(title, style: AppText.displayL),
                    SizedBox(height: AppSpacing.lg),
                    Text(subtitle, style: AppText.bodyM),
                    SizedBox(height: 4.27.h), // 36
                    ...children,
                  ],
                ),
              ),
            ),
            Padding(
              padding: gutter.copyWith(bottom: 3.32.h), // 28
              child: footer,
            ),
          ],
        ),
      ),
    );
  }
}

/// The two-part line at the bottom of each auth screen: a muted question,
/// then a link.
class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Wraps rather than overflows: these strings change length a lot between
    // French, English and Arabic, and the first draft of the onboarding footer
    // ran off a 390 frame for exactly this reason.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 1.54.w, // 6
      children: [
        Text(question, style: AppText.bodyS),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Text(action, style: AppText.link),
        ),
      ],
    );
  }
}

/// The one loud control on the screen — white on black.
///
/// The themed [FilledButton] rather than a bespoke widget: the Figma
/// component's pressed state is an opacity drop, which the theme's overlay
/// already produces.
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      FilledButton(onPressed: onPressed, child: Text(label));
}

/// Builds the three field messages once per screen from `L10n`.
AppFieldMessages fieldMessages({
  required String required,
  required String invalidEmail,
  required String tooShort,
}) =>
    AppFieldMessages(
      required: required,
      invalidEmail: invalidEmail,
      tooShort: tooShort,
    );
