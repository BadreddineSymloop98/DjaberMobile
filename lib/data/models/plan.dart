import '../../core/utils/json.dart';

/// `monthly` / `yearly` — the web's billing toggle and the checkout's
/// `billingCycle`.
enum BillingCycle {
  monthly('monthly'),
  yearly('yearly');

  const BillingCycle(this.wire);

  final String wire;
}

/// One subscription plan from `GET /api/plans` — public, active plans only,
/// in the admin's order.
///
/// Prices arrive as Decimal strings (`"2900"`); `currency` is a display label
/// (`DA`). `name`, `features` and `description` are whatever the admin typed —
/// French on the live backend, whatever `Accept-Language` says. Kept here as
/// sent; `PlanCopy` in the settings screen translates what it recognises.
class Plan {
  const Plan({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    this.priceMonthly = 0,
    this.priceYearly = 0,
    this.currency = 'DA',
    this.features = const [],
    this.isFeatured = false,
  });

  final String id;

  /// Matches `User.plan` — `individual`, `pro`, `teams`.
  final String slug;
  final String name;
  final String? description;
  final double priceMonthly;
  final double priceYearly;
  final String currency;
  final List<String> features;

  /// Shown as `POPULAIRE` when it is not the merchant's own plan.
  final bool isFeatured;

  double priceFor(BillingCycle cycle) => cycle == BillingCycle.yearly ? priceYearly : priceMonthly;

  factory Plan.fromJson(Map<String, dynamic> json) {
    final features = json['features'];
    return Plan(
      id: Json.str(json['id']),
      slug: Json.str(json['slug']),
      name: Json.str(json['name']),
      description: Json.strOrNull(json['description']),
      priceMonthly: Json.dbl(json['priceMonthly']),
      priceYearly: Json.dbl(json['priceYearly']),
      currency: Json.strOrNull(json['currency']) ?? 'DA',
      features: features is List ? features.whereType<String>().toList(growable: false) : const [],
      isFeatured: Json.boolOf(json['isFeatured']),
    );
  }
}

/// `POST /api/payments/checkout` → `{ checkoutUrl, checkoutId }` — a hosted
/// Chargily Pay page.
class CheckoutSession {
  const CheckoutSession({required this.checkoutUrl, required this.checkoutId});

  final String checkoutUrl;
  final String checkoutId;

  factory CheckoutSession.fromJson(Map<String, dynamic> json) => CheckoutSession(
        checkoutUrl: Json.str(json['checkoutUrl']),
        checkoutId: Json.str(json['checkoutId']),
      );
}

/// Chargily's checkout statuses, plus the verify endpoint's own `unknown`.
enum CheckoutStatus { paid, pending, failed, canceled, expired, unknown }

CheckoutStatus checkoutStatusOf(Object? wire) => switch (wire) {
      'paid' => CheckoutStatus.paid,
      'pending' => CheckoutStatus.pending,
      'failed' => CheckoutStatus.failed,
      'canceled' || 'cancelled' => CheckoutStatus.canceled,
      'expired' => CheckoutStatus.expired,
      _ => CheckoutStatus.unknown,
    };
