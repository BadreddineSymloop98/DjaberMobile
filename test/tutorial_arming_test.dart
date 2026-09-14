import 'package:djaber_mobile/core/services/device_info_service.dart';
import 'package:djaber_mobile/core/services/push_service.dart';
import 'package:djaber_mobile/core/storage/prefs_storage.dart';
import 'package:djaber_mobile/presentation/viewmodels/session_view_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_auth_repository.dart';

/// **Who is shown the tutorial.**
///
/// The rule (brief §21.5): it runs once, straight after an account is created,
/// and never for a merchant signing in to an account that already exists.
///
/// The redirect that enforces the hold is covered in
/// `tutorial_redirect_test.dart`, but that suite sets `tutorialPending` by
/// hand. These tests cover the half it cannot: **who sets it**. Without them a
/// change to `signIn` could start arming the tutorial for every returning
/// merchant and nothing would fail.
void main() {
  late PrefsStorage prefs;
  late FakeAuthRepository auth;
  late SessionViewModel session;

  Future<void> boot({Map<String, Object> prefsValues = const {}}) async {
    SharedPreferences.setMockInitialValues(prefsValues);
    FlutterSecureStorage.setMockInitialValues({});
    prefs = await PrefsStorage.load();
    auth = FakeAuthRepository(prefs: prefs);
    session = SessionViewModel(
      authRepository: auth,
      prefs: prefs,
      push: NoopPushService(),
      deviceInfo: const DeviceInfoService.fake(),
    );
  }

  tearDown(() => session.dispose());

  test('creating an account arms the tutorial', () async {
    await boot();
    expect(session.tutorialPending, isFalse);

    final ok = await session.signUp(
      firstName: 'Amina',
      lastName: 'Benali',
      email: 'amina@shop.dz',
      password: 'hunter2hunter2',
    );

    expect(ok, isTrue);
    expect(auth.registrations, 1);
    expect(session.tutorialPending, isTrue);
  });

  test('signing in to an existing account does not', () async {
    await boot();

    final ok = await session.signIn(
      email: 'amina@shop.dz',
      password: 'hunter2hunter2',
    );

    expect(ok, isTrue);
    expect(auth.logins, 1);
    // The account already exists — it has been set up, on this handset or
    // another. Walking a returning merchant through creating a first product
    // would be worse than useless.
    expect(session.tutorialPending, isFalse);
  });

  test('a failed sign-up arms nothing', () async {
    await boot();
    auth = FakeAuthRepository(prefs: prefs, fails: true);
    session.dispose();
    session = SessionViewModel(
      authRepository: auth,
      prefs: prefs,
      push: NoopPushService(),
      deviceInfo: const DeviceInfoService.fake(),
    );

    final ok = await session.signUp(
      firstName: 'Amina',
      lastName: 'Benali',
      email: 'taken@shop.dz',
      password: 'hunter2hunter2',
    );

    expect(ok, isFalse);
    expect(session.isSignedIn, isFalse);
    // No account was created, so there is nothing to walk through.
    expect(session.tutorialPending, isFalse);
  });

  test('it survives a restart, so a force-quit does not skip it', () async {
    await boot();
    await session.signUp(
      firstName: 'Amina',
      lastName: 'Benali',
      email: 'amina@shop.dz',
      password: 'hunter2hunter2',
    );

    // A second PrefsStorage over the same store is what the next launch sees.
    final relaunched = await PrefsStorage.load();
    expect(relaunched.tutorialPending, isTrue);
  });

  test('completing it clears the flag for good', () async {
    await boot();
    await session.signUp(
      firstName: 'Amina',
      lastName: 'Benali',
      email: 'amina@shop.dz',
      password: 'hunter2hunter2',
    );

    await session.completeTutorial();

    expect(session.tutorialPending, isFalse);
    expect((await PrefsStorage.load()).tutorialPending, isFalse);
  });

  test('signing out drops it, so it is not inherited on a shared handset',
      () async {
    await boot();
    await session.signUp(
      firstName: 'Amina',
      lastName: 'Benali',
      email: 'amina@shop.dz',
      password: 'hunter2hunter2',
    );
    expect(session.tutorialPending, isTrue);

    await session.signOut();

    // Deliberate, and it has a cost worth naming: the merchant who abandoned
    // the tutorial is never asked again, because the flag lives on the device
    // and not on their record. The alternative is worse — the next merchant to
    // sign in on this handset would be dropped into someone else's setup.
    expect(session.tutorialPending, isFalse);
  });

  test('onboarding is per install, and outlives a sign-out', () async {
    await boot(prefsValues: {'onboarding_seen': true});
    await session.signIn(
      email: 'amina@shop.dz',
      password: 'hunter2hunter2',
    );

    await session.signOut();

    // Unlike the tutorial: onboarding explains the product, not the account,
    // so a merchant who has seen it lands on login rather than replaying it.
    expect(session.onboardingSeen, isTrue);
  });
}
