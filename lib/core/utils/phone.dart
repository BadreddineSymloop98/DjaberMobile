import 'package:flutter/services.dart';

/// Algerian phone numbers, written the way merchants here write them: a
/// leading **0** rather than the `+213` country code.
///
/// - Mobile is ten digits — `0555 12 34 56` — and starts `05`, `06` or `07`.
///   The Figma frames write it in 4-2-2-2 groups, which is what this produces.
/// - A landline is nine — `021 23 45 67` — and starts with any other digit, so
///   it groups 3-2-2-2.
///
/// **What is typed and what is sent are different things.** The spacing is for
/// reading; the value that leaves the app is [digits], with no spaces at all.
/// That matters more than it looks: a client's phone is unique per merchant
/// server-side, and `0555 12 34 56` and `0555123456` would be two different
/// clients to a database that only compares strings.
///
/// **A number that is not Algerian is left alone.** A foreign supplier's
/// number has neither of those shapes, so grouping it would be an invention
/// and capping it would lock the merchant out of typing it. Anything that does
/// not normalise to a leading 0 passes through as bare digits.
class Phone {
  const Phone._();

  /// Mobile prefixes: Mobilis, Djezzy and Ooredoo all sit in `05`–`07`.
  static const _mobileLeads = {'5', '6', '7'};

  static const mobileLength = 10;
  static const landlineLength = 9;

  /// E.164's ceiling, the cap for anything this cannot recognise.
  static const _foreignLength = 15;

  /// The value to store and send: digits only, country code folded to a 0.
  ///
  /// Empty in, empty out — a cleared field clears the column, which is what
  /// the repositories send `""` for.
  static String digits(String raw) => _normalise(_bare(raw)).digits;

  /// The same, or null when there is nothing left — for the optional fields
  /// that would rather omit a key than send an empty one.
  static String? digitsOrNull(String raw) {
    final value = digits(raw);
    return value.isEmpty ? null : value;
  }

  /// Grouped for reading. Hands back whatever it was given if it cannot
  /// recognise the shape, so a foreign or half-typed number still shows.
  static String format(String raw) {
    final value = digits(raw);
    if (value.isEmpty) return '';
    if (!_isLocal(value)) return value;

    final groups = _groupsFor(value);
    final out = StringBuffer();
    var index = 0;
    for (final size in groups) {
      if (index >= value.length) break;
      if (index > 0) out.write(' ');
      out.write(value.substring(index, (index + size).clamp(0, value.length)));
      index += size;
    }
    // Anything past the last group — only reachable if the caps below are
    // bypassed — is kept rather than silently dropped.
    if (index < value.length) out.write(' ${value.substring(index)}');
    return out.toString();
  }

  /// True once the number is long enough to be a whole Algerian one. Used to
  /// tell "still typing" from "wrong", so a form does not complain at the
  /// third digit.
  static bool isComplete(String raw) {
    final value = digits(raw);
    if (!_isLocal(value)) return value.length >= 6;
    return value.length == _lengthFor(value);
  }

  static String _bare(String raw) {
    final out = StringBuffer();
    for (final rune in raw.runes) {
      final char = String.fromCharCode(rune);
      if (char.codeUnitAt(0) >= 0x30 && char.codeUnitAt(0) <= 0x39) out.write(char);
    }
    return out.toString();
  }

  /// Folds the country code to a leading 0, and adds the 0 a merchant leaves
  /// off when they type a mobile straight from memory.
  ///
  /// [shift] is how far the digits moved, so a formatter can keep the caret
  /// where the finger left it.
  static ({String digits, int shift}) _normalise(String bare) {
    if (bare.startsWith('00213')) {
      return (digits: _cap('0${bare.substring(5)}'), shift: -4);
    }
    if (bare.startsWith('213')) {
      return (digits: _cap('0${bare.substring(3)}'), shift: -2);
    }
    // `05…` typed as `5…`. Only for a mobile lead: a bare `21…` is far more
    // likely to be someone part-way through typing a country code than a
    // landline missing its 0.
    if (bare.isNotEmpty && _mobileLeads.contains(bare[0])) {
      return (digits: _cap('0$bare'), shift: 1);
    }
    return (digits: _cap(bare), shift: 0);
  }

  static String _cap(String value) {
    final max = _isLocal(value) ? _lengthFor(value) : _foreignLength;
    return value.length <= max ? value : value.substring(0, max);
  }

  static bool _isLocal(String value) => value.startsWith('0');

  static int _lengthFor(String value) =>
      value.length > 1 && _mobileLeads.contains(value[1]) ? mobileLength : landlineLength;

  static List<int> _groupsFor(String value) =>
      value.length > 1 && _mobileLeads.contains(value[1])
          ? const [4, 2, 2, 2]
          : const [3, 2, 2, 2];

  /// Internal, for the formatter's caret arithmetic.
  static ({String digits, int shift}) normaliseForCaret(String raw) => _normalise(_bare(raw));
}

/// Formats a phone field as it is typed: digits only, grouped the Algerian
/// way, country code folded to a 0.
///
/// The caret is put back where the finger left it rather than jumped to the
/// end, so a merchant can correct a digit in the middle without the field
/// fighting them.
class AlgerianPhoneFormatter extends TextInputFormatter {
  const AlgerianPhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue value) {
    final result = Phone.normaliseForCaret(value.text);
    final text = Phone.format(result.digits);

    // How many digits the merchant had typed before the caret. Counting digits
    // rather than characters is what survives the spaces moving around.
    final cursor = value.selection.baseOffset.clamp(0, value.text.length);
    var typed = 0;
    for (var i = 0; i < cursor; i++) {
      final code = value.text.codeUnitAt(i);
      if (code >= 0x30 && code <= 0x39) typed++;
    }
    final target = (typed + result.shift).clamp(0, result.digits.length);

    // Walk the formatted text to the same digit, so the caret lands after it
    // and not before the space that follows.
    var offset = text.length;
    var seen = 0;
    for (var i = 0; i < text.length; i++) {
      if (seen == target) {
        offset = i;
        break;
      }
      final code = text.codeUnitAt(i);
      if (code >= 0x30 && code <= 0x39) seen++;
    }
    if (seen == target && target == result.digits.length) offset = text.length;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset.clamp(0, text.length)),
    );
  }
}
