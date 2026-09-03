import 'package:flutter/widgets.dart';

/// Holds the current screen metrics so the `.h` / `.w` extension can be a plain
/// getter on a number rather than something that needs a [BuildContext].
///
/// [init] is called from [ScreenInitializer], which sits above every route in
/// [MaterialApp.builder], so the values are populated before any widget that
/// uses the extension is built — and re-populated on rotation, split screen,
/// or a keyboard opening.
class Screen {
  const Screen._();

  static double _width = 0;
  static double _height = 0;
  static double _statusBar = 0;
  static double _bottomInset = 0;
  static double _devicePixelRatio = 1;
  static double _textScale = 1;
  static bool _initialized = false;

  /// Full screen width in logical pixels.
  static double get width => _width;

  /// Full screen height in logical pixels, safe areas included.
  static double get height => _height;

  /// Height with the status bar and the system gesture bar removed — the space
  /// a page body actually gets.
  static double get safeHeight => _height - _statusBar - _bottomInset;

  static double get statusBarHeight => _statusBar;
  static double get bottomInset => _bottomInset;
  static double get devicePixelRatio => _devicePixelRatio;
  static double get textScale => _textScale;
  static bool get isInitialized => _initialized;

  /// The shorter edge. Used by `.r` so a radius or a square icon keeps its
  /// proportions in landscape instead of stretching.
  static double get shortestSide => _width < _height ? _width : _height;

  static bool get isLandscape => _width > _height;

  /// The market is low-end Android — 5" 720p handsets are common and a 360dp
  /// width is the realistic floor, not the exception.
  static bool get isSmall => shortestSide < 360;
  static bool get isTablet => shortestSide >= 600;

  static void update(MediaQueryData mq) {
    _width = mq.size.width;
    _height = mq.size.height;
    _statusBar = mq.padding.top;
    _bottomInset = mq.padding.bottom;
    _devicePixelRatio = mq.devicePixelRatio;
    _textScale = mq.textScaler.scale(1);
    _initialized = true;
  }
}

/// Wraps the widget tree, keeps [Screen] current, and clamps the OS text scale.
///
/// The clamp is deliberate: Djaber's screens are dense (a queue, a stock list,
/// a conversation), and an unbounded system font scale on Android breaks them
/// outright. Clamping to 1.3 keeps the app usable for people who need larger
/// type without letting a 2.0 scale destroy every layout.
class ScreenInitializer extends StatelessWidget {
  const ScreenInitializer({super.key, required this.child});

  final Widget child;

  static const double maxTextScale = 1.3;
  static const double minTextScale = 0.85;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final clamped = mq.copyWith(
      textScaler: mq.textScaler.clamp(
        minScaleFactor: minTextScale,
        maxScaleFactor: maxTextScale,
      ),
    );
    Screen.update(clamped);
    return MediaQuery(data: clamped, child: child);
  }
}
