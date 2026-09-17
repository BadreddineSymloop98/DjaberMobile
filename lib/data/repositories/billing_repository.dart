import '../../core/constants/api_endpoints.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client.dart';
import '../models/plan.dart';

/// Plans and paying for one — `11 — Paramètres`' Plan & facturation.
class BillingRepository {
  BillingRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  /// `GET /api/plans` → `{ plans }`. Public; no side effects.
  Future<Result<List<Plan>>> plans() => _api.get<List<Plan>>(
        Api.plans,
        parse: (json) {
          final rows = (json as Map<String, dynamic>)['plans'];
          if (rows is! List) return const <Plan>[];
          return rows.whereType<Map<String, dynamic>>().map(Plan.fromJson).toList(growable: false);
        },
      );

  /// `POST /api/payments/checkout` — creates a Chargily checkout. Nothing is
  /// written until Chargily reports the payment; `400` for a free plan.
  Future<Result<CheckoutSession>> checkout({required String planSlug, required BillingCycle cycle}) =>
      _api.post<CheckoutSession>(
        Api.paymentsCheckout,
        body: {'planSlug': planSlug, 'billingCycle': cycle.wire},
        parse: (json) => CheckoutSession.fromJson(json as Map<String, dynamic>),
      );

  /// `GET /api/payments/verify/{checkoutId}`.
  ///
  /// **Call it once per checkout.** Per the live docs it is not idempotent: on
  /// a paid checkout every call inserts another subscription and resets the
  /// credit counter again. The webhook activates the plan anyway, so a
  /// `pending` answer is not polled.
  Future<Result<CheckoutStatus>> verify(String checkoutId) => _api.get<CheckoutStatus>(
        Api.paymentVerify(checkoutId),
        parse: (json) => checkoutStatusOf((json as Map<String, dynamic>)['status']),
      );
}
