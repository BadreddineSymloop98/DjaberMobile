import '../../core/error/app_exception.dart';
import '../../data/models/plan.dart';
import '../../data/repositories/billing_repository.dart';
import 'base_view_model.dart';

/// `11 — Paramètres` — the part of it that talks to the backend: the plans
/// and paying for one. The stock mode is [StockModeViewModel]; the account
/// fields are the session's user, read-only as on the web (there is no
/// endpoint that updates them).
class SettingsViewModel extends BaseViewModel {
  SettingsViewModel({required BillingRepository billing}) : _billing = billing;

  final BillingRepository _billing;

  List<Plan> _plans = const [];
  List<Plan> get plans => _plans;

  bool _loadedOnce = false;
  bool get isFirstLoad => !_loadedOnce;

  BillingCycle _cycle = BillingCycle.monthly;
  BillingCycle get cycle => _cycle;

  String? _subscribingSlug;
  CheckoutPhase _phase = CheckoutPhase.none;

  /// The plan whose checkout is running — its button says so. Set from
  /// creating the checkout until [endCheckout], so it covers the payment page
  /// *and* asking how it ended.
  String? get subscribingSlug => _subscribingSlug;

  CheckoutPhase get checkoutPhase => _phase;

  /// True while any checkout is running; every plan's button is locked, so a
  /// second tap cannot start a second checkout.
  bool get isSubscribing => _subscribingSlug != null;

  AppException? _checkoutError;
  AppException? get checkoutError => _checkoutError;

  Future<void> load() async {
    await run(
      _billing.plans,
      onSuccess: (rows) => _plans = rows,
      isEmpty: () => _plans.isEmpty,
      silent: _loadedOnce,
      tag: 'plans',
    );
    _loadedOnce = true;
    safeNotify();
  }

  void setCycle(BillingCycle cycle) {
    if (_cycle == cycle) return;
    _cycle = cycle;
    safeNotify();
  }

  /// Creates the checkout for [plan] in the chosen cycle. Null on failure,
  /// with [checkoutError] set and the checkout ended; null too while another
  /// one is running.
  ///
  /// On success the checkout stays running — the caller must [endCheckout].
  Future<CheckoutSession?> startCheckout(Plan plan) async {
    if (_subscribingSlug != null) return null;
    _subscribingSlug = plan.slug;
    _phase = CheckoutPhase.redirecting;
    _checkoutError = null;
    safeNotify();
    final result = await _billing.checkout(planSlug: plan.slug, cycle: _cycle);
    if (isDisposed) return null;
    final session = result.valueOrNull;
    _checkoutError = result.errorOrNull;
    if (session == null) {
      _subscribingSlug = null;
      _phase = CheckoutPhase.none;
    }
    safeNotify();
    return session;
  }

  /// Asks once how the checkout ended — see [BillingRepository.verify].
  Future<CheckoutStatus> verify(String checkoutId) async {
    _phase = CheckoutPhase.verifying;
    safeNotify();
    final result = await _billing.verify(checkoutId);
    return result.valueOrNull ?? CheckoutStatus.unknown;
  }

  /// Unlocks the plan buttons once the outcome is known and shown.
  void endCheckout() {
    if (_subscribingSlug == null) return;
    _subscribingSlug = null;
    _phase = CheckoutPhase.none;
    safeNotify();
  }
}

/// How far a checkout started from the screen has got.
enum CheckoutPhase {
  none,

  /// Creating it, then on Chargily's page.
  redirecting,

  /// Back from the page, asking the backend how it ended.
  verifying,
}
