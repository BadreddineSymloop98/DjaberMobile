import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/widgets/exit_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_host.dart';

/// Two presses to leave, and a line explaining the first.
///
/// The app navigates with `go`, so the stack is only ever one deep and back
/// had nothing to pop on **every** top-level screen — Android took it as
/// "close the app". Defensible on home, which is the root; not defensible
/// silently, and not defensible at all on a screen reached from somewhere
/// else, where a merchant presses back expecting to go back and the app
/// vanishes with whatever they were doing.
void main() {
  late SessionViewModel session;
  late List<MethodCall> platform;

  setUp(() async {
    session = await sessionForTest();
    platform = [];
    // `SystemNavigator.pop` is the real exit — there is nothing in the Flutter
    // stack to pop, which is the whole reason this widget exists. Recorded
    // rather than performed.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      platform.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    session.dispose();
  });

  Future<L10n> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      authHost(
        const ExitGuard(child: Scaffold(body: Center(child: Text('screen')))),
        session,
      ),
    );
    await tester.pumpAndSettle();
    return L10n.delegate.load(const Locale('fr'));
  }

  /// The system back gesture, as the framework delivers it.
  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pump();
  }

  bool exited() => platform.any((c) => c.method == 'SystemNavigator.pop');

  testWidgets('the first press explains itself instead of closing the app',
      (tester) async {
    final l10n = await pump(tester);

    await back(tester);

    expect(exited(), isFalse, reason: 'the app must still be here');
    expect(find.text(l10n.exitHint), findsOneWidget);
    expect(find.text('screen'), findsOneWidget);
  });

  testWidgets('the second press leaves', (tester) async {
    await pump(tester);

    await back(tester);
    await back(tester);

    expect(exited(), isTrue);
  });

  testWidgets('a press after the window has passed re-arms rather than '
      'leaving — a stray tap minutes ago is not consent', (tester) async {
    final l10n = await pump(tester);

    await back(tester);
    expect(exited(), isFalse);

    // Past the two-second window.
    await tester.pump(ExitGuard.window + const Duration(seconds: 1));
    await back(tester);

    expect(exited(), isFalse, reason: 'the first press had expired');
    expect(find.text(l10n.exitHint), findsWidgets);
  });

  testWidgets('the hint is localised', (tester) async {
    await tester.pumpWidget(
      authHost(
        const ExitGuard(child: Scaffold(body: SizedBox.shrink())),
        session,
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();
    await back(tester);

    final ar = await L10n.delegate.load(const Locale('ar'));
    expect(find.text(ar.exitHint), findsOneWidget);
    expect(ar.exitHint, matches(RegExp(r'[؀-ۿ]')));
  });
}
