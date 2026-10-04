import '../../core/error/result.dart';
import '../../data/models/delivery.dart';
import '../../data/models/order.dart';
import '../../data/repositories/delivery_repository.dart';
import '../../data/repositories/order_repository.dart';
import 'base_view_model.dart';

/// The overview's tabs — the web's `DeliveryFilter`, one per delivery status.
enum DeliveryTab {
  all(null),
  ready(DeliveryStatus.notSent),
  sent(DeliveryStatus.sent),
  inTransit(DeliveryStatus.inTransit),
  delivered(DeliveryStatus.delivered);

  const DeliveryTab(this.status);

  /// Sent to the server as `deliveryStatus`; null for *Tous*.
  final DeliveryStatus? status;
}

/// `Delivery overview` (Figma `660:13827`) — the web's `stock/delivery`.
///
/// The four counts come from `GET /orders/stats` (server figures, so they do
/// not follow the search); the rows from `GET /orders?deliveryStatus=` (the tab
/// filters server-side). The courier accounts are loaded alongside, to put a
/// name on each sent order — the order only carries the account's id.
class DeliveryViewModel extends BaseViewModel {
  DeliveryViewModel({required OrderRepository orders, required DeliveryRepository delivery})
      : _orders = orders,
        _delivery = delivery;

  final OrderRepository _orders;
  final DeliveryRepository _delivery;

  /// The web's page size for this list.
  static const pageSize = 100;

  List<Order> _list = const [];
  List<Order> get orders => _list;

  OrderStats? _stats;
  OrderStats? get stats => _stats;

  Map<String, DeliveryProvider> _providers = const {};

  DeliveryTab _tab = DeliveryTab.all;
  DeliveryTab get tab => _tab;

  String _search = '';
  bool get isNarrowed => _search.trim().isNotEmpty || _tab != DeliveryTab.all;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  /// The display name of the courier account that shipped [order], or null —
  /// none yet, or the account has since been deleted.
  String? providerName(Order order) => _providers[order.deliveryProvider]?.displayName;

  /// The courier behind [order] (`yalidine`…), for the tracking sheet's header.
  String? courierOf(Order order) => _providers[order.deliveryProvider]?.provider;

  Future<void> load() async {
    final tab = _tab;
    final search = _search;
    // The counts and the courier names are annotations: if they fail, the
    // list still shows. Only the list itself can fail the screen.
    final side = Future.wait([_orders.stats(), _delivery.providers()]);
    await run(
      () => _orders.list(search: search, deliveryStatus: tab.status, limit: pageSize),
      onSuccess: (page) {
        if (tab != _tab || search != _search) return; // a newer request owns the screen
        // *Prêt* agrees with its count: a cancelled or returned order is never
        // sent, so it does not wait in the ready column (the web's own filter).
        _list = tab == DeliveryTab.ready
            ? page.orders.where((o) => !o.status.isTerminal).toList(growable: false)
            : page.orders;
      },
      silent: _loadedOnce,
      tag: 'delivery',
    );
    final [stats, providers] = await side;
    if (isDisposed) return;
    if (stats case Success(:final value)) _stats = value as OrderStats;
    if (providers case Success(:final value)) {
      _providers = {for (final p in value as List<DeliveryProvider>) p.id: p};
    }
    _loadedOnce = true;
    safeNotify();
  }

  void setTab(DeliveryTab value) {
    if (value == _tab) return;
    _tab = value;
    safeNotify();
    load();
  }

  void setSearch(String value) {
    if (value == _search) return;
    _search = value;
    load();
  }

  /// After a parcel went out: the row and the counts both moved.
  void replace(Order updated) {
    _list = [for (final o in _list) o.id == updated.id ? updated : o];
    safeNotify();
    load();
  }

  Future<Result<ParcelTracking>> track(Order order) => _delivery.track(order.id);

  Future<Result<ShippingLabel>> label(Order order) => _delivery.label(order.id);
}
