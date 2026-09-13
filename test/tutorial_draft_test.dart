import 'package:djaber_mobile/app/routes.dart';
import 'package:djaber_mobile/data/models/agent.dart';
import 'package:djaber_mobile/data/repositories/agent_repository.dart';
import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/tutorial/tutorial_agent_screen.dart';
import 'package:djaber_mobile/presentation/screens/tutorial/tutorial_product_screen.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/tutorial_agent_view_model.dart';
import 'package:djaber_mobile/presentation/viewmodels/tutorial_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';

/// Leaving the app mid-step must not cost the merchant what they typed.
///
/// On return the splash replays and the router swaps the step out for it, so
/// the step comes back as a brand-new screen — changing the phone's language
/// in Settings is the everyday way to hit this. These tests make the same swap
/// directly: show the step, replace it with nothing, show it again.
void main() {
  late SessionViewModel session;
  late TutorialViewModel tutorial;

  setUp(() async {
    session = await sessionForTest();
    tutorial = TutorialViewModel();
  });

  tearDown(() {
    tutorial.dispose();
    session.dispose();
  });

  /// Hosts [step] behind a switch, so a test can tear it down and bring it
  /// back the way the splash detour does.
  Future<ValueNotifier<bool>> pump(WidgetTester tester, Widget step) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final shown = ValueNotifier(true);
    addTearDown(shown.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProductRepository>.value(
            value: ProductRepository(api: apiForTest()),
          ),
          Provider<AgentRepository>.value(
            value: AgentRepository(api: apiForTest()),
          ),
          ChangeNotifierProvider<TutorialViewModel>.value(value: tutorial),
        ],
        child: authHost(
          ValueListenableBuilder<bool>(
            valueListenable: shown,
            builder: (_, visible, _) =>
                visible ? step : const SizedBox.shrink(),
          ),
          session,
          locale: const Locale('fr'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return shown;
  }

  /// The splash detour: the step is torn down, then built again from scratch.
  Future<void> leaveAndReturn(
    WidgetTester tester,
    ValueNotifier<bool> shown,
  ) async {
    shown.value = false;
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);

    shown.value = true;
    await tester.pumpAndSettle();
  }

  String textAt(WidgetTester tester, int index) => tester
      .widget<TextField>(find.byType(TextField).at(index))
      .controller!
      .text;

  testWidgets('T3 keeps all six values when the step is rebuilt',
      (tester) async {
    final shown = await pump(tester, const TutorialProductScreen());

    const typed = ['Sac cuir', 'SAC-01', 'Cuir véritable', '1000', '1500', '12'];
    for (var i = 0; i < typed.length; i++) {
      await tester.enterText(find.byType(TextField).at(i), typed[i]);
    }
    await tester.pumpAndSettle();

    await leaveAndReturn(tester, shown);

    for (var i = 0; i < typed.length; i++) {
      expect(textAt(tester, i), typed[i], reason: 'field $i was wiped');
    }
  });

  testWidgets('T4 keeps the name, instructions and personality',
      (tester) async {
    final shown = await pump(tester, const TutorialAgentScreen());
    final l10n = await L10n.delegate.load(const Locale('fr'));

    await tester.enterText(find.byType(TextField).at(0), 'Sara');
    await tester.enterText(find.byType(TextField).at(1), 'Toujours vouvoyer.');
    final casual = find.text(l10n.agentToneCasual);
    await tester.ensureVisible(casual);
    await tester.tap(casual);
    await tester.pumpAndSettle();

    await leaveAndReturn(tester, shown);

    expect(textAt(tester, 0), 'Sara');
    expect(textAt(tester, 1), 'Toujours vouvoyer.');
    final model = tester
        .element(find.byType(TextField).first)
        .read<TutorialAgentViewModel>();
    expect(model.personality, AgentPersonality.casual);
  });

  testWidgets('a step opened with no draft starts empty', (tester) async {
    await pump(tester, const TutorialProductScreen());

    for (var i = 0; i < 6; i++) {
      expect(textAt(tester, i), isEmpty);
    }
  });

  test('a spent or finished draft does not come back', () {
    tutorial.saveDraft(Routes.tutorialProduct, {'name': 'Sac cuir'});
    tutorial.saveDraft(Routes.tutorialAgent, {'name': 'Sara'});
    expect(tutorial.draftFor(Routes.tutorialProduct), {'name': 'Sac cuir'});

    // A step that went through drops its own draft...
    tutorial.clearDraft(Routes.tutorialProduct);
    expect(tutorial.draftFor(Routes.tutorialProduct), isEmpty);
    expect(tutorial.draftFor(Routes.tutorialAgent), {'name': 'Sara'});

    // ...and the end of the tutorial drops the rest, so a second run starts
    // clean.
    tutorial.reset();
    expect(tutorial.draftFor(Routes.tutorialAgent), isEmpty);
  });
}
