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
    // Coming back to the foreground is the moment the merchant's view is most
    // likely stale — a push may have been missed, credits may have run out.
    // Screens poll on their own; this refreshes the session-level facts.
    if (state == AppLifecycleState.resumed) {
      final session = context.read<SessionViewModel>();
      if (session.isSignedIn) session.refreshProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeModel = context.watch<LocaleViewModel>();

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
