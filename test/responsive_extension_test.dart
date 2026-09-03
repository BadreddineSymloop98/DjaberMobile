import 'package:djaber_mobile/core/extensions/responsive_extension.dart';
import 'package:djaber_mobile/core/utils/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The responsive extension is used by every widget in the app, so its
/// arithmetic is worth pinning down before any screen depends on it.
void main() {
  // A common low-end Android target: 360×800 logical pixels.
  const size = Size(360, 800);

  setUp(() {
    Screen.update(
      const MediaQueryData(
        size: size,
        devicePixelRatio: 3,
        padding: EdgeInsets.only(top: 24, bottom: 16),
      ),
    );
  });

  group('percentage sizing', () {
    test('.h is a percentage of the full screen height', () {
      expect(100.h, size.height);
      expect(50.h, 400);
      expect(2.5.h, 20);
    });

    test('.w is a percentage of the full screen width', () {
      expect(100.w, size.width);
      expect(50.w, 180);
    });

    test('.sh excludes the status bar and the gesture bar', () {
      expect(100.sh, size.height - 24 - 16);
    });

    test('.r follows the shorter edge, so it survives rotation', () {
      expect(10.r, 36);
    });
  });

  group('type sizing', () {
    test('.sp scales against the 390dp design frame', () {
      // 360 / 390 = 0.923, inside the 0.85–1.15 clamp.
      expect(15.sp, closeTo(15 * (360 / 390), 0.001));
    });

    test('.sp is clamped so a tablet does not get enormous type', () {
      Screen.update(const MediaQueryData(size: Size(1024, 1366)));
      expect(15.sp, 15 * 1.15);
    });

    test('.sp is clamped so a very narrow phone stays readable', () {
      Screen.update(const MediaQueryData(size: Size(280, 640)));
      expect(15.sp, 15 * 0.85);
    });
  });

  group('breakpoints', () {
    test('360dp is not classed as small — it is the market floor, not an edge '
        'case', () {
      expect(Screen.isSmall, isFalse);
    });

    test('below 360dp is small', () {
      Screen.update(const MediaQueryData(size: Size(320, 568)));
      expect(Screen.isSmall, isTrue);
      // .dp shrinks slightly on a small handset, .h does not change meaning.
      expect(24.dp, closeTo(24 * 0.92, 0.001));
    });

    test('600dp and above is a tablet', () {
      Screen.update(const MediaQueryData(size: Size(834, 1112)));
      expect(Screen.isTablet, isTrue);
      expect(Screen.isSmall, isFalse);
    });
  });
}
