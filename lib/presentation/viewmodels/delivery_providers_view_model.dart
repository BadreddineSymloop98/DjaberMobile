import '../../core/error/app_exception.dart';
import '../../core/error/result.dart';
import '../../data/models/delivery.dart';
import '../../data/repositories/delivery_repository.dart';
import 'base_view_model.dart';

/// `Delivery providers` (Figma `662:14400`) — the web's `stock/delivery/settings`.
class DeliveryProvidersViewModel extends BaseViewModel {
  DeliveryProvidersViewModel({required DeliveryRepository delivery}) : _delivery = delivery;

  final DeliveryRepository _delivery;

  List<DeliveryProvider> _providers = const [];
  List<DeliveryProvider> get providers => _providers;

  Map<String, CourierSchema> _couriers = const {};
  List<Wilaya> _wilayas = const [];

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  /// `Yalidine`, `ZR Express` — the courier's own name for *Transporteur :*.
  String courierName(String id) => _couriers[id]?.name ?? id;

  Wilaya? wilaya(int? id) => id == null ? null : _wilayas.where((w) => w.id == id).firstOrNull;

  Future<void> load() async {
    // Names and wilayas are labels; only the accounts can fail the screen.
    final side = Future.wait([_delivery.couriers(), _delivery.wilayas()]);
    await run(
      _delivery.providers,
      onSuccess: (value) => _providers = value,
      silent: _loadedOnce,
      tag: 'deliveryProviders',
    );
    final [couriers, wilayas] = await side;
    if (isDisposed) return;
    if (couriers case Success(:final value)) {
      _couriers = {for (final c in value as List<CourierSchema>) c.id: c};
    }
    if (wilayas case Success(:final value)) _wilayas = value as List<Wilaya>;
    _loadedOnce = true;
    safeNotify();
  }

  final Set<String> _deleting = {};

  /// A delete is running for [provider] — its card is busy and inert.
  bool isDeleting(DeliveryProvider provider) => _deleting.contains(provider.id);

  /// `DELETE /delivery/providers/{id}`. A second tap while one runs is ignored.
  ///
  /// A 404 means the account was already removed elsewhere (the web, another
  /// handset): the card goes too, and the caller says so rather than showing
  /// an error for something that is, in effect, done.
  Future<DeleteOutcome> delete(DeliveryProvider provider) async {
    if (!_deleting.add(provider.id)) return const DeleteOutcome.ignored();
    safeNotify();
    final result = await _delivery.deleteProvider(provider.id);
    if (isDisposed) return const DeleteOutcome.ignored();
    _deleting.remove(provider.id);
    final error = result.errorOrNull;
    final gone = error == null || error is NotFoundException;
    if (gone) _providers = [for (final p in _providers) if (p.id != provider.id) p];
    safeNotify();
    if (error == null) return const DeleteOutcome.deleted();
    return error is NotFoundException ? const DeleteOutcome.alreadyGone() : DeleteOutcome.failed(error);
  }
}

/// How a delete ended, for the screen's toast.
class DeleteOutcome {
  const DeleteOutcome.deleted() : kind = DeleteKind.deleted, error = null;
  const DeleteOutcome.alreadyGone() : kind = DeleteKind.alreadyGone, error = null;
  const DeleteOutcome.ignored() : kind = DeleteKind.ignored, error = null;
  const DeleteOutcome.failed(this.error) : kind = DeleteKind.failed;

  final DeleteKind kind;
  final AppException? error;
}

enum DeleteKind { deleted, alreadyGone, ignored, failed }
