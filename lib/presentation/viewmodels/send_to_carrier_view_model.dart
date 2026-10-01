import 'package:flutter/widgets.dart';

import '../../core/error/app_exception.dart';
import '../../data/models/delivery.dart';
import '../../data/models/order.dart';
import '../../data/repositories/delivery_repository.dart';
import 'base_view_model.dart';

/// `Send an order to a carrier` (Figma `661:13915`) — the web's Send modal.
///
/// **Pre-filled from the order** (decided 2026-10-01): its wilaya, commune and
/// stop desk, and the default courier. The API ignores the order's own wilaya
/// unless it is sent, so the sheet always sends one; the web starts empty and
/// makes the merchant pick it every time.
class SendToCarrierViewModel extends BaseViewModel {
  SendToCarrierViewModel({required DeliveryRepository delivery, required this.order})
      : _delivery = delivery,
        _wilayaId = order.wilayaId,
        _isStopdesk = order.isStopdesk;

  final DeliveryRepository _delivery;
  final Order order;

  final note = TextEditingController();

  List<DeliveryProvider> _providers = const [];

  /// Only active accounts can send (`providerId` must be active).
  List<DeliveryProvider> get providers => _providers;

  List<Wilaya> _wilayas = const [];
  List<Wilaya> get wilayas => _wilayas;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// Loaded, and nothing to send with — the *aucun transporteur* state.
  bool get hasNoProvider => _loaded && _providers.isEmpty;

  String? _providerId;
  String? get providerId => _providerId;
  DeliveryProvider? get provider => _providers.where((p) => p.id == _providerId).firstOrNull;

  int? _wilayaId;
  int? get wilayaId => _wilayaId;

  bool _isStopdesk;
  bool get isStopdesk => _isStopdesk;

  CourierRates? _rates;
  CourierRates? get rates => _rates;
  bool _ratesLoading = false;
  bool get ratesLoading => _ratesLoading;

  /// The send was refused — the courier's own words, kept on screen.
  AppException? _sendError;
  AppException? get sendError => _sendError;

  bool get canSend => !isBusy && provider != null && _wilayaId != null;

  Future<void> load() async {
    final results = await Future.wait([_delivery.providers(), _delivery.wilayas()]);
    if (isDisposed) return;
    final providers = results[0].valueOrNull as List<DeliveryProvider>?;
    _wilayas = (results[1].valueOrNull as List<Wilaya>?) ?? const [];
    _providers = (providers ?? const []).where((p) => p.isActive).toList(growable: false);
    // The default account, else the first active one — the server's own order.
    _providerId = (_providers.where((p) => p.isDefault).firstOrNull ?? _providers.firstOrNull)?.id;
    // A providers call that failed is not "none configured": say why instead.
    if (providers == null) _sendError = results[0].errorOrNull;
    _loaded = true;
    safeNotify();
    await _loadRates();
  }

  void setProvider(String? id) {
    if (id == null || id == _providerId) return;
    _providerId = id;
    _sendError = null;
    safeNotify();
    _loadRates();
  }

  void setWilaya(int? id) {
    if (id == null || id == _wilayaId) return;
    _wilayaId = id;
    _sendError = null;
    safeNotify();
    _loadRates();
  }

  void setStopdesk(bool value) {
    _isStopdesk = value;
    safeNotify();
  }

  /// *Tarifs estimés* — the chosen courier's live tariff to the chosen wilaya.
  /// Maystro has no rate API; a failure simply shows dashes.
  Future<void> _loadRates() async {
    final courier = provider?.provider;
    final wilaya = _wilayaId;
    if (courier == null || wilaya == null) {
      _rates = null;
      safeNotify();
      return;
    }
    _ratesLoading = true;
    safeNotify();
    final result = await _delivery.rates(courier: courier, toWilayaId: wilaya);
    if (isDisposed || courier != provider?.provider || wilaya != _wilayaId) return;
    _rates = result.valueOrNull;
    _ratesLoading = false;
    safeNotify();
  }

  /// Sends the parcel. The updated order on success, null otherwise (the
  /// reason is in [sendError]).
  Future<Order?> send() async {
    if (!canSend) return null;
    _sendError = null;
    return run(
      () => _delivery.send(
        order.id,
        providerId: _providerId,
        toWilayaId: _wilayaId!,
        communeName: order.communeName,
        isStopdesk: _isStopdesk,
        note: note.text,
      ),
      onError: (error) => _sendError = error,
      tag: 'sendToDelivery',
    );
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }
}
