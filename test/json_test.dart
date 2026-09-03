import 'package:djaber_mobile/core/utils/json.dart';
import 'package:flutter_test/flutter_test.dart';

/// These helpers exist because of how the backend actually serialises, not
/// how it ought to. The cases below are the shapes that were breaking naive
/// casts — Prisma `Decimal` as a string is the important one, since it is
/// every price in the app.
void main() {
  group('numbers', () {
    test('reads a Prisma Decimal, which arrives as a string', () {
      expect(Json.dbl('1250.00'), 1250.0);
      expect(Json.dbl('0.5'), 0.5);
    });

    test('reads a plain number', () {
      expect(Json.dbl(42), 42.0);
      expect(Json.intOf(42), 42);
      expect(Json.intOf('42'), 42);
    });

    test('falls back rather than throwing on junk', () {
      expect(Json.dbl(null), 0);
      expect(Json.dbl('not a number'), 0);
      expect(Json.intOf({}, -1), -1);
    });

    test('distinguishes absent from zero', () {
      expect(Json.dblOrNull(null), isNull);
      expect(Json.dblOrNull(0), 0.0);
    });
  });

  group('booleans', () {
    test('accepts the MySQL and query-string forms', () {
      expect(Json.boolOf(true), isTrue);
      expect(Json.boolOf(1), isTrue);
      expect(Json.boolOf('true'), isTrue);
      expect(Json.boolOf('1'), isTrue);
      expect(Json.boolOf(0), isFalse);
      expect(Json.boolOf('false'), isFalse);
    });
  });

  group('lists', () {
    Map<String, dynamic> asMap(Map<String, dynamic> m) => m;

    test('skips an entry that fails to parse instead of losing the list', () {
      final parsed = Json.list<String>(
        [
          {'name': 'A'},
          {'name': 'B'},
          'not a map',
        ],
        (m) {
          if (m['name'] == 'B') throw StateError('bad row');
          return m['name'] as String;
        },
      );
      // One malformed product must not empty a screen.
      expect(parsed, ['A']);
    });

    test('listAt unwraps the envelope the backend usually returns', () {
      final fromEnvelope = Json.listAt(
        {
          'products': [
            {'id': '1'},
          ],
        },
        'products',
        asMap,
      );
      final fromBareArray = Json.listAt(
        [
          {'id': '1'},
        ],
        'products',
        asMap,
      );
      expect(fromEnvelope.single['id'], '1');
      expect(fromBareArray.single['id'], '1');
    });
  });

  group('dates', () {
    test('parses ISO-8601 into UTC', () {
      final parsed = Json.dateOrNull('2026-09-02T10:30:00.000Z');
      expect(parsed!.isUtc, isTrue);
      expect(parsed.year, 2026);
    });

    test('returns null rather than a wrong date', () {
      expect(Json.dateOrNull(null), isNull);
      expect(Json.dateOrNull('tomorrow'), isNull);
    });
  });
}
