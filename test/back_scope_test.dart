import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/widgets/back_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_host.dart';

/// "Tap again to leave" only where back really closes the app.
///
/// A [BackScope.root] is the only place the hint can show: nothing is below
/// it and the router declared no parent. Every other scope pops or goes to its
/// fallback, and an active [BackIntercept] (unsaved work) is asked first.
void main() {
  late SessionViewModel session;
  late List<MethodCall> platform;

  setUp(() async {
    session = await sessionForTest();
    platform = [];
    // `SystemNavigator.pop` is the real exit. Recorded rather than performed.
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

  Future<L10n> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(authHost(screen, session));
    await tester.pumpAndSettle();
    return L10n.delegate.load(const Locale('fr'));
  }

  /// The system back gesture, as the framework delivers it.
  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pump();
  }

  bool exited() => platform.any((c) => c.method == 'SystemNavigator.pop');

  const root = BackScope.root(
    child: Scaffold(body: Center(child: Text('screen'))),
  );

  testWidgets('on a root, the first press explains itself instead of closing',
      (tester) async {
    final l10n = await pump(tester, root);

    await back(tester);

    expect(exited(), isFalse, reason: 'the app must still be here');
    expect(find.text(l10n.exitHint), findsOneWidget);
    expect(find.text('screen'), findsOneWidget);
  });

  testWidgets('on a root, the second press leaves', (tester) async {
    await pump(tester, root);

    await back(tester);
    await back(tester);

    expect(exited(), isTrue);
  });

  testWidgets('a press after the window has passed re-arms rather than leaving',
      (tester) async {
    final l10n = await pump(tester, root);

    await back(tester);
    expect(exited(), isFalse);

    await tester.pump(BackScope.exitWindow + const Duration(seconds: 1));
    await back(tester);

    expect(exited(), isFalse, reason: 'the first press had expired');
    expect(find.text(l10n.exitHint), findsWidgets);
  });

  testWidgets('a pushed screen pops back without any hint', (tester) async {
    final l10n = await pump(
      tester,
      Builder(
        builder: (context) => BackScope.root(
          child: Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BackScope(
                    fallback: '/unused',
                    child: Scaffold(body: Text('detail')),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsOneWidget);

    await back(tester);
    await tester.pumpAndSettle();

    expect(find.text('detail'), findsNothing);
    expect(find.text('open'), findsOneWidget);
    expect(find.text(l10n.exitHint), findsNothing);
    expect(exited(), isFalse);
  });

  testWidgets('unsaved work is asked about first, and a refusal keeps the '
      'screen', (tester) async {
    var asked = 0;
    final l10n = await pump(
      tester,
      BackScope.root(
        child: BackIntercept(
          active: true,
          onBack: () {
            asked++;
            return false;
          },
          child: const Scaffold(body: Text('form')),
        ),
      ),
    );

    await back(tester);
    await tester.pumpAndSettle();

    expect(asked, 1);
    expect(find.text('form'), findsOneWidget);
    expect(find.text(l10n.exitHint), findsNothing);
    expect(exited(), isFalse);
  });

  testWidgets('the hint is localised', (tester) async {
    await tester.pumpWidget(
      authHost(
        const BackScope.root(child: Scaffold(body: SizedBox.shrink())),
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
