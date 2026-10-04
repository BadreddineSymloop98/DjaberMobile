import 'package:djaber_mobile/core/utils/phone.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Algerian numbers, written with a leading 0 rather than `+213`.
void main() {
  group('what gets stored', () {
    test('keeps digits and drops everything else', () {
      expect(Phone.digits('0555 12 34 56'), '0555123456');
      expect(Phone.digits('0555-12-34-56'), '0555123456');
      expect(Phone.digits('(0555) 12 34 56'), '0555123456');
    });

    test('folds the country code to a 0, however it was written', () {
      expect(Phone.digits('+213555123456'), '0555123456');
      expect(Phone.digits('213 555 12 34 56'), '0555123456');
      expect(Phone.digits('00213555123456'), '0555123456');
    });

    test('adds the 0 a merchant leaves off a mobile', () {
      expect(Phone.digits('555123456'), '0555123456');
      expect(Phone.digits('661457890'), '0661457890');
    });

    test('an empty field stays empty, so it can clear the column', () {
      expect(Phone.digits(''), '');
      expect(Phone.digits('   '), '');
      expect(Phone.digitsOrNull(''), isNull);
    });

    test('caps a mobile at ten digits and a landline at nine', () {
      expect(Phone.digits('05551234567890'), '0555123456');
      expect(Phone.digits('021234567890'), '021234567');
    });
  });

  group('what gets shown', () {
    test('a mobile groups 4-2-2-2, as the frames write it', () {
      expect(Phone.format('0555123456'), '0555 12 34 56');
      expect(Phone.format('0661457890'), '0661 45 78 90');
    });

    test('a landline groups 3-2-2-2', () {
      expect(Phone.format('021234567'), '021 23 45 67');
    });

    test('a half-typed number groups as far as it goes', () {
      expect(Phone.format('0555'), '0555');
      expect(Phone.format('055512'), '0555 12');
      expect(Phone.format('05551234'), '0555 12 34');
    });

    test('nothing in, nothing out', () => expect(Phone.format(''), ''));
  });

  group('a number that is not Algerian', () {
    // A foreign supplier. Grouping it would be an invention and capping it at
    // ten would stop the merchant typing it at all.
    test('passes through as bare digits, ungrouped', () {
      expect(Phone.digits('+33 6 12 34 56 78'), '33612345678');
      expect(Phone.format('+33 6 12 34 56 78'), '33612345678');
    });

    test('is still capped, at E.164 length', () {
      expect(Phone.digits('33612345678901234').length, 15);
    });
  });

  group('completeness — to tell "still typing" from "wrong"', () {
    test('a whole mobile and a whole landline are complete', () {
      expect(Phone.isComplete('0555 12 34 56'), isTrue);
      expect(Phone.isComplete('021 23 45 67'), isTrue);
    });

    test('a short one is not', () {
      expect(Phone.isComplete('0555 12'), isFalse);
      expect(Phone.isComplete(''), isFalse);
    });
  });

  group('the field as it is typed', () {
    const formatter = AlgerianPhoneFormatter();

    TextEditingValue type(String text, {int? cursor}) => formatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: cursor ?? text.length),
          ),
        );

    test('spaces appear as the digits arrive', () {
      expect(type('0').text, '0');
      expect(type('0555').text, '0555');
      expect(type('05551').text, '0555 1');
      expect(type('0555123456').text, '0555 12 34 56');
    });

    test('the caret stays at the end while typing', () {
      final value = type('05551');
      expect(value.selection.baseOffset, value.text.length);
    });

    test('the caret keeps its place when a digit is fixed mid-number', () {
      // Caret sits after the fourth digit; it must still sit after the fourth
      // digit once the spaces have moved.
      final value = type('0556123456', cursor: 4);
      expect(value.text, '0556 12 34 56');
      expect(value.selection.baseOffset, 4);
    });

    test('a pasted +213 number becomes a local one', () {
      expect(type('+213555123456').text, '0555 12 34 56');
    });

    test('letters cannot be typed at all', () {
      expect(type('0555abc12').text, '0555 12');
    });
  });
}
