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
  String get errorServer => 'Something went wrong on our side.';

  @override
  String get toastProductCreated => 'Product created';

  @override
  String get toastProductUpdated => 'Product updated';

  @override
  String get toastAgentCreated => 'AI agent created';

  @override
  String get toastPageConnected => 'Page connected';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

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
  String get obEsc2Body => '2400 DA · created by the AI';

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
  String get authSentMessage =>
      'If an account exists for this address, a reset link has just been sent to it';

  @override
  String get authSentNoReceive => 'Didn’t receive the email?';

  @override
  String get authSentTryAnother => 'Try another email address';

  @override
  String get authSentResend => 'Resend link';

  @override
  String authSentResendIn(int seconds) {
    return 'Resend link in ${seconds}s';
  }

  @override
  String get authSentResent => 'A new link has been sent';

  @override
  String get authSentNextStep =>
      'Open the link in the e-mail to choose a new password.';

  @override
  String get authResetTitle => 'New Password';

  @override
  String get authResetSubtitle => 'Choose a new password for your account';

  @override
  String get authResetDeadSubtitle =>
      'Request a new link to reset your password';

  @override
  String get authResetChecking => 'Checking the link…';

  @override
  String get authResetPasswordLabel => 'New password';

  @override
  String get authResetConfirmLabel => 'Confirm password';

  @override
  String get authErrPasswordMismatch => 'Passwords don’t match';

  @override
  String get authResetSubmit => 'Save password';

  @override
  String get authResetDone => 'Password updated';

  @override
  String get authResetRequestNew => 'Request a new link';

  @override
  String get menuOverview => 'Overview';

  @override
  String get menuInbox => 'Inbox';

  @override
  String get menuSocial => 'Social Media';

  @override
  String get menuServices => 'Services';

  @override
  String get menuProducts => 'Products';

  @override
  String get menuAgents => 'Agents';

  @override
  String get menuCommercial => 'Commercial';

  @override
  String get menuSoon => 'Soon';

  @override
  String get menuNotifications => 'Notifications';

  @override
  String get menuAnalytics => 'Analytics';

  @override
  String get menuReports => 'Reports';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuWebOnly => 'on the web';

  @override
  String get tutorialStepAlreadyDone => 'Already done — moving on';

  @override
  String get exitHint => 'Tap back again to leave';

  @override
  String get menuPages => 'Pages';

  @override
  String get menuPlan => 'Your Plan';

  @override
  String get menuPlanUnknown => '—';

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
  String get stockOverviewTitle => 'Stock overview';

  @override
  String get stockOverviewSubtitle => 'Inventory, sales and purchase summary';

  @override
  String get stockOverviewHintSimple =>
      'Simple mode shows products, orders and clients. Switch to Advanced for sales, purchases, suppliers, caisse and movements.';

  @override
  String get stockOverviewHintAdvanced =>
      'Advanced mode: full ERP — sales, purchases, suppliers, caisse and stock movements are enabled.';

  @override
  String get stockTotalProducts => 'Total products';

  @override
  String get stockLowStock => 'Low stock';

  @override
  String get stockValue => 'Stock value';

  @override
  String get stockRetailValue => 'Retail value';

  @override
  String get stockCategories => 'Categories';

  @override
  String get stockSuppliers => 'Suppliers';

  @override
  String get stockTotalItems => 'Total items in stock';

  @override
  String get stockSalesMonth => 'Sales this month';

  @override
  String get stockTotalSales => 'Total sales';

  @override
  String get stockRevenue => 'Revenue';

  @override
  String get stockPaid => 'Paid';

  @override
  String get stockPending => 'Pending';

  @override
  String get stockPurchasesMonth => 'Purchases this month';

  @override
  String get stockTotalPurchases => 'Total purchases';

  @override
  String get stockTotalSpent => 'Total spent';

  @override
  String get stockReceived => 'Received';

  @override
  String get stockRecentMovements => 'Recent movements';

  @override
  String get stockMovementsEmpty =>
      'No movements recorded yet. Stock movements will appear here when products are added, sold, or adjusted.';

  @override
  String get stockMoveIn => 'In';

  @override
  String get stockMoveOut => 'Out';

  @override
  String get stockMoveAdjustment => 'Adjustment';

  @override
  String get stockMoveReturn => 'Return';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Manage your account and application settings';

  @override
  String get settingsStockMode => 'Stock management';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageFrench => 'French';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'Arabic';

  @override
  String get settingsLanguageHelp =>
      'The app stays in the language you choose, even if your phone\'s language changes.';

  @override
  String get planNameIndividual => 'Individual';

  @override
  String get planNamePro => 'Pro';

  @override
  String get planNameTeams => 'Teams';

  @override
  String get planDescIndividual =>
      'To get started: connect your page and let the AI answer your customers.';

  @override
  String get planDescPro =>
      'For active sellers: vision, voice notes and more volume.';

  @override
  String get planDescTeams =>
      'For established shops: maximum volume and priority support.';

  @override
  String planFeaturePages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Facebook / Instagram pages',
      one: '1 Facebook or Instagram page',
    );
    return '$_temp0';
  }

  @override
  String planFeatureCredits(String amount) {
    return '$amount AI credits / month';
  }

  @override
  String planFeatureProducts(String amount) {
    return '$amount products';
  }

  @override
  String planFeatureDelivery(int count, String carriers) {
    return 'Delivery to $count wilayas ($carriers)';
  }

  @override
  String get planFeatureAgentText => '24/7 AI agent (text)';

  @override
  String get planFeatureAgentFull => '24/7 AI agent (text + images + voice)';

  @override
  String get planFeatureStock => 'Stock & order management';

  @override
  String get planFeatureCallConfirmation => 'Order confirmation by phone call';

  @override
  String get planFeatureVision => 'Image recognition (vision)';

  @override
  String get planFeatureVoiceNotes => 'Voice notes (transcription)';

  @override
  String get planFeatureCrossSell => 'AI cross-sell / up-sell';

  @override
  String get planFeatureUnlimitedProducts => 'Unlimited products';

  @override
  String get planFeatureUnlimitedConversations => 'Unlimited conversations';

  @override
  String get planFeatureEverythingPro => 'Everything in Pro';

  @override
  String get planFeaturePrioritySupport => 'Priority support';

  @override
  String get settingsAccount => 'Account information';

  @override
  String get settingsBilling => 'Plan & billing';

  @override
  String get settingsCurrentPlan => 'Current plan';

  @override
  String get settingsMonthly => 'Monthly';

  @override
  String get settingsYearly => 'Yearly';

  @override
  String get settingsFree => 'Free';

  @override
  String settingsPerMonth(String currency) {
    return '$currency / mo';
  }

  @override
  String settingsPerYear(String currency) {
    return '$currency / yr';
  }

  @override
  String get settingsBadgeCurrent => 'Current';

  @override
  String get settingsBadgePopular => 'Popular';

  @override
  String get settingsYourPlan => 'Your current plan';

  @override
  String get settingsFreeNoPayment => 'Free — no payment needed';

  @override
  String settingsSubscribe(String price) {
    return 'Subscribe — $price';
  }

  @override
  String get settingsRedirecting => 'Redirecting…';

  @override
  String get settingsVerifying => 'Verifying payment…';

  @override
  String get settingsNoPlans => 'No plans available yet.';

  @override
  String settingsCheckoutPaid(String plan) {
    return 'Payment confirmed — your $plan plan is active.';
  }

  @override
  String get settingsCheckoutPending =>
      'Payment not confirmed yet. If it went through, your plan will be activated shortly.';

  @override
  String get settingsCheckoutFailed => 'The payment did not go through.';

  @override
  String get settingsFbTitle => 'Facebook API permissions';

  @override
  String get settingsFbActive => 'Currently active permissions';

  @override
  String get settingsFbAvailable => 'Available advanced permissions';

  @override
  String get settingsFbReviewHint =>
      'These permissions require Facebook App Review approval.';

  @override
  String get settingsDangerTitle => 'Danger zone';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteHelp =>
      'Permanently delete your account and all associated data.';

  @override
  String get inboxTitle => 'Inbox';

  @override
  String get inboxSubtitle => 'Read and reply to your customer messages.';

  @override
  String get inboxNoPagesTitle => 'No pages connected';

  @override
  String get inboxNoPagesBody =>
      'Connect a Facebook or Instagram page to start receiving messages here.';

  @override
  String get inboxConnectPage => 'Connect a page';

  @override
  String get inboxPlatformMessenger => 'Messenger';

  @override
  String get inboxPlatformInstagram => 'Instagram DMs';

  @override
  String inboxSynced(String time) {
    return 'synced $time';
  }

  @override
  String get inboxSwitchPage => 'Switch page';

  @override
  String get inboxConnectAnother => 'Connect another page';

  @override
  String get inboxSync => 'Sync';

  @override
  String get inboxSyncing => 'Syncing…';

  @override
  String get inboxTabAll => 'All';

  @override
  String get inboxTabActive => 'Active';

  @override
  String get inboxTabResolved => 'Done';

  @override
  String get inboxTabArchived => 'Archived';

  @override
  String get inboxSearchHint => 'Search by name or message…';

  @override
  String get inboxNoMatches => 'No matches';

  @override
  String get inboxNoConversations => 'No conversations yet';

  @override
  String get inboxNothingHere => 'Nothing in this view';

  @override
  String get inboxPullFromFacebook => 'Pull from Facebook';

  @override
  String get inboxUpToDate => 'Up to date';

  @override
  String inboxSyncedCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Synced — $n new messages',
      one: 'Synced — 1 new message',
    );
    return '$_temp0';
  }

  @override
  String get inboxAttachment => 'Attachment';

  @override
  String get inboxEmptyMessage => 'Empty message';

  @override
  String get inboxAiPaused => 'AI paused';

  @override
  String get inboxStatusActive => 'Active';

  @override
  String get inboxStatusResolved => 'Resolved';

  @override
  String get inboxStatusArchived => 'Archived';

  @override
  String get inboxTimeNow => 'now';

  @override
  String inboxTimeMinutes(int n) {
    return '${n}m';
  }

  @override
  String inboxTimeHours(int n) {
    return '${n}h';
  }

  @override
  String get conversationMarkResolved => 'Mark resolved';

  @override
  String get conversationArchive => 'Archive conversation';

  @override
  String get conversationReopen => 'Reopen';

  @override
  String get conversationResumeAi => 'Resume the AI';

  @override
  String get conversationPausedNotice =>
      'The agent no longer replies to this customer. Reply here.';

  @override
  String get conversationReplyHint => 'Type your reply…';

  @override
  String get conversationSend => 'Send';

  @override
  String get conversationSending => 'Sending…';

  @override
  String get conversationReopenHint => 'Reopen this conversation to reply.';

  @override
  String get conversationEmpty => 'No messages yet';

  @override
  String get conversationResolvedToast => 'Marked as resolved';

  @override
  String get conversationArchivedToast => 'Archived';

  @override
  String get conversationReopenedToast => 'Conversation reopened';

  @override
  String get conversationAiResumedToast => 'The AI is replying again';

  @override
  String get conversationAuthorAi => 'AI';

  @override
  String get conversationAuthorYou => 'You';

  @override
  String get productVariantsTitle => 'Variants';

  @override
  String productVariantsTotal(int count) {
    return 'Total qty: $count';
  }

  @override
  String get productVariantAdd => 'Add variant';

  @override
  String get productVariantsEmpty =>
      'No variants. Tap “Add variant” to create one.';

  @override
  String get productVariantName => 'Name';

  @override
  String get productVariantNamePlaceholder => 'e.g., Red - Large';

  @override
  String get productVariantSku => 'SKU';

  @override
  String get productVariantSkuPlaceholder => 'Optional SKU';

  @override
  String get productVariantCost => 'Cost';

  @override
  String get productVariantPrice => 'Price';

  @override
  String get productVariantQuantity => 'Qty';

  @override
  String get productVariantMinQuantity => 'Min qty';

  @override
  String get productVariantRemove => 'Remove variant';

  @override
  String get productVariantDuplicate =>
      'Two variants cannot have the same name';

  @override
  String get productVariantsRequired =>
      'Add at least one variant, or untick the box.';

  @override
  String get productVariantsRetryHint =>
      'The product is created — only the missing variants will be sent again.';

  @override
  String get productDetailEyebrow => 'PRODUCT DETAILS';

  @override
  String get productDetailNoImages => 'No images';

  @override
  String get productDetailCost => 'Cost price';

  @override
  String get productDetailSelling => 'Selling price';

  @override
  String get productDetailProfit => 'Profit / margin';

  @override
  String get productDetailInStock => 'In stock';

  @override
  String get productDetailStatus => 'Status';

  @override
  String get productDetailActive => 'Active';

  @override
  String get productDetailInactive => 'Inactive';

  @override
  String productDetailVariants(int count) {
    return 'Variants ($count)';
  }

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
  String get productsEyebrow => 'CATALOGUE';

  @override
  String get productsTitle => 'Products';

  @override
  String productsSummary(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
      zero: 'No products yet',
    );
    return 'What your agent sells. $_temp0, $value of stock value.';
  }

  @override
  String get productsSearchLabel => 'SEARCH';

  @override
  String get productsSearchPlaceholder => 'Search products…';

  @override
  String get productsFilterAll => 'All';

  @override
  String get productsFilterLowStock => 'Low stock';

  @override
  String get productsSectionAll => 'ALL PRODUCTS';

  @override
  String get productsSectionLowStock => 'LOW STOCK';

  @override
  String get productsInStock => 'IN STOCK';

  @override
  String get productsOutOfStock => 'OUT OF STOCK';

  @override
  String productsThreshold(int count) {
    return 'THRESHOLD $count';
  }

  @override
  String productsVariantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count VARIANTS',
      one: '1 VARIANT',
    );
    return '$_temp0';
  }

  @override
  String get productsEmptyTitle => 'No products yet';

  @override
  String get productsEmptyBody =>
      'Add your first product and your agent will be able to sell it.';

  @override
  String get productsNoMatchTitle => 'Nothing matches';

  @override
  String get productsNoMatchBody => 'Try another word, or clear the filter.';

  @override
  String get productsAdd => 'Add Product';

  @override
  String get productAddTitle => 'Add Product';

  @override
  String get productAlertThreshold => 'Alert threshold';

  @override
  String get productAlertThresholdHint => 'Leave empty for no alert';

  @override
  String get productCategory => 'Category';

  @override
  String get productCategoryNone => 'No category';

  @override
  String get productUnit => 'Unit';

  @override
  String get productUnitNone => 'Select unit';

  @override
  String get productPhotos => 'Add photos';

  @override
  String get productPhotosHint => 'JPEG, PNG, WEBP · 5MB MAX';

  @override
  String get productHasVariants => 'This product has variants';

  @override
  String get productHasVariantsHint =>
      'Sizes or colours — the quantity is set per variant';

  @override
  String get productAddSubmit => 'Create product';

  @override
  String get productEditTitle => 'Edit product';

  @override
  String get productEditSubmit => 'Update product';

  @override
  String get productEditVariantsHint =>
      'To change variant quantities, use “Adjust stock”.';

  @override
  String get productEditLeaveBody => 'Your changes will be lost.';

  @override
  String get productEditDeleteVariantsTitle => 'Delete variants?';

  @override
  String productEditDeleteVariantsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variants will be permanently deleted.',
      one: '1 variant will be permanently deleted.',
    );
    return '$_temp0';
  }

  @override
  String productEditDeleteVariantsStock(int count, int stock) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count variants will be permanently deleted, and their $stock units written off your stock.',
      one:
          '1 variant will be permanently deleted, and its $stock units written off your stock.',
    );
    return '$_temp0';
  }

  @override
  String get productEditDeleteVariantsConfirm => 'Delete and save';

  @override
  String get productUnitAdd => 'Add a custom unit';

  @override
  String get productUnitName => 'Unit name';

  @override
  String get productUnitNamePlaceholder => 'e.g. Dozen';

  @override
  String get productUnitAbbreviation => 'Abbreviation';

  @override
  String get productUnitAbbreviationPlaceholder => 'e.g. dz';

  @override
  String get productUnitCreate => 'Add unit';

  @override
  String get stockAdjustTitle => 'Adjust stock';

  @override
  String stockAdjustSubtitle(String product, String stock) {
    return '$product  ·  Current stock: $stock';
  }

  @override
  String get stockAdjustIn => 'Stock in (+)';

  @override
  String get stockAdjustOut => 'Stock out (−)';

  @override
  String get stockAdjustSet => 'Set';

  @override
  String get stockAdjustReason => 'Reason';

  @override
  String stockAdjustCurrent(int count) {
    return 'QTY: $count';
  }

  @override
  String stockAdjustResult(int count) {
    return 'New quantity: $count';
  }

  @override
  String stockAdjustInsufficient(int count) {
    return 'Only $count in stock';
  }

  @override
  String get stockAdjustNothing => 'Enter a quantity on at least one line.';

  @override
  String get stockAdjustSubmit => 'Adjust stock';

  @override
  String get stockAdjustDone => 'Stock adjusted';

  @override
  String get expensesTitle => 'Product expenses';

  @override
  String get expensesEyebrow => 'PRODUCT EXPENSES';

  @override
  String get expensesMarginSummary => 'Margin summary';

  @override
  String get expensesTotal => 'Total expenses';

  @override
  String get expensesPerUnit => 'Expense / unit';

  @override
  String get expensesTrueCost => 'True cost';

  @override
  String get expensesNetMargin => 'Net margin';

  @override
  String expensesSection(int count) {
    return 'Expenses ($count)';
  }

  @override
  String get expensesEmpty =>
      'No expenses yet. Add one below and the margin above will take it into account.';

  @override
  String get expensesAddSection => 'Add an expense';

  @override
  String get expenseCategory => 'Category';

  @override
  String get expenseCategoryMarketing => 'Marketing';

  @override
  String get expenseCategoryShipping => 'Shipping';

  @override
  String get expenseCategoryPackaging => 'Packaging';

  @override
  String get expenseCategoryCustoms => 'Customs';

  @override
  String get expenseCategoryStorage => 'Storage';

  @override
  String get expenseCategoryOther => 'Other';

  @override
  String get expenseAmount => 'Amount (DA)';

  @override
  String get expenseAmountPlaceholder => 'Amount';

  @override
  String get expenseDescriptionPlaceholder => 'Description (optional)';

  @override
  String get expenseFixed => 'Fixed';

  @override
  String get expensePerUnit => 'Per unit';

  @override
  String get expensePerUnitTag => '/ unit';

  @override
  String get expenseAdd => 'Add expense';

  @override
  String get expenseAdded => 'Expense added';

  @override
  String get expenseDeleteTitle => 'Delete this expense?';

  @override
  String expenseDeleteBody(String category, String amount) {
    return '$category — $amount will be removed, and the margin recalculated.';
  }

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get productDeleteTitle => 'Delete product';

  @override
  String productDeleteBody(String name) {
    return 'Do you really want to delete $name? This action cannot be undone.';
  }

  @override
  String get productDeleteDone => 'Product deleted';

  @override
  String get productDetailActions => 'Actions';

  @override
  String get productDetailAdjustMeta =>
      'Stock in, stock out, or set the exact quantity';

  @override
  String get productDetailExpensesMeta => 'True cost and net margin';

  @override
  String get productDetailDeleteMeta => 'Removes it from your catalogue';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
      zero: 'No products',
    );
    return '$_temp0';
  }

  @override
  String get productPhotosSoon => 'Photos can be added from the web for now';

  @override
  String get productPhotosTooLarge => 'Photos over 5 MB were not added.';

  @override
  String get productPhotosWrongType =>
      'Only JPEG, PNG, WEBP or GIF photos can be added.';

  @override
  String get productPhotosTooMany => 'Up to 10 photos per product.';

  @override
  String get productPhotosUploadFailed =>
      'Product created, but its photos could not be uploaded.';

  @override
  String get productPhotosUploadFailedEdit =>
      'Product updated, but the new photos could not be uploaded.';

  @override
  String get productPhotoRemove => 'Remove photo';

  @override
  String get productPhotoCamera => 'Take a photo';

  @override
  String get productPhotoGallery => 'Choose from gallery';

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
  String get connectFailed =>
      'Your page could not be connected. Try again, or connect it later.';

  @override
  String get connectNothingNew =>
      'No new page came through. Make sure you pick a page when asked, then try again.';

  @override
  String get connectLinkFailed =>
      'Page connected, but not yet linked to your agent. You can link it from your agent\'s settings.';

  @override
  String get tutorialReadyTitle => 'Your agent is live';

  @override
  String get tutorialReadySubtitle =>
      'It is already answering your page\'s messages, with your catalogue and your prices. Add more products whenever you like.';

  @override
  String get tutorialReadyTitlePending => 'Almost there';

  @override
  String get tutorialReadySubtitlePending =>
      'Your catalogue and your agent are ready. All that is left is connecting your page — your agent starts answering the moment it is.';

  @override
  String get tutorialReadySubmit => 'Open the app';

  @override
  String get tutorialReadyModeSimple =>
      'Simple — products, categories and orders';

  @override
  String get tutorialReadyModeAdvanced => 'Advanced — the full suite';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeSnapshot => 'here is a snapshot';

  @override
  String get homeQueue => 'To handle';

  @override
  String get homeQueueStuck => 'AI stuck';

  @override
  String get homeQueueEmpty =>
      'Nothing waiting. The agent is handling every conversation.';

  @override
  String get homeQueueNoPage =>
      'No page connected, so no conversation can reach you yet.';

  @override
  String homeQueueMore(int count) {
    return '+ $count more';
  }

  @override
  String homeAgeMinutes(int count) {
    return '$count MIN';
  }

  @override
  String homeAgeHours(int count) {
    return '$count H';
  }

  @override
  String homeAgeDays(int count) {
    return '$count D';
  }

  @override
  String get homeNoPageTitle => 'No page connected';

  @override
  String get homeNoPageBody =>
      'Your agent has nowhere to answer yet. Connect your Facebook or Instagram page and it starts working on the first message.';

  @override
  String get homeOverview => 'Overview';

  @override
  String get homeKpiPages => 'Connected pages';

  @override
  String get homeKpiProducts => 'Products';

  @override
  String homeKpiLowStock(int count) {
    return '$count low stock';
  }

  @override
  String get homeKpiRevenue => 'Revenue (30d)';

  @override
  String homeKpiSales(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sales',
      one: '$count sale',
    );
    return '$_temp0';
  }

  @override
  String get homeKpiStockValue => 'Stock value';

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String get homeActionConnectTitle => 'Connect a page';

  @override
  String get homeActionConnectBody => 'Link your Facebook page';

  @override
  String get homeActionProductsTitle => 'Add products';

  @override
  String get homeActionProductsBody => 'Build your catalogue';

  @override
  String get homeActionAgentsTitle => 'AI agents';

  @override
  String get homeActionAgentsBody => 'Manage your assistants';

  @override
  String get homeYourPages => 'Your pages';

  @override
  String get homeManageAll => 'MANAGE ALL →';

  @override
  String get homePagesEmpty => 'No page connected yet.';

  @override
  String get homePageActive => 'ACTIVE';

  @override
  String get homePageInactive => 'PAUSED';

  @override
  String homePageConnectedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'CONNECTED $dateString';
  }

  @override
  String get platformFacebook => 'Facebook';

  @override
  String get platformInstagram => 'Instagram';

  @override
  String get homeGetStarted => 'Get started';

  @override
  String get homeStepConnectTitle => 'Connect a page';

  @override
  String get homeStepConnectBody => 'Link Facebook to start chatting';

  @override
  String get homeStepProductsTitle => 'Add products';

  @override
  String get homeStepProductsBody => 'Build up your catalogue';

  @override
  String get homeStepAgentTitle => 'Configure your AI agent';

  @override
  String get homeStepAgentBody => 'Set the tone and the behaviour';

  @override
  String get homeStepSaleTitle => 'Make your first sale';

  @override
  String get homeStepSaleBody => 'Watch the AI handle the requests';

  @override
  String get navHome => 'HOME';

  @override
  String get navQueue => 'QUEUE';

  @override
  String get navInbox => 'INBOX';

  @override
  String get navStock => 'STOCK';

  @override
  String get navOrders => 'ORD';

  @override
  String get commonNotBuilt => 'not built yet';

  @override
  String get agentsTitle => 'AI Agents';

  @override
  String get agentsSubtitle =>
      'Create and manage AI agents that sell your products on connected pages';

  @override
  String get agentsActive => 'AI active';

  @override
  String get agentsInactive => 'AI paused';

  @override
  String get agentsStatPages => 'Pages';

  @override
  String get agentsStatProducts => 'Products';

  @override
  String get agentsStatModel => 'Model';

  @override
  String get agentsAllProducts => 'All';

  @override
  String get agentsNoPages => 'Not answering on any page yet';

  @override
  String get agentsPause => 'Pause the agent';

  @override
  String get agentsResume => 'Resume the agent';

  @override
  String get agentsPausedToast => 'Agent paused — it no longer replies';

  @override
  String get agentsResumedToast => 'Agent active — it replies again';

  @override
  String get agentsEmptyTitle => 'No agent yet';

  @override
  String get agentsEmptyBody =>
      'Create an AI agent to automatically respond to messages on your connected pages and sell your products.';

  @override
  String get agentsEmptyCta => 'Create your agent';

  @override
  String get agentsActionInsights => 'Issues to review';

  @override
  String get agentsActionTest => 'Test the agent';

  @override
  String get agentsActionDetails => 'Details and stats';

  @override
  String get agentsActionDelete => 'Delete the agent';

  @override
  String get agentsDeleteTitle => 'Delete the agent?';

  @override
  String agentsDeleteBody(String name) {
    return '$name will be deleted and will stop replying on your pages. You can create a new agent afterwards.';
  }

  @override
  String get agentsDeleteConfirm => 'Delete';

  @override
  String get agentsDeletedToast => 'Agent deleted';

  @override
  String get agentsInsightsTitle => 'Pending issues';

  @override
  String get agentsInsightsEmpty =>
      'No pending issues — your agent is handling everything.';

  @override
  String get agentsInsightsNone => 'Nothing here.';

  @override
  String get agentsInsightUnclear => 'Unclear';

  @override
  String get agentsInsightUnknown => 'Unknown topic';

  @override
  String get agentsInsightHandoff => 'Handed to you';

  @override
  String get agentsInsightCustomer => 'Customer';

  @override
  String get agentsInsightAgent => 'AI response';

  @override
  String get agentsInsightResolve => 'Resolve';

  @override
  String get agentsInsightDismiss => 'Dismiss';

  @override
  String get agentsInsightAddAndResolve => 'Add and resolve';

  @override
  String get agentsInsightInstructionHint =>
      'Add an instruction so the agent handles this better next time…';

  @override
  String get agentsInsightResolved => 'Resolved';

  @override
  String get agentsInsightDismissed => 'Dismissed';

  @override
  String get agentsInsightPending => 'Pending';

  @override
  String get agentsInsightFailed => 'The issue could not be updated.';

  @override
  String agentsTestTitle(String name) {
    return 'Test — $name';
  }

  @override
  String get agentsTestEmpty => 'Send a message to test';

  @override
  String get agentsTestNote => 'A dry run: no credits used, no orders created.';

  @override
  String get agentsTestPlaceholder => 'Type a message…';

  @override
  String get agentsTestSend => 'Send';

  @override
  String get agentsTestFailed => 'No reply — try again.';

  @override
  String get agentsDetailsConversations => 'Conversations';

  @override
  String agentsDetailsConversationsFoot(int received, int sent) {
    return '$received received · $sent sent';
  }

  @override
  String get agentsDetailsMessages => 'Messages';

  @override
  String agentsDetailsLastActive(String date) {
    return 'Last: $date';
  }

  @override
  String get agentsDetailsNoActivity => 'No activity yet';

  @override
  String get agentsDetailsOrders => 'Orders created';

  @override
  String agentsDetailsResolvedFoot(int count) {
    return '$count resolved';
  }

  @override
  String get agentsDetailsInsights => 'Agent insights';

  @override
  String get agentsDetailsAll => 'All';

  @override
  String get agentsDetailsInstructions => 'Custom instructions';

  @override
  String get agentsDetailsNoInstructions => 'No instructions yet.';

  @override
  String get agentsDetailsEdit => 'Edit';

  @override
  String get agentsDetailsSave => 'Save';

  @override
  String get agentsDetailsSaved => 'Instructions saved';

  @override
  String get agentsDetailsSavedMerged =>
      'Instructions saved — lines added on the web were kept';

  @override
  String get agentsDetailsConflictTitle => 'Changed on the web';

  @override
  String get agentsDetailsConflictBody =>
      'These instructions were changed while you were editing. The current version:';

  @override
  String get agentsDetailsUseLatest => 'Use this version';

  @override
  String get agentsDetailsKeepMine => 'Replace with mine';

  @override
  String get agentsNotFound => 'Agent not found.';

  @override
  String agentsTestEmptyFor(String name) {
    return 'Send a message to test $name';
  }

  @override
  String get agentsTestProduct => 'Product';

  @override
  String agentsTestProductId(String id) {
    return 'ID: $id…';
  }

  @override
  String get agentsPresetsTitle => 'Start with a ready-made agent';

  @override
  String get agentsPresetsBody =>
      'Each one is fully configured for Algerian selling — Darija, Arabic and French, delivery quoting, and order handling. Pick one to launch in seconds, then fine-tune anything.';

  @override
  String get agentsPresetVisionVoice => 'VISION + VOICE';

  @override
  String get agentsPresetVoice => 'VOICE';

  @override
  String get agentsPresetCloserTagline =>
      'Turns conversations into confirmed orders';

  @override
  String get agentsPresetCloser1 =>
      'Guides the customer from question to confirmed order';

  @override
  String get agentsPresetCloser2 =>
      'Quotes delivery per wilaya and closes with the full total';

  @override
  String get agentsPresetCloser3 => 'Understands photos and voice notes';

  @override
  String get agentsPresetSupportTagline =>
      'Answers fast, escalates problems to you';

  @override
  String get agentsPresetSupport1 =>
      'Handles product and order questions politely';

  @override
  String get agentsPresetSupport2 =>
      'Escalates complaints and refunds to a human';

  @override
  String get agentsPresetSupport3 => 'Calm, accurate, and to the point';

  @override
  String get agentsPresetAdvisorTagline =>
      'Helps customers pick the right product';

  @override
  String get agentsPresetAdvisor1 =>
      'Compares options and explains differences';

  @override
  String get agentsPresetAdvisor2 => 'Matches a customer photo to your catalog';

  @override
  String get agentsPresetAdvisor3 =>
      'Great for catalogs with variants and specs';

  @override
  String get agentsPresetExpressTagline =>
      'Ultra-fast replies for high message volume';

  @override
  String get agentsPresetExpress1 => 'Short, quick answers for busy pages';

  @override
  String get agentsPresetExpress2 => 'Lowest credit use — text and voice only';

  @override
  String get agentsPresetExpress3 => 'Still places and cancels orders';

  @override
  String get agentsPresetUse => 'Use this agent  →';

  @override
  String get agentsPresetOwn => 'Prefer to build your own?';

  @override
  String get agentsPresetScratch => 'Start from scratch';

  @override
  String get agentsCreatedToast => 'Agent created';

  @override
  String get agentFormSubtitle =>
      'Set up an agent to answer your conversations. Only the name is required — everything else has a default.';

  @override
  String get agentFormBasics => 'Basic information';

  @override
  String get agentFormDescription => 'Description';

  @override
  String get agentFormDescriptionPlaceholder =>
      'Briefly describe what this agent does…';

  @override
  String get agentFormInstructions => 'Custom instructions';

  @override
  String get agentFormInstructionsPlaceholder =>
      'How to respond, what to avoid, how to handle certain cases…';

  @override
  String get agentFormInstructionsHint =>
      'These instructions guide the agent’s behavior in conversations.';

  @override
  String get agentFormAdvanced => 'Advanced settings';

  @override
  String get agentFormAdvancedHint => 'Optional — sensible defaults apply.';

  @override
  String get agentFormBehavior => 'Behavior';

  @override
  String get agentFormBehaviorSummary => 'Closing · Human handoff';

  @override
  String get agentFormClosing => 'Conversation closing';

  @override
  String get agentFormClosingPlaceholder =>
      'Examples:\n• After an order: “Thank you! Your order is on its way.”\n• Customer says bye: “Thanks for chatting, come back anytime!”\n• Angry customer: “Sorry — let me get a human to help you.”';

  @override
  String get agentFormClosingHint =>
      'When and how the AI closes conversations. If empty, it uses sensible defaults (thanks after an order, answers goodbyes).';

  @override
  String get agentFormHandoff => 'Human intervention rules';

  @override
  String get agentFormHandoffPlaceholder =>
      'Examples:\n• Refund or return → stop the AI, notify me\n• Discount request → let me handle it\n• Complaint → transfer the conversation to me';

  @override
  String get agentFormHandoffHint =>
      'When the AI should stop and let a human take over. Normal greetings (slm, cava, hi) are always handled by the AI.';

  @override
  String get agentFormDisplay => 'Product display';

  @override
  String get agentFormDisplayDefault => 'Default style';

  @override
  String get agentFormDisplayCustom => 'Custom';

  @override
  String get agentFormDisplayHint =>
      'How the AI presents products. Tap a tag to insert it — the AI fills in real product data.';

  @override
  String get agentFormTemplate => 'Template';

  @override
  String get agentFormTemplatePlaceholder => 'Tap the tags above or type here…';

  @override
  String get agentFormTagCard => 'Product card';

  @override
  String get agentFormTagName => 'Name';

  @override
  String get agentFormTagPrice => 'Price (DA)';

  @override
  String get agentFormTagDescription => 'Description';

  @override
  String get agentFormTagStock => 'Stock qty';

  @override
  String get agentFormTagNewLine => '↵ New line';

  @override
  String get agentFormPreview => 'Preview';

  @override
  String get agentFormPreviewLive => 'Live preview';

  @override
  String get agentFormPreviewCustomer => 'Show me your products';

  @override
  String get agentFormPreviewDefault =>
      'Here’s what we have!\n[PRODUCT_CARD]\nWould you like to order?';

  @override
  String get agentFormPreviewSampleName => 'Sample product';

  @override
  String get agentFormPreviewSampleDescription => 'A great product';

  @override
  String get agentFormModel => 'AI model';

  @override
  String agentFormModelSummary(String model, String temperature, int tokens) {
    return '$model · $temperature · $tokens tokens';
  }

  @override
  String get agentFormModelPicker => 'Model';

  @override
  String agentFormModelCost(String usd) {
    return '≈ $usd / 1000 msgs';
  }

  @override
  String get agentFormModelsLoading => 'Loading available models…';

  @override
  String get agentFormModelsUnavailable =>
      'AI models are temporarily unavailable. Please try again later.';

  @override
  String get agentFormTraitBestQuality => 'Best quality';

  @override
  String get agentFormTraitFastAffordable => 'Fast & affordable';

  @override
  String get agentFormTraitLongContext128k => '128k context';

  @override
  String get agentFormTraitLegacyFast => 'Legacy, fast';

  @override
  String get agentFormTraitBestBalanced => 'Best balanced';

  @override
  String get agentFormTraitFastCheap => 'Fast & cheap';

  @override
  String get agentFormTraitMostCapable => 'Most capable';

  @override
  String get agentFormTraitLatestFast => 'Latest, fast';

  @override
  String get agentFormTraitLongContext1m => '1M context';

  @override
  String get agentFormTraitBestOpenSource => 'Best open-source';

  @override
  String get agentFormTraitUltraFast => 'Ultra fast';

  @override
  String get agentFormTraitMixtureOfExperts => 'MoE, 32k context';

  @override
  String get agentFormTraitReasoning => 'Reasoning model';

  @override
  String get agentFormTemperature => 'Temperature';

  @override
  String get agentFormPrecise => 'Precise';

  @override
  String get agentFormCreative => 'Creative';

  @override
  String get agentFormMaxTokens => 'Max tokens';

  @override
  String get agentFormMaxTokensHint => 'Maximum response length · 100 – 4096';

  @override
  String get agentFormImages => 'Image recognition';

  @override
  String get agentFormImagesHint =>
      'The AI sees customer photos and compares them with your products. 5 credits per image (vs 1 for text).';

  @override
  String get agentFormVoice => 'Voice notes';

  @override
  String get agentFormVoiceHint =>
      'The AI transcribes voice notes (AR, FR, EN, Darja). 3 credits per note. When off, the agent asks for a text instead.';

  @override
  String get agentFormDelay => 'Response delay';

  @override
  String agentFormDelayValue(int seconds) {
    return '$seconds s';
  }

  @override
  String get agentFormDelayMax => '10 s';

  @override
  String get agentFormDelayHint =>
      'Waits for more messages before replying — customers often send several short ones, and this combines them.';

  @override
  String get agentFormPages => 'Connected pages';

  @override
  String get agentFormPagesHint =>
      'The pages this agent answers on. Each page can only have one agent.';

  @override
  String agentFormPagesSummary(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String agentFormPagesCount(int selected, int total) {
    return '$selected of $total';
  }

  @override
  String get agentFormPagesNone => 'No pages connected';

  @override
  String get agentFormPagesEmpty =>
      'No pages connected yet. Connect a Facebook or Instagram page first, then link it to this agent.';

  @override
  String agentFormPageTaken(String agent) {
    return 'Already on $agent';
  }

  @override
  String get agentFormPageActive => 'Active';

  @override
  String get agentFormPageInactive => 'Inactive';

  @override
  String get agentFormSelectAll => 'Select all';

  @override
  String get agentFormClear => 'Clear';

  @override
  String get agentFormProducts => 'Products';

  @override
  String get agentFormSellAll => 'Sell all products';

  @override
  String get agentFormSellAllHint =>
      'The agent knows your entire catalog. Turn off to choose.';

  @override
  String get agentFormProductsAll => 'All products';

  @override
  String agentFormProductsChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products chosen',
      one: '1 product chosen',
      zero: 'No product chosen',
    );
    return '$_temp0';
  }

  @override
  String get agentFormProductSearch => 'Search';

  @override
  String get agentFormProductSearchPlaceholder => 'Search products…';

  @override
  String get agentFormProductsNone => 'No products available';

  @override
  String get agentFormProductsNoMatch => 'No products match your search';

  @override
  String get agentFormEditTitle => 'Edit agent';

  @override
  String get agentFormEditSubtitle =>
      'Update your AI agent configuration. Changes apply to the next messages.';

  @override
  String get agentFormEditAdvancedHint => 'Tap a section to change it.';

  @override
  String get agentFormActive => 'Active';

  @override
  String get agentFormActiveHint =>
      'The agent responds to messages on its pages while active.';

  @override
  String get agentFormSave => 'Save changes';

  @override
  String get agentFormSavedToast => 'Agent updated';

  @override
  String get agentFormSavedMergedToast =>
      'Agent updated — instructions added on the web were kept';

  @override
  String get agentFormLeaveTitle => 'Leave without saving?';

  @override
  String agentFormLeaveBody(String name) {
    return 'Your changes to $name will be lost.';
  }

  @override
  String get productFormLeaveBody => 'The product you started will be lost.';

  @override
  String get conversationLeaveBody => 'Your unsent reply will be lost.';

  @override
  String get agentDetailsLeaveBody =>
      'Your changes to the instructions will be lost.';

  @override
  String get agentGenerateLeaveBody => 'The generated agent will be discarded.';

  @override
  String get tutorialAgentLeaveBody => 'The agent you started will be lost.';

  @override
  String get checkoutLeaveTitle => 'Leave the payment page?';

  @override
  String get checkoutLeaveBody => 'Your payment is not finished.';

  @override
  String get agentFormKeepEditing => 'Keep editing';

  @override
  String get agentFormLeave => 'Leave without saving';

  @override
  String get agentsDetailsEditAgent => 'Edit agent';

  @override
  String get pagesEyebrow => 'Connected channels';

  @override
  String get pagesTitle => 'Pages & inboxes';

  @override
  String get pagesSubtitle =>
      'Each connected page has its own inbox, stock and tailored AI agent.';

  @override
  String get pagesStatTotal => 'Total pages';

  @override
  String get pagesStatPlanLimit => 'Plan limit';

  @override
  String get pagesFilterAll => 'All Platforms';

  @override
  String get pagesEmptyTitle => 'No pages connected';

  @override
  String get pagesEmptyBody =>
      'Connect your pages to start managing them with AI.';

  @override
  String pagesEmptyPlatformTitle(String platform) {
    return 'No $platform pages';
  }

  @override
  String pagesEmptyPlatformBody(String platform) {
    return 'Connect your $platform pages to get started.';
  }

  @override
  String get pagesDisconnectTitle => 'Disconnect page?';

  @override
  String pagesDisconnectBody(String name) {
    return 'You won’t receive messages from $name anymore and the AI agent will stop replying there.';
  }

  @override
  String get pagesDisconnectConfirm => 'Disconnect';

  @override
  String get pagesDisconnectedToast => 'Page disconnected';

  @override
  String get pageCardAiOn => 'AI on';

  @override
  String get pageCardAiOff => 'AI off';

  @override
  String get pageCardStatConvos => 'Convos';

  @override
  String get pageCardStatMsgs7d => 'Msgs 7d';

  @override
  String get pageCardStatUnread => 'Unread';

  @override
  String get pageCardStatStock => 'Stock';

  @override
  String pageCardStatActive(int n) {
    return '$n active';
  }

  @override
  String pageCardStatIn(int n) {
    return '$n in';
  }

  @override
  String get pageCardStatNeedsReply => 'needs reply';

  @override
  String get pageCardStatProducts => 'products';

  @override
  String get pageCardAgentReady => 'AI agent ready';

  @override
  String get pageCardAgentTailored => 'Tailored to this page’s inbox.';

  @override
  String get pageCardAgentNotReady => 'No tailored agent yet';

  @override
  String get pageCardAgentNotReadyHint =>
      'Generate one from this page’s recent conversations.';

  @override
  String get pageCardAgentGenerate => 'Generate';

  @override
  String get pageCardAgentRegenerate => 'Regenerate';

  @override
  String get pageCardActionInbox => 'Inbox';

  @override
  String get pageCardActionStock => 'Stock';

  @override
  String get pageCardActionConfigure => 'Configure';

  @override
  String get pageCardActionDisconnect => 'Disconnect';

  @override
  String get pageCardNoActivity => 'No activity yet';

  @override
  String get pageCardNow => 'just now';

  @override
  String pageCardMinutesAgo(int n) {
    return '$n min ago';
  }

  @override
  String pageCardHoursAgo(int n) {
    return '$n h ago';
  }

  @override
  String pageCardDaysAgo(int n) {
    return '$n d ago';
  }

  @override
  String get agentGenTitle => 'Generate AI agent from inbox';

  @override
  String agentGenSubtitle(String pageName) {
    return 'We’ll read the recent conversations on $pageName and draft a tailored agent.';
  }

  @override
  String get agentGenWhatTitle => 'What this does';

  @override
  String get agentGenWhat1 =>
      'Reads up to 25 recent conversations on this page (we don’t store any new copy)';

  @override
  String get agentGenWhat2 =>
      'Detects what you sell, the languages your customers use, and the most common questions';

  @override
  String get agentGenWhat3 =>
      'Drafts a personality, tone, response length, and custom instructions tailored to your business';

  @override
  String get agentGenWhat4 =>
      'You preview, edit, and apply — nothing is changed until you tap Apply';

  @override
  String get agentGenStart => 'Read inbox & generate';

  @override
  String get agentGenPhaseReading => 'Reading recent conversations…';

  @override
  String get agentGenPhaseAnalyzing =>
      'Understanding context — products, language, tone…';

  @override
  String get agentGenPhaseDrafting => 'Drafting your tailored AI agent…';

  @override
  String get agentGenPhaseSubhint => 'This usually takes 10–30 seconds.';

  @override
  String get agentGenStepRead => 'Read';

  @override
  String get agentGenStepAnalyze => 'Analyze';

  @override
  String get agentGenStepDraft => 'Draft';

  @override
  String get agentGenSummary => 'Business summary';

  @override
  String agentGenSampled(int conversations, int messages) {
    return '$conversations conversations · $messages messages';
  }

  @override
  String get agentGenLanguages => 'Languages';

  @override
  String get agentGenTopQuestions => 'Top questions';

  @override
  String get agentGenPersonality => 'Personality';

  @override
  String get agentGenTone => 'Tone';

  @override
  String get agentGenLength => 'Length';

  @override
  String get agentGenInstructions => 'Custom instructions';

  @override
  String get agentGenEditHint =>
      'Edit anything before applying. These instructions are saved on this page’s AI settings.';

  @override
  String agentGenChars(int n) {
    return '$n chars';
  }

  @override
  String get agentGenDiscard => 'Discard';

  @override
  String agentGenApply(String pageName) {
    return 'Apply to $pageName';
  }

  @override
  String get agentGenApplying => 'Applying settings…';

  @override
  String agentGenCreated(String pageName) {
    return 'AI agent created and linked to $pageName';
  }

  @override
  String agentGenUpdated(String pageName) {
    return 'AI agent updated for $pageName';
  }

  @override
  String get agentGenApplyFail => 'Could not apply settings';

  @override
  String get agentGenToneBalanced => 'Balanced';

  @override
  String get agentGenToneFormal => 'Formal';

  @override
  String get agentGenToneCasual => 'Casual';

  @override
  String get agentGenToneEnthusiastic => 'Enthusiastic';

  @override
  String get agentGenLengthShort => 'Short';

  @override
  String get agentGenLengthMedium => 'Medium';

  @override
  String get agentGenLengthDetailed => 'Detailed';

  @override
  String get agentsNewTitle => 'New agent';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get menuCategories => 'Categories';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String categoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categories',
      one: '1 category',
    );
    return '$_temp0';
  }

  @override
  String get categoriesSearchPlaceholder => 'Search categories...';

  @override
  String get categoriesFilters => 'Filters';

  @override
  String categoriesFiltersActive(int count) {
    return 'Filters · $count';
  }

  @override
  String get categoriesSection => 'All categories';

  @override
  String categoriesProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
      zero: '0 products',
    );
    return '$_temp0';
  }

  @override
  String get categoriesEmptyTitle => 'No Categories';

  @override
  String get categoriesEmptyBody =>
      'Create categories to organize your products';

  @override
  String get categoriesNoMatchBody =>
      'No categories match your search or filters.';

  @override
  String get categoriesFilterMin => 'Products · min';

  @override
  String get categoriesFilterMax => 'Products · max';

  @override
  String get categoriesFilterRangeInvalid => 'Must be at least the minimum';

  @override
  String get categoriesFilterHasDescription => 'Has description';

  @override
  String categoriesFilterColorsSelected(int count) {
    return '$count selected';
  }

  @override
  String get categoriesFilterApply => 'Apply filters';

  @override
  String get categoriesFilterClear => 'Clear all';

  @override
  String get categoryAddTitle => 'Add Category';

  @override
  String get categoryEditTitle => 'Edit Category';

  @override
  String get categoryName => 'Name';

  @override
  String get categoryNamePlaceholder => 'e.g., Electronics';

  @override
  String get categoryDescriptionPlaceholder => 'Optional description';

  @override
  String get categoryColor => 'Color';

  @override
  String get categoryColorCustom => 'Custom colour';

  @override
  String get categoryColorHex => 'Hex code';

  @override
  String get categoryColorInvalid => 'Six hex digits, e.g. EC4899';

  @override
  String get categoryColorApply => 'Use this colour';

  @override
  String get categoryCreate => 'Add Category';

  @override
  String get categoryUpdate => 'Update Category';

  @override
  String get categoryNameTooShort => 'At least 2 characters';

  @override
  String get categoryNameTaken => 'You already have a category with this name';

  @override
  String get categoryAdded => 'Category added';

  @override
  String get categoryUpdated => 'Category updated';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get categoryDeleteTitle => 'Delete Category';

  @override
  String categoryDeleteBody(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String categoryDeleteNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This category has $count products.',
      one: 'This category has 1 product.',
    );
    return '$_temp0';
  }

  @override
  String get categoryDeleteNoticeBody => 'They will become uncategorized.';

  @override
  String get menuClients => 'Clients';

  @override
  String get clientsEyebrow => 'SALES';

  @override
  String get clientsTitle => 'Clients';

  @override
  String get clientsSubtitle =>
      'Customers saved from AI conversations and confirmed orders';

  @override
  String get clientsStatTotal => 'Total Clients';

  @override
  String get clientsStatActive => 'Active';

  @override
  String get clientsStatWithOrders => 'With Orders';

  @override
  String get clientsStatTotalSpent => 'Total Spent';

  @override
  String get clientsSearchName => 'Search by name or email...';

  @override
  String get clientsSearchPhone => 'Search by phone...';

  @override
  String get clientsSection => 'All clients';

  @override
  String get clientsSourceAi => 'AI Chat';

  @override
  String get clientsSourceManual => 'Manual';

  @override
  String clientsOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
      zero: '0 orders',
    );
    return '$_temp0';
  }

  @override
  String clientsConversationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversations',
      one: '1 conversation',
    );
    return '$_temp0';
  }

  @override
  String get clientsEmptyTitle => 'No clients';

  @override
  String get clientsEmptyBody =>
      'Clients appear here automatically when the AI chatbot confirms an order, or add them manually.';

  @override
  String get clientsNoMatchBody => 'No clients match your search or filters.';

  @override
  String get clientsFilterStatus => 'Status';

  @override
  String get clientsFilterActive => 'Active';

  @override
  String get clientsFilterInactive => 'Inactive';

  @override
  String get clientsFilterSource => 'Source';

  @override
  String get clientsFilterOrdersMin => 'Orders · min';

  @override
  String get clientsFilterOrdersMax => 'Orders · max';

  @override
  String get clientsFilterSpentMin => 'Spent (DA) · min';

  @override
  String get clientsFilterSpentMax => 'Spent (DA) · max';

  @override
  String get dateFrom => 'From date';

  @override
  String get dateTo => 'To date';

  @override
  String get dateClear => 'Clear date';

  @override
  String get datePickerToday => 'Today';

  @override
  String get clientAddTitle => 'Add Client';

  @override
  String get clientEditTitle => 'Edit Client';

  @override
  String get clientCreate => 'Add Client';

  @override
  String get clientUpdate => 'Update Client';

  @override
  String get clientNamePlaceholder => 'Client name';

  @override
  String get clientPhone => 'Phone';

  @override
  String get clientAddress => 'Address';

  @override
  String get clientAddressPlaceholder => 'Client address';

  @override
  String get clientNotes => 'Notes';

  @override
  String get clientNotesPlaceholder => 'Optional notes';

  @override
  String get clientErrNoLetters => 'Must contain at least one letter or number';

  @override
  String get clientErrPhone => 'Phone must be 8-15 digits (e.g. 0555 12 34 56)';

  @override
  String clientErrPhoneTaken(String name) {
    return 'A client already exists with this phone ($name)';
  }

  @override
  String get clientAdded => 'Client added';

  @override
  String get clientUpdated => 'Client updated';

  @override
  String get clientDeleted => 'Client deleted';

  @override
  String get clientDeleteTitle => 'Delete Client';

  @override
  String clientDeleteBody(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String clientDeleteNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This client has $count orders linked.',
      one: 'This client has 1 order linked.',
    );
    return '$_temp0';
  }

  @override
  String get clientDetailEyebrow => 'CLIENT DETAILS';

  @override
  String get clientDetailTotalOrders => 'Total Orders';

  @override
  String get clientDetailLastOrder => 'Last Order';

  @override
  String get clientDetailMetrics => 'AI conversation metrics';

  @override
  String get clientDetailConversations => 'Conversations';

  @override
  String get clientDetailMessages => 'Messages';

  @override
  String get clientDetailAiResponses => 'AI responses';

  @override
  String get clientDetailClientMessages => 'Client messages';

  @override
  String get clientDetailLastMessage => 'Last message';

  @override
  String get clientDetailHistory => 'Conversation history';

  @override
  String get clientDetailMsgs => 'MSGS';

  @override
  String get clientDetailFromAi => 'AI:';

  @override
  String get clientDetailFromClient => 'Client:';

  @override
  String get clientViewOrders => 'View Orders';

  @override
  String get clientOrdersSoon => 'Orders are not available on mobile yet';

  @override
  String get menuSuppliers => 'Suppliers';

  @override
  String get suppliersEyebrow => 'PURCHASES';

  @override
  String get suppliersTitle => 'Suppliers';

  @override
  String suppliersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suppliers',
      one: '1 supplier',
    );
    return '$_temp0';
  }

  @override
  String get suppliersStatTotal => 'Total Suppliers';

  @override
  String get suppliersStatWithPurchases => 'With Purchases';

  @override
  String get suppliersSearch => 'Search suppliers...';

  @override
  String get suppliersSection => 'All suppliers';

  @override
  String suppliersPurchaseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count purchases',
      one: '1 purchase',
      zero: '0 purchases',
    );
    return '$_temp0';
  }

  @override
  String get suppliersEmptyTitle => 'No Suppliers';

  @override
  String get suppliersEmptyBody => 'Add suppliers to manage your purchases';

  @override
  String get suppliersNoMatchBody =>
      'No suppliers match your search or filters.';

  @override
  String get suppliersFilterPurchasesMin => 'Purchases · min';

  @override
  String get suppliersFilterPurchasesMax => 'Purchases · max';

  @override
  String get supplierActive => 'Active';

  @override
  String get supplierInactive => 'Inactive';

  @override
  String get supplierAddTitle => 'Add Supplier';

  @override
  String get supplierEditTitle => 'Edit Supplier';

  @override
  String get supplierCreate => 'Add Supplier';

  @override
  String get supplierUpdate => 'Update Supplier';

  @override
  String get supplierNamePlaceholder => 'Supplier name';

  @override
  String get supplierAddressPlaceholder => 'Supplier address';

  @override
  String get supplierErrNameTaken =>
      'You already have a supplier with this name';

  @override
  String get supplierAdded => 'Supplier added';

  @override
  String get supplierUpdated => 'Supplier updated';

  @override
  String get supplierDeleted => 'Supplier deleted';

  @override
  String get supplierDeleteTitle => 'Delete Supplier';

  @override
  String supplierDeleteBody(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String supplierDeleteNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This supplier has $count purchases linked.',
      one: 'This supplier has 1 purchase linked.',
    );
    return '$_temp0';
  }

  @override
  String get supplierDetailEyebrow => 'SUPPLIER DETAILS';

  @override
  String get supplierDetailPurchases => 'Purchases';

  @override
  String get supplierDetailMemberSince => 'Member Since';

  @override
  String get supplierViewPurchases => 'View Purchases';

  @override
  String get supplierPurchasesSoon =>
      'Purchases are not available on mobile yet';

  @override
  String get supplierNotFound => 'This supplier no longer exists.';

  @override
  String get ordersEyebrow => 'SALES';

  @override
  String get ordersTitle => 'Orders';

  @override
  String ordersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
    );
    return '$_temp0';
  }

  @override
  String get ordersStatTotal => 'Total orders';

  @override
  String get ordersStatPending => 'Pending';

  @override
  String get ordersStatDelivered => 'Delivered';

  @override
  String get ordersStatValue => 'Total value';

  @override
  String get ordersSearch => 'Search by order #, client, phone, product...';

  @override
  String get ordersSection => 'All orders';

  @override
  String get ordersSelectAll => 'Select all';

  @override
  String get ordersNew => 'New order';

  @override
  String get ordersEmptyTitle => 'No orders yet';

  @override
  String get ordersEmptyBody =>
      'Orders appear from AI chatbot confirmations, or create them manually.';

  @override
  String get ordersNoMatchBody => 'No orders match your search or filters.';

  @override
  String get orderStatusAll => 'All';

  @override
  String get orderStatusPending => 'New';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusPreparing => 'Preparing';

  @override
  String get orderStatusShipped => 'Shipped';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderStatusReturned => 'Returned';

  @override
  String get orderConfirmNotCalled => 'Not called';

  @override
  String get orderConfirmNoAnswer => 'No answer';

  @override
  String get orderConfirmConfirmed => 'Confirmed';

  @override
  String get orderConfirmRejected => 'Rejected';

  @override
  String orderConfirmWithCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get orderSourceAi => 'AI';

  @override
  String get orderSourceAiLong => 'AI chatbot';

  @override
  String get orderSourceManual => 'Manual';

  @override
  String get paymentStatusPaid => 'Paid';

  @override
  String get paymentStatusPending => 'Pending';

  @override
  String get paymentStatusPartial => 'Partial';

  @override
  String ordersRowItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String ordersRowMeta(String items, String paid, String remaining) {
    return '$items  ·  PAID $paid  ·  REMAINING $remaining';
  }

  @override
  String get ordersRowNoRemaining => '–';

  @override
  String get orderActionCallConfirm => 'Call & confirm';

  @override
  String get orderActionRetry => 'Try again';

  @override
  String get orderActionPrepare => 'Prepare';

  @override
  String get orderActionMarkShipped => 'Mark shipped';

  @override
  String get orderActionMarkDelivered => 'Mark delivered';

  @override
  String get orderActionOpen => 'Open';

  @override
  String get orderActionMarkReturned => 'Mark returned';

  @override
  String get orderActionDelete => 'Delete order';

  @override
  String ordersSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders selected',
      one: '1 order selected',
    );
    return '$_temp0';
  }

  @override
  String get ordersClearSelection => 'Clear';

  @override
  String get ordersBulkConfirm => 'Confirm all';

  @override
  String get ordersBulkPrepare => 'Start preparing all';

  @override
  String get ordersBulkShip => 'Ship all';

  @override
  String get ordersBulkDeliver => 'Mark all delivered';

  @override
  String get ordersBulkReturn => 'Mark all returned';

  @override
  String get ordersBulkCancel => 'Cancel all';

  @override
  String get ordersBulkNone => 'No bulk action available for this selection';

  @override
  String ordersBulkFailed(int failed, int total) {
    return '$failed of $total orders could not be updated';
  }

  @override
  String get ordersFilters => 'Filters';

  @override
  String ordersFiltersActive(int count) {
    return 'Filters · $count';
  }

  @override
  String get ordersFilterStatus => 'Order status';

  @override
  String get ordersFilterStatusAll => 'All statuses';

  @override
  String get ordersFilterConfirmation => 'Confirmation';

  @override
  String get ordersFilterPayment => 'Payment status';

  @override
  String get ordersFilterAny => 'All';

  @override
  String get ordersFilterHasRemaining => 'Has remaining balance';

  @override
  String get ordersFilterPaymentDisabled =>
      'Disabled — \"Has remaining\" is active';

  @override
  String get ordersFilterTotalMin => 'Total amount (DA) · min';

  @override
  String get ordersFilterTotalMax => 'Total amount (DA) · max';

  @override
  String get ordersFilterApply => 'Apply filters';

  @override
  String get ordersFilterClear => 'Clear all';

  @override
  String get orderEyebrow => 'Order';

  @override
  String get orderStepReview => 'Review';

  @override
  String get orderStepCall => 'Call outcome';

  @override
  String get orderStepResult => 'Result';

  @override
  String orderCallsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count calls',
      one: '1 call',
      zero: 'no calls',
    );
    return '$_temp0';
  }

  @override
  String get orderClientSection => 'Customer';

  @override
  String get orderEditContact => 'Edit';

  @override
  String get orderEditContactDone => 'Done';

  @override
  String get orderFieldName => 'Name';

  @override
  String get orderFieldPhone => 'Phone';

  @override
  String get orderFieldAddress => 'Address';

  @override
  String get orderFieldRegion => 'Region';

  @override
  String get orderNoPhone => 'no phone';

  @override
  String get orderNoAddress => 'no address';

  @override
  String get orderPhoneHint => '0555 12 34 56';

  @override
  String get orderAddressHint => 'Wilaya, commune, street, building...';

  @override
  String get orderContactSavedWithCall =>
      'Edits are saved when you log the call outcome.';

  @override
  String get orderStopdeskChip => 'Stopdesk (agency pickup)';

  @override
  String get orderItemsSection => 'Items';

  @override
  String orderUnitLine(int qty, String price) {
    return '×$qty · $price / unit';
  }

  @override
  String get orderTotalLabel => 'Total';

  @override
  String get orderPaidLabel => 'Paid';

  @override
  String get orderRemainingLabel => 'Remaining';

  @override
  String get orderNotesSection => 'Notes';

  @override
  String get orderAttemptsSection => 'Previous attempts';

  @override
  String get orderCallHistorySection => 'Call history';

  @override
  String get orderLogCall => 'Log call outcome';

  @override
  String get orderAlreadyConfirmed => 'Already confirmed';

  @override
  String get orderClose => 'Close';

  @override
  String orderReadOnlyNotice(String status) {
    return 'This order is $status — call logging is disabled.';
  }

  @override
  String get orderReadOnlyResell => 'Create a new order to re-sell.';

  @override
  String get orderCallQuestion => 'How did the call go?';

  @override
  String get orderCallSubtitle =>
      'We’ll log the attempt and update the order accordingly.';

  @override
  String get orderOutcomeConfirmed => 'Confirmed';

  @override
  String get orderOutcomeConfirmedHint =>
      'Customer wants the order — we’ll mark it ready to ship.';

  @override
  String get orderOutcomeNoAnswer => 'No answer';

  @override
  String get orderOutcomeNoAnswerHint =>
      'Logged as attempt — stays in pending queue.';

  @override
  String get orderOutcomeBusy => 'Busy';

  @override
  String get orderOutcomeBusyHint =>
      'Try again later — stays in pending queue.';

  @override
  String get orderOutcomeVoicemail => 'Voicemail';

  @override
  String get orderOutcomeVoicemailHint =>
      'Logged as attempt — stays in pending queue.';

  @override
  String get orderOutcomeRejected => 'Rejected';

  @override
  String get orderOutcomeRejectedHint =>
      'Customer doesn’t want it — order will be cancelled.';

  @override
  String get orderCallNotesLabel => 'Notes (optional, for your records)';

  @override
  String get orderCallNotesHintConfirmed =>
      'Confirmed delivery time / delivery instructions / payment...';

  @override
  String get orderCallNotesHintRejected => 'Why did the customer reject?';

  @override
  String get orderCallNotesHintOther => 'What happened?';

  @override
  String get orderSaveOutcome => 'Save outcome';

  @override
  String get orderBackToReview => 'Back';

  @override
  String get orderNoAddressWarning => 'This order has no delivery address yet.';

  @override
  String get orderNoAddressBody =>
      'Go back to Review and edit the customer card before confirming.';

  @override
  String get orderResultConfirmedTitle => 'Order confirmed';

  @override
  String get orderResultConfirmedBody =>
      'Ready to send to your delivery provider.';

  @override
  String get orderResultCancelledTitle => 'Order cancelled';

  @override
  String get orderResultCancelledBody =>
      'Stock is restored. The recorded payment is rolled back — any actual refund is still yours to make.';

  @override
  String get orderResultAttemptTitle => 'Attempt logged';

  @override
  String orderResultAttemptBody(int count) {
    return 'Attempt #$count recorded. Stays in your pending queue.';
  }

  @override
  String get orderNextSection => 'Next: prepare & ship';

  @override
  String get orderNextBody =>
      'Send this order to your delivery provider, or mark it as preparing while you pack it.';

  @override
  String get orderSendToDelivery => 'Send to delivery';

  @override
  String get orderSendToDeliverySoon => 'Yalidine / ZR — coming soon';

  @override
  String get orderMarkPreparing => 'Mark as preparing';

  @override
  String get orderDone => 'Done';

  @override
  String get orderReturnTitle => 'Mark as returned';

  @override
  String orderReturnBody(String number) {
    return 'Are you sure you want to mark order $number as returned? Stock will be restored and the payment rolled back.';
  }

  @override
  String get orderReturnNoticeTitle => 'The refund is not automatic';

  @override
  String get orderReturnNoticeBody =>
      'Money already collected must be given back to the customer and entered as a caisse expense.';

  @override
  String get orderDeleteTitle => 'Delete order';

  @override
  String orderDeleteBody(String number) {
    return 'Are you sure you want to delete order $number? Stock will be restored.';
  }

  @override
  String get orderDeleteNoticeBody =>
      'The order, its lines and its call history are gone for good.';

  @override
  String get newOrderTitle => 'New order';

  @override
  String get newOrderClientSection => 'Client';

  @override
  String get newOrderSearchClient => 'Search a client';

  @override
  String get newOrderSearchClientHint => 'Search client by name or phone...';

  @override
  String get newOrderNoClients => 'No clients found';

  @override
  String get newOrderOrType => 'Or type';

  @override
  String get newOrderClientName => 'Client name';

  @override
  String get newOrderClientPhone => 'Phone';

  @override
  String get newOrderDeliveryAddress => 'Delivery address';

  @override
  String get newOrderWilaya => 'Wilaya';

  @override
  String get newOrderWilayaHint => 'Select wilaya…';

  @override
  String get newOrderCommune => 'Commune';

  @override
  String get newOrderCommuneHint => 'Commune (optional)';

  @override
  String get newOrderStopdesk => 'Stopdesk (agency pickup — cheaper)';

  @override
  String get newOrderProductsSection => 'Products';

  @override
  String get newOrderAddProducts => 'Add products';

  @override
  String get newOrderProductHint => 'Search product by name or SKU…';

  @override
  String get newOrderNoProducts => 'No products found';

  @override
  String newOrderVariantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variants',
      one: '1 variant',
    );
    return '$_temp0';
  }

  @override
  String newOrderInStock(int count) {
    return '$count in stock';
  }

  @override
  String get newOrderOutOfStock => 'Out of stock';

  @override
  String get newOrderQty => 'Qty';

  @override
  String get newOrderUnitPrice => 'Price (DA)';

  @override
  String get newOrderLineTotal => 'Total';

  @override
  String get newOrderNoLines => 'Search and select products above to add them';

  @override
  String get newOrderNotesSection => 'Remark / Notes';

  @override
  String get newOrderNotes => 'Notes';

  @override
  String get newOrderNotesHint => 'Add a note for this order…';

  @override
  String get newOrderSummary => 'Order summary';

  @override
  String get newOrderSubtotal => 'Subtotal';

  @override
  String get newOrderDelivery => 'Delivery';

  @override
  String get newOrderTotal => 'Total';

  @override
  String get newOrderPayInFull => 'Paid in full';

  @override
  String get newOrderAmountPaid => 'Amount paid (DA)';

  @override
  String get newOrderCodHint =>
      'Leave at 0 for COD — payment is recorded automatically on delivery.';

  @override
  String get newOrderRemainingDebt => 'Remaining (debt)';

  @override
  String get newOrderFullyPaid => 'Fully paid';

  @override
  String get newOrderPayment => 'Payment';

  @override
  String get newOrderStatus => 'Order status';

  @override
  String get newOrderPaymentMethod => 'Payment method';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodCard => 'Card';

  @override
  String get paymentMethodTransfer => 'Bank transfer';

  @override
  String get paymentMethodCcp => 'CCP';

  @override
  String get newOrderSubmit => 'Create order';

  @override
  String get newOrderStockReserved =>
      'Stock is reserved as soon as the order is created, even a pending one.';

  @override
  String get newOrderErrNoItems => 'Add at least one product';

  @override
  String get newOrderErrName => 'Client name is required';

  @override
  String get newOrderErrPhone =>
      'A phone number is required to contact the client';

  @override
  String get newOrderErrWilaya => 'Wilaya (delivery region) is required';

  @override
  String get newOrderErrAddress =>
      'Delivery address is required for home delivery (or pick Stopdesk)';

  @override
  String newOrderErrStock(String name, int count) {
    return '$name — only $count left in stock';
  }

  @override
  String get orderCreatedToast => 'Order created';

  @override
  String get orderCallLoggedToast => 'Call outcome saved';

  @override
  String get orderStatusChangedToast => 'Order updated';

  @override
  String get orderReturnedToast => 'Order marked as returned';

  @override
  String get orderDeletedToast => 'Order deleted';

  @override
  String newOrderDraftLinesDropped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count lines from your draft could not be restored: the products are gone or out of stock.',
      one: '1 line from your draft could not be restored: the product is gone or out of stock.',
    );
    return '$_temp0';
  }

  @override
  String get productsFilterPriceMin => 'Selling price (DA) · min';

  @override
  String get productsFilterPriceMax => 'Selling price (DA) · max';

  @override
  String get productsFilterCostMin => 'Cost price (DA) · min';

  @override
  String get productsFilterCostMax => 'Cost price (DA) · max';

  @override
  String get productsFilterQtyMin => 'Quantity · min';

  @override
  String get productsFilterQtyMax => 'Quantity · max';

  @override
  String get productsFilterProfitMin => 'Net profit (DA) · min';

  @override
  String get productsFilterProfitMax => 'Net profit (DA) · max';

  @override
  String get productsFilterMarginMin => 'Margin (%) · min';

  @override
  String get productsFilterMarginMax => 'Margin (%) · max';

  @override
  String get productsSectionInactive => 'INACTIVE PRODUCTS';

  @override
  String get menuDelivery => 'Delivery';

  @override
  String get deliveryEyebrow => 'SALES';

  @override
  String get deliveryTitle => 'Delivery';

  @override
  String get deliverySubtitle =>
      'Send orders to delivery companies and track shipments';

  @override
  String get deliveryFeesAction => 'Fees';

  @override
  String get deliveryProvidersAction => 'Providers';

  @override
  String get deliveryRefresh => 'Refresh';

  @override
  String get deliveryStatReady => 'READY TO SHIP';

  @override
  String get deliveryStatShipped => 'SHIPPED';

  @override
  String get deliveryStatInTransit => 'IN TRANSIT';

  @override
  String get deliveryStatDelivered => 'DELIVERED';

  @override
  String get deliverySearchLabel => 'SEARCH';

  @override
  String get deliverySearchPlaceholder => 'Search orders...';

  @override
  String get deliveryTabAll => 'All';

  @override
  String get deliveryTabReady => 'Ready';

  @override
  String get deliveryTabSent => 'Sent';

  @override
  String get deliveryTabInTransit => 'In Transit';

  @override
  String get deliveryTabDelivered => 'Delivered';

  @override
  String get deliveryOrdersSection => 'ORDERS';

  @override
  String get deliveryPillNotSent => 'NOT SENT';

  @override
  String get deliveryPillSent => 'SENT';

  @override
  String get deliveryPillInTransit => 'IN TRANSIT';

  @override
  String get deliveryPillDelivered => 'DELIVERED';

  @override
  String deliveryMetaLine(String provider, String tracking) {
    return 'PROVIDER $provider  ·  TRACKING $tracking';
  }

  @override
  String get deliverySend => 'Send';

  @override
  String get deliveryTrack => 'Track';

  @override
  String get deliveryLabel => 'Label';

  @override
  String get deliveryEmptyTitle => 'No orders';

  @override
  String get deliveryEmptyBody =>
      'Orders show up here, ready to be sent to a delivery company.';

  @override
  String get deliveryNoMatchTitle => 'No matches';

  @override
  String get deliveryNoMatchBody => 'Try another word or another tab.';

  @override
  String deliverySendTitle(String order) {
    return 'Send $order to Delivery';
  }

  @override
  String get deliveryClient => 'Client';

  @override
  String get deliveryPhone => 'Phone';

  @override
  String get deliveryAddress => 'Address';

  @override
  String get deliveryTotal => 'Total';

  @override
  String get deliveryProviderLabel => 'DELIVERY PROVIDER';

  @override
  String deliveryProviderDefault(String name) {
    return '$name (Default)';
  }

  @override
  String get deliveryDestination => 'DESTINATION WILAYA';

  @override
  String get deliveryChooseWilaya => 'Choose a wilaya';

  @override
  String get deliveryStopdesk => 'Stop desk delivery';

  @override
  String get deliveryNote => 'NOTE';

  @override
  String get deliveryNotePlaceholder =>
      'Optional note for the delivery company...';

  @override
  String get deliveryRates => 'ESTIMATED RATES';

  @override
  String get deliveryRateHome => 'Home Delivery';

  @override
  String get deliveryRateStopdesk => 'Stop Desk';

  @override
  String get deliveryConfirmSend => 'Confirm & Send';

  @override
  String get deliveryNoProviders => 'No delivery providers configured';

  @override
  String get deliveryAddProvider => 'Add Provider';

  @override
  String deliverySentToast(String order, String provider) {
    return '$order sent to $provider';
  }

  @override
  String deliveryTrackTitle(String order) {
    return 'Tracking — $order';
  }

  @override
  String deliveryCourierResponse(String provider) {
    return 'COURIER RESPONSE · $provider';
  }

  @override
  String get deliveryTrackEmpty => 'The courier returned no information.';

  @override
  String get deliveryLabelNotReady =>
      'The courier has not produced a label yet.';

  @override
  String get deliveryLabelOpenFailed =>
      'The label could not be opened on this phone.';

  @override
  String get deliveryFeesEyebrow => 'DELIVERY';

  @override
  String get deliveryFeesTitle => 'Delivery Fees';

  @override
  String get deliveryFeesSubtitle =>
      'Set your shipping price per wilaya. Used automatically when creating orders and by the AI agent for Messenger quotes.';

  @override
  String get deliveryFeesFillMissing => 'Fill missing';

  @override
  String get deliveryFeesResetAll => 'Reset all to defaults';

  @override
  String get deliveryFeesSearch => 'Search wilaya…';

  @override
  String get deliveryFeesSection => 'WILAYAS';

  @override
  String get deliveryFeesDefault => 'DEFAULT';

  @override
  String get deliveryFeesCustom => 'CUSTOM';

  @override
  String get deliveryFeesHome => 'HOME (DA)';

  @override
  String get deliveryFeesStopdesk => 'STOPDESK (DA)';

  @override
  String get deliveryFeesReturn => 'RETURN (DA)';

  @override
  String get deliveryFeesReset => 'Reset';

  @override
  String get deliveryFeesResetAllTitle => 'Reset all to defaults';

  @override
  String get deliveryFeesResetAllBody =>
      'Overwrite all your custom prices with system defaults?';

  @override
  String deliveryFeesSaved(String wilaya) {
    return '$wilaya fees saved';
  }

  @override
  String deliveryFeesResetDone(String wilaya) {
    return '$wilaya is back to the default fees';
  }

  @override
  String deliveryFeesFilled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wilayas filled',
      one: '1 wilaya filled',
      zero: 'Nothing to fill: every wilaya already has its fees',
    );
    return '$_temp0';
  }

  @override
  String get deliveryFeesResetAllDone => 'All fees are back to the defaults';

  @override
  String get deliveryProvidersTitle => 'Delivery Providers';

  @override
  String get deliveryProvidersSubtitle =>
      'Configure delivery companies for shipping orders';

  @override
  String get deliveryProvidersSection => 'PROVIDERS';

  @override
  String get deliveryDefaultBadge => 'DEFAULT';

  @override
  String get deliveryCardProvider => 'Provider:';

  @override
  String get deliveryCardSender => 'Sender:';

  @override
  String get deliveryCardPhone => 'Phone:';

  @override
  String get deliveryCardWilaya => 'Wilaya:';

  @override
  String get deliveryEdit => 'Edit';

  @override
  String get deliveryProvidersEmptyTitle => 'No providers configured';

  @override
  String get deliveryProvidersEmptyBody =>
      'Add a delivery provider to start shipping orders';

  @override
  String get deliveryDeleteTitle => 'Delete Provider';

  @override
  String get deliveryDeleteBody =>
      'Are you sure you want to remove this delivery provider? This cannot be undone.';

  @override
  String deliveryProviderDeleted(String name) {
    return '$name deleted';
  }

  @override
  String get deliveryFormAddTitle => 'Add Provider';

  @override
  String get deliveryFormEditTitle => 'Edit Delivery Provider';

  @override
  String get deliveryFormCourier => 'DELIVERY PROVIDER';

  @override
  String get deliveryFormChooseCourier => 'Choose a provider';

  @override
  String get deliveryFormDisplayName => 'DISPLAY NAME';

  @override
  String get deliveryFormCredentials => 'API CREDENTIALS';

  @override
  String get deliveryFormUnchanged => '(unchanged — enter to update)';

  @override
  String get deliveryFormTest => 'Test Credentials';

  @override
  String deliveryFormTestOk(String name) {
    return 'Credentials are valid — connected to $name.';
  }

  @override
  String deliveryFormTestFailed(String name, String reason) {
    return '$name refused the connection: $reason';
  }

  @override
  String get deliveryFormSender => 'SENDER INFORMATION';

  @override
  String get deliveryFormSenderName => 'SENDER NAME';

  @override
  String get deliveryFormSenderPhone => 'SENDER PHONE';

  @override
  String get deliveryFormSenderAddress => 'SENDER ADDRESS';

  @override
  String get deliveryFormSenderWilaya => 'SENDER WILAYA';

  @override
  String get deliveryFormSetDefault => 'Set as default provider';

  @override
  String get deliveryFormAdd => 'Add Provider';

  @override
  String get deliveryFormUpdate => 'Update';

  @override
  String deliveryProviderAdded(String name) {
    return '$name added';
  }

  @override
  String deliveryProviderUpdated(String name) {
    return '$name updated';
  }

  @override
  String get deliveryFormAllTaken =>
      'Every supported provider is already configured.';

  @override
  String get deliveryDeleteNoticeTitle => 'Orders already sent';

  @override
  String deliveryDeleteNoticeBody(String name) {
    return 'Those sent with $name keep their tracking number, but can no longer be tracked or have their label printed.';
  }

  @override
  String get deliveryDeleteNoticeDefault =>
      'This is your default provider: choose another one afterwards.';

  @override
  String deliveryProviderAlreadyGone(String name) {
    return '$name had already been deleted';
  }

  @override
  String get menuSales => 'Sales';

  @override
  String get salesEyebrow => 'SALES';

  @override
  String get salesTitle => 'Sales';

  @override
  String salesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sales',
      one: '1 sale',
    );
    return '$_temp0';
  }

  @override
  String get salesPeriodToday => 'Today';

  @override
  String get salesPeriodWeek => 'Week';

  @override
  String get salesPeriodMonth => 'Month';

  @override
  String get salesPeriodYear => 'Year';

  @override
  String get salesStatTotal => 'Total sales';

  @override
  String get salesStatRevenue => 'Revenue';

  @override
  String get salesStatAverage => 'Avg order value';

  @override
  String get salesStatPending => 'Pending';

  @override
  String get salesSearch => 'Search sales…';

  @override
  String get salesQuickAll => 'All';

  @override
  String get salesQuickPaid => 'Paid';

  @override
  String get salesQuickRemaining => 'Remaining';

  @override
  String get salesSection => 'All sales';

  @override
  String get salesView => 'View';

  @override
  String get salesNew => 'New sale';

  @override
  String get salesEmptyTitle => 'No sales';

  @override
  String get salesEmptyBody => 'Record your first sale to track revenue';

  @override
  String get salesNoMatchBody => 'No sale matches these filters.';

  @override
  String get salesFilterMethodAny => 'All methods';

  @override
  String get saleStatusPaid => 'Paid';

  @override
  String get saleStatusPending => 'Pending';

  @override
  String get saleStatusPartial => 'Partial';

  @override
  String get saleDeleteTitle => 'Delete sale';

  @override
  String saleDeleteBody(String number) {
    return 'Are you sure you want to delete sale $number?';
  }

  @override
  String get saleDeleteNotice =>
      'This action cannot be undone. Stock quantities will be restored.';

  @override
  String saleDeletedToast(String number) {
    return 'Sale $number deleted';
  }

  @override
  String saleAlreadyGone(String number) {
    return 'Sale $number had already been deleted';
  }

  @override
  String get saleEyebrow => 'SALE';

  @override
  String get saleFieldCustomer => 'Customer';

  @override
  String get saleFieldPhone => 'Phone';

  @override
  String get saleFieldDate => 'Date';

  @override
  String get saleFieldMethod => 'Payment method';

  @override
  String get saleFieldItems => 'Items';

  @override
  String get saleWalkIn => 'Walk-in customer';

  @override
  String get saleItemsSection => 'Items';

  @override
  String saleLineMeta(int qty, String price) {
    return '×$qty  ·  $price';
  }

  @override
  String saleLineDiscount(String amount) {
    return 'Discount $amount';
  }

  @override
  String get saleSubtotal => 'Subtotal';

  @override
  String get saleDiscount => 'Discount';

  @override
  String get saleTax => 'Tax';

  @override
  String get saleTotal => 'Total';

  @override
  String get salePaymentStatus => 'Payment status';

  @override
  String get saleMarkPaid => 'Mark as paid';

  @override
  String get saleEdit => 'Edit';

  @override
  String get saleMarkedPaidToast => 'Sale marked as paid';

  @override
  String saleEditTitle(String number) {
    return 'Edit sale $number';
  }

  @override
  String get saleEditSubtitle =>
      'Update payment and notes. Items and prices cannot be changed once a sale is recorded.';

  @override
  String get saleMethodHint => 'Choose a method';

  @override
  String get saleEditPartialMissing => 'Enter the amount received';

  @override
  String saleEditPartialTooHigh(String total) {
    return 'Must be below the total ($total) — otherwise choose “Paid”';
  }

  @override
  String saleEditCaisse(String from, String to) {
    return 'The cash register will go from $from to $to.';
  }

  @override
  String get saleEditSave => 'Save changes';

  @override
  String get saleUpdatedToast => 'Sale updated';

  @override
  String get saleEditLeaveBody => 'Your changes will be lost.';

  @override
  String get newSaleNotesHint => 'Add a note for this sale…';

  @override
  String get newSaleSummary => 'Payment summary';

  @override
  String get newSaleFullyPaid => 'Fully paid';

  @override
  String get newSaleStatus => 'Status';

  @override
  String get newSalePayInFull => 'Paid in full';

  @override
  String newSaleChangeDue(String amount) {
    return 'Change due: $amount';
  }

  @override
  String get newSaleSubmit => 'Complete sale';

  @override
  String get newSaleStockNote =>
      'Stock is deducted as soon as the sale is recorded.';

  @override
  String get newSaleErrPhone => 'Incomplete phone number';

  @override
  String newSaleCreatedToast(String number) {
    return 'Sale $number recorded';
  }

  @override
  String get newSaleDateTitle => 'Sale date';

  @override
  String get newSaleLeaveBody => 'The sale you started will be lost.';

  @override
  String get menuPurchases => 'Purchases';

  @override
  String get menuMovements => 'Movements';

  @override
  String get purchasesEyebrow => 'PURCHASES';

  @override
  String get purchasesTitle => 'Purchases';

  @override
  String purchasesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count purchases',
      one: '1 purchase',
    );
    return '$_temp0';
  }

  @override
  String get purchasesStatTotal => 'Total purchases';

  @override
  String get purchasesStatSpent => 'Total spent';

  @override
  String get purchasesStatToReceive => 'To receive';

  @override
  String get purchasesStatReceived => 'Received';

  @override
  String get purchasesSearch => 'Search purchases…';

  @override
  String get purchasesQuickAll => 'All';

  @override
  String get purchasesQuickPaid => 'Paid';

  @override
  String get purchasesQuickToPay => 'To pay';

  @override
  String get purchasesSection => 'All purchases';

  @override
  String purchasesRowMeta(String items, String paid, String remaining) {
    return '$items  ·  PAID $paid  ·  TO PAY $remaining';
  }

  @override
  String get purchasesReceive => 'Receive';

  @override
  String get purchasesNew => 'New purchase';

  @override
  String get purchasesEmptyTitle => 'No purchases';

  @override
  String get purchasesEmptyBody => 'Record your first purchase from a supplier';

  @override
  String get purchasesNoMatchBody => 'No purchase matches these filters.';

  @override
  String get purchasesFilterStatus => 'Fulfillment status';

  @override
  String get purchasesFilterSupplierAny => 'All suppliers';

  @override
  String get purchasesFilterHasRemaining => 'Still owed to supplier';

  @override
  String get purchaseStatusPending => 'To receive';

  @override
  String get purchaseStatusPartial => 'Partly received';

  @override
  String get purchaseStatusReceived => 'Received';

  @override
  String get purchaseStatusCancelled => 'Cancelled';

  @override
  String get purchasePayPending => 'Unpaid';

  @override
  String get purchasePayPartial => 'Partly paid';

  @override
  String get purchasePayPaid => 'Paid';

  @override
  String get purchaseDeleteTitle => 'Delete purchase';

  @override
  String purchaseDeleteBody(String number) {
    return 'Are you sure you want to delete purchase $number?';
  }

  @override
  String get purchaseDeleteNotice => 'This action cannot be undone.';

  @override
  String purchaseDeletedToast(String number) {
    return 'Purchase $number deleted';
  }

  @override
  String purchaseAlreadyGone(String number) {
    return 'Purchase $number had already been deleted';
  }

  @override
  String get purchaseEyebrow => 'PURCHASE';

  @override
  String get purchaseFieldSupplier => 'Supplier';

  @override
  String get purchaseFieldReceiving => 'Receiving';

  @override
  String get purchaseFieldPayment => 'Payment';

  @override
  String get purchaseFieldPaid => 'Amount paid';

  @override
  String get purchaseFieldRemaining => 'Still to pay';

  @override
  String get purchaseFieldReceivedOn => 'Received on';

  @override
  String get purchaseNoSupplier => 'No supplier';

  @override
  String purchaseLineMeta(int ordered, int received, String cost) {
    return 'Ordered $ordered  ·  Received $received  ·  Cost $cost / unit';
  }

  @override
  String get purchaseMarkPaid => 'Mark as paid';

  @override
  String get purchaseMarkedPaidToast => 'Purchase marked as paid';

  @override
  String get purchaseReceiveDelivery => 'Receive delivery';

  @override
  String get purchaseCancel => 'Cancel purchase';

  @override
  String get purchaseCancelKeep => 'Keep purchase';

  @override
  String purchaseCancelBody(String number) {
    return 'Purchase $number will be cancelled.';
  }

  @override
  String get purchaseCancelNoticeTitle => 'What will happen';

  @override
  String purchaseCancelStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count units already received will be taken out of stock.',
      one: '1 unit already received will be taken out of stock.',
    );
    return '$_temp0';
  }

  @override
  String purchaseCancelMoney(String amount) {
    return 'The $amount payment will be removed from the cash register. Record the supplier’s refund yourself.';
  }

  @override
  String get purchaseCancelFinal =>
      'A cancelled purchase can no longer be received or paid.';

  @override
  String purchaseCancelledToast(String number) {
    return 'Purchase $number cancelled';
  }

  @override
  String get receiveBody =>
      'Enter the quantity the supplier delivered for each item. Stock will be updated automatically.';

  @override
  String receiveLineMeta(int ordered, int received) {
    return 'Ordered $ordered  ·  Already received $received';
  }

  @override
  String get receiveNowLabel => 'Received now';

  @override
  String receiveToCome(int count) {
    return '$count to receive';
  }

  @override
  String get receiveComplete => 'Complete';

  @override
  String receiveOver(int count) {
    return 'At most $count';
  }

  @override
  String get receiveSubmit => 'Confirm receipt';

  @override
  String get receiveNothing => 'Enter at least one quantity';

  @override
  String get receivedToast => 'Receipt recorded · stock updated';

  @override
  String get newPurchaseSearchSupplier => 'Search supplier';

  @override
  String get newPurchaseSearchSupplierHint =>
      'Search supplier by name or phone…';

  @override
  String get newPurchaseNoSuppliers => 'No supplier found';

  @override
  String get newPurchaseUnitCost => 'Unit cost (DA)';

  @override
  String get newPurchaseNotesHint => 'Add a note for this purchase…';

  @override
  String get newPurchaseSummary => 'Payment to supplier';

  @override
  String get newPurchaseAmountPaid => 'Amount paid to supplier (DA)';

  @override
  String get newPurchaseFullyPaid => 'Fully paid';

  @override
  String get newPurchasePayInFull => 'Pay in full';

  @override
  String newPurchaseOverpaid(String total) {
    return 'More than the total: only $total will be recorded.';
  }

  @override
  String get newPurchaseStockNote =>
      'Stock is added when the delivery is received.';

  @override
  String get newPurchaseSubmit => 'Save purchase';

  @override
  String newPurchaseCreatedToast(String number) {
    return 'Purchase $number saved';
  }

  @override
  String get newPurchaseDateTitle => 'Purchase date';

  @override
  String get newPurchaseLeaveBody => 'The purchase you started will be lost.';

  @override
  String get movementsEyebrow => 'STOCK';

  @override
  String get movementsTitle => 'Stock movements';

  @override
  String get movementsSubtitle => 'Audit trail of all stock changes';

  @override
  String get movementsSection => 'Movements';

  @override
  String get movementsEmptyTitle => 'No movements';

  @override
  String get movementsEmptyBody =>
      'Stock movements will appear here when products are added, sold, or adjusted';

  @override
  String get movementsNoMatchBody => 'No movement matches these filters.';

  @override
  String get movementsFilterType => 'Movement type';

  @override
  String get movementsFilterTypeAny => 'All types';

  @override
  String get movementsFilterProduct => 'Product';

  @override
  String get movementsFilterProductAny => 'All products';

  @override
  String movementReasonSale(String number) {
    return 'Sale $number';
  }

  @override
  String movementReasonSaleDeleted(String number) {
    return 'Sale $number deleted';
  }

  @override
  String movementReasonPurchase(String number) {
    return 'Purchase received $number';
  }

  @override
  String movementReasonPurchaseCancelled(String number) {
    return 'Purchase $number cancelled';
  }

  @override
  String movementReasonOrder(String number) {
    return 'Order $number';
  }

  @override
  String movementReasonOrderCancelled(String number) {
    return 'Cancelled order $number';
  }

  @override
  String movementReasonOrderReturned(String number) {
    return 'Returned order $number';
  }

  @override
  String movementReasonOrderDeleted(String number) {
    return 'Deleted order $number';
  }

  @override
  String get movementReasonInitial => 'Initial stock';

  @override
  String get movementReasonVariantDeleted => 'Variant deleted';
}
