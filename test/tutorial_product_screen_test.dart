import 'package:djaber_mobile/data/repositories/product_repository.dart';
import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:djaber_mobile/presentation/screens/tutorial/tutorial_product_screen.dart';
import 'package:djaber_mobile/presentation/theme/app_colors.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:djaber_mobile/presentation/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/auth_host.dart';

/// The `T3 — Produit` form on screen: the six fields, and when each rule shows.
void main() {
  late SessionViewModel session;
  late ProductRepository products;

  setUp(() async {
    session = await sessionForTest();
    products = ProductRepository(api: apiForTest());
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
      Provider<ProductRepository>.value(
        value: products,
        child: authHost(const TutorialProductScreen(), session, locale: locale),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('carries the six fields the frame does', (tester) async {
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    expect(find.byType(AppTextField), findsNWidgets(6));
    for (final label in [
      l10n.productName,
      l10n.productSku,
      l10n.productDescription,
      l10n.productCostPrice,
      l10n.productSellingPrice,
      l10n.productQuantity,
    ]) {
      expect(find.textContaining(label.toUpperCase()), findsOneWidget);
    }
    expect(find.text(l10n.tutorialProductSubmit), findsOneWidget);
  });

  testWidgets('a placeholder is muted, well below entered text', (tester) async {
    await pump(tester);

    // The Figma Text Field sets its value text in `text/muted`. At the
    // brighter `text/secondary` a placeholder reads as a filled value — on
    // sign-up, "Jane" and "Doe" looked like autofilled content.
    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.decoration!.hintStyle!.color, AppColors.textMuted);
    // And entered text stays at the top of the ramp, so the two cannot be
    // confused.
    expect(field.style!.color, AppColors.textPrimary);
  });

  testWidgets('sits at step 2 of the wizard', (tester) async {
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));
    expect(find.text(l10n.tutorialStepCounter(2, 4)), findsOneWidget);
  });

  testWidgets('only the description is optional', (tester) async {
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    final fields = tester.widgetList<AppTextField>(find.byType(AppTextField));
    final optional = fields.where((f) => !f.isRequired).toList();
    expect(optional.length, 1);
    expect(optional.single.label, l10n.productDescription);
  });

  testWidgets('submitting an empty form reveals every rule at once',
      (tester) async {
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    await tester.tap(find.text(l10n.tutorialProductSubmit));
    await tester.pumpAndSettle();

    // Five required fields, all complaining; the description stays quiet.
    expect(find.text(l10n.productErrRequired), findsNWidgets(5));
  });

  testWidgets('a zero price is "greater than 0", not "required"',
      (tester) async {
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    await tester.enterText(find.byType(TextField).at(3), '0');
    await tester.pumpAndSettle();

    // The distinction matters: the field visibly contains a value, so
    // "required" would read as a bug.
    expect(find.text(l10n.productErrMustBePositive), findsWidgets);
  });

  testWidgets('a selling price below cost is caught before the round trip',
      (tester) async {
    await pump(tester);
    final l10n = await L10n.delegate.load(const Locale('fr'));

    await tester.enterText(find.byType(TextField).at(3), '1000'); // cost
    await tester.enterText(find.byType(TextField).at(4), '900'); // selling
    await tester.pumpAndSettle();

    expect(find.text(l10n.productErrBelowCost), findsOneWidget);

    // And it clears as soon as the cost drops below it — proving the field
    // re-evaluates when its *neighbour* changes, not only when it does.
    await tester.enterText(find.byType(TextField).at(3), '800');
    await tester.pumpAndSettle();
    expect(find.text(l10n.productErrBelowCost), findsNothing);
  });

  for (final size in const [Size(320, 640), Size(360, 740)]) {
    testWidgets('renders without overflow at ${size.width.toInt()} wide',
        (tester) async {
      await pump(tester, size: size);
      expect(tester.takeException(), isNull);
      expect(find.byType(AppTextField), findsNWidgets(6));
    });
  }

  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets('renders in ${locale.languageCode}', (tester) async {
      await pump(tester, size: const Size(320, 640), locale: locale);
      expect(tester.takeException(), isNull);
      final l10n = await L10n.delegate.load(locale);
      expect(find.text(l10n.tutorialProductSubmit), findsOneWidget);
    });
  }
}
