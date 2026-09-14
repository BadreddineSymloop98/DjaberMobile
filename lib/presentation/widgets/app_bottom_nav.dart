import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/extensions/responsive_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

/// One destination in the bottom nav.
class NavDestination {
  const NavDestination({
    required this.icon,
    required this.label,
    required this.route,
  });

  final List<String> icon;
  final String label;
  final String route;
}

/// `Bottom nav` (node `134:791`) and its `Nav Item` (node `34:21`).
///
/// **Custom, not Material's `NavigationBar`.** Brief §16 names the stock nav
/// bar as one of the four things that make an app read as Android, and the
/// frame draws something Material will not: a 2px indicator *above* the item,
/// no ripple, no pill, no label animation.
///
/// The component's own note: *"Active carries the indicator bar and
/// text/primary; inactive drops to text/muted. The count badge is hidden by
/// default — turn it back on where a live number matters."* The badge is not
/// built; when the queue's count earns one, it belongs here.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<NavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    // The frame's 20 of bottom padding is its allowance for the system's own
    // furniture. On a handset that reports a real inset — a gesture bar — the
    // inset replaces it rather than stacking on top of it, which would push
    // the labels a finger's width off the bottom of the screen.
    final inset = MediaQuery.viewPaddingOf(context).bottom;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.ink,
        border: Border(
          top: BorderSide(color: AppColors.rule, width: AppStroke.hairline),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: math.max(inset, AppSpacing.gutter)),
        child: Row(
          // Top-aligned: the active item is 2px taller than the rest because
          // of its indicator, and the frame lets it be — the icons stay on one
          // line and the bar does not grow.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, destination) in destinations.indexed)
              Expanded(
                child: _NavItem(
                  destination: destination,
                  active: index == currentIndex,
                  onTap: () => onSelect(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.active,
    required this.onTap,
  });

  final NavDestination destination;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = active ? AppColors.textPrimary : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 24x2 in `paper`, and only on the active item. Kept in the tree at
          // zero opacity on the others so tapping between tabs does not shift
          // the icons by two pixels.
          Opacity(
            opacity: active ? 1 : 0,
            child: Container(
              width: 6.15.w, // 24
              height: 2,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.md), // 12
          AppIcon(destination.icon, size: 5.13.w, color: tint), // 20
          SizedBox(height: AppSpacing.xs), // 4
          Text(
            destination.label,
            style: AppText.labelMicro.copyWith(color: tint),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
        ],
      ),
    );
  }
}
