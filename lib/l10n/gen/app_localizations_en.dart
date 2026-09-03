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
  String get onboardingEscalationTitle => 'You step in when it matters';

  @override
  String get onboardingEscalationBody =>
      'When the agent can no longer carry a conversation, your phone rings. You take over, reply, and hand it back.';

  @override
  String get onboardingStockTitle => 'Your stock in your pocket';

  @override
  String get onboardingStockBody =>
      'Check availability, correct a count, receive a delivery — without going back to a desk.';

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
}
