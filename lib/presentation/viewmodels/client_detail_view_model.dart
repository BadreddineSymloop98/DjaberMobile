import '../../core/error/result.dart';
import '../../data/models/client.dart';
import '../../data/repositories/client_repository.dart';
import 'base_view_model.dart';

/// `Client details` — the web's *Client Details* modal as a screen.
///
/// Two reads, and only the first is required: the client itself, and its AI
/// conversation metrics. A failed metrics read hides those two sections rather
/// than the whole screen — the contact details and order figures are what the
/// merchant opened it for.
class ClientDetailViewModel extends BaseViewModel {
  ClientDetailViewModel({required ClientRepository clients, required this.clientId})
      : _clients = clients;

  final ClientRepository _clients;
  final String clientId;

  Client? _client;
  Client? get client => _client;

  ClientMetrics? _metrics;
  ClientMetrics? get metrics => _metrics;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  /// Silent after the first load, so a refresh keeps what is on screen.
  Future<void> load() async {
    final silent = _loadedOnce;
    final metrics = _clients.metrics(clientId);
    await run(
      () => _clients.get(clientId),
      onSuccess: (value) => _client = value,
      silent: silent,
      tag: 'clientDetail',
    );
    final metricsResult = await metrics;
    if (isDisposed) return;
    if (metricsResult case Success(:final value)) _metrics = value;
    _loadedOnce = true;
    safeNotify();
  }
}
