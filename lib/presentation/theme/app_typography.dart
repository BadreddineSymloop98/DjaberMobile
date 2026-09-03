import 'package:flutter/material.dart';

import '../../core/extensions/responsive_extension.dart';
import 'app_colors.dart';

/// Font families, matching the web's `@import` in `src/app/globals.css`.
///
/// Bundled as static instances under `assets/fonts/` rather than fetched at
/// runtime: the market is Algerian mobile data on low-end Android, and a
/// first-run font download means an app that opens unstyled or not at all.
class AppFonts {
  const AppFonts._();

  /// Display face. The web sets `fontFamily: 'Syne'` inline on page headings
  /// across `src/`. Headings only — Syne has no tabular figures.
  static const display = 'Syne';

  /// Body, titles, and every number. Weights 400–700 bundled.
  static const sans = 'Geist';

  /// Uppercase labels. The web's `.label` primitive: 11px, 0.16em tracking.
  static const mono = 'JetBrainsMono';

  /// Arabic. The web binds it to `html[lang="ar"]`.
  static const arabic = 'Changa';

  /// The family to render body copy in for a given locale.
  static String bodyFor(Locale locale) =>
      locale.languageCode == 'ar' ? arabic : sans;

  /// The web overrides Syne with Changa for Arabic headings, so display copy
  /// follows the same rule rather than falling back to a Latin-only face.
  static String displayFor(Locale locale) =>
      locale.languageCode == 'ar' ? arabic : display;
}

/// The type ramp, as settled in brief §15.
///
/// Sizes go through `.sp`, so they scale against the 390dp Figma frame and stay
/// readable on a 320dp handset without ballooning on a tablet.
class AppText {
  const AppText._();

  // ---- Display — Syne Bold, headings only ----

  /// 30 — auth screen headings.
  static TextStyle get displayL => TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 30.sp,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.6,
        color: AppColors.textPrimary,
      );

  /// 27 — onboarding headings.
  static TextStyle get displayM => TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 27.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  /// 20 — the wordmark and section headings.
  static TextStyle get displayS => TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
      );

  // ---- Titles and body — Geist ----

  /// 17 — screen titles, product names.
  static TextStyle get titleL => TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  /// 15 — list row primary line.
  static TextStyle get title => TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppColors.textPrimary,
      );

  /// 15 — message text, paragraphs.
  static TextStyle get body => TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.textPrimary,
      );

  /// 13 — list row secondary line, helper text.
  static TextStyle get bodyS => TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textSecondary,
      );

  /// 12 — captions, timestamps.
  static TextStyle get caption => TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: AppColors.textMuted,
      );

  // ---- Numerals — Geist, never Syne ----

  /// 28 — a KPI figure.
  static TextStyle get numeralL => TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        height: 1.1,
        letterSpacing: -0.5,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: AppColors.textPrimary,
      );

  /// 17 — a quantity or an amount in a row.
  static TextStyle get numeralM => TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: AppColors.textPrimary,
      );

  // ---- Labels — JetBrains Mono, uppercase ----
  //
  // The web's `.label`: 11px, 0.16em tracking, `--mute`.

  static TextStyle get label => TextStyle(
        fontFamily: AppFonts.mono,
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 11.sp * 0.16,
        height: 1.2,
        color: AppColors.textMuted,
      );

  static TextStyle get labelStrong => label.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// 10 — a nav item label or a badge.
  static TextStyle get labelS => TextStyle(
        fontFamily: AppFonts.mono,
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 10.sp * 0.12,
        height: 1.2,
        color: AppColors.textMuted,
      );

  /// 15 — the label inside a primary button.
  static TextStyle get button => TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.ink,
      );
}
