import 'package:flutter/material.dart';

import '../../core/extensions/responsive_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A stand-in for a screen that has not been built.
///
/// Deliberately not a design: it exists so the router, the redirect policy and
/// the deep-link path are runnable and testable before any screen exists. Each
/// one is replaced by the real screen as it is built, and this file is deleted
/// when the last route is filled in.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, this.detail});

  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.gutter),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('NOT BUILT', style: AppText.label),
                SizedBox(height: AppSpacing.sm),
                Text(title, style: AppText.displayS, textAlign: TextAlign.center),
                if (detail != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    detail!,
                    style: AppText.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: AppSpacing.xxl),
                // Proves the responsive extension is live at runtime.
                Text(
                  '${Screenreadout.size}  ·  50.w = ${50.w.toStringAsFixed(1)}'
                  '  ·  10.h = ${10.h.toStringAsFixed(1)}',
                  style: AppText.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps the five bottom-nav destinations until the custom nav bar is built.
///
/// The real bar is a custom widget, not Material's `NavigationBar` — brief §16
/// names the stock nav as one of the four things that make the app read as
/// Android.
class PlaceholderShell extends StatelessWidget {
  const PlaceholderShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        height: 7.58.h, // 64
        decoration: const BoxDecoration(
          color: AppColors.ink,
          border: Border(top: BorderSide(color: AppColors.rule)),
        ),
        alignment: Alignment.center,
        child: Text('CUSTOM NAV — NOT BUILT', style: AppText.labelS),
      ),
    );
  }
}

/// A tiny helper so the placeholder can print live screen metrics without
/// pulling `Screen` into the widget's imports.
class Screenreadout {
  const Screenreadout._();
  static String get size =>
      '${100.w.toStringAsFixed(0)}×${100.h.toStringAsFixed(0)}';
}
