import 'package:djaber_mobile/core/error/app_exception.dart';
import 'package:djaber_mobile/data/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// The exact bodies the three endpoints return, from
  /// `backend/src/controllers/auth.controller.ts`.
  const loginUser = {
    'id': 'u-1',
    'email': 'amina@shop.dz',
    'firstName': 'Amina',
    'lastName': 'Benali',
    'plan': 'individual',
    'isAdmin': false,
  };

  const registerUser = {
    'id': 'u-1',
    'email': 'amina@shop.dz',
    'firstName': 'Amina',
    'lastName': 'Benali',
    'plan': 'individual',
    // No isAdmin — register omits it.
  };

  const profileUser = {
    'id': 'u-1',
    'email': 'amina@shop.dz',
    'firstName': 'Amina',
    'lastName': 'Benali',
    'plan': 'individual',
    'isAdmin': false,
    'creditsUsed': 120,
    'creditsLimit': 500,
    'createdAt': '2026-08-01T10:30:00.000Z',
  };

  group('parsing each endpoint', () {
    test('login gives everything but credits', () {
      final user = User.fromJson(loginUser);
      expect(user.id, 'u-1');
      expect(user.displayName, 'Amina Benali');
      expect(user.plan, 'individual');
      expect(user.isAdmin, isFalse);
      expect(user.creditsUsed, isNull);
      expect(user.creditsLimit, isNull);
    });

    test('register omits isAdmin, which defaults to false', () {
      expect(User.fromJson(registerUser).isAdmin, isFalse);
    });

    test('profile gives credits and createdAt', () {
      final user = User.fromJson(profileUser);
      expect(user.creditsUsed, 120);
      expect(user.creditsLimit, 500);
      expect(user.creditsRemaining, 380);
      expect(user.createdAt?.year, 2026);
      expect(user.createdAt?.isUtc, isTrue);
    });
  });

  group('isAgentPaused — the signal that was silently dead', () {
    test('false while credits are unknown', () {
      // The old model read a `credits` field the backend never sends, so this
      // answered false because it was always null — not because the merchant
      // had credit. Straight after login credits genuinely are unknown, and
      // "not loaded" must not read as "out of credits".
      expect(User.fromJson(loginUser).isAgentPaused, isFalse);
    });

    test('false with credit remaining', () {
      expect(User.fromJson(profileUser).isAgentPaused, isFalse);
    });

    test('true once used reaches the limit', () {
      final spent = User.fromJson({...profileUser, 'creditsUsed': 500});
      expect(spent.isAgentPaused, isTrue);
      expect(spent.creditsRemaining, 0);
    });

    test('true when used somehow exceeds the limit', () {
      final over = User.fromJson({...profileUser, 'creditsUsed': 620});
      expect(over.isAgentPaused, isTrue);
      // Never reported as negative.
      expect(over.creditsRemaining, 0);
    });
  });

  group('merging', () {
    test('the profile adds credits without dropping isAdmin', () {
      // The real sequence: login returns isAdmin but no credits, then the
      // profile fetch returns credits. Replacing wholesale would lose one.
      final afterLogin = User.fromJson({...loginUser, 'isAdmin': true});
      final merged = afterLogin.mergedWith(User.fromJson(profileUser));

      expect(merged.creditsLimit, 500);
      expect(merged.isAdmin, isTrue, reason: 'kept from the login response');
    });

    test('a sparser response does not blank fields already known', () {
      final full = User.fromJson(profileUser);
      final merged = full.mergedWith(User.fromJson(loginUser));

      expect(merged.creditsUsed, 120);
      expect(merged.createdAt, isNotNull);
    });
  });

  group('greetingName', () {
    test('uses the first name', () {
      expect(User.fromJson(loginUser).greetingName, 'Amina');
    });

    test('falls back to the local part of the email', () {
      // The backend requires firstName, but a merchant created outside the
      // sign-up form might not have one, and "Welcome back, " reads as a bug.
      final noName = User.fromJson({
        'id': 'u-2',
        'email': 'boutique.oran@shop.dz',
      });
      expect(noName.greetingName, 'boutique.oran');
    });
  });

  group('initials', () {
    test('two names give two letters', () {
      expect(User.fromJson(loginUser).initials, 'AB');
    });

    test('an email alone gives one', () {
      expect(
        User.fromJson({'id': 'u-3', 'email': 'zak@shop.dz'}).initials,
        'Z',
      );
    });
  });

  group('backend error mapping', () {
    test('the shapes the endpoints actually return are typed correctly', () {
      // 401 from a public login endpoint can only mean bad credentials.
      const badCredentials =
          UnauthorizedException('Invalid email or password');
      expect(badCredentials.statusCode, 401);

      // A duplicate email arrives as 400 — the same code as a field failure —
      // so the message is the only discriminator.
      const duplicate = ValidationException(
        'User with this email already exists',
        statusCode: 400,
      );
      expect(duplicate.message.toLowerCase().contains('already exists'), isTrue);
    });
  });
}
