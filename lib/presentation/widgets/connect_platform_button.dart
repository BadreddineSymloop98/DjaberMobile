import 'package:flutter/material.dart';

import '../../core/extensions/responsive_extension.dart';
import '../../data/models/connected_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

/// *Connecter Facebook* / *Connecter Instagram* — the pair `T5` and `13 —
/// Connecter une page` draw: Geist Regular 13 with a 16px brand mark, white
/// for Facebook, hairline-outlined for Instagram. Two loud controls on purpose:
/// there are genuinely two destinations, not a primary and a secondary.
class ConnectPlatformButton extends StatelessWidget {
  const ConnectPlatformButton({
    super.key,
    required this.platform,
    required this.label,
    required this.busy,
    required this.onTap,
  });

  final PagePlatform platform;
  final String label;

  /// This platform's connection is under way.
  final bool busy;

  /// Null while any connection is in flight.
  final VoidCallback? onTap;

  bool get _filled => platform == PagePlatform.facebook;

  @override
  Widget build(BuildContext context) {
    final foreground = _filled ? AppColors.ink : AppColors.textPrimary;

    return Semantics(
      button: true,
      enabled: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: onTap == null && !busy ? 0.5 : 1,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: _filled ? AppColors.textPrimary : null,
              border: _filled ? null : Border.all(color: AppColors.rule, width: AppStroke.hairline),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: busy
                  ? [
                      SizedBox.square(
                        dimension: 4.1.w,
                        child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
                      ),
                    ]
                  : [
                      AppIcon(
                        platform == PagePlatform.instagram ? AppIcons.instagram : AppIcons.facebook,
                        size: 4.1.w, // 16
                        color: foreground,
                        filled: true,
                      ),
                      SizedBox(width: AppSpacing.sm), // 8
                      Flexible(
                        child: Text(
                          label,
                          style: AppText.bodyS.copyWith(height: 1.32, color: foreground),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
