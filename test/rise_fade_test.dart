import 'package:djaber_mobile/presentation/widgets/rise_fade.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// [RiseFade] is the app's single entrance motion — the splash logo and every
/// onboarding slide go through it — so its start state, its latch and its
/// reduced-motion behaviour are all load-bearing.
void main() {
  /// Reads the opacity and vertical offset currently applied to the child.
  ({double opacity, double dy}) readState(WidgetTester tester) {
    final opacity = tester.widget<FadeTransition>(
      find.byType(FadeTransition),
    );
    final transform = tester.widget<Transform>(find.byType(Transform));
    return (
      opacity: opacity.opacity.value,
      dy: transform.transform.getTranslation().y,
    );
  }

  Widget host(Widget child, {bool disableAnimations = false}) => MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: child,
        ),
      );

  testWidgets('starts hidden and below, ends visible and in place',
      (tester) async {
    await tester.pumpWidget(
      host(const RiseFade(offset: 24, child: SizedBox(width: 10, height: 10))),
    );

    final start = readState(tester);
    expect(start.opacity, 0);
    expect(start.dy, 24, reason: 'starts one full offset below its resting place');

    await tester.pumpAndSettle();

    final end = readState(tester);
    expect(end.opacity, 1);
    expect(end.dy, 0);
  });

  testWidgets('rises upward — the offset only ever decreases', (tester) async {
    await tester.pumpWidget(
      host(const RiseFade(offset: 24, child: SizedBox(width: 10, height: 10))),
    );

    var previous = readState(tester).dy;
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 80));
      final current = readState(tester).dy;
      expect(current, lessThanOrEqualTo(previous));
      previous = current;
    }
  });

  testWidgets('holds hidden until animate turns true', (tester) async {
    await tester.pumpWidget(
      host(const RiseFade(animate: false, child: SizedBox(width: 10, height: 10))),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(readState(tester).opacity, 0);

    await tester.pumpWidget(
      host(const RiseFade(child: SizedBox(width: 10, height: 10))),
    );
    await tester.pumpAndSettle();
    expect(readState(tester).opacity, 1);
  });

  testWidgets('latches — going back to animate:false stays revealed',
      (tester) async {
    await tester.pumpWidget(
      host(const RiseFade(child: SizedBox(width: 10, height: 10))),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      host(const RiseFade(animate: false, child: SizedBox(width: 10, height: 10))),
    );
    await tester.pump();

    // Onboarding depends on this: swiping back to a slide already seen must
    // show it immediately rather than replaying the entrance.
    expect(readState(tester).opacity, 1);
  });

  testWidgets('respects a delay before starting', (tester) async {
    await tester.pumpWidget(
      host(
        const RiseFade(
          delay: Duration(milliseconds: 200),
          child: SizedBox(width: 10, height: 10),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 150));
    expect(readState(tester).opacity, 0, reason: 'still waiting out the delay');

    await tester.pumpAndSettle();
    expect(readState(tester).opacity, 1);
  });

  testWidgets('shows the end state outright when the OS disables animations',
      (tester) async {
    await tester.pumpWidget(
      host(
        const RiseFade(child: SizedBox(key: Key('child'), width: 10, height: 10)),
        disableAnimations: true,
      ),
    );

    // No transition wrappers at all — the child is rendered directly, so it is
    // never invisible for someone who asked for reduced motion.
    expect(find.byType(FadeTransition), findsNothing);
    expect(find.byKey(const Key('child')), findsOneWidget);
  });

  testWidgets('a pending delay does not fire after dispose', (tester) async {
    await tester.pumpWidget(
      host(
        const RiseFade(
          delay: Duration(milliseconds: 300),
          child: SizedBox(width: 10, height: 10),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    // Popping the screen mid-delay is normal; the timer must not outlive it.
    await tester.pumpWidget(host(const SizedBox()));
    await tester.pump(const Duration(milliseconds: 500));
    // Reaching here without a "ticker was disposed" error is the assertion.
  });
}
