import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// Product name. Never translated. The wordmark renders 'Djaber' in primary text and '.ai' in secondary.
  ///
  /// In en, this message translates to:
  /// **'Djaber.ai'**
  String get appName;

  /// From dash.tagline in src/lib/i18n.ts.
  ///
  /// In en, this message translates to:
  /// **'Social AI Agent'**
  String get appTagline;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @commonEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get commonEmpty;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get commonStart;

  /// No description provided for @onboardingAnswersTitle.
  ///
  /// In en, this message translates to:
  /// **'The agent replies to your customers'**
  String get onboardingAnswersTitle;

  /// No description provided for @onboardingAnswersBody.
  ///
  /// In en, this message translates to:
  /// **'It knows your catalogue, your stock and your prices. It answers Facebook and Instagram messages for you, day and night.'**
  String get onboardingAnswersBody;

  /// No description provided for @onboardingEscalationTitle.
  ///
  /// In en, this message translates to:
  /// **'You step in when it is needed'**
  String get onboardingEscalationTitle;

  /// No description provided for @onboardingEscalationBody.
  ///
  /// In en, this message translates to:
  /// **'When the AI can no longer follow, it stops and tells you. You reply from your phone, then hand the conversation back to it.'**
  String get onboardingEscalationBody;

  /// No description provided for @onboardingStockTitle.
  ///
  /// In en, this message translates to:
  /// **'Your stock in your pocket'**
  String get onboardingStockTitle;

  /// No description provided for @onboardingStockBody.
  ///
  /// In en, this message translates to:
  /// **'Products, purchases, sales and orders. Check a quantity while the customer waits, and correct it on the spot.'**
  String get onboardingStockBody;

  /// Placeholder customer name in the onboarding artwork. Not a real person.
  ///
  /// In en, this message translates to:
  /// **'Amina B.'**
  String get onboardingSampleCustomer;

  /// No description provided for @onboardingSampleMessage.
  ///
  /// In en, this message translates to:
  /// **'Is the black one available in M?'**
  String get onboardingSampleMessage;

  /// No description provided for @onboardingSampleReply.
  ///
  /// In en, this message translates to:
  /// **'Yes — 4 left in M. Delivery to Oran is 600 DA.'**
  String get onboardingSampleReply;

  /// No description provided for @onboardingSampleEscalation.
  ///
  /// In en, this message translates to:
  /// **'The customer is asking for a refund.'**
  String get onboardingSampleEscalation;

  /// No description provided for @onboardingSampleNeedsHuman.
  ///
  /// In en, this message translates to:
  /// **'Needs you'**
  String get onboardingSampleNeedsHuman;

  /// No description provided for @onboardingSampleHandling.
  ///
  /// In en, this message translates to:
  /// **'Agent handling'**
  String get onboardingSampleHandling;

  /// No description provided for @onboardingShortcutProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get onboardingShortcutProducts;

  /// No description provided for @onboardingShortcutOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get onboardingShortcutOrders;

  /// No description provided for @onboardingShortcutMovements.
  ///
  /// In en, this message translates to:
  /// **'Movements'**
  String get onboardingShortcutMovements;

  /// NetworkException. Shown with a retry action — this market drops connections constantly, so it must not read like a fatal error.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Sign in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get errorNotFound;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side.'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorUnknown;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get langFrench;

  /// Language names always appear in their own language, matching LANGS in src/lib/i18n.ts.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get langArabic;

  /// No description provided for @obStockValue.
  ///
  /// In en, this message translates to:
  /// **'1.24'**
  String get obStockValue;

  /// No description provided for @obStockValueUnit.
  ///
  /// In en, this message translates to:
  /// **'M DA'**
  String get obStockValueUnit;

  /// No description provided for @obStockValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock value'**
  String get obStockValueLabel;

  /// No description provided for @obKpiProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get obKpiProducts;

  /// No description provided for @obKpiProductsValue.
  ///
  /// In en, this message translates to:
  /// **'128'**
  String get obKpiProductsValue;

  /// No description provided for @obKpiPurchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get obKpiPurchases;

  /// No description provided for @obKpiPurchasesValue.
  ///
  /// In en, this message translates to:
  /// **'6'**
  String get obKpiPurchasesValue;

  /// No description provided for @obKpiSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get obKpiSales;

  /// No description provided for @obKpiSalesValue.
  ///
  /// In en, this message translates to:
  /// **'24'**
  String get obKpiSalesValue;

  /// No description provided for @obKpiOrders.
  ///
  /// In en, this message translates to:
  /// **'Ord'**
  String get obKpiOrders;

  /// No description provided for @obKpiOrdersValue.
  ///
  /// In en, this message translates to:
  /// **'12'**
  String get obKpiOrdersValue;

  /// No description provided for @obInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get obInStock;

  /// No description provided for @obStockRow1Name.
  ///
  /// In en, this message translates to:
  /// **'Satin dress — Black — M'**
  String get obStockRow1Name;

  /// No description provided for @obStockRow1Meta.
  ///
  /// In en, this message translates to:
  /// **'Threshold 5 · Out of stock'**
  String get obStockRow1Meta;

  /// No description provided for @obStockRow1Qty.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get obStockRow1Qty;

  /// No description provided for @obStockRow2Name.
  ///
  /// In en, this message translates to:
  /// **'Oud perfume 50 ml'**
  String get obStockRow2Name;

  /// No description provided for @obStockRow2Meta.
  ///
  /// In en, this message translates to:
  /// **'Threshold 10'**
  String get obStockRow2Meta;

  /// No description provided for @obStockRow2Qty.
  ///
  /// In en, this message translates to:
  /// **'3'**
  String get obStockRow2Qty;

  /// No description provided for @obStockRow3Name.
  ///
  /// In en, this message translates to:
  /// **'Leather bag — Camel'**
  String get obStockRow3Name;

  /// No description provided for @obStockRow3Meta.
  ///
  /// In en, this message translates to:
  /// **'Threshold 5'**
  String get obStockRow3Meta;

  /// No description provided for @obStockRow3Qty.
  ///
  /// In en, this message translates to:
  /// **'7'**
  String get obStockRow3Qty;

  /// No description provided for @obEsc1Kind.
  ///
  /// In en, this message translates to:
  /// **'AI stuck'**
  String get obEsc1Kind;

  /// No description provided for @obEsc1Time.
  ///
  /// In en, this message translates to:
  /// **'2 min'**
  String get obEsc1Time;

  /// No description provided for @obEsc1Name.
  ///
  /// In en, this message translates to:
  /// **'Amina B.'**
  String get obEsc1Name;

  /// No description provided for @obEsc1Body.
  ///
  /// In en, this message translates to:
  /// **'She wants to change the size — order already paid.'**
  String get obEsc1Body;

  /// No description provided for @obEsc2Kind.
  ///
  /// In en, this message translates to:
  /// **'Order to approve'**
  String get obEsc2Kind;

  /// No description provided for @obEsc2Time.
  ///
  /// In en, this message translates to:
  /// **'18 min'**
  String get obEsc2Time;

  /// No description provided for @obEsc2Name.
  ///
  /// In en, this message translates to:
  /// **'#1042 — Bab Ezzouar'**
  String get obEsc2Name;

  /// No description provided for @obEsc2Body.
  ///
  /// In en, this message translates to:
  /// **'2,400 DA · created by the AI'**
  String get obEsc2Body;

  /// No description provided for @obEsc3Kind.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get obEsc3Kind;

  /// No description provided for @obEsc3Time.
  ///
  /// In en, this message translates to:
  /// **'1 h'**
  String get obEsc3Time;

  /// No description provided for @obEsc3Name.
  ///
  /// In en, this message translates to:
  /// **'Satin dress — Black — M'**
  String get obEsc3Name;

  /// No description provided for @obEsc3Body.
  ///
  /// In en, this message translates to:
  /// **'0 in stock · 3 orders waiting'**
  String get obEsc3Body;

  /// No description provided for @obEsc4Kind.
  ///
  /// In en, this message translates to:
  /// **'Negotiation'**
  String get obEsc4Kind;

  /// No description provided for @obEsc4Time.
  ///
  /// In en, this message translates to:
  /// **'3 h'**
  String get obEsc4Time;

  /// No description provided for @obEsc4Name.
  ///
  /// In en, this message translates to:
  /// **'Sofiane K.'**
  String get obEsc4Name;

  /// No description provided for @obEsc4Body.
  ///
  /// In en, this message translates to:
  /// **'ndir lik 2 000 DA w nakhdo'**
  String get obEsc4Body;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account to continue'**
  String get authLoginSubtitle;

  /// No description provided for @authSignupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignupTitle;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get started in less than a minute'**
  String get authSignupSubtitle;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get authFirstName;

  /// No description provided for @authLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get authLastName;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authPasswordHint;

  /// No description provided for @authRemember.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get authRemember;

  /// No description provided for @authLoginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authLoginSubmit;

  /// No description provided for @authSignupSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignupSubmit;

  /// No description provided for @authForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get authForgot;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account?'**
  String get authNoAccount;

  /// No description provided for @authSignupLink.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get authSignupLink;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authSigninLink.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSigninLink;

  /// No description provided for @authEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authEmailPlaceholder;

  /// No description provided for @authFirstNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Jane'**
  String get authFirstNamePlaceholder;

  /// No description provided for @authLastNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Doe'**
  String get authLastNamePlaceholder;

  /// No description provided for @authErrEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get authErrEmailRequired;

  /// No description provided for @authErrInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get authErrInvalidEmail;

  /// No description provided for @authErrPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authErrPasswordRequired;

  /// No description provided for @authErrPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get authErrPasswordTooShort;

  /// No description provided for @authErrFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get authErrFirstNameRequired;

  /// No description provided for @authErrLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get authErrLastNameRequired;

  /// No description provided for @authForgotBack.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get authForgotBack;

  /// No description provided for @authForgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotTitle;

  /// No description provided for @authForgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a reset link'**
  String get authForgotSubtitle;

  /// No description provided for @authForgotEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authForgotEmail;

  /// No description provided for @authForgotEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'you@company.com'**
  String get authForgotEmailPlaceholder;

  /// No description provided for @authForgotSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get authForgotSubmit;

  /// No description provided for @authForgotSecure.
  ///
  /// In en, this message translates to:
  /// **'Your password reset link is encrypted and expires in 1 hour'**
  String get authForgotSecure;

  /// No description provided for @authForgotRemember.
  ///
  /// In en, this message translates to:
  /// **'Remember your password?'**
  String get authForgotRemember;

  /// No description provided for @authSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get authSentTitle;

  /// No description provided for @authSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We’ve sent a password reset link to'**
  String get authSentMessage;

  /// No description provided for @authSentNoReceive.
  ///
  /// In en, this message translates to:
  /// **'Didn’t receive the email?'**
  String get authSentNoReceive;

  /// No description provided for @authSentTryAnother.
  ///
  /// In en, this message translates to:
  /// **'Try another email address'**
  String get authSentTryAnother;

  /// No description provided for @authErrInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get authErrInvalidCredentials;

  /// No description provided for @authErrUserExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists'**
  String get authErrUserExists;

  /// No description provided for @authErrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server. Check your connection.'**
  String get authErrNetwork;

  /// No description provided for @authErrUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrUnknown;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String homeWelcome(String name);

  /// From menu.signout in src/lib/i18n.ts. Currently on the home stub as a temporary control; belongs in the hamburger menu (brief §16, tier 3) once that exists.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get menuSignOut;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return L10nAr();
    case 'en':
      return L10nEn();
    case 'fr':
      return L10nFr();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
