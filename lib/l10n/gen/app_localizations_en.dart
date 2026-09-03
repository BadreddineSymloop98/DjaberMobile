// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Djaber.ai';

  @override
  String get appTagline => 'Social AI Agent';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDismiss => 'Dismiss';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonEmpty => 'Nothing here';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonStart => 'Get started';

  @override
  String get onboardingAnswersTitle => 'The agent replies to your customers';

  @override
  String get onboardingAnswersBody =>
      'It knows your catalogue, your stock and your prices. It answers Facebook and Instagram messages for you, day and night.';

  @override
  String get onboardingEscalationTitle => 'You step in when it is needed';

  @override
  String get onboardingEscalationBody =>
      'When the AI can no longer follow, it stops and tells you. You reply from your phone, then hand the conversation back to it.';

  @override
  String get onboardingStockTitle => 'Your stock in your pocket';

  @override
  String get onboardingStockBody =>
      'Products, purchases, sales and orders. Check a quantity while the customer waits, and correct it on the spot.';

  @override
  String get onboardingSampleCustomer => 'Amina B.';

  @override
  String get onboardingSampleMessage => 'Is the black one available in M?';

  @override
  String get onboardingSampleReply =>
      'Yes — 4 left in M. Delivery to Oran is 600 DA.';

  @override
  String get onboardingSampleEscalation =>
      'The customer is asking for a refund.';

  @override
  String get onboardingSampleNeedsHuman => 'Needs you';

  @override
  String get onboardingSampleHandling => 'Agent handling';

  @override
  String get onboardingShortcutProducts => 'Products';

  @override
  String get onboardingShortcutOrders => 'Orders';

  @override
  String get onboardingShortcutMovements => 'Movements';

  @override
  String get errorNetwork => 'No connection. Check your network and try again.';

  @override
  String get errorTimeout => 'The request took too long.';

  @override
  String get errorUnauthorized => 'Your session expired. Sign in again.';

  @override
  String get errorNotFound => 'Not found.';

  @override
  String get errorServer => 'Something went wrong on our side.';

  @override
  String get errorUnknown => 'Something went wrong.';

  @override
  String get langEnglish => 'English';

  @override
  String get langFrench => 'Français';

  @override
  String get langArabic => 'العربية';

  @override
  String get obStockValue => '1.24';

  @override
  String get obStockValueUnit => 'M DA';

  @override
  String get obStockValueLabel => 'Stock value';

  @override
  String get obKpiProducts => 'Products';

  @override
  String get obKpiProductsValue => '128';

  @override
  String get obKpiPurchases => 'Purchases';

  @override
  String get obKpiPurchasesValue => '6';

  @override
  String get obKpiSales => 'Sales';

  @override
  String get obKpiSalesValue => '24';

  @override
  String get obKpiOrders => 'Ord';

  @override
  String get obKpiOrdersValue => '12';

  @override
  String get obInStock => 'In stock';

  @override
  String get obStockRow1Name => 'Satin dress — Black — M';

  @override
  String get obStockRow1Meta => 'Threshold 5 · Out of stock';

  @override
  String get obStockRow1Qty => '0';

  @override
  String get obStockRow2Name => 'Oud perfume 50 ml';

  @override
  String get obStockRow2Meta => 'Threshold 10';

  @override
  String get obStockRow2Qty => '3';

  @override
  String get obStockRow3Name => 'Leather bag — Camel';

  @override
  String get obStockRow3Meta => 'Threshold 5';

  @override
  String get obStockRow3Qty => '7';

  @override
  String get obEsc1Kind => 'AI stuck';

  @override
  String get obEsc1Time => '2 min';

  @override
  String get obEsc1Name => 'Amina B.';

  @override
  String get obEsc1Body => 'She wants to change the size — order already paid.';

  @override
  String get obEsc2Kind => 'Order to approve';

  @override
  String get obEsc2Time => '18 min';

  @override
  String get obEsc2Name => '#1042 — Bab Ezzouar';

  @override
  String get obEsc2Body => '2,400 DA · created by the AI';

  @override
  String get obEsc3Kind => 'Out of stock';

  @override
  String get obEsc3Time => '1 h';

  @override
  String get obEsc3Name => 'Satin dress — Black — M';

  @override
  String get obEsc3Body => '0 in stock · 3 orders waiting';

  @override
  String get obEsc4Kind => 'Negotiation';

  @override
  String get obEsc4Time => '3 h';

  @override
  String get obEsc4Name => 'Sofiane K.';

  @override
  String get obEsc4Body => 'ndir lik 2 000 DA w nakhdo';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authLoginSubtitle => 'Sign in to your account to continue';

  @override
  String get authSignupTitle => 'Create account';

  @override
  String get authSignupSubtitle => 'Get started in less than a minute';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authFirstName => 'First name';

  @override
  String get authLastName => 'Last name';

  @override
  String get authPasswordHint => 'At least 8 characters';

  @override
  String get authRemember => 'Remember me';

  @override
  String get authLoginSubmit => 'Sign In';

  @override
  String get authSignupSubmit => 'Create account';

  @override
  String get authForgot => 'Forgot your password?';

  @override
  String get authNoAccount => 'Don’t have an account?';

  @override
  String get authSignupLink => 'Get started';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authSigninLink => 'Sign In';

  @override
  String get authEmailPlaceholder => 'you@example.com';

  @override
  String get authFirstNamePlaceholder => 'Jane';

  @override
  String get authLastNamePlaceholder => 'Doe';

  @override
  String get authErrEmailRequired => 'Email is required';

  @override
  String get authErrInvalidEmail => 'Please enter a valid email address';

  @override
  String get authErrPasswordRequired => 'Password is required';

  @override
  String get authErrPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get authErrFirstNameRequired => 'First name is required';

  @override
  String get authErrLastNameRequired => 'Last name is required';
}
