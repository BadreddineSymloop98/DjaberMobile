import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// The single `ThemeData`. Dark only — the web app has no light mode and the
/// palette is built on true black.
///
/// Material components are configured here rather than styled per screen, but
/// the app deliberately replaces the ones that make it read as Android: the
/// bottom bar is custom, not `NavigationBar` (brief §16), and icons come from
/// the web's own Heroicon set, not Material's.
class AppTheme {
  const AppTheme._();

  static ThemeData build(Locale locale) {
    final bodyFamily = AppFonts.bodyFor(locale);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.ink,
      canvasColor: AppColors.ink,
      fontFamily: bodyFamily,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.ink,
        surfaceContainer: AppColors.surface,
        surfaceContainerHigh: AppColors.surfaceHigh,
        primary: AppColors.textPrimary,
        onPrimary: AppColors.ink,
        secondary: AppColors.textSecondary,
        onSecondary: AppColors.ink,
        outline: AppColors.rule,
        outlineVariant: AppColors.ruleStrong,
        error: AppColors.accentAlert,
        onError: AppColors.ink,
      ),
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      textTheme: _textTheme(bodyFamily),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.titleL,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.ink,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.rule,
        thickness: AppStroke.hairline,
        space: AppStroke.hairline,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.rule),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        hintStyle: AppText.bodyS.copyWith(color: AppColors.textMuted),
        labelStyle: AppText.label,
        errorStyle: AppText.caption.copyWith(color: AppColors.accentAlert),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        border: _inputBorder(AppColors.rule),
        enabledBorder: _inputBorder(AppColors.rule),
        focusedBorder: _inputBorder(AppColors.ruleStrong),
        errorBorder: _inputBorder(AppColors.accentAlert),
        focusedErrorBorder: _inputBorder(AppColors.accentAlert),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: AppColors.ink,
          disabledBackgroundColor: AppColors.surfaceHigh,
          disabledForegroundColor: AppColors.textMuted,
          minimumSize: const Size.fromHeight(52),
          textStyle: AppText.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.rule),
          textStyle: AppText.button.copyWith(color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: AppText.bodyS.copyWith(color: AppColors.textPrimary),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: AppColors.scrim,
        showDragHandle: true,
        dragHandleColor: AppColors.textMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppText.titleL,
        contentTextStyle: AppText.bodyS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.rule),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: AppText.bodyS.copyWith(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.rule),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.textPrimary
              : AppColors.surfaceHigh,
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.ink
              : AppColors.textMuted,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(AppColors.rule),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.textPrimary
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.ink),
        side: const BorderSide(color: AppColors.ruleStrong),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.textPrimary,
        linearTrackColor: AppColors.surfaceHigh,
        circularTrackColor: Colors.transparent,
      ),
      iconTheme: const IconThemeData(color: AppColors.textMuted, size: 24),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        iconColor: AppColors.textMuted,
      ),
      splashColor: AppColors.overlay,
      highlightColor: AppColors.overlay,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: color, width: AppStroke.hairline),
      );

  /// Material's own slots, filled from the ramp in [AppText] so a stray
  /// `Theme.of(context).textTheme.bodyMedium` still lands on the design system
  /// instead of Roboto.
  static TextTheme _textTheme(String bodyFamily) => TextTheme(
        displayLarge: AppText.displayL,
        displayMedium: AppText.displayM,
        displaySmall: AppText.displayS,
        headlineLarge: AppText.displayM,
        headlineMedium: AppText.displayS,
        headlineSmall: AppText.titleL,
        titleLarge: AppText.titleL,
        titleMedium: AppText.title,
        titleSmall: AppText.bodyS,
        bodyLarge: AppText.body,
        bodyMedium: AppText.bodyS,
        bodySmall: AppText.caption,
        labelLarge: AppText.button,
        labelMedium: AppText.label,
        labelSmall: AppText.labelS,
      ).apply(fontFamily: bodyFamily);
}
