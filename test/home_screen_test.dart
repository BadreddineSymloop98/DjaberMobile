import 'package:djaber_mobile/data/models/user.dart';
import 'package:djaber_mobile/presentation/screens/home/home_screen.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_host.dart';

/// The home screen is a stub, but the thing it proves is not: that the session
/// survived sign-in and carries a usable name.
void main() {
  late SessionViewModel session;

  setUp(() async => session = await sessionForTest());
  tearDown(() => session.dispose());

  void sizeTo(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('greets the signed-in merchant by first name', (tester) async {
    sizeTo(tester, const Size(411, 914));
    session.debugSetUser(const User(
      id: 'u-1',
      email: 'amina@shop.dz',
      firstName: 'Amina',
      lastName: 'Benali',
    ));

    await tester.pumpWidget(authHost(const HomeScreen(), session));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Bon retour, Amina'), findsOneWidget);
  });

  testWidgets('falls back to the email when there is no first name',
      (tester) async {
    sizeTo(tester, const Size(411, 914));
    session.debugSetUser(
      const User(id: 'u-2', email: 'boutique.oran@shop.dz'),
    );

    await tester.pumpWidget(authHost(const HomeScreen(), session));
    await tester.pumpAndSettle();

    // "Bon retour, " with nothing after it reads as a bug.
    expect(find.text('Bon retour, boutique.oran'), findsOneWidget);
  });

  testWidgets('renders without a user rather than throwing', (tester) async {
    // Reachable for one frame: the router redirects away from home when the
    // session ends, but the screen may build once before that lands.
    sizeTo(tester, const Size(411, 914));

    await tester.pumpWidget(authHost(const HomeScreen(), session));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('greets in Arabic too', (tester) async {
    sizeTo(tester, const Size(411, 914));
    session.debugSetUser(const User(
      id: 'u-3',
      email: 'amina@shop.dz',
      firstName: 'أمينة',
    ));

    await tester.pumpWidget(
      authHost(const HomeScreen(), session, locale: const Locale('ar')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('مرحباً بعودتك، أمينة'), findsOneWidget);
  });
}
