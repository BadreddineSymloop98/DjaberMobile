import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../utils/logger.dart';

/// Tracks whether the device has a network interface at all.
///
/// This is a transport check, not a reachability check — connectivity_plus
/// reports "connected to wifi", which in Algeria regularly means connected to a
/// router with no upstream. So it is used to *explain* a failure and to trigger
/// a refresh when the connection returns, never to pre-emptively block a
/// request: a request that might work is always worth attempting.
class ConnectivityService extends ChangeNotifier {
  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  /// Fires when the device goes from offline to online, so open screens can
  /// retry whatever failed while it was down.
  final _reconnected = StreamController<void>.broadcast();
  Stream<void> get onReconnected => _reconnected.stream;

  Future<void> init() async {
    _apply(await _connectivity.checkConnectivity());
    _subscription = _connectivity.onConnectivityChanged.listen(_apply);
  }

  void _apply(List<ConnectivityResult> results) {
    final online =
        results.any((r) => r != ConnectivityResult.none) && results.isNotEmpty;
    if (online == _isOnline) return;
    _isOnline = online;
    Log.i('connectivity: ${online ? 'online' : 'offline'}', tag: 'net');
    notifyListeners();
    if (online) _reconnected.add(null);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _reconnected.close();
    super.dispose();
  }
}
