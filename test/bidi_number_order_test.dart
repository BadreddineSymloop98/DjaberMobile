import 'package:djaber_mobile/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Grouped numbers must not come apart in Arabic.
///
/// `onboarding 3`'s second escalation card prints a price. Written as
/// `2 400 دج`, with an ordinary space between the digit groups, it rendered as
/// **`400 2`** — and nothing in the suite noticed: the string is correct, the
/// layout does not overflow, and the localisation sweep only asserts that
/// Arabic lays out without throwing. The damage is in the *order the glyphs are
/// placed*, which is invisible to every assertion we had.
///
/// The cause is Unicode bidi rule N1: numbers act as right-to-left toward the
/// neutrals beside them, so an ordinary space between two digit groups resolves
/// RTL and splits one number into two runs that are then ordered right to left.
///
/// **The figure carries no separator at all now.** A separator of bidi class
/// `CS` — `U+202F`, `U+00A0`, a comma — would also have held the run together,
/// but this number is four digits and does not need grouping to be read, and
/// nothing inside it can then be mistaken for a boundary. `Money` still groups
/// real prices, where the figures are long enough to need it; it emits `U+202F`
/// for French and a comma for Arabic and English, all of which are safe.
///
/// Asserted by measuring where the glyphs actually land rather than by
/// inspecting the string, because the string was never the thing that was
/// wrong.
void main() {
  /// The left edge of [part] as laid out inside [full], in an RTL paragraph.
  double leftEdgeOf(String full, String part) {
    final start = full.indexOf(part);
    expect(start, isNonNegative, reason: '"$part" is not in "$full"');
    final painter = TextPainter(
      text: TextSpan(text: full, style: const TextStyle(fontSize: 14)),
      textDirection: TextDirection.rtl,
    )..layout(maxWidth: 400);
    return painter
        .getBoxesForSelection(
          TextSelection(baseOffset: start, extentOffset: start + part.length),
        )
        .map((box) => box.left)
        .reduce((a, b) => a < b ? a : b);
  }

  test('the escalation price is written without a separator, in every locale',
      () {
    for (final tag in ['ar', 'fr', 'en']) {
      expect(
        lookupL10n(Locale(tag)).obEsc2Body,
        contains('2400'),
        reason: '[$tag] the digits must stay contiguous — any separator '
            'between them is a neutral, and a neutral is what reversed this '
            'number before. The three locales carry the same figure.',
      );
    }
  });

  test('and it renders in reading order, not reversed', () {
    final body = lookupL10n(const Locale('ar')).obEsc2Body;

    expect(
      leftEdgeOf(body, '2'),
      lessThan(leftEdgeOf(body, '400')),
      reason: 'the figure is rendering reversed',
    );
  });

  test('an ordinary space is what breaks it — the guard is not vacuous', () {
    // Without this, the tests above would keep passing if someone replaced the
    // figure with something that merely happens to lay out left to right.
    const broken = '2 400 دج';
    expect(leftEdgeOf(broken, '2'), greaterThan(leftEdgeOf(broken, '400')));
  });
}
