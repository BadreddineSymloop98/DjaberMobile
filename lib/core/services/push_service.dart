import 'dart:async';

import '../utils/logger.dart';

/// A push notification payload, normalised away from whatever transport
/// delivered it.
///
/// The backend already puts the conversation id in the payload; the old Flutter
/// skeleton never read it, so tapping a notification landed the merchant on the
/// home screen to hunt for the conversation manually (brief Q6). [route] exists
/// so that stops being possible: the router consumes it directly.
class PushMessage {
  const PushMessage({
    required this.data,
    this.title,
    this.body,
    this.receivedAt,
  });

  final Map<String, String> data;
  final String? title;
  final String? body;
  final DateTime? receivedAt;

  String? get type => data['type'];
  String? get conversationId => data['conversationId'] ?? data['conversation_id'];
  String? get orderId => data['orderId'] ?? data['order_id'];
  String? get productId => data['productId'] ?? data['product_id'];

  /// The in-app destination this notification should open, or null when it is
  /// informational only.
  String? get route {
    final conversation = conversationId;
    if (conversation != null) return '/conversation/$conversation';
    final order = orderId;
    if (order != null) return '/orders/$order';
    final product = productId;
    if (product != null) return '/products/$product';
    return null;
  }

  @override
  String toString() => 'PushMessage(type: $type, data: $data)';
}

/// The contract the app codes against, so choosing a transport is one class to
/// write rather than a change spread across the app.
///
/// **This is deliberately unimplemented.** Brief §7 records the finding: the
/// backend sends push through *Expo* and validates Expo-format tokens, while
/// the app is Flutter, which cannot produce one. The loop the whole product
/// exists to close does not close today. Q5 — which transport replaces Expo —
/// is still open, so nothing here commits to Firebase, OneSignal or anything
/// else, and no vendor SDK is in `pubspec.yaml`.
///
/// When Q5 is answered, add the plugin and write one subclass. Nothing above
/// this file changes.
abstract class PushService {
  /// Ask for permission and start receiving. Returns false if the merchant
  /// declined — which on this product is worth surfacing, not swallowing: an
  /// app with notifications off cannot do the one thing it is for.
  Future<bool> initialize();

  /// The device token to register with `POST /api/devices/register`.
  Future<String?> getToken();

  /// Fires when the token is rotated by the OS or the transport. The old token
  /// in the database is dead from that moment and must be replaced.
  Stream<String> get onTokenRefresh;

  /// A notification arriving while the app is in the foreground. Nothing is
  /// shown by the system in this case — the app decides.
  Stream<PushMessage> get onMessage;

  /// The merchant tapped a notification. Drives the deep link.
  Stream<PushMessage> get onMessageOpened;

  /// The notification that launched the app from a cold start, if any. Must be
  /// read after the router exists, or the deep link is lost.
  Future<PushMessage?> getInitialMessage();

  /// Stop receiving on this device. Called on logout, together with
  /// `POST /api/devices/unregister`.
  Future<void> deleteToken();
}

/// Stands in until Q5 is answered, so the app compiles, runs and can be
/// developed end to end without a push transport wired.
///
/// It logs loudly rather than silently doing nothing — the one failure mode
/// worth avoiding here is shipping a build that looks fine and never alerts.
class NoopPushService implements PushService {
  final _tokenRefresh = StreamController<String>.broadcast();
  final _message = StreamController<PushMessage>.broadcast();
  final _messageOpened = StreamController<PushMessage>.broadcast();

  @override
  Future<bool> initialize() async {
    Log.w(
      'Push is not wired. Brief §7/Q5: the backend speaks Expo, the app is '
      'Flutter. Escalations will not reach this device.',
      tag: 'push',
    );
    return false;
  }

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<String> get onTokenRefresh => _tokenRefresh.stream;

  @override
  Stream<PushMessage> get onMessage => _message.stream;

  @override
  Stream<PushMessage> get onMessageOpened => _messageOpened.stream;

  @override
  Future<PushMessage?> getInitialMessage() async => null;

  @override
  Future<void> deleteToken() async {}

  /// Test and development hook — lets the deep-link path be exercised without
  /// a transport by pushing a message through the same streams the real one
  /// will use.
  void simulateOpen(PushMessage message) => _messageOpened.add(message);

  void dispose() {
    _tokenRefresh.close();
    _message.close();
    _messageOpened.close();
  }
}
