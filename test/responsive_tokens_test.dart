import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:djaber_mobile/presentation/theme/app_spacing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The design tokens are percentages of the screen now, not fixed dp. These
/// pin the two things that could go wrong: that they resolve to the Figma
/// numbers on the design frame, and that they actually move on other handsets.
void main() {
  /// The frame every screen is drawn against.
  const designFrame = Size(390, 844);

  void on(Size size) => Screen.update(MediaQueryData(size: size));

  group('on the 390x844 design frame', () {
    setUp(() => on(designFrame));

    test('spacing resolves to the dp values in the frames', () {
      expect(AppSpacing.xs, closeTo(4, 0.1));
      expect(AppSpacing.sm, closeTo(8, 0.1));
      expect(AppSpacing.md, closeTo(12, 0.1));
      expect(AppSpacing.lg, closeTo(16, 0.1));
      expect(AppSpacing.xl, closeTo(20, 0.1));
      expect(AppSpacing.xxl, closeTo(24, 0.1));
      expect(AppSpacing.gutter, closeTo(20, 0.1));
      expect(AppSpacing.gutterTight, closeTo(16, 0.1));
    });

    test('radii resolve to the frame values', () {
      expect(AppRadius.card, closeTo(8, 0.1));
      expect(AppRadius.sheet, closeTo(16, 0.1));
    });
  });

  group('across handsets', () {
    test('spacing scales with the screen', () {
      on(const Size(320, 568));
      final small = AppSpacing.gutter;
      on(designFrame);
      final frame = AppSpacing.gutter;
      on(const Size(430, 932));
      final large = AppSpacing.gutter;

      expect(small, lessThan(frame));
      expect(frame, lessThan(large));
    });

    test('the whole scale stays proportional to width', () {
      on(const Size(320, 568));
      // Every token is the same fraction of the screen it was on the frame.
      expect(AppSpacing.gutter / 320, closeTo(20 / 390, 0.0005));
      expect(AppSpacing.md / 320, closeTo(12 / 390, 0.0005));
    });

    test('a hairline stays exactly one logical pixel everywhere', () {
      // Deliberately not scaled: a fractional hairline renders as a grey blur,
      // and every border in this design system is a hairline.
      for (final size in const [
        Size(320, 568),
        designFrame,
        Size(430, 932),
        Size(800, 1280),
      ]) {
        on(size);
        expect(AppStroke.hairline, 1);
      }
    });
  });
}
