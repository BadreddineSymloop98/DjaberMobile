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

  @override
  String get authForgotBack => 'Back to Login';

  @override
  String get authForgotTitle => 'Forgot Password?';

  @override
  String get authForgotSubtitle => 'Enter your email to receive a reset link';

  @override
  String get authForgotEmail => 'Email Address';

  @override
  String get authForgotEmailPlaceholder => 'you@company.com';

  @override
  String get authForgotSubmit => 'Send Reset Link';

  @override
  String get authForgotSecure =>
      'Your password reset link is encrypted and expires in 1 hour';

  @override
  String get authForgotRemember => 'Remember your password?';

  @override
  String get authSentTitle => 'Check Your Email';

  @override
  String get authSentMessage => 'We’ve sent a password reset link to';

  @override
  String get authSentNoReceive => 'Didn’t receive the email?';

  @override
  String get authSentTryAnother => 'Try another email address';

  @override
  String get authErrInvalidCredentials => 'Invalid email or password';

  @override
  String get authErrUserExists => 'An account with this email already exists';

  @override
  String get authErrNetwork =>
      'Cannot reach the server. Check your connection.';

  @override
  String get authErrUnknown => 'Something went wrong. Please try again.';

  @override
  String homeWelcome(String name) {
    return 'Welcome back, $name';
  }

  @override
  String get menuSignOut => 'Sign out';

  @override
  String get tutorialStepMode => 'Choose your stock mode';

  @override
  String get tutorialStepProduct => 'Create your first product';

  @override
  String get tutorialStepAgent => 'Create your AI agent';

  @override
  String get tutorialStepPage => 'Connect your page';

  @override
  String get tutorialWelcomeTitle => 'Welcome to Djaber.ai';

  @override
  String get tutorialWelcomeBody =>
      'Let\'s get your shop running together. Four steps, and your agent starts answering your customers.';

  @override
  String get tutorialStockTitle => 'First, your stock';

  @override
  String get tutorialStockBody =>
      'You choose how to manage your stock, then you create your first product — name, price, quantity.';

  @override
  String get tutorialAgentTitle => 'Then your agent';

  @override
  String get tutorialAgentBody =>
      'Create it in three fields, connect your Facebook page, and it answers from the first question on.';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonActive => 'ACTIVE';

  @override
  String tutorialStepCounter(int step, int total) {
    return 'STEP $step OF $total';
  }

  @override
  String get tutorialModeTitle => 'How do you manage your stock?';

  @override
  String get tutorialModeSubtitle =>
      'This choice decides what you see in the app. You can change it at any time in settings.';

  @override
  String get stockModeSimple => 'Simple';

  @override
  String get stockModeAdvanced => 'Advanced';

  @override
  String get stockModeSimpleDesc =>
      'Products, Categories & Orders — manage your inventory and orders without the complexity.';

  @override
  String get stockModeAdvancedDesc =>
      'Full suite — Suppliers, Clients, Sales, Purchases, Caisse, Movements, Delivery & more.';

  @override
  String get tutorialProductTitle => 'Your first product';

  @override
  String get tutorialProductSubtitle =>
      'This is what your agent will sell. The description is what it reads to answer customers.';

  @override
  String get tutorialProductSubmit => 'Create the product';

  @override
  String get productName => 'Name';

  @override
  String get productNamePlaceholder => 'Satin dress — Black';

  @override
  String get productSku => 'Reference (SKU)';

  @override
  String get productSkuPlaceholder => 'PRD-001';

  @override
  String get productDescription => 'Description';

  @override
  String get productDescriptionPlaceholder =>
      'Describe the product — the agent uses this to sell it';

  @override
  String get productCostPrice => 'Cost price (DA)';

  @override
  String get productSellingPrice => 'Selling price (DA)';

  @override
  String get productQuantity => 'Initial quantity';

  @override
  String get productErrRequired => 'This field is required';

  @override
  String get productErrNotANumber => 'Enter a number';

  @override
  String get productErrMustBePositive => 'Must be greater than 0';

  @override
  String get productErrBelowCost =>
      'Must be greater than or equal to the cost price';

  @override
  String get tutorialAgentSubtitle =>
      'It answers your customers with your catalogue and your prices. Three fields are enough — everything else can be tuned later.';

  @override
  String get tutorialAgentSubmit => 'Create the agent';

  @override
  String get agentName => 'Agent name';

  @override
  String get agentNamePlaceholder => 'e.g. Sales assistant';

  @override
  String get agentPersonality => 'Personality';

  @override
  String get agentToneProfessional => 'Professional';

  @override
  String get agentToneProfessionalDesc => 'Formal and business-oriented';

  @override
  String get agentToneFriendly => 'Friendly';

  @override
  String get agentToneFriendlyDesc => 'Warm and approachable';

  @override
  String get agentToneCasual => 'Casual';

  @override
  String get agentToneCasualDesc => 'Relaxed and conversational';

  @override
  String get agentToneTechnical => 'Technical';

  @override
  String get agentToneTechnicalDesc => 'Detailed and precise';

  @override
  String get agentInstructions => 'Instructions';

  @override
  String get agentInstructionsPlaceholder =>
      'How it should answer, and when to hand over to you';

  @override
  String get tutorialConnectTitle => 'Connect your page';

  @override
  String get tutorialConnectSubtitle =>
      'This is the last step. Your agent answers in that page\'s inbox — the moment it is connected, it is working.';

  @override
  String get connectPermissionsHeading => 'Facebook will ask you for';

  @override
  String get connectPermissionPages => 'See the list of your pages';

  @override
  String get connectPermissionMessages => 'Read and send the page\'s messages';

  @override
  String get connectPermissionInfo => 'Access the page\'s information';

  @override
  String get connectFacebook => 'Connect Facebook';

  @override
  String get connectInstagram => 'Connect Instagram';

  @override
  String get oauthLoading => 'Loading Facebook…';

  @override
  String get oauthLoadingHint => 'Facebook\'s authorisation page appears here.';

  @override
  String get connectLater => 'Connect later';

  @override
  String get oauthDenied =>
      'Authorisation cancelled. You can try again whenever you like.';

  @override
  String get tutorialReadyTitle => 'Your agent is live';

  @override
  String get tutorialReadySubtitle =>
      'It is already answering your page\'s messages, with your catalogue and your prices. Add more products whenever you like.';

  @override
  String get tutorialReadySubmit => 'Open the app';

  @override
  String get tutorialReadyModeSimple =>
      'Simple — products, categories and orders';

  @override
  String get tutorialReadyModeAdvanced => 'Advanced — the full suite';
}
