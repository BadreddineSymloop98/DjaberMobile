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

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side.'**
  String get errorServer;

  /// Success toast after POST /api/user-stock/products. Raised on the step that did the write and read on the next one — the root ScaffoldMessenger carries it across the navigation.
  ///
  /// In en, this message translates to:
  /// **'Product created'**
  String get toastProductCreated;

  /// No description provided for @toastProductUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated'**
  String get toastProductUpdated;

  /// No description provided for @toastAgentCreated.
  ///
  /// In en, this message translates to:
  /// **'AI agent created'**
  String get toastAgentCreated;

  /// Success toast after the Facebook grant completes and the page is linked to the agent. Not raised when the merchant defers the step — nothing was written.
  ///
  /// In en, this message translates to:
  /// **'Page connected'**
  String get toastPageConnected;

  /// Shown when the backend rejected the request but did not return a message a merchant can act on — a bare status name like "Unauthorized", the global 404 handler's "Cannot GET /api/…", or an empty body. See preciseBackendMessage in core/error/backend_message.dart. Deliberately admits nothing more than that the action failed, because we genuinely do not know why.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

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
  /// **'2400 DA · created by the AI'**
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

  /// Neutral on purpose: POST /api/auth/forgot-password answers the same whether or not the account exists. Diverges from the web's 'We’ve sent a password reset link to'.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this address, a reset link has just been sent to it'**
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

  /// No description provided for @authSentResend.
  ///
  /// In en, this message translates to:
  /// **'Resend link'**
  String get authSentResend;

  /// Countdown before resend is offered: the server sends nothing new within 60 seconds of the last request.
  ///
  /// In en, this message translates to:
  /// **'Resend link in {seconds}s'**
  String authSentResendIn(int seconds);

  /// No description provided for @authSentResent.
  ///
  /// In en, this message translates to:
  /// **'A new link has been sent'**
  String get authSentResent;

  /// 08: the reset happens through the e-mail's link (the web page, or the app when Android hands the link over). Nothing on this screen leads to the reset.
  ///
  /// In en, this message translates to:
  /// **'Open the link in the e-mail to choose a new password.'**
  String get authSentNextStep;

  /// 08b — the reset screen, opened only by the e-mail's link handed to the app (App Link or the web page's intent).
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get authResetTitle;

  /// No description provided for @authResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for your account'**
  String get authResetSubtitle;

  /// No description provided for @authResetDeadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Request a new link to reset your password'**
  String get authResetDeadSubtitle;

  /// No description provided for @authResetChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking the link…'**
  String get authResetChecking;

  /// No description provided for @authResetPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authResetPasswordLabel;

  /// 08b: the new password is typed twice; the button stays disabled until both match.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authResetConfirmLabel;

  /// No description provided for @authErrPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don’t match'**
  String get authErrPasswordMismatch;

  /// No description provided for @authResetSubmit.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get authResetSubmit;

  /// No description provided for @authResetDone.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get authResetDone;

  /// No description provided for @authResetRequestNew.
  ///
  /// In en, this message translates to:
  /// **'Request a new link'**
  String get authResetRequestNew;

  /// 09a — Menu. Every nav label in this block is nav.* in src/lib/i18n.ts verbatim — the drawer is a port of the web sidebar, which is what the web itself collapses behind a hamburger below lg.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get menuOverview;

  /// No description provided for @menuInbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get menuInbox;

  /// No description provided for @menuSocial.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get menuSocial;

  /// No description provided for @menuServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get menuServices;

  /// No description provided for @menuProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get menuProducts;

  /// No description provided for @menuAgents.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get menuAgents;

  /// The web ships this sub-item active:false with a null href, so it is inert on both clients and carries menuSoon.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get menuCommercial;

  /// No description provided for @menuSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get menuSoon;

  /// No description provided for @menuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get menuNotifications;

  /// No description provided for @menuAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get menuAnalytics;

  /// No description provided for @menuReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get menuReports;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// Appended for Analyses and Rapports, which are deliberately web-only (brief §14.3) rather than unbuilt. NOT from i18n.ts — ours, and unapproved.
  ///
  /// In en, this message translates to:
  /// **'on the web'**
  String get menuWebOnly;

  /// Shown when a tutorial step turns out to be already satisfied — a taken SKU on T3, PLAN_LIMIT_REACHED on T4. Not an error: the step's goal is met, so the flow advances and says so. Ours, unapproved, like the rest of the tutorial copy.
  ///
  /// In en, this message translates to:
  /// **'Already done — moving on'**
  String get tutorialStepAlreadyDone;

  /// First press of the system back button on a root screen (home, login, onboarding, tutorial roots), where back would otherwise close the app. Root screens only. Ours, unapproved.
  ///
  /// In en, this message translates to:
  /// **'Tap back again to leave'**
  String get exitHint;

  /// Second row of the drawer's plan box. The web sidebar shows connected pages here, not credits (src/app/dashboard/layout.tsx:492) — and credits already have the header pill, so showing both was two readings of one account.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get menuPages;

  /// Meta line of the plan box. The plan name and the credit figures are read from the session, not hardcoded — the frame's 'Pro / 2 / 10' is one of four conflicting answers in the file (§23.10) and the live account is Individual.
  ///
  /// In en, this message translates to:
  /// **'Your Plan'**
  String get menuPlan;

  /// Stands in for the plan name before /auth/profile answers. An em dash rather than a guess.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get menuPlanUnknown;

  /// From menu.signout in src/lib/i18n.ts. Currently on the home stub as a temporary control; belongs in the hamburger menu (brief §16, tier 3) once that exists.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get menuSignOut;

  /// Step 1 of 4. Precedes the product step deliberately: the merchant decides how they manage stock before being asked for an initial quantity.
  ///
  /// In en, this message translates to:
  /// **'Choose your stock mode'**
  String get tutorialStepMode;

  /// No description provided for @tutorialStepProduct.
  ///
  /// In en, this message translates to:
  /// **'Create your first product'**
  String get tutorialStepProduct;

  /// No description provided for @tutorialStepAgent.
  ///
  /// In en, this message translates to:
  /// **'Create your AI agent'**
  String get tutorialStepAgent;

  /// No description provided for @tutorialStepPage.
  ///
  /// In en, this message translates to:
  /// **'Connect your page'**
  String get tutorialStepPage;

  /// No description provided for @tutorialWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Djaber.ai'**
  String get tutorialWelcomeTitle;

  /// No description provided for @tutorialWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get your shop running together. Four steps, and your agent starts answering your customers.'**
  String get tutorialWelcomeBody;

  /// No description provided for @tutorialStockTitle.
  ///
  /// In en, this message translates to:
  /// **'First, your stock'**
  String get tutorialStockTitle;

  /// No description provided for @tutorialStockBody.
  ///
  /// In en, this message translates to:
  /// **'You choose how to manage your stock, then you create your first product — name, price, quantity.'**
  String get tutorialStockBody;

  /// No description provided for @tutorialAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Then your agent'**
  String get tutorialAgentTitle;

  /// No description provided for @tutorialAgentBody.
  ///
  /// In en, this message translates to:
  /// **'Create it in three fields, connect your Facebook page, and it answers from the first question on.'**
  String get tutorialAgentBody;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// The badge on the chosen Option Card. Uppercase in the Label/Micro style; the web's settings page hardcodes its own equivalent in English, so this wording is ours.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get commonActive;

  /// The counter above the four-segment progress bar on tutorial steps T2-T5. Stored already uppercased per locale rather than upper-cased at the call site, because case does not apply in Arabic.
  ///
  /// In en, this message translates to:
  /// **'STEP {step} OF {total}'**
  String tutorialStepCounter(int step, int total);

  /// No description provided for @tutorialModeTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you manage your stock?'**
  String get tutorialModeTitle;

  /// No description provided for @tutorialModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This choice decides what you see in the app. You can change it at any time in settings.'**
  String get tutorialModeSubtitle;

  /// No description provided for @stockModeSimple.
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get stockModeSimple;

  /// No description provided for @stockModeAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get stockModeAdvanced;

  /// No description provided for @stockModeSimpleDesc.
  ///
  /// In en, this message translates to:
  /// **'Products, Categories & Orders — manage your inventory and orders without the complexity.'**
  String get stockModeSimpleDesc;

  /// No description provided for @stockModeAdvancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Full suite — Suppliers, Clients, Sales, Purchases, Caisse, Movements, Delivery & more.'**
  String get stockModeAdvancedDesc;

  /// No description provided for @stockOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock overview'**
  String get stockOverviewTitle;

  /// No description provided for @stockOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory, sales and purchase summary'**
  String get stockOverviewSubtitle;

  /// No description provided for @stockOverviewHintSimple.
  ///
  /// In en, this message translates to:
  /// **'Simple mode shows products, orders and clients. Switch to Advanced for sales, purchases, suppliers, caisse and movements.'**
  String get stockOverviewHintSimple;

  /// No description provided for @stockOverviewHintAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced mode: full ERP — sales, purchases, suppliers, caisse and stock movements are enabled.'**
  String get stockOverviewHintAdvanced;

  /// No description provided for @stockTotalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total products'**
  String get stockTotalProducts;

  /// No description provided for @stockLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get stockLowStock;

  /// No description provided for @stockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock value'**
  String get stockValue;

  /// No description provided for @stockRetailValue.
  ///
  /// In en, this message translates to:
  /// **'Retail value'**
  String get stockRetailValue;

  /// No description provided for @stockCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get stockCategories;

  /// No description provided for @stockSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get stockSuppliers;

  /// No description provided for @stockTotalItems.
  ///
  /// In en, this message translates to:
  /// **'Total items in stock'**
  String get stockTotalItems;

  /// No description provided for @stockSalesMonth.
  ///
  /// In en, this message translates to:
  /// **'Sales this month'**
  String get stockSalesMonth;

  /// No description provided for @stockTotalSales.
  ///
  /// In en, this message translates to:
  /// **'Total sales'**
  String get stockTotalSales;

  /// No description provided for @stockRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get stockRevenue;

  /// No description provided for @stockPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get stockPaid;

  /// No description provided for @stockPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get stockPending;

  /// No description provided for @stockPurchasesMonth.
  ///
  /// In en, this message translates to:
  /// **'Purchases this month'**
  String get stockPurchasesMonth;

  /// No description provided for @stockTotalPurchases.
  ///
  /// In en, this message translates to:
  /// **'Total purchases'**
  String get stockTotalPurchases;

  /// No description provided for @stockTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get stockTotalSpent;

  /// No description provided for @stockReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get stockReceived;

  /// No description provided for @stockRecentMovements.
  ///
  /// In en, this message translates to:
  /// **'Recent movements'**
  String get stockRecentMovements;

  /// No description provided for @stockMovementsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No movements recorded yet. Stock movements will appear here when products are added, sold, or adjusted.'**
  String get stockMovementsEmpty;

  /// No description provided for @stockMoveIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get stockMoveIn;

  /// No description provided for @stockMoveOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get stockMoveOut;

  /// No description provided for @stockMoveAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get stockMoveAdjustment;

  /// No description provided for @stockMoveReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get stockMoveReturn;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your account and application settings'**
  String get settingsSubtitle;

  /// No description provided for @settingsStockMode.
  ///
  /// In en, this message translates to:
  /// **'Stock management'**
  String get settingsStockMode;

  /// Settings section title for the interface language. The three options show each language's own name, with this locale's name for it underneath.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get settingsLanguageFrench;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get settingsLanguageArabic;

  /// Under the three language options: a chosen language is kept and the phone's system language is no longer followed.
  ///
  /// In en, this message translates to:
  /// **'The app stays in the language you choose, even if your phone\'s language changes.'**
  String get settingsLanguageHelp;

  /// Plan names, descriptions and features: GET /api/plans sends French admin text and ignores Accept-Language, so the app translates the texts it recognises (plan_copy.dart). Unrecognised server text is shown as sent.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get planNameIndividual;

  /// No description provided for @planNamePro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get planNamePro;

  /// No description provided for @planNameTeams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get planNameTeams;

  /// No description provided for @planDescIndividual.
  ///
  /// In en, this message translates to:
  /// **'To get started: connect your page and let the AI answer your customers.'**
  String get planDescIndividual;

  /// No description provided for @planDescPro.
  ///
  /// In en, this message translates to:
  /// **'For active sellers: vision, voice notes and more volume.'**
  String get planDescPro;

  /// No description provided for @planDescTeams.
  ///
  /// In en, this message translates to:
  /// **'For established shops: maximum volume and priority support.'**
  String get planDescTeams;

  /// No description provided for @planFeaturePages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Facebook or Instagram page} other{{count} Facebook / Instagram pages}}'**
  String planFeaturePages(int count);

  /// amount is already grouped for the locale (5 000).
  ///
  /// In en, this message translates to:
  /// **'{amount} AI credits / month'**
  String planFeatureCredits(String amount);

  /// No description provided for @planFeatureProducts.
  ///
  /// In en, this message translates to:
  /// **'{amount} products'**
  String planFeatureProducts(String amount);

  /// carriers are brand names from the server (Yalidine, ZR Express, Maystro), not translated.
  ///
  /// In en, this message translates to:
  /// **'Delivery to {count} wilayas ({carriers})'**
  String planFeatureDelivery(int count, String carriers);

  /// No description provided for @planFeatureAgentText.
  ///
  /// In en, this message translates to:
  /// **'24/7 AI agent (text)'**
  String get planFeatureAgentText;

  /// No description provided for @planFeatureAgentFull.
  ///
  /// In en, this message translates to:
  /// **'24/7 AI agent (text + images + voice)'**
  String get planFeatureAgentFull;

  /// No description provided for @planFeatureStock.
  ///
  /// In en, this message translates to:
  /// **'Stock & order management'**
  String get planFeatureStock;

  /// No description provided for @planFeatureCallConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Order confirmation by phone call'**
  String get planFeatureCallConfirmation;

  /// No description provided for @planFeatureVision.
  ///
  /// In en, this message translates to:
  /// **'Image recognition (vision)'**
  String get planFeatureVision;

  /// No description provided for @planFeatureVoiceNotes.
  ///
  /// In en, this message translates to:
  /// **'Voice notes (transcription)'**
  String get planFeatureVoiceNotes;

  /// No description provided for @planFeatureCrossSell.
  ///
  /// In en, this message translates to:
  /// **'AI cross-sell / up-sell'**
  String get planFeatureCrossSell;

  /// No description provided for @planFeatureUnlimitedProducts.
  ///
  /// In en, this message translates to:
  /// **'Unlimited products'**
  String get planFeatureUnlimitedProducts;

  /// No description provided for @planFeatureUnlimitedConversations.
  ///
  /// In en, this message translates to:
  /// **'Unlimited conversations'**
  String get planFeatureUnlimitedConversations;

  /// No description provided for @planFeatureEverythingPro.
  ///
  /// In en, this message translates to:
  /// **'Everything in Pro'**
  String get planFeatureEverythingPro;

  /// No description provided for @planFeaturePrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get planFeaturePrioritySupport;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account information'**
  String get settingsAccount;

  /// No description provided for @settingsBilling.
  ///
  /// In en, this message translates to:
  /// **'Plan & billing'**
  String get settingsBilling;

  /// No description provided for @settingsCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get settingsCurrentPlan;

  /// No description provided for @settingsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get settingsMonthly;

  /// No description provided for @settingsYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get settingsYearly;

  /// No description provided for @settingsFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get settingsFree;

  /// No description provided for @settingsPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{currency} / mo'**
  String settingsPerMonth(String currency);

  /// No description provided for @settingsPerYear.
  ///
  /// In en, this message translates to:
  /// **'{currency} / yr'**
  String settingsPerYear(String currency);

  /// No description provided for @settingsBadgeCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get settingsBadgeCurrent;

  /// No description provided for @settingsBadgePopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get settingsBadgePopular;

  /// No description provided for @settingsYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Your current plan'**
  String get settingsYourPlan;

  /// No description provided for @settingsFreeNoPayment.
  ///
  /// In en, this message translates to:
  /// **'Free — no payment needed'**
  String get settingsFreeNoPayment;

  /// The plan card's button. {price} is the grouped amount and the plan's currency label, e.g. 2,900 DA.
  ///
  /// In en, this message translates to:
  /// **'Subscribe — {price}'**
  String settingsSubscribe(String price);

  /// No description provided for @settingsRedirecting.
  ///
  /// In en, this message translates to:
  /// **'Redirecting…'**
  String get settingsRedirecting;

  /// No description provided for @settingsVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying payment…'**
  String get settingsVerifying;

  /// No description provided for @settingsNoPlans.
  ///
  /// In en, this message translates to:
  /// **'No plans available yet.'**
  String get settingsNoPlans;

  /// No description provided for @settingsCheckoutPaid.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed — your {plan} plan is active.'**
  String settingsCheckoutPaid(String plan);

  /// No description provided for @settingsCheckoutPending.
  ///
  /// In en, this message translates to:
  /// **'Payment not confirmed yet. If it went through, your plan will be activated shortly.'**
  String get settingsCheckoutPending;

  /// No description provided for @settingsCheckoutFailed.
  ///
  /// In en, this message translates to:
  /// **'The payment did not go through.'**
  String get settingsCheckoutFailed;

  /// No description provided for @settingsFbTitle.
  ///
  /// In en, this message translates to:
  /// **'Facebook API permissions'**
  String get settingsFbTitle;

  /// No description provided for @settingsFbActive.
  ///
  /// In en, this message translates to:
  /// **'Currently active permissions'**
  String get settingsFbActive;

  /// No description provided for @settingsFbAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available advanced permissions'**
  String get settingsFbAvailable;

  /// No description provided for @settingsFbReviewHint.
  ///
  /// In en, this message translates to:
  /// **'These permissions require Facebook App Review approval.'**
  String get settingsFbReviewHint;

  /// No description provided for @settingsDangerTitle.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get settingsDangerTitle;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteHelp.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and all associated data.'**
  String get settingsDeleteHelp;

  /// No description provided for @inboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inboxTitle;

  /// No description provided for @inboxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read and reply to your customer messages.'**
  String get inboxSubtitle;

  /// No description provided for @inboxNoPagesTitle.
  ///
  /// In en, this message translates to:
  /// **'No pages connected'**
  String get inboxNoPagesTitle;

  /// No description provided for @inboxNoPagesBody.
  ///
  /// In en, this message translates to:
  /// **'Connect a Facebook or Instagram page to start receiving messages here.'**
  String get inboxNoPagesBody;

  /// No description provided for @inboxConnectPage.
  ///
  /// In en, this message translates to:
  /// **'Connect a page'**
  String get inboxConnectPage;

  /// No description provided for @inboxPlatformMessenger.
  ///
  /// In en, this message translates to:
  /// **'Messenger'**
  String get inboxPlatformMessenger;

  /// No description provided for @inboxPlatformInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram DMs'**
  String get inboxPlatformInstagram;

  /// No description provided for @inboxSynced.
  ///
  /// In en, this message translates to:
  /// **'synced {time}'**
  String inboxSynced(String time);

  /// No description provided for @inboxSwitchPage.
  ///
  /// In en, this message translates to:
  /// **'Switch page'**
  String get inboxSwitchPage;

  /// No description provided for @inboxConnectAnother.
  ///
  /// In en, this message translates to:
  /// **'Connect another page'**
  String get inboxConnectAnother;

  /// No description provided for @inboxSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get inboxSync;

  /// No description provided for @inboxSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get inboxSyncing;

  /// No description provided for @inboxTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get inboxTabAll;

  /// No description provided for @inboxTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get inboxTabActive;

  /// No description provided for @inboxTabResolved.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get inboxTabResolved;

  /// No description provided for @inboxTabArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get inboxTabArchived;

  /// No description provided for @inboxSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or message…'**
  String get inboxSearchHint;

  /// No description provided for @inboxNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get inboxNoMatches;

  /// No description provided for @inboxNoConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get inboxNoConversations;

  /// No description provided for @inboxNothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this view'**
  String get inboxNothingHere;

  /// No description provided for @inboxPullFromFacebook.
  ///
  /// In en, this message translates to:
  /// **'Pull from Facebook'**
  String get inboxPullFromFacebook;

  /// No description provided for @inboxUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get inboxUpToDate;

  /// No description provided for @inboxSyncedCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Synced — 1 new message} other{Synced — {n} new messages}}'**
  String inboxSyncedCount(int n);

  /// No description provided for @inboxAttachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get inboxAttachment;

  /// No description provided for @inboxEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Empty message'**
  String get inboxEmptyMessage;

  /// Mobile addition, not on the web inbox: the AI handed the conversation over (Conversation.aiPaused).
  ///
  /// In en, this message translates to:
  /// **'AI paused'**
  String get inboxAiPaused;

  /// No description provided for @inboxStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get inboxStatusActive;

  /// No description provided for @inboxStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get inboxStatusResolved;

  /// No description provided for @inboxStatusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get inboxStatusArchived;

  /// No description provided for @inboxTimeNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get inboxTimeNow;

  /// No description provided for @inboxTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n}m'**
  String inboxTimeMinutes(int n);

  /// No description provided for @inboxTimeHours.
  ///
  /// In en, this message translates to:
  /// **'{n}h'**
  String inboxTimeHours(int n);

  /// No description provided for @conversationMarkResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark resolved'**
  String get conversationMarkResolved;

  /// No description provided for @conversationArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive conversation'**
  String get conversationArchive;

  /// No description provided for @conversationReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get conversationReopen;

  /// No description provided for @conversationResumeAi.
  ///
  /// In en, this message translates to:
  /// **'Resume the AI'**
  String get conversationResumeAi;

  /// No description provided for @conversationPausedNotice.
  ///
  /// In en, this message translates to:
  /// **'The agent no longer replies to this customer. Reply here.'**
  String get conversationPausedNotice;

  /// No description provided for @conversationReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Type your reply…'**
  String get conversationReplyHint;

  /// No description provided for @conversationSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get conversationSend;

  /// No description provided for @conversationSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get conversationSending;

  /// No description provided for @conversationReopenHint.
  ///
  /// In en, this message translates to:
  /// **'Reopen this conversation to reply.'**
  String get conversationReopenHint;

  /// No description provided for @conversationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get conversationEmpty;

  /// No description provided for @conversationResolvedToast.
  ///
  /// In en, this message translates to:
  /// **'Marked as resolved'**
  String get conversationResolvedToast;

  /// No description provided for @conversationArchivedToast.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get conversationArchivedToast;

  /// No description provided for @conversationReopenedToast.
  ///
  /// In en, this message translates to:
  /// **'Conversation reopened'**
  String get conversationReopenedToast;

  /// No description provided for @conversationAiResumedToast.
  ///
  /// In en, this message translates to:
  /// **'The AI is replying again'**
  String get conversationAiResumedToast;

  /// No description provided for @conversationAuthorAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get conversationAuthorAi;

  /// No description provided for @conversationAuthorYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get conversationAuthorYou;

  /// No description provided for @productVariantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Variants'**
  String get productVariantsTitle;

  /// No description provided for @productVariantsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total qty: {count}'**
  String productVariantsTotal(int count);

  /// No description provided for @productVariantAdd.
  ///
  /// In en, this message translates to:
  /// **'Add variant'**
  String get productVariantAdd;

  /// No description provided for @productVariantsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No variants. Tap “Add variant” to create one.'**
  String get productVariantsEmpty;

  /// No description provided for @productVariantName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get productVariantName;

  /// No description provided for @productVariantNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g., Red - Large'**
  String get productVariantNamePlaceholder;

  /// No description provided for @productVariantSku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get productVariantSku;

  /// No description provided for @productVariantSkuPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Optional SKU'**
  String get productVariantSkuPlaceholder;

  /// No description provided for @productVariantCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get productVariantCost;

  /// No description provided for @productVariantPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productVariantPrice;

  /// No description provided for @productVariantQuantity.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get productVariantQuantity;

  /// No description provided for @productVariantMinQuantity.
  ///
  /// In en, this message translates to:
  /// **'Min qty'**
  String get productVariantMinQuantity;

  /// No description provided for @productVariantRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove variant'**
  String get productVariantRemove;

  /// No description provided for @productVariantDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Two variants cannot have the same name'**
  String get productVariantDuplicate;

  /// No description provided for @productVariantsRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one variant, or untick the box.'**
  String get productVariantsRequired;

  /// No description provided for @productVariantsRetryHint.
  ///
  /// In en, this message translates to:
  /// **'The product is created — only the missing variants will be sent again.'**
  String get productVariantsRetryHint;

  /// No description provided for @productDetailEyebrow.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT DETAILS'**
  String get productDetailEyebrow;

  /// No description provided for @productDetailNoImages.
  ///
  /// In en, this message translates to:
  /// **'No images'**
  String get productDetailNoImages;

  /// No description provided for @productDetailCost.
  ///
  /// In en, this message translates to:
  /// **'Cost price'**
  String get productDetailCost;

  /// No description provided for @productDetailSelling.
  ///
  /// In en, this message translates to:
  /// **'Selling price'**
  String get productDetailSelling;

  /// No description provided for @productDetailProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit / margin'**
  String get productDetailProfit;

  /// No description provided for @productDetailInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get productDetailInStock;

  /// No description provided for @productDetailStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get productDetailStatus;

  /// No description provided for @productDetailActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get productDetailActive;

  /// No description provided for @productDetailInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get productDetailInactive;

  /// No description provided for @productDetailVariants.
  ///
  /// In en, this message translates to:
  /// **'Variants ({count})'**
  String productDetailVariants(int count);

  /// No description provided for @tutorialProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first product'**
  String get tutorialProductTitle;

  /// No description provided for @tutorialProductSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is what your agent will sell. The description is what it reads to answer customers.'**
  String get tutorialProductSubtitle;

  /// No description provided for @tutorialProductSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create the product'**
  String get tutorialProductSubmit;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get productName;

  /// No description provided for @productNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Satin dress — Black'**
  String get productNamePlaceholder;

  /// No description provided for @productSku.
  ///
  /// In en, this message translates to:
  /// **'Reference (SKU)'**
  String get productSku;

  /// No description provided for @productSkuPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'PRD-001'**
  String get productSkuPlaceholder;

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescription;

  /// No description provided for @productDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe the product — the agent uses this to sell it'**
  String get productDescriptionPlaceholder;

  /// No description provided for @productCostPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost price (DA)'**
  String get productCostPrice;

  /// No description provided for @productSellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling price (DA)'**
  String get productSellingPrice;

  /// No description provided for @productQuantity.
  ///
  /// In en, this message translates to:
  /// **'Initial quantity'**
  String get productQuantity;

  /// No description provided for @productErrRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get productErrRequired;

  /// No description provided for @productErrNotANumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get productErrNotANumber;

  /// The backend rejects a cost price, selling price or initial quantity of 0 outright — so this is a distinct message from 'required', which would be wrong for a field that visibly contains 0.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than 0'**
  String get productErrMustBePositive;

  /// No description provided for @productErrBelowCost.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than or equal to the cost price'**
  String get productErrBelowCost;

  /// No description provided for @productsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'CATALOGUE'**
  String get productsEyebrow;

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTitle;

  /// No description provided for @productsSummary.
  ///
  /// In en, this message translates to:
  /// **'What your agent sells. {count, plural, =0{No products yet} =1{1 product} other{{count} products}}, {value} of stock value.'**
  String productsSummary(int count, String value);

  /// No description provided for @productsSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get productsSearchLabel;

  /// No description provided for @productsSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search products…'**
  String get productsSearchPlaceholder;

  /// No description provided for @productsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get productsFilterAll;

  /// No description provided for @productsFilterLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get productsFilterLowStock;

  /// No description provided for @productsSectionAll.
  ///
  /// In en, this message translates to:
  /// **'ALL PRODUCTS'**
  String get productsSectionAll;

  /// No description provided for @productsSectionLowStock.
  ///
  /// In en, this message translates to:
  /// **'LOW STOCK'**
  String get productsSectionLowStock;

  /// No description provided for @productsInStock.
  ///
  /// In en, this message translates to:
  /// **'IN STOCK'**
  String get productsInStock;

  /// No description provided for @productsOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'OUT OF STOCK'**
  String get productsOutOfStock;

  /// Shown on a row's meta line when the product has a low-stock threshold set. The number is the threshold, not the stock.
  ///
  /// In en, this message translates to:
  /// **'THRESHOLD {count}'**
  String productsThreshold(int count);

  /// Shown on a row's meta line when the product has variants, like the web's 'N variants' badge next to the product name.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 VARIANT} other{{count} VARIANTS}}'**
  String productsVariantCount(int count);

  /// No description provided for @productsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get productsEmptyTitle;

  /// No description provided for @productsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first product and your agent will be able to sell it.'**
  String get productsEmptyBody;

  /// No description provided for @productsNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get productsNoMatchTitle;

  /// No description provided for @productsNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Try another word, or clear the filter.'**
  String get productsNoMatchBody;

  /// No description provided for @productsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get productsAdd;

  /// No description provided for @productAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get productAddTitle;

  /// No description provided for @productAlertThreshold.
  ///
  /// In en, this message translates to:
  /// **'Alert threshold'**
  String get productAlertThreshold;

  /// No description provided for @productAlertThresholdHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for no alert'**
  String get productAlertThresholdHint;

  /// No description provided for @productCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productCategory;

  /// No description provided for @productCategoryNone.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get productCategoryNone;

  /// No description provided for @productUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get productUnit;

  /// No description provided for @productUnitNone.
  ///
  /// In en, this message translates to:
  /// **'Select unit'**
  String get productUnitNone;

  /// No description provided for @productPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get productPhotos;

  /// No description provided for @productPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'JPEG, PNG, WEBP · 5MB MAX'**
  String get productPhotosHint;

  /// No description provided for @productHasVariants.
  ///
  /// In en, this message translates to:
  /// **'This product has variants'**
  String get productHasVariants;

  /// No description provided for @productHasVariantsHint.
  ///
  /// In en, this message translates to:
  /// **'Sizes or colours — the quantity is set per variant'**
  String get productHasVariantsHint;

  /// No description provided for @productAddSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create product'**
  String get productAddSubmit;

  /// Title of the edit form (Figma `Edit product`), and the accessible name of the pencil that opens it from 17a.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get productEditTitle;

  /// No description provided for @productEditSubmit.
  ///
  /// In en, this message translates to:
  /// **'Update product'**
  String get productEditSubmit;

  /// Under the variants checkbox on the edit form. Replaces the create form's hint, because on edit a saved variant's quantity is locked — PUT cannot carry one.
  ///
  /// In en, this message translates to:
  /// **'To change variant quantities, use “Adjust stock”.'**
  String get productEditVariantsHint;

  /// No description provided for @productEditLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes will be lost.'**
  String get productEditLeaveBody;

  /// No description provided for @productEditDeleteVariantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete variants?'**
  String get productEditDeleteVariantsTitle;

  /// Confirmation before a save that deletes variants holding no stock.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 variant will be permanently deleted.} other{{count} variants will be permanently deleted.}}'**
  String productEditDeleteVariantsBody(int count);

  /// Same confirmation when the variants still hold stock. The backend writes a negative adjustment movement for each, which is why the units are named.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 variant will be permanently deleted, and its {stock} units written off your stock.} other{{count} variants will be permanently deleted, and their {stock} units written off your stock.}}'**
  String productEditDeleteVariantsStock(int count, int stock);

  /// No description provided for @productEditDeleteVariantsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete and save'**
  String get productEditDeleteVariantsConfirm;

  /// The + beside the unit picker on the edit form, and the title of the sheet it opens — the web's Add Custom Unit.
  ///
  /// In en, this message translates to:
  /// **'Add a custom unit'**
  String get productUnitAdd;

  /// No description provided for @productUnitName.
  ///
  /// In en, this message translates to:
  /// **'Unit name'**
  String get productUnitName;

  /// No description provided for @productUnitNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dozen'**
  String get productUnitNamePlaceholder;

  /// No description provided for @productUnitAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'Abbreviation'**
  String get productUnitAbbreviation;

  /// No description provided for @productUnitAbbreviationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. dz'**
  String get productUnitAbbreviationPlaceholder;

  /// No description provided for @productUnitCreate.
  ///
  /// In en, this message translates to:
  /// **'Add unit'**
  String get productUnitCreate;

  /// Title of the Adjust stock sheet (Figma `Adjust stock`), and the action row that opens it on 17a.
  ///
  /// In en, this message translates to:
  /// **'Adjust stock'**
  String get stockAdjustTitle;

  /// Under the sheet's title. `stock` is already formatted with its unit abbreviation, e.g. `15 pcs`.
  ///
  /// In en, this message translates to:
  /// **'{product}  ·  Current stock: {stock}'**
  String stockAdjustSubtitle(String product, String stock);

  /// No description provided for @stockAdjustIn.
  ///
  /// In en, this message translates to:
  /// **'Stock in (+)'**
  String get stockAdjustIn;

  /// No description provided for @stockAdjustOut.
  ///
  /// In en, this message translates to:
  /// **'Stock out (−)'**
  String get stockAdjustOut;

  /// The third adjustment type: set the exact quantity. Short, because three chips share one row.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get stockAdjustSet;

  /// No description provided for @stockAdjustReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get stockAdjustReason;

  /// On a variant card's header — the stock it holds before the adjustment.
  ///
  /// In en, this message translates to:
  /// **'QTY: {count}'**
  String stockAdjustCurrent(int count);

  /// Preview under a filled adjustment line.
  ///
  /// In en, this message translates to:
  /// **'New quantity: {count}'**
  String stockAdjustResult(int count);

  /// An outgoing movement larger than the stock on hand. The backend answers 400 `Insufficient stock`; this says so first.
  ///
  /// In en, this message translates to:
  /// **'Only {count} in stock'**
  String stockAdjustInsufficient(int count);

  /// No description provided for @stockAdjustNothing.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity on at least one line.'**
  String get stockAdjustNothing;

  /// No description provided for @stockAdjustSubmit.
  ///
  /// In en, this message translates to:
  /// **'Adjust stock'**
  String get stockAdjustSubmit;

  /// No description provided for @stockAdjustDone.
  ///
  /// In en, this message translates to:
  /// **'Stock adjusted'**
  String get stockAdjustDone;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Product expenses'**
  String get expensesTitle;

  /// No description provided for @expensesEyebrow.
  ///
  /// In en, this message translates to:
  /// **'PRODUCT EXPENSES'**
  String get expensesEyebrow;

  /// No description provided for @expensesMarginSummary.
  ///
  /// In en, this message translates to:
  /// **'Margin summary'**
  String get expensesMarginSummary;

  /// No description provided for @expensesTotal.
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get expensesTotal;

  /// No description provided for @expensesPerUnit.
  ///
  /// In en, this message translates to:
  /// **'Expense / unit'**
  String get expensesPerUnit;

  /// No description provided for @expensesTrueCost.
  ///
  /// In en, this message translates to:
  /// **'True cost'**
  String get expensesTrueCost;

  /// No description provided for @expensesNetMargin.
  ///
  /// In en, this message translates to:
  /// **'Net margin'**
  String get expensesNetMargin;

  /// No description provided for @expensesSection.
  ///
  /// In en, this message translates to:
  /// **'Expenses ({count})'**
  String expensesSection(int count);

  /// No description provided for @expensesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet. Add one below and the margin above will take it into account.'**
  String get expensesEmpty;

  /// No description provided for @expensesAddSection.
  ///
  /// In en, this message translates to:
  /// **'Add an expense'**
  String get expensesAddSection;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategory;

  /// No description provided for @expenseCategoryMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get expenseCategoryMarketing;

  /// No description provided for @expenseCategoryShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get expenseCategoryShipping;

  /// No description provided for @expenseCategoryPackaging.
  ///
  /// In en, this message translates to:
  /// **'Packaging'**
  String get expenseCategoryPackaging;

  /// No description provided for @expenseCategoryCustoms.
  ///
  /// In en, this message translates to:
  /// **'Customs'**
  String get expenseCategoryCustoms;

  /// No description provided for @expenseCategoryStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get expenseCategoryStorage;

  /// No description provided for @expenseCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expenseCategoryOther;

  /// No description provided for @expenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (DA)'**
  String get expenseAmount;

  /// No description provided for @expenseAmountPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseAmountPlaceholder;

  /// No description provided for @expenseDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get expenseDescriptionPlaceholder;

  /// The amount is a fixed total, spread over the quantity in stock. The web's `fixed` toggle, and the default.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get expenseFixed;

  /// No description provided for @expensePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Per unit'**
  String get expensePerUnit;

  /// Tag on an expense row whose amount applies to each unit sold.
  ///
  /// In en, this message translates to:
  /// **'/ unit'**
  String get expensePerUnitTag;

  /// No description provided for @expenseAdd.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expenseAdd;

  /// No description provided for @expenseAdded.
  ///
  /// In en, this message translates to:
  /// **'Expense added'**
  String get expenseAdded;

  /// No description provided for @expenseDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this expense?'**
  String get expenseDeleteTitle;

  /// Confirmation before deleting an expense. The backend's delete is hard.
  ///
  /// In en, this message translates to:
  /// **'{category} — {amount} will be removed, and the margin recalculated.'**
  String expenseDeleteBody(String category, String amount);

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

  /// No description provided for @productDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get productDeleteTitle;

  /// The web's own delete copy. The row is a soft delete, but the product's image FILES are removed from disk, so it is not reversible in practice.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete {name}? This action cannot be undone.'**
  String productDeleteBody(String name);

  /// No description provided for @productDeleteDone.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleteDone;

  /// No description provided for @productDetailActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get productDetailActions;

  /// No description provided for @productDetailAdjustMeta.
  ///
  /// In en, this message translates to:
  /// **'Stock in, stock out, or set the exact quantity'**
  String get productDetailAdjustMeta;

  /// No description provided for @productDetailExpensesMeta.
  ///
  /// In en, this message translates to:
  /// **'True cost and net margin'**
  String get productDetailExpensesMeta;

  /// No description provided for @productDetailDeleteMeta.
  ///
  /// In en, this message translates to:
  /// **'Removes it from your catalogue'**
  String get productDetailDeleteMeta;

  /// The meta line under a category in the picker — how many products it holds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No products} =1{1 product} other{{count} products}}'**
  String productsCount(int count);

  /// No description provided for @productPhotosSoon.
  ///
  /// In en, this message translates to:
  /// **'Photos can be added from the web for now'**
  String get productPhotosSoon;

  /// No description provided for @productPhotosTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Photos over 5 MB were not added.'**
  String get productPhotosTooLarge;

  /// No description provided for @productPhotosWrongType.
  ///
  /// In en, this message translates to:
  /// **'Only JPEG, PNG, WEBP or GIF photos can be added.'**
  String get productPhotosWrongType;

  /// No description provided for @productPhotosTooMany.
  ///
  /// In en, this message translates to:
  /// **'Up to 10 photos per product.'**
  String get productPhotosTooMany;

  /// Toast on 18 when the product was created but the separate photo upload failed. The product exists either way.
  ///
  /// In en, this message translates to:
  /// **'Product created, but its photos could not be uploaded.'**
  String get productPhotosUploadFailed;

  /// Toast on the edit form when everything saved but the photo upload, which runs last, failed. The edit stands either way.
  ///
  /// In en, this message translates to:
  /// **'Product updated, but the new photos could not be uploaded.'**
  String get productPhotosUploadFailedEdit;

  /// No description provided for @productPhotoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get productPhotoRemove;

  /// No description provided for @productPhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get productPhotoCamera;

  /// No description provided for @productPhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get productPhotoGallery;

  /// No description provided for @tutorialAgentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'It answers your customers with your catalogue and your prices. Three fields are enough — everything else can be tuned later.'**
  String get tutorialAgentSubtitle;

  /// No description provided for @tutorialAgentSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create the agent'**
  String get tutorialAgentSubmit;

  /// No description provided for @agentName.
  ///
  /// In en, this message translates to:
  /// **'Agent name'**
  String get agentName;

  /// No description provided for @agentNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sales assistant'**
  String get agentNamePlaceholder;

  /// No description provided for @agentPersonality.
  ///
  /// In en, this message translates to:
  /// **'Personality'**
  String get agentPersonality;

  /// No description provided for @agentToneProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get agentToneProfessional;

  /// No description provided for @agentToneProfessionalDesc.
  ///
  /// In en, this message translates to:
  /// **'Formal and business-oriented'**
  String get agentToneProfessionalDesc;

  /// No description provided for @agentToneFriendly.
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get agentToneFriendly;

  /// No description provided for @agentToneFriendlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Warm and approachable'**
  String get agentToneFriendlyDesc;

  /// No description provided for @agentToneCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get agentToneCasual;

  /// No description provided for @agentToneCasualDesc.
  ///
  /// In en, this message translates to:
  /// **'Relaxed and conversational'**
  String get agentToneCasualDesc;

  /// No description provided for @agentToneTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get agentToneTechnical;

  /// No description provided for @agentToneTechnicalDesc.
  ///
  /// In en, this message translates to:
  /// **'Detailed and precise'**
  String get agentToneTechnicalDesc;

  /// No description provided for @agentInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get agentInstructions;

  /// No description provided for @agentInstructionsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'How it should answer, and when to hand over to you'**
  String get agentInstructionsPlaceholder;

  /// No description provided for @tutorialConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your page'**
  String get tutorialConnectTitle;

  /// No description provided for @tutorialConnectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is the last step. Your agent answers in that page\'s inbox — the moment it is connected, it is working.'**
  String get tutorialConnectSubtitle;

  /// No description provided for @connectPermissionsHeading.
  ///
  /// In en, this message translates to:
  /// **'Facebook will ask you for'**
  String get connectPermissionsHeading;

  /// No description provided for @connectPermissionPages.
  ///
  /// In en, this message translates to:
  /// **'See the list of your pages'**
  String get connectPermissionPages;

  /// No description provided for @connectPermissionMessages.
  ///
  /// In en, this message translates to:
  /// **'Read and send the page\'s messages'**
  String get connectPermissionMessages;

  /// No description provided for @connectPermissionInfo.
  ///
  /// In en, this message translates to:
  /// **'Access the page\'s information'**
  String get connectPermissionInfo;

  /// No description provided for @connectFacebook.
  ///
  /// In en, this message translates to:
  /// **'Connect Facebook'**
  String get connectFacebook;

  /// No description provided for @connectInstagram.
  ///
  /// In en, this message translates to:
  /// **'Connect Instagram'**
  String get connectInstagram;

  /// No description provided for @oauthLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading Facebook…'**
  String get oauthLoading;

  /// No description provided for @oauthLoadingHint.
  ///
  /// In en, this message translates to:
  /// **'Facebook\'s authorisation page appears here.'**
  String get oauthLoadingHint;

  /// The one way out of the tutorial, on T5 only. T5 is the only step that depends on a third party — the merchant may have no Page yet, or Meta may not grant access — so it is the only one that can be deferred. Worded as later, not skip: the step stays outstanding on home rather than being abandoned.
  ///
  /// In en, this message translates to:
  /// **'Connect later'**
  String get connectLater;

  /// No description provided for @oauthDenied.
  ///
  /// In en, this message translates to:
  /// **'Authorisation cancelled. You can try again whenever you like.'**
  String get oauthDenied;

  /// T5, above the connect buttons. Meta granted access but the backend could not save the page — its callback page reported an error. The backend's own reason is English and technical, so it goes to the log, not here.
  ///
  /// In en, this message translates to:
  /// **'Your page could not be connected. Try again, or connect it later.'**
  String get connectFailed;

  /// T5, above the connect buttons. The grant went through but no page can be named as the one just connected — none was picked, or nothing new was saved.
  ///
  /// In en, this message translates to:
  /// **'No new page came through. Make sure you pick a page when asked, then try again.'**
  String get connectNothingNew;

  /// Toast after a page connects but attaching it to the agent fails. The tutorial still moves on.
  ///
  /// In en, this message translates to:
  /// **'Page connected, but not yet linked to your agent. You can link it from your agent\'s settings.'**
  String get connectLinkFailed;

  /// No description provided for @tutorialReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your agent is live'**
  String get tutorialReadyTitle;

  /// No description provided for @tutorialReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'It is already answering your page\'s messages, with your catalogue and your prices. Add more products whenever you like.'**
  String get tutorialReadySubtitle;

  /// T6 when the merchant chose Connecter plus tard on T5. The tutorial still ends here, but with no Page the agent is answering nobody — so the live heading is replaced and the fourth step stays unticked.
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get tutorialReadyTitlePending;

  /// No description provided for @tutorialReadySubtitlePending.
  ///
  /// In en, this message translates to:
  /// **'Your catalogue and your agent are ready. All that is left is connecting your page — your agent starts answering the moment it is.'**
  String get tutorialReadySubtitlePending;

  /// No description provided for @tutorialReadySubmit.
  ///
  /// In en, this message translates to:
  /// **'Open the app'**
  String get tutorialReadySubmit;

  /// No description provided for @tutorialReadyModeSimple.
  ///
  /// In en, this message translates to:
  /// **'Simple — products, categories and orders'**
  String get tutorialReadyModeSimple;

  /// No description provided for @tutorialReadyModeAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced — the full suite'**
  String get tutorialReadyModeAdvanced;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// From page.dash.greeting.* in src/lib/i18n.ts, which splits the day the same three ways. Rendered as '{greeting}, {firstName}'.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeSnapshot.
  ///
  /// In en, this message translates to:
  /// **'here is a snapshot'**
  String get homeSnapshot;

  /// No description provided for @homeQueue.
  ///
  /// In en, this message translates to:
  /// **'To handle'**
  String get homeQueue;

  /// The kind on an escalation card. Every item in this queue is a conversation the backend flagged aiPaused, which is exactly 'the AI stopped and is waiting for you' — so there is one kind, not several.
  ///
  /// In en, this message translates to:
  /// **'AI stuck'**
  String get homeQueueStuck;

  /// No description provided for @homeQueueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting. The agent is handling every conversation.'**
  String get homeQueueEmpty;

  /// No description provided for @homeQueueNoPage.
  ///
  /// In en, this message translates to:
  /// **'No page connected, so no conversation can reach you yet.'**
  String get homeQueueNoPage;

  /// No description provided for @homeQueueMore.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more'**
  String homeQueueMore(int count);

  /// How long an escalation has been waiting. Uppercase in the Label/Meta style, stored cased per locale because case does not apply in Arabic.
  ///
  /// In en, this message translates to:
  /// **'{count} MIN'**
  String homeAgeMinutes(int count);

  /// No description provided for @homeAgeHours.
  ///
  /// In en, this message translates to:
  /// **'{count} H'**
  String homeAgeHours(int count);

  /// No description provided for @homeAgeDays.
  ///
  /// In en, this message translates to:
  /// **'{count} D'**
  String homeAgeDays(int count);

  /// No description provided for @homeNoPageTitle.
  ///
  /// In en, this message translates to:
  /// **'No page connected'**
  String get homeNoPageTitle;

  /// Sits above À traiter when the merchant has no Page — including one who chose Connecter plus tard on T5. The queue can only be empty in that state, so the screen explains the silence instead of showing an empty section.
  ///
  /// In en, this message translates to:
  /// **'Your agent has nowhere to answer yet. Connect your Facebook or Instagram page and it starts working on the first message.'**
  String get homeNoPageBody;

  /// No description provided for @homeOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get homeOverview;

  /// No description provided for @homeKpiPages.
  ///
  /// In en, this message translates to:
  /// **'Connected pages'**
  String get homeKpiPages;

  /// No description provided for @homeKpiProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get homeKpiProducts;

  /// No description provided for @homeKpiLowStock.
  ///
  /// In en, this message translates to:
  /// **'{count} low stock'**
  String homeKpiLowStock(int count);

  /// No description provided for @homeKpiRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue (30d)'**
  String get homeKpiRevenue;

  /// No description provided for @homeKpiSales.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} sale} other{{count} sales}}'**
  String homeKpiSales(int count);

  /// No description provided for @homeKpiStockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock value'**
  String get homeKpiStockValue;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActions;

  /// No description provided for @homeActionConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect a page'**
  String get homeActionConnectTitle;

  /// No description provided for @homeActionConnectBody.
  ///
  /// In en, this message translates to:
  /// **'Link your Facebook page'**
  String get homeActionConnectBody;

  /// No description provided for @homeActionProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add products'**
  String get homeActionProductsTitle;

  /// No description provided for @homeActionProductsBody.
  ///
  /// In en, this message translates to:
  /// **'Build your catalogue'**
  String get homeActionProductsBody;

  /// No description provided for @homeActionAgentsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI agents'**
  String get homeActionAgentsTitle;

  /// No description provided for @homeActionAgentsBody.
  ///
  /// In en, this message translates to:
  /// **'Manage your assistants'**
  String get homeActionAgentsBody;

  /// No description provided for @homeYourPages.
  ///
  /// In en, this message translates to:
  /// **'Your pages'**
  String get homeYourPages;

  /// No description provided for @homeManageAll.
  ///
  /// In en, this message translates to:
  /// **'MANAGE ALL →'**
  String get homeManageAll;

  /// No description provided for @homePagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No page connected yet.'**
  String get homePagesEmpty;

  /// No description provided for @homePageActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get homePageActive;

  /// No description provided for @homePageInactive.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get homePageInactive;

  /// The second line of a page row, beside the network name. Uppercase in the Label/Meta style.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED {date}'**
  String homePageConnectedOn(DateTime date);

  /// No description provided for @platformFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get platformFacebook;

  /// No description provided for @platformInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get platformInstagram;

  /// No description provided for @homeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get homeGetStarted;

  /// No description provided for @homeStepConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect a page'**
  String get homeStepConnectTitle;

  /// No description provided for @homeStepConnectBody.
  ///
  /// In en, this message translates to:
  /// **'Link Facebook to start chatting'**
  String get homeStepConnectBody;

  /// No description provided for @homeStepProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add products'**
  String get homeStepProductsTitle;

  /// No description provided for @homeStepProductsBody.
  ///
  /// In en, this message translates to:
  /// **'Build up your catalogue'**
  String get homeStepProductsBody;

  /// No description provided for @homeStepAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure your AI agent'**
  String get homeStepAgentTitle;

  /// No description provided for @homeStepAgentBody.
  ///
  /// In en, this message translates to:
  /// **'Set the tone and the behaviour'**
  String get homeStepAgentBody;

  /// No description provided for @homeStepSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Make your first sale'**
  String get homeStepSaleTitle;

  /// No description provided for @homeStepSaleBody.
  ///
  /// In en, this message translates to:
  /// **'Watch the AI handle the requests'**
  String get homeStepSaleBody;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get navHome;

  /// No description provided for @navQueue.
  ///
  /// In en, this message translates to:
  /// **'QUEUE'**
  String get navQueue;

  /// No description provided for @navInbox.
  ///
  /// In en, this message translates to:
  /// **'INBOX'**
  String get navInbox;

  /// No description provided for @navStock.
  ///
  /// In en, this message translates to:
  /// **'STOCK'**
  String get navStock;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'ORD'**
  String get navOrders;

  /// Shown when a control leads to a screen that does not exist yet. Says so rather than doing nothing, which reads as a broken tap.
  ///
  /// In en, this message translates to:
  /// **'not built yet'**
  String get commonNotBuilt;

  /// No description provided for @agentsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Agents'**
  String get agentsTitle;

  /// No description provided for @agentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and manage AI agents that sell your products on connected pages'**
  String get agentsSubtitle;

  /// No description provided for @agentsActive.
  ///
  /// In en, this message translates to:
  /// **'AI active'**
  String get agentsActive;

  /// No description provided for @agentsInactive.
  ///
  /// In en, this message translates to:
  /// **'AI paused'**
  String get agentsInactive;

  /// No description provided for @agentsStatPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get agentsStatPages;

  /// No description provided for @agentsStatProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get agentsStatProducts;

  /// No description provided for @agentsStatModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get agentsStatModel;

  /// No description provided for @agentsAllProducts.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get agentsAllProducts;

  /// No description provided for @agentsNoPages.
  ///
  /// In en, this message translates to:
  /// **'Not answering on any page yet'**
  String get agentsNoPages;

  /// No description provided for @agentsPause.
  ///
  /// In en, this message translates to:
  /// **'Pause the agent'**
  String get agentsPause;

  /// No description provided for @agentsResume.
  ///
  /// In en, this message translates to:
  /// **'Resume the agent'**
  String get agentsResume;

  /// No description provided for @agentsPausedToast.
  ///
  /// In en, this message translates to:
  /// **'Agent paused — it no longer replies'**
  String get agentsPausedToast;

  /// No description provided for @agentsResumedToast.
  ///
  /// In en, this message translates to:
  /// **'Agent active — it replies again'**
  String get agentsResumedToast;

  /// No description provided for @agentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No agent yet'**
  String get agentsEmptyTitle;

  /// No description provided for @agentsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create an AI agent to automatically respond to messages on your connected pages and sell your products.'**
  String get agentsEmptyBody;

  /// 14 — Agents IA, the button on the no-agent state. Leads to 15 — Agents · démarrer (F15), not built yet.
  ///
  /// In en, this message translates to:
  /// **'Create your agent'**
  String get agentsEmptyCta;

  /// No description provided for @agentsActionInsights.
  ///
  /// In en, this message translates to:
  /// **'Issues to review'**
  String get agentsActionInsights;

  /// No description provided for @agentsActionTest.
  ///
  /// In en, this message translates to:
  /// **'Test the agent'**
  String get agentsActionTest;

  /// No description provided for @agentsActionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details and stats'**
  String get agentsActionDetails;

  /// No description provided for @agentsActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete the agent'**
  String get agentsActionDelete;

  /// No description provided for @agentsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the agent?'**
  String get agentsDeleteTitle;

  /// No description provided for @agentsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be deleted and will stop replying on your pages. You can create a new agent afterwards.'**
  String agentsDeleteBody(String name);

  /// No description provided for @agentsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get agentsDeleteConfirm;

  /// No description provided for @agentsDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Agent deleted'**
  String get agentsDeletedToast;

  /// No description provided for @agentsInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending issues'**
  String get agentsInsightsTitle;

  /// No description provided for @agentsInsightsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pending issues — your agent is handling everything.'**
  String get agentsInsightsEmpty;

  /// No description provided for @agentsInsightsNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing here.'**
  String get agentsInsightsNone;

  /// No description provided for @agentsInsightUnclear.
  ///
  /// In en, this message translates to:
  /// **'Unclear'**
  String get agentsInsightUnclear;

  /// No description provided for @agentsInsightUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown topic'**
  String get agentsInsightUnknown;

  /// No description provided for @agentsInsightHandoff.
  ///
  /// In en, this message translates to:
  /// **'Handed to you'**
  String get agentsInsightHandoff;

  /// No description provided for @agentsInsightCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get agentsInsightCustomer;

  /// No description provided for @agentsInsightAgent.
  ///
  /// In en, this message translates to:
  /// **'AI response'**
  String get agentsInsightAgent;

  /// No description provided for @agentsInsightResolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get agentsInsightResolve;

  /// No description provided for @agentsInsightDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get agentsInsightDismiss;

  /// No description provided for @agentsInsightAddAndResolve.
  ///
  /// In en, this message translates to:
  /// **'Add and resolve'**
  String get agentsInsightAddAndResolve;

  /// No description provided for @agentsInsightInstructionHint.
  ///
  /// In en, this message translates to:
  /// **'Add an instruction so the agent handles this better next time…'**
  String get agentsInsightInstructionHint;

  /// No description provided for @agentsInsightResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get agentsInsightResolved;

  /// No description provided for @agentsInsightDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get agentsInsightDismissed;

  /// No description provided for @agentsInsightPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get agentsInsightPending;

  /// No description provided for @agentsInsightFailed.
  ///
  /// In en, this message translates to:
  /// **'The issue could not be updated.'**
  String get agentsInsightFailed;

  /// No description provided for @agentsTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Test — {name}'**
  String agentsTestTitle(String name);

  /// No description provided for @agentsTestEmpty.
  ///
  /// In en, this message translates to:
  /// **'Send a message to test'**
  String get agentsTestEmpty;

  /// No description provided for @agentsTestNote.
  ///
  /// In en, this message translates to:
  /// **'A dry run: no credits used, no orders created.'**
  String get agentsTestNote;

  /// No description provided for @agentsTestPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get agentsTestPlaceholder;

  /// No description provided for @agentsTestSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get agentsTestSend;

  /// No description provided for @agentsTestFailed.
  ///
  /// In en, this message translates to:
  /// **'No reply — try again.'**
  String get agentsTestFailed;

  /// No description provided for @agentsDetailsConversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get agentsDetailsConversations;

  /// No description provided for @agentsDetailsConversationsFoot.
  ///
  /// In en, this message translates to:
  /// **'{received} received · {sent} sent'**
  String agentsDetailsConversationsFoot(int received, int sent);

  /// No description provided for @agentsDetailsMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get agentsDetailsMessages;

  /// No description provided for @agentsDetailsLastActive.
  ///
  /// In en, this message translates to:
  /// **'Last: {date}'**
  String agentsDetailsLastActive(String date);

  /// No description provided for @agentsDetailsNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get agentsDetailsNoActivity;

  /// No description provided for @agentsDetailsOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders created'**
  String get agentsDetailsOrders;

  /// No description provided for @agentsDetailsResolvedFoot.
  ///
  /// In en, this message translates to:
  /// **'{count} resolved'**
  String agentsDetailsResolvedFoot(int count);

  /// No description provided for @agentsDetailsInsights.
  ///
  /// In en, this message translates to:
  /// **'Agent insights'**
  String get agentsDetailsInsights;

  /// No description provided for @agentsDetailsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get agentsDetailsAll;

  /// No description provided for @agentsDetailsInstructions.
  ///
  /// In en, this message translates to:
  /// **'Custom instructions'**
  String get agentsDetailsInstructions;

  /// No description provided for @agentsDetailsNoInstructions.
  ///
  /// In en, this message translates to:
  /// **'No instructions yet.'**
  String get agentsDetailsNoInstructions;

  /// No description provided for @agentsDetailsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get agentsDetailsEdit;

  /// No description provided for @agentsDetailsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get agentsDetailsSave;

  /// No description provided for @agentsDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Instructions saved'**
  String get agentsDetailsSaved;

  /// Saving on the phone after the web appended instructions (an insight resolve) while the editor was open. Ours, unapproved.
  ///
  /// In en, this message translates to:
  /// **'Instructions saved — lines added on the web were kept'**
  String get agentsDetailsSavedMerged;

  /// No description provided for @agentsDetailsConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Changed on the web'**
  String get agentsDetailsConflictTitle;

  /// No description provided for @agentsDetailsConflictBody.
  ///
  /// In en, this message translates to:
  /// **'These instructions were changed while you were editing. The current version:'**
  String get agentsDetailsConflictBody;

  /// No description provided for @agentsDetailsUseLatest.
  ///
  /// In en, this message translates to:
  /// **'Use this version'**
  String get agentsDetailsUseLatest;

  /// No description provided for @agentsDetailsKeepMine.
  ///
  /// In en, this message translates to:
  /// **'Replace with mine'**
  String get agentsDetailsKeepMine;

  /// No description provided for @agentsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Agent not found.'**
  String get agentsNotFound;

  /// No description provided for @agentsTestEmptyFor.
  ///
  /// In en, this message translates to:
  /// **'Send a message to test {name}'**
  String agentsTestEmptyFor(String name);

  /// No description provided for @agentsTestProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get agentsTestProduct;

  /// No description provided for @agentsTestProductId.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}…'**
  String agentsTestProductId(String id);

  /// No description provided for @agentsPresetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with a ready-made agent'**
  String get agentsPresetsTitle;

  /// No description provided for @agentsPresetsBody.
  ///
  /// In en, this message translates to:
  /// **'Each one is fully configured for Algerian selling — Darija, Arabic and French, delivery quoting, and order handling. Pick one to launch in seconds, then fine-tune anything.'**
  String get agentsPresetsBody;

  /// No description provided for @agentsPresetVisionVoice.
  ///
  /// In en, this message translates to:
  /// **'VISION + VOICE'**
  String get agentsPresetVisionVoice;

  /// No description provided for @agentsPresetVoice.
  ///
  /// In en, this message translates to:
  /// **'VOICE'**
  String get agentsPresetVoice;

  /// No description provided for @agentsPresetCloserTagline.
  ///
  /// In en, this message translates to:
  /// **'Turns conversations into confirmed orders'**
  String get agentsPresetCloserTagline;

  /// No description provided for @agentsPresetCloser1.
  ///
  /// In en, this message translates to:
  /// **'Guides the customer from question to confirmed order'**
  String get agentsPresetCloser1;

  /// No description provided for @agentsPresetCloser2.
  ///
  /// In en, this message translates to:
  /// **'Quotes delivery per wilaya and closes with the full total'**
  String get agentsPresetCloser2;

  /// No description provided for @agentsPresetCloser3.
  ///
  /// In en, this message translates to:
  /// **'Understands photos and voice notes'**
  String get agentsPresetCloser3;

  /// No description provided for @agentsPresetSupportTagline.
  ///
  /// In en, this message translates to:
  /// **'Answers fast, escalates problems to you'**
  String get agentsPresetSupportTagline;

  /// No description provided for @agentsPresetSupport1.
  ///
  /// In en, this message translates to:
  /// **'Handles product and order questions politely'**
  String get agentsPresetSupport1;

  /// No description provided for @agentsPresetSupport2.
  ///
  /// In en, this message translates to:
  /// **'Escalates complaints and refunds to a human'**
  String get agentsPresetSupport2;

  /// No description provided for @agentsPresetSupport3.
  ///
  /// In en, this message translates to:
  /// **'Calm, accurate, and to the point'**
  String get agentsPresetSupport3;

  /// No description provided for @agentsPresetAdvisorTagline.
  ///
  /// In en, this message translates to:
  /// **'Helps customers pick the right product'**
  String get agentsPresetAdvisorTagline;

  /// No description provided for @agentsPresetAdvisor1.
  ///
  /// In en, this message translates to:
  /// **'Compares options and explains differences'**
  String get agentsPresetAdvisor1;

  /// No description provided for @agentsPresetAdvisor2.
  ///
  /// In en, this message translates to:
  /// **'Matches a customer photo to your catalog'**
  String get agentsPresetAdvisor2;

  /// No description provided for @agentsPresetAdvisor3.
  ///
  /// In en, this message translates to:
  /// **'Great for catalogs with variants and specs'**
  String get agentsPresetAdvisor3;

  /// No description provided for @agentsPresetExpressTagline.
  ///
  /// In en, this message translates to:
  /// **'Ultra-fast replies for high message volume'**
  String get agentsPresetExpressTagline;

  /// No description provided for @agentsPresetExpress1.
  ///
  /// In en, this message translates to:
  /// **'Short, quick answers for busy pages'**
  String get agentsPresetExpress1;

  /// No description provided for @agentsPresetExpress2.
  ///
  /// In en, this message translates to:
  /// **'Lowest credit use — text and voice only'**
  String get agentsPresetExpress2;

  /// No description provided for @agentsPresetExpress3.
  ///
  /// In en, this message translates to:
  /// **'Still places and cancels orders'**
  String get agentsPresetExpress3;

  /// No description provided for @agentsPresetUse.
  ///
  /// In en, this message translates to:
  /// **'Use this agent  →'**
  String get agentsPresetUse;

  /// No description provided for @agentsPresetOwn.
  ///
  /// In en, this message translates to:
  /// **'Prefer to build your own?'**
  String get agentsPresetOwn;

  /// No description provided for @agentsPresetScratch.
  ///
  /// In en, this message translates to:
  /// **'Start from scratch'**
  String get agentsPresetScratch;

  /// No description provided for @agentsCreatedToast.
  ///
  /// In en, this message translates to:
  /// **'Agent created'**
  String get agentsCreatedToast;

  /// 15b — Partir de zéro, the full agent form. The web's AgentForm.tsx is hardcoded English and has no i18n keys; section names follow it, the rest is ours and unapproved.
  ///
  /// In en, this message translates to:
  /// **'Set up an agent to answer your conversations. Only the name is required — everything else has a default.'**
  String get agentFormSubtitle;

  /// No description provided for @agentFormBasics.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get agentFormBasics;

  /// No description provided for @agentFormDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get agentFormDescription;

  /// No description provided for @agentFormDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe what this agent does…'**
  String get agentFormDescriptionPlaceholder;

  /// No description provided for @agentFormInstructions.
  ///
  /// In en, this message translates to:
  /// **'Custom instructions'**
  String get agentFormInstructions;

  /// No description provided for @agentFormInstructionsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'How to respond, what to avoid, how to handle certain cases…'**
  String get agentFormInstructionsPlaceholder;

  /// No description provided for @agentFormInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'These instructions guide the agent’s behavior in conversations.'**
  String get agentFormInstructionsHint;

  /// No description provided for @agentFormAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced settings'**
  String get agentFormAdvanced;

  /// No description provided for @agentFormAdvancedHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — sensible defaults apply.'**
  String get agentFormAdvancedHint;

  /// No description provided for @agentFormBehavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get agentFormBehavior;

  /// No description provided for @agentFormBehaviorSummary.
  ///
  /// In en, this message translates to:
  /// **'Closing · Human handoff'**
  String get agentFormBehaviorSummary;

  /// No description provided for @agentFormClosing.
  ///
  /// In en, this message translates to:
  /// **'Conversation closing'**
  String get agentFormClosing;

  /// No description provided for @agentFormClosingPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Examples:\n• After an order: “Thank you! Your order is on its way.”\n• Customer says bye: “Thanks for chatting, come back anytime!”\n• Angry customer: “Sorry — let me get a human to help you.”'**
  String get agentFormClosingPlaceholder;

  /// No description provided for @agentFormClosingHint.
  ///
  /// In en, this message translates to:
  /// **'When and how the AI closes conversations. If empty, it uses sensible defaults (thanks after an order, answers goodbyes).'**
  String get agentFormClosingHint;

  /// No description provided for @agentFormHandoff.
  ///
  /// In en, this message translates to:
  /// **'Human intervention rules'**
  String get agentFormHandoff;

  /// No description provided for @agentFormHandoffPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Examples:\n• Refund or return → stop the AI, notify me\n• Discount request → let me handle it\n• Complaint → transfer the conversation to me'**
  String get agentFormHandoffPlaceholder;

  /// No description provided for @agentFormHandoffHint.
  ///
  /// In en, this message translates to:
  /// **'When the AI should stop and let a human take over. Normal greetings (slm, cava, hi) are always handled by the AI.'**
  String get agentFormHandoffHint;

  /// No description provided for @agentFormDisplay.
  ///
  /// In en, this message translates to:
  /// **'Product display'**
  String get agentFormDisplay;

  /// No description provided for @agentFormDisplayDefault.
  ///
  /// In en, this message translates to:
  /// **'Default style'**
  String get agentFormDisplayDefault;

  /// No description provided for @agentFormDisplayCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get agentFormDisplayCustom;

  /// No description provided for @agentFormDisplayHint.
  ///
  /// In en, this message translates to:
  /// **'How the AI presents products. Tap a tag to insert it — the AI fills in real product data.'**
  String get agentFormDisplayHint;

  /// No description provided for @agentFormTemplate.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get agentFormTemplate;

  /// No description provided for @agentFormTemplatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tap the tags above or type here…'**
  String get agentFormTemplatePlaceholder;

  /// No description provided for @agentFormTagCard.
  ///
  /// In en, this message translates to:
  /// **'Product card'**
  String get agentFormTagCard;

  /// No description provided for @agentFormTagName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get agentFormTagName;

  /// No description provided for @agentFormTagPrice.
  ///
  /// In en, this message translates to:
  /// **'Price (DA)'**
  String get agentFormTagPrice;

  /// No description provided for @agentFormTagDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get agentFormTagDescription;

  /// No description provided for @agentFormTagStock.
  ///
  /// In en, this message translates to:
  /// **'Stock qty'**
  String get agentFormTagStock;

  /// No description provided for @agentFormTagNewLine.
  ///
  /// In en, this message translates to:
  /// **'↵ New line'**
  String get agentFormTagNewLine;

  /// No description provided for @agentFormPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get agentFormPreview;

  /// No description provided for @agentFormPreviewLive.
  ///
  /// In en, this message translates to:
  /// **'Live preview'**
  String get agentFormPreviewLive;

  /// No description provided for @agentFormPreviewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Show me your products'**
  String get agentFormPreviewCustomer;

  /// No description provided for @agentFormPreviewDefault.
  ///
  /// In en, this message translates to:
  /// **'Here’s what we have!\n[PRODUCT_CARD]\nWould you like to order?'**
  String get agentFormPreviewDefault;

  /// No description provided for @agentFormPreviewSampleName.
  ///
  /// In en, this message translates to:
  /// **'Sample product'**
  String get agentFormPreviewSampleName;

  /// No description provided for @agentFormPreviewSampleDescription.
  ///
  /// In en, this message translates to:
  /// **'A great product'**
  String get agentFormPreviewSampleDescription;

  /// No description provided for @agentFormModel.
  ///
  /// In en, this message translates to:
  /// **'AI model'**
  String get agentFormModel;

  /// No description provided for @agentFormModelSummary.
  ///
  /// In en, this message translates to:
  /// **'{model} · {temperature} · {tokens} tokens'**
  String agentFormModelSummary(String model, String temperature, int tokens);

  /// No description provided for @agentFormModelPicker.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get agentFormModelPicker;

  /// The web's costPer1000Label. usd arrives with its dollar sign.
  ///
  /// In en, this message translates to:
  /// **'≈ {usd} / 1000 msgs'**
  String agentFormModelCost(String usd);

  /// No description provided for @agentFormModelsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading available models…'**
  String get agentFormModelsLoading;

  /// No description provided for @agentFormModelsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI models are temporarily unavailable. Please try again later.'**
  String get agentFormModelsUnavailable;

  /// No description provided for @agentFormTraitBestQuality.
  ///
  /// In en, this message translates to:
  /// **'Best quality'**
  String get agentFormTraitBestQuality;

  /// No description provided for @agentFormTraitFastAffordable.
  ///
  /// In en, this message translates to:
  /// **'Fast & affordable'**
  String get agentFormTraitFastAffordable;

  /// No description provided for @agentFormTraitLongContext128k.
  ///
  /// In en, this message translates to:
  /// **'128k context'**
  String get agentFormTraitLongContext128k;

  /// No description provided for @agentFormTraitLegacyFast.
  ///
  /// In en, this message translates to:
  /// **'Legacy, fast'**
  String get agentFormTraitLegacyFast;

  /// No description provided for @agentFormTraitBestBalanced.
  ///
  /// In en, this message translates to:
  /// **'Best balanced'**
  String get agentFormTraitBestBalanced;

  /// No description provided for @agentFormTraitFastCheap.
  ///
  /// In en, this message translates to:
  /// **'Fast & cheap'**
  String get agentFormTraitFastCheap;

  /// No description provided for @agentFormTraitMostCapable.
  ///
  /// In en, this message translates to:
  /// **'Most capable'**
  String get agentFormTraitMostCapable;

  /// No description provided for @agentFormTraitLatestFast.
  ///
  /// In en, this message translates to:
  /// **'Latest, fast'**
  String get agentFormTraitLatestFast;

  /// No description provided for @agentFormTraitLongContext1m.
  ///
  /// In en, this message translates to:
  /// **'1M context'**
  String get agentFormTraitLongContext1m;

  /// No description provided for @agentFormTraitBestOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Best open-source'**
  String get agentFormTraitBestOpenSource;

  /// No description provided for @agentFormTraitUltraFast.
  ///
  /// In en, this message translates to:
  /// **'Ultra fast'**
  String get agentFormTraitUltraFast;

  /// No description provided for @agentFormTraitMixtureOfExperts.
  ///
  /// In en, this message translates to:
  /// **'MoE, 32k context'**
  String get agentFormTraitMixtureOfExperts;

  /// No description provided for @agentFormTraitReasoning.
  ///
  /// In en, this message translates to:
  /// **'Reasoning model'**
  String get agentFormTraitReasoning;

  /// No description provided for @agentFormTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get agentFormTemperature;

  /// No description provided for @agentFormPrecise.
  ///
  /// In en, this message translates to:
  /// **'Precise'**
  String get agentFormPrecise;

  /// No description provided for @agentFormCreative.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get agentFormCreative;

  /// No description provided for @agentFormMaxTokens.
  ///
  /// In en, this message translates to:
  /// **'Max tokens'**
  String get agentFormMaxTokens;

  /// No description provided for @agentFormMaxTokensHint.
  ///
  /// In en, this message translates to:
  /// **'Maximum response length · 100 – 4096'**
  String get agentFormMaxTokensHint;

  /// No description provided for @agentFormImages.
  ///
  /// In en, this message translates to:
  /// **'Image recognition'**
  String get agentFormImages;

  /// No description provided for @agentFormImagesHint.
  ///
  /// In en, this message translates to:
  /// **'The AI sees customer photos and compares them with your products. 5 credits per image (vs 1 for text).'**
  String get agentFormImagesHint;

  /// No description provided for @agentFormVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice notes'**
  String get agentFormVoice;

  /// No description provided for @agentFormVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'The AI transcribes voice notes (AR, FR, EN, Darja). 3 credits per note. When off, the agent asks for a text instead.'**
  String get agentFormVoiceHint;

  /// No description provided for @agentFormDelay.
  ///
  /// In en, this message translates to:
  /// **'Response delay'**
  String get agentFormDelay;

  /// No description provided for @agentFormDelayValue.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String agentFormDelayValue(int seconds);

  /// No description provided for @agentFormDelayMax.
  ///
  /// In en, this message translates to:
  /// **'10 s'**
  String get agentFormDelayMax;

  /// No description provided for @agentFormDelayHint.
  ///
  /// In en, this message translates to:
  /// **'Waits for more messages before replying — customers often send several short ones, and this combines them.'**
  String get agentFormDelayHint;

  /// No description provided for @agentFormPages.
  ///
  /// In en, this message translates to:
  /// **'Connected pages'**
  String get agentFormPages;

  /// No description provided for @agentFormPagesHint.
  ///
  /// In en, this message translates to:
  /// **'The pages this agent answers on. Each page can only have one agent.'**
  String get agentFormPagesHint;

  /// No description provided for @agentFormPagesSummary.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} selected'**
  String agentFormPagesSummary(int selected, int total);

  /// No description provided for @agentFormPagesCount.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total}'**
  String agentFormPagesCount(int selected, int total);

  /// No description provided for @agentFormPagesNone.
  ///
  /// In en, this message translates to:
  /// **'No pages connected'**
  String get agentFormPagesNone;

  /// No description provided for @agentFormPagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pages connected yet. Connect a Facebook or Instagram page first, then link it to this agent.'**
  String get agentFormPagesEmpty;

  /// No description provided for @agentFormPageTaken.
  ///
  /// In en, this message translates to:
  /// **'Already on {agent}'**
  String agentFormPageTaken(String agent);

  /// No description provided for @agentFormPageActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get agentFormPageActive;

  /// No description provided for @agentFormPageInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get agentFormPageInactive;

  /// No description provided for @agentFormSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get agentFormSelectAll;

  /// No description provided for @agentFormClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get agentFormClear;

  /// No description provided for @agentFormProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get agentFormProducts;

  /// No description provided for @agentFormSellAll.
  ///
  /// In en, this message translates to:
  /// **'Sell all products'**
  String get agentFormSellAll;

  /// No description provided for @agentFormSellAllHint.
  ///
  /// In en, this message translates to:
  /// **'The agent knows your entire catalog. Turn off to choose.'**
  String get agentFormSellAllHint;

  /// No description provided for @agentFormProductsAll.
  ///
  /// In en, this message translates to:
  /// **'All products'**
  String get agentFormProductsAll;

  /// No description provided for @agentFormProductsChosen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No product chosen} =1{1 product chosen} other{{count} products chosen}}'**
  String agentFormProductsChosen(int count);

  /// No description provided for @agentFormProductSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get agentFormProductSearch;

  /// No description provided for @agentFormProductSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search products…'**
  String get agentFormProductSearchPlaceholder;

  /// No description provided for @agentFormProductsNone.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get agentFormProductsNone;

  /// No description provided for @agentFormProductsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No products match your search'**
  String get agentFormProductsNoMatch;

  /// 15c — the agent form in edit mode. The web says Edit Agent / Update your AI agent configuration; the rest is ours, unapproved.
  ///
  /// In en, this message translates to:
  /// **'Edit agent'**
  String get agentFormEditTitle;

  /// No description provided for @agentFormEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your AI agent configuration. Changes apply to the next messages.'**
  String get agentFormEditSubtitle;

  /// No description provided for @agentFormEditAdvancedHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a section to change it.'**
  String get agentFormEditAdvancedHint;

  /// No description provided for @agentFormActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get agentFormActive;

  /// No description provided for @agentFormActiveHint.
  ///
  /// In en, this message translates to:
  /// **'The agent responds to messages on its pages while active.'**
  String get agentFormActiveHint;

  /// No description provided for @agentFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get agentFormSave;

  /// No description provided for @agentFormSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Agent updated'**
  String get agentFormSavedToast;

  /// No description provided for @agentFormSavedMergedToast.
  ///
  /// In en, this message translates to:
  /// **'Agent updated — instructions added on the web were kept'**
  String get agentFormSavedMergedToast;

  /// No description provided for @agentFormLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave without saving?'**
  String get agentFormLeaveTitle;

  /// No description provided for @agentFormLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes to {name} will be lost.'**
  String agentFormLeaveBody(String name);

  /// Leave sheet body when backing out of a dirty Add product form. Ours, unapproved.
  ///
  /// In en, this message translates to:
  /// **'The product you started will be lost.'**
  String get productFormLeaveBody;

  /// Leave sheet body when backing out of a conversation with text in the composer. Ours, unapproved.
  ///
  /// In en, this message translates to:
  /// **'Your unsent reply will be lost.'**
  String get conversationLeaveBody;

  /// Leave sheet body when backing out of agent details with unsaved instructions or a typed resolve instruction. Ours, unapproved.
  ///
  /// In en, this message translates to:
  /// **'Your changes to the instructions will be lost.'**
  String get agentDetailsLeaveBody;

  /// Leave sheet body when closing the generate-agent sheet on its preview. Ours, unapproved.
  ///
  /// In en, this message translates to:
  /// **'The generated agent will be discarded.'**
  String get agentGenerateLeaveBody;

  /// Leave sheet body when backing out of the app from tutorial step T4 with typed values. Ours, unapproved.
  ///
  /// In en, this message translates to:
  /// **'The agent you started will be lost.'**
  String get tutorialAgentLeaveBody;

  /// Leave sheet title before abandoning the Chargily checkout web view. Ours, unapproved.
  ///
  /// In en, this message translates to:
  /// **'Leave the payment page?'**
  String get checkoutLeaveTitle;

  /// Leave sheet body before abandoning the Chargily checkout web view. Ours, unapproved.
  ///
  /// In en, this message translates to:
  /// **'Your payment is not finished.'**
  String get checkoutLeaveBody;

  /// No description provided for @agentFormKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get agentFormKeepEditing;

  /// No description provided for @agentFormLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave without saving'**
  String get agentFormLeave;

  /// No description provided for @agentsDetailsEditAgent.
  ///
  /// In en, this message translates to:
  /// **'Edit agent'**
  String get agentsDetailsEditAgent;

  /// 12 / 13 — the pages screen. pages.* and pageCard.* are the web's i18n verbatim; empty states, relative times and the disconnect sheet are ours (the web hardcodes English there), unapproved.
  ///
  /// In en, this message translates to:
  /// **'Connected channels'**
  String get pagesEyebrow;

  /// No description provided for @pagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pages & inboxes'**
  String get pagesTitle;

  /// No description provided for @pagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each connected page has its own inbox, stock and tailored AI agent.'**
  String get pagesSubtitle;

  /// No description provided for @pagesStatTotal.
  ///
  /// In en, this message translates to:
  /// **'Total pages'**
  String get pagesStatTotal;

  /// No description provided for @pagesStatPlanLimit.
  ///
  /// In en, this message translates to:
  /// **'Plan limit'**
  String get pagesStatPlanLimit;

  /// No description provided for @pagesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All Platforms'**
  String get pagesFilterAll;

  /// No description provided for @pagesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pages connected'**
  String get pagesEmptyTitle;

  /// No description provided for @pagesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Connect your pages to start managing them with AI.'**
  String get pagesEmptyBody;

  /// No description provided for @pagesEmptyPlatformTitle.
  ///
  /// In en, this message translates to:
  /// **'No {platform} pages'**
  String pagesEmptyPlatformTitle(String platform);

  /// No description provided for @pagesEmptyPlatformBody.
  ///
  /// In en, this message translates to:
  /// **'Connect your {platform} pages to get started.'**
  String pagesEmptyPlatformBody(String platform);

  /// No description provided for @pagesDisconnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect page?'**
  String get pagesDisconnectTitle;

  /// No description provided for @pagesDisconnectBody.
  ///
  /// In en, this message translates to:
  /// **'You won’t receive messages from {name} anymore and the AI agent will stop replying there.'**
  String pagesDisconnectBody(String name);

  /// No description provided for @pagesDisconnectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get pagesDisconnectConfirm;

  /// No description provided for @pagesDisconnectedToast.
  ///
  /// In en, this message translates to:
  /// **'Page disconnected'**
  String get pagesDisconnectedToast;

  /// No description provided for @pageCardAiOn.
  ///
  /// In en, this message translates to:
  /// **'AI on'**
  String get pageCardAiOn;

  /// No description provided for @pageCardAiOff.
  ///
  /// In en, this message translates to:
  /// **'AI off'**
  String get pageCardAiOff;

  /// No description provided for @pageCardStatConvos.
  ///
  /// In en, this message translates to:
  /// **'Convos'**
  String get pageCardStatConvos;

  /// No description provided for @pageCardStatMsgs7d.
  ///
  /// In en, this message translates to:
  /// **'Msgs 7d'**
  String get pageCardStatMsgs7d;

  /// No description provided for @pageCardStatUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get pageCardStatUnread;

  /// No description provided for @pageCardStatStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get pageCardStatStock;

  /// No description provided for @pageCardStatActive.
  ///
  /// In en, this message translates to:
  /// **'{n} active'**
  String pageCardStatActive(int n);

  /// No description provided for @pageCardStatIn.
  ///
  /// In en, this message translates to:
  /// **'{n} in'**
  String pageCardStatIn(int n);

  /// No description provided for @pageCardStatNeedsReply.
  ///
  /// In en, this message translates to:
  /// **'needs reply'**
  String get pageCardStatNeedsReply;

  /// No description provided for @pageCardStatProducts.
  ///
  /// In en, this message translates to:
  /// **'products'**
  String get pageCardStatProducts;

  /// No description provided for @pageCardAgentReady.
  ///
  /// In en, this message translates to:
  /// **'AI agent ready'**
  String get pageCardAgentReady;

  /// No description provided for @pageCardAgentTailored.
  ///
  /// In en, this message translates to:
  /// **'Tailored to this page’s inbox.'**
  String get pageCardAgentTailored;

  /// No description provided for @pageCardAgentNotReady.
  ///
  /// In en, this message translates to:
  /// **'No tailored agent yet'**
  String get pageCardAgentNotReady;

  /// No description provided for @pageCardAgentNotReadyHint.
  ///
  /// In en, this message translates to:
  /// **'Generate one from this page’s recent conversations.'**
  String get pageCardAgentNotReadyHint;

  /// No description provided for @pageCardAgentGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get pageCardAgentGenerate;

  /// No description provided for @pageCardAgentRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get pageCardAgentRegenerate;

  /// No description provided for @pageCardActionInbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get pageCardActionInbox;

  /// No description provided for @pageCardActionStock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get pageCardActionStock;

  /// No description provided for @pageCardActionConfigure.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get pageCardActionConfigure;

  /// No description provided for @pageCardActionDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get pageCardActionDisconnect;

  /// No description provided for @pageCardNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get pageCardNoActivity;

  /// No description provided for @pageCardNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get pageCardNow;

  /// No description provided for @pageCardMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String pageCardMinutesAgo(int n);

  /// No description provided for @pageCardHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} h ago'**
  String pageCardHoursAgo(int n);

  /// No description provided for @pageCardDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} d ago'**
  String pageCardDaysAgo(int n);

  /// The web's agentGen.* verbatim — its GenerateAgentModal, as a sheet.
  ///
  /// In en, this message translates to:
  /// **'Generate AI agent from inbox'**
  String get agentGenTitle;

  /// No description provided for @agentGenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We’ll read the recent conversations on {pageName} and draft a tailored agent.'**
  String agentGenSubtitle(String pageName);

  /// No description provided for @agentGenWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What this does'**
  String get agentGenWhatTitle;

  /// No description provided for @agentGenWhat1.
  ///
  /// In en, this message translates to:
  /// **'Reads up to 25 recent conversations on this page (we don’t store any new copy)'**
  String get agentGenWhat1;

  /// No description provided for @agentGenWhat2.
  ///
  /// In en, this message translates to:
  /// **'Detects what you sell, the languages your customers use, and the most common questions'**
  String get agentGenWhat2;

  /// No description provided for @agentGenWhat3.
  ///
  /// In en, this message translates to:
  /// **'Drafts a personality, tone, response length, and custom instructions tailored to your business'**
  String get agentGenWhat3;

  /// No description provided for @agentGenWhat4.
  ///
  /// In en, this message translates to:
  /// **'You preview, edit, and apply — nothing is changed until you tap Apply'**
  String get agentGenWhat4;

  /// No description provided for @agentGenStart.
  ///
  /// In en, this message translates to:
  /// **'Read inbox & generate'**
  String get agentGenStart;

  /// No description provided for @agentGenPhaseReading.
  ///
  /// In en, this message translates to:
  /// **'Reading recent conversations…'**
  String get agentGenPhaseReading;

  /// No description provided for @agentGenPhaseAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Understanding context — products, language, tone…'**
  String get agentGenPhaseAnalyzing;

  /// No description provided for @agentGenPhaseDrafting.
  ///
  /// In en, this message translates to:
  /// **'Drafting your tailored AI agent…'**
  String get agentGenPhaseDrafting;

  /// No description provided for @agentGenPhaseSubhint.
  ///
  /// In en, this message translates to:
  /// **'This usually takes 10–30 seconds.'**
  String get agentGenPhaseSubhint;

  /// No description provided for @agentGenStepRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get agentGenStepRead;

  /// No description provided for @agentGenStepAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get agentGenStepAnalyze;

  /// No description provided for @agentGenStepDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get agentGenStepDraft;

  /// No description provided for @agentGenSummary.
  ///
  /// In en, this message translates to:
  /// **'Business summary'**
  String get agentGenSummary;

  /// No description provided for @agentGenSampled.
  ///
  /// In en, this message translates to:
  /// **'{conversations} conversations · {messages} messages'**
  String agentGenSampled(int conversations, int messages);

  /// No description provided for @agentGenLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get agentGenLanguages;

  /// No description provided for @agentGenTopQuestions.
  ///
  /// In en, this message translates to:
  /// **'Top questions'**
  String get agentGenTopQuestions;

  /// No description provided for @agentGenPersonality.
  ///
  /// In en, this message translates to:
  /// **'Personality'**
  String get agentGenPersonality;

  /// No description provided for @agentGenTone.
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get agentGenTone;

  /// No description provided for @agentGenLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get agentGenLength;

  /// No description provided for @agentGenInstructions.
  ///
  /// In en, this message translates to:
  /// **'Custom instructions'**
  String get agentGenInstructions;

  /// No description provided for @agentGenEditHint.
  ///
  /// In en, this message translates to:
  /// **'Edit anything before applying. These instructions are saved on this page’s AI settings.'**
  String get agentGenEditHint;

  /// No description provided for @agentGenChars.
  ///
  /// In en, this message translates to:
  /// **'{n} chars'**
  String agentGenChars(int n);

  /// No description provided for @agentGenDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get agentGenDiscard;

  /// No description provided for @agentGenApply.
  ///
  /// In en, this message translates to:
  /// **'Apply to {pageName}'**
  String agentGenApply(String pageName);

  /// No description provided for @agentGenApplying.
  ///
  /// In en, this message translates to:
  /// **'Applying settings…'**
  String get agentGenApplying;

  /// No description provided for @agentGenCreated.
  ///
  /// In en, this message translates to:
  /// **'AI agent created and linked to {pageName}'**
  String agentGenCreated(String pageName);

  /// No description provided for @agentGenUpdated.
  ///
  /// In en, this message translates to:
  /// **'AI agent updated for {pageName}'**
  String agentGenUpdated(String pageName);

  /// No description provided for @agentGenApplyFail.
  ///
  /// In en, this message translates to:
  /// **'Could not apply settings'**
  String get agentGenApplyFail;

  /// No description provided for @agentGenToneBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get agentGenToneBalanced;

  /// No description provided for @agentGenToneFormal.
  ///
  /// In en, this message translates to:
  /// **'Formal'**
  String get agentGenToneFormal;

  /// No description provided for @agentGenToneCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get agentGenToneCasual;

  /// No description provided for @agentGenToneEnthusiastic.
  ///
  /// In en, this message translates to:
  /// **'Enthusiastic'**
  String get agentGenToneEnthusiastic;

  /// No description provided for @agentGenLengthShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get agentGenLengthShort;

  /// No description provided for @agentGenLengthMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get agentGenLengthMedium;

  /// No description provided for @agentGenLengthDetailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get agentGenLengthDetailed;

  /// No description provided for @agentsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New agent'**
  String get agentsNewTitle;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @menuCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get menuCategories;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @categoriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 category} other{{count} categories}}'**
  String categoriesCount(int count);

  /// No description provided for @categoriesSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get categoriesSearchPlaceholder;

  /// No description provided for @categoriesFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get categoriesFilters;

  /// The Filters chip once filters are applied.
  ///
  /// In en, this message translates to:
  /// **'Filters · {count}'**
  String categoriesFiltersActive(int count);

  /// No description provided for @categoriesSection.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get categoriesSection;

  /// No description provided for @categoriesProductCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 products} =1{1 product} other{{count} products}}'**
  String categoriesProductCount(int count);

  /// No description provided for @categoriesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Categories'**
  String get categoriesEmptyTitle;

  /// No description provided for @categoriesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create categories to organize your products'**
  String get categoriesEmptyBody;

  /// No description provided for @categoriesNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'No categories match your search or filters.'**
  String get categoriesNoMatchBody;

  /// No description provided for @categoriesFilterMin.
  ///
  /// In en, this message translates to:
  /// **'Products · min'**
  String get categoriesFilterMin;

  /// No description provided for @categoriesFilterMax.
  ///
  /// In en, this message translates to:
  /// **'Products · max'**
  String get categoriesFilterMax;

  /// No description provided for @categoriesFilterRangeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Must be at least the minimum'**
  String get categoriesFilterRangeInvalid;

  /// No description provided for @categoriesFilterHasDescription.
  ///
  /// In en, this message translates to:
  /// **'Has description'**
  String get categoriesFilterHasDescription;

  /// No description provided for @categoriesFilterColorsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String categoriesFilterColorsSelected(int count);

  /// No description provided for @categoriesFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get categoriesFilterApply;

  /// No description provided for @categoriesFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get categoriesFilterClear;

  /// No description provided for @categoryAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get categoryAddTitle;

  /// No description provided for @categoryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get categoryEditTitle;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryName;

  /// No description provided for @categoryNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g., Electronics'**
  String get categoryNamePlaceholder;

  /// No description provided for @categoryDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Optional description'**
  String get categoryDescriptionPlaceholder;

  /// No description provided for @categoryColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoryColor;

  /// No description provided for @categoryColorCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom colour'**
  String get categoryColorCustom;

  /// No description provided for @categoryColorHex.
  ///
  /// In en, this message translates to:
  /// **'Hex code'**
  String get categoryColorHex;

  /// No description provided for @categoryColorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Six hex digits, e.g. EC4899'**
  String get categoryColorInvalid;

  /// No description provided for @categoryColorApply.
  ///
  /// In en, this message translates to:
  /// **'Use this colour'**
  String get categoryColorApply;

  /// No description provided for @categoryCreate.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get categoryCreate;

  /// No description provided for @categoryUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Category'**
  String get categoryUpdate;

  /// No description provided for @categoryNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 2 characters'**
  String get categoryNameTooShort;

  /// No description provided for @categoryNameTaken.
  ///
  /// In en, this message translates to:
  /// **'You already have a category with this name'**
  String get categoryNameTaken;

  /// No description provided for @categoryAdded.
  ///
  /// In en, this message translates to:
  /// **'Category added'**
  String get categoryAdded;

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated'**
  String get categoryUpdated;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @categoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get categoryDeleteTitle;

  /// No description provided for @categoryDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String categoryDeleteBody(String name);

  /// No description provided for @categoryDeleteNotice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This category has 1 product.} other{This category has {count} products.}}'**
  String categoryDeleteNotice(int count);

  /// No description provided for @categoryDeleteNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'They will become uncategorized.'**
  String get categoryDeleteNoticeBody;

  /// No description provided for @menuClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get menuClients;

  /// No description provided for @clientsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'SALES'**
  String get clientsEyebrow;

  /// No description provided for @clientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clientsTitle;

  /// No description provided for @clientsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customers saved from AI conversations and confirmed orders'**
  String get clientsSubtitle;

  /// No description provided for @clientsStatTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Clients'**
  String get clientsStatTotal;

  /// No description provided for @clientsStatActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get clientsStatActive;

  /// No description provided for @clientsStatWithOrders.
  ///
  /// In en, this message translates to:
  /// **'With Orders'**
  String get clientsStatWithOrders;

  /// No description provided for @clientsStatTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get clientsStatTotalSpent;

  /// No description provided for @clientsSearchName.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get clientsSearchName;

  /// No description provided for @clientsSearchPhone.
  ///
  /// In en, this message translates to:
  /// **'Search by phone...'**
  String get clientsSearchPhone;

  /// No description provided for @clientsSection.
  ///
  /// In en, this message translates to:
  /// **'All clients'**
  String get clientsSection;

  /// No description provided for @clientsSourceAi.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get clientsSourceAi;

  /// No description provided for @clientsSourceManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get clientsSourceManual;

  /// No description provided for @clientsOrderCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 orders} =1{1 order} other{{count} orders}}'**
  String clientsOrderCount(int count);

  /// No description provided for @clientsConversationCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 conversation} other{{count} conversations}}'**
  String clientsConversationCount(int count);

  /// No description provided for @clientsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No clients'**
  String get clientsEmptyTitle;

  /// No description provided for @clientsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Clients appear here automatically when the AI chatbot confirms an order, or add them manually.'**
  String get clientsEmptyBody;

  /// No description provided for @clientsNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'No clients match your search or filters.'**
  String get clientsNoMatchBody;

  /// No description provided for @clientsFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get clientsFilterStatus;

  /// No description provided for @clientsFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get clientsFilterActive;

  /// No description provided for @clientsFilterInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get clientsFilterInactive;

  /// No description provided for @clientsFilterSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get clientsFilterSource;

  /// No description provided for @clientsFilterOrdersMin.
  ///
  /// In en, this message translates to:
  /// **'Orders · min'**
  String get clientsFilterOrdersMin;

  /// No description provided for @clientsFilterOrdersMax.
  ///
  /// In en, this message translates to:
  /// **'Orders · max'**
  String get clientsFilterOrdersMax;

  /// No description provided for @clientsFilterSpentMin.
  ///
  /// In en, this message translates to:
  /// **'Spent (DA) · min'**
  String get clientsFilterSpentMin;

  /// No description provided for @clientsFilterSpentMax.
  ///
  /// In en, this message translates to:
  /// **'Spent (DA) · max'**
  String get clientsFilterSpentMax;

  /// No description provided for @dateFrom.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get dateFrom;

  /// No description provided for @dateTo.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get dateTo;

  /// No description provided for @dateClear.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get dateClear;

  /// No description provided for @datePickerToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get datePickerToday;

  /// No description provided for @clientAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get clientAddTitle;

  /// No description provided for @clientEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Client'**
  String get clientEditTitle;

  /// No description provided for @clientCreate.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get clientCreate;

  /// No description provided for @clientUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Client'**
  String get clientUpdate;

  /// No description provided for @clientNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Client name'**
  String get clientNamePlaceholder;

  /// No description provided for @clientPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get clientPhone;

  /// No description provided for @clientAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get clientAddress;

  /// No description provided for @clientAddressPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Client address'**
  String get clientAddressPlaceholder;

  /// No description provided for @clientNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get clientNotes;

  /// No description provided for @clientNotesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Optional notes'**
  String get clientNotesPlaceholder;

  /// No description provided for @clientErrNoLetters.
  ///
  /// In en, this message translates to:
  /// **'Must contain at least one letter or number'**
  String get clientErrNoLetters;

  /// No description provided for @clientErrPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone must be 8-15 digits (e.g. 0555 12 34 56)'**
  String get clientErrPhone;

  /// No description provided for @clientErrPhoneTaken.
  ///
  /// In en, this message translates to:
  /// **'A client already exists with this phone ({name})'**
  String clientErrPhoneTaken(String name);

  /// No description provided for @clientAdded.
  ///
  /// In en, this message translates to:
  /// **'Client added'**
  String get clientAdded;

  /// No description provided for @clientUpdated.
  ///
  /// In en, this message translates to:
  /// **'Client updated'**
  String get clientUpdated;

  /// No description provided for @clientDeleted.
  ///
  /// In en, this message translates to:
  /// **'Client deleted'**
  String get clientDeleted;

  /// No description provided for @clientDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Client'**
  String get clientDeleteTitle;

  /// No description provided for @clientDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String clientDeleteBody(String name);

  /// No description provided for @clientDeleteNotice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This client has 1 order linked.} other{This client has {count} orders linked.}}'**
  String clientDeleteNotice(int count);

  /// No description provided for @clientDetailEyebrow.
  ///
  /// In en, this message translates to:
  /// **'CLIENT DETAILS'**
  String get clientDetailEyebrow;

  /// No description provided for @clientDetailTotalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get clientDetailTotalOrders;

  /// No description provided for @clientDetailLastOrder.
  ///
  /// In en, this message translates to:
  /// **'Last Order'**
  String get clientDetailLastOrder;

  /// No description provided for @clientDetailMetrics.
  ///
  /// In en, this message translates to:
  /// **'AI conversation metrics'**
  String get clientDetailMetrics;

  /// No description provided for @clientDetailConversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get clientDetailConversations;

  /// No description provided for @clientDetailMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get clientDetailMessages;

  /// No description provided for @clientDetailAiResponses.
  ///
  /// In en, this message translates to:
  /// **'AI responses'**
  String get clientDetailAiResponses;

  /// No description provided for @clientDetailClientMessages.
  ///
  /// In en, this message translates to:
  /// **'Client messages'**
  String get clientDetailClientMessages;

  /// No description provided for @clientDetailLastMessage.
  ///
  /// In en, this message translates to:
  /// **'Last message'**
  String get clientDetailLastMessage;

  /// No description provided for @clientDetailHistory.
  ///
  /// In en, this message translates to:
  /// **'Conversation history'**
  String get clientDetailHistory;

  /// No description provided for @clientDetailMsgs.
  ///
  /// In en, this message translates to:
  /// **'MSGS'**
  String get clientDetailMsgs;

  /// No description provided for @clientDetailFromAi.
  ///
  /// In en, this message translates to:
  /// **'AI:'**
  String get clientDetailFromAi;

  /// No description provided for @clientDetailFromClient.
  ///
  /// In en, this message translates to:
  /// **'Client:'**
  String get clientDetailFromClient;

  /// No description provided for @clientViewOrders.
  ///
  /// In en, this message translates to:
  /// **'View Orders'**
  String get clientViewOrders;

  /// No description provided for @clientOrdersSoon.
  ///
  /// In en, this message translates to:
  /// **'Orders are not available on mobile yet'**
  String get clientOrdersSoon;
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
