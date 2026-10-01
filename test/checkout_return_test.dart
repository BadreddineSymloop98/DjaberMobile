import 'package:djaber_mobile/presentation/screens/settings/checkout_web_view_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// How the payment page knows the merchant is done with Chargily.
///
/// The URLs are the ones Chargily's test checkout produced on 2026-09-29.
void main() {
  group("Chargily's own result page", () {
    // Chargily sends the web view here first, over plain HTTP. Android blocks
    // cleartext, so the page never loads and its "back to djaber" link — the
    // dashboard URL — is never reached. The page was left open on an error.
    test('a failure is read from the URL, before it loads', () {
      expect(
        CheckoutWebViewScreen.readReturn(
          'http://pay.chargily.dz/test/payments/failure/01m3p4z5jesxntnw2dq09qehkc'
          '?expires=1790672295&signature=a8d3d546bcff1ae39eeadd2f5867b07de0fb5b980240e459a54877b87b820375',
        ),
        CheckoutReturn.failed,
      );
    });

    test('a success is read the same way', () {
      expect(
        CheckoutWebViewScreen.readReturn(
          'http://pay.chargily.dz/test/payments/success/01m3p4z5jesxntnw2dq09qehkc?expires=1&signature=x',
        ),
        CheckoutReturn.success,
      );
    });

    test("Chargily's own Cancel and Expire end it too, as a failure", () {
      expect(
        CheckoutWebViewScreen.readReturn(
          'http://pay.chargily.dz/test/payments/cancellation/01m3p573x99w41maxtdrjg4gvn?expires=1&signature=x',
        ),
        CheckoutReturn.failed,
      );
      expect(
        CheckoutWebViewScreen.readReturn(
          'http://pay.chargily.dz/test/payments/expiration/01m3p587f15ww84v5h8ecjv7yb?expires=1&signature=x',
        ),
        CheckoutReturn.failed,
      );
    });

    test('live mode and HTTPS are read too', () {
      expect(
        CheckoutWebViewScreen.readReturn('https://pay.chargily.dz/payments/success/01abc?expires=1&signature=x'),
        CheckoutReturn.success,
      );
      expect(
        CheckoutWebViewScreen.readReturn('https://pay.chargily.com/payments/failure/01abc'),
        CheckoutReturn.failed,
      );
    });

    test('the same path on another host is not taken for Chargily', () {
      expect(CheckoutWebViewScreen.readReturn('https://example.com/payments/success/01abc'), isNull);
    });
  });

  group("the merchant's return URL", () {
    test('is still read, with the checkout id Chargily appends', () {
      expect(
        CheckoutWebViewScreen.readReturn(
          'https://djaber.vercel.app/dashboard?section=settings&payment=failed&checkout_id=01m3p4z5jesxntnw2dq09qehkc',
        ),
        CheckoutReturn.failed,
      );
      expect(
        CheckoutWebViewScreen.readReturn('https://djaber.vercel.app/dashboard?section=settings&payment=success'),
        CheckoutReturn.success,
      );
    });
  });

  group('pages that are part of paying', () {
    test('are not a return', () {
      expect(
        CheckoutWebViewScreen.readReturn('https://pay.chargily.dz/test/checkouts/01m3p4x2b3djvjyzbnjtw0jzmy/pay'),
        isNull,
      );
      expect(CheckoutWebViewScreen.readReturn('https://chargily.com/business/pay/tos/consumer'), isNull);
    });
  });
}
