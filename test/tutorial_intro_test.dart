import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/tutorial/tutorial_intro_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_typography.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/widgets/checklist_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_host.dart';

/// `T1a` – `T1c`, the tutorial intro.
///
/// The three pages differ in exactly three ways — the copy, which steps are
/// lit, and the last one's button label — so those are what is pinned here.
/// Tapping the *last* button is not exercised in this file: it calls
/// `context.go`, which needs the real router, and lives in
/// `tutorial_redirect_test.dart` instead.
void main() {
  late SessionViewModel session;

  setUp(() async {
    session = await sessionForTest();
  });

  tearDown(() => session.dispose());

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    Locale locale = const Locale('fr'),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      authHost(const TutorialIntroScreen(), session, locale: locale),
    );
    await tester.pumpAndSettle();
  }

  /// The rows actually on screen — a `PageView` keeps neighbouring pages in
  /// the tree, so an unfiltered `byType` would count them too.
  List<ChecklistRow> visibleRows(WidgetTester tester) => tester
      .widgetList<ChecklistRow>(find.byType(ChecklistRow).hitTestable())
      .toList();

  Future<void> tapNext(WidgetTester tester) async {
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  testWidgets('T1a shows the four steps and the welcome copy', (tester) async {
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    expect(find.text(l10n.tutorialWelcomeTitle), findsOneWidget);
    expect(find.text(l10n.tutorialWelcomeBody), findsOneWidget);

    // All four steps, in the tutorial's own order — mode before product.
    final rows = visibleRows(tester);
    expect(rows.map((r) => r.label).toList(), [
      l10n.tutorialStepMode,
      l10n.tutorialStepProduct,
      l10n.tutorialStepAgent,
      l10n.tutorialStepPage,
    ]);
    expect(rows.map((r) => r.step).toList(), [1, 2, 3, 4]);
  });

  testWidgets('T1a lights every step; T1b lights 1-2; T1c lights 3-4',
      (tester) async {
    await pump(tester);

    // T1a is the overview: nothing dimmed.
    expect(visibleRows(tester).where((r) => r.dimmed), isEmpty);

    await tapNext(tester);
    expect(
      visibleRows(tester).where((r) => r.dimmed).map((r) => r.step).toList(),
      [3, 4],
    );

    await tapNext(tester);
    expect(
      visibleRows(tester).where((r) => r.dimmed).map((r) => r.step).toList(),
      [1, 2],
    );
  });

  testWidgets('the button reads Suivant until the last page, then Commencer',
      (tester) async {
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    expect(find.text(l10n.commonNext), findsOneWidget);
    await tapNext(tester);
    expect(find.text(l10n.commonNext), findsOneWidget);
    await tapNext(tester);
    expect(find.text(l10n.commonStart), findsOneWidget);
    expect(find.text(l10n.commonNext), findsNothing);
  });

  testWidgets('Passer stays on every page, including the last', (tester) async {
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    // Unlike the install onboarding, which hides its skip on the final slide.
    // The frames keep it on all three.
    expect(find.text(l10n.commonSkip), findsOneWidget);
    await tapNext(tester);
    expect(find.text(l10n.commonSkip), findsOneWidget);
    await tapNext(tester);
    expect(find.text(l10n.commonSkip), findsOneWidget);
  });

  testWidgets('Passer is sentence case, not the onboarding uppercase',
      (tester) async {
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    // The frames set it in `Title` at `text/muted`; the install onboarding's
    // skip is uppercase mono. Getting these the right way round is the point.
    final skip = tester.widget<Text>(find.text(l10n.commonSkip));
    expect(skip.data, isNot(l10n.commonSkip.toUpperCase()));
    expect(skip.style!.fontFamily, AppFonts.sans);
    expect(skip.style!.fontSize, AppText.title.fontSize);
  });

  testWidgets('the body is the file Body style, 13/1.32, not bodyS 1.4',
      (tester) async {
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    final body = tester.widget<Text>(find.text(l10n.tutorialWelcomeBody));
    expect(body.style!.height, 1.32);
    expect(body.style!.fontSize, 13);
    expect(tutorialBodyStyle.height, 1.32);
  });

  testWidgets('the heading matches the file Display/M line height',
      (tester) async {
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    final title = tester.widget<Text>(find.text(l10n.tutorialWelcomeTitle));
    // Display/M is Syne Bold 27 at 1.15 in the Figma file. Code had 1.2.
    expect(title.style!.fontFamily, AppFonts.display);
    expect(title.style!.fontSize, 27);
    expect(title.style!.height, 1.15);
  });

  for (final size in const [Size(320, 640), Size(360, 740), Size(411, 914)]) {
    testWidgets('renders without overflow at ${size.width.toInt()} wide',
        (tester) async {
      await pump(tester, size: size);
      expect(tester.takeException(), isNull);
      expect(find.byType(ChecklistBox), findsOneWidget);
    });
  }

  for (final locale in const [Locale('fr'), Locale('en'), Locale('ar')]) {
    testWidgets('renders in ${locale.languageCode} without overflow',
        (tester) async {
      await pump(tester, size: const Size(320, 640), locale: locale);
      expect(tester.takeException(), isNull);

      final l10n = await L10n.delegate.load(locale);
      expect(find.text(l10n.tutorialWelcomeTitle), findsOneWidget);
      expect(find.text(l10n.tutorialStepMode), findsOneWidget);
    });
  }

  testWidgets('the step number is not mirrored under RTL', (tester) async {
    await pump(tester, locale: const Locale('ar'));

    // Numerals keep their reading order in Arabic (brief §21.8), so the ring
    // forces LTR regardless of the surrounding direction.
    final numeral = find.descendant(
      of: find.byType(ChecklistRow).first,
      matching: find.byType(Directionality),
    );
    expect(
      tester.widget<Directionality>(numeral.first).textDirection,
      TextDirection.ltr,
    );
  });
}
