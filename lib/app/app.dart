import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/utils/screen.dart';
import '../l10n/gen/app_localizations.dart';
import '../presentation/theme/app_theme.dart';
import '../presentation/viewmodels/locale_view_model.dart';
import '../presentation/viewmodels/session_view_model.dart';
import 'router.dart';

/// The app root.
///
/// Watches [LocaleViewModel] so a language change rebuilds `MaterialApp` with
/// the new locale — which flips the whole layout to RTL for Arabic and swaps
/// the body font to Changa, both handled by Flutter once `locale` changes.
class DjaberApp extends StatefulWidget {
  const DjaberApp({super.key, required this.router});

  final AppRouter router;

  @override
  State<DjaberApp> createState() => _DjaberAppState();
}

class _DjaberAppState extends State<DjaberApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final session = context.read<SessionViewModel>();

    switch (state) {
      case AppLifecycleState.paused:
        // Put the app back behind the splash, so it plays on every return and
        // not only on a cold start. Done on the way out rather than on the way
        // in: by the time the merchant is looking at the screen again the
        // router has already settled on the splash, so there is no flash of
        // the previous screen.
        session.resetBoot();
      case AppLifecycleState.resumed:
        // Coming back to the foreground is the moment the merchant's view is
        // most likely stale — a push may have been missed, credits may have
        // run out. Screens poll on their own; this refreshes the
        // session-level facts.
        if (session.isSignedIn) session.refreshProfile();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // A MediaQuery *above* MaterialApp, so [Screen] is populated before the
    // theme is constructed.
    //
    // The theme now sizes buttons, icons and radii through `.w`, and it is
    // built inside `MaterialApp`'s constructor — which runs before anything
    // inside `MaterialApp.builder`. Without this the first theme is computed
    // against a zero-width screen, and since the theme is not rebuilt when the
    // metrics later arrive, it stays wrong: buttons collapse to their
    // intrinsic height for the life of the app.
    //
    // `MediaQuery.fromView` also listens for metric changes, so a rotation,
    // split screen or a font-scale change rebuilds the theme rather than
    // leaving it stale.
    return MediaQuery.fromView(
      view: View.of(context),
      child: Builder(builder: _buildApp),
    );
  }

  Widget _buildApp(BuildContext context) {
    final localeModel = context.watch<LocaleViewModel>();
    Screen.update(MediaQuery.of(context));

    return MaterialApp.router(
      title: 'Djaber.ai',
      debugShowCheckedModeBanner: false,
      routerConfig: widget.router.router,
      theme: AppTheme.build(localeModel.locale),
      darkTheme: AppTheme.build(localeModel.locale),
      themeMode: ThemeMode.dark,
      locale: localeModel.locale,
      supportedLocales: AppLanguage.values.map((l) => l.locale),
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Runs above every route: keeps `Screen` current so the `.h` / `.w`
      // extension is populated before any screen builds, and clamps the OS
      // text scale so a 2.0 system font size cannot destroy dense layouts.
      builder: (context, child) => ScreenInitializer(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
